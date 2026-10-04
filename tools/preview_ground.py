"""
Slavs - compare the current ground (env_08) with a new tileable ground texture,
drawn the way the game draws the scene (sky layers, ground, hero + rusher at 2x),
and measure it. No generation happens here.

    python tools/preview_ground.py ref/preview/ground_pro_512.png

Writes ref/preview/ground_compare.png (left = current, right = new, new tile
repeated vertically too), ground_compare_rim.png (same, but the original
env_08 rim is kept around the edge of the new ground) and ground_new_full.png
(whole screen, new ground only). Prints the three numbers from
DIZAJN_pozadie_a_rozlisenie.md section 6.
"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ART = "slavs/art/"
OUT = "ref/preview/"
SCALE = 2            # new texture is shown at an integer 2x, NEAREST
VIEW_W = 1280        # one phone screen
Y0, Y1 = 100, 1420   # env_08 rows shown
WALK_TOP, WALK_BOTTOM = 406, 1287
RIM = 36             # px of original env_08 kept at the edge in the "rim" variant


def luma(a):
    return 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]


def tiled_x(img, width):
    out = Image.new("RGBA", (width, img.height))
    for x in range(0, width, img.width):
        out.paste(img, (x, 0))
    return out


def sky(width):
    s = Image.open(ART + "env_07_sky.png").convert("RGBA")
    canvas = Image.new("RGBA", (width, Y1 - Y0), (0, 0, 0, 255))
    for y in (265, -606.5):                      # lower layer first, upper in front
        t = tiled_x(s, width)
        canvas.alpha_composite(t, (0, int(round(y)) - Y0)) if int(round(y)) - Y0 >= 0 else \
            canvas.alpha_composite(t.crop((0, Y0 - int(round(y)), width, t.height)), (0, 0))
    return canvas


def new_ground(tile, size):
    t = tile.resize((tile.width * SCALE, tile.height * SCALE), Image.NEAREST)
    out = Image.new("RGBA", size)
    for y in range(0, size[1], t.height):
        for x in range(0, size[0], t.width):
            out.paste(t, (x, y))
    return out


def stand(canvas, path, cx, feet_row, feet_y):
    im = Image.open(path).convert("RGBA")
    im = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
    canvas.alpha_composite(im, (cx - im.width // 2, feet_y - feet_row * 2))
    return im


def main():
    tile = Image.open(sys.argv[1]).convert("RGBA")
    env = Image.open(ART + "env_08.png").convert("RGBA")
    a = np.asarray(env)[..., 3]
    rows = np.where(a.max(axis=1) > 0)[0]
    top = rows.min()
    gen = new_ground(tile, env.size)
    # tile starts at the top of the alpha so the first tile is whole
    shifted = Image.new("RGBA", env.size)
    shifted.paste(gen.crop((0, 0, env.width, env.height - top)), (0, top))
    mask = env.split()[3]

    new_a = Image.composite(shifted, Image.new("RGBA", env.size), mask)
    eroded = mask.filter(ImageFilter.MinFilter(2 * RIM + 1))
    rim = new_a.copy()
    inner = Image.composite(shifted, Image.new("RGBA", env.size), eroded)
    rim = env.copy()
    rim.alpha_composite(inner)

    def scene(ground_cur, ground_new, split):
        c = sky(VIEW_W)
        gc = ground_cur.crop((0, Y0, VIEW_W, Y1))
        gn = ground_new.crop((0, Y0, VIEW_W, Y1))
        if split:
            tmp = gc.copy()
            tmp.paste(gn.crop((VIEW_W // 2, 0, VIEW_W, gn.height)), (VIEW_W // 2, 0))
            c.alpha_composite(tmp)
        else:
            c.alpha_composite(gn)
        d = ImageDraw.Draw(c)
        if split:
            d.line([(VIEW_W // 2, 0), (VIEW_W // 2, c.height)], fill=(255, 0, 255, 255), width=2)
        for cx_h, cx_r in ((300, 520), (900, 1120)) if split else ((420, 780),):
            stand(c, ART + "hero_pl_axe_idle/idle_0000.png", cx_h, 79, 800 - Y0)
            stand(c, ART + "rusher_pl_idle/idle_0000.png", cx_r, 88, 930 - Y0)
        return c

    scene(env, new_a, True).convert("RGB").save(OUT + "ground_compare.png")
    scene(env, rim, True).convert("RGB").save(OUT + "ground_compare_rim.png")
    scene(env, new_a, False).convert("RGB").save(OUT + "ground_new_full.png")

    # ---- measurements -----------------------------------------------------
    hero = np.asarray(Image.open(ART + "hero_pl_axe_idle/idle_0000.png").convert("RGBA")).astype(float)
    rush = np.asarray(Image.open(ART + "rusher_pl_idle/idle_0000.png").convert("RGBA")).astype(float)
    hl = luma(hero)[hero[..., 3] > 0].mean()
    rl = luma(rush)[rush[..., 3] > 0].mean()
    band = slice(WALK_TOP, WALK_BOTTOM + 1)
    for name, img in (("env_08 (dnes)", env), ("nova zem", new_a)):
        px = np.asarray(img).astype(float)
        m = px[band, :, 3] > 0
        bl = luma(px[band, :, :3])[m].mean()
        print("%-14s jas pasu %.1f (>=80: %s) | hrdina %.1f rozdiel %.1f (>=35: %s) | bezec %.1f rozdiel %.1f"
              % (name, bl, "ano" if bl >= 80 else "NIE", hl, bl - hl, "ano" if bl - hl >= 35 else "NIE",
                 rl, bl - rl))

    t = np.asarray(tile.convert("RGB")).astype(float)
    for name, arr, axis in (("512 tile, lavy/pravy", t, 1), ("512 tile, horny/dolny", t, 0)):
        first, last = (arr[:, 0], arr[:, -1]) if axis == 1 else (arr[0], arr[-1])
        seam = np.abs(first - last).mean()
        noise = np.abs(np.diff(arr, axis=axis)).mean()
        print("spoj %-22s %.1f proti sumu susedov %.1f = %.2fx" % (name, seam, noise, seam / noise))
    e = np.asarray(env.convert("RGB")).astype(float)[WALK_TOP:WALK_BOTTOM]
    seam = np.abs(e[:, 0] - e[:, -1]).mean(); noise = np.abs(np.diff(e, axis=1)).mean()
    print("spoj env_08 lavy/pravy: %.1f proti %.1f = %.2fx" % (seam, noise, seam / noise))
    # hidden repeat inside the tile: left half vs right half
    h = t.shape[1] // 2
    print("lavá vs pravá polovica dlazdice: stredna absolutna odchylka %.1f (0 = presne kopia)"
          % np.abs(t[:, :h] - t[:, h:]).mean())


if __name__ == "__main__":
    main()
