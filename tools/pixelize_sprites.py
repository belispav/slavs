"""
VOLYA - turn a rendered PNG sequence into pixel-art sprites.

This is the second half of the graphics pipeline. Blender produces flat,
cel-banded frames; this script does the final pixel-art pass:

  1. hard alpha       - a pixel is either fully there or not there at all,
                        because pixel art has no soft anti-aliased edges
  2. shared palette   - ONE palette for the whole animation, so colours do not
                        flicker between frames
  3. despeckle        - remove lone pixels that differ from all four neighbours,
                        the single biggest "this was rendered, not drawn" tell
  4. outline          - 1 px dark border around the silhouette

It also measures pixel crawl (how much of the sprite changes colour between
consecutive frames) so the shimmer problem can be judged from a number instead
of a feeling.

Runs on plain Python - no Blender needed.

    python tools/pixelize_sprites.py --in volya/art/hero_run --out volya/art/hero_run_px

Requires Pillow and numpy:

    pip install pillow numpy
"""

import argparse
import glob
import os
import sys

try:
    import numpy as np
    from PIL import Image, ImageFilter
except ImportError:
    sys.exit("VOLYA: chyba kniznica. Spusti:  pip install pillow numpy")


OUTLINE_COLOUR = (26, 20, 18, 255)


# ------------------------------------------------------------------- stages --

def hard_alpha(im, threshold=128):
    """Kill semi-transparent anti-aliased edges. Pixel art has none."""
    alpha = im.split()[3].point(lambda v: 255 if v >= threshold else 0)
    out = im.copy()
    out.putalpha(alpha)
    return out


def pad(im, px=1):
    """Grow the canvas so the outline has somewhere to live."""
    if px <= 0:
        return im
    out = Image.new("RGBA", (im.width + 2 * px, im.height + 2 * px), (0, 0, 0, 0))
    out.paste(im, (px, px))
    return out


def denoise(im, amount):
    """Safety net for renders that still carry texture noise.

    With a proper toon render this should be 0. Values above 0 trade detail for
    flatness; 1.0 is already quite soft.
    """
    if amount <= 0:
        return im
    alpha = im.split()[3]
    rgb = im.convert("RGB").filter(ImageFilter.MedianFilter(3))
    if amount > 0.4:
        rgb = rgb.filter(ImageFilter.GaussianBlur(amount))
    out = rgb.convert("RGBA")
    out.putalpha(alpha)
    return out


def band_luminance(im, bands, lift, gain):
    """Cel shading as a safety net: hard steps in brightness, hue preserved.

    Hue is preserved on purpose. Posterising each RGB channel separately is the
    obvious approach and it is wrong - it shifts hues and sprays the sprite with
    yellow and blue speckles.

    With a proper toon render from Blender the bands are already there, so
    bands=0 disables this stage entirely.
    """
    if bands < 2:
        return im
    alpha = im.split()[3]
    base = np.asarray(im.convert("RGB")).astype(np.float32) / 255.0
    lum = base @ np.array([0.299, 0.587, 0.114], np.float32)
    lum = np.clip(lum * gain + lift, 0.0, 1.0)
    stepped = np.round(lum * (bands - 1)) / (bands - 1)
    stepped = lift + stepped * (1.0 - lift)
    # normalise each pixel to its own brightest channel, then re-apply the
    # stepped brightness - this keeps the hue and only quantises the value
    hue = base / np.maximum(base.max(axis=2, keepdims=True), 1e-3)
    out = np.clip(hue * stepped[..., None], 0.0, 1.0)
    result = Image.fromarray((out * 255).astype(np.uint8), "RGB").convert("RGBA")
    result.putalpha(alpha)
    return result


def build_shared_palette(frames, colours):
    """One palette for the whole animation.

    Quantising each frame on its own gives every frame slightly different
    colours, which reads as flicker even when nothing moves.
    """
    width = max(f.width for f in frames)
    strip = Image.new("RGB", (width * len(frames), frames[0].height), (0, 0, 0))
    for i, f in enumerate(frames):
        strip.paste(f.convert("RGB"), (i * width, 0), f)
    return strip.quantize(colors=colours, method=Image.MEDIANCUT,
                          dither=Image.Dither.NONE)


def apply_palette(im, palette_image):
    alpha = im.split()[3]
    out = im.convert("RGB").quantize(palette=palette_image,
                                     dither=Image.Dither.NONE).convert("RGBA")
    out.putalpha(alpha)
    return out


def despeckle(im, tolerance=40):
    """Replace pixels that differ from all four neighbours with a neighbour.

    Hand-drawn pixel art has almost no lone pixels; renders are full of them.
    """
    arr = np.asarray(im).copy()
    solid = arr[..., 3] > 0
    rgb = arr[..., :3].astype(np.int16)
    padded = np.pad(rgb, ((1, 1), (1, 1), (0, 0)), mode="edge")
    neighbours = [padded[:-2, 1:-1], padded[2:, 1:-1],
                  padded[1:-1, :-2], padded[1:-1, 2:]]
    differing = sum((np.abs(rgb - n).sum(axis=2) > tolerance).astype(np.int8)
                    for n in neighbours)
    lone = (differing == 4) & solid
    arr[..., :3][lone] = neighbours[0][lone]
    return Image.fromarray(arr, "RGBA"), int(lone.sum())


def outline(im, colour=OUTLINE_COLOUR):
    solid = np.asarray(im.split()[3]) > 0
    padded = np.pad(solid, 1)
    ring = (padded[:-2, 1:-1] | padded[2:, 1:-1] |
            padded[1:-1, :-2] | padded[1:-1, 2:]) & ~solid
    arr = np.asarray(im).copy()
    arr[ring] = colour
    return Image.fromarray(arr, "RGBA")


# ------------------------------------------------------------------ measure --

def measure_crawl(frames):
    """How much of the sprite changes colour between consecutive frames.

    Only pixels solid in BOTH frames are counted, so this measures shimmer
    rather than movement of the silhouette. Interpretation:
        under 15 %  - calm, looks drawn
        15 to 30 %  - visible shimmer on fast animations, usually acceptable
        over 30 %   - the sprite boils; needs fewer colours or a lower
                      render resolution
    Note this number is only meaningful on frames rendered close together
    (--step 1). On a 10 fps run cycle the pose changes so much between frames
    that the figure says nothing about crawl.
    """
    rates = []
    for a_img, b_img in zip(frames, frames[1:]):
        a = np.asarray(a_img)
        b = np.asarray(b_img)
        both = (a[..., 3] > 0) & (b[..., 3] > 0)
        if both.sum() == 0:
            continue
        changed = (np.abs(a[..., :3].astype(int) -
                          b[..., :3].astype(int)).sum(axis=2) > 30) & both
        rates.append(100.0 * changed.sum() / both.sum())
    return rates


def write_gif(frames, path, fps=30, scale=6, background=(38, 40, 42)):
    """Animated preview.

    A still sheet cannot show shimmer, and shimmer is the thing most likely to
    sink this whole approach. The GIF is put on a solid background rather than
    left transparent, because a 1 px dark outline is invisible against the
    checkerboard most image viewers draw behind transparency.
    """
    w, h = frames[0].size
    out = []
    for f in frames:
        big = f.resize((w * scale, h * scale), Image.NEAREST)
        canvas = Image.new("RGB", (w * scale, h * scale), background)
        canvas.paste(big, (0, 0), big)
        out.append(canvas.convert("P", palette=Image.ADAPTIVE, colors=64))
    out[0].save(path, save_all=True, append_images=out[1:],
                duration=max(10, int(1000 / max(fps, 1))), loop=0, disposal=2)


def contact_sheet(frames, path, scale=6, per_row=8, background=(38, 40, 42)):
    """Magnified grid of every frame, plus one row at true game size.

    The magnified grid is for judging the pixels. The true-size row is the one
    that actually decides anything - on a phone the character is about a
    centimetre tall, and detail that only survives at 6x does not exist.
    """
    w, h = frames[0].size
    gap = 12
    rows = (len(frames) + per_row - 1) // per_row
    cell_w, cell_h = w * scale + gap, h * scale + gap

    strip_h = h + gap * 2
    sheet = Image.new("RGB", (max(cell_w * per_row + gap,
                                  (w + 6) * len(frames) + gap),
                              rows * cell_h + gap + strip_h), background)

    for i, f in enumerate(frames):
        big = f.resize((w * scale, h * scale), Image.NEAREST)
        x = gap + (i % per_row) * cell_w
        y = gap + (i // per_row) * cell_h
        sheet.paste(big, (x, y), big)

    # true size, no magnification - this is what the phone shows
    base_y = rows * cell_h + gap * 2
    for i, f in enumerate(frames):
        sheet.paste(f, (gap + i * (w + 6), base_y), f)

    sheet.save(path)


# --------------------------------------------------------------------- main --

def main():
    ap = argparse.ArgumentParser(description="VOLYA pixel-art pass")
    ap.add_argument("--in", dest="src", required=True,
                    help="folder with the rendered PNG sequence")
    ap.add_argument("--out", dest="dst", default=None,
                    help="output folder (default: <in>_px)")
    ap.add_argument("--colours", type=int, default=16,
                    help="palette size for the whole animation (default 16)")
    ap.add_argument("--bands", type=int, default=0,
                    help="cel bands applied here; 0 = trust the toon render")
    ap.add_argument("--denoise", type=float, default=0.0,
                    help="0 = off. Raise only if the render is still noisy")
    ap.add_argument("--lift", type=float, default=0.18,
                    help="how far shadows are kept off pure black")
    ap.add_argument("--gain", type=float, default=1.35, help="contrast before banding")
    ap.add_argument("--no-outline", action="store_true")
    ap.add_argument("--no-despeckle", action="store_true")
    ap.add_argument("--sheet", default=None,
                    help="also write a magnified contact sheet here")
    ap.add_argument("--gif", default=None,
                    help="also write an animated preview here")
    ap.add_argument("--fps", type=int, default=30,
                    help="playback speed of the preview (default 30)")
    cfg = ap.parse_args()

    dst = cfg.dst or (cfg.src.rstrip("/\\") + "_px")
    files = sorted(glob.glob(os.path.join(cfg.src, "*.png")))
    if not files:
        sys.exit("VOLYA: v %s nie su ziadne PNG subory." % cfg.src)

    print("VOLYA: %d snimok z %s" % (len(files), cfg.src))

    prepared = []
    for path in files:
        im = Image.open(path).convert("RGBA")
        im = hard_alpha(im)
        im = pad(im, 0 if cfg.no_outline else 1)
        im = denoise(im, cfg.denoise)
        im = band_luminance(im, cfg.bands, cfg.lift, cfg.gain)
        prepared.append(im)

    palette = build_shared_palette(prepared, cfg.colours)

    os.makedirs(dst, exist_ok=True)
    finished = []
    speckles = 0
    for path, im in zip(files, prepared):
        im = apply_palette(im, palette)
        if not cfg.no_despeckle:
            im, removed = despeckle(im)
            speckles += removed
        if not cfg.no_outline:
            im = outline(im)
        im.save(os.path.join(dst, os.path.basename(path)))
        finished.append(im)

    used = len(finished[0].convert("RGB").getcolors(1 << 24))
    print("VOLYA: paleta %d farieb, osamelych pixelov odstranenych %d"
          % (used, speckles))

    rates = measure_crawl(finished)
    if rates:
        avg = sum(rates) / len(rates)
        verdict = ("pokojne" if avg < 15 else
                   "mierne chvenie" if avg < 30 else "sprajt vrie")
        print("VOLYA: pixel crawl priemer %.0f %% (%s)" % (avg, verdict))
        print("VOLYA: cislo plati len ak si renderoval s --step 1")

    if cfg.sheet:
        contact_sheet(finished, cfg.sheet)
        print("VOLYA: prehlad ulozeny do %s" % cfg.sheet)

    if cfg.gif:
        write_gif(finished, cfg.gif, fps=cfg.fps)
        # 10 fps is the sprite rate the game will actually run at; 30 fps here
        # is every rendered frame, which is only useful for spotting shimmer
        slow = os.path.splitext(cfg.gif)[0] + "_10fps.gif"
        write_gif(finished[::3], slow, fps=10)
        print("VOLYA: animacia %s (plynula) a %s (herna rychlost)"
              % (cfg.gif, slow))

    print("VOLYA: hotovo - %d sprajtov v %s" % (len(finished), dst))


if __name__ == "__main__":
    main()
