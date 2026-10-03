"""
Slavs - turn a flat-colour chroma-key background into real transparency.

The AI generator this project uses only outputs JPEG, and JPEG has no alpha
channel - no prompt wording changes that, it is a property of the format.
So instead of asking the generator for "transparent", the prompt (see
ref/PROMPTY.md SS4c) asks for a perfectly flat, uniform key colour (magenta,
#FF00FF, chosen because it cannot occur in grass/rock/wood) standing in for
what should end up transparent. This script keys that colour out, the same
idea ref/PROMPTY.md SS5 already relies on for objects ("plain solid neutral
grey background") - this is what actually performs that cut-out.

What it does, in order:
  1. Measures the distance of every pixel from the key colour and turns that
     into an alpha value, feathered over a threshold band rather than a hard
     cut - a hard cut leaves a jagged, aliased edge; JPEG compression noise
     around the key colour makes a hard cut worse, not better.
  2. Despills: pixels close to the edge of the keyed area often carry a tinge
     of the key colour bled in by JPEG compression. Where magenta (R and B)
     is clearly higher than green, it is pulled down towards greyscale
     instead of left as a visible pink fringe.
  3. Crops vertically to where real content actually is (measured from the
     file, never assumed) - the generator does not reliably hit a requested
     aspect ratio, so this is not something to hand-write into a prompt.
     Never crops horizontally: a parallax layer must keep its full width to
     tile.
  4. Measures the same seam check DIZAJN_pozadie_a_rozlisenie.md uses for
     env_* backgrounds (left edge vs right edge against the image's own
     neighbour noise) so a bad tile is caught here, not on the phone.

    python tools/key_transparency.py slavs/art/env_05_fg_raw.jpg slavs/art/env_05_fg.png

Exits nonzero if the result looks unusable (see "problems" at the bottom),
so it can gate wiring the file into main.gd.
"""

import sys

try:
    import numpy as np
    from PIL import Image
except ImportError:
    sys.exit("Slavs: chyba kniznica. Spusti:  pip install pillow numpy")


KEY_DEFAULT = (255, 0, 255)
# Distance (0-441, the max possible in 8-bit RGB space) below which a pixel
# counts as fully keyed, and above which it counts as fully opaque. Between
# the two, alpha is feathered - this is what avoids a jagged cut-out edge.
DIST_TRANSPARENT = 60.0
DIST_OPAQUE = 140.0
# A row counts as "real content" once more than this fraction of its pixels
# are meaningfully opaque. Low, on purpose: a foreground strip is meant to be
# sparse (grass blades with gaps), not a solid block.
ROW_CONTENT_SHARE = 0.03


def parse_key(text):
    text = text.strip().lstrip("#")
    if len(text) != 6:
        sys.exit("Slavs: --key potrebuje 6 hex znakov, napr. FF00FF")
    return tuple(int(text[i:i + 2], 16) for i in (0, 2, 4))


def key_out(pixels, key):
    """RGB array -> (rgb array with despill applied, float alpha 0..1 array)."""
    diff = pixels.astype(float) - np.array(key, dtype=float)
    dist = np.sqrt((diff ** 2).sum(axis=2))

    alpha = (dist - DIST_TRANSPARENT) / (DIST_OPAQUE - DIST_TRANSPARENT)
    alpha = np.clip(alpha, 0.0, 1.0)
    # Smoothstep rather than a linear ramp - a linear feather still shows as
    # a visible soft ring around every leaf; smoothstep reads as a clean edge.
    alpha = alpha * alpha * (3.0 - 2.0 * alpha)

    # Despill: where red and blue (the magenta channels) sit clearly above
    # green, pull them down to the green level. Only matters near the edge -
    # deep inside real content, R/G/B do not follow the key colour's shape,
    # so this rarely fires there.
    r = pixels[..., 0].astype(float)
    g = pixels[..., 1].astype(float)
    b = pixels[..., 2].astype(float)
    magenta_push = np.clip(np.minimum(r, b) - g, 0.0, None)
    r2 = r - magenta_push
    b2 = b - magenta_push
    out = np.stack([r2, g, b2], axis=2)
    out = np.clip(out, 0.0, 255.0)
    return out, alpha


def content_rows(alpha):
    share = (alpha > 0.5).mean(axis=1)
    rows = np.where(share > ROW_CONTENT_SHARE)[0]
    if len(rows) == 0:
        return None, None
    return int(rows[0]), int(rows[-1])


def seam_metric(rgb, alpha):
    """Same idea as check_background.py's seam check, restricted to pixels
    that are actually part of the content (alpha above half), so empty
    margins on either side do not fake a perfect or a terrible match."""
    left_rgb, left_a = rgb[:, :6], alpha[:, :6]
    right_rgb, right_a = rgb[:, -6:], alpha[:, -6:]
    mask = (left_a.mean(axis=1) > 0.5) & (right_a.mean(axis=1) > 0.5)
    if not mask.any():
        return None, None
    seam = float(np.abs(left_rgb[mask].mean(axis=1) - right_rgb[mask].mean(axis=1)).mean())
    neighbour = float(np.abs(np.diff(rgb.mean(axis=2), axis=1)).mean())
    return seam, neighbour


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) < 2:
        sys.exit(__doc__.strip())
    src, dst = args[0], args[1]

    key = KEY_DEFAULT
    for a in sys.argv[1:]:
        if a.startswith("--key="):
            key = parse_key(a.split("=", 1)[1])

    image = Image.open(src).convert("RGB")
    pixels = np.asarray(image)
    height, width = pixels.shape[:2]

    rgb_out, alpha = key_out(pixels, key)

    covered = float((alpha > 0.5).mean())
    print("Slavs: %s -> %s" % (src, dst))
    print("  vstup               %d x %d px" % (width, height))
    print("  kluc                #%02X%02X%02X" % key)
    print("  podiel nepriehladnych pixelov   %.1f %%" % (covered * 100.0))

    top, bottom = content_rows(alpha)
    if top is None:
        sys.exit("Slavs: nenasiel som ziadny obsah - je kluc spravne? (--key=RRGGBB)")

    band = bottom - top + 1
    print("  obsah                riadky %d az %d (%d px)" % (top, bottom, band))

    rgb_crop = rgb_out[top:bottom + 1]
    alpha_crop = alpha[top:bottom + 1]

    seam, neighbour = seam_metric(rgb_crop, alpha_crop)
    problems = []
    if band < 20:
        problems.append(
            "Pas obsahu je len %d px - to je skoro nic, over kluc alebo obrazok." % band)
    if seam is not None and neighbour is not None:
        ratio = seam / neighbour if neighbour > 0.01 else float("inf")
        print("  spoj lava/prava      %.1f (susedny sum %.1f, poner %.2fx)"
              % (seam, neighbour, ratio))
        if ratio > 2.5:
            problems.append(
                "Lavy a pravy okraj obsahu sa lisia %.1fx viac nez susedny sum "
                "(env_05 sam mal 2.39x a to bol nahlaseny problem). Pri "
                "opakovani bude vidiet spoj." % ratio)
    else:
        print("  spoj lava/prava      nedalo sa zmerat (okraje su prazdne)")

    out_rgba = np.dstack([rgb_crop, (alpha_crop * 255.0)]).astype(np.uint8)
    Image.fromarray(out_rgba, mode="RGBA").save(dst)
    print("  ulozene do %s, %d x %d px" % (dst, width, band))
    print()
    print("  main.gd BG_LAYERS \"y\": pouzi background_top() + (obrazok_env05_vyska"
          " - %d)" % band)

    if problems:
        print()
        for p in problems:
            print("  CHYBA: %s" % p)
        return 1
    print("  V poriadku, ale aj tak sa na to pozri - toto nemeria, ci to")
    print("  vyzera ako riedka tráva, len ci sa kluc a spoj podarili.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
