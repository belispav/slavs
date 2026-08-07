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
    "import": "",      # load this FBX/OBJ/GLB instead of using the open scene
    "out": "//sprites",
    "name": "anim",
    "height": 96,      # rendered pixel height of one frame
    "step": 1,         # render every frame; 30 fps was picked on device over
                       # 15 and 10, which both read as choppy on this cycle
    "frame_start": 0,  # 0 = from the start of the animation
    "frame_end": 0,    # 0 = to the end of the animation
    "angles": 1,       # 1 = single view; 8 = full 45-degree turnaround
    "start_angle": -1.0,  # -1 = work the side view out from the model itself
    "yaw": 0.0,        # degrees turned off pure profile; + = more of the front
    "angle_step": 0.0,  # >0 = spacing between angles in the same sense as yaw,
                        # for a fine sweep; 0 = spread evenly over 360 degrees
    "elevation": 0.0,  # degrees the camera is raised above eye level
    "light_follow": 1,  # 1 = lights turn with the camera, so every angle is lit
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
    "texture": "",       # colour map to put on the model, overriding its own
    # --- weapon --------------------------------------------------------------
    # Empty = no weapon. Otherwise one of blender_attach_weapon.BUILDERS:
    # arquebus, club, spear, sword, bow. The weapon is built and hung on the
    # hand bone in this same run, before the camera is placed, so it counts
    # towards the framing instead of sticking out of the rendered frame.
    "weapon": "",
    "weapon_hand": "right",
    "weapon_scale": 1.0,
    "weapon_shift_x": 0.0,   # metres, relative to the hand bone
    "weapon_shift_y": 0.0,
    "weapon_shift_z": 0.0,
    "weapon_turn": 0.0,      # degrees around the shaft
    "weapon_aim": 1,         # 1 = shaft follows the line between the hands
    "weapon_debug": 0,       # 1 = paint the weapon magenta to find it
    "weapon_only": 0,        # 1 = hide the character and render the weapon alone
    "weapon_spin": 0.0,      # degrees to turn the weapon about the vertical axis
    "weapon_sweep": 0,       # >1 = render this many spins, camera held still
    "weapon_sweep_step": 0.0,  # degrees between them; 0 = spread over 360
    "weapon_model": "",      # a downloaded weapon mesh instead of the built one
    "weapon_fit": "",        # JSON from save_weapon_fit.py; beats everything
    "weapon_iron_from": 0.0,  # 0..1 along the weapon; past this it turns iron
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


def facing_axis():
    """Which way the character is looking, from the rig's rest pose.

    Taken from foot to toe, because in a T-pose the toes point forward on every
    Mixamo rig and nothing else in the skeleton states the facing without a
    sign ambiguity. The shoulder axis alone gives a LINE, not a direction, so a
    camera placed from it lands on the front or the back with equal chance -
    which is how the first enemy render came out showing their backs.

    Returns None if the rig has no feet to ask.
    """
    for obj in bpy.context.scene.objects:
        if obj.type != "ARMATURE":
            continue
        table = _normalised_bone_names(obj)
        vectors = []
        for side in ("left", "right"):
            foot = _find_bone(table, side, "foot")
            toe = _find_bone(table, side, "toe")
            if foot is None or toe is None:
                continue
            span = ((obj.matrix_world @ toe.head_local)
                    - (obj.matrix_world @ foot.head_local))
            span[2] = 0.0
            if span.length > 1e-5:
                vectors.append(span)
        if vectors:
            total = mathutils.Vector((0.0, 0.0, 0.0))
            for v in vectors:
                total += v
            if total.length > 1e-5:
                print("VOLYA: smer pohladu urceny z %d chodidiel" % len(vectors))
                return total.normalized()
    return None


def side_view_azimuth():
    """Camera angle that puts the character in profile.

    The camera at azimuth A looks along (-sin A, cos A). A side view means
    looking straight down the shoulder axis, so A = atan2(-sx, sy).

    Of the two angles that satisfy that, the one the character faces INTO is
    picked, using the feet. Both give a profile, but only one shows the face,
    the front of the tunic and the weapon in the near hand; the other shows a
    back and a shoulder. That is not a horizontal flip in Godot - a flip
    mirrors the same pixels, it cannot turn a character around.
    """
    facing = facing_axis()
    if facing is not None:
        # The camera sits at direction (sin A, -cos A) from the centre. For a
        # profile that has to be perpendicular to the facing; of the two
        # perpendiculars this one leaves the character walking to the LEFT of
        # the frame, which is the direction every enemy moves in this game.
        azimuth = math.degrees(math.atan2(-facing[1], -facing[0])) % 360.0
        # Sanity: the camera direction must be perpendicular to the facing.
        look = mathutils.Vector((-math.sin(math.radians(azimuth)),
                                 math.cos(math.radians(azimuth))))
        if abs(look.dot(mathutils.Vector((facing[0], facing[1])))) > 0.2:
            print("VOLYA: POZOR - vypocet bocneho pohladu nesedi, "
                  "vraciam sa k osi ramien")
        else:
            print("VOLYA: bocny pohlad je %.0f stupnov (z chodidiel)" % azimuth)
            return azimuth

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


def srgb_to_linear(channel):
    """Turn a colour as a screen shows it into the numbers Blender shades with.

    Blender's shader maths is linear; a hex code off a colour picker is sRGB.
    Writing the sRGB number straight into a shader makes everything come out
    far too bright - #3A2616 was typed in and #6D5741 came out, nearly twice as
    light. Worse than being wrong, it made the setting unusable: the number you
    ask for is not the number you get, so no amount of careful choosing helps.
    """
    if channel <= 0.04045:
        return channel / 12.92
    return ((channel + 0.055) / 1.055) ** 2.4


def linear_to_srgb(channel):
    """The way back, for printing. Only ever used in messages to a human."""
    channel = max(0.0, min(1.0, channel))
    if channel <= 0.0031308:
        return channel * 12.92
    return 1.055 * (channel ** (1.0 / 2.4)) - 0.055


def parse_colour_overrides(text):
    """--material_colours "Alpha_Body=C08A6B,Alpha_Joints=6B5540"

    The hex is read as sRGB - what a colour picker or a paint program shows -
    and converted, so what is typed is what the sprite comes out as.
    """
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
            rgb = tuple(srgb_to_linear(int(value[i:i + 2], 16) / 255.0)
                        for i in (0, 2, 4))
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
    # Never read 'use_nodes'. Blender 5.x prints a deprecation warning every
    # time it is touched, that warning goes to stderr, and PowerShell treats
    # anything on stderr from a native command as a failure - which killed a
    # six-variant colour test after the first one. The node tree alone says
    # everything needed anyway.
    if not material or material.node_tree is None:
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

    if material.node_tree is None:
        # Only touch the deprecated flag when there is genuinely no node tree
        # to work with; reading it needlessly prints a warning on every
        # material of every frame.
        try:
            material.use_nodes = True
        except Exception:
            pass
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
    spec = cfg.get("material_colours", "")
    if not spec and cfg.get("weapon_fit"):
        here = os.path.dirname(os.path.abspath(__file__))
        if here not in sys.path:
            sys.path.insert(0, here)
        import blender_attach_weapon as _W
        spec = _W.settings_for(cfg["weapon_fit"]).get("colours", "")
        if spec:
            print("VOLYA: farby zo settings suboru: %s" % spec)
    overrides = parse_colour_overrides(spec)

    # A colour map supplied on the command line beats whatever the model
    # carries. Mixamo returns a rigged mesh with no texture, while the
    # generator's own export has the texture but no rig - and since it is the
    # same mesh with the same UVs, one can simply be put on the other.
    forced = None
    if cfg.get("texture"):
        path = os.path.abspath(cfg["texture"])
        if os.path.exists(path):
            forced = bpy.data.images.load(path, check_existing=True)
            print("VOLYA: textura z prikazoveho riadku: %s (%dx%d)"
                  % (os.path.basename(path), forced.size[0], forced.size[1]))
        else:
            print("VOLYA: POZOR - texturu %s som nenasiel" % path)

    seen = []
    done = 0
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue

        # A mesh can arrive with no material at all - Mixamo returns the rig
        # and the geometry but drops the material along with the texture. There
        # is then nothing to rebuild, and the model renders in Blender's default
        # grey no matter what texture was supplied. So make one.
        if not any(slot.material for slot in obj.material_slots):
            created = bpy.data.materials.new("VOLYA_" + obj.name)
            obj.data.materials.append(created)
            print("VOLYA:   %s nemal ziadny material, vytvoril som mu ho"
                  % obj.name)

        if forced is not None and not obj.data.uv_layers:
            print("VOLYA:   POZOR - %s nema UV mapu, texturu nie je kam "
                  "polozit. Bude jednofarebny." % obj.name)

        for slot in obj.material_slots:
            material = slot.material
            if material is None or material.name in seen:
                continue
            # Already flattened once. Running the rebuild a second time reads
            # the toon node tree as if it were the original material, finds no
            # texture in it, and repaints the character in one flat colour -
            # which is exactly what happened to the gunman during a weapon
            # sweep, where this is called again for every new weapon.
            if material.get("VOLYA_toon"):
                continue
            material["VOLYA_toon"] = 1
            seen.append(material.name)

            image, base = None, overrides.get(material.name.lower())
            source = "rucne zadana"
            if forced is not None:
                image, base, source = forced, None, "textura zvonku"
            elif base is None:
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
                    # Printed back as sRGB - the same numbers that were typed
                    # in. Printing the internal linear value instead reported
                    # 4A3016 as 110702 and read like the setting was ignored.
                    shown = tuple(int(round(linear_to_srgb(c) * 255))
                                  for c in base[:3])
                    print("VOLYA:   %-28s #%02X%02X%02X               (%s)"
                          % (material.name, shown[0], shown[1], shown[2],
                             source))
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

    # Elevation lifts the camera and tilts it back down at the same point, so
    # the floor reads. The genre draws characters from slightly above for
    # exactly that reason; a strict side view gives no ground plane at all and
    # nothing on screen says where a character's feet are relative to a cage or
    # an enemy. 0 keeps the old strict side view.
    elev = math.radians(float(cfg["elevation"]))
    cam.location = (0.0, -distance * math.cos(elev), distance * math.sin(elev))
    cam.rotation_euler = (math.radians(90.0) - elev, 0.0, 0.0)
    if abs(float(cfg["elevation"])) > 0.01:
        print("VOLYA: kamera zdvihnuta o %.0f stupnov" % float(cfg["elevation"]))

    bpy.context.scene.camera = cam
    return pivot


def build_lights(cfg, pivot=None):
    """Simple light rig, by default parented to the camera pivot.

    The lights used to sit in world space, and that turned out to decide the
    render for us: the key light comes from -Y, so of the two valid profile
    angles one was lit and the other came out almost black. The first enemy
    render landed on the dark one and nothing could be judged from it - not the
    weapon, not the silhouette.

    Hanging the lights off the same pivot as the camera means every azimuth is
    lit identically, so the angle can be chosen for how the character reads
    rather than for where the sun happens to be. It also makes an eight-angle
    preview usable, since all eight frames are now lit the same.

    Pass light_follow=0 for the old world-space behaviour.
    """
    lo, hi = visible_mesh_bounds()
    center = (lo + hi) * 0.5
    height = max(hi[2] - lo[2], 1e-4)
    reach = height * 3.0
    follow = pivot is not None and int(cfg.get("light_follow", 1)) != 0

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
        obj.rotation_euler = (-vec).to_track_quat("-Z", "Y").to_euler()
        if follow:
            # Pivot-local: the pivot already sits at the centre, so the offset
            # is the direction alone. matrix_parent_inverse has to be identity
            # or Blender folds the pivot's current transform in and the light
            # stops turning with the camera.
            obj.parent = pivot
            obj.matrix_parent_inverse = mathutils.Matrix.Identity(4)
            obj.location = vec * reach
        else:
            obj.location = center + vec * reach
    print("VOLYA: svetla %s"
          % ("otacaju sa s kamerou" if follow else "fixne vo svete"))


# ------------------------------------------------------------------- render --

def sync_frame_range(cfg=None):
    """FBX import does not always set the scene range - take it from the actions.

    --frame_start / --frame_end cut a window out of it afterwards. That is not
    a convenience: a downloaded animation can contain frames that are unusable
    for a side view (the rusher's idle turns him a quarter turn away from the
    camera halfway through), and an idle only has to loop, not to be complete.
    """
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

    if cfg is None:
        return
    scene = bpy.context.scene
    want_lo = int(cfg.get("frame_start", 0))
    want_hi = int(cfg.get("frame_end", 0))
    if want_lo > 0:
        scene.frame_start = max(scene.frame_start, want_lo)
    if want_hi > 0:
        scene.frame_end = min(scene.frame_end, want_hi)
    if scene.frame_end < scene.frame_start:
        scene.frame_end = scene.frame_start
    if want_lo > 0 or want_hi > 0:
        print("VOLYA: orezane na %d-%d"
              % (scene.frame_start, scene.frame_end))


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
    step = float(cfg.get("angle_step", 0.0))
    if step > 0.0:
        # Subtracted, so the sweep walks in the same direction as --yaw: frame
        # a00 is the given yaw and each following frame is one step more of the
        # front. That makes the answer readable straight off the contact sheet -
        # "a03 is right" means "--yaw <start + 3 steps>".
        azimuth = float(cfg["start_angle"]) - step * index
    else:
        azimuth = float(cfg["start_angle"]) + (360.0 / total) * index
    pivot.rotation_euler = (0.0, 0.0, math.radians(azimuth))

    out_dir = bpy.path.abspath(cfg["out"])
    os.makedirs(out_dir, exist_ok=True)
    prefix = "%s_a%02d_" % (cfg["name"], index)
    scene.render.filepath = os.path.join(out_dir, prefix)

    print("VOLYA: rendering angle %d/%d (%.1f deg) frames %d-%d step %d -> %s"
          % (index + 1, total, azimuth, scene.frame_start, scene.frame_end,
             scene.frame_step, out_dir))
    bpy.ops.render.render(animation=True, write_still=False)


def import_source(path):
    """Load a model file into an empty scene.

    Saves a round trip through the Blender UI: a rigged FBX straight from
    Mixamo can be rendered without opening anything by hand, which matters
    because every character will go through this several times.
    """
    if not path:
        return
    path = os.path.abspath(path)
    if not os.path.exists(path):
        raise RuntimeError("subor neexistuje: %s" % path)

    bpy.ops.wm.read_factory_settings(use_empty=True)
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
    else:
        raise RuntimeError("neznamy format: %s" % path)
    print("VOLYA: nacitane %s" % os.path.basename(path))


def attach_weapon(cfg):
    """Hang a weapon on the imported rig, if one was asked for.

    Done here rather than as a separate Blender run, because the camera is
    framed from the model's bounding box: attaching afterwards would push the
    weapon outside the frame that was already decided.
    """
    name = str(cfg.get("weapon", "")).strip()
    model = str(cfg.get("weapon_model", "")).strip()
    if not name and not model:
        return None
    here = os.path.dirname(os.path.abspath(__file__))
    if here not in sys.path:
        sys.path.insert(0, here)
    import blender_attach_weapon
    return blender_attach_weapon.attach({
        "weapon": name,
        "hand": cfg["weapon_hand"],
        "scale": float(cfg["weapon_scale"]),
        "shift_x": float(cfg["weapon_shift_x"]),
        "shift_y": float(cfg["weapon_shift_y"]),
        "shift_z": float(cfg["weapon_shift_z"]),
        "turn": float(cfg["weapon_turn"]),
        "aim": int(cfg["weapon_aim"]),
        "debug": int(cfg["weapon_debug"]),
        "spin": float(cfg["weapon_spin"]),
        "model": cfg["weapon_model"],
        "fit": cfg["weapon_fit"],
        "iron_from": float(cfg["weapon_iron_from"]),
    })


def main():
    cfg = parse_args()

    import_source(cfg["import"])
    weapon = attach_weapon(cfg)

    # Rendering the weapon on its own answers "is it hidden or is it missing?",
    # which no amount of looking at the finished sprite can.
    if weapon is not None and int(cfg["weapon_only"]) != 0:
        hidden = 0
        for obj in bpy.context.scene.objects:
            if obj.type == "MESH" and obj is not weapon:
                obj.hide_render = True
                hidden += 1
        print("VOLYA: DEBUG - skryl som %d sietí, renderujem len zbran" % hidden)

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

    # Positive yaw turns the camera towards the character's front. Straight
    # profile hides everything held across the body - a club, an arquebus at
    # the waist - so a few degrees of front is worth more than it sounds.
    yaw = float(cfg["yaw"])
    if abs(yaw) > 0.01:
        cfg["start_angle"] = (float(cfg["start_angle"]) - yaw) % 360.0
        print("VOLYA: natocene o %.0f stupnov k prednej strane -> %.0f stupnov"
              % (yaw, cfg["start_angle"]))

    sync_frame_range(cfg)
    configure_render(cfg, engine)
    if toon:
        apply_toon_shading(cfg)
    pivot = build_camera(cfg)
    build_lights(cfg, pivot)

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

    sweep = int(cfg["weapon_sweep"])
    if sweep > 1 and (str(cfg["weapon"]).strip()
                      or str(cfg["weapon_model"]).strip()):
        # Same trick that settled the camera: instead of arguing about which
        # way the weapon should point, render every option once and let a human
        # look. The camera is held still so only one thing changes per frame.
        base = float(cfg["weapon_spin"])
        gap = float(cfg["weapon_sweep_step"]) or (360.0 / sweep)
        pivot.rotation_euler = (0.0, 0.0, math.radians(float(cfg["start_angle"])))
        out_dir = bpy.path.abspath(cfg["out"])
        os.makedirs(out_dir, exist_ok=True)
        for index in range(sweep):
            for obj in list(bpy.data.objects):
                if obj.name.startswith("VOLYA_Weapon"):
                    bpy.data.objects.remove(obj, do_unlink=True)
            cfg["weapon_spin"] = base + gap * index
            attach_weapon(cfg)
            if toon:
                apply_toon_shading(cfg)
            scene.render.filepath = os.path.join(
                out_dir, "%s_a%02d_" % (cfg["name"], index))
            print("VOLYA: spin %d/%d = %.0f stupnov"
                  % (index + 1, sweep, cfg["weapon_spin"]))
            bpy.ops.render.render(animation=True, write_still=False)
        print("VOLYA: hotovo - %d natoceni zbrane, kamera stala" % sweep)
        return

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
