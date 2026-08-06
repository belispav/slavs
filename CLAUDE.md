# VOLYA — Project Memory (read this first)

You are the AI development partner for VOLYA, a 2D side-scrolling run-and-gun mobile game (Metal Slug style) built in **Godot 4.7 / GDScript** for **Android first**. The developer (Pavel) is a solo creator with **zero prior game-dev knowledge** — you write the code, he directs, tests on his phone, and learns by reading. Communicate in Slovak; code, comments and commit messages in English.

## Key documents in this folder

- `PRIKAZY.md` — **the command cheat sheet.** Deploy, render, the character
  pipeline, troubleshooting. Pavel does not memorise commands; put anything he
  will need to type again in here.

- `VOLYA_plan_hry.md` — full plan: game design, business case, phase plan (F0–F5), deployment, roadmap, risks.
- `DIZAJN_core_loop.md` — **supersedes the plan's §3.2 and §3.5 on game structure.** The game is a run-based score attack, not 12 handcrafted levels. Cage encounters are the core mechanic and the currency source. Read this before designing anything about levels, progression or economy. The plan's §2 (sensitive topic) is untouched and remains absolute.
- `SPEC_ovladanie_implementacia.md` — the control system spec + implementation addendum. This is the single source of truth for controls. Controls are the product; everything else comes second.
- `Phone controls instrucitons.txt` — original control philosophy document (superseded by the SPEC file, kept for reference).
- `F2P Monetization Strategies Analysis.md` — background research only; the game is PREMIUM (5,99 €), no IAP in v1.0, no ads, no gacha. Ever.
- `SETUP_F0.md` — Pavel's setup + testing guide (Godot, JDK 17, Android SDK, one-click USB deploy, F1 test protocol).
- `volya/` — the Godot 4.7 project itself. Scenes are built in code (`main.gd`); only `main.tscn` exists as a scene file. Control tunables live in `volya/config/control_config.tres`, gameplay constants in `volya/scripts/tuning.gd`.

## Design pillars (never violate)

1. **Overwhelming, absurd action.** 15–30 enemies on screen, generous hitboxes favoring the player, enemies die in 1–3 hits. No complex combat, no stealth, no puzzles.
2. **Zero thumb-lifting controls** per the SPEC. If a feature conflicts with the control scheme, the feature loses.
   - Consequence discovered on device: **the left thumb physically covers the left third of the screen.** Lethal threats must never arrive from the left — the player cannot see them. Enemies advance from the right. This constrains level design, spawn logic and boss arenas for the whole game.
3. **Short sessions.** Levels 2–4 minutes. Instant restart.
4. **Fixed v1.0 scope** (plan §3.5): 12 levels, 8 enemy types, 3 bosses, meta-progression, endless arena. Anything beyond → suggest adding to the backlog section of the plan, do NOT implement.

## Content rules (hard constraints — store policy + project ethics)

> **OPEN, must close before F3.** The tuning-stage enemy art (`ref/objects/Enemy_rusher_01`, `Enemy_gunman_01`) breaks the ethnicity rule below — both wear turbans, one has glowing red eyes. Pavel is aware, has a parallel review of Google Play policy running, and is knowingly using them as **tuning assets only**. Raised once, recorded here, not to be re-litigated in every session.
>
> What has to happen before any of it ships: regenerate with the ethnic markers replaced (fur cap, hood, helmet, brimmed hat instead of turban; no glowing eyes) and cross-check art, names, strings and store copy against the policy review. The silhouettes and role reads are good and should be kept — the coiled whip and the bandolier both say what the enemy is at a glance.
>
> The cost of leaving it later than F3: eight enemy types modelled, rigged, rendered and balanced on art that has to be thrown away.

- **Setting: 15th century Eastern Europe** — an escaped Slavic slave fighting slavers on the raid routes of the "harvest of the steppe". **Decided; do not re-open it and do not revert it to the 9th–10th century.** The plan (`VOLYA_plan_hry.md` §1.2, §3.1) still describes the 9th–10th century era because it was written first; the 15th century wins wherever they disagree. Consequences that follow from the era, and are therefore correct, not anachronisms: firearms exist (arquebus, hand cannon), plate and mail both appear, and the raid captains are Crimean/Nogai/Ottoman rather than Varangian.
- Enemies are ALWAYS defined by role/faction (slaver, raider, overseer, caravan guard, raid captain…), NEVER by ethnicity or skin color — in code, art direction, names, strings, and store copy.
- No killable civilians. No religious symbols as targets. Stylized pixel violence, no realistic gore (target rating PEGI 16).
- The in-game codex cites real history with sources.

## Working rules

1. **Small tasks.** One feature per task. Never large rewrites without explicit approval.
2. **Green state discipline.** After every change: run on device/editor → works? → `git commit`. Never continue on a broken state. Git from day one.
3. **Explain as you go.** Pavel is learning — after each task, 2–3 sentences on what was done and why (in Slovak). No lectures.
3b. **Anything about framing, sizes or proportions: draw it first.** `tools/preview_framing.py` composites the real background, the real sprite and the real camera arithmetic into a picture of the finished shot. Five rounds were lost describing framing in numbers, each making it worse, because a number cannot say whether the water is on screen. Produce the picture, agree on it, then build.
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
- [x] Graphics direction decided: 3D in Blender → pre-rendered 2D sprites (see `GRAFIKA_test_pipeline.md`, `tools/blender_render_sprites.py`). Chosen because frame-to-frame consistency is structural, and the budget is 0 €. Pipeline test passed on 2026-07-31: silhouette readable, Pavel comfortable with Blender.
  - Backgrounds may be generated externally (consistency does not matter there); animation frames may NOT.
  - Style references go in `ref/`, prompts in `ref/PROMPTY.md`.
- [x] Style decided (2026-08-02): **pixel art, reached from 3D**, not hand-placed. The 18 scene references are all one style — detailed hand-placed pixel art — which this pipeline cannot reproduce directly. It gets close, and the measured requirement is that the flat colour areas must be produced **in Blender**; post-processing a normal render into pixel art was tried and does not work. S2 (pre-rendered, softer) stays as the fallback if this fails on device.
  - Blender side: `--toon` rebuilds materials as flat colour with hard bands of light; `--pixel` disables anti-aliasing; textures are shrunk to 48 px first, because a 2048 px texture sampled onto a 96 px sprite is noise, not detail (it took lone-pixel removals from 476 to 5261 and measured crawl from 39 % to 62 %).
  - Python side: `tools/pixelize_sprites.py` — hard alpha, one shared palette for the whole animation, despeckle, 1 px outline, and a pixel-crawl measurement. The crawl thresholds in it are **guesses, not measurements** — Pavel's eye overrules them.
  - **30 fps chosen on device** over 15 and 10; both lower rates read as choppy on a 17-frame cycle.
  - Sprite height moving 96 → 128. The hitbox stays 30×54 on purpose: a body narrower than the drawing is what design pillar 1 means by favouring the player.
- [x] Character pipeline settled: **image → 3D (Meshy) → Mixamo auto-rigger → our render**. Modelling by hand is weeks of learning and was rejected. This suits the project unusually well — the standard objection to AI meshes is topology and detail, and neither survives 96 px. Documented step by step in `POSTUP_vlastna_postava.md`.
  - **Hard-won: the export must carry a UV map.** Meshy's FBX has none; its GLB does. Without one there is nowhere on the body for a texture to land and the character is grey forever, and the fault only shows up four steps downstream. `tools/inspect_fbx.py` now refuses to call a model fine without UVs.
  - The T-pose rules in `POSTUP_vlastna_postava.md` are not stylistic. A character holding a weapon, wearing a cape or with a dangling chain fails the auto-rigger two steps later.
  - Meshy free tier cannot download Meshy 6 models; Meshy 5 works. **Licence decision still open**: free tier is CC BY 4.0 and obliges a credit line. Decide before the game is built on it.
  - Hitem3D was tried as an alternative: 1,014,241 vertices and 242 MB against Meshy's 41,963 and 2.6 MB. Reduced and parked, not rigged.
- [x] First real character is in the game and rendering in colour (2026-08-02). Player draws whatever sequence sits in `volya/art/run_px/`, so swapping characters means re-rendering that folder and nothing else. Grey box remains the fallback.
- [x] **DECIDED 2026-08-03: free movement, no jumping.** Played back to back against the platform version on device — "plošinovka a skoky sú o ničom". The left thumb drives both axes, there is no gravity and no jump. This is now the default in `control_config.tres`; the jump code stays behind the toggle but nothing new should be built on it.
  - Consequences already taken: six of the ten tuning sliders served the jump flick and are no longer built. Jump-through platforms are not built either — without a jump they are unreachable scenery.
  - **Still to do: re-render sprites from a slightly raised camera.** The genre draws characters from slightly above so the floor reads; ours are strict side view. It is one parameter in the render script, but it must be decided **before** eight enemy types are produced, not after.
  - Enemies come **only from the right** regardless — forced by the left thumb covering the left third of the screen, not by the genre. Rushers close from the right, stop a short gap short and press; a hard limit keeps every enemy right of the player.
  - Open sub-question: movement as a stick (hold an offset, keep walking) versus copying the thumb (stop the thumb, stop the character). Follow is preferred on first play but not settled. Its cost is real — it runs out of thumb before it runs out of level.
  - **Playing field:** the bottom is fixed (ground, wall, river get drawn there) and the playable area reaches **1.5 screen heights upward**, so the camera travels vertically. A band shorter than the screen is used up in a second by a 130-unit character and leaves nowhere to put the feet of an enemy or the bottom of a cage. Higher than 1.5 and nothing on screen tells you where anything else is. For frozen boss arenas Pavel wants the same idea: **+50 % up, +20 % right** — more vertical than horizontal, because the character is taller than it is wide.
  - Death no longer sends the player back to the start; it costs health and a moment. Being restarted constantly made it impossible to settle into a run.
- [x] **Free movement built and playing well (2026-08-06).** Enemies only from the right, rushers close and press, throwers hold their own range. Death costs health, not the run. Player health 5. All control values in `control_config.tres` are measured on device — never change them by guessing.
- [x] **Background pipeline works.** `env_03` is in the game, drawn 1:1 and tiled horizontally on the GPU, so level length costs nothing. The playing field is taken **from the picture** (`BG_WALK_TOP` / `BG_WALK_BOTTOM` in `main.gd`), not from screen fractions — that was the source of a long argument that only ended when the shot was drawn instead of described.
  - **Scale is stated in the prompt now:** the character is 121 px for 1.8 m, so 1 m = 67 px. Without it, generators draw waist-high grass and the hero looks like a dwarf on his own field.
  - The camera follows vertically, clamped to the picture. Each boundary — palisade behind, river in front — comes into view at full height as the character walks toward it. They do not need to be on screen together.
- [ ] **Enemy art and weapons in progress.** Weapons attach to the hand bone in Blender **after** rigging (`tools/blender_attach_weapon.py`, has arquebus / club / spear / sword / bow), because Mixamo refuses to rig a model holding anything — and the animation has to match the weapon, so a rifle needs a rifle animation.
  - **Rusher: done through Mixamo.** Three animations in `ref/characters/`: `Great Sword Idle`, `Walking`, `Standing Melee Attack Downward`. All verified — 35 bones, UV map present, textures embedded.
  - **The rusher's club is two-handed (1.25 m), decided 2026-08-06.** The Great Sword animations put both hands on a shaft, so a 0.72 m one-handed club left the left hand closing on air. Lengthening the club was chosen over re-downloading three animations. Do not shorten it back without swapping to one-handed animations at the same time.
  - **Open: `Walking` is probably the wrong cycle for a rusher** — a rusher closes and presses, and a walk reads too slow. `Great Sword Run` is the replacement to try.
  - **Gunman: model is clean and ready for Mixamo** (`ref/objects/Enemy_gunman_01_mixamo.fbx`, 95 790 vertices, UV map present, 0 skins as it should be). No animations yet. It carries an **arquebus** — correct for the 15th century, not an anachronism.
  - Housekeeping: `ref/objects/*" - Copy".glb` are duplicates (~28 MB) and `ref/characters/Hitem3d-1785662322779.fbx` is 242 MB. Do not let them into git.
- [ ] **Still missing an `idle` animation for the hero.** Without it the character freezes mid-stride when standing. Render it to `volya/art/idle_px/` and the game picks it up by itself.
- [ ] F2: vertical slice
- [ ] F3: content production
- [ ] F4: polish + closed testing (12 testers / 14 days — mandatory for new personal Google Play accounts)
- [ ] F5: launch
