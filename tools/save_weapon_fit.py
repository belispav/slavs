"""
Slavs - read a hand-placed weapon back out of a .blend into a small JSON file.

The point of the file is reuse. A weapon's placement is stored relative to the
HAND BONE, and every animation of the same character has the same rig, so a
placement fitted once on the idle is correct on the walk and on the attack too.
Fit once per enemy by mouse, then every render of that enemy reads the numbers.

    blender --background --python tools/save_weapon_fit.py -- ^
        --blend tools/blender/Enemy_gunman_01 Rifle Idle.blend ^
        --name gunman

Writes art/fits/gunman.json. Use it with:

    ... render_pixel_test.ps1 ... -WFit art\fits\gunman.json
"""

import json
import os
import sys

import bpy


def parse_args():
    cfg = {"blend": "", "name": "", "out": ""}
    argv = sys.argv
    if "--" not in argv:
        return cfg
    argv = argv[argv.index("--") + 1:]
    i = 0
    while i < len(argv):
        key = argv[i]
        if key.startswith("--") and key[2:] in cfg:
            cfg[key[2:]] = argv[i + 1] if i + 1 < len(argv) else ""
            i += 2
        else:
            i += 1
    return cfg


def main():
    cfg = parse_args()
    if not cfg["blend"]:
        sys.exit("Slavs: chyba --blend <subor>")
    bpy.ops.wm.open_mainfile(filepath=os.path.abspath(cfg["blend"]))

    weapon = None
    for obj in bpy.context.scene.objects:
        if obj.name.startswith("SLAVS_Weapon"):
            weapon = obj
            break
    if weapon is None:
        sys.exit("Slavs: v tom .blend nie je objekt SLAVS_Weapon. Ulozil si "
                 "spravny subor?")
    if weapon.parent is None or weapon.parent_type != "BONE":
        sys.exit("Slavs: zbran nie je pripnuta na kost - odparila sa pri "
                 "uprave. Zopakuj fitovanie a zbran len posuvaj, "
                 "neodparcuj ju.")

    fit = {
        "bone": weapon.parent_bone,
        "location": list(weapon.location),
        "rotation_euler": list(weapon.rotation_euler),
        "scale": list(weapon.scale),
        "from_blend": os.path.basename(cfg["blend"]),
    }

    name = cfg["name"] or os.path.splitext(os.path.basename(cfg["blend"]))[0]
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    fits = os.path.join(root, "art", "fits")
    out = cfg["out"] or os.path.join(fits, name + ".json")
    os.makedirs(os.path.dirname(out), exist_ok=True)

    # Only the placement is written. Colours, the weapon model, the camera and
    # everything else live in <character>.settings.json, which nothing here
    # opens - so no amount of re-fitting can lose them.

    with open(out, "w", encoding="utf-8") as handle:
        json.dump(fit, handle, indent=2)

    print("Slavs: kost      %s" % fit["bone"])
    print("Slavs: posun     %.3f %.3f %.3f" % tuple(fit["location"]))
    print("Slavs: otocenie  %.1f %.1f %.1f stupnov"
          % tuple(d * 57.2957795 for d in fit["rotation_euler"]))
    print("Slavs: velkost   %.3f" % fit["scale"][0])
    print("Slavs: ulozene do %s" % out)


if __name__ == "__main__":
    main()
