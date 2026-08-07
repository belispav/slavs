"""
VOLYA - find the frame that shows the most of the weapon.

Judging a weapon from a frame where the body hides it wastes a whole round, and
it happened three times in a row because the frame was always chosen by guess.
The weapon is rendered on its own, in magenta; counting its pixels per frame is
then arithmetic, not opinion.

    python tools/count_weapon.py --dir render/gunman_pick_raw --fit art/fits/gunman.json

Prints a ranking and, if --fit is given, stores the winner in that file as
"preview_frame", so every later preview uses it without being told.
"""

import argparse
import glob
import json
import os
import re
import sys

try:
    from PIL import Image
    import numpy as np
except ImportError:
    sys.exit("VOLYA: chyba Pillow alebo numpy - "
             "pip install pillow numpy")


def frame_number(path):
    found = re.findall(r"(\d+)\.png$", os.path.basename(path))
    return int(found[0]) if found else -1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True,
                    help="folder of weapon-only renders")
    ap.add_argument("--fit", default="",
                    help="placement JSON; the winner goes in its .settings.json")
    ap.add_argument("--top", type=int, default=8)
    args = ap.parse_args()

    files = sorted(glob.glob(os.path.join(args.dir, "*.png")))
    if not files:
        sys.exit("VOLYA: v %s nie su ziadne PNG" % args.dir)

    counts = []
    for path in files:
        a = np.array(Image.open(path).convert("RGBA"))
        counts.append((frame_number(path), int((a[..., 3] > 8).sum())))

    ranked = sorted(counts, key=lambda t: -t[1])
    best, most = ranked[0]
    worst = ranked[-1]

    print("VOLYA: %d snimok preskumanych" % len(counts))
    print("VOLYA: najlepsie snimky (kolko pixelov zbrane je vidiet):")
    for frame, n in ranked[:args.top]:
        print("   snimka %4d : %4d px" % (frame, n))
    print("VOLYA: najhorsia snimka %d ma len %d px - o %.0f %% menej"
          % (worst[0], worst[1], (1 - worst[1] / float(max(most, 1))) * 100))
    print("VOLYA: NA POSUDZOVANIE POUZI SNIMKU %d" % best)

    if args.fit:
        folder = os.path.dirname(os.path.abspath(args.fit))
        stem = os.path.splitext(os.path.basename(args.fit))[0].split("_")[0]
        target = os.path.join(folder, stem + ".settings.json")
        data = {}
        if os.path.exists(target):
            with open(target, "r", encoding="utf-8") as handle:
                data = json.load(handle)
        data["preview_frame"] = best
        with open(target, "w", encoding="utf-8") as handle:
            json.dump(data, handle, indent=2, ensure_ascii=False)
        print("VOLYA: preview_frame %d zapisany do %s"
              % (best, os.path.basename(target)))


if __name__ == "__main__":
    main()
