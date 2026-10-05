"""
Slavs - the two full-screen Nano Banana ground images (16:9) in the game scene.

Each image is shown twice: (1) as it came, 1 image pixel = 1 world unit, as a whole
screen; (2) at the game's pixel size (2 world units per art pixel), mirrored into a
field, with the forest above, to judge how stones and grass feel next to the hero.

    python tools/nb_scene_mock.py
"""
import numpy as np
from PIL import Image
import sys
sys.path.insert(0, "tools")
import nb_ground_mock as g

IM = "ref/preview/"
files = {10: ("nb_scene_a.jpg", 3), 11: ("nb_scene_b.jpg", 4)}


def mirrored(a):
    top = np.concatenate([a, a[:, ::-1]], axis=1)
    return np.concatenate([top, top[::-1]], axis=0)


def characters(c, y_hero=520, y_rusher=640, y_barrel=585):
    def put(path, fr, cx, fy, s=2):
        im = Image.open(g.ART + path).convert("RGBA"); im = im.resize((im.width * s, im.height * s), Image.NEAREST)
        c.alpha_composite(im, (cx - im.width // 2, fy - fr * s))
    put("hero_pl_axe_idle/idle_0000.png", 79, 330, y_hero)
    put("rusher_pl_idle/idle_0000.png", 88, 900, y_rusher)
    put("barrel_pl/barrel_0000.png", 40, 620, y_barrel)


def main():
    out = []
    for n, (name, block) in files.items():
        im = Image.open(IM + name).convert("RGBA")
        c = im.crop((48, 24, 48 + 1280, 24 + 720))
        characters(c)
        out.append(c.convert("RGB"))
    for n, (name, block) in files.items():
        art = g.to_art_grid(IM + name, BLOCK=block)
        print(n, "art grid", art.shape)
        out.append(g.scene(g.ground(mirrored(art))))
    for i, o in enumerate(out):
        o.save(IM + "nbs_%d.png" % i)
    sheet = Image.new("RGB", (1280, 720 * len(out)))
    for i, o in enumerate(out):
        sheet.paste(o, (0, 720 * i))
    sheet.save(IM + "nbs_compare.png")


if __name__ == "__main__":
    main()
