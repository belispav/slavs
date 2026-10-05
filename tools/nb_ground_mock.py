"""
Slavs - put the two Nano Banana ground tiles (ref/preview/nb_ground_*.jpg) into
the real scene at the real pixel size, and try "calm base + a few objects".

The tiles have 5 px blocks, so they are first sampled down to their art-pixel grid
(this also removes the JPEG noise), made seamless with a minimum-error cut and then
shown at 2 world units per art pixel, the same as every character in the game.

    python tools/nb_ground_mock.py
"""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage as ndi
sys.path.insert(0, "tools")
from bake_ground import min_cut

ART = "slavs/art/"
BLOCK = 5
rng = np.random.default_rng(11)


def to_art_grid(path, BLOCK=BLOCK):
    a = np.asarray(Image.open(path).convert("RGB")).astype(np.int32)
    best = None
    for off in range(BLOCK):
        d = np.abs(np.diff(a.sum(axis=2), axis=1))[:, off::BLOCK].mean() \
            + np.abs(np.diff(a.sum(axis=2), axis=0))[off::BLOCK].mean()
        if best is None or d > best[0]:
            best = (d, off)          # block EDGES sit between off-1 and off
    off = best[1]
    c = (off + BLOCK // 2) % BLOCK
    n = (a.shape[0] - c) // BLOCK
    return a[c::BLOCK, c::BLOCK][:n, :n].astype(np.uint8)


def seamless(t, ov=14):
    """Make a tile periodic in x and y with minimum-error cuts."""
    t = t.astype(np.int32)
    h, w, _ = t.shape
    # x: blend the right end into the left start
    head = t[:, :ov]; tail = np.concatenate([t[:, w - ov:]], axis=1)
    err = ((tail - head) ** 2).sum(axis=2).astype(float)
    cut = min_cut(err[:, 2:ov - 2]) + 2
    u = t[:, :w - ov].copy()
    for y in range(h):
        u[y, :cut[y]] = tail[y, :cut[y]]
    # y: same on rows
    h2 = u.shape[0]
    head = u[:ov]; tail = u[h2 - ov:]
    err = ((tail - head) ** 2).sum(axis=2).astype(float).T
    cut = min_cut(err[:, 2:ov - 2]) + 2
    v = u[:h2 - ov].copy()
    for x in range(v.shape[1]):
        v[:cut[x], x] = tail[:cut[x], x]
    return v.astype(np.uint8)


def objects(a):
    r, g, b = a[..., 0].astype(int), a[..., 1].astype(int), a[..., 2].astype(int)
    L = 0.299 * r + 0.587 * g + 0.114 * b
    stone = (b >= r - 6) & (L > 75)
    tuft = (g > r + 2) & (g > b + 25) & (L > 70)
    m = ndi.binary_dilation(stone | tuft, iterations=1)
    lab, n = ndi.label(m)
    out = []
    for i in range(1, n + 1):
        mm = lab == i
        ys, xs = np.where(mm)
        if mm.sum() < 22 or mm.sum() > 500 or np.ptp(ys) > 30 or np.ptp(xs) > 34:
            continue
        y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
        rgba = np.zeros((y1 - y0, x1 - x0, 4), np.uint8)
        rgba[..., :3] = a[y0:y1, x0:x1]
        rgba[..., 3] = np.where(mm[y0:y1, x0:x1], 255, 0)
        out.append(rgba)
    return out


def remove_objects(t):
    """Paint the stones and tufts out of a calm tile, so nothing repeats every tile (periodic via 3x3)."""
    import cv2
    r, g, b = t[..., 0].astype(int), t[..., 1].astype(int), t[..., 2].astype(int)
    L = 0.299 * r + 0.587 * g + 0.114 * b
    m = ((b >= r - 6) & (L > 75)) | ((g > r + 2) & (g > b + 25))
    m = ndi.binary_dilation(m, iterations=2)
    big = np.tile(t, (3, 3, 1)); bm = np.tile(m.astype(np.uint8) * 255, (3, 3))
    out = cv2.inpaint(big, bm, 3, cv2.INPAINT_TELEA)
    h = t.shape[0]
    return out[h:2 * h, h:2 * h]


def tint(a, target):
    mean = a.reshape(-1, 3).astype(float).mean(axis=0)
    return np.clip(a.astype(float) * (np.array(target) / mean), 0, 255).astype(np.uint8)


env = Image.open(ART + "env_09.png").convert("RGBA")
sky = Image.open(ART + "env_07_sky.png").convert("RGBA")
W, H = env.size
alpha = np.asarray(env)[..., 3]
top_row = alpha.argmax(axis=0)


def tile_world(art_tile):
    t2 = np.repeat(np.repeat(art_tile, 2, axis=0), 2, axis=1)
    reps = (H // t2.shape[0] + 1, W // t2.shape[1] + 1, 1)
    return np.tile(t2, reps)[:H, :W]


def ground(art_tile, sprites=None, n_obj=0):
    g = Image.fromarray(tile_world(art_tile)).convert("RGBA")
    if n_obj:
        layer = Image.new("RGBA", (W, H))
        for _ in range(n_obj):
            s = sprites[rng.integers(len(sprites))]
            im = Image.fromarray(s).resize((s.shape[1] * 2, s.shape[0] * 2), Image.NEAREST)
            layer.alpha_composite(im, (int(rng.integers(0, W - im.width)), int(rng.integers(300, H - im.height))))
        g.alpha_composite(layer)
    arr = np.asarray(g).copy()
    arr[..., 3] = alpha
    rows = np.arange(H)[:, None]
    rim = (rows < top_row[None, :] + 36) & (alpha > 0)
    arr[rim] = np.asarray(env)[rim]
    return Image.fromarray(arr, "RGBA")


def scene(gr, x0=800, y0=160):
    """The fixed one-screen view of the game's SCENA BEZ SCROLLU mode: picture rows 160..880."""
    c = Image.new("RGBA", (1280, 720), (0, 0, 0, 255))
    for y in (265, -606):
        t = sky.crop((x0, 0, x0 + 1280, sky.height)); off = y - y0
        if 0 <= off < 720: c.alpha_composite(t, (0, off))
        elif off < 0 and off + t.height > 0: c.alpha_composite(t.crop((0, -off, 1280, t.height)), (0, 0))
    c.alpha_composite(gr.crop((x0, y0, x0 + 1280, y0 + 720)), (0, 0))
    def put(path, fr, cx, fy, s=2):
        im = Image.open(ART + path).convert("RGBA"); im = im.resize((im.width * s, im.height * s), Image.NEAREST)
        c.alpha_composite(im, (cx - im.width // 2, fy - fr * s))
    put("hero_pl_axe_idle/idle_0000.png", 79, 330, 560)
    put("rusher_pl_idle/idle_0000.png", 88, 900, 650)
    put("barrel_pl/barrel_0000.png", 40, 620, 600)
    return c.convert("RGB")


def main():
    a8 = to_art_grid("ref/preview/nb_ground_current_prompt.jpg")
    a9 = to_art_grid("ref/preview/nb_ground_calm_prompt.jpg")
    print("art tiles", a8.shape, a9.shape)
    s8, s9 = seamless(a8), seamless(a9)
    brown = tint(s9, (112, 88, 64))
    sprites = objects(a8)
    print("objects cut from the busy tile:", len(sprites))
    print("after size filter:", len(sprites))

    bare = tint(remove_objects(s9), (112, 88, 64))
    panels = [
        scene(ground(s9)),
        scene(ground(bare)),
        scene(ground(bare, sprites, 70)),
    ]
    for i, p in enumerate(panels):
        p.save("ref/preview/nbg_%d.png" % i)
    sheet = Image.new("RGB", (1280, 720 * 3))
    for i, p in enumerate(panels):
        sheet.paste(p, (0, 720 * i))
    sheet.save("ref/preview/nbg_compare.png")


if __name__ == "__main__":
    main()
