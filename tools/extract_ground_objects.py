"""
Slavs - cut stones and grass patches out of the PixelLab ground tile (free objects).

A "tuft" is the grass blades AND the irregular green moss patch they grow from, as
one sprite (the patch is what makes grass look planted instead of pasted on brown).
Sprites are written at art resolution (shown 2x in the game), hard alpha.

    python tools/extract_ground_objects.py
Writes ref/preview/ground_objects/{stone,tuft}_NN.png and ground_objects_catalog.png
"""
import os
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

SRC = "ref/preview/ground_pro_512.png"
OUT = "ref/preview/ground_objects"
os.makedirs(OUT, exist_ok=True)
t = np.asarray(Image.open(SRC).convert("RGB")).astype(np.int32)
R, G, B = t[..., 0], t[..., 1], t[..., 2]
L = 0.299 * R + 0.587 * G + 0.114 * B

green = (G >= R - 4) & (G - B > 20)
blade = (G > 105) & (G - B > 55) & (G >= R - 10)
gm = ndi.binary_dilation(green, iterations=2)
gm = ndi.binary_closing(gm, iterations=2)
gm = ndi.binary_fill_holes(gm)
stone = (R - B < 22) & (L > 62) & ~gm & (G - B < 24)
sm = ndi.binary_dilation(stone, iterations=1)       # includes the dark outline
sm &= ~gm


def cut(mask, kind, lo, hi, maxdim):
    lab, n = ndi.label(mask)
    out = []
    for i in range(1, n + 1):
        m = lab == i
        a = int(m.sum())
        ys, xs = np.where(m)
        h, w = ys.max() - ys.min() + 1, xs.max() - xs.min() + 1
        if a < lo or a > hi or h > maxdim or w > maxdim:
            continue
        y0, x0 = ys.min(), xs.min()
        rgba = np.zeros((h, w, 4), np.uint8)
        sub = m[y0:y0 + h, x0:x0 + w]
        rgba[..., :3] = t[y0:y0 + h, x0:x0 + w]
        rgba[..., 3] = np.where(sub, 255, 0)
        out.append((a, rgba))
    out.sort(key=lambda p: p[0])
    return out


stones = cut(sm, "stone", 20, 900, 40)
lab_g, n_g = ndi.label(gm)
has_blade = ndi.maximum(ndi.binary_dilation(blade, iterations=0), lab_g, range(1, n_g + 1))
blade_cnt = ndi.sum(blade, lab_g, range(1, n_g + 1))
tuft_mask = np.isin(lab_g, [i + 1 for i in range(n_g) if blade_cnt[i] >= 6])
moss_mask = np.isin(lab_g, [i + 1 for i in range(n_g) if blade_cnt[i] < 6])
tufts = cut(tuft_mask, "tuft", 40, 4000, 90)
moss = cut(moss_mask, "moss", 60, 4000, 90)
print(len(stones), "stones,", len(tufts), "grass patches,", len(moss), "moss patches")
for k, items in (("stone", stones), ("tuft", tufts), ("moss", moss)):
    for j, (a, im) in enumerate(items):
        Image.fromarray(im).save("%s/%s_%02d.png" % (OUT, k, j))

# catalog: sprites at 2x on a brown board, rows by size
board = Image.new("RGBA", (1400, 1500), (120, 92, 64, 255))
x = y = 10; rowh = 0
for k, items in (("stone", stones), ("tuft", tufts), ("moss", moss)):
    for a, im in items:
        s = Image.fromarray(im).resize((im.shape[1] * 2, im.shape[0] * 2), Image.NEAREST)
        if x + s.width > 1390:
            x = 10; y += rowh + 10; rowh = 0
        if y + s.height > 1490:
            break
        board.alpha_composite(s, (x, y)); x += s.width + 10; rowh = max(rowh, s.height)
    x = 10; y += rowh + 40; rowh = 0
board.convert("RGB").save("ref/preview/ground_objects_catalog.png")
