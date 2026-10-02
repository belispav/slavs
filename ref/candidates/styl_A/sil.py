"""
VOLYA style test A: characters drawn by code as silhouettes.

Every figure is built from simple parts (capsules for limbs, ellipses for
head/torso, polygons for gear) in one fill colour, which is exactly how the
game would build them in Godot (Polygon2D parts on a Skeleton2D). Rendered
supersampled for clean edges, then composited over the real in-game
background at in-game scale (1 world unit = 1 px, view 1600x720).
"""
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

SS = 6  # supersampling factor
U = "/mnt/user-data/uploads/Slavs figh back/volya/art"
OUT = "/tmp/claude-0/-home-claude/33458727-12c3-53dc-8685-e87064f2450e/scratchpad/sil/"
VIEW_W, VIEW_H = 1600, 720
CROP_Y = 120  # env_08 row shown at the top of the frame


# ------------------------------------------------------------------ geometry
class Pen:
    """Draws into a supersampled L-mode mask, local coords: origin at feet,
    +x forward (facing right), y down. flip=True mirrors to face left."""

    def __init__(self, size, origin, flip=False, scale=1.0):
        self.img = Image.new("L", (size[0] * SS, size[1] * SS), 0)
        self.d = ImageDraw.Draw(self.img)
        self.ox, self.oy = origin
        self.flip = flip
        self.s = scale

    def P(self, p):
        x, y = p
        if self.flip:
            x = -x
        return ((self.ox + x * self.s) * SS, (self.oy + y * self.s) * SS)

    def R(self, r):
        return r * self.s * SS

    def circle(self, c, r, fill=255):
        x, y = self.P(c)
        rr = self.R(r)
        self.d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=fill)

    def poly(self, pts, fill=255):
        self.d.polygon([self.P(p) for p in pts], fill=fill)

    def capsule(self, a, b, r1, r2, fill=255):
        ax, ay = a
        bx, by = b
        dx, dy = bx - ax, by - ay
        L = math.hypot(dx, dy) or 1e-6
        nx, ny = -dy / L, dx / L
        self.poly([(ax + nx * r1, ay + ny * r1), (bx + nx * r2, by + ny * r2),
                   (bx - nx * r2, by - ny * r2), (ax - nx * r1, ay - ny * r1)], fill)
        self.circle(a, r1, fill)
        self.circle(b, r2, fill)

    def ellipse(self, c, rx, ry, ang=0.0, fill=255, part=None):
        cx, cy = c
        pts = []
        lo, hi = (0, 2 * math.pi) if part is None else part
        n = 40
        for i in range(n + 1):
            t = lo + (hi - lo) * i / n
            x, y = rx * math.cos(t), ry * math.sin(t)
            ca, sa = math.cos(ang), math.sin(ang)
            pts.append((cx + x * ca - y * sa, cy + x * sa + y * ca))
        self.poly(pts, fill)

    def stroke(self, pts, w0, w1, fill=255):
        """Variable-width polyline (width = diameter), tapering w0 -> w1."""
        n = len(pts)
        left, right = [], []
        for i, (x, y) in enumerate(pts):
            if i == 0:
                dx, dy = pts[1][0] - x, pts[1][1] - y
            elif i == n - 1:
                dx, dy = x - pts[i - 1][0], y - pts[i - 1][1]
            else:
                dx, dy = pts[i + 1][0] - pts[i - 1][0], pts[i + 1][1] - pts[i - 1][1]
            L = math.hypot(dx, dy) or 1e-6
            nx, ny = -dy / L, dx / L
            w = (w0 + (w1 - w0) * i / (n - 1)) / 2
            left.append((x + nx * w, y + ny * w))
            right.append((x - nx * w, y - ny * w))
        self.poly(left + right[::-1], fill)
        self.circle(pts[0], w0 / 2, fill)
        self.circle(pts[-1], w1 / 2, fill)

    def mask(self, size):
        return self.img.resize(size, Image.LANCZOS)


def bezier(p0, p1, p2, p3, n=30):
    out = []
    for i in range(n + 1):
        t = i / n
        a = (1 - t) ** 3
        b = 3 * (1 - t) ** 2 * t
        c = 3 * (1 - t) * t ** 2
        d = t ** 3
        out.append((a * p0[0] + b * p1[0] + c * p2[0] + d * p3[0],
                    a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1]))
    return out


def leg(p, hip, knee, ankle, toe, r=(7.0, 5.6, 3.8)):
    p.capsule(hip, knee, r[0], r[1])
    p.capsule(knee, ankle, r[1], r[2])
    # boot: ankle to toe with a flat sole
    p.capsule(ankle, toe, r[2] + 0.4, 2.4)
    p.poly([(ankle[0] - 4, ankle[1] - 1), (toe[0] + 1.5, toe[1] - 2),
            (toe[0] + 1.5, toe[1] + 0.4), (ankle[0] - 4.5, toe[1] + 0.4)])


def arm(p, sh, el, wr, r=(4.6, 3.9, 3.0), fist=3.7):
    p.capsule(sh, el, r[0], r[1])
    p.capsule(el, wr, r[1], r[2])
    p.circle(wr, fist)


# ------------------------------------------------------------------ figures
def hero(p, accent):
    """Escaped slave, drawing a bow. Beard, long hair, broken shackle."""
    # legs - wide archer stance
    leg(p, (-2, -62), (-11, -33), (-22, -6), (-11, 0))
    leg(p, (2, -62), (14, -34), (19, -6), (30, 0))
    # torso (side profile) + loose tunic flaring over the hips
    p.capsule((0, -62), (3, -89), 10.5, 11.5)
    p.poly([(-11, -72), (12, -72), (17, -47), (-15, -45)])
    # neck, head, beard, hair, nose
    p.capsule((4, -97), (6, -104), 4.6, 4.2)
    p.ellipse((6, -112), 7.4, 8.6)
    p.poly([(7, -108), (14.5, -107), (13, -99), (5, -100)])
    p.poly([(2, -119), (-6, -114), (-9, -103), (-3, -104), (0, -109)])
    p.circle((13.6, -112.5), 1.6)
    # draw arm (string hand at the cheek) and bow arm (extended)
    arm(p, (-1, -94), (-15, -99), (9, -104))
    p.circle((-1, -94), 6.2)  # shoulder mass
    arm(p, (6, -95), (25, -98), (43, -99))
    # bow: recurve, thick at the grip, thin at the tips
    limb = bezier((39, -137), (47, -128), (48, -112), (45, -99)) + \
        bezier((45, -99), (48, -86), (47, -70), (39, -61))[1:]
    p.stroke(limb, 1.6, 1.6)
    p.stroke(bezier((45, -112), (46.5, -106), (46.5, -92), (45, -86), 8), 3.4, 3.4)
    # string to the hand, arrow along it
    p.stroke([(39, -137), (9, -104)], 0.8, 0.8)
    p.stroke([(39, -61), (9, -104)], 0.8, 0.8)
    p.stroke([(6, -104), (58, -100)], 1.2, 1.2)
    p.poly([(58, -102.6), (64, -100), (58, -97.6)])
    p.poly([(6, -104), (1, -107.5), (3, -104), (1, -100.5)])
    # broken shackle + dangling chain on the draw forearm
    p.ellipse((1, -102), 3.6, 4.2, 0.3)
    for i, c in enumerate([(-0.5, -96.5), (-1.5, -92.5), (-1.8, -88.5)]):
        p.circle(c, 1.5 - i * 0.15)
    # sash: separate colour layer, drawn by the caller with accent pen
    return [
        ("band", [(-11.5, -68), (12.5, -68), (12.5, -62.5), (-11.5, -62.5)]),
        ("tail", bezier((-10, -64), (-20, -63), (-28, -57), (-34, -49), 16)),
    ]


def rusher(p):
    """Big raider charging, two-handed spiked club wound up overhead."""
    s = 1.0
    leg(p, (-3, -74), (-15, -42), (-31, -16), (-25, -7), r=(8.5, 6.8, 4.6))
    leg(p, (3, -74), (19, -44), (17, -8), (30, 0), r=(8.5, 6.8, 4.6))
    # barrel body leaning forward, belly
    p.capsule((0, -72), (11, -103), 13.5, 15.5)
    p.circle((13, -86), 13.5)
    # kaftan skirt flaring back from the run
    p.poly([(-15, -84), (17, -84), (25, -48), (-6, -44), (-30, -52)])
    # neck + head + helmet (dome, rim, short spike) - no turban
    p.capsule((14, -114), (17, -121), 6.2, 5.6)
    p.ellipse((19, -127), 9.2, 10.0)
    p.ellipse((18, -130), 11.0, 10.5, 0, part=(math.pi, 2 * math.pi))
    p.ellipse((18, -130), 12.5, 2.2)
    p.stroke([(18, -140), (17, -147)], 2.4, 0.8)
    p.circle((28, -125), 1.8)  # nose
    # arms up behind the head, both hands on the club
    p.circle((11, -108), 8.0)
    arm(p, (9, -109), (-4, -127), (2, -147), r=(6.0, 5.0, 3.8), fist=4.5)
    arm(p, (14, -107), (22, -128), (10, -146), r=(6.0, 5.0, 3.8), fist=4.5)
    # club: handle in the fists, head swung back
    p.stroke([(14, -146), (-6, -151), (-24, -156), (-42, -161)], 4.0, 12.0)
    for t in (0.35, 0.55, 0.75, 0.95):
        x = 14 + (-42 - 14) * t
        y = -146 + (-161 + 146) * t
        w = 4 + 8 * t
        p.poly([(x - 2, y - w / 2 + 1), (x + 0.5, y - w / 2 - 5), (x + 2, y - w / 2 + 1)])
        p.poly([(x - 2, y + w / 2 - 1), (x - 0.5, y + w / 2 + 5), (x + 2, y + w / 2 - 1)])


def gunman(p):
    """Arquebusier aiming. Kettle hat, long coat."""
    leg(p, (-2, -64), (-6, -34), (-13, -6), (-2, 0))
    leg(p, (2, -64), (9, -34), (11, -6), (21, 0))
    p.capsule((0, -62), (0, -92), 10.5, 11.5)
    p.poly([(-12, -72), (12, -72), (18, -30), (-18, -28)])
    p.capsule((2, -100), (3, -106), 4.6, 4.2)
    p.ellipse((4, -113), 7.4, 8.4)
    p.circle((11.5, -113.5), 1.5)
    # kettle hat: crown + wide brim
    p.ellipse((3, -119), 8.6, 8.0, 0, part=(math.pi, 2 * math.pi))
    p.ellipse((3, -119), 15.5, 2.6)
    # arquebus at the shoulder
    p.poly([(-5, -99), (5, -108), (16, -108), (16, -102), (3, -97)])
    p.capsule((15, -105.5), (66, -106.5), 2.1, 1.7)
    p.stroke([(22, -104), (40, -104)], 3.0, 3.0)  # wooden fore-stock
    p.stroke([(30, -103), (30, -91), (33, -88)], 1.1, 1.1)  # match cord
    # arms
    p.circle((0, -97), 6.0)
    arm(p, (-1, -97), (-9, -89), (8, -102))
    arm(p, (4, -96), (19, -93), (30, -104))
    # bandolier charges along the chest (they read even as silhouette bumps)
    for i in range(4):
        p.circle((10 + i * 0.3, -95 + i * 6), 2.0)


def overseer(p):
    """Slave-driver winding up a whip. Fur cap."""
    leg(p, (-2, -63), (-8, -34), (-15, -6), (-4, 0))
    leg(p, (2, -63), (11, -34), (15, -6), (25, 0))
    p.capsule((0, -62), (-2, -93), 10.5, 12.0)
    p.poly([(-12, -74), (11, -74), (16, -34), (-16, -33)])
    p.capsule((0, -100), (1, -106), 4.8, 4.4)
    p.ellipse((2, -113), 7.6, 8.6)
    p.circle((9.8, -113), 1.6)
    p.poly([(4, -108), (10, -107), (8, -102), (2, -103)])  # short beard
    # fur cap: tall dome on a thick rim
    p.ellipse((1, -123), 8.8, 9.5, 0, part=(math.pi, 2 * math.pi))
    p.ellipse((1, -120), 10.6, 3.6)
    # whip arm raised behind
    p.circle((-3, -96), 6.4)
    arm(p, (-3, -97), (-17, -110), (-24, -127))
    p.stroke([(-24, -127), (-22, -139)], 3.0, 2.4)
    lash = bezier((-22, -139), (-50, -175), (-95, -150), (-88, -108), 30) + \
        bezier((-88, -108), (-84, -88), (-62, -96), (-70, -108), 18)[1:]
    p.stroke(lash, 2.4, 0.7)
    # other arm points ahead
    arm(p, (3, -95), (14, -84), (27, -86))


# ------------------------------------------------------------------ scene
INK = (14, 12, 14)
SASH = (176, 28, 24)
RIM = (255, 196, 120)


def render_figure(fn, origin, flip, size=(VIEW_W, VIEW_H), scale=1.0):
    p = Pen(size, origin, flip, scale)
    extra = fn(p) if fn is not hero else None
    sash = None
    if fn is hero:
        parts = hero(p, None)
        a = Pen(size, origin, flip, scale)
        a.poly(parts[0][1])
        a.stroke(parts[1][1], 4.6, 1.4)
        sash = a.mask(size)
    return p.mask(size), sash


def rim_light(mask, dx, dy, width=2):
    """Edge pixels of the silhouette that face the light (dx, dy)."""
    m = np.asarray(mask).astype(np.float32) / 255.0
    shifted = np.roll(np.roll(m, -dy * width, axis=0), -dx * width, axis=1)
    rim = np.clip(m - shifted, 0, 1)
    return Image.fromarray((rim * 255).astype(np.uint8))


def shadow(size, cx, cy, rx, ry, alpha=0.35):
    sh = Image.new("L", (size[0] * SS, size[1] * SS), 0)
    d = ImageDraw.Draw(sh)
    d.ellipse([(cx - rx) * SS, (cy - ry) * SS, (cx + rx) * SS, (cy + ry) * SS],
              fill=int(255 * alpha))
    return sh.resize(size, Image.LANCZOS).filter(ImageFilter.GaussianBlur(2))


def background(variant):
    sky = Image.open(U + "/env_07_sky.png").convert("RGBA")
    sky = sky.resize((sky.width // 2, sky.height // 2), Image.LANCZOS)
    ground = Image.open(U + "/env_08.png").convert("RGBA")
    frame = Image.new("RGBA", (VIEW_W, VIEW_H), (0, 0, 0, 255))
    if variant == 3:
        # dusk: graded sky gradient, the forest/hills of the real sky layer
        # turned into dark layered shapes
        g = np.zeros((VIEW_H, VIEW_W, 3), np.float32)
        top, mid, low = np.array([62, 40, 70]), np.array([214, 110, 70]), np.array([255, 214, 140])
        for y in range(VIEW_H):
            t = y / 330.0
            if t < 0.6:
                c = top + (mid - top) * (t / 0.6)
            else:
                c = mid + (low - mid) * min((t - 0.6) / 0.4, 1)
            g[y, :] = c
        frame = Image.fromarray(g.astype(np.uint8)).convert("RGBA")
        sk = np.asarray(sky).astype(np.float32)
        lum = (0.299 * sk[..., 0] + 0.587 * sk[..., 1] + 0.114 * sk[..., 2]) / 255
        bluish = (sk[..., 2] > sk[..., 1] + 25) & (sk[..., 2] > 120)
        out = np.zeros_like(sk)
        hills = np.array([120, 70, 72])
        trees = np.array([58, 34, 44])
        for c in range(3):
            out[..., c] = trees[c] + (hills[c] - trees[c]) * np.clip((lum - 0.15) * 2.2, 0, 1)
        out[..., 3] = np.where(bluish, 0, 255)
        sky = Image.fromarray(out.astype(np.uint8))
    sky_bottom = 520 if variant == 3 else 400
    for x0 in range(0, VIEW_W, sky.width):
        frame.alpha_composite(sky, (x0, sky_bottom - sky.height))
    crop = ground.crop((0, CROP_Y, VIEW_W, CROP_Y + VIEW_H))
    if variant == 3:
        a = np.asarray(crop).astype(np.float32)
        lum = 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]
        warm = np.array([236, 176, 120], np.float32)
        lifted = 70 + lum * 1.05
        for c in range(3):
            a[..., c] = np.clip(lifted * warm[c] / 236.0 * 0.85 + a[..., c] * 0.15, 0, 255)
        crop = Image.fromarray(a.astype(np.uint8))
    frame.alpha_composite(crop)
    return frame


# placement: (figure, x, feet_y, facing_left)
CAST = [
    (gunman, 1270, 420, True),
    (overseer, 1060, 505, True),
    (hero, 520, 560, False),
    (rusher, 790, 630, True),
]


def compose(variant):
    frame = background(variant)
    for fn, x, y, flip in CAST:
        frame.alpha_composite(Image.new("RGBA", frame.size, (0, 0, 0, 0)))
        sh = shadow(frame.size, x, y, 24 if fn is not rusher else 30, 5)
        black = Image.new("RGBA", frame.size, (0, 0, 0, 255))
        frame.paste(black, (0, 0), sh)
        mask, sash = render_figure(fn, (x, y), flip)
        ink = Image.new("RGBA", frame.size, INK + (255,))
        frame.paste(ink, (0, 0), mask)
        if variant in (2, 3):
            rim = rim_light(mask, 1 if not flip else 1, -1, 2)
            col = RIM if variant == 2 else (255, 170, 110)
            r = Image.new("RGBA", frame.size, col + (255,))
            rim = Image.fromarray((np.asarray(rim) * (0.85 if variant == 2 else 0.6)).astype(np.uint8))
            frame.paste(r, (0, 0), rim)
        if sash is not None:
            frame.paste(Image.new("RGBA", frame.size, SASH + (255,)), (0, 0), sash)
    # one enemy shot in flight + muzzle smoke for the gunman, game-style
    d = ImageDraw.Draw(frame, "RGBA")
    for i, (sx, sy, r) in enumerate([(1196, 315, 9), (1182, 309, 12), (1166, 300, 15)]):
        d.ellipse([sx - r, sy - r, sx + r, sy + r], fill=(200, 200, 200, 70 - i * 15))
    d.ellipse([1000 - 6, 318 - 6, 1000 + 6, 318 + 6], fill=(255, 107, 77, 255))
    return frame.convert("RGB")


def closeup():
    W, H = 760, 230
    frame = Image.new("RGBA", (W, H), (226, 214, 196, 255))
    xs = [(hero, 100, False), (rusher, 300, True), (gunman, 480, True), (overseer, 660, True)]
    for fn, x, flip in xs:
        mask, sash = render_figure(fn, (x, 200), flip, size=(W, H))
        frame.paste(Image.new("RGBA", (W, H), INK + (255,)), (0, 0), mask)
        if sash is not None:
            frame.paste(Image.new("RGBA", (W, H), SASH + (255,)), (0, 0), sash)
    return frame.convert("RGB").resize((W * 2, H * 2), Image.LANCZOS)


if __name__ == "__main__":
    shots = []
    for v in (1, 2, 3):
        im = compose(v)
        im.save(OUT + f"styl_A_variant{v}.png")
        shots.append(im)
    closeup().save(OUT + "styl_A_postavy_zblizka.png")
    # grid with numbers, as the project's method asks
    gw = VIEW_W // 2
    gh = VIEW_H // 2
    grid = Image.new("RGB", (gw, gh * 3 + 8 * 2), (20, 20, 20))
    for i, im in enumerate(shots):
        small = im.resize((gw, gh), Image.LANCZOS)
        grid.paste(small, (0, i * (gh + 8)))
        d = ImageDraw.Draw(grid)
        try:
            f = ImageFont.truetype("DejaVuSans-Bold.ttf", 40)
        except OSError:
            f = ImageFont.load_default()
        d.rectangle([10, i * (gh + 8) + 10, 60, i * (gh + 8) + 60], fill=(0, 0, 0))
        d.text((22, i * (gh + 8) + 12), str(i + 1), fill=(255, 255, 255), font=f)
    grid.save(OUT + "styl_A_mriezka.png")
    print("ok")
