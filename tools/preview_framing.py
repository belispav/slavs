"""
VOLYA - draw what the phone will actually show, before building anything.

Framing has been argued about in numbers for several rounds and got worse each
time, because a number does not say whether the water is on screen. This
composites the real background, the real sprite and the real camera arithmetic
into pictures of the finished shot.

Reads the constants out of main.gd, so it cannot drift from the game.

    python tools/preview_framing.py

Writes preview_framing.png next to the outputs.
"""

import os
import re
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    sys.exit("VOLYA: chyba kniznica. Spusti:  pip install pillow")


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAIN = os.path.join(ROOT, "volya", "scripts", "main.gd")
SPRITES = os.path.join(ROOT, "volya", "art", "run_px")

# What the phone shows. The game renders 1280x720 units but stretches to fit,
# uncovering more at the sides: about 1600x720 of world is visible.
VIEW_W, VIEW_H = 1600, 720

LABEL = (235, 238, 245)
MARK_FIELD = (120, 220, 140)
MARK_EDGE = (255, 140, 120)


def constant(name, default=None):
    text = open(MAIN, encoding="utf-8").read()
    found = re.search(r"^const\s+%s\s*:?=\s*([-\d.]+)" % name, text, re.M)
    if found:
        return float(found.group(1))
    found = re.search(r'^const\s+%s\s*:?=\s*"([^"]+)"' % name, text, re.M)
    if found:
        return found.group(1)
    if default is None:
        sys.exit("VOLYA: v main.gd som nenasiel %s" % name)
    return default


def character():
    """The tallest frame of the walk, so the framing is judged on the worst case."""
    names = sorted(n for n in os.listdir(SPRITES) if n.endswith(".png"))
    if not names:
        return None
    best = None
    for name in names:
        image = Image.open(os.path.join(SPRITES, name)).convert("RGBA")
        box = image.getbbox()
        if box is None:
            continue
        cropped = image.crop(box)
        if best is None or cropped.height > best.height:
            best = cropped
    return best


def main():
    ground_y = constant("GROUND_Y")
    walk_top = constant("BG_WALK_TOP")
    walk_bottom = constant("BG_WALK_BOTTOM")
    bg_name = os.path.basename(str(constant("BACKGROUND_PATH")))

    background = Image.open(os.path.join(ROOT, "volya", "art", bg_name)).convert("RGB")
    bg_h = background.height

    # Same arithmetic as main.gd.
    bg_top = ground_y - walk_bottom                 # world y of image row 0
    foot_top = ground_y - (walk_bottom - walk_top)  # highest the feet may go
    foot_bottom = ground_y

    cam_min = bg_top + VIEW_H * 0.5
    cam_max = bg_top + bg_h - VIEW_H * 0.5

    body = character()
    body_h = body.height if body else 130
    feet_offset = 27.0        # half the collision box: player.gd SIZE.y * 0.5

    shots = [
        ("vzadu pri hradbe", foot_top),
        ("v strede pola", (foot_top + foot_bottom) * 0.5),
        ("vpredu pri vode", foot_bottom),
    ]

    panels = []
    for title, feet_y in shots:
        centre = min(max(feet_y - feet_offset, cam_min), cam_max)
        top_world = centre - VIEW_H * 0.5

        row = int(round(top_world - bg_top))
        strip = background.crop((0, row, min(VIEW_W, background.width), row + VIEW_H))
        if strip.width < VIEW_W:
            tiled = Image.new("RGB", (VIEW_W, VIEW_H))
            for x in range(0, VIEW_W, strip.width):
                tiled.paste(strip, (x, 0))
            strip = tiled

        if body:
            scaled = body.resize((int(body.width * body_h / body.height), body_h),
                                 Image.NEAREST)
            x = VIEW_W // 2 - scaled.width // 2
            y = int(round(feet_y - top_world)) - scaled.height
            strip.paste(scaled, (x, y), scaled)

        draw = ImageDraw.Draw(strip)
        for edge, colour, text in (
                (foot_top, MARK_FIELD, "sem az smu nohy (vzadu)"),
                (foot_bottom, MARK_FIELD, "sem az smu nohy (vpredu)")):
            y = int(round(edge - top_world))
            if 0 <= y < VIEW_H:
                draw.line([(0, y), (VIEW_W, y)], fill=colour, width=2)
                draw.text((12, y + 6), text, fill=colour)
        draw.rectangle([0, 0, VIEW_W - 1, VIEW_H - 1], outline=MARK_EDGE, width=3)
        draw.text((12, 12), "%s   (nohy na y=%.0f)" % (title, feet_y), fill=LABEL)
        panels.append(strip)

    gap = 16
    sheet = Image.new("RGB", (VIEW_W, (VIEW_H + gap) * len(panels) + gap),
                      (26, 28, 32))
    for index, panel in enumerate(panels):
        sheet.paste(panel, (0, gap + index * (VIEW_H + gap)))
    sheet = sheet.resize((sheet.width // 2, sheet.height // 2), Image.LANCZOS)

    out = os.path.join(ROOT, "preview_framing.png")
    sheet.save(out)

    print("VOLYA: pozadie %s, %d px vysoke" % (bg_name, bg_h))
    print("VOLYA: pas pre nohy  svet %.0f .. %.0f  (%.0f jednotiek)"
          % (foot_top, foot_bottom, foot_bottom - foot_top))
    print("VOLYA: kamera stred  %.0f .. %.0f  (posun %.0f)"
          % (cam_min, cam_max, cam_max - cam_min))
    print("VOLYA: postava vysoka %d px" % body_h)
    print("VOLYA: ulozene %s" % out)


if __name__ == "__main__":
    main()
