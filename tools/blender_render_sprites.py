"""
VOLYA — Blender sprite renderer.

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
    """Blender renamed the EEVEE engine id between versions — resolve it safely."""
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
        raise RuntimeError("No visible mesh in the scene — did the FBX import fail?")
    return lo, hi


def side_view_azimuth():
    """Work out which way to point the camera to get a clean side view.

    A human is wide across the shoulders and narrow front-to-back. At azimuth 0
    the camera looks along +Y, so what it sees as width is the X extent. For a
    side view we want the narrow axis facing us, so we turn 90 degrees whenever
    the model is wider in X than in Y.

    This resolves side vs. front. It cannot tell left from right — but that is
    a horizontal flip in Godot, which costs nothing.
    """
    lo, hi = visible_mesh_bounds()
    span_x = hi[0] - lo[0]
    span_y = hi[1] - lo[1]
    azimuth = 90.0 if span_x > span_y else 0.0
    print("VOLYA: rozmery modelu X=%.2f Y=%.2f -> bocny pohlad je %.0f stupnov"
          % (span_x, span_y, azimuth))
    return azimuth


# ------------------------------------------------------------------ shading --

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


def material_base_colour(material):
    """The one flat colour that stands in for this whole material."""
    fallback = [0.6, 0.6, 0.6]
    if not material or not material.use_nodes:
        return fallback
    for node in material.node_tree.nodes:
        if node.type != "BSDF_PRINCIPLED":
            continue
        slot = node.inputs.get("Base Color")
        if slot is None:
            continue
        if slot.is_linked:
            source = slot.links[0].from_node
            if source.type == "TEX_IMAGE" and source.image:
                averaged = average_image_colour(source.image)
                if averaged:
                    return averaged
            return fallback
        return list(slot.default_value)[:3]
    return fallback


def make_toon_material(material, cfg):
    """Rebuild a material as flat colour with hard bands of light.

    The trick is that the bands are not computed by multiplying a ramp with a
    colour — the already-multiplied colours are written straight into the ramp
    stops. Fewer nodes, and it behaves the same on every Blender 4.x.

    Needs EEVEE: 'Shader to RGB' does not exist in Cycles.
    """
    base = material_base_colour(material)
    bands = max(2, int(cfg["bands"]))
    darkest = float(cfg["shadow"])

    material.use_nodes = True
    tree = material.node_tree
    tree.nodes.clear()

    diffuse = tree.nodes.new("ShaderNodeBsdfDiffuse")
    diffuse.inputs["Color"].default_value = (1.0, 1.0, 1.0, 1.0)
    diffuse.inputs["Roughness"].default_value = 1.0
    diffuse.location = (-600, 0)

    to_rgb = tree.nodes.new("ShaderNodeShaderToRGB")
    to_rgb.location = (-400, 0)

    ramp = tree.nodes.new("ShaderNodeValToRGB")
    ramp.location = (-200, 0)
    ramp.color_ramp.interpolation = "CONSTANT"

    # One stop per band. Stop i lights the surface by factor f, and the stop
    # colour is base * f, so no multiply node is needed.
    while len(ramp.color_ramp.elements) > 1:
        ramp.color_ramp.elements.remove(ramp.color_ramp.elements[-1])
    for i in range(bands):
        factor = darkest + (1.0 - darkest) * (i / float(bands - 1))
        position = i / float(bands)
        element = (ramp.color_ramp.elements[0] if i == 0
                   else ramp.color_ramp.elements.new(position))
        element.position = position
        element.color = (base[0] * factor, base[1] * factor,
                         base[2] * factor, 1.0)

    emission = tree.nodes.new("ShaderNodeEmission")
    emission.location = (100, 0)
    emission.inputs["Strength"].default_value = 1.0

    output = tree.nodes.new("ShaderNodeOutputMaterial")
    output.location = (300, 0)

    tree.links.new(diffuse.outputs["BSDF"], to_rgb.inputs["Shader"])
    tree.links.new(to_rgb.outputs["Color"], ramp.inputs["Fac"])
    tree.links.new(ramp.outputs["Color"], emission.inputs["Color"])
    tree.links.new(emission.outputs["Emission"], output.inputs["Surface"])


def apply_toon_shading(cfg):
    """Flatten every material in the scene. This is what makes pixel art work.

    A photographic texture shrunk to 96 pixels is mud. Large flat areas of one
    colour survive the shrink; detail does not.
    """
    done = 0
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        for slot in obj.material_slots:
            if slot.material is None:
                continue
            try:
                make_toon_material(slot.material, cfg)
                done += 1
            except Exception as exc:
                print("VOLYA: material %s sa nepodarilo prerobit (%s)"
                      % (slot.material.name, exc))
    print("VOLYA: toon shading nastaveny na %d materialoch, %d pasiem svetla"
          % (done, int(cfg["bands"])))
    if done == 0:
        print("VOLYA: POZOR - model nema ziadne materialy, ostane sedy")


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
    """Simple 3-point rig parented to nothing — lighting stays fixed in world space."""
    lo, hi = visible_mesh_bounds()
    center = (lo + hi) * 0.5
    height = max(hi[2] - lo[2], 1e-4)
    reach = height * 3.0

    if int(cfg["toon"]) != 0:
        # Two lights only. A rim light paints a thin gradient along the edge,
        # which at 96 pixels turns into a row of speckles rather than a
        # highlight — exactly the noise the pixel pass then has to remove.
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
    """FBX import does not always set the scene range — take it from the actions."""
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
    print("VOLYA: done — %d angle(s) x %d frames = %d PNG files in %s"
          % (total, count, total * count, bpy.path.abspath(cfg["out"])))


if __name__ == "__main__":
    main()
