"""
VOLYA - measure the ground's real bottom edge, per picture column.

Mirrors measure_walk_top.py exactly, just from the other side: BG_WALK_BOTTOM
in main.gd is one flat number, the LAST row where the WHOLE width of the
picture is solid, so the character never straddles a transparent notch on the
way out at the front of the field. That is correct but conservative in the
same way BG_WALK_TOP's flat number was - the silhouette frays gradually
(env_08: rows 1287-1369, see main.gd's BG_WALK_TOP/BOTTOM comment), and most
columns stay solid well past the worst one.

This reads the actual per-column edge instead: for every pixel column, the
LAST row (scanning from the top down) where alpha == 255. Written out the
same way measure_walk_top.py writes its file - a flat JSON array, one integer
per column, in the picture's own row numbers, so main.gd can offset it by
background_top() the same way.

    python tools/measure_walk_bottom.py volya/art/env_08.png volya/art/env_08_bottom.json

Threshold is alpha == 255 (hard), not alpha > 0, for the same reason
measure_walk_top.py uses it: env_08's edge alpha is hard 0/255 by
construction (tools/key_transparency.py's despill pass, not a soft cut), so
this and the flat constant's own convention stay comparable.

ADDED 2026-09-15, Pavel on device: asked why the silhouette-following only
happened at the top, not the bottom - "toto ocividne funguje len na hornom
okraji... chceme to aj na spodnom". No reason it shouldn't; nobody had built
it yet because the per-column top curve was only ever requested for the top
(2026-09-04, the Metal Slug ledge). player.gd's set_dynamic_bottom() is the
new counterpart to set_dynamic_top() that reads this file's output.
"""

import json
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("VOLYA: chyba kniznica. Spusti:  pip install pillow")


def bottom_edge_per_column(image_path: str) -> list[int]:
    im = Image.open(image_path).convert("RGBA")
    width, height = im.size
    pixels = im.load()
    edges = []
    for x in range(width):
        edge = -1
        for y in range(height - 1, -1, -1):
            if pixels[x, y][3] == 255:
                edge = y
                break
        edges.append(edge)
    return edges


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit("pouzitie: python tools/measure_walk_bottom.py <vstup.png> <vystup.json>")
    src, dst = sys.argv[1], sys.argv[2]
    edges = bottom_edge_per_column(src)

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
