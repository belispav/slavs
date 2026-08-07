"""
VOLYA - build a .blend with the weapon already in the character's hand, ready
to be placed by mouse.

    blender --background --python tools/blender_fit_weapon.py -- ^
        --import "ref/characters/Enemy_gunman_01 Rifle Idle.fbx" ^
        --weapon arquebus --angle 45 --elevation 12 ^
        --out "tools/blender/gunman_fit.blend"

Then open that .blend normally. Use tools/fit_weapon.ps1, which does both.

WHY IT IS SPLIT IN TWO. The obvious version - open Blender and let a startup
script import the character - does not work. Blender's FBX importer switches to
Edit Mode while it builds an armature, and that operator needs a proper window
context which a --python startup script does not have, whether it runs
immediately or from a timer. Headless import has none of that trouble, and the
saved file carries everything with it: the pose, the camera, the viewport
looking through it, and which object is selected.

WHAT TO DO ONCE IT OPENS
  G then move the mouse   - slide the weapon   (G X / G Y / G Z locks an axis)
  R then move the mouse   - turn it            (R X / R Y / R Z likewise)
  S                       - resize it
  Ctrl+S                  - save, over the same file

Do not unparent the weapon - only move it. Then run save_weapon_fit.py to write
the placement out, and every animation of that character can reuse it.
"""

import os
import sys

import bpy

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

import blender_attach_weapon as W          # noqa: E402
import blender_render_sprites as R         # noqa: E402


DEFAULTS = {
    "import": "",
    "weapon": "arquebus",
    "model": "",          # a downloaded weapon mesh instead of the built one
    "hand": "right",
    "angle": 45.0,        # camera azimuth, the one chosen for the game
    "elevation": 12.0,
    "frame": 0,           # 0 = middle of the animation
    "fit": "",            # start from a placement already saved
    "out": "",
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
            cur = cfg[key]
            cfg[key] = value if isinstance(cur, str) else type(cur)(value)
        else:
            print("VOLYA: neznamy argument --%s (ignorujem)" % key)
        i += 2
    return cfg


def look_through_camera():
    """Make every saved 3D viewport open looking through the render camera.

    Iterates bpy.data.screens rather than the window manager, because in
    --background there are no windows - but the screens are still there, they
    are saved into the .blend, and that is what the file will open with.
    """
    touched = 0
    for screen in bpy.data.screens:
        for area in screen.areas:
            if area.type != "VIEW_3D":
                continue
            for space in area.spaces:
                if space.type != "VIEW_3D":
                    continue
                space.region_3d.view_perspective = "CAMERA"
                space.shading.type = "MATERIAL"
                touched += 1
    print("VOLYA: %d vyrezov nastavenych na hernu kameru" % touched)


def main():
    cfg = parse_args()
    if not cfg["import"]:
        sys.exit("VOLYA: chyba --import <fbx>")
    source = os.path.abspath(cfg["import"])
    if not os.path.exists(source):
        sys.exit("VOLYA: subor %s neexistuje" % source)

    R.import_source(source)

    weapon = W.attach({
        "weapon": cfg["weapon"],
        "model": cfg["model"],
        "hand": cfg["hand"],
        "scale": 1.0,
        "shift_x": 0.0, "shift_y": 0.0, "shift_z": 0.0,
        "turn": 0.0, "aim": 1, "debug": 0, "spin": 0.0,
        "fit": cfg["fit"], "iron_from": 0.0,
    })

    R.sync_frame_range(None)
    scene = bpy.context.scene
    frame = int(cfg["frame"]) or (scene.frame_start + scene.frame_end) // 2
    scene.frame_set(frame)

    R.build_camera({"margin": 1.35,
                    "start_angle": float(cfg["angle"]),
                    "elevation": float(cfg["elevation"])})
    R.build_lights({"toon": 0, "sun": 4.0, "light_follow": 0})
    look_through_camera()

    # Selection is saved in the file, so the weapon is already the active
    # object when it opens and G works on the first keystroke. Without this the
    # first thing the mouse moves is the character.
    for obj in bpy.context.scene.objects:
        obj.select_set(False)
    weapon.select_set(True)
    bpy.context.view_layer.objects.active = weapon

    out = cfg["out"] or os.path.join(
        HERE, "blender",
        os.path.splitext(os.path.basename(source))[0] + "_fit.blend")
    out = os.path.abspath(out)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=out)

    print("")
    print("=" * 70)
    print("VOLYA: hotovo -> %s" % out)
    print("VOLYA: snimka %d, kamera %.0f stupnov, zdvih %.0f"
          % (frame, float(cfg["angle"]), float(cfg["elevation"])))
    if cfg["fit"]:
        print("VOLYA: zbran je uz umiestnena podla %s"
              % os.path.basename(cfg["fit"]))
        print("VOLYA: ak sedi, nic nerob a zavri. Ak nie, oprav a uloz -")
        print("VOLYA: oprava plati pre VSETKY animacie tejto postavy.")
    print("VOLYA: zbran je vybrata. G = posun, R = otocenie, S = velkost.")
    print("=" * 70)


if __name__ == "__main__":
    main()
