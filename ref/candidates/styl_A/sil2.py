"""Style test A, v2 figures: anatomical silhouettes built with body.py."""
import math
import sil
from sil import bezier
from body import leg, arm, torso, head, chaikin, profile_stroke, lerp


def hero(p, _accent):
    """Escaped slave drawing a bow: ragged tunic, long hair, beard,
    broken shackle with the chain still hanging."""
    H, N = (0, -61), (-1, -99)
    leg(p, (-3, -60), (-14, -34), (-25, -8), (-13, 0), heel=(-28, -1), baggy=1.1)
    leg(p, (3, -60), (16, -35), (20, -8), (32, 0), heel=(16, 0), baggy=1.1)
    torso(p, H, N, chest=12.5, back=11.5)
    # ragged tunic over the hips, tails blown back
    p.poly(chaikin([(-12, -76), (12, -76), (15, -60), (16, -47), (12, -50),
                    (9, -44), (5, -49), (1, -43), (-3, -48), (-8, -42),
                    (-11, -47), (-17, -41), (-16, -52), (-14, -64)], 1))
    # neck, head, beard, long hair
    profile_stroke(p, [(-1, -99), (2, -106)], [10, 9])
    head(p, (3, -114))
    p.poly(chaikin([(1, -109), (9, -110), (11.5, -104), (9, -97), (4, -96), (0, -100)], 2))
    # hair: one mass, tied back and blown behind
    p.ellipse((2, -118), 7.8, 6.2)
    p.poly(chaikin([(-5, -122), (2, -124), (-1, -116), (-4, -108), (-9, -101),
                    (-15, -99), (-13, -106), (-10, -114)], 2))
    # arms: bow arm straight ahead, draw hand at the cheek
    arm(p, (-3, -94), (-20, -98), (6, -106))
    arm(p, (3, -95), (22, -98), (42, -100))
    # bow
    limb = bezier((38, -139), (47, -130), (49, -114), (45, -100)) + \
        bezier((45, -100), (49, -86), (47, -70), (38, -61))[1:]
    p.stroke(limb, 2.0, 1.4)
    p.stroke(bezier((45.5, -112), (47, -106), (47, -94), (45.5, -88), 8), 3.8, 3.8)
    p.stroke([(38, -139), (6, -106)], 0.8, 0.8)
    p.stroke([(38, -61), (6, -106)], 0.8, 0.8)
    p.stroke([(3, -106), (60, -101)], 1.3, 1.3)
    p.poly([(59, -103.8), (66, -101), (59, -98.2)])
    p.poly([(3, -106), (-3, -110), (0, -106), (-3, -102)])
    # broken shackle on the draw forearm, chain hanging
    p.ellipse((-3, -104), 4.0, 4.8, 0.35)
    for i, c in enumerate([(-5, -98), (-6.2, -93.5), (-6.8, -89), (-6.6, -84.8)]):
        p.circle(c, 1.7 - i * 0.18)
    return [
        ("band", chaikin([(-12.5, -70), (12.8, -70), (12.4, -63), (-12.8, -63)], 1)),
        ("tail", bezier((-11, -66), (-22, -66), (-31, -60), (-40, -52), 16)),
    ]


def rusher(p):
    """Heavy raider charging, spiked club wound up behind the head."""
    k = 1.2
    H, N = (0, -76), (16, -114)
    leg(p, (-4, -74), (-18, -44), (-36, -18), (-28, -9), heel=(-40, -14), k=k)
    leg(p, (4, -74), (23, -48), (21, -9), (35, 0), heel=(16, 0), k=k)
    torso(p, H, N, k=k, chest=14, back=13, belly=13, butt=12, waist=12, gut=4)
    # kaftan skirt flaring back from the run
    p.poly(chaikin([(-15, -88), (18, -86), (24, -64), (28, -48), (8, -45),
                    (-12, -44), (-32, -50), (-24, -70)], 2))
    profile_stroke(p, [(16, -114), (20, -121)], [13, 12])
    head(p, (23, -128), k=1.15)
    # open mouth / shout: notch in the jaw outline is not readable at this
    # size, so the read comes from the jutting jaw and the helmet instead
    p.ellipse((22, -132), 11.5, 10.5, 0, part=(math.pi, 2 * math.pi))
    p.ellipse((22, -132), 13.5, 2.4)
    p.stroke([(22, -142), (21, -150)], 2.6, 0.8)
    p.stroke([(31, -131), (31.5, -123)], 2.0, 1.4)  # nasal guard
    # arms up, hands together above and behind the head
    arm(p, (11, -108), (-1, -128), (8, -149), k=1.25)
    arm(p, (17, -107), (30, -126), (13, -150), k=1.25)
    # club: from the fists back and down behind the shoulders
    shaft = [(16, -151), (-2, -146), (-20, -139), (-38, -130)]
    profile_stroke(p, shaft, [5, 7, 11, 14])
    for t in (0.45, 0.62, 0.79, 0.96):
        x = 16 + (-38 - 16) * t
        y = -151 + (-130 + 151) * t
        w = 5 + 9 * t
        p.poly([(x - 2.4, y - w / 2 + 1), (x - 1, y - w / 2 - 6), (x + 2.4, y - w / 2 + 1)])
        p.poly([(x - 2.4, y + w / 2 - 1), (x - 1.5, y + w / 2 + 6), (x + 2.4, y + w / 2 - 1)])


def gunman(p):
    """Arquebusier aiming. Kettle hat, long coat, bandolier of charges."""
    H, N = (0, -62), (1, -99)
    leg(p, (-3, -61), (-7, -33), (-14, -7), (-2, 0), heel=(-17, 0))
    leg(p, (3, -61), (10, -34), (12, -7), (24, 0), heel=(8, 0))
    torso(p, H, N, chest=12, back=11.5)
    p.poly(chaikin([(-12, -74), (12, -74), (16, -50), (19, -30), (6, -28),
                    (-6, -28), (-20, -30), (-15, -52)], 2))
    profile_stroke(p, [(1, -99), (3, -106)], [10, 9])
    head(p, (5, -114))
    p.ellipse((4, -120), 8.8, 8.2, 0, part=(math.pi, 2 * math.pi))
    p.ellipse((4, -120), 16.5, 2.6)
    # arquebus
    p.poly(chaikin([(-6, -98), (4, -108), (17, -109), (17, -102), (3, -96)], 1))
    p.capsule((16, -106), (68, -107), 2.2, 1.8)
    p.stroke([(22, -104.5), (42, -104.5)], 3.4, 3.0)
    p.stroke([(30, -103), (29, -92), (33, -88), (36, -90)], 1.1, 1.1)
    arm(p, (-1, -95), (-10, -87), (8, -103))
    arm(p, (4, -95), (19, -92), (31, -104))
    for i in range(5):
        p.circle(lerp((12, -96), (0, -72), i / 4), 2.1)


def overseer(p):
    """Slave-driver lashing a whip. Fur cap."""
    H, N = (0, -62), (-3, -99)
    leg(p, (-3, -61), (-9, -34), (-16, -7), (-4, 0), heel=(-19, 0))
    leg(p, (3, -61), (12, -34), (16, -7), (28, 0), heel=(12, 0))
    torso(p, H, N, chest=13, back=12, belly=11, gut=2)
    p.poly(chaikin([(-12, -74), (12, -74), (15, -50), (17, -34), (4, -32),
                    (-8, -32), (-18, -34), (-14, -52)], 2))
    profile_stroke(p, [(-3, -99), (-1, -106)], [10.5, 9.5])
    head(p, (1, -114))
    p.poly(chaikin([(-1, -109), (8, -110), (10, -104), (7, -100), (1, -100)], 2))
    p.ellipse((0, -124), 9.3, 10.0, 0, part=(math.pi, 2 * math.pi))
    p.ellipse((0, -121), 11.2, 3.8)
    # whip arm raised back, lash curling behind
    arm(p, (-5, -95), (-20, -110), (-28, -128))
    p.stroke([(-28, -128), (-25, -141)], 3.2, 2.6)
    lash = bezier((-25, -141), (-55, -180), (-104, -152), (-96, -108), 30) + \
        bezier((-96, -108), (-91, -86), (-66, -96), (-75, -110), 18)[1:]
    p.stroke(lash, 2.6, 0.8)
    # other arm pointing ahead at the hero
    arm(p, (3, -94), (17, -88), (32, -92))


sil.hero = hero
sil.rusher = rusher
sil.gunman = gunman
sil.overseer = overseer
sil.CAST = [
    (gunman, 1270, 420, True),
    (overseer, 1060, 505, True),
    (hero, 520, 560, False),
    (rusher, 800, 640, True),
]

if __name__ == "__main__":
    from PIL import Image, ImageDraw, ImageFont
    OUT = sil.OUT
    shots = []
    for v in (1, 2, 3):
        im = sil.compose(v)
        im.save(OUT + f"styl_A_variant{v}.png")
        shots.append(im)
    W, H = 760, 240
    frame = Image.new("RGBA", (W, H), (226, 214, 196, 255))
    for fn, x, flip in [(hero, 100, False), (rusher, 300, True),
                        (gunman, 490, True), (overseer, 670, True)]:
        mask, sash = sil.render_figure(fn, (x, 215), flip, size=(W, H))
        frame.paste(Image.new("RGBA", (W, H), sil.INK + (255,)), (0, 0), mask)
        if sash is not None:
            frame.paste(Image.new("RGBA", (W, H), sil.SASH + (255,)), (0, 0), sash)
    frame.convert("RGB").resize((W * 2, H * 2), Image.LANCZOS).save(OUT + "styl_A_postavy_zblizka.png")
    gw, gh = sil.VIEW_W // 2, sil.VIEW_H // 2
    grid = Image.new("RGB", (gw, gh * 3 + 16), (20, 20, 20))
    f = ImageFont.truetype("DejaVuSans-Bold.ttf", 40)
    for i, im in enumerate(shots):
        grid.paste(im.resize((gw, gh), Image.LANCZOS), (0, i * (gh + 8)))
        d = ImageDraw.Draw(grid)
        d.rectangle([10, i * (gh + 8) + 10, 60, i * (gh + 8) + 60], fill=(0, 0, 0))
        d.text((22, i * (gh + 8) + 12), str(i + 1), fill=(255, 255, 255), font=f)
    grid.save(OUT + "styl_A_mriezka.png")
    print("ok")
