"""
Slavs - T12: natural top edge for the walkable ground (pixen A).

The ground picture used to start on one straight row (IMG_TOP = 350), so the dirt met
the forest in a ruled line. This bakes an irregular verge ABOVE that row:

  * the dirt is extended upward by a smooth-but-uneven profile (4..44 px, art-pixel steps),
    filled with the dirt's own texture mirrored across row 350 (no new colours),
  * the outermost art pixel of the verge is darkened (outline rule: ring from the body
    colour, x0.55) so it reads against the forest,
  * grass+moss tufts from art/ground_objects.png (kind "tuft") sit on the edge.

Rows >= IMG_TOP keep their pixels (except the dark lip, which is only on the new verge),
so the walk limit does not change: ground_pixen_a_top.json stays at 350 and the hero
still walks exactly one screen of ground. The verge is scenery behind his feet.

Idempotent: the first run saves the straight picture to ref/ground_pixen_a_straight.png
(local only, not in git) and every later run starts from that copy.

    python tools/bake_ground_edge.py
"""

import json
import os
import shutil

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "slavs", "art")
GROUND = os.path.join(ART, "ground_pixen_a.png")
STRAIGHT = os.path.join(ROOT, "ref", "ground_pixen_a_straight.png")
IMG_TOP = 350            # first ground row (art_px aligned: even)
S = 2                    # art pixel -> picture pixel
MIN_H, MAX_H = 2, 22     # verge height range, art px
SEED = 12
TUFT_EVERY = (22, 60)    # art px between tufts (random range)
LIP = 0.55               # darkening of the outermost verge pixel


def periodic_noise(n, rng, waves):
    """Smooth, seamlessly wrapping noise in 0..1 as a sum of cosines."""
    x = np.arange(n) / n
    v = np.zeros(n)
    tot = 0.0
    for k, amp in waves:
        ph = rng.uniform(0, 2 * np.pi)
        v += amp * np.cos(2 * np.pi * k * x + ph)
        tot += amp
    v = (v / tot + 1.0) / 2.0
    return (v - v.min()) / (v.max() - v.min())


def main():
    if not os.path.exists(STRAIGHT):
        os.makedirs(os.path.dirname(STRAIGHT), exist_ok=True)
        shutil.copyfile(GROUND, STRAIGHT)
    img = np.array(Image.open(STRAIGHT).convert("RGBA"))
    H, W = img.shape[:2]
    assert (img[:IMG_TOP, :, 3] == 0).all() and (img[IMG_TOP, :, 3] == 255).all()
    rng = np.random.default_rng(SEED)
    na = W // S                                    # art columns (1344)

    # edge height per art column, in art px
    prof = (periodic_noise(na, rng, [(5, 1.0), (9, 0.8), (17, 0.6), (31, 0.5), (67, 0.35)]))
    prof = MIN_H + prof * (MAX_H - MIN_H)
    prof = np.round(prof + rng.integers(-1, 2, na) * 0.6).clip(MIN_H, MAX_H).astype(int)

    out = img.copy()
    top_row = np.full(na, IMG_TOP, dtype=int)
    for c in range(na):
        h = prof[c] * S
        x0, x1 = c * S, c * S + S
        for j in range(1, h + 1):                   # j-th row above IMG_TOP
            src = IMG_TOP + 40 + (j - 1)            # dirt from 40 px lower, shifted sideways:
            sx = (x0 + 700) % W                     # no mirror symmetry along the edge
            out[IMG_TOP - j, x0:x1] = img[src, sx:sx + S]
        top_row[c] = IMG_TOP - h
        # dark lip: outermost art pixel row of the column
        lip_rows = slice(IMG_TOP - h, IMG_TOP - h + S)
        out[lip_rows, x0:x1, :3] = (out[lip_rows, x0:x1, :3] * LIP).astype(np.uint8)
        # a second, lighter-darkened row under the lip sells the roundness
        r2 = slice(IMG_TOP - h + S, IMG_TOP - h + 2 * S)
        out[r2, x0:x1, :3] = (out[r2, x0:x1, :3] * 0.8).astype(np.uint8)

    # grass + moss tufts standing on the edge
    atlas = Image.open(os.path.join(ART, "ground_objects.png")).convert("RGBA")
    rects = [r for r in json.load(open(os.path.join(ART, "ground_objects.json"))) if r["k"] == "tuft"]
    tufts = []
    for r in rects:
        t = atlas.crop((r["x"], r["y"], r["x"] + r["w"], r["y"] + r["h"]))
        tufts.append(t.resize((t.width * S, t.height * S), Image.NEAREST))
    pic = Image.fromarray(out)
    c = int(rng.integers(0, 20))
    placed = 0
    while c < na - 8:
        t = tufts[int(rng.integers(0, len(tufts)))]
        if rng.random() < 0.5:
            t = t.transpose(Image.FLIP_LEFT_RIGHT)
        tw = t.width // S
        cc = min(c, na - tw)
        base = int(top_row[cc:cc + tw].max() + 2 * S)   # lowest edge point of its span: base always in dirt
        pic.alpha_composite(t, (cc * S, base - t.height))
        placed += 1
        c += tw + int(rng.integers(*TUFT_EVERY))
    # wrap: copy the first 2*MAXtuft columns' overhang is not needed - tufts stay inside 0..W
    pic.save(GROUND, optimize=True)
    json.dump([IMG_TOP] * W, open(os.path.join(ART, "ground_pixen_a_top.json"), "w"))
    print("verge h(art px) min/mean/max:", prof.min(), round(prof.mean(), 1), prof.max(),
          "| tufts:", placed, "| top edge row min:", int(top_row.min()))


if __name__ == "__main__":
    main()
