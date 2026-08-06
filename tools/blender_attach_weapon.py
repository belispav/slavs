"""
VOLYA - build a weapon and hang it on the character's hand bone.

A weapon drawn as a separate sprite pinned over the character looks wrong the
moment the character moves: a matchlock that never comes up to the shoulder, a
sword that never swings. Attaching it to the hand bone costs nothing and solves
it completely - the hand is already animated, so the weapon is too.

Order matters, and it is the opposite of what one expects. Mixamo's auto-rigger
refuses a model that is holding anything, so the character is rigged with empty
hands, the animation is downloaded, and the weapon goes on afterwards, here.

    blender character.blend --background --python tools/blender_attach_weapon.py -- \
        --weapon arquebus

Or as part of a render:

    blender --background --python tools/blender_render_sprites.py -- \
        --import "tools/blender/strelec_run.fbx" ...

then run this on the saved .blend first. Prints what it found and where it put
things, so the offsets can be corrected from the render instead of guessed.
"""

import math
import sys

import bpy
import mathutils


DEFAULTS = {
    "weapon": "arquebus",   # arquebus, spear, sword, bow
    "hand": "right",        # which hand holds it
    "scale": 1.0,
    # Tuning, in metres, relative to the hand bone. Print the values, look at
    # the render, adjust - there is no way to get these right by reasoning.
    "shift_x": 0.0,
    "shift_y": 0.0,
    "shift_z": 0.0,
    "turn": 0.0,            # degrees around the barrel
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
            cfg[key] = float(value) if isinstance(cfg[key], float) else value
        else:
            print("VOLYA: neznamy argument --%s (ignorujem)" % key)
        i += 2
    return cfg


def box(name, size, at, colour):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=at)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = mathutils.Vector(size) * 0.5
    _paint(obj, colour)
    return obj


def cylinder(name, radius, length, at, colour):
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=length,
                                        vertices=8, location=at,
                                        rotation=(0.0, math.radians(90.0), 0.0))
    obj = bpy.context.active_object
    obj.name = name
    _paint(obj, colour)
    return obj


def _paint(obj, colour):
    material = bpy.data.materials.new("VOLYA_" + obj.name)
    material.diffuse_color = (colour[0], colour[1], colour[2], 1.0)
    try:
        material.use_nodes = False
    except Exception:
        pass
    obj.data.materials.append(material)


# Weapons are built along +X, which is "the way the character is pointing".
# Eight-sided cylinders and boxes: at 121 pixels a matchlock is a stick with a
# lump on it, and anything finer is thrown away by the render.
WOOD = (0.30, 0.19, 0.11)
IRON = (0.34, 0.35, 0.38)
HORN = (0.55, 0.47, 0.33)


def build_arquebus():
    parts = [
        cylinder("barrel", 0.020, 1.05, (0.28, 0.0, 0.0), IRON),
        box("stock", (0.62, 0.055, 0.075), (-0.16, 0.0, -0.02), WOOD),
        box("butt", (0.20, 0.060, 0.130), (-0.52, 0.0, -0.05), WOOD),
        box("lock", (0.10, 0.070, 0.060), (0.02, 0.0, 0.02), IRON),
    ]
    return parts, 1.35


def build_spear():
    parts = [
        cylinder("shaft", 0.016, 1.90, (0.10, 0.0, 0.0), WOOD),
        box("head", (0.26, 0.030, 0.070), (1.12, 0.0, 0.0), IRON),
    ]
    return parts, 2.05


def build_sword():
    parts = [
        box("blade", (0.78, 0.020, 0.075), (0.42, 0.0, 0.0), IRON),
        box("guard", (0.035, 0.030, 0.200), (0.03, 0.0, 0.0), IRON),
        cylinder("grip", 0.022, 0.18, (-0.08, 0.0, 0.0), HORN),
        box("pommel", (0.055, 0.055, 0.055), (-0.19, 0.0, 0.0), IRON),
    ]
    return parts, 1.00


def build_bow():
    parts = [
        box("limb_up", (0.045, 0.025, 0.55), (0.0, 0.0, 0.30), HORN),
        box("limb_down", (0.045, 0.025, 0.55), (0.0, 0.0, -0.30), HORN),
        box("grip", (0.055, 0.040, 0.16), (0.0, 0.0, 0.0), WOOD),
    ]
    return parts, 1.20


def build_club():
    """A two-handed cudgel: a cut branch, thicker at the business end.

    Two tapering sections rather than one bar, because at 128 pixels the only
    thing that separates a club from a sword is that one end is fatter.

    It is 1.25 m and not the 0.72 m a one-handed club would be, because the
    rusher's Mixamo animations are the Great Sword set - both hands on the
    shaft. Only the right hand carries the weapon through the bone; the left
    hand simply lands where the animation puts it, so the shaft has to reach
    back roughly 0.35 m behind the right hand or the left one closes on air.
    Shorten this only together with swapping to one-handed animations.
    """
    parts = [
        cylinder("handle", 0.030, 0.80, (0.02, 0.0, 0.0), WOOD),
        cylinder("head", 0.060, 0.42, (0.63, 0.0, 0.0), WOOD),
        box("knot", (0.08, 0.095, 0.095), (0.82, 0.0, 0.0), WOOD),
    ]
    return parts, 1.25


BUILDERS = {
    "arquebus": build_arquebus,
    "spear": build_spear,
    "sword": build_sword,
    "bow": build_bow,
    "club": build_club,
}


def find_armature():
    for obj in bpy.context.scene.objects:
        if obj.type == "ARMATURE":
            return obj
    return None


def find_hand(armature, side):
    """The hand bone, whatever the rig calls it.

    Mixamo uses mixamorig:RightHand, but the prefix survives imports
    inconsistently, so match on the normalised name instead.
    """
    wanted = side.lower()
    best = None
    for bone in armature.data.bones:
        key = "".join(c for c in bone.name.lower() if c.isalnum())
        if wanted in key and "hand" in key:
            # Prefer the hand itself over its fingers.
            if "index" in key or "thumb" in key or "middle" in key \
                    or "ring" in key or "pinky" in key:
                continue
            if best is None or len(bone.name) < len(best.name):
                best = bone
    return best


def main():
    cfg = parse_args()
    builder = BUILDERS.get(str(cfg["weapon"]).lower())
    if builder is None:
        sys.exit("VOLYA: neznama zbran '%s'. Mam: %s"
                 % (cfg["weapon"], ", ".join(sorted(BUILDERS))))

    armature = find_armature()
    if armature is None:
        sys.exit("VOLYA: v scene nie je kostra. Naimportuj najprv postavu "
                 "z Mixama.")

    hand = find_hand(armature, str(cfg["hand"]))
    if hand is None:
        print("VOLYA: nenasiel som kost ruky. Kosti v rigu:")
        for bone in armature.data.bones:
            print("   %s" % bone.name)
        sys.exit("VOLYA: prerusene.")
    print("VOLYA: ruka = %s" % hand.name)

    parts, length = builder()
    bpy.ops.object.select_all(action="DESELECT")
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    weapon = bpy.context.view_layer.objects.active
    weapon.name = "VOLYA_Weapon"

    # The character is about 1.8 m, and a matchlock is about 1.35 m. Scale the
    # weapon to the rig actually loaded rather than assuming Mixamo's units.
    height = max(armature.dimensions.z, 0.01)
    factor = (height / 1.8) * float(cfg["scale"])
    weapon.scale = mathutils.Vector((factor, factor, factor))
    print("VOLYA: postava %.2f jednotiek vysoka, zbran zmensena %.3fx"
          % (height, factor))

    # Bone parenting hangs the child off the bone's TAIL, so the weapon has to
    # be placed by hand afterwards - it does not land in the palm on its own.
    weapon.parent = armature
    weapon.parent_type = "BONE"
    weapon.parent_bone = hand.name

    grip_back = -0.18 * length * factor      # hold it near the balance point
    offset = mathutils.Vector((
        grip_back + float(cfg["shift_x"]),
        float(cfg["shift_y"]),
        float(cfg["shift_z"])))
    weapon.matrix_parent_inverse = mathutils.Matrix.Identity(4)
    weapon.location = offset
    weapon.rotation_euler = (math.radians(float(cfg["turn"])), 0.0, 0.0)

    print("VOLYA: zbran %s pripnuta na %s" % (cfg["weapon"], hand.name))
    print("VOLYA: posun %.3f %.3f %.3f, otocenie %.0f stupnov"
          % (offset.x, offset.y, offset.z, float(cfg["turn"])))
    print("VOLYA: ak sedi zle, oprav to cez --shift_x/--shift_y/--shift_z "
          "a --turn")

    if bpy.data.filepath:
        bpy.ops.wm.save_mainfile()
        print("VOLYA: ulozene do %s" % bpy.data.filepath)
    else:
        print("VOLYA: scena nie je ulozena ako .blend, nic som neukladal")


if __name__ == "__main__":
    main()
