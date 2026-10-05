"""
Slavs - the three PixelLab pixen ground images (672x384 art pixels = 1344x768 world
units at 2x, i.e. exactly one screen) in the game scene.

    python tools/pixen_scene_mock.py
Writes ref/preview/pixen_full.png (ground fills the screen) and pixen_forest.png
(forest above, ground below, like the SCENA BEZ SCROLLU layout).
"""
import sys
import numpy as np
from PIL import Image
sys.path.insert(0, "tools")
import nb_ground_mock as g
import nb_scene_mock as s

P = "ref/preview/"
names = ["a_minimal", "b_low", "c_medium"]


def world(name):
    im = Image.open(P + "pixen_%s.png" % name).convert("RGBA")
    return im.resize((im.width * 2, im.height * 2), Image.NEAREST)


def full(name):
    c = world(name).crop((32, 24, 32 + 1280, 24 + 720))
    s.characters(c)
    return c.convert("RGB")


def forest(name, top=190):
    sky = g.sky
    c = Image.new("RGBA", (1280, 720), (0, 0, 0, 255))
    for y in (265 - 160, -606 - 160):
        t = sky.crop((800, 0, 800 + 1280, sky.height))
        if 0 <= y < 720: c.alpha_composite(t, (0, y))
        elif y < 0 and y + t.height > 0: c.alpha_composite(t.crop((0, -y, 1280, t.height)), (0, 0))
    c.alpha_composite(world(name).crop((32, 0, 32 + 1280, 720 - top)), (0, top))
    s.characters(c)
    return c.convert("RGB")


def main():
    for tag, fn in (("full", full), ("forest", forest)):
        panels = [fn(n) for n in names]
        sheet = Image.new("RGB", (1280, 720 * 3))
        for i, p in enumerate(panels):
            sheet.paste(p, (0, 720 * i))
        sheet.save(P + "pixen_%s.png" % tag)


if __name__ == "__main__":
    main()
