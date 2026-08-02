"""
VOLYA - prepare a character sheet image for an image-to-3D tool.

Does three things, in this order:

  1. removes everything that is not the figure - generator watermarks, stray
     marks - by keeping only the largest connected blob
  2. crops to a square centred on the figure, with an equal margin all round
  3. resizes to a fixed size

Step 1 has to come first. A watermark in a corner counts as part of the subject
when the bounding box is measured, which drags the centre towards it and leaves
a wide empty band on the opposite side. That is not cosmetic: the reconstruction
gets less of the figure for the same number of pixels, and some tools try to
model the watermark.

    python tools/prepare_character_image.py ref/characters/02_main_front.png

Writes <name>_meshy.png next to the original.
"""

import argparse
import os
import sys

try:
    import numpy as np
    from PIL import Image
except ImportError:
    sys.exit("VOLYA: chyba kniznica. Spusti:  pip install pillow numpy")


FIGURE_THRESHOLD = 45


def background_colour(pixels):
    """Averaged from the four corners, so one dirty corner cannot skew it."""
    height, width = pixels.shape[:2]
    inset = max(2, min(width, height) // 100)
    corners = [pixels[inset, inset], pixels[inset, width - 1 - inset],
               pixels[height - 1 - inset, inset],
               pixels[height - 1 - inset, width - 1 - inset]]
    return np.mean(corners, axis=0)


def largest_blob(mask):
    """Mask of the biggest connected region.

    Written out by hand with an explicit stack rather than recursion, because
    a figure covering a million pixels would blow the recursion limit, and
    scipy is not a dependency worth adding for one label pass.
    """
    height, width = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    best_size = 0
    best_seed = None
    sizes = {}

    for start_y in range(height):
        row = mask[start_y]
        for start_x in np.where(row & ~seen[start_y])[0]:
            if seen[start_y, start_x]:
                continue
            stack = [(start_y, int(start_x))]
            seen[start_y, start_x] = True
            size = 0
            pixels = []
            while stack:
                y, x = stack.pop()
                size += 1
                pixels.append((y, x))
                for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                    if 0 <= ny < height and 0 <= nx < width \
                            and mask[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
            sizes[(start_y, int(start_x))] = (size, pixels)
            if size > best_size:
                best_size = size
                best_seed = (start_y, int(start_x))

    out = np.zeros_like(mask)
    if best_seed is not None:
        for y, x in sizes[best_seed][1]:
            out[y, x] = True
    removed = int(mask.sum() - out.sum())
    return out, removed


def prepare(path, out_path, size, margin_fraction):
    image = Image.open(path).convert("RGB")
    pixels = np.asarray(image).astype(int)
    background = background_colour(pixels)

    mask = np.abs(pixels - background).sum(axis=2) > FIGURE_THRESHOLD
    if not mask.any():
        sys.exit("VOLYA: nenasiel som postavu. Je pozadie jednofarebne?")

    figure, removed = largest_blob(mask)
    if removed > 0:
        print("VOLYA: odstranene mimo postavy: %d px (vodoznak alebo smeti)"
              % removed)

    # Paint over everything that is not the figure.
    cleaned = pixels.copy()
    cleaned[mask & ~figure] = background.astype(int)
    image = Image.fromarray(cleaned.astype(np.uint8), "RGB")

    ys, xs = np.where(figure)
    top, bottom, left, right = int(ys.min()), int(ys.max()), \
        int(xs.min()), int(xs.max())
    fig_w, fig_h = right - left + 1, bottom - top + 1
    print("VOLYA: postava %d x %d px v obrazku %d x %d"
          % (fig_w, fig_h, image.width, image.height))

    side = int(max(fig_w, fig_h) * (1.0 + 2.0 * margin_fraction))
    centre_x, centre_y = (left + right) // 2, (top + bottom) // 2

    # Build the square on a background-coloured canvas rather than cropping the
    # source directly: the square is usually larger than the source in at least
    # one axis, and cropping out of bounds fills with black.
    canvas = Image.new("RGB", (side, side),
                       tuple(int(v) for v in background))
    canvas.paste(image, (side // 2 - centre_x, side // 2 - centre_y))
    canvas = canvas.resize((size, size), Image.LANCZOS)
    canvas.save(out_path)

    check = np.asarray(canvas).astype(int)
    cmask = np.abs(check - background).sum(axis=2) > FIGURE_THRESHOLD
    cys, cxs = np.where(cmask)
    print("VOLYA: hotovo %s (%d x %d)" % (out_path, size, size))
    print("VOLYA: volne vlavo %d px, vpravo %d px, hore %d px, dole %d px"
          % (cxs.min(), size - cxs.max(), cys.min(), size - cys.max()))
    print("VOLYA: postava zabera %.0f %% vysky"
          % (100.0 * (cys.max() - cys.min()) / size))


def main():
    ap = argparse.ArgumentParser(description="VOLYA character image prep")
    ap.add_argument("image")
    ap.add_argument("--out", default=None)
    ap.add_argument("--size", type=int, default=1536)
    ap.add_argument("--margin", type=float, default=0.05,
                    help="free space each side, as a fraction of the figure")
    cfg = ap.parse_args()

    out = cfg.out
    if out is None:
        stem, ext = os.path.splitext(cfg.image)
        out = stem + "_meshy" + (ext if ext.lower() == ".png" else ".png")
    prepare(cfg.image, out, cfg.size, cfg.margin)


if __name__ == "__main__":
    main()
