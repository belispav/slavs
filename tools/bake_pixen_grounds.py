"""
Slavs - bake the PixelLab pixen ground images and the free ground objects for the game.

Grounds: ref/preview/pixen_<name>.png (672x384 art px) become slavs/art/ground_pixen_<name>.png:
shown at 2x (1344x768), mirrored once so the picture repeats without a seam
(2688 wide), placed on a 2688x1287 picture with its top at row IMG_TOP, transparent
above (the forest layers show through) and the last rows repeated below. Each gets
<name>_top.json / _bottom.json for the walk limits.

Objects: slavs/art/ground_objects.png (atlas) + ground_objects.json, a selection of the stones,
pebbles and grass+moss patches cut by tools/extract_ground_objects.py.

    python tools/bake_pixen_grounds.py
"""
import glob
import json
import numpy as np
from PIL import Image

P = "ref/preview/"
A = "slavs/art/"
IMG_TOP = 350            # picture row where the ground image starts
HEIGHT = 1287            # = main.gd BG_WALK_BOTTOM
NAMES = {"a": "a_minimal", "d": "d_smooth", "e": "e_flat", "f": "f_burned"}

for key, name in NAMES.items():
    im = Image.open(P + "pixen_%s.png" % name).convert("RGB")
    a = np.asarray(im.resize((im.width * 2, im.height * 2), Image.NEAREST))      # 768 x 1344
    a = np.concatenate([a, a[:, ::-1]], axis=1)                                   # 768 x 2688
    h, w, _ = a.shape
    rgba = np.zeros((HEIGHT, w, 4), np.uint8)
    rgba[IMG_TOP:IMG_TOP + h, :, :3] = a
    rgba[IMG_TOP:IMG_TOP + h, :, 3] = 255
    for y in range(IMG_TOP + h, HEIGHT):                                          # reflect the last rows
        rgba[y] = rgba[2 * (IMG_TOP + h) - y - 1]
    Image.fromarray(rgba, "RGBA").save(A + "ground_pixen_%s.png" % key, optimize=True)
    json.dump([IMG_TOP] * w, open(A + "ground_pixen_%s_top.json" % key, "w"))
    json.dump([IMG_TOP + h] * w, open(A + "ground_pixen_%s_bottom.json" % key, "w"))
    print("ground_pixen_%s: %dx%d" % (key, w, HEIGHT))


def load(kind):
    out = []
    for f in sorted(glob.glob(P + "ground_objects/%s_*.png" % kind)):
        im = Image.open(f).convert("RGBA")
        al = np.asarray(im)[..., 3] > 0
        out.append((int(al.sum()), float(al.mean()), im))
    return out


def pick(items, n):
    if len(items) <= n:
        return [i for _, _, i in items]
    idx = np.linspace(0, len(items) - 1, n).astype(int)
    return [items[i][2] for i in idx]


stones = pick([x for x in load("stone") if 60 <= x[0] <= 700 and x[1] > 0.5], 36)
pebbles = pick([x for x in load("stone") if 22 <= x[0] < 60 and x[1] > 0.5], 24)
tufts = pick([x for x in load("tuft") if x[0] >= 150], 24)
sprites = [("stone", s) for s in stones] + [("pebble", s) for s in pebbles] + [("tuft", s) for s in tufts]

# shelf-pack into an atlas
W_ATLAS = 512
x = y = 0
rowh = 0
rects = []
for kind, im in sprites:
    if x + im.width > W_ATLAS:
        x = 0; y += rowh + 1; rowh = 0
    rects.append({"k": kind, "x": x, "y": y, "w": im.width, "h": im.height})
    x += im.width + 1
    rowh = max(rowh, im.height)
atlas = Image.new("RGBA", (W_ATLAS, y + rowh + 1), (0, 0, 0, 0))
for (kind, im), r in zip(sprites, rects):
    atlas.paste(im, (r["x"], r["y"]))
atlas.save(A + "ground_objects.png", optimize=True)
json.dump(rects, open(A + "ground_objects.json", "w"))
print("atlas", atlas.size, len(rects), "objects:", len(stones), "stones,", len(pebbles), "pebbles,", len(tufts), "tufts")
