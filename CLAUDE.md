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

## Sessions and which model to use

Credits are a real constraint. **One session, one subject** — do not start a
second topic in a session that already has one open; it costs a re-read of the
whole context and it is how a day turns into twenty rounds about a club.

**Sonnet is the default.** It is enough whenever the path is already written
down and the work is following it:

- producing an enemy by `PRIKAZY.md` (fit the weapon, measure the grip, pick
  from grids, render) — the method is settled, only the answers change
- small self-contained changes: one script, one scene, a few tunables, a HUD
  toggle
- renders, measurements, grids, commits, deploys

**Switch to Opus when:**

- something in the pipeline breaks in a way nobody understands yet, and it
  needs several wrong hypotheses discarded before the right one
- a decision touches many files at once, or changes what a system *is*
  (controls, core loop, economy, the sensitive-topic rules)
- the plan or the design pillars are being changed rather than followed

If a Sonnet session hits three rounds without progress on the same problem,
that is the signal to stop and bring it to Opus rather than keep pushing.

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
- [x] **Gunman is finished and in the game** (2026-08-07) — idle / walk / fire, arquebus in hand, wired in as the THROWER in `enemy.gd`. Other enemy types stay coloured boxes until they have art, and the box is still the fallback if a folder is empty.
  - The arquebus is a **downloaded CC0 model** (`ref/objects/arkebuza_cgtrader.blend`), not one built from primitives. The built ones remain in `blender_attach_weapon.py` and still work.
  - Everything decided about him lives in `art/fits/gunman.settings.json`; the placements live in `gunman.json`, `gunman_walk.json`, `gunman_fire.json`. **They are separate files on purpose** — they used to share one and saving a placement wiped the weapon model, which showed up as an unarmed man three renders later.
  - His idle turns the character away between frames 158 and 290, so it is cut to **19–157**. Every Mixamo idle so far does this; check before rendering a full clip.
  - Open: Pavel is not fully sure about the weapon's position in the idle. It is good enough to test with.
- [x] **Debug test panel (2026-08-07), tested by Pavel and working.** `debug_state.gd` (new autoload `Debug`) holds three switches, never allowed to ship and never touching `control_config.tres`: `god_mode`, `disable_rusher`, `disable_thrower`. The panel's TEST section also has PAUZA, wired straight to `get_tree().paused` — the panel itself is `PROCESS_MODE_ALWAYS` so it stays usable while the rest of the tree freezes. Turning a kind off despawns any of that kind already on screen instead of waiting for it to die off, so the effect is immediate.
- [x] **Enemy awareness split from combat readiness (2026-08-07), designed and coded, not yet on art or device.** Caught on the gunman: it plays its "looking around" idle between shots, but it is actively firing at the player at that point, which reads as an enemy that has not noticed someone it is shooting at. The idle a character shows has to match what it *knows*, not just whether it is moving.
  - **General rule for every future enemy type:** two different idles, not one. An **unaware** idle (looking around, on guard against nothing in particular) for before it has noticed the player, and a **ready** idle (weapon up, watching) for the gaps between attacks once it has. Reusing one clip for both is the mistake that shipped on the gunman.
  - **Not fixed on the gunman yet** — open backlog item, not urgent, not re-litigated here. Its current idle stays as the unaware one; it needs a second, alert idle clip and the same wiring the rusher is getting below.
  - **Built into `enemy.gd` for the rusher first**, since it has no art yet and is the cleanest place to try the mechanic. New state: `_aware` (bool, sticky — once it notices the player it does not go back to looking around), driving four clips: `idle_unaware` → `walk` (closing in) → `attack` → `idle_ready` (between swings). Detection range is `Tuning.enemy_detection_range`, live-tunable on the panel, default 640 px = half the 1280 px screen, per Pavel's ask. `RUSHER_ATTACK_INTERVAL` / `RUSHER_ATTACK_ANIM_TIME` in `tuning.gd` drive the attack/ready cycle once in melee range.
  - **Cosmetic only so far:** contact damage still comes from the hurtbox touching the player continuously, not from the attack animation landing a hit. Whether a swing should carry its own damage beat instead of continuous contact damage is open — not decided, would change the combat feel and is worth trying once the art exists to see it properly.
  - `_build_sprite()` in `enemy.gd` now builds both the thrower's and the rusher's `AnimatedSprite2D` up front (whichever folders are empty come back null and the box fallback still applies), and `spawn()` picks which one to show. Same box-fallback rule as always: nothing here needs art to exist before it works.
  - **Still needed before this can be seen in-game:** a rendered `idle_unaware`, `idle_ready`, `walk`, `attack` set for the rusher. The already-downloaded `Great Sword Idle` covers `idle_unaware` (it is the "looking around" clip — correct for that state). `idle_ready` needs a second Mixamo clip Pavel has not picked yet: an alert/en-garde stance, weapon up, not looking around. Search Mixamo's greatsword-compatible idles for one and verify the grip with `inspect_grip.py` before rendering, same as every other clip.
- [x] **Contact damage replaced with a swing, on the rusher (2026-08-07), tested working on device.** Caught by Pavel straight after the awareness split went in: the rusher was stopping pressed against the player (`ENEMY_STOP_GAP` = 26 px), which read as a shove, not a swing — wrong the moment the character is drawn holding a club out in front of itself.
  - `ENEMY_STOP_GAP` retired, replaced by `Tuning.rusher_melee_range` (const `RUSHER_MELEE_RANGE` = 70, live on the panel). How close a rusher stops is now meant to read as weapon reach. **70 is a placeholder, not measured** — Pavel's own words: it depends on how the club animation actually looks. Do not treat it as settled; watch the render and move the slider, the same as everything else under METHOD rule 2.
  - Enemy.gd gained `melee_hit(from_pos)`, emitted by `_update_attack_timer` the instant a swing triggers (same beat that starts the `attack` clip) — the hit is not tied to bodies touching at all any more. `main.gd` wires it straight to `player.take_damage()`.
  - Player's old hurtbox-contact damage (`_on_body_touched`) still exists but now skips anything where `is_melee_kind()` is true, via duck typing — no other kind is melee yet, so this only changes the rusher.
  - **Open, not decided:** the swing currently lands damage at the moment the attack animation *starts*, not part-way through where the club would actually reach the player. That timing is a guess until the render exists to look at.
- **METHOD, learned the hard way today. Do not go back on this.**
  1. **Anything about a picture is decided from a picture.** Never describe a position, an angle or a colour in words and ask for a judgement. Render the options, lay them out numbered with `make_grid.py`, let Pavel say a number. Twenty rounds were lost before this was accepted.
  2. **Anything about a number is measured, never guessed.** `inspect_grip.py` says whether an animation really holds a weapon (Mixamo names lie). `best_frame.ps1` says which frame shows the weapon best (a frame with 64 visible pixels was used to judge a weapon that reaches 137 in a better one). `count_weapon.py` counts.
  3. **The weapon is placed with the mouse in Blender**, via `fit_weapon.ps1`, and read back with `save_fit.ps1`. The placement is stored against the hand bone, so one fitting covers every animation of that character. Per-animation files exist for the cases where it genuinely differs.
  4. **A tool that ends in "look at these" must produce the picture itself.** Leaving that as a manual step is how "write hotovo and wait" crept in.
  5. **Check colour contrast against the background when generating any character.** Not a one-off note, a standing rule: an enemy or the hero close in colour to what is behind them reads as blending in, not as camouflage — it reads as broken.
- [ ] **Backlog, raised by Pavel 2026-08-07, not urgent except where marked.**
  1. **Player hurtbox bug, root-caused but not fixed.** Enemy bullets miss the top of the player and hit the bottom — confirmed on device. Cause: enemy bullets are hostile Area2Ds that check `body_entered` against the player's plain movement `CollisionShape2D` (`SIZE = Vector2(30, 54)`, set once in `player.gd _ready()` and never resized), not against the correctly-fitted `_hurt_shape` that `_fit_hurtbox()` already sizes to the real drawn art. That fitted hurtbox has `collision_layer = 0`, so nothing can detect it as an Area at all right now — it only ever detects enemies touching it, it is never itself the target. The fix is to give the player's hurtbox a real collision layer and switch `bullet.gd`'s hostile-shot handling from `body_entered` to `area_entered`, mirroring exactly how the player's own shots already hit enemies through their `_hurtbox` Area. Also worth a look while in there: `_fit_hurtbox()` is handed `drawn_height = height - bottom_margin`, which does not subtract the empty margin at the *top* of the frame, so the box is a little taller and a little lower than the character actually is — secondary to the layer bug above, fix both at once.
  2. **DONE where it matters right now: enemy size.** Gunman and rusher read small next to the hero. Measured 2026-08-07 (see PRIKAZY.md's ZBRANE step 3): hero's drawn height is ~120 px at `-Height` ~162; gunman came out ~97 px because its render reused PRIKAZY.md's old example value, `-Height 128` — a stale doc value, not a deliberate size choice. PRIKAZY.md's example is corrected now. For the rusher render: use `-Height` ~175–185 (a bit taller than the hero, per Pavel's ask), then measure the actual result and adjust — do not trust this number blindly, it is a starting point from a measured ratio, not a final one. Gunman himself is not being re-rendered today; re-rendering him at `-Height` ~162 is backlog.
  3. **Environment reads static.** Either add moving elements (water, sky — real work) or borrow Metal Slug's cheaper trick: a near layer (grass / the walkable strip) scrolls at a different rate than the far background, which reads as movement on its own. Not started.
  4. **Background vs. character resolution mismatch.** The background was assumed to already be at the ceiling of usable detail, but the rendered characters (gunman, rusher) are noticeably more detailed than it is, so they sit oddly on top of it. Two directions, not chosen between yet: sharpen the background, or pixelize the characters down to the background's level.
- [ ] **Rusher: animations ready, art not started.** `Enemy_rusher_02 Great Sword Idle / Run / Slash` — all three measured two-handed (26–44 cm), which the first set was not. Needs its own fit, colours and render, by the method above. Now also needs a fourth clip for `idle_ready` — see the awareness entry above — before the fit step, so `inspect_grip.py` can check all four at once.
  - **Weapon decision: use our own club (`--weapon club`, 1.25 m, already sized for a two-handed grip), not a downloaded model.** It is already correct for the animations on hand, costs no licence check or import risk, and at a 96 px sprite a finer mesh would not read anyway — the same reasoning that made AI mesh topology a non-issue applies to a nicer club model. Revisit only if the primitive club looks wrong in the actual pixel-art render; that is a render-and-look decision, not one to make in words now.
- [ ] **Enemy art and weapons in progress.** Weapons attach to the hand bone in Blender **after** rigging (`tools/blender_attach_weapon.py`, has arquebus / club / spear / sword / bow), because Mixamo refuses to rig a model holding anything — and the animation has to match the weapon, so a rifle needs a rifle animation.
  - **Rusher: done through Mixamo.** Three animations in `ref/characters/`: `Great Sword Idle`, `Walking`, `Standing Melee Attack Downward`. All verified — 35 bones, UV map present, textures embedded.
  - **The rusher's club is two-handed (1.25 m), decided 2026-08-06.** The Great Sword animations put both hands on a shaft, so a 0.72 m one-handed club left the left hand closing on air. Lengthening the club was chosen over re-downloading three animations. Do not shorten it back without swapping to one-handed animations at the same time.
  - **Open: `Walking` is probably the wrong cycle for a rusher** — a rusher closes and presses, and a walk reads too slow. `Great Sword Run` is the replacement to try.
  - **Gunman: done through Mixamo too.** Three animations in `ref/characters/`: `Rifle Idle`, `Rifle Walk`, `Firing Rifle`. All verified — 53 bones, UV map present, textures embedded. They match the **arquebus**, which is correct for the 15th century and not an anachronism.
  - Next for both: attach the weapon in Blender (`blender_attach_weapon.py --weapon club` / `--weapon arquebus`), render to `volya/art/`, then tune the offsets **from the render**, never by reasoning.
  - Housekeeping: `ref/objects/*" - Copy".glb` are duplicates (~28 MB) and `ref/characters/Hitem3d-1785662322779.fbx` is 242 MB. Do not let them into git.
- [ ] **Still missing an `idle` animation for the hero.** Without it the character freezes mid-stride when standing. Render it to `volya/art/idle_px/` and the game picks it up by itself.
- [ ] F2: vertical slice
- [ ] F3: content production
- [ ] F4: polish + closed testing (12 testers / 14 days — mandatory for new personal Google Play accounts)
- [ ] F5: launch
