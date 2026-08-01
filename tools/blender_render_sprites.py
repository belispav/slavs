"""
VOLYA - Blender sprite renderer.

Renders the animation currently loaded in a .blend / imported FBX into a PNG
sequence with a transparent background, using an orthographic side view.
Frame consistency is structural: every frame comes from the same model, so
frames can never drift apart the way hand-drawn or AI-generated ones do.

Usage (headless, from a normal terminal):

    blender scene.blend --background --python tools/blender_render_sprites.py -- \
        --out volya/art/hero_run --name run --height 96 --step 3

Usage (inside Blender): open the Scripting tab, load this file, edit
DEFAULTS below, press Run.

Everything is auto-framed, so the import scale of the model does not matter.
"""

import os
import sys
import math

import bpy
import mathutils


# Used when the script is run from Blender's UI (no command line arguments).
DEFAULTS = {
    "out": "//sprites",
    "name": "anim",
    "height": 96,      # rendered pixel height of one frame
    "step": 3,         # render every Nth frame (30 fps mocap / 3 = 10 fps sprite)
    "angles": 1,       # 1 = single view; 8 = full 45-degree turnaround
    "start_angle": -1.0,  # -1 = work the side view out from the model itself
    "preview": 0,      # 1 = one frame from 8 angles, to pick the side view
    "margin": 1.35,    # extra room around the rest-pose bounding box
    "engine": "auto",
    "samples": 32,
    "sun": 4.0,
    # --- pixel-art mode ------------------------------------------------------
    "toon": 1,         # 1 = flat cel-banded materials instead of the originals
    "bands": 3,        # how many hard steps of light on a surface
    "shadow": 0.38,    # darkest band, as a fraction of the base colour
    "pixel": 1,        # 1 = no anti-aliasing, so every pixel is a real pixel
    "material_colours": "",  # "Alpha_Body=C08A6B,Alpha_Joints=6B5540"
    "texture_size": 48,  # shrink textures to this before use; 0 = leave alone
}


# --------------------------------------------------------------------- args --

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
            current = cfg[key]
            if isinstance(current, bool):
                cfg[key] = value.lower() not in ("0", "false", "no")
            elif isinstance(current, int):
                cfg[key] = int(float(value))
            elif isinstance(current, float):
                cfg[key] = float(value)
            else:
                cfg[key] = value
        else:
            print("VOLYA: unknown argument --%s (ignored)" % key)
        i += 2
    return cfg


# ------------------------------------------------------------------- engine --

def pick_engine(preferred):
    """Blender renamed the EEVEE engine id between versions - resolve it safely."""
    try:
        available = list(
            bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items.keys())
    except Exception:
        available = []
    if preferred != "auto" and preferred in available:
        return preferred
    for candidate in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE", "BLENDER_WORKBENCH"):
        if candidate in available:
            return candidate
    return available[0] if available else "BLENDER_WORKBENCH"


# ------------------------------------------------------------------ framing --

def visible_mesh_bounds():
    """World-space bounding box of every visible mesh, in rest pose."""
    lo = mathutils.Vector((1e12, 1e12, 1e12))
    hi = mathutils.Vector((-1e12, -1e12, -1e12))
    found = False
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        try:
            if not obj.visible_get():
                continue
        except Exception:
            pass
        for corner in obj.bound_box:
            world = obj.matrix_world @ mathutils.Vector(corner)
            for axis in range(3):
                lo[axis] = min(lo[axis], world[axis])
                hi[axis] = max(hi[axis], world[axis])
            found = True
    if not found:
        raise RuntimeError("No visible mesh in the scene - did the FBX import fail?")
    return lo, hi


def _normalised_bone_names(armature_object):
    table = {}
    for bone in armature_object.data.bones:
        key = "".join(ch for ch in bone.name.lower() if ch.isalnum())
        table[key] = bone
    return table


def _find_bone(table, side, part):
    for key, bone in table.items():
        if side in key and part in key:
            return bone
    return None


def shoulder_axis():
    """Left-to-right axis of the body, taken from the rig's rest pose.

    Bone rest positions do not move with the animation, which is the whole
    point: a running character swings its arms and legs far along the direction
    of travel, so the mesh bounding box says the model is deepest front-to-back
    and any guess based on it points the camera at the character's face.
    """
    for obj in bpy.context.scene.objects:
        if obj.type != "ARMATURE":
            continue
        table = _normalised_bone_names(obj)
        vectors = []
        for part in ("shoulder", "arm", "upleg", "hand", "leg"):
            left = _find_bone(table, "left", part)
            right = _find_bone(table, "right", part)
            if left is None or right is None:
                continue
            head_l = obj.matrix_world @ left.head_local
            head_r = obj.matrix_world @ right.head_local
            span = head_r - head_l
            if span.length > 1e-5:
                vectors.append(span)
        if vectors:
            total = mathutils.Vector((0.0, 0.0, 0.0))
            for v in vectors:
                # flip any vector pointing the other way before averaging,
                # otherwise a mirrored pair cancels the sum out
                total += v if v.dot(vectors[0]) >= 0 else -v
            print("VOLYA: os ramien urcena z %d kosti rigu" % len(vectors))
            return total
    return None


def rest_pose_bounds():
    """Bounding box with the armature forced back to its rest pose."""
    changed = []
    for obj in bpy.context.scene.objects:
        if obj.type == "ARMATURE" and obj.data.pose_position != "REST":
            obj.data.pose_position = "REST"
            changed.append(obj)
    if changed:
        bpy.context.view_layer.update()
    bounds = visible_mesh_bounds()
    for obj in changed:
        obj.data.pose_position = "POSE"
    if changed:
        bpy.context.view_layer.update()
    return bounds


def side_view_azimuth():
    """Camera angle that puts the character in profile.

    The camera at azimuth A looks along (-sin A, cos A). A side view means
    looking straight down the shoulder axis, so A = atan2(-sx, sy).

    Left profile or right profile is not decided here - that is a horizontal
    flip in Godot and costs nothing.
    """
    axis = shoulder_axis()
    if axis is None:
        lo, hi = rest_pose_bounds()
        span_x, span_y = hi[0] - lo[0], hi[1] - lo[1]
        axis = mathutils.Vector((1.0, 0.0, 0.0) if span_x >= span_y
                                else (0.0, 1.0, 0.0))
        print("VOLYA: rig sa nenasiel, os odhadnuta z rozmerov v kludovej poze "
              "(X=%.2f Y=%.2f)" % (span_x, span_y))

    flat = mathutils.Vector((axis[0], axis[1]))
    if flat.length < 1e-6:
        print("VOLYA: os ramien je zvisla, pouzivam 0 stupnov")
        return 0.0
    flat.normalize()
    azimuth = math.degrees(math.atan2(-flat[0], flat[1])) % 360.0
    print("VOLYA: bocny pohlad je %.0f stupnov" % azimuth)
    return azimuth


# ------------------------------------------------------------------ shading --

def downscaled_texture(image, longest_side):
    """A deliberately small copy of a texture.

    A 2048 px texture sampled onto a 96 px sprite is not detail, it is noise:
    every rendered pixel lands on a different stitch or scratch, and the result
    changes completely from frame to frame. Shrinking the texture first keeps
    what matters at this size - the tunic is one colour, the mail is another -
    and throws away what cannot be seen anyway.
    """
    if longest_side <= 0:
        return image
    width, height = image.size
    if width <= 0 or height <= 0 or max(width, height) <= longest_side:
        return image

    key = "VOLYA_%s_%d" % (image.name, longest_side)
    existing = bpy.data.images.get(key)
    if existing is not None:
        return existing

    if width >= height:
        new_w = longest_side
        new_h = max(1, int(round(height * longest_side / float(width))))
    else:
        new_h = longest_side
        new_w = max(1, int(round(width * longest_side / float(height))))

    try:
        small = image.copy()
        small.name = key
        small.scale(new_w, new_h)
        print("VOLYA:     textura %dx%d -> %dx%d" % (width, height, new_w, new_h))
        return small
    except Exception as exc:
        print("VOLYA:     texturu sa nepodarilo zmensit (%s)" % exc)
        return image


def average_image_colour(image):
    """Collapse a texture to one colour by scaling a copy down to 8x8."""
    try:
        small = image.copy()
        small.scale(8, 8)
        pixels = list(small.pixels)
        bpy.data.images.remove(small)
    except Exception:
        return None
    if not pixels:
        return None
    total = [0.0, 0.0, 0.0]
    count = len(pixels) // 4
    for i in range(count):
        for c in range(3):
            total[c] += pixels[i * 4 + c]
    return [total[c] / max(count, 1) for c in range(3)]


# Provisional test colours, NOT the final palette - that is a separate
# decision. They exist so an untextured model comes out of the renderer with
# readable, separated areas instead of one flat grey, which is the only way to
# judge whether the style works at all.
SCHEME = [
    ("skin",    (0.72, 0.54, 0.42), ("skin", "body", "head", "face", "hand",
                                     "arm", "joint")),
    ("hair",    (0.26, 0.19, 0.14), ("hair", "beard", "brow")),
    ("linen",   (0.70, 0.66, 0.55), ("cloth", "shirt", "tunic", "linen",
                                     "robe", "fabric")),
    ("leather", (0.42, 0.29, 0.19), ("leather", "belt", "boot", "strap",
                                     "shoe", "glove", "bag")),
    ("steel",   (0.60, 0.63, 0.68), ("metal", "armor", "armour", "helmet",
                                     "steel", "iron", "mail", "blade",
                                     "sword", "weapon")),
    ("wool",    (0.34, 0.31, 0.29), ("pant", "trouser", "leg", "skirt")),
]

GREY = (0.6, 0.6, 0.6)


def parse_colour_overrides(text):
    """--material_colours "Alpha_Body=C08A6B,Alpha_Joints=6B5540" """
    overrides = {}
    for chunk in (text or "").split(","):
        chunk = chunk.strip()
        if "=" not in chunk:
            continue
        name, value = chunk.split("=", 1)
        value = value.strip().lstrip("#")
        if len(value) != 6:
            print("VOLYA: preskakujem farbu '%s' (caka sa 6 hex znakov)" % chunk)
            continue
        try:
            rgb = tuple(int(value[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
        except ValueError:
            print("VOLYA: preskakujem farbu '%s' (nie je to hex)" % chunk)
            continue
        overrides[name.strip().lower()] = rgb
    return overrides


def scheme_colour(material_name, index):
    """Pick a flat colour for a material that has none of its own.

    First by what the material is called, because Mixamo names them things
    like Alpha_Body_MAT. Failing that, by slot order, so at least no two
    materials end up the same colour.
    """
    key = material_name.lower()
    for label, rgb, tokens in SCHEME:
        if any(token in key for token in tokens):
            return rgb, label
    rgb, label = SCHEME[index % len(SCHEME)][1], SCHEME[index % len(SCHEME)][0]
    return rgb, label + " (podla poradia)"


def material_appearance(material):
    """What this material actually looks like: a texture, a colour, or nothing.

    Returns (image, colour). If image is not None it must be kept and shaded,
    not averaged away.

    Averaging was the first design and it was wrong. Mixamo packs the whole
    character - skin, tunic, mail, boots - into a single texture on a single
    material. Collapsing that to its mean gives one muddy grey, and the render
    comes out as a grey statue even though the source model is fully coloured.
    """
    # Blender 5.x warns that 'use_nodes' goes away in 6.0, where every material
    # is node-based anyway. Asking for the node tree directly survives both.
    if not material or material.node_tree is None:
        return None, None
    if not getattr(material, "use_nodes", True):
        return None, None
    for node in material.node_tree.nodes:
        if node.type != "BSDF_PRINCIPLED":
            continue
        slot = node.inputs.get("Base Color")
        if slot is None:
            continue
        if slot.is_linked:
            source = slot.links[0].from_node
            if source.type == "TEX_IMAGE" and source.image:
                return source.image, None
            return None, None
        colour = list(slot.default_value)[:3]
        # An untouched Principled node sits on a neutral mid grey. Treating
        # that as a deliberate choice is what leaves a model uncoloured.
        if max(colour) - min(colour) < 0.02 and colour[0] > 0.45:
            return None, None
        return None, colour
    return None, None


def _new_multiply_node(tree):
    """Colour multiply, across Blender versions.

    4.x prefers ShaderNodeMix with data_type RGBA; ShaderNodeMixRGB still
    exists but is deprecated. Returns (node, input_a, input_b).
    """
    try:
        node = tree.nodes.new("ShaderNodeMix")
        node.data_type = "RGBA"
        node.blend_type = "MULTIPLY"
        node.inputs["Factor"].default_value = 1.0
        colour_inputs = [s for s in node.inputs if s.type == "RGBA"]
        return node, colour_inputs[0], colour_inputs[1]
    except Exception:
        node = tree.nodes.new("ShaderNodeMixRGB")
        node.blend_type = "MULTIPLY"
        node.inputs["Fac"].default_value = 1.0
        return node, node.inputs["Color1"], node.inputs["Color2"]


def make_toon_material(material, cfg, image, colour, bands_override=None):
    """Rebuild a material with hard bands of light instead of smooth shading.

    Two shapes, depending on what the material has:

      texture:  the texture keeps its colours and is multiplied by a greyscale
                band ramp, so a tunic stays red and a mail shirt stays grey
      colour:   the band colours are written straight into the ramp stops, so
                no multiply node is needed at all

    Needs EEVEE: 'Shader to RGB' does not exist in Cycles.
    """
    bands = max(2, int(bands_override or cfg["bands"]))
    darkest = float(cfg["shadow"])

    try:
        if not getattr(material, "use_nodes", True):
            material.use_nodes = True
    except Exception:
        pass    # Blender 6.0 removed the flag; materials are always node-based
    tree = material.node_tree
    tree.nodes.clear()

    diffuse = tree.nodes.new("ShaderNodeBsdfDiffuse")
    diffuse.inputs["Color"].default_value = (1.0, 1.0, 1.0, 1.0)
    diffuse.inputs["Roughness"].default_value = 1.0
    diffuse.location = (-800, 0)

    to_rgb = tree.nodes.new("ShaderNodeShaderToRGB")
    to_rgb.location = (-600, 0)

    ramp = tree.nodes.new("ShaderNodeValToRGB")
    ramp.location = (-400, 0)
    ramp.color_ramp.interpolation = "CONSTANT"
    while len(ramp.color_ramp.elements) > 1:
        ramp.color_ramp.elements.remove(ramp.color_ramp.elements[-1])

    for i in range(bands):
        factor = darkest + (1.0 - darkest) * (i / float(bands - 1))
        position = i / float(bands)
        element = (ramp.color_ramp.elements[0] if i == 0
                   else ramp.color_ramp.elements.new(position))
        element.position = position
        if image is not None:
            element.color = (factor, factor, factor, 1.0)
        else:
            element.color = (colour[0] * factor, colour[1] * factor,
                             colour[2] * factor, 1.0)

    emission = tree.nodes.new("ShaderNodeEmission")
    emission.location = (100, 0)
    emission.inputs["Strength"].default_value = 1.0

    output = tree.nodes.new("ShaderNodeOutputMaterial")
    output.location = (300, 0)

    tree.links.new(diffuse.outputs["BSDF"], to_rgb.inputs["Shader"])
    tree.links.new(to_rgb.outputs["Color"], ramp.inputs["Fac"])

    if image is not None:
        tex = tree.nodes.new("ShaderNodeTexImage")
        tex.image = downscaled_texture(image, int(cfg["texture_size"]))
        # Linear, not Closest. The texture has already been shrunk to roughly
        # sprite scale, so the hard edges come from the cel bands; sampling it
        # with Closest on top of that only reintroduces speckle.
        tex.interpolation = "Linear"
        tex.location = (-400, 260)

        mix, slot_a, slot_b = _new_multiply_node(tree)
        mix.location = (-100, 130)
        tree.links.new(tex.outputs["Color"], slot_a)
        tree.links.new(ramp.outputs["Color"], slot_b)
        tree.links.new(mix.outputs[mix.outputs.keys()[0]],
                       emission.inputs["Color"])
    else:
        tree.links.new(ramp.outputs["Color"], emission.inputs["Color"])

    tree.links.new(emission.outputs["Emission"], output.inputs["Surface"])


def apply_toon_shading(cfg):
    """Flatten every material in the scene. This is what makes pixel art work.

    A photographic texture shrunk to 96 pixels is mud. Large flat areas of one
    colour survive the shrink; detail does not.
    """
    overrides = parse_colour_overrides(cfg.get("material_colours", ""))
    seen = []
    done = 0
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        for slot in obj.material_slots:
            material = slot.material
            if material is None or material.name in seen:
                continue
            seen.append(material.name)

            image, base = None, overrides.get(material.name.lower())
            source = "rucne zadana"
            if base is None:
                image, base = material_appearance(material)
                source = "textura z modelu" if image else "farba z modelu"
            if image is None and base is None:
                base, label = scheme_colour(material.name, len(seen) - 1)
                source = "nahradna: " + label

            try:
                make_toon_material(material, cfg, image, base)
                done += 1
                if image is not None:
                    print("VOLYA:   %-28s %-22s (%s)"
                          % (material.name, image.name, source))
                else:
                    print("VOLYA:   %-28s #%02X%02X%02X               (%s)"
                          % (material.name, int(base[0] * 255),
                             int(base[1] * 255), int(base[2] * 255), source))
            except Exception as exc:
                print("VOLYA: material %s sa nepodarilo prerobit (%s)"
                      % (material.name, exc))

    print("VOLYA: toon shading na %d materialoch, %d pasiem svetla"
          % (done, int(cfg["bands"])))
    if done == 0:
        print("VOLYA: POZOR - model nema ziadne materialy, ostane sedy. "
              "Prirad mu v Blenderi aspon jeden material na cast tela.")


def build_camera(cfg):
    """Orthographic camera on a pivot, so azimuth is one rotation away."""
    lo, hi = visible_mesh_bounds()
    center = (lo + hi) * 0.5
    height = max(hi[2] - lo[2], 1e-4)
    distance = max(height * 4.0, 1.0)

    pivot = bpy.data.objects.new("VOLYA_Pivot", None)
    bpy.context.scene.collection.objects.link(pivot)
    pivot.location = center

    cam_data = bpy.data.cameras.new("VOLYA_Cam")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = height * cfg["margin"]
    cam_data.clip_start = 0.01
    cam_data.clip_end = distance * 4.0

    cam = bpy.data.objects.new("VOLYA_Cam", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    cam.parent = pivot
    cam.location = (0.0, -distance, 0.0)
    cam.rotation_euler = (math.radians(90.0), 0.0, 0.0)

    bpy.context.scene.camera = cam
    return pivot


def build_lights(cfg):
    """Simple 3-point rig parented to nothing - lighting stays fixed in world space."""
    lo, hi = visible_mesh_bounds()
    center = (lo + hi) * 0.5
    height = max(hi[2] - lo[2], 1e-4)
    reach = height * 3.0

    if int(cfg["toon"]) != 0:
        # Two lights only. A rim light paints a thin gradient along the edge,
        # which at 96 pixels turns into a row of speckles rather than a
        # highlight - exactly the noise the pixel pass then has to remove.
        specs = [
            ("VOLYA_Key", cfg["sun"], (-0.6, -1.0, 0.9)),
            ("VOLYA_Fill", cfg["sun"] * 0.3, (1.0, -0.7, 0.2)),
        ]
    else:
        specs = [
            ("VOLYA_Key", cfg["sun"], (-0.6, -1.0, 0.9)),
            ("VOLYA_Fill", cfg["sun"] * 0.35, (1.0, -0.7, 0.2)),
            ("VOLYA_Rim", cfg["sun"] * 0.6, (0.3, 1.0, 0.6)),
        ]
    for name, energy, direction in specs:
        data = bpy.data.lights.new(name, type="SUN")
        data.energy = energy
        obj = bpy.data.objects.new(name, data)
        bpy.context.scene.collection.objects.link(obj)
        vec = mathutils.Vector(direction).normalized()
        obj.location = center + vec * reach
        obj.rotation_euler = (-vec).to_track_quat("-Z", "Y").to_euler()


# ------------------------------------------------------------------- render --

def sync_frame_range():
    """FBX import does not always set the scene range - take it from the actions."""
    lo = None
    hi = None
    for obj in bpy.context.scene.objects:
        anim = obj.animation_data
        if anim is None or anim.action is None:
            continue
        span = anim.action.frame_range
        lo = span[0] if lo is None else min(lo, span[0])
        hi = span[1] if hi is None else max(hi, span[1])
    if lo is None or hi is None or hi <= lo:
        print("VOLYA: no action found, keeping scene range %d-%d"
              % (bpy.context.scene.frame_start, bpy.context.scene.frame_end))
        return
    bpy.context.scene.frame_start = int(math.floor(lo))
    bpy.context.scene.frame_end = int(math.ceil(hi))
    print("VOLYA: frame range taken from animation: %d-%d"
          % (bpy.context.scene.frame_start, bpy.context.scene.frame_end))


def configure_render(cfg, engine):
    scene = bpy.context.scene
    render = scene.render

    render.engine = engine
    render.resolution_y = int(cfg["height"])
    render.resolution_x = max(2, int(cfg["height"] * 0.75))
    render.resolution_percentage = 100
    render.film_transparent = True
    render.image_settings.file_format = "PNG"
    render.image_settings.color_mode = "RGBA"
    render.image_settings.compression = 90
    scene.frame_step = max(1, int(cfg["step"]))

    pixel_mode = int(cfg["pixel"]) != 0
    # Anti-aliasing is the enemy here. It blends edge pixels into half-tones,
    # and a sprite made of half-tones reads as a shrunk 3D render, not as
    # pixel art. Two things create it: the pixel filter width, and EEVEE's
    # sub-pixel jitter across samples. Both have to go.
    render.filter_size = 0.01 if pixel_mode else 0.8
    samples = 1 if pixel_mode else int(cfg["samples"])

    try:
        scene.eevee.taa_render_samples = samples
    except Exception:
        pass
    try:
        scene.cycles.samples = samples
        scene.cycles.pixel_filter_type = "BOX" if pixel_mode else "BLACKMAN_HARRIS"
    except Exception:
        pass


def render_angle(cfg, pivot, index, total):
    scene = bpy.context.scene
    azimuth = cfg["start_angle"] + (360.0 / total) * index
    pivot.rotation_euler = (0.0, 0.0, math.radians(azimuth))

    out_dir = bpy.path.abspath(cfg["out"])
    os.makedirs(out_dir, exist_ok=True)
    prefix = "%s_a%02d_" % (cfg["name"], index)
    scene.render.filepath = os.path.join(out_dir, prefix)

    print("VOLYA: rendering angle %d/%d (%.1f deg) frames %d-%d step %d -> %s"
          % (index + 1, total, azimuth, scene.frame_start, scene.frame_end,
             scene.frame_step, out_dir))
    bpy.ops.render.render(animation=True, write_still=False)


def main():
    cfg = parse_args()

    toon = int(cfg["toon"]) != 0
    if toon and cfg["engine"] == "auto":
        # 'Shader to RGB', which the toon material is built on, only exists in
        # EEVEE. Asking for Cycles here would silently render untouched grey.
        cfg["engine"] = "BLENDER_EEVEE_NEXT"
    engine = pick_engine(cfg["engine"])
    if toon and "EEVEE" not in engine:
        print("VOLYA: POZOR - toon shading potrebuje EEVEE, engine je %s. "
              "Vypinam toon." % engine)
        cfg["toon"] = 0
        toon = False
    print("VOLYA: Blender %s, engine %s, toon %s, pixel %s"
          % (bpy.app.version_string, engine,
             "ano" if toon else "nie",
             "ano" if int(cfg["pixel"]) else "nie"))

    # The side view is decided from the model before anything else, so the
    # camera does not have to be guessed by rendering eight angles by hand.
    if float(cfg["start_angle"]) < 0.0:
        cfg["start_angle"] = side_view_azimuth()

    sync_frame_range()
    configure_render(cfg, engine)
    if toon:
        apply_toon_shading(cfg)
    pivot = build_camera(cfg)
    build_lights(cfg)

    scene = bpy.context.scene
    total = max(1, int(cfg["angles"]))

    # Preview: one frame from eight angles, so the correct side view can be
    # picked by eye. Mixamo characters are not all facing the same way, so
    # guessing the camera azimuth is a waste of a render.
    if int(cfg["preview"]) != 0:
        total = 8
        middle = (scene.frame_start + scene.frame_end) // 2
        scene.frame_start = middle
        scene.frame_end = middle
        scene.frame_step = 1
        print("VOLYA: PREVIEW - 1 frame from 8 angles (a00 = %.0f deg, "
              "each step +45 deg)" % cfg["start_angle"])

    for index in range(total):
        render_angle(cfg, pivot, index, total)

    count = len(range(scene.frame_start, scene.frame_end + 1, scene.frame_step))
    if int(cfg["preview"]) != 0:
        print("VOLYA: pozri sa na subory _a00_ az _a07_ a vyber ten, kde je")
        print("VOLYA: postava presne z boku. Cislo N pouzi ako --start_angle")
        print("VOLYA: s hodnotou N*45, a potom renderuj s --angles 1.")
    print("VOLYA: done - %d angle(s) x %d frames = %d PNG files in %s"
          % (total, count, total * count, bpy.path.abspath(cfg["out"])))


if __name__ == "__main__":
    main()
