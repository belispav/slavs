"""
Slavs - the pixen ground variants with the free stones and grass patches scattered on.

    python tools/pixen_objects_mock.py
Writes ref/preview/pixen2_bare.png and pixen2_objects.png (4 variants each, forest layout).
"""
import glob
import sys
import numpy as np
from PIL import Image
sys.path.insert(0, "tools")
import pixen_scene_mock as ps
import nb_scene_mock as s

P = "ref/preview/"
names = ["a_minimal", "d_smooth", "e_flat", "f_burned"]
rng = np.random.default_rng(5)


def load(kind):
    out = []
    for f in sorted(glob.glob(P + "ground_objects/%s_*.png" % kind)):
        im = Image.open(f).convert("RGBA")
        a = np.asarray(im)[..., 3] > 0
        out.append((int(a.sum()), a.mean(), im))
    return out


stones = [im for n, fill, im in load("stone") if 45 <= n <= 700 and fill > 0.5]
pebbles = [im for n, fill, im in load("stone") if 20 <= n < 45 and fill > 0.5]
tufts = [im for n, fill, im in load("tuft") if n >= 150]
print(len(stones), "stones,", len(pebbles), "pebbles,", len(tufts), "grass patches")


def with_objects(name, seed):
    r = np.random.default_rng(seed)
    base = ps.world(name).copy()
    W, H = base.size
    layer = Image.new("RGBA", (W, H))
    def drop(pool, n, y0=60):
        for _ in range(n):
            im = pool[r.integers(len(pool))]
            im = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
            layer.alpha_composite(im, (int(r.integers(0, W - im.width)), int(r.integers(y0, H - im.height))))
    drop(tufts, 6)
    drop(stones, 11)
    drop(pebbles, 14)
    base.alpha_composite(layer)
    return base


def forest_with(img):
    sky = ps.g.sky
    c = Image.new("RGBA", (1280, 720), (0, 0, 0, 255))
    for y in (265 - 160, -606 - 160):
        t = sky.crop((800, 0, 800 + 1280, sky.height))
        if 0 <= y < 720: c.alpha_composite(t, (0, y))
        elif y < 0 and y + t.height > 0: c.alpha_composite(t.crop((0, -y, 1280, t.height)), (0, 0))
    c.alpha_composite(img.crop((32, 0, 32 + 1280, 720 - 190)), (0, 190))
    s.characters(c)
    return c.convert("RGB")


def sheet(imgs, fname):
    sh = Image.new("RGB", (1280, 720 * len(imgs)))
    for i, im in enumerate(imgs):
        sh.paste(im, (0, 720 * i))
    sh.save(P + fname)


sheet([forest_with(ps.world(n)) for n in names], "pixen2_bare.png")
sheet([forest_with(with_objects(n, 20 + i)) for i, n in enumerate(names)], "pixen2_objects.png")
