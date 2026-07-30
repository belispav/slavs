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
    "angles": 1,       # 1 = pure side view; 8 = full 45-degree turnaround
    "start_angle": 0.0,
    "margin": 1.35,    # extra room around the rest-pose bounding box
    "engine": "auto",
    "samples": 32,
    "sun": 4.0,
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
    render.filter_size = 0.8          # softer = 1.5, crisper/pixelier = 0.3
    render.image_settings.file_format = "PNG"
    render.image_settings.color_mode = "RGBA"
    render.image_settings.compression = 90
    scene.frame_step = max(1, int(cfg["step"]))

    try:
        scene.eevee.taa_render_samples = int(cfg["samples"])
    except Exception:
        pass
    try:
        scene.cycles.samples = int(cfg["samples"])
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
    engine = pick_engine(cfg["engine"])
    print("VOLYA: Blender %s, engine %s" % (bpy.app.version_string, engine))

    sync_frame_range()
    configure_render(cfg, engine)
    pivot = build_camera(cfg)
    build_lights(cfg)

    total = max(1, int(cfg["angles"]))
    for index in range(total):
        render_angle(cfg, pivot, index, total)

    scene = bpy.context.scene
    count = len(range(scene.frame_start, scene.frame_end + 1, scene.frame_step))
    print("VOLYA: done — %d angle(s) x %d frames = %d PNG files in %s"
          % (total, count, total * count, bpy.path.abspath(cfg["out"])))


if __name__ == "__main__":
    main()
