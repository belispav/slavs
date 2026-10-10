"""Placeholder warning sounds (package 3, D4, 2026-10-10): one event folder per enemy type.
  warn_rusher  - a short rising grunt as the club goes up
  warn_thrower - two metallic clicks (the arquebus being cocked)
  warn_brute   - a low growl
Files are named ph_*.wav; replace them with real samples later (everything is a prototype
until final tuning). Run:  python tools/make_warn_sfx.py
"""
import numpy as np

import make_placeholder_sfx as m

RATE = m.RATE


def grunt(rng):
    sec = 0.3
    n = len(m.t(sec))
    f = np.linspace(rng.uniform(150, 190), rng.uniform(300, 380), n)
    tone = np.sin(2 * np.pi * np.cumsum(f) / RATE)
    breath = m.bandpass(rng.standard_normal(n), 400, 2200)
    shape = np.sin(np.pi * np.arange(n) / n) ** 1.5
    return (tone * 0.8 + breath * 1.2) * shape


def click_click(rng):
    sec = 0.4
    n = len(m.t(sec))
    x = np.zeros(n)
    for at in (0.0, rng.uniform(0.11, 0.16)):
        s = int(at * RATE)
        k = n - s
        f = rng.uniform(2100, 2700)
        tick = np.sin(2 * np.pi * f * m.t(sec)[:k]) * m.env(k, 0.0003, 0.02)
        tick += m.bandpass(rng.standard_normal(k), 1500, 7000) * m.env(k, 0.0002, 0.008) * 1.5
        x[s:] += tick * (1.0 if at == 0.0 else 0.8)
    return x


def growl(rng):
    sec = 0.55
    n = len(m.t(sec))
    base = rng.uniform(62, 78)
    f = base + 8 * np.sin(2 * np.pi * 7 * m.t(sec))
    tone = np.sin(2 * np.pi * np.cumsum(f) / RATE) * (0.6 + 0.4 * np.sin(2 * np.pi * 28 * m.t(sec)))
    rasp = m.lowpass(rng.standard_normal(n), 900) * 1.3
    shape = np.sin(np.pi * np.arange(n) / n) ** 1.2
    return (tone * 1.5 + rasp) * shape


def main():
    rng = np.random.default_rng(33)
    for i in range(3):
        m.save("warn_rusher", f"ph_warn_rusher_{i}.wav", grunt(rng), rng)
        m.save("warn_thrower", f"ph_warn_thrower_{i}.wav", click_click(rng), rng)
    for i in range(2):
        m.save("warn_brute", f"ph_warn_brute_{i}.wav", growl(rng), rng)
    print("warning placeholders written")


if __name__ == "__main__":
    main()
