"""
VOLYA - lay rendered variants out in a numbered grid, ready to choose from.

Every comparison in this project ends the same way: several renders, side by
side, numbered, and a human says a number. Doing that by hand each time is how
"write hotovo and wait" crept into the workflow, so it happens automatically at
the end of a variant run instead.

    python tools/make_grid.py --name zelezo --labels render/zelezo_variants.txt

Reads volya/art/<name>_v00_px, _v01_px ... and writes render/_look/<name>.png
"""

import argparse
import glob
import os
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    sys.exit("VOLYA: chyba Pillow - pip install pillow")


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--name", required=True)
    ap.add_argument("--labels", default="")
    ap.add_argument("--cols", type=int, default=3)
    ap.add_argument("--zoom", type=int, default=7)
    ap.add_argument("--out", default="")
    args = ap.parse_args()

    folders = sorted(glob.glob(os.path.join(
        ROOT, "volya", "art", "%s_v*_px" % args.name)))
    if not folders:
        sys.exit("VOLYA: nenasiel som ziadne %s_v??_px" % args.name)

    images = []
    for folder in folders:
        frames = sorted(glob.glob(os.path.join(folder, "*.png")))
        if frames:
            images.append(Image.open(frames[0]).convert("RGBA"))

    labels = []
    if args.labels and os.path.exists(args.labels):
        with open(args.labels, "r", encoding="utf-8") as handle:
            labels = [line.strip() for line in handle if line.strip()]
    while len(labels) < len(images):
        labels.append("")

    zoom = args.zoom
    cols = max(1, min(args.cols, len(images)))
    rows = (len(images) + cols - 1) // cols
    width, height = images[0].size
    bar = 32
    cell_w, cell_h = width * zoom, height * zoom + bar

    sheet = Image.new("RGB", (cols * cell_w, rows * cell_h), (22, 22, 30))
    draw = ImageDraw.Draw(sheet)
    for index, image in enumerate(images):
        row, col = divmod(index, cols)
        x, y = col * cell_w, row * cell_h
        big = image.resize((width * zoom, height * zoom), Image.NEAREST)
        sheet.paste(big, (x, y + bar), big)
        draw.rectangle([x, y, x + cell_w - 1, y + cell_h - 1],
                       outline=(74, 74, 94))
        draw.rectangle([x, y, x + cell_w - 1, y + bar - 1], fill=(40, 40, 54))
        draw.rectangle([x + 6, y + 5, x + 50, y + bar - 5], fill=(198, 58, 48))
        draw.text((x + 18, y + 11), "%02d" % (index + 1), fill=(255, 255, 255))
        draw.text((x + 60, y + 11), labels[index], fill=(228, 228, 228))

    out = args.out or os.path.join(ROOT, "render", "_look", args.name + ".png")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    sheet.save(out)
    print("VOLYA: mriezka %d variantov -> %s" % (len(images), out))
    return out


if __name__ == "__main__":
    main()
