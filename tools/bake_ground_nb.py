"""
Slavs - bake the Nano Banana ground sections into slavs/art/env_10.png.

Input: ref/preview/nb2_panorama_raw.png (two sections stitched with a minimum
error cut, magenta #FF00FF above an uneven earth edge). Output:

  * slavs/art/env_10.png        - magenta keyed out, periodic (the right end is
                                  stitched into the left start with a min cut),
                                  colours reduced to a hard palette, padded so the
                                  edge sits where the forest layers expect it
                                  (rows ~276-390) and 1287 rows tall, the same
                                  BG_WALK_BOTTOM as env_08/env_09
  * slavs/art/env_10_top.json   - first ground row per column
  * slavs/art/env_10_bottom.json - 1287 for every column (ground to the bottom)

    python tools/bake_ground_nb.py
"""
import json
import numpy as np
from PIL import Image, ImageFilter
import sys
sys.path.insert(0, "tools")
from bake_ground import min_cut

SRC = "ref/preview/nb2_panorama_raw.png"
OUT = "slavs/art/env_10"
OV = 300              # px overlap for the wrap stitch
COLOURS = 64
TOP_EDGE_ROW = 276    # where the highest point of the edge should land
HEIGHT = 1287         # = main.gd BG_WALK_BOTTOM


def main():
    P = np.asarray(Image.open(SRC).convert("RGB")).astype(np.int32)
    h, W, _ = P.shape
    # key magenta (JPEG halo: dilate 2 px)
    r, g, b = P[..., 0], P[..., 1], P[..., 2]
    mag = ((r - g) > 70) & ((b - g) > 50)
    mag = np.asarray(Image.fromarray((mag * 255).astype(np.uint8))
                     .filter(ImageFilter.MaxFilter(5))) > 0
    # make the keyed pixels a constant so they cost nothing in the error
    P[mag] = (255, 0, 255)

    # --- periodic: choose the period where the tail matches the head best ----
    best = None
    for Wp in range(W - OV - 260, W - OV + 1, 4):
        tail = P[:, Wp:Wp + OV]; head = P[:, :OV]
        e = ((tail - head) ** 2).sum(axis=2).mean()
        if best is None or e < best[0]:
            best = (e, Wp)
    e, Wp = best
    tail = P[:, Wp:Wp + OV]; head = P[:, :OV]
    err = ((tail - head) ** 2).sum(axis=2).astype(float)
    cut = min_cut(err[:, 20:OV - 20]) + 20
    Q = P[:, :Wp].copy()
    for y in range(h):
        Q[y, :cut[y]] = tail[y, :cut[y]]
    print("period %d (tail/head error %.0f), cut %d..%d" % (Wp, e, cut.min(), cut.max()))

    mask = (Q == (255, 0, 255)).all(axis=2)
    # --- palette: kills JPEG noise, hard blocks ------------------------------
    ground = Image.fromarray(np.where(mask[..., None], Q[mask == False][0] if (~mask).any() else 0, Q).astype(np.uint8))
    ground = ground.quantize(colors=COLOURS, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    G = np.asarray(ground)
    top_rows = np.where(~mask, np.arange(h)[:, None], 10 ** 6).min(axis=0)
    pad = TOP_EDGE_ROW - int(top_rows.min())
    total = pad + h
    rgba = np.zeros((HEIGHT, Wp, 4), np.uint8)
    rgba[pad:pad + h, :, :3] = G
    rgba[pad:pad + h, :, 3] = np.where(mask, 0, 255)
    extra = HEIGHT - total
    if extra > 0:                       # reflect the last rows to reach HEIGHT
        rgba[pad + h:HEIGHT] = rgba[pad + h - 1 - np.arange(extra)][:extra]
    elif extra < 0:
        rgba = rgba[:HEIGHT]
    Image.fromarray(rgba, "RGBA").save(OUT + ".png", optimize=True)
    top = (top_rows + pad).astype(int)
    json.dump([int(v) for v in top], open(OUT + "_top.json", "w"))
    json.dump([HEIGHT] * Wp, open(OUT + "_bottom.json", "w"))
    print("wrote %s.png %dx%d, edge rows %d-%d, depth below highest edge point %d" %
          (OUT, Wp, HEIGHT, top.min(), top.max(), HEIGHT - top.max()))


if __name__ == "__main__":
    main()
