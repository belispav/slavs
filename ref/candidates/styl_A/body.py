"""Anatomy toolkit for code-drawn silhouettes (v2): organic limbs with muscle
profiles, a curved torso, smooth outlines. All in local coords, facing right
(+x), origin at the feet, y down."""
import math


def lerp(a, b, t):
    return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)


def add(a, b):
    return (a[0] + b[0], a[1] + b[1])


def chaikin(pts, iters=3, closed=True):
    for _ in range(iters):
        out = []
        n = len(pts)
        rng = range(n) if closed else range(n - 1)
        if not closed:
            out.append(pts[0])
        for i in rng:
            p, q = pts[i], pts[(i + 1) % n]
            out.append(lerp(p, q, 0.25))
            out.append(lerp(p, q, 0.75))
        if not closed:
            out.append(pts[-1])
        pts = out
    return pts


def catmull(pts, n=8):
    """Smooth centreline through the given points."""
    out = []
    P = [pts[0]] + pts + [pts[-1]]
    for i in range(1, len(P) - 2):
        p0, p1, p2, p3 = P[i - 1], P[i], P[i + 1], P[i + 2]
        for k in range(n):
            t = k / n
            t2, t3 = t * t, t * t * t
            x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * t +
                       (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2 +
                       (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3)
            y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * t +
                       (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2 +
                       (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3)
            out.append((x, y))
    out.append(pts[-1])
    return out


def profile_stroke(pen, pts, widths, fill=255, n=8):
    """Stroke a smooth centreline whose width follows `widths` (one per
    control point, interpolated)."""
    line = catmull(pts, n)
    m = len(line)
    k = len(pts) - 1
    left, right = [], []
    for i, (x, y) in enumerate(line):
        a = line[max(i - 1, 0)]
        b = line[min(i + 1, m - 1)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy) or 1e-6
        nx, ny = -dy / L, dx / L
        u = i / (m - 1) * k
        j = min(int(u), k - 1)
        w = (widths[j] + (widths[j + 1] - widths[j]) * (u - j)) / 2
        left.append((x + nx * w, y + ny * w))
        right.append((x - nx * w, y - ny * w))
    pen.poly(left + right[::-1], fill)
    pen.circle(line[0], widths[0] / 2, fill)
    pen.circle(line[-1], widths[-1] / 2, fill)


def leg(pen, hip, knee, ankle, toe, heel=None, k=1.0, baggy=1.0):
    """Thigh bulges at the front, calf at the back. Boot with a heel."""
    thigh = add(lerp(hip, knee, 0.42), (1.2 * k, 0))
    calf = add(lerp(knee, ankle, 0.3), (-1.6 * k, 0))
    profile_stroke(pen, [hip, thigh, knee, calf, ankle],
                   [15 * k * baggy, 14 * k * baggy, 10 * k, 11.5 * k, 7.2 * k])
    if heel is None:
        heel = (ankle[0] - 4.5 * k, toe[1])
    sole_y = max(toe[1], heel[1])
    pen.poly(chaikin([(ankle[0] - 3.5 * k, ankle[1] - 2 * k),
                      (ankle[0] + 3.0 * k, ankle[1] - 2.5 * k),
                      (toe[0] - 1 * k, toe[1] - 4.2 * k),
                      (toe[0] + 1.6 * k, toe[1] - 1.5 * k),
                      (toe[0] + 1.2 * k, sole_y + 0.5),
                      (heel[0], heel[1] + 0.5),
                      (heel[0] - 0.8 * k, heel[1] - 3 * k)], 2))


def arm(pen, sh, el, wr, k=1.0, fist=True):
    bicep = lerp(sh, el, 0.45)
    fore = lerp(el, wr, 0.3)
    pen.circle(sh, 6.3 * k)  # deltoid
    profile_stroke(pen, [sh, bicep, el, fore, wr],
                   [11 * k, 9.4 * k, 7.0 * k, 8.0 * k, 5.6 * k])
    if fist:
        pen.circle(wr, 4.1 * k)


def torso(pen, H, N, k=1.0, chest=12.5, back=11.5, belly=10.0, butt=11.0,
          waist=9.0, gut=0.0):
    """Side profile from hip centre H to neck base N."""
    ux, uy = N[0] - H[0], N[1] - H[1]
    L = math.hypot(ux, uy)
    ux, uy = ux / L, uy / L
    fx, fy = -uy, ux  # perpendicular
    if fx < 0:  # forward must point +x
        fx, fy = -fx, -fy

    def at(t, f):
        return (H[0] + ux * L * t + fx * f * k, H[1] + uy * L * t + fy * f * k)

    pts = [
        at(-0.08, belly - 1),           # lower belly
        at(0.22, belly + gut),          # belly
        at(0.45, waist + gut * 0.5),    # under the ribs
        at(0.70, chest),                # chest
        at(0.90, chest - 2.5),          # collarbone
        at(1.02, 5.0),                  # front of the neck base
        at(1.02, -5.5),                 # nape
        at(0.86, -back),                # shoulder blades
        at(0.55, -back + 2.5),          # lower back curve
        at(0.25, -waist - 0.5),         # small of the back
        at(0.02, -butt),                # seat
        at(-0.12, -butt + 3),
    ]
    pen.poly(chaikin(pts, 3))


def head(pen, c, k=1.0, rx=7.3, ry=8.5, jaw=True, nose=True):
    pen.ellipse(c, rx * k, ry * k)
    if jaw:
        pen.poly(chaikin([(c[0] - 2 * k, c[1] + 2 * k), (c[0] + 6.5 * k, c[1] + 2.5 * k),
                          (c[0] + 7.0 * k, c[1] + 6.5 * k), (c[0] + 4.5 * k, c[1] + 9.5 * k),
                          (c[0] - 1.5 * k, c[1] + 8.5 * k)], 2))
    if nose:
        pen.poly([(c[0] + 6.2 * k, c[1] - 3.5 * k), (c[0] + 9.6 * k, c[1] + 0.8 * k),
                  (c[0] + 6.4 * k, c[1] + 1.4 * k)])
