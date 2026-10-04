"""
Slavs - bake the new ground texture into a full background picture.

Takes a tileable ground tile (ref/preview/ground_pro_512.png) and writes
slavs/art/env_09.png: the same 2752x1536 picture as env_08 so the walkable
curves (env_08_top.json / env_08_bottom.json) and everything else stay put, but

  * the ground is the new texture at an integer 2x, no resampling;
  * the ground is opaque all the way to the bottom of the picture, so nothing
    but ground is ever visible below the walkable edge (the old lower band of
    forest is gone);
  * the top edge keeps a RIM-px strip of the original env_08 (grass fringe);
  * the picture wraps at 2752, which is not a multiple of the 1024 tile, so the
    wrap seam (and the seam where the tile repeats downwards) is stitched with a
    minimum-error cut instead of a hard edge.

All work is done at tile resolution (512 px) and doubled at the end, so every
art pixel stays a clean 2x2 block.

    python tools/bake_ground.py ref/preview/ground_pro_512.png
"""
import sys
import numpy as np
from PIL import Image

ART = "slavs/art/"
SCALE = 2
RIM = 36              # world units of env_08 kept along the top edge
OV_X = 80             # base px of overlap for the wrap seam
OV_Y = 48             # base px of overlap for the vertical repeat


def min_cut(err):
    """err[line, k]: cost of cutting at k on each line. Returns k per line,
    moving at most 1 between neighbouring lines."""
    n, m = err.shape
    cost = err.copy()
    back = np.zeros((n, m), dtype=int)
    for i in range(1, n):
        prev = cost[i - 1]
        best = prev.copy(); arg = np.arange(m)
        left = np.r_[np.inf, prev[:-1]]; right = np.r_[prev[1:], np.inf]
        for cand, shift in ((left, -1), (right, 1)):
            better = cand < best
            best = np.where(better, cand, best)
            arg = np.where(better, np.arange(m) + shift, arg)
        cost[i] = err[i] + best
        back[i] = arg
    path = np.zeros(n, dtype=int)
    path[-1] = int(np.argmin(cost[-1]))
    for i in range(n - 1, 0, -1):
        path[i - 1] = back[i, path[i]]
    return path


def main():
    tile = np.asarray(Image.open(sys.argv[1]).convert("RGB")).astype(np.int32)   # 512x512
    th, tw = tile.shape[:2]
    env = Image.open(ART + "env_08.png").convert("RGBA")
    W, H = env.size                      # 2752 x 1536
    W0, H0 = W // SCALE, H // SCALE      # 1376 x 768
    alpha = np.asarray(env)[..., 3] > 0
    top_row = alpha.argmax(axis=0)       # first opaque row per column (full res)

    # --- horizontal strip, periodic over W0 --------------------------------
    reps = (W0 + OV_X) // tw + 1
    base = np.tile(tile, (1, reps, 1))[:, :W0 + OV_X]
    a = base[:, W0:W0 + OV_X]            # continues from the right end
    b = base[:, :OV_X]
    err = ((a - b) ** 2).sum(axis=2)     # rows x OV_X
    cut = min_cut(err)
    strip = base[:, :W0].copy()
    for y in range(th):
        strip[y, :cut[y]] = a[y, :cut[y]]
    print("wrap seam cut: columns %d..%d of the %d px overlap" % (cut.min(), cut.max(), OV_X))

    # --- stack two copies vertically, second one rolled sideways -----------
    best = None
    ref_band = strip[th - OV_Y:th]
    for dx in range(0, W0, 2):
        band = np.roll(strip, dx, axis=1)[:OV_Y]
        e = ((ref_band - band) ** 2).mean()
        if best is None or e < best[0]:
            best = (e, dx)
    dx = best[1]
    second = np.roll(strip, dx, axis=1)
    err = ((ref_band - second[:OV_Y]) ** 2).sum(axis=2).T      # W0 x OV_Y
    cut = min_cut(err)
    total = th + th - OV_Y
    ground = np.zeros((total, W0, 3), dtype=np.int32)
    ground[:th] = strip
    ground[th:] = second[OV_Y:]
    ov = ground[th - OV_Y:th].copy()
    for x in range(W0):
        ov[cut[x]:, x] = second[:OV_Y][cut[x]:, x]
    ground[th - OV_Y:th] = ov
    print("vertical repeat: second copy rolled %d px, overlap error %.0f" % (dx, best[0]))

    # --- place on the picture ----------------------------------------------
    top0 = int(top_row.min()) // SCALE
    canvas = np.zeros((H0, W0, 3), dtype=np.uint8)
    need = H0 - top0
    canvas[top0:] = ground[:need]
    canvas[:top0] = ground[0]
    full = np.repeat(np.repeat(canvas, SCALE, axis=0), SCALE, axis=1)

    rows = np.arange(H)[:, None]
    solid = rows >= top_row[None, :]
    rim = solid & (rows < top_row[None, :] + RIM) & alpha
    envpx = np.asarray(env)
    out = np.zeros((H, W, 4), dtype=np.uint8)
    out[..., :3] = full
    out[..., 3] = np.where(solid, 255, 0)
    out[rim] = envpx[rim]
    Image.fromarray(out, "RGBA").save(ART + "env_09.png", optimize=True)
    print("wrote %senv_09.png %dx%d, top edge rows %d-%d" % (ART, W, H, top_row.min(), top_row.max()))


if __name__ == "__main__":
    main()
