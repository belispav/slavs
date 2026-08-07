"""
VOLYA - measure how a downloaded animation actually holds the weapon.

Animation names lie. "Great Sword Idle" turned out to be a genuine two-handed
grip; "Walking" is a plain empty-handed walk with the arms swinging at the
sides. Mixing the two gives a rusher who carries a club in both hands while
standing and lets go of it to walk - and that is only visible after the whole
render-and-pixelate pipeline has run, by which point it looks like a bug in the
weapon code rather than a wrong download.

This measures the distance between the hands across the animation and says
what kind of grip it is, in seconds rather than in a render round.

    blender --background --python tools/inspect_grip.py -- \
        "ref/characters/Enemy_rusher_01 Great Sword Idle.fbx" \
        "ref/characters/Enemy_rusher_01 Walking.fbx"

Distances are printed in centimetres of a 1.8 m character, worked out from the
MESH height - never from the armature object's bounding box, which for a Mixamo
import measures something else entirely and quietly scales everything wrong.
"""

import os
import sys

import bpy
import mathutils


SAMPLES = 24            # frames sampled across the animation
TWO_HANDED_CM = 55      # hands closer than this for most of the clip = both on the shaft
ONE_HANDED_CM = 75      # hands further apart than this = not a shared grip


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def load(path):
    lower = path.lower()
    if lower.endswith(".fbx"):
        bpy.ops.import_scene.fbx(filepath=path)
    elif lower.endswith((".glb", ".gltf")):
        bpy.ops.import_scene.gltf(filepath=path)
    else:
        raise RuntimeError("neznamy format: %s" % path)


def mesh_height():
    lo = 1e12
    hi = -1e12
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        for corner in obj.bound_box:
            z = (obj.matrix_world @ mathutils.Vector(corner)).z
            lo = min(lo, z)
            hi = max(hi, z)
    return max(hi - lo, 1e-6)


def find_armature():
    for obj in bpy.context.scene.objects:
        if obj.type == "ARMATURE":
            return obj
    return None


def hand_bone(armature, side):
    best = None
    for bone in armature.pose.bones:
        key = "".join(c for c in bone.name.lower() if c.isalnum())
        if side not in key or "hand" not in key:
            continue
        if any(f in key for f in ("index", "thumb", "middle", "ring", "pinky")):
            continue
        if best is None or len(bone.name) < len(best.name):
            best = bone
    return best


def frame_range():
    lo = hi = None
    for obj in bpy.context.scene.objects:
        anim = obj.animation_data
        if anim is None or anim.action is None:
            continue
        a, b = anim.action.frame_range
        lo = a if lo is None else min(lo, a)
        hi = b if hi is None else max(hi, b)
    if lo is None:
        return 1, 1
    return int(lo), int(hi)


def measure(path):
    clear_scene()
    load(path)

    armature = find_armature()
    if armature is None:
        print("  ziadna kostra - preskakujem")
        return

    left = hand_bone(armature, "left")
    right = hand_bone(armature, "right")
    if left is None or right is None:
        print("  nenasiel som obe ruky - preskakujem")
        return

    # Centimetres of a real 1.8 m person, so the number means something no
    # matter what units the file happened to be exported in.
    per_cm = mesh_height() / 180.0
    lo, hi = frame_range()
    step = max(1, (hi - lo) // SAMPLES)

    scene = bpy.context.scene
    values = []
    for frame in range(lo, hi + 1, step):
        scene.frame_set(frame)
        bpy.context.view_layer.update()
        a = armature.matrix_world @ right.head
        b = armature.matrix_world @ left.head
        values.append((frame, (a - b).length / per_cm))

    dist = [v for _, v in values]
    small = sum(1 for v in dist if v <= TWO_HANDED_CM)
    share = small / float(len(dist))

    if share >= 0.8:
        verdict = "OBOJRUCNY - ruky su na spolocnom drieku cely cas"
    elif share >= 0.35:
        verdict = "STRIEDAVY - obojrucny len cast animacie (%.0f %%)" % (share * 100)
    else:
        verdict = "JEDNORUCNY / VOLNE RUKY - spolocny uchop nikdy"

    print("  snimky %d-%d, ruky od seba: min %.0f cm, max %.0f cm, priemer %.0f cm"
          % (lo, hi, min(dist), max(dist), sum(dist) / len(dist)))
    print("  ZAVER: %s" % verdict)
    spark = "".join("#" if v <= TWO_HANDED_CM else "." for v in dist)
    print("  priebeh (# = ruky spolu): %s" % spark)


def main():
    argv = sys.argv
    paths = argv[argv.index("--") + 1:] if "--" in argv else []
    if not paths:
        sys.exit("VOLYA: zadaj aspon jeden FBX/GLB")
    for path in paths:
        print("")
        print("=== %s" % os.path.basename(path))
        if not os.path.exists(path):
            print("  subor neexistuje")
            continue
        measure(path)


if __name__ == "__main__":
    main()
