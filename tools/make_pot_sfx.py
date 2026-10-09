"""Placeholder sounds for the ceramic pot (2026-10-09): pot_hit and pot_break.

Same idea as make_placeholder_sfx.py (files are named ph_*.wav; replace them with real
samples later). Run:  python tools/make_pot_sfx.py
"""
import numpy as np

import make_placeholder_sfx as m

RATE = m.RATE


def tink(rng):
    """A glazed pot knocked: a dull tick plus a few short ringing partials."""
    n = len(m.t(0.28))
    x = m.bandpass(rng.standard_normal(n), 800, 5000) * m.env(n, 0.0003, 0.012) * 1.5
    for f, d in ((1650, 0.07), (2480, 0.05), (3900, 0.035)):
        f *= rng.uniform(0.93, 1.07)
        x += np.sin(2 * np.pi * f * m.t(0.28)) * m.env(n, 0.0004, d)
    return x


def smash(rng):
    """Pot breaking: one crack, then a scatter of small shards clinking."""
    sec = 0.8
    n = len(m.t(sec))
    x = m.bandpass(rng.standard_normal(n), 600, 7000) * m.env(n, 0.0005, 0.09) * 2.0
    x += np.sin(2 * np.pi * 180 * m.t(sec)) * m.env(n, 0.002, 0.05)
    for _ in range(rng.integers(9, 15)):
        start = int(rng.uniform(0.02, 0.55) * RATE)
        f = rng.uniform(1800, 5200)
        d = rng.uniform(0.02, 0.06)
        m_n = n - start
        clink = np.sin(2 * np.pi * f * m.t(sec)[:m_n]) * m.env(m_n, 0.0003, d)
        x[start:] += clink * rng.uniform(0.2, 0.7)
    return x


def main():
    rng = np.random.default_rng(21)
    for i in range(3):
        m.save("pot_hit", f"ph_pot_hit_{i}.wav", tink(rng), rng)
    for i in range(2):
        m.save("pot_break", f"ph_pot_break_{i}.wav", smash(rng), rng)
    print("pot placeholders written")


if __name__ == "__main__":
    main()
