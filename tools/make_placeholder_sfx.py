"""Synthesise PLACEHOLDER sound effects for the generic events (2026-10-04).

Not the final sounds - a way to hear the sound system working on the phone
before real samples (CC0 libraries, or recorded) exist. Every file is named
ph_*.wav so it is obvious what to delete once a real sound replaces it.

Writes 16-bit mono WAVs into slavs/audio/sfx/<event>/:
    gunshot, axe_throw, enemy_hit, enemy_death, barrel_hit, barrel_break,
    cauldron_whistle, explosion
Voices (hero_hurt, rusher_shout, barks...) are NOT made here - a synthesised
voice is worse than none.

    python tools/make_placeholder_sfx.py
"""
import os
import wave

import numpy as np

RATE = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "slavs", "audio", "sfx")


def t(sec):
    return np.arange(int(RATE * sec)) / RATE


def env(n, attack, decay):
    """Exponential decay after a short linear attack (both in seconds)."""
    x = np.arange(n) / RATE
    a = np.clip(x / max(attack, 1e-4), 0, 1)
    return a * np.exp(-x / decay)


def lowpass(x, cutoff):
    """One-pole low-pass, good enough for placeholders."""
    a = np.exp(-2 * np.pi * cutoff / RATE)
    y = np.zeros_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def bandpass(x, lo, hi):
    return lowpass(x, hi) - lowpass(x, lo)


def save(event, name, x, rng):
    x = x / (np.max(np.abs(x)) + 1e-9) * 0.9
    d = os.path.join(OUT, event)
    os.makedirs(d, exist_ok=True)
    with wave.open(os.path.join(d, name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((x * 32767).astype("<i2").tobytes())


def gunshot(rng):
    n = len(t(0.7))
    crack = rng.standard_normal(n) * env(n, 0.001, 0.05)
    boom = lowpass(rng.standard_normal(n), 300) * env(n, 0.002, 0.25) * 6
    thump = np.sin(2 * np.pi * 55 * t(0.7)) * env(n, 0.002, 0.12)
    return lowpass(crack, 5000) + boom + thump


def whoosh(rng):
    n = len(t(0.32))
    x = rng.standard_normal(n)
    shape = np.sin(np.pi * np.arange(n) / n) ** 2
    return bandpass(x, 400, 2500) * shape


def hit(rng, f):
    n = len(t(0.25))
    body = np.sin(2 * np.pi * f * t(0.25)) * env(n, 0.001, 0.06)
    slap = lowpass(rng.standard_normal(n), 2500) * env(n, 0.0005, 0.02)
    return body * 1.5 + slap


def death(rng):
    n = len(t(0.5))
    thud = np.sin(2 * np.pi * 70 * t(0.5)) * env(n, 0.003, 0.15)
    rustle = lowpass(rng.standard_normal(n), 1200) * env(n, 0.01, 0.12)
    return thud * 1.5 + rustle * 0.8


def knock(rng):
    n = len(t(0.3))
    x = np.zeros(n)
    for f, d in ((420, 0.05), (930, 0.03), (1650, 0.02)):
        f *= rng.uniform(0.93, 1.07)
        x += np.sin(2 * np.pi * f * t(0.3)) * env(n, 0.0005, d)
    return x + lowpass(rng.standard_normal(n), 3000) * env(n, 0.0003, 0.008)


def crack(rng):
    n = len(t(0.8))
    x = np.zeros(n)
    for _ in range(7):
        at = int(rng.uniform(0, 0.35) * RATE)
        k = knock(rng)[: n - at] * rng.uniform(0.4, 1.0)
        x[at:at + len(k)] += k
    splinter = bandpass(rng.standard_normal(n), 800, 6000) * env(n, 0.001, 0.2)
    return x + splinter * 0.6


def whistle(rng):
    """A kettle whistle, one second, meant to LOOP (the game bends its pitch)."""
    n = len(t(1.0))
    x = t(1.0)
    f = 1400 + 25 * np.sin(2 * np.pi * 6 * x)
    tone = np.sin(2 * np.pi * np.cumsum(f) / RATE)
    hiss = bandpass(rng.standard_normal(n), 2000, 6000) * 0.25
    return tone * 0.6 + hiss


def explosion(rng):
    n = len(t(1.6))
    boom = lowpass(rng.standard_normal(n), 180) * env(n, 0.003, 0.5) * 8
    crack = lowpass(rng.standard_normal(n), 4000) * env(n, 0.001, 0.08)
    rumble = np.sin(2 * np.pi * 40 * t(1.6)) * env(n, 0.01, 0.6)
    return boom + crack + rumble


def main():
    rng = np.random.default_rng(7)
    for i in range(3):
        save("gunshot", f"ph_gunshot_{i}.wav", gunshot(rng), rng)
        save("axe_throw", f"ph_axe_throw_{i}.wav", whoosh(rng), rng)
        save("enemy_hit", f"ph_enemy_hit_{i}.wav", hit(rng, rng.uniform(110, 160)), rng)
        save("barrel_hit", f"ph_barrel_hit_{i}.wav", knock(rng), rng)
    for i in range(2):
        save("enemy_death", f"ph_enemy_death_{i}.wav", death(rng), rng)
        save("barrel_break", f"ph_barrel_break_{i}.wav", crack(rng), rng)
    save("cauldron_whistle", "ph_whistle.wav", whistle(rng), rng)
    for i in range(2):
        save("explosion", f"ph_explosion_{i}.wav", explosion(rng), rng)
    print("placeholders written to", os.path.normpath(OUT))


if __name__ == "__main__":
    main()
