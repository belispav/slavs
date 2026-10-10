"""Preview of the enemy "dirt" variants (package 3). Mirrors the planned in-game algorithm:
dark spots (1-3 px clusters, mud brown at weight DARK) placed only on pixels that are opaque in the
kind's reference frame, same positions on every frame of a variant, applied only where the frame
is opaque. Usage: python tools/preview_dirt.py [--spots 14] [--dark 0.45] [--variants 5]"""
import argparse, os, random
import numpy as np
from PIL import Image

ART = os.path.join(os.path.dirname(__file__), "..", "slavs", "art")
MUD = (78, 58, 40)
KINDS = [("rusher", "rusher_pl_walk", "rusher_pl_idle"),
         ("gunman", "gunman_pl_walk", "gunman_pl_idle"),
         ("brute", "brute_pl_walk", "brute_pl_idle")]

def load(d, i):
    fs = sorted(f for f in os.listdir(os.path.join(ART, d)) if f.endswith(".png"))
    return Image.open(os.path.join(ART, d, fs[i])).convert("RGBA")

def dirt_layer(ref, seed, spots, dark):
    rng = random.Random(seed)
    a = np.array(ref)[:, :, 3] > 0
    ys, xs = np.nonzero(a)
    layer = np.zeros(a.shape, dtype=np.float32)
    for _ in range(spots):
        i = rng.randrange(len(xs)); x, y = xs[i], ys[i]
        layer[y, x] = dark * rng.uniform(0.8, 1.2)
        for _ in range(rng.choice([0, 0, 1, 2])):          # 1-3 px smudge
            dx, dy = rng.choice([(1, 0), (-1, 0), (0, 1), (0, -1)])
            if 0 <= y+dy < a.shape[0] and 0 <= x+dx < a.shape[1]:
                layer[y+dy, x+dx] = dark * rng.uniform(0.6, 1.0)
    return layer

def apply(frame, layer):
    arr = np.array(frame).astype(np.float32)
    opaque = arr[:, :, 3] > 0
    w = (layer * opaque)[:, :, None]                 # blend toward mud brown, not black:
    arr[:, :, :3] = arr[:, :, :3] * (1.0 - w) + np.array(MUD, np.float32) * w  # shows on dark cloth too
    return Image.fromarray(arr.clip(0, 255).astype(np.uint8))

def crop(img, box=None):
    return img.crop(box or img.getbbox())

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--spots", type=int, default=14)
    ap.add_argument("--dark", type=float, default=0.45)
    ap.add_argument("--variants", type=int, default=5)
    ap.add_argument("--out", default="ref/dirt_preview.png")
    a = ap.parse_args()
    scale, pad = 3, 8
    rows = []
    for name, walk, idle in KINDS:
        ref = load(idle, 0)
        frame = load(walk, 2)
        box = frame.getbbox()
        tiles = [crop(frame, box)]
        for v in range(a.variants):
            tiles.append(crop(apply(frame, dirt_layer(ref, 1000 + v, a.spots, a.dark)), box))
        rows.append(tiles)
    tw = max(t.width for r in rows for t in r) * scale + pad
    th = max(t.height for r in rows for t in r) * scale + pad
    sheet = Image.new("RGBA", (tw * (a.variants + 1) + pad, th * len(rows) + pad), (70, 60, 50, 255))
    for r, tiles in enumerate(rows):
        for c, t in enumerate(tiles):
            t = t.resize((t.width * scale, t.height * scale), Image.NEAREST)
            sheet.alpha_composite(t, (pad + c * tw, pad + r * th))
    sheet.save(a.out)
    print(a.out, sheet.size)
