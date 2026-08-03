"""
VOLYA - make a generated mesh acceptable to Mixamo's auto-rigger.

Image-to-3D tools hand back whatever density their reconstruction produced,
which can be a million vertices for a single character. Mixamo refuses or
stalls on files like that, and none of that density survives being rendered at
96 pixels anyway.

Does the four things the auto-rigger cares about:

  1. deletes everything that is not a mesh - cameras, lights, empties, which
     the rigger explicitly cannot cope with
  2. joins the remaining meshes into one, because it cannot rig a body made of
     separate pieces
  3. reduces the polygon count to a target
  4. puts the character on the world origin

Run through Blender, headless:

    blender --background --python tools/prepare_for_mixamo.py -- \
        --in model.fbx --out model_mixamo.fbx --tris 30000

Textures are kept and embedded, so Mixamo gets a textured character back.
"""

import math
import os
import sys

import bpy


DEFAULTS = {
    "in": "",
    "out": "",
    "tris": 30000,       # comfortably under anything Mixamo has ever refused
    "embed": 1,          # 1 = pack textures into the FBX
    "up": "auto",        # auto, or x / y / z to overrule the guess
}


def parse_args():
    cfg = dict(DEFAULTS)
    argv = sys.argv
    if "--" not in argv:
        return cfg
    argv = argv[argv.index("--") + 1:]
    i = 0
    while i < len(argv):
        key = argv[i]
        if not key.startswith("--"):
            i += 1
            continue
        key = key[2:]
        value = argv[i + 1] if i + 1 < len(argv) else ""
        if key in cfg:
            cfg[key] = int(float(value)) if isinstance(cfg[key], int) else value
        else:
            print("VOLYA: neznamy argument --%s (ignorujem)" % key)
        i += 2
    return cfg


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def import_any(path):
    lower = path.lower()
    if lower.endswith(".fbx"):
        bpy.ops.import_scene.fbx(filepath=path)
    elif lower.endswith(".obj"):
        # Blender 4.x renamed the OBJ importer; try the new one first.
        try:
            bpy.ops.wm.obj_import(filepath=path)
        except AttributeError:
            bpy.ops.import_scene.obj(filepath=path)
    elif lower.endswith((".glb", ".gltf")):
        bpy.ops.import_scene.gltf(filepath=path)
    else:
        raise RuntimeError("neznamy format: %s" % path)


def stand_upright(body, forced):
    """Turn a model that came in lying down.

    Exporters disagree about which axis is up, and a character on its back
    rigs badly or not at all. The bounding box alone cannot decide it: in a
    T-pose the arm span and the height are nearly the same number, which is
    exactly the case seen here (1.78 x 1.78 x 0.34).

    What does separate them is where the mass sits. Along the arm-span axis
    almost everything is in the middle - torso, hips, legs - and the outer
    fifth holds only forearms and hands. Along the height axis the outer fifth
    holds the head at one end and the boots at the other, which is far more.
    So the height axis is the one with the fuller ends.
    """
    coords = [body.matrix_world @ v.co for v in body.data.vertices]
    total = len(coords)
    if total == 0:
        return

    scores = {}
    for axis in range(3):
        values = [c[axis] for c in coords]
        low, high = min(values), max(values)
        span = high - low
        if span < 1e-6:
            scores[axis] = (0.0, span)
            continue
        edge = span * 0.2
        ends = sum(1 for v in values if v < low + edge or v > high - edge)
        scores[axis] = (ends / float(total), span)

    for axis, name in enumerate("XYZ"):
        share, span = scores[axis]
        print("VOLYA: os %s  dlzka %.2f  v krajnych patinach %.0f %% vrcholov"
              % (name, span, share * 100))

    if forced in ("x", "y", "z"):
        up = "xyz".index(forced)
        print("VOLYA: os nahor zadana rucne: %s" % forced.upper())
    else:
        # Only axes of a plausible length compete; a thin axis is the body's
        # depth and can never be its height.
        longest = max(s[1] for s in scores.values())
        candidates = [a for a in range(3) if scores[a][1] > longest * 0.6]
        up = max(candidates, key=lambda a: scores[a][0])
        print("VOLYA: os nahor urcena ako %s" % "XYZ"[up])

    if up == 2:
        print("VOLYA: postava uz stoji")
        return

    body.rotation_euler = (math.radians(90.0), 0.0, 0.0) if up == 1 \
        else (0.0, math.radians(-90.0), 0.0)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    print("VOLYA: postava otocena do stoja")


def rescue_textures(out_dir):
    """Write the model's textures out as real files.

    A generated FBX stores its texture inside the file and Blender keeps the
    reference as a name like '*0'. That is not a path, so exporting fails with
    'Invalid argument' and the model leaves without its colours - which shows
    up later as a grey character in the game.
    """
    saved = 0
    for image in bpy.data.images:
        if not image.has_data or image.size[0] == 0:
            continue
        name = bpy.path.clean_name(image.name) or "texture"
        if not name.lower().endswith((".png", ".jpg", ".jpeg")):
            name += ".png"
        path = os.path.join(out_dir, name)
        try:
            image.filepath_raw = path
            image.file_format = "PNG" if name.lower().endswith(".png") \
                else "JPEG"
            image.save()
            image.filepath = path
            saved += 1
            print("VOLYA: textura ulozena %s (%dx%d)"
                  % (name, image.size[0], image.size[1]))
        except Exception as exc:
            print("VOLYA: texturu %s sa nepodarilo ulozit (%s)"
                  % (image.name, exc))
    if saved == 0:
        print("VOLYA: POZOR - model nema ziadnu texturu, bude sedy")
    return saved


def triangle_count(objects):
    total = 0
    for obj in objects:
        mesh = obj.data
        for polygon in mesh.polygons:
            total += max(1, len(polygon.vertices) - 2)
    return total


def main():
    cfg = parse_args()
    if not cfg["in"]:
        sys.exit("VOLYA: chyba --in")
    source = os.path.abspath(cfg["in"])
    target = os.path.abspath(cfg["out"] or
                             os.path.splitext(source)[0] + "_mixamo.fbx")

    clear_scene()
    import_any(source)

    # 1. anything that is not a mesh confuses the auto-rigger
    removed = 0
    for obj in list(bpy.context.scene.objects):
        if obj.type != "MESH":
            bpy.data.objects.remove(obj, do_unlink=True)
            removed += 1
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not meshes:
        sys.exit("VOLYA: v subore nie je ziadna siet.")
    print("VOLYA: odstranene ne-mesh objekty: %d" % removed)

    before = triangle_count(meshes)
    print("VOLYA: na vstupe %d sieti, %s trojuholnikov"
          % (len(meshes), f"{before:,}".replace(",", " ")))

    # 2. one body, one mesh
    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
        print("VOLYA: siete spojene do jednej")
    body = bpy.context.view_layer.objects.active

    # 3. reduce, but only downwards - Decimate cannot add detail
    goal = int(cfg["tris"])
    if goal <= 0:
        print("VOLYA: redukcia vypnuta (--tris 0)")
    elif before > goal:
        if body.data.uv_layers:
            print("VOLYA: POZOR - model ma UV mapu a redukcia ju rozhadze. "
                  "Ak nemusis, pouzi --tris 0.")
        goal = max(1000, goal)
        modifier = body.modifiers.new("VOLYA_Decimate", "DECIMATE")
        modifier.decimate_type = "COLLAPSE"
        modifier.ratio = goal / float(before)
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        after = triangle_count([body])
        print("VOLYA: zredukovane na %s trojuholnikov (pomer %.4f)"
              % (f"{after:,}".replace(",", " "), modifier.ratio))
    else:
        print("VOLYA: redukcia netreba, model je uz pod cielom")

    # 4. standing up, centred on the origin, feet on zero
    bpy.ops.object.select_all(action="DESELECT")
    body.select_set(True)
    bpy.context.view_layer.objects.active = body
    stand_upright(body, cfg["up"].lower())

    bpy.ops.object.origin_set(type="ORIGIN_GEOMETRY", center="BOUNDS")
    body.location = (0.0, 0.0, 0.0)
    bpy.context.view_layer.update()
    lowest = min((body.matrix_world @ v.co).z for v in body.data.vertices)
    body.location.z -= lowest
    bpy.context.view_layer.update()

    size = body.dimensions
    print("VOLYA: rozmery sirka %.2f  hlbka %.2f  vyska %.2f"
          % (size.x, size.y, size.z))
    if size.z < max(size.x, size.y) * 0.6:
        print("VOLYA: POZOR - postava je stale nizsia nez sirsia, mozno lezi.")
        print("VOLYA: skus to prebit rucne: --up x  alebo  --up y")

    # Without a UV map there is nowhere to put a texture, and the character
    # arrives in the game grey no matter what is supplied later. Worth saying
    # before the file is uploaded, not after the render comes back colourless.
    print("VOLYA: UV mapy: %d" % len(body.data.uv_layers))
    if not body.data.uv_layers:
        print("VOLYA: POZOR - bez UV mapy bude postava vzdy jednofarebna.")
        print("VOLYA: pouzi ako vstup ten export, ktory textury nesie "
              "(u Meshy je to GLB, nie FBX).")

    # 5. textures out to real files before export, or they are lost
    rescue_textures(os.path.dirname(target))

    bpy.ops.export_scene.fbx(
        filepath=target,
        use_selection=False,
        path_mode="COPY" if int(cfg["embed"]) else "AUTO",
        embed_textures=bool(int(cfg["embed"])),
        mesh_smooth_type="FACE",
        add_leaf_bones=False,
    )
    megabytes = os.path.getsize(target) / 1e6
    print("VOLYA: ulozene %s (%.1f MB)" % (target, megabytes))
    if megabytes > 60:
        print("VOLYA: stale velke - skus --tris mensie alebo --embed 0")


if __name__ == "__main__":
    main()
