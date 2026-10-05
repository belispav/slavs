"""
Slavs - simulate "calm ground + scattered objects" from art we ALREADY have, no
PixelLab generation. Cuts stones and grass tufts out of the PixelLab ground tile
(ref/preview/ground_pro_512.png), paints the holes over, smooths the rest into a
calm base, then scatters the cut-outs sparsely on top and draws the scene.

    python tools/calm_ground_mock.py
Writes ref/preview/calm_*.png
"""
import numpy as np, cv2
from PIL import Image
from scipy import ndimage as ndi

rng = np.random.default_rng(7)
CONTRAST = 0.4
ART = "slavs/art/"
tile = np.asarray(Image.open("ref/preview/ground_pro_512.png").convert("RGB")).astype(np.int32)
R, G, B = tile[..., 0], tile[..., 1], tile[..., 2]
L = 0.299 * R + 0.587 * G + 0.114 * B

# ---- 1. find objects ------------------------------------------------------
stone = ((R - B) < 22) & (L > 62)
tuft = (G >= R - 6) & ((G - B) > 30) & (L > 62)
obj = stone | tuft
obj = ndi.binary_opening(obj, iterations=0) | obj
obj = ndi.binary_dilation(obj, iterations=1)
lab, n = ndi.label(obj)
sizes = ndi.sum(obj, lab, range(1, n + 1))
keep = np.zeros_like(obj)
sprites = []
for i, sz in enumerate(sizes, 1):
    if sz < 10 or sz > 1500:
        continue
    m = lab == i
    ys, xs = np.where(m)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    if y1 - y0 > 60 or x1 - x0 > 70:
        continue
    keep |= m
    rgba = np.zeros((y1 - y0, x1 - x0, 4), np.uint8)
    rgba[..., :3] = tile[y0:y1, x0:x1]
    rgba[..., 3] = np.where(m[y0:y1, x0:x1], 255, 0)
    kind = "tuft" if tuft[m].mean() > 0.35 else "stone"
    sprites.append((kind, rgba))
print("cut", len(sprites), "objects:", sum(k == "stone" for k, _ in sprites), "stones,",
      sum(k == "tuft" for k, _ in sprites), "tufts")

# ---- 2. calm base: paint holes, smooth, few colours (periodic via 3x3 tiling) --
big = np.tile(tile.astype(np.uint8), (3, 3, 1))
mask_big = np.tile(keep.astype(np.uint8) * 255, (3, 3))
paint = cv2.inpaint(big, mask_big, 4, cv2.INPAINT_TELEA)
smooth = cv2.medianBlur(paint, 7)
smooth = cv2.medianBlur(smooth, 7)
q = Image.fromarray(smooth).quantize(colors=14, method=Image.Quantize.MEDIANCUT,
                                      dither=Image.Dither.NONE).convert("RGB")
base = np.asarray(q)[512:1024, 512:1024].astype(np.float32)
# pull the tones together: the blotches are what made it read as camouflage
mean = np.median(base.reshape(-1, 3), axis=0)
base = mean + CONTRAST * (base - mean)
base = np.asarray(Image.fromarray(np.clip(base, 0, 255).astype(np.uint8)).quantize(
    colors=9, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB"))
Image.fromarray(base).save("ref/preview/calm_base_tile.png")


# ---- 3. scene -------------------------------------------------------------
env = Image.open(ART + "env_09.png").convert("RGBA")
sky = Image.open(ART + "env_07_sky.png").convert("RGBA")
W, H = env.size
alpha = np.asarray(env)[..., 3]
top_row = alpha.argmax(axis=0)


def tile2x(img, size):
    t2 = np.repeat(np.repeat(img, 2, axis=0), 2, axis=1)
    reps = (size[1] // t2.shape[0] + 1, size[0] // t2.shape[1] + 1, 1)
    return np.tile(t2, reps)[:size[1], :size[0]]


def ground_with(base_rgb, density):
    g = tile2x(base_rgb, (W, H)).copy() if base_rgb is not None else np.asarray(env)[..., :3].copy()
    out = Image.fromarray(g).convert("RGBA")
    if density > 0:
        for kind, spr in sprites:
            pass
        n_obj = int(density * W * H / (512 * 512 * 4) * len(sprites))
        layer = Image.new("RGBA", (W, H))
        for _ in range(n_obj):
            kind, spr = sprites[rng.integers(len(sprites))]
            im = Image.fromarray(spr).resize((spr.shape[1] * 2, spr.shape[0] * 2), Image.NEAREST)
            x = int(rng.integers(0, W - im.width)); y = int(rng.integers(300, H - im.height))
            layer.alpha_composite(im, (x, y))
        out.alpha_composite(layer)
    # alpha of env_09 (ground edge) + keep env_08's rim pixels along the top edge
    arr = np.asarray(out).copy()
    arr[..., 3] = alpha
    rows = np.arange(H)[:, None]
    rim = (rows < top_row[None, :] + 36) & (alpha > 0)
    arr[rim] = np.asarray(env)[rim]
    return Image.fromarray(arr, "RGBA")


def scene(ground, x0=800, y0=100):
    c = Image.new("RGBA", (1280, 720), (0, 0, 0, 255))
    for y in (265, -606):
        t = sky.crop((x0, 0, x0 + 1280, sky.height)); off = y - y0
        if 0 <= off < 720: c.alpha_composite(t, (0, off))
        elif off < 0 and off + t.height > 0: c.alpha_composite(t.crop((0, -off, 1280, t.height)), (0, 0))
    c.alpha_composite(ground.crop((x0, y0, x0 + 1280, y0 + 720)), (0, 0))
    def put(path, fr, cx, fy, s=2):
        im = Image.open(ART + path).convert("RGBA"); im = im.resize((im.width * s, im.height * s), Image.NEAREST)
        c.alpha_composite(im, (cx - im.width // 2, fy - fr * s))
    put("hero_pl_axe_idle/idle_0000.png", 79, 330, 480)
    put("rusher_pl_idle/idle_0000.png", 88, 880, 600)
    put("barrel_pl/barrel_0000.png", 40, 620, 430)
    return c.convert("RGB")


panels = [scene(ground_with(None, 0)), scene(ground_with(base, 0)), scene(ground_with(base, 0.3))]
for i, p in enumerate(panels):
    p.save("ref/preview/calm_%d.png" % i)
sheet = Image.new("RGB", (1280, 720 * 3))
for i, p in enumerate(panels):
    sheet.paste(p, (0, 720 * i))
sheet.save("ref/preview/calm_compare.png")
