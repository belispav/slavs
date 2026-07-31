# VOLYA — Project Memory (read this first)

You are the AI development partner for VOLYA, a 2D side-scrolling run-and-gun mobile game (Metal Slug style) built in **Godot 4.7 / GDScript** for **Android first**. The developer (Pavel) is a solo creator with **zero prior game-dev knowledge** — you write the code, he directs, tests on his phone, and learns by reading. Communicate in Slovak; code, comments and commit messages in English.

## Key documents in this folder

- `VOLYA_plan_hry.md` — full plan: game design, business case, phase plan (F0–F5), deployment, roadmap, risks. The scope defined there is FIXED.
- `SPEC_ovladanie_implementacia.md` — the control system spec + implementation addendum. This is the single source of truth for controls. Controls are the product; everything else comes second.
- `Phone controls instrucitons.txt` — original control philosophy document (superseded by the SPEC file, kept for reference).
- `F2P Monetization Strategies Analysis.md` — background research only; the game is PREMIUM (5,99 €), no IAP in v1.0, no ads, no gacha. Ever.
- `SETUP_F0.md` — Pavel's setup + testing guide (Godot, JDK 17, Android SDK, one-click USB deploy, F1 test protocol).
- `volya/` — the Godot 4.7 project itself. Scenes are built in code (`main.gd`); only `main.tscn` exists as a scene file. Control tunables live in `volya/config/control_config.tres`, gameplay constants in `volya/scripts/tuning.gd`.

## Design pillars (never violate)

1. **Overwhelming, absurd action.** 15–30 enemies on screen, generous hitboxes favoring the player, enemies die in 1–3 hits. No complex combat, no stealth, no puzzles.
2. **Zero thumb-lifting controls** per the SPEC. If a feature conflicts with the control scheme, the feature loses.
3. **Short sessions.** Levels 2–4 minutes. Instant restart.
4. **Fixed v1.0 scope** (plan §3.5): 12 levels, 8 enemy types, 3 bosses, meta-progression, endless arena. Anything beyond → suggest adding to the backlog section of the plan, do NOT implement.

## Content rules (hard constraints — store policy + project ethics)

- Setting: Slavic slave fighting slavers, 9th–10th century trade routes (v1.0).
- Enemies are ALWAYS defined by role/faction (slaver, raider, overseer, caravan guard, Varangian jarl…), NEVER by ethnicity or skin color — in code, art direction, names, strings, and store copy.
- No killable civilians. No religious symbols as targets. Stylized pixel violence, no realistic gore (target rating PEGI 16).
- The in-game codex cites real history with sources.

## Working rules

1. **Small tasks.** One feature per task. Never large rewrites without explicit approval.
2. **Green state discipline.** After every change: run on device/editor → works? → `git commit`. Never continue on a broken state. Git from day one.
3. **Explain as you go.** Pavel is learning — after each task, 2–3 sentences on what was done and why (in Slovak). No lectures.
4. **Weekly refactor.** When asked (or when a file exceeds ~300 lines), clean up before adding features.
5. **Performance target:** 60 fps on a ~150 € Android phone. Object pooling for enemies/projectiles from the start.
6. **Tunables in one place.** All gameplay constants (control thresholds, damage, speeds) in exported variables / a single config resource so Pavel can tune without code.

## Current status (update this section as you work)

- [x] Plan complete (`VOLYA_plan_hry.md`)
- [x] Control implementation spec complete
- [x] F1 control prototype WRITTEN (`volya/`)
- [x] F0: Godot runs, APK builds and runs on a Samsung SM-S731B. One-click deploy in the editor never appeared despite a provably correct setup (possible engine bug); the working loop is `tools/deploy_android.ps1` — export, install, launch, live logcat.
- [x] F1: GO. Controls work on device and Pavel is satisfied enough to move on.
  - The formal 10-minute protocol (SPEC PART C §1) was **deliberately waived by Pavel** — he had already played far more than that across tuning sessions. Last measured session: 111 gestures / 103 jumps / 0 unintended.
  - **Still open:** criterion 5, a second device with a different DPI. All tuning is in millimetres and verified only at 450 dpi. Pavel will test later; until then this is a live risk.
  - Values may still be revisited; nothing about them is frozen.
  - Working loop: `tools/deploy_android.ps1` (build stamp → export → install → launch → live logcat). The in-game panel tunes controls live; `VYPIS DO LOGU` prints all values to logcat. Values measured on device are committed to `control_config.tres` — never change them by guessing.
  - Corrections found on hardware, all recorded in the SPEC with reasons: threshold is a DOME not a valley; the curve is ASYMMETRIC (thumb reach differs inward vs outward) and is parameterised by real thumb reach in mm, not by a dx² coefficient; sliding anchor on the aim stick; jump buffering (0.14 s) because gestures made just before landing were being discarded.
  - Open: Pavel still converging on final values. Unintended jumps: none observed. Missed jumps: improving. HUD shows gesture / performed / swallowed counts.
  - **v1.0 requirement discovered here:** left/right-handed switch, because the arc asymmetry depends on which hand holds the phone.
  - Google Play account deferred ~1 month before testing.
- [x] Graphics direction decided: 3D in Blender → pre-rendered 2D sprites (see `GRAFIKA_test_pipeline.md`, `tools/blender_render_sprites.py`). Chosen because frame-to-frame consistency is structural, and the budget is 0 €. Pipeline test passed on 2026-07-31: silhouette readable, Pavel comfortable with Blender. Character height should rise from 64 px to ~96 px; the in-game player box (54 units of 720) is also undersized versus the genre (~16 % of screen height ≈ 115) — fix after the F1 gate, not before.
  - Backgrounds may be generated externally (consistency does not matter there); animation frames may NOT.
  - Style references go in `ref/`, prompts in `ref/PROMPTY.md`.
- [ ] F2: vertical slice
- [ ] F3: content production
- [ ] F4: polish + closed testing (12 testers / 14 days — mandatory for new personal Google Play accounts)
- [ ] F5: launch
