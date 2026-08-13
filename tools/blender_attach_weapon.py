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

import json
import math
import os
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
    "aim": 1,               # 1 = point the shaft along the line between hands
    "debug": 0,             # 1 = paint the weapon magenta so it cannot be missed
    "aim_vector": None,     # world direction to point the shaft along; wins over "aim"
    "spin": 0.0,            # degrees to turn the aim about the vertical axis
    "model": "",            # a downloaded weapon mesh to use instead of ours
    "fit": "",              # JSON from save_weapon_fit.py; wins over everything
    "iron_from": 0.0,       # 0..1 along the weapon; past this, faces become iron
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
    """A box of exactly `size` metres.

    The 0.5 that used to be here made every box half the size it asked for.
    A cube added with size=1.0 already measures one unit across, so scaling it
    by half the wanted size halves it again. Cylinders were unaffected, which
    is why it went unnoticed: the arquebus barrel was right and only the stock
    and butt were short - short enough to stop touching, which is exactly the
    "gap at the end of the gun" that showed up in the render.
    """
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=at)
    obj = bpy.context.view_layer.objects.active
    obj.name = name
    obj.scale = mathutils.Vector(size)
    _paint(obj, colour)
    return obj


def cylinder(name, radius, length, at, colour):
    # 8 sides read as an octagon rather than a rod once a part gets thick and
    # the render gets big - the rusher's club at Height ~180 instead of the
    # 128 the first version disappeared into. 12 plus smooth shading rounds
    # it off without adding real cost; this is still a handful of triangles.
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=length,
                                        vertices=12, location=at,
                                        rotation=(0.0, math.radians(90.0), 0.0))
    obj = bpy.context.view_layer.objects.active
    obj.name = name
    bpy.ops.object.shade_smooth()
    _paint(obj, colour)
    return obj


# Set from attach() when --debug is on. A weapon that is the wrong size, in the
# wrong place or pointing the wrong way all look identical at 128 px: absent.
# Painting it a colour that exists nowhere on a 15th century Slav settles in one
# render what four rounds of reasoning could not.
DEBUG_COLOUR = None
MAGENTA = (1.0, 0.0, 1.0)


def _paint(obj, colour):
    """Give the part a real material, coloured through the Principled node.

    The colour has to live on the node and not only in `diffuse_color`, because
    the render script reads Base Color to decide what a material looks like. A
    node-less material reads as "no colour of its own" and the renderer then
    guesses from the material's NAME - which is how a club called "head" came
    out skin-coloured. Parts are named so nothing collides with those keywords
    either; belt and braces, since a wrong colour only shows up in the render.
    """
    if DEBUG_COLOUR is not None:
        colour = DEBUG_COLOUR
    material = bpy.data.materials.new("VOLYA_" + obj.name)
    material.diffuse_color = (colour[0], colour[1], colour[2], 1.0)
    material.use_nodes = True
    for node in material.node_tree.nodes:
        if node.type == "BSDF_PRINCIPLED":
            node.inputs["Base Color"].default_value = (
                colour[0], colour[1], colour[2], 1.0)
            break
    obj.data.materials.append(material)


# Weapons are built along +X, which is "the way the character is pointing".
# Eight-sided cylinders and boxes: at 121 pixels a matchlock is a stick with a
# lump on it, and anything finer is thrown away by the render.
# Deliberately lighter than real wood. The first club was 0.30/0.19/0.11, which
# is honest oak and also the exact colour of the rusher's leather and his
# breeches - so a correctly sized, correctly aimed club read as a belt. At this
# size a weapon has to separate from the body in one glance or it is not a
# weapon, it is texture.
WOOD = (0.52, 0.36, 0.20)
WOOD_DARK = (0.26, 0.17, 0.10)   # stock and butt: the heavy end reads heavy
IRON = (0.52, 0.55, 0.60)        # barrel: clearly grey, not brown
IRON_DARK = (0.13, 0.14, 0.16)   # lock and trigger: a dark spot to read by
HORN = (0.62, 0.54, 0.38)


def build_arquebus():
    """A matchlock, built to read at 3 pixels wide.

    Rebuilt from the first version, which came out as one pale bar with a
    detached lump floating off the end. Three things were wrong and all three
    are visual, not historical: the parts were thin enough that the pixel pass
    deleted the joins, they were all one colour, and the butt sat low enough to
    separate from the stock.

    Now: dark wood at the back, grey iron at the front, a near-black block at
    the lock so the eye has somewhere to land, and a short flare at the muzzle.
    Every section overlaps its neighbour so the silhouette cannot break apart.
    """
    # Laid out back to front in real metres, every section overlapping the next
    # so the silhouette cannot break. Total reach -0.53 to 0.85 = 1.38 m, which
    # is a matchlock. At 53 px per metre that gives a 3 px barrel, a 6 px stock
    # and an 8 px butt - the thinnest that survives the pixel pass.
    # The wooden part reaches from -0.385 to 0.01, which is 0.40 m - about two
    # thirds of the 0.58 m it used to be. The length it lost went to the
    # barrel, so the whole gun still measures 1.36 m. A matchlock really is
    # mostly barrel; the first version read as a club with a pipe on it.
    parts = [
        box("butt", (0.17, 0.075, 0.150), (-0.30, 0.0, -0.035), WOOD_DARK),
        box("stock", (0.32, 0.070, 0.105), (-0.15, 0.0, -0.015), WOOD_DARK),
        box("lock", (0.11, 0.090, 0.085), (0.00, 0.0, 0.010), IRON_DARK),
        box("trigger", (0.05, 0.050, 0.070), (-0.02, 0.0, -0.055), IRON_DARK),
        cylinder("barrel", 0.032, 0.95, (0.47, 0.0, 0.020), IRON),
        cylinder("muzzle", 0.046, 0.09, (0.93, 0.0, 0.020), IRON),
    ]
    #        parts,  overall length,  where the holding hand sits along +X
    return parts, 1.36, 0.00


def build_spear():
    parts = [
        cylinder("shaft", 0.016, 1.90, (0.10, 0.0, 0.0), WOOD),
        box("point", (0.26, 0.030, 0.070), (1.12, 0.0, 0.0), IRON),
    ]
    return parts, 2.05, 0.00


def build_sword():
    parts = [
        box("blade", (0.78, 0.020, 0.075), (0.42, 0.0, 0.0), IRON),
        box("guard", (0.035, 0.030, 0.200), (0.03, 0.0, 0.0), IRON),
        cylinder("grip", 0.022, 0.18, (-0.08, 0.0, 0.0), HORN),
        box("pommel", (0.055, 0.055, 0.055), (-0.19, 0.0, 0.0), IRON),
    ]
    return parts, 1.00, -0.05


def build_bow():
    parts = [
        box("limb_up", (0.045, 0.025, 0.55), (0.0, 0.0, 0.30), HORN),
        box("limb_down", (0.045, 0.025, 0.55), (0.0, 0.0, -0.30), HORN),
        box("grip", (0.055, 0.040, 0.16), (0.0, 0.0, 0.0), WOOD),
    ]
    return parts, 1.20, 0.00


def build_club():
    """A two-handed cudgel: a cut branch, thicker at the business end.

    Three tapering sections rather than one bar, because at 128 pixels the
    only thing that separates a club from a sword is that one end is fatter.

    It is 1.25 m and not the 0.72 m a one-handed club would be, because the
    rusher's Mixamo animations are the Great Sword set - both hands on the
    shaft. Only the right hand carries the weapon through the bone; the left
    hand simply lands where the animation puts it, so the shaft has to reach
    back roughly 0.35 m behind the right hand or the left one closes on air.
    Shorten this only together with swapping to one-handed animations.

    Reworked 2026-08-08: the head used to be a `box`, which reads as a flat,
    hard-edged block once the rusher is rendered at the size that matches the
    hero (Height ~180) rather than the 128 px the first version was tuned to
    disappear into. Replaced with a third, fatter cylinder - rounded like the
    shaft, just thicker - so the whole thing reads as one turned piece of
    wood instead of a rod with a crate glued to the end. Same ~1.2 m overall
    reach as before, so the fit Pavel already placed by hand still lands;
    only the shape inside that reach changed. Colour is still the flat
    default WOOD - not touched here, on purpose.
    """
    # The shaft is 9 cm and the head 26 cm across. That is thicker than a real
    # cut branch on purpose: at 128 pixels the first version measured 2 px and
    # 6 px, and a two-pixel line next to a body is not read as a weapon at
    # all. Sections overlap their neighbour so the silhouette cannot break.
    parts = [
        cylinder("shaft", 0.036, 0.62, (-0.10, 0.0, 0.0), WOOD),
        cylinder("neck", 0.075, 0.32, (0.29, 0.0, 0.0), WOOD),
        cylinder("head", 0.130, 0.34, (0.62, 0.0, 0.0), WOOD),
    ]
    return parts, 1.20, 0.25


BUILDERS = {
    "arquebus": build_arquebus,
    "spear": build_spear,
    "sword": build_sword,
    "bow": build_bow,
    "club": build_club,
}


def import_weapon_model(path):
    """Load a downloaded weapon mesh and lay it along +X like the built ones.

    Free weapon models are everywhere and are better than six boxes, but they
    come pointing in whatever direction their author liked. Everything here
    assumes a weapon runs along +X with the business end at positive X, so the
    longest axis is rotated onto X once, on import, and never thought about
    again.
    """
    before = set(bpy.data.objects)
    lower = path.lower()
    if lower.endswith(".fbx"):
        bpy.ops.import_scene.fbx(filepath=path)
    elif lower.endswith((".glb", ".gltf")):
        bpy.ops.import_scene.gltf(filepath=path)
    elif lower.endswith(".obj"):
        try:
            bpy.ops.wm.obj_import(filepath=path)
        except AttributeError:
            bpy.ops.import_scene.obj(filepath=path)
    elif lower.endswith(".blend"):
        # Model sites hand out .blend more often than anything else, and it is
        # the best of the formats they offer: native, so nothing is lost in
        # translation, and it carries its materials. Pulling meshes out of
        # another file is "append", not "import".
        with bpy.data.libraries.load(path, link=False) as (source, target):
            target.objects = list(source.objects)
        linked = 0
        for obj in target.objects:
            if obj is not None and obj.type == "MESH":
                bpy.context.scene.collection.objects.link(obj)
                linked += 1
        if linked == 0:
            sys.exit("VOLYA: v %s nie je ziadna siet"
                     % os.path.basename(path))
        print("VOLYA: z .blend som prevzal %d sieti" % linked)
    else:
        sys.exit("VOLYA: neznamy format zbrane: %s\n"
                 "VOLYA: viem .blend, .glb, .gltf, .fbx a .obj. "
                 "Format .3ds nie, ten je zastaraly - ak mas na vyber, "
                 "stiahni .blend alebo .glb." % path)

    fresh = [o for o in bpy.data.objects if o not in before and o.type == "MESH"]
    if not fresh:
        sys.exit("VOLYA: v %s nie je ziadna siet" % os.path.basename(path))

    bpy.ops.object.select_all(action="DESELECT")
    for obj in fresh:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = fresh[0]
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    if len(fresh) > 1:
        bpy.ops.object.join()
    weapon = bpy.context.view_layer.objects.active

    dims = list(weapon.dimensions)
    longest = dims.index(max(dims))
    if longest == 1:
        weapon.rotation_euler = (0.0, 0.0, math.radians(-90.0))
    elif longest == 2:
        weapon.rotation_euler = (0.0, math.radians(90.0), 0.0)
    bpy.ops.object.select_all(action="DESELECT")
    weapon.select_set(True)
    bpy.context.view_layer.objects.active = weapon
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

    length = max(weapon.dimensions)
    print("VOLYA: nacitana zbran %s, dlzka %.2f, najdlhsia os bola %s"
          % (os.path.basename(path), length, "XYZ"[longest]))
    return weapon, length


def settings_for(fit_path):
    """Read the enemy's settings file that belongs to a placement file.

    Placements and decisions live in different files on purpose. They used to
    share one, and saving a new placement wiped the colours, the weapon model
    and the camera angle - the loss was invisible until the next render came
    out with an unarmed man in it. A file that is only ever read cannot be
    destroyed by a save.

        art/fits/gunman_walk.json  ->  art/fits/gunman.settings.json
    """
    if not fit_path:
        return {}
    folder = os.path.dirname(os.path.abspath(fit_path))
    stem = os.path.splitext(os.path.basename(fit_path))[0]
    character = stem.split("_")[0]
    path = os.path.join(folder, character + ".settings.json")
    if not os.path.exists(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except Exception as problem:          # noqa: BLE001
        print("VOLYA: POZOR - %s sa neda precitat: %s"
              % (os.path.basename(path), problem))
        return {}

def split_iron(weapon, fraction):
    """Give the front part of a weapon the iron material instead of the wood.

    A downloaded arquebus has its wooden fore-end running the whole way under
    the barrel, so at sprite size the iron shows as a one pixel line and no
    choice of colour can rescue it. Reassigning faces past a point along the
    weapon is the only fix that keeps the model - and it is one number, which
    can be swept and chosen by eye like everything else here.

    0.35 means "everything past 35 % of the length, measured from the butt".
    """
    fraction = float(fraction)
    if fraction <= 0.0 or fraction >= 1.0:
        return
    mesh = weapon.data
    if not mesh.polygons:
        return

    names = [(slot.material.name.lower() if slot.material else "")
             for slot in weapon.material_slots]

    def slot_matching(*words):
        for index, name in enumerate(names):
            if any(word in name for word in words):
                return index
        return None

    iron = slot_matching("steel", "iron", "metal", "barrel")
    if iron is None:
        material = bpy.data.materials.new("steel")
        material.use_nodes = True
        mesh.materials.append(material)
        iron = len(mesh.materials) - 1
        print("VOLYA: model nemal zelezny material, vytvoril som ho")

    xs = [v.co.x for v in mesh.vertices]
    lo, hi = min(xs), max(xs)
    if hi - lo < 1e-9:
        return
    cut = lo + fraction * (hi - lo)

    moved = 0
    for poly in mesh.polygons:
        centre = sum(mesh.vertices[i].co.x for i in poly.vertices) / len(poly.vertices)
        if centre > cut and poly.material_index != iron:
            poly.material_index = iron
            moved += 1
    print("VOLYA: od %.0f %% dlzky zbrane je zelezo - preradenych %d plosok"
          % (fraction * 100, moved))


def _mesh_bounds(exclude=None):
    """World-space bounding box of every visible mesh except one."""
    lo = mathutils.Vector((1e12, 1e12, 1e12))
    hi = mathutils.Vector((-1e12, -1e12, -1e12))
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH" or obj is exclude:
            continue
        for corner in obj.bound_box:
            world = obj.matrix_world @ mathutils.Vector(corner)
            for axis in range(3):
                lo[axis] = min(lo[axis], world[axis])
                hi[axis] = max(hi[axis], world[axis])
    return lo, hi


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


# Which end of the weapon points away from the holding hand. A club, a sword
# and a spear all reach out past the hand that grips them; a firearm and a bow
# reach out past the OTHER hand, because the trigger hand is the back one.
FORWARD_PAST_OTHER_HAND = ("arquebus", "bow")


def aim_along_hands(armature, hand, weapon_name):
    """Direction the weapon shaft should point, taken from where the hands are.

    Weapons are built along +X and hung off the hand bone, and +X in bone space
    turned out to be roughly straight out of the palm - so a 1.25 m club stood
    out sideways into the depth of the picture and only a stub of it was ever
    on screen. No amount of camera angle fixes that.

    Both hands are on the shaft in every animation we use (the Great Sword set
    for the rusher, the Rifle set for the gunman), so the line between the two
    hands IS the shaft. That is a measurement rather than a guess, and it
    survives swapping the animation, which a hand-tuned rotation would not.

    Returns a world-space direction, or None if the rig has only one hand.
    """
    other = find_hand(armature, "left" if "right" in hand.name.lower()
                      else "right")
    if other is None:
        return None
    try:
        pose_a = armature.pose.bones[hand.name]
        pose_b = armature.pose.bones[other.name]
    except KeyError:
        return None
    world = armature.matrix_world
    a = world @ pose_a.head
    b = world @ pose_b.head
    span = (a - b)
    if span.length < 1e-6:
        return None
    if str(weapon_name).lower() in FORWARD_PAST_OTHER_HAND:
        span = -span
    print("VOLYA: ruky su od seba %.3f jednotiek, mierim zbran po tejto ciare"
          % (a - b).length)
    return span.normalized()


def attach(cfg):
    """Build the weapon and hang it on the hand bone of whatever rig is loaded.

    Split out of main() so the render script can call it in the same Blender
    run as the render. Rendering and attaching in one process is what makes it
    possible to look at the result and correct the offsets from the picture,
    which is the only way these numbers ever come out right.

    Returns the weapon object, or None if there was nothing to attach it to.
    """
    global DEBUG_COLOUR
    DEBUG_COLOUR = MAGENTA if int(cfg.get("debug", 0)) != 0 else None
    if DEBUG_COLOUR is not None:
        print("VOLYA: DEBUG - zbran bude fialova")

    builder = BUILDERS.get(str(cfg["weapon"]).lower())
    if builder is None and not str(cfg.get("model", "")).strip():
        sys.exit("VOLYA: neznama zbran '%s'. Mam: %s (alebo zadaj --model "
                 "s vlastnym suborom)"
                 % (cfg["weapon"], ", ".join(sorted(BUILDERS))))

    armature = find_armature()
    if armature is None:
        sys.exit("VOLYA: v scene nie je kostra. Naimportuj najprv postavu "
                 "z Mixama.")

    body_lo, body_hi = _mesh_bounds()

    hand = find_hand(armature, str(cfg["hand"]))
    if hand is None:
        print("VOLYA: nenasiel som kost ruky. Kosti v rigu:")
        for bone in armature.data.bones:
            print("   %s" % bone.name)
        sys.exit("VOLYA: prerusene.")
    print("VOLYA: ruka = %s" % hand.name)

    model_path = str(cfg.get("model", "")).strip()
    if model_path:
        weapon_obj, model_length = import_weapon_model(os.path.abspath(model_path))
        parts, length, grip_at = None, model_length, 0.0
    else:
        built = builder()
        parts, length, grip_at = (built if len(built) == 3
                                  else (built[0], built[1], 0.0))
    if parts is None:
        weapon = weapon_obj
        weapon.name = "VOLYA_Weapon"
    else:
        bpy.ops.object.select_all(action="DESELECT")
        for part in parts:
            part.select_set(True)
        bpy.context.view_layer.objects.active = parts[0]

    # Bake each part's own scale into its mesh before joining. Without this the
    # joined object keeps the FIRST part's scale, and the uniform scale set a
    # few lines below then wipes it out - blowing the weapon up by however much
    # that part happened to be squashed. It only bit once the first part in the
    # list changed from a cylinder (scale 1) to a box (scale 0.075 in Y), and
    # the arquebus came out fourteen units long next to a 1.9 unit man.
        bpy.ops.object.transform_apply(location=False, rotation=True,
                                       scale=True)
        bpy.ops.object.join()
        weapon = bpy.context.view_layer.objects.active
        weapon.name = "VOLYA_Weapon"

    # The character is about 1.8 m, and a matchlock is about 1.35 m. Scale the
    # weapon to the rig actually loaded rather than assuming Mixamo's units.
    #
    # The division by the armature's own scale is the whole trick. Mixamo's FBX
    # arrives as an armature scaled to 0.01 holding bones a hundred times too
    # big, so the object measures a correct 1.8 units while everything parented
    # to it is shrunk by 100. A weapon built at 1.25 m then renders about one
    # pixel tall, which does not look like a bug - it looks like no weapon at
    # all, and that is exactly how the first two enemy renders came out.
    # The height has to come from the MESH, not from the armature object. An
    # armature's bounding box in Blender is the extent of its bones' own object
    # data, which for a Mixamo import measured 0.67 while the character it
    # deforms was 1.45 tall. Scaling to 0.67 made every weapon 2.2x too small -
    # small enough to sit entirely inside a fat torso and never be seen, which
    # cost several rounds of looking for it in the wrong place.
    height = max(body_hi.z - body_lo.z, 0.01)
    parent_scale = armature.matrix_world.to_scale()
    unit = max(abs(parent_scale.z), 1e-9)
    factor = (height / 1.8) * float(cfg["scale"]) / unit
    weapon.scale = mathutils.Vector((factor, factor, factor))
    print("VOLYA: postava %.2f jednotiek vysoka (kostra sama %.2f), "
          "mierka kostry %.4f, zbran zvacsena %.1fx"
          % (height, armature.dimensions.z, unit, factor))

    # Bone parenting hangs the child off the bone's TAIL, so the weapon has to
    # be placed by hand afterwards - it does not land in the palm on its own.
    weapon.parent = armature
    weapon.parent_type = "BONE"
    weapon.parent_bone = hand.name

    # Point the shaft along the line between the hands, expressed in the hand
    # bone's own axes because that is the space a bone-parented child lives in.
    bpy.context.view_layer.update()
    aim = None
    given = cfg.get("aim_vector")
    if given is not None:
        aim = mathutils.Vector(given).normalized()
        print("VOLYA: zbran mierim zadanym smerom (%.2f %.2f %.2f)"
              % (aim.x, aim.y, aim.z))
    elif int(cfg.get("aim", 1)) != 0:
        aim = aim_along_hands(armature, hand, cfg["weapon"])

    spin = float(cfg.get("spin", 0.0))
    if aim is not None and abs(spin) > 0.01:
        aim = (mathutils.Matrix.Rotation(math.radians(spin), 3, "Z")
               @ aim).normalized()
        print("VOLYA: zbran otocena o %.0f stupnov okolo zvislej osi" % spin)

    turn = mathutils.Matrix.Rotation(math.radians(float(cfg["turn"])), 4, "X")
    if aim is not None:
        basis = (armature.matrix_world
                 @ armature.pose.bones[hand.name].matrix).to_3x3()
        for col in range(3):
            v = basis.col[col]
            if v.length > 1e-9:
                basis.col[col] = v.normalized()
        local = (basis.inverted() @ aim).normalized()
        rot = local.to_track_quat("X", "Z").to_matrix().to_4x4()
        print("VOLYA: zbran natocena podla ruk (%.2f %.2f %.2f v priestore kosti)"
              % (local.x, local.y, local.z))
    else:
        rot = mathutils.Matrix.Identity(4)
        print("VOLYA: druha ruka sa nenasla, zbran ostava v osi X kosti")

    rot = rot @ turn
    # Where the hand sits along the weapon, per weapon. The old formula put it
    # 18 % back from the middle for everything, which for a matchlock is out on
    # the barrel - so the gun hung a quarter of a metre too far forward and
    # came out of the elbow instead of the hands.
    grip_back = -grip_at * factor
    offset = (rot.to_3x3() @ mathutils.Vector((grip_back, 0.0, 0.0))
              + mathutils.Vector((float(cfg["shift_x"]),
                                  float(cfg["shift_y"]),
                                  float(cfg["shift_z"]))))
    weapon.matrix_parent_inverse = mathutils.Matrix.Identity(4)
    weapon.location = offset
    weapon.rotation_euler = rot.to_euler()

    # A placement fitted by hand beats every calculation above, and it is
    # stored against the hand bone, so it holds for every animation of the same
    # character. This is the line that ends the guessing.
    fit_path = str(cfg.get("fit", "")).strip()
    if fit_path:
        if not os.path.exists(fit_path):
            sys.exit("VOLYA: fit subor %s neexistuje" % fit_path)
        with open(fit_path, "r", encoding="utf-8") as handle:
            fit = json.load(handle)
        if fit.get("bone") and fit["bone"] != hand.name:
            print("VOLYA: POZOR - fit bol robeny na kost %s, tu je %s"
                  % (fit["bone"], hand.name))
        weapon.location = mathutils.Vector(fit["location"])
        weapon.rotation_euler = mathutils.Euler(fit["rotation_euler"])
        weapon.scale = mathutils.Vector(fit["scale"])
        print("VOLYA: pouzil som rucne fitovanie z %s"
              % os.path.basename(fit_path))

    print("VOLYA: zbran %s pripnuta na %s" % (cfg["weapon"], hand.name))
    print("VOLYA: posun %.3f %.3f %.3f, otocenie %.0f stupnov"
          % (offset.x, offset.y, offset.z, float(cfg["turn"])))

    # Measure the result instead of trusting the arithmetic. A weapon that ends
    # up microscopic renders as nothing at all, and "nothing at all" is
    # indistinguishable from "the script never ran" when looking at a sprite.
    bpy.context.view_layer.update()
    span = max(weapon.dimensions)
    print("VOLYA: zbran ma vo svete %.2f jednotiek (postava %.2f)"
          % (span, height))

    # WHERE it is, not just how big. Size alone was measured for two rounds and
    # said everything was fine while the weapon rendered nowhere at all; a
    # correct size in the wrong place looks exactly like no weapon.
    centre = weapon.matrix_world.translation
    lo, hi = body_lo, body_hi
    body = hi - lo
    print("VOLYA: zbran stred (%.2f %.2f %.2f)" % (centre.x, centre.y, centre.z))
    print("VOLYA: telo od (%.2f %.2f %.2f) po (%.2f %.2f %.2f)"
          % (lo.x, lo.y, lo.z, hi.x, hi.y, hi.z))
    inside = all(lo[i] - 0.1 * body[i] <= centre[i] <= hi[i] + 0.1 * body[i]
                 for i in range(3))
    print("VOLYA: zbran je %s telom"
          % ("V oblasti tela - musi byt teda schovana za nim / v nom"
             if inside else "MIMO tela"))
    if span < 0.15 * height:
        print("VOLYA: POZOR - zbran je oproti postave zanedbatelna a v renderi "
              "ju neuvidis. Skontroluj mierku importu.")
    elif span > 3.0 * height:
        print("VOLYA: POZOR - zbran je obrovska, vytlaci postavu z zaberu.")

    # The fit file is where a character's decisions live. Anything given on the
    # command line still wins, but nothing has to be repeated.
    iron = float(cfg.get("iron_from", 0.0))
    if iron <= 0.0:
        iron = float(settings_for(fit_path).get("iron_from", 0.0))
        if iron > 0.0:
            print("VOLYA: pomer zeleza %.2f zo settings suboru" % iron)
    split_iron(weapon, iron)

    print("VOLYA: ak sedi zle, oprav to cez --shift_x/--shift_y/--shift_z "
          "a --turn")
    return weapon


def main():
    attach(parse_args())

    if bpy.data.filepath:
        bpy.ops.wm.save_mainfile()
        print("VOLYA: ulozene do %s" % bpy.data.filepath)
    else:
        print("VOLYA: scena nie je ulozena ako .blend, nic som neukladal")


if __name__ == "__main__":
    main()
