"""
VOLYA - measure the rock's real top edge, per picture column.

BG_WALK_TOP in main.gd is one flat number: the first row where the WHOLE
width of the picture is solid rock, so the character never straddles a
transparent notch. That is correct but conservative - most columns turn
solid much earlier than the worst one, and the difference is the jagged
rock silhouette itself (see the background's own doc comment on
BACKGROUND_PATH for how that alpha cut was made).

This reads the actual per-column edge instead: for every pixel column, the
first row (from the top) where alpha == 255. Written out as a flat JSON
array, one integer per column, in the picture's own row numbers - the same
space BG_WALK_TOP is in - so main.gd can offset it by background_top() the
same way it already offsets the flat constant.

    python tools/measure_walk_top.py volya/art/env_07.png volya/art/env_07_top.json

Threshold is alpha == 255 (hard), not alpha > 0, on purpose: env_07's edge
alpha is soft (~50k partially-transparent pixels, see main.gd's comment on
BACKGROUND_PATH) and matching the flat constant's own convention keeps the
two comparable.
"""

import json
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("VOLYA: chyba kniznica. Spusti:  pip install pillow")


def top_edge_per_column(image_path: str) -> list[int]:
    im = Image.open(image_path).convert("RGBA")
    width, height = im.size
    pixels = im.load()
    edges = []
    for x in range(width):
        edge = -1
        for y in range(height):
            if pixels[x, y][3] == 255:
                edge = y
                break
        edges.append(edge)
    return edges


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit("pouzitie: python tools/measure_walk_top.py <vstup.png> <vystup.json>")
    src, dst = sys.argv[1], sys.argv[2]
    edges = top_edge_per_column(src)

    missing = edges.count(-1)
    if missing:
        print(f"VAROVANIE: {missing} stlpcov nema ziaden plne nepriehladny pixel "
              f"(alfa==255) v celom obrazku - obrazok mozno nie je vhodny pre "
              f"tuto metodu.", file=sys.stderr)

    print(f"stlpcov: {len(edges)}  min={min(edges)}  max={max(edges)}  "
          f"priemer={sum(edges) / len(edges):.1f}")
    print(f"sev na okraji (stlpec 0 vs posledny): "
          f"{edges[0]} vs {edges[-1]}  (rozdiel {abs(edges[0] - edges[-1])})")

    with open(dst, "w") as f:
        json.dump(edges, f)
    print(f"zapisane: {dst}")


if __name__ == "__main__":
    main()
