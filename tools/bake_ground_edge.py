"""
Slavs - T12: natural top edge for the walkable ground (pixen A).

The ground picture used to start on one straight row (IMG_TOP = 350), so the dirt met
the forest in a ruled line. This bakes an irregular edge INTO the picture:

  * the top of the dirt is cut into an uneven silhouette: the edge of each art-pixel
    column lies between IMG_TOP and IMG_TOP + 2*MAX_D px (so the walkable ground is never
    taller than one screen),
  * the outermost rows of the edge (and its steep sides) are darkened - outline rule,
    colour from the body, not black. Three strengths, --lip 1|2|3,
  * grass+moss tufts and stones from art/ground_objects.png sit on the edge, three
    amounts, --density few|mid|many,
  * ground_pixen_a_top.json = the new edge row per picture column, so the hero walks
    along the edge (main.gd already reads it; set_dynamic_top in player.gd).

Idempotent: the first run saves the straight picture to ref/ground_pixen_a_straight.png
(local only, not in git); every later run starts from that copy.

    python tools/bake_ground_edge.py --preview      # writes 2 contact sheets, changes nothing
    python tools/bake_ground_edge.py --lip 2 --density mid --apply
"""

import argparse
import json
import os
import shutil

import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "slavs", "art")
GROUND = os.path.join(ART, "ground_pixen_a.png")
TOPJSON = os.path.join(ART, "ground_pixen_a_top.json")
STRAIGHT = os.path.join(ROOT, "ref", "ground_pixen_a_straight.png")
SKY = os.path.join(ART, "env_07_sky.png")
OUTDIR = os.path.join(ROOT, "Claude outputs")
IMG_TOP = 350            # first ground row of the straight picture (even)
S = 2                    # art pixel -> picture pixel
MIN_D, MAX_D = 1, 22     # how far the edge sits below IMG_TOP, art px
SEED = 12

# darkening, multiplier per art-pixel row counted from the outermost one
LIPS = {1: [0.55, 0.8],
        2: [0.38, 0.62, 0.85],
        3: [0.22, 0.45, 0.70, 0.88]}
# (spacing range between elements in art px, probability that an element is a stone)
DENSITY = {"few": ((45, 120), 0.35), "mid": ((22, 60), 0.35), "many": ((10, 30), 0.35)}


def periodic_noise(n, rng, waves):
    """Smooth, seamlessly wrapping noise normalised to 0..1 (sum of cosines)."""
    x = np.arange(n) / n
    v = np.zeros(n)
    for k, amp in waves:
        v += amp * np.cos(2 * np.pi * k * x + rng.uniform(0, 2 * np.pi))
    return (v - v.min()) / (v.max() - v.min())


def load_sprites():
    atlas = Image.open(os.path.join(ART, "ground_objects.png")).convert("RGBA")
    rects = json.load(open(os.path.join(ART, "ground_objects.json")))
    out = {"tuft": [], "stone": []}
    for r in rects:
        kind = "tuft" if r["k"] == "tuft" else ("stone" if r["k"] == "stone" else None)
        if kind is None:
            continue
        t = atlas.crop((r["x"], r["y"], r["x"] + r["w"], r["y"] + r["h"]))
        out[kind].append(t.resize((t.width * S, t.height * S), Image.NEAREST))
    return out


def build(lip, density, seed=SEED):
    """Return (PIL picture, edge row per picture column as a list)."""
    img = np.array(Image.open(STRAIGHT).convert("RGBA"))
    H, W = img.shape[:2]
    assert (img[:IMG_TOP, :, 3] == 0).all() and (img[IMG_TOP, :, 3] == 255).all()
    rng = np.random.default_rng(seed)
    na = W // S
    prof = periodic_noise(na, rng, [(5, 1.0), (9, 0.8), (17, 0.6), (31, 0.5), (67, 0.35)])
    d = np.round(MIN_D + prof * (MAX_D - MIN_D) + rng.integers(-1, 2, na) * 0.6)
    d = d.clip(MIN_D, MAX_D).astype(int)
    edge = IMG_TOP + d * S                       # first opaque row per art column

    out = img.copy()
    mult = LIPS[lip]
    for c in range(na):
        x0, x1 = c * S, c * S + S
        e = edge[c]
        out[IMG_TOP:e, x0:x1, 3] = 0             # cut the dirt away above the edge
        # steep sides: rows next to a neighbouring column that starts lower are outline too
        side_end = max(edge[(c - 1) % na], edge[(c + 1) % na])
        for k, m in enumerate(mult):             # rows from the top of the column
            r0, r1 = e + k * S, e + (k + 1) * S
            out[r0:r1, x0:x1, :3] = (out[r0:r1, x0:x1, :3] * m).astype(np.uint8)
        if side_end > e + S:
            r0, r1 = e + S * 1, min(side_end, e + S * 6)
            if r1 > r0:
                out[r0:r1, x0:x1, :3] = np.minimum(
                    out[r0:r1, x0:x1, :3],
                    (img[r0:r1, x0:x1, :3] * mult[0]).astype(np.uint8))

    # tufts and stones standing on the edge
    sprites = load_sprites()
    (lo, hi), p_stone = DENSITY[density]
    pic = Image.fromarray(out)
    c = int(rng.integers(0, 20))
    n_t = n_s = 0
    while c < na - 12:
        stone = rng.random() < p_stone
        pool = sprites["stone" if stone else "tuft"]
        t = pool[int(rng.integers(0, len(pool)))]
        if rng.random() < 0.5:
            t = t.transpose(Image.FLIP_LEFT_RIGHT)
        tw = t.width // S
        cc = min(c, na - tw)
        lowest = int(edge[cc:cc + tw].max())
        base = lowest + (S * 3 if stone else S)   # stones half sunk, tufts rooted in the dirt
        if stone:
            base = min(base, int(edge[cc:cc + tw].min()) + t.height - S)
            base = max(base, lowest + S)
        pic.alpha_composite(t, (cc * S, base - t.height))
        n_s += stone
        n_t += not stone
        c += tw + int(rng.integers(lo, hi))
    top = [int(edge[x // S]) for x in range(W)]
    print("lip", lip, "density", density, "| edge depth art px mean %.1f" % d.mean(),
          "| tufts", n_t, "stones", n_s)
    return pic, top


def composite(pic, x0=0, w=1280, y0=240, h=200):
    """The picture over the real forest layer (same placement as main.gd BG_LAYERS)."""
    sky = Image.open(SKY).convert("RGBA")
    canvas = Image.new("RGBA", (w, 1000), (0, 0, 0, 255))
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    layer.paste(sky.crop((x0, 0, x0 + w, sky.height)), (0, -606))
    canvas = Image.alpha_composite(canvas, layer)
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    layer.paste(pic.crop((x0, 0, x0 + w, pic.height)), (0, 0))
    canvas = Image.alpha_composite(canvas, layer)
    return canvas.crop((0, y0, w, y0 + h)).convert("RGB")


def sheet(panels, path):
    w, h = panels[0][1].size
    im = Image.new("RGB", (w, (h + 4) * len(panels)), (255, 0, 255))
    d = ImageDraw.Draw(im)
    for i, (label, p) in enumerate(panels):
        im.paste(p, (0, i * (h + 4)))
        d.rectangle((0, i * (h + 4), 150, i * (h + 4) + 14), fill=(0, 0, 0))
        d.text((3, i * (h + 4) + 2), label, fill=(255, 255, 255))
    im.save(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lip", type=int, default=2, choices=[1, 2, 3])
    ap.add_argument("--density", default="mid", choices=list(DENSITY))
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--preview", action="store_true")
    a = ap.parse_args()
    if not os.path.exists(STRAIGHT):
        os.makedirs(os.path.dirname(STRAIGHT), exist_ok=True)
        shutil.copyfile(GROUND, STRAIGHT)
    if a.preview:
        os.makedirs(OUTDIR, exist_ok=True)
        names = {1: "1 slabsie (terajsie)", 2: "2 silnejsie", 3: "3 najsilnejsie"}
        sheet([(names[l], composite(build(l, "mid")[0])) for l in (1, 2, 3)],
              os.path.join(OUTDIR, "t12_stmavenie.png"))
        sheet([(d + " prvkov", composite(build(2, d)[0])) for d in ("few", "mid", "many")],
              os.path.join(OUTDIR, "t12_mnozstvo.png"))
    if a.apply:
        pic, top = build(a.lip, a.density)
        pic.save(GROUND, optimize=True)
        json.dump(top, open(TOPJSON, "w"))
        print("applied: top curve rows", min(top), "..", max(top))


if __name__ == "__main__":
    main()
