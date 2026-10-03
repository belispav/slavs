"""
Slavs - check a character sheet before spending a 3D generation credit.

Image-to-3D tools cross-reference the views they are given. Where the views
disagree, the reconstruction is worst exactly there - so it is worth knowing
about a mismatch before paying for it, not after.

Checks the three things that cannot be judged by eye:

  1. is the figure the same height in every view
  2. is the background flat, or does it have a gradient the tool may read as
     part of the subject
  3. is there a cast shadow touching the figure

    python tools/check_character_sheet.py ref/characters/02_main

That looks for <prefix>_front, <prefix>_side and <prefix>_back with any common
image extension. A single folder or explicit file list also works:

    python tools/check_character_sheet.py ref/characters
    python tools/check_character_sheet.py a.png b.png c.png
"""

import glob
import os
import sys

try:
    import numpy as np
    from PIL import Image
except ImportError:
    sys.exit("Slavs: chyba kniznica. Spusti:  pip install pillow numpy")


EXTENSIONS = ("png", "jpg", "jpeg", "webp", "bmp")

# How far a pixel must differ from the background before it counts as figure.
FIGURE_THRESHOLD = 45

# A soft cast shadow is visible but far weaker than the figure. Anything in
# this band, low down in the image, is shadow rather than subject.
FAINT_LOW = 12
FAINT_HIGH = FIGURE_THRESHOLD

# Measured, not guessed. On the first character sheet, which had a shadow under
# the feet, the bottom sixth of the image was 8.5 to 11.5 per cent faint pixels.
# On the corrected sheet it was 0.14 to 0.22 per cent. Two per cent sits in the
# empty gap between them.
SHADOW_FRACTION = 0.02

# Heights within this fraction of each other are treated as consistent.
HEIGHT_TOLERANCE = 0.02


def collect(paths):
    """Turn whatever was on the command line into a list of image files."""
    files = []
    for arg in paths:
        if os.path.isdir(arg):
            for ext in EXTENSIONS:
                files.extend(sorted(glob.glob(os.path.join(arg, "*." + ext))))
        elif os.path.isfile(arg):
            files.append(arg)
        else:
            for ext in EXTENSIONS:
                files.extend(sorted(glob.glob("%s*.%s" % (arg, ext))))
    seen = []
    for f in files:
        if f not in seen:
            seen.append(f)
    return seen


def measure(path):
    image = Image.open(path).convert("RGB")
    pixels = np.asarray(image).astype(int)
    height, width = pixels.shape[:2]

    # The background colour is taken from the corners rather than assumed, and
    # the spread between them is what reveals a gradient.
    inset = max(2, min(width, height) // 100)
    corners = [pixels[inset, inset], pixels[inset, width - 1 - inset],
               pixels[height - 1 - inset, inset],
               pixels[height - 1 - inset, width - 1 - inset]]
    background = np.mean(corners, axis=0)
    gradient = float(np.max([np.abs(c - background).sum() for c in corners]))

    mask = np.abs(pixels - background).sum(axis=2) > FIGURE_THRESHOLD
    rows = np.where(mask.any(axis=1))[0]
    cols = np.where(mask.any(axis=0))[0]
    if rows.size == 0:
        return None

    top, bottom = int(rows[0]), int(rows[-1])
    left, right = int(cols[0]), int(cols[-1])

    # A cast shadow is visible but far weaker than the figure, and it pools in
    # the bottom of the frame. Measuring how much of the lower sixth sits in
    # that weak band separates a shadow from a clean plate by a wide margin.
    difference = np.abs(pixels - background).sum(axis=2)
    faint = (difference > FAINT_LOW) & (difference <= FAINT_HIGH)
    band_top = max(top, bottom - (bottom - top) // 6)
    shadow_fraction = float(faint[band_top:bottom + 1].mean())

    return {
        "path": path,
        "height": bottom - top + 1,
        "width": right - left + 1,
        "centre_x": (left + right) / 2.0 / width,
        "gradient": gradient,
        "shadow_fraction": shadow_fraction,
    }


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip())

    files = collect(sys.argv[1:])
    if not files:
        sys.exit("Slavs: nenasiel som ziadne obrazky.")

    results = [r for r in (measure(f) for f in files) if r is not None]
    if not results:
        sys.exit("Slavs: v obrazkoch som nenasiel ziadnu postavu. "
                 "Je pozadie jednofarebne?")

    print("Slavs: %d obrazkov" % len(results))
    print()
    print("  %-30s %7s %7s %8s %7s" % ("subor", "vyska", "sirka", "stred X",
                                       "tien"))
    for r in results:
        print("  %-30s %7d %7d %8.2f %6.2f%%"
              % (os.path.basename(r["path"]), r["height"], r["width"],
                 r["centre_x"], r["shadow_fraction"] * 100))
    print()

    problems = []

    heights = [r["height"] for r in results]
    spread = (max(heights) - min(heights)) / float(max(heights))
    if spread > HEIGHT_TOLERANCE:
        problems.append(
            "Postava nie je vsade rovnako vysoka (rozdiel %.1f %%). "
            "Rekonstrukcia bude skreslena - vygeneruj znova." % (spread * 100))
    else:
        print("  vysky sedia (rozdiel %.1f %%)" % (spread * 100))

    for r in results:
        if r["gradient"] > 30:
            problems.append(
                "%s: pozadie nie je rovnomerne (rozdiel v rohoch %d). "
                "Prechod sa moze zratat do modelu."
                % (os.path.basename(r["path"]), int(r["gradient"])))
        if r["shadow_fraction"] > SHADOW_FRACTION:
            problems.append(
                "%s: pod postavou je tien (%.1f %% spodnej sestiny). "
                "Zapecie sa do textury ako tmave fliaky."
                % (os.path.basename(r["path"]),
                   r["shadow_fraction"] * 100))

    print()
    if problems:
        for p in problems:
            print("  CHYBA: %s" % p)
        print()
        print("Slavs: oprav obrazky skor, nez minies kredit.")
        return 1

    print("Slavs: vyska, pozadie a tien su v poriadku.")
    print("Slavs: skript NEVIDI, ci postava nieco drzi alebo z nej nieco visi")
    print("Slavs: ani ci ma vsade rovnake vlasy - to prejdi okom.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
