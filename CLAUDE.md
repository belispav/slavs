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
- [x] F1 control prototype WRITTEN (`volya/`) — not yet run on hardware
- [ ] F0: Godot installed, project runs on PC, APK on device (`SETUP_F0.md` is the step-by-step guide; Google Play account deferred ~1 month before testing)
- [ ] F1: control prototype VALIDATED on device (GO/NO-GO milestone — acceptance criteria in SPEC PART C)
- [ ] F2: vertical slice
- [ ] F3: content production
- [ ] F4: polish + closed testing (12 testers / 14 days — mandatory for new personal Google Play accounts)
- [ ] F5: launch
