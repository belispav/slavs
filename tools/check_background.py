"""
VOLYA - measure a background before it goes into the game.

The picture is drawn one pixel to one game unit, so its rows ARE the game's
geometry. The screen is 720 units tall; if the open ground is shorter than that,
the whole field fits at once and the camera has nothing to scroll to.

Reports where the open ground is, whether it is tall enough, and whether the
left and right edges match well enough to repeat.

    python tools/check_background.py volya/art/env_01.png

Prints the two numbers to paste into main.gd if the picture is usable.
"""

import sys

try:
    import numpy as np
    from PIL import Image
except ImportError:
    sys.exit("VOLYA: chyba kniznica. Spusti:  pip install pillow numpy")


SCREEN_HEIGHT = 720          # must match the viewport height in project.godot
WANTED_SCROLL = 180          # how much vertical travel to aim for
CHARACTER_HEIGHT = 130       # for a sense of scale, not a rule


GROUND_SHARE = 0.72


def ground_rows(pixels):
    """How much of each row looks like open ground.

    Ground is warm and mid-bright: brown dirt and green grass. Water below is
    pale, trees above are dark. A timber palisade is neither - it is warm brown
    wood, and reads as ground on colour alone, so colour alone is not enough.

    What separates them is structure. A row of palisade is a row of posts, so it
    changes colour many times across its width; a row of open ground changes
    slowly. Counting those changes tells the two apart.
    """
    red = pixels[..., 0]
    blue = pixels[..., 2]
    brightness = pixels.mean(axis=2)
    warm = (red > blue + 12) & (brightness > 70) & (brightness < 190)

    steps = np.abs(np.diff(brightness, axis=1)) > 26
    busy = steps.mean(axis=1)
    # Normalised against the calmest rows in the picture, so this works whatever
    # the art style turns out to be.
    calm = busy <= np.quantile(busy, 0.55)

    return warm.mean(axis=1) * calm


def longest_run(mask):
    """Start and end of the longest unbroken stretch of true.

    Taking the first and last matching row instead was the earlier mistake: a
    few palisade rows a long way above the ground dragged the top of the band up
    into the fence.
    """
    best = (0, -1)
    start = None
    for index, value in enumerate(mask):
        if value and start is None:
            start = index
        elif not value and start is not None:
            if index - 1 - start > best[1] - best[0]:
                best = (start, index - 1)
            start = None
    if start is not None and len(mask) - 1 - start > best[1] - best[0]:
        best = (start, len(mask) - 1)
    return best


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip())
    path = sys.argv[1]

    image = Image.open(path).convert("RGB")
    pixels = np.asarray(image).astype(int)
    height, width = pixels.shape[:2]

    share = ground_rows(pixels)
    top, bottom = longest_run(share > GROUND_SHARE)
    if bottom <= top:
        sys.exit("VOLYA: nenasiel som suvislu zem. Je to vobec pozadie?")
    band = bottom - top

    print("VOLYA: %s" % path)
    print("  rozmer            %d x %d px" % (width, height))
    print("  volna zem         riadky %d az %d" % (top, bottom))
    print("  vyska pasu        %d px  (%.0f %% obrazka)"
          % (band, 100.0 * band / height))
    print("  to je             %.1f vysky postavy" % (band / float(CHARACTER_HEIGHT)))

    scroll = max(0, band - SCREEN_HEIGHT)
    print("  kamera scrolluje  %d px" % scroll)

    left = pixels[:, :6].mean(axis=1)
    right = pixels[:, -6:].mean(axis=1)
    seam = float(np.abs(left - right).mean())
    print("  spoj lava/prava   %.1f" % seam)

    print()
    problems = []
    if band < SCREEN_HEIGHT:
        problems.append(
            "Pas je nizsi nez obrazovka (%d < %d), takze sa cele pole zmesti "
            "naraz a kamera sa zamkne. Treba sirsiu volnu zem - horny a dolny "
            "pas zuzit, nie obrazok zvacsit."
            % (band, SCREEN_HEIGHT))
    elif scroll < WANTED_SCROLL * 0.6:
        problems.append(
            "Pas je len o %d px vyssi nez obrazovka, scroll bude sotva citelny. "
            "Ciel je okolo %d." % (scroll, WANTED_SCROLL))
    if seam > 25.0:
        problems.append(
            "Lavy a pravy okraj sa lisia (%.0f). Pri opakovani bude vidiet spoj."
            % seam)
    if height < 1200:
        problems.append(
            "Obrazok je nizky (%d px). Kresli sa 1:1, takze mala vyska v "
            "pixeloch znamena malu hraciu plochu - a zvacsit sa neda, "
            "skalovany pixel art vyzera zle." % height)

    if problems:
        for p in problems:
            print("  CHYBA: %s" % p)
        return 1

    print("  V poriadku. Do volya/scripts/main.gd nastav:")
    print("      const BG_WALK_TOP := %.1f" % top)
    print("      const BG_WALK_BOTTOM := %.1f" % bottom)
    return 0


if __name__ == "__main__":
    sys.exit(main())
