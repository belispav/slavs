# Slavs fight back — Project Memory (read this first)

> **NAME (Pavel, 2026-10-03): the game is "Slavs fight back", working name
> "Slavs".** The old AI-invented name was removed from the whole repo on
> 2026-10-03 (folder is now `slavs/`, Godot project name "Slavs fight back",
> `PLAN_hry.md`, docs, tools, Blender object names, env var `SLAVS_BLENDER`).
> Do not reintroduce it anywhere. **The ONE exception is the Android package
> id `sk.pavel.volya`** (`export_presets.cfg`, `deploy_android.ps1`,
> `get_tuning.ps1`, `SETUP_F0.md`): it never changes - a new id installs as a
> second app and loses the data on the phone.

You are the AI development partner for Slavs fight back, a 2D side-scrolling run-and-gun mobile game (Metal Slug style) built in **Godot 4.7 / GDScript** for **Android first**. The developer (Pavel) is a solo creator with **zero prior game-dev knowledge** — you write the code, he directs, tests on his phone, and learns by reading. Communicate in Slovak; code, comments and commit messages in English.

> **ALL GAME ART IS MADE IN PIXELLAB (since 2026-10-02) — Pavel's choice, and he is very happy with it.**
> Characters, their animations, props and effects are generated with the PixelLab
> MCP tools (`pixellab__*`, connected locally in Pavel's Claude app; frames download
> from `*.pixellab.ai`, which is allowlisted) and shown in game at an integer 2x.
> Do NOT go back to the old 3D chain (Meshy -> Mixamo -> Blender -> pixelize) or
> propose another generator unless Pavel asks. Method, costs and limits: section
> "Art pipeline switched to PixelLab" under Current status, and `PRIKAZY.md`
> -> "PIXELLAB". Backgrounds are the exception (too large for PixelLab) - keep
> making them the way env_08 was made.

## Key documents in this folder

- `ZACNI_TU_dalsia_session.md` — the starting prompt for the next session. Old prompts, the superseded 3D character pipeline and other finished documents are in `_archiv/`.

- `PRIKAZY.md` — **the command cheat sheet.** Deploy, render, the character
  pipeline, troubleshooting. Pavel does not memorise commands; put anything he
  will need to type again in here.

- `PLAN_hry.md` — full plan: game design, business case, phase plan (F0–F5), deployment, roadmap, risks.
- `DIZAJN_pozadie_a_rozlisenie.md` — **closed 2026-09-15** (Pavel satisfied with the parallax/background state; reopens only if he asks). Kept in the root because code comments point at it. Parallax for the static background, and unifying asset resolution between characters and background. Contains the measured facts, the decisions already made, the hard constraints, and the three questions only Pavel answers. Read it before touching anything about the background, `env_*`, sprite scale or texture filtering.
- `DIZAJN_core_loop.md` — **supersedes the plan's §3.2 and §3.5 on game structure.** The game is a run-based score attack, not 12 handcrafted levels. Cage encounters are the core mechanic and the currency source. Read this before designing anything about levels, progression or economy. The plan's §2 (sensitive topic) is untouched and remains absolute.
- `SPEC_ovladanie_implementacia.md` — the control system spec + implementation addendum. This is the single source of truth for controls. Controls are the product; everything else comes second.
- `_archiv/Phone controls instrucitons.txt` — original control philosophy document (superseded by the SPEC file, kept for reference).
- `_archiv/F2P Monetization Strategies Analysis.md` — background research only; the game is PREMIUM (5,99 €), no IAP in v1.0, no ads, no gacha. Ever.
- `SETUP_F0.md` — Pavel's setup + testing guide (Godot, JDK 17, Android SDK, one-click USB deploy, F1 test protocol).
- `slavs/` — the Godot 4.7 project itself. Scenes are built in code (`main.gd`); only `main.tscn` exists as a scene file. Control tunables live in `slavs/config/control_config.tres`, gameplay constants in `slavs/scripts/tuning.gd`.

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

- **Setting: 15th century Eastern Europe** — an escaped Slavic slave fighting slavers on the raid routes of the "harvest of the steppe". **Decided; do not re-open it and do not revert it to the 9th–10th century.** The plan (`PLAN_hry.md` §1.2, §3.1) still describes the 9th–10th century era because it was written first; the 15th century wins wherever they disagree. Consequences that follow from the era, and are therefore correct, not anachronisms: firearms exist (arquebus, hand cannon), plate and mail both appear, and the raid captains are Crimean/Nogai/Ottoman rather than Varangian.
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

## Cloud sessions (from 2026-10-03, see POSTUP_cloud_github.md)

Pavel is moving work to Claude Code cloud sessions on the private GitHub repo
**`belispav/slavs`** (branch `master`). In a cloud session:

- **Push to `master`** after the headless check passes, then tell Pavel
  "nasaď" with `git pull` + the deploy command. He only pulls; he does not
  merge branches or review PRs. Commits therefore come BEFORE his device
  test - a failed test is fixed forward with the next commit.
- **Check before every push:** `godot --headless --path slavs --import`,
  then run the scene with `--quit-after N` and a temporary test appended to
  a copy of the script (see the axe/barrel entry). `tools/cloud_setup.sh`
  installs Godot; `xvfb-run ... --rendering-driver opengl3` gives screenshots.
- **PixelLab:** `.mcp.json` points at `https://api.pixellab.ai/mcp`; the key
  is an environment API credential for `api.pixellab.ai` (Authorization:
  Bearer), never in the repo. If the MCP server does not come up, call the
  same API over HTTPS - the proxy attaches the key. Verify with get_balance
  at the start of the first cloud session.
- Things that are NOT in the repo: `tools/.pixellab_token`,
  `export_presets.cfg`, `ref/*.png`, `render/`. Deploy stays on Pavel's PC.

## Working rules

1. **Small tasks.** One feature per task. Never large rewrites without explicit approval.
2. **Green state discipline.** After every change: run on device/editor → works? → `git commit`. Never continue on a broken state. Git from day one.
3. **Explain as you go.** Pavel is learning — after each task, 2–3 sentences on what was done and why (in Slovak). No lectures.
3b. **Anything about framing, sizes or proportions: draw it first.** `tools/preview_framing.py` composites the real background, the real sprite and the real camera arithmetic into a picture of the finished shot. Five rounds were lost describing framing in numbers, each making it worse, because a number cannot say whether the water is on screen. Produce the picture, agree on it, then build.
4. **Weekly refactor.** When asked (or when a file exceeds ~300 lines), clean up before adding features.
5. **Performance target:** 60 fps on a ~150 € Android phone. Object pooling for enemies/projectiles from the start.
6. **Tunables in one place.** All gameplay constants (control thresholds, damage, speeds) in exported variables / a single config resource so Pavel can tune without code.

## Current status (update this section as you work)

- [x] Plan complete (`PLAN_hry.md`)
- [x] Control implementation spec complete
- [x] F1 control prototype WRITTEN (`slavs/`)
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
- [x] Graphics direction decided: 3D in Blender → pre-rendered 2D sprites (see `_archiv/GRAFIKA_test_pipeline.md`, `tools/blender_render_sprites.py`). Chosen because frame-to-frame consistency is structural, and the budget is 0 €. Pipeline test passed on 2026-07-31: silhouette readable, Pavel comfortable with Blender.
  - Backgrounds may be generated externally (consistency does not matter there); animation frames may NOT.
  - Style references go in `ref/`, prompts in `ref/PROMPTY.md`.
- [x] Style decided (2026-08-02): **pixel art, reached from 3D**, not hand-placed. The 18 scene references are all one style — detailed hand-placed pixel art — which this pipeline cannot reproduce directly. It gets close, and the measured requirement is that the flat colour areas must be produced **in Blender**; post-processing a normal render into pixel art was tried and does not work. S2 (pre-rendered, softer) stays as the fallback if this fails on device.
  - Blender side: `--toon` rebuilds materials as flat colour with hard bands of light; `--pixel` disables anti-aliasing; textures are shrunk to 48 px first, because a 2048 px texture sampled onto a 96 px sprite is noise, not detail (it took lone-pixel removals from 476 to 5261 and measured crawl from 39 % to 62 %).
  - Python side: `tools/pixelize_sprites.py` — hard alpha, one shared palette for the whole animation, despeckle, 1 px outline, and a pixel-crawl measurement. The crawl thresholds in it are **guesses, not measurements** — Pavel's eye overrules them.
  - **30 fps chosen on device** over 15 and 10; both lower rates read as choppy on a 17-frame cycle.
  - Sprite height moving 96 → 128. The hitbox stays 30×54 on purpose: a body narrower than the drawing is what design pillar 1 means by favouring the player.
- [x] ~~Character pipeline settled: **image → 3D (Meshy) → Mixamo auto-rigger → our render**.~~ **SUPERSEDED 2026-10-02 by PixelLab - see the banner at the top.** Kept for history. Modelling by hand is weeks of learning and was rejected. This suits the project unusually well — the standard objection to AI meshes is topology and detail, and neither survives 96 px. Documented step by step in `_archiv/POSTUP_vlastna_postava.md`.
  - **Hard-won: the export must carry a UV map.** Meshy's FBX has none; its GLB does. Without one there is nowhere on the body for a texture to land and the character is grey forever, and the fault only shows up four steps downstream. `tools/inspect_fbx.py` now refuses to call a model fine without UVs.
  - The T-pose rules in `_archiv/POSTUP_vlastna_postava.md` are not stylistic. A character holding a weapon, wearing a cape or with a dangling chain fails the auto-rigger two steps later.
  - Meshy free tier cannot download Meshy 6 models; Meshy 5 works. **Licence decision still open**: free tier is CC BY 4.0 and obliges a credit line. Decide before the game is built on it.
  - Hitem3D was tried as an alternative: 1,014,241 vertices and 242 MB against Meshy's 41,963 and 2.6 MB. Reduced and parked, not rigged.
- [x] First real character is in the game and rendering in colour (2026-08-02). Player draws whatever sequence sits in `slavs/art/run_px/`, so swapping characters means re-rendering that folder and nothing else. Grey box remains the fallback.
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
- [x] **Player hurtbox bug, fixed 2026-08-10, not yet redeployed.** Enemy bullets missed the top of the player and hit the bottom — confirmed on device, twice (Pavel re-raised it after the rusher's hits still felt wrong). Two bugs, fixed together:
  - **The real one:** enemy bullets checked `body_entered` against the player's plain movement `CollisionShape2D` (`SIZE = Vector2(30, 54)`, the F1 box, never resized to the drawn ~120 px art), not against the correctly-fitted `_hurtbox` Area. That Area had `collision_layer = 0` — detectable by nothing, so it only ever detected enemies touching it, never was itself a target. Fixed: `_hurtbox.collision_layer = Tuning.LAYER_PLAYER`, and `bullet.gd` now handles both directions through one `area_entered` handler (`"take_damage"` vs `"hit"` by `hostile`), the same way the player's own shots already hit enemies through their Area. `_on_body_entered` is gone.
  - **The secondary one:** `_fit_hurtbox()` was handed `drawn_height = height - bottom_margin`, which kept the empty rows *above the head* as if they were body. New `SpriteSequence.head_margin()` mirrors `foot_margin()` from the top edge; `drawn` in `player.gd` is now `height - foot_margin - head_margin`, the true head-to-feet extent.
  - **Side effect, needs a look on device:** `_muzzle_height` is computed from the same `drawn` value, and `MUZZLE_HEIGHT_FRACTION` (0.58) was calibrated on the *old, inflated* number. Measured on the hero's own frames: old `drawn` ≈ 141, new ≈ 121 — the muzzle point drops by about 11-12 units (world space). It may now sit visibly lower than "just above the hands". If so, `MUZZLE_HEIGHT_FRACTION` needs a fresh on-device measurement, the same way it was the first time.
  - **Pavel re-tested 2026-08-10: better (upper body now registers), but reported the bottom of the body still hits while the top ~5-10% still misses.** Measured every frame of `run_px` directly (17 frames): top gap 20-24 px, bottom gap 21-26 px, both averaging ~21-22 - the current formula is symmetric to within about 1 px, not the 5-10% reported. Could not find a code asymmetry to match what he is seeing; likely device-testing noise (iframes after a hit, the bullet's own hit radius padding the felt edge, or a faint anti-aliased pixel at the hairline reading as "still head" by eye but under the alpha threshold in the file). Rather than guess further from stills: `PLAYER_HURT_HEIGHT_FRACTION` is now also live (`Tuning.player_hurt_height_fraction`, panel slider "aky vysoky kus tela hraca sa da trafit"), and `player.gd` re-fits the hurtbox every physics frame from it, so Pavel can drag the margin tighter on the device itself and see immediately whether it still feels uneven. If it does, that is new information the file measurements did not show and is worth another look with fresh eyes rather than more guessing.
  2. **DONE where it matters right now: enemy size.** Gunman and rusher read small next to the hero. Measured 2026-08-07 (see PRIKAZY.md's ZBRANE step 3): hero's drawn height is ~120 px at `-Height` ~162; gunman came out ~97 px because its render reused PRIKAZY.md's old example value, `-Height 128` — a stale doc value, not a deliberate size choice. PRIKAZY.md's example is corrected now. For the rusher render: use `-Height` ~175–185 (a bit taller than the hero, per Pavel's ask), then measure the actual result and adjust — do not trust this number blindly, it is a starting point from a measured ratio, not a final one. Gunman himself is not being re-rendered today; re-rendering him at `-Height` ~162 is backlog.
  3. **Environment reads static** and **4. background vs. character mismatch** — both are now the live assignment. Everything about them, including the measurements that reframed them, is in **`DIZAJN_pozadie_a_rozlisenie.md`**. Do not re-derive it here; that document is the source of truth and the notes that used to sit at these two points were written before anything was measured and were wrong about the cause.
- [x] **Rusher: idle/walk/attack rendered and in `enemy.gd` (2026-08-08).** `Enemy_rusher_02 Great Sword Idle / Run / Slash` at `-Height 180`, fitted with our own club (`art/fits/rusher.json` + `rusher.settings.json`, `weapon: club`). Still needs a fourth clip for `idle_ready` — see the awareness entry above — before that gets its own fit and render.
  - **Weapon decision confirmed: our own club, not a downloaded model** — Pavel tried it first per the recommendation below and is continuing with it.
  - **Club reshaped 2026-08-08, then superseded the same day.** The primitive head was a `box`, replaced with a rounder cylinder plus smooth shading (kept — improves every weapon, arquebus included) — but the reshaped primitive still read as "3 valce nalepené na seba" (3 cylinders stuck together) once Pavel saw it rendered. **Switched to a downloaded model**, per the fallback that was always on the table: `ref/objects/Club/club.obj`, `rusher.settings.json` now points `weapon_model` at it instead of `weapon: club`. Its `.mtl` shipped with the original modeller's absolute Windows paths to the texture maps (`C:\Users\petr\Desktop\...`), which do not exist here — fixed by rewriting them to `maps/Club Diff.png` etc., relative to the `.mtl`, so the model's own texture loads instead of falling back to grey.
    - **The imported model came in about 70x too large** (`weapon_model` gets no automatic size normalisation the way our own weapons do — a downloaded mesh's own real-world unit scale is whatever its author used, then the same character-height-based multiplier that correctly scales our metre-authored primitives is applied on top). Fixed by hand in Blender with `S 0.013 Enter` as a numeric starting point, then fitted visually as normal. Nothing to do differently next time except expect it and start with a numeric scale guess rather than trying to drag-resize an object 70x the size of the character on screen.
    - Hands still do not fully close around the shaft in the Great Sword animations (both hands sit slightly off the mesh). Root cause unknown, likely a Mixamo rig quirk unrelated to Slavs's placement code. **Pavel: does not block, not revisited unless it reads badly once the club's own colour is decided** (deliberately last, per Pavel).
  - **Two real bugs found from watching the rendered animation in-game (2026-08-10), both fixed in `enemy.gd`, not yet redeployed:**
    1. **Attack animation was being cut short every time.** `RUSHER_ATTACK_ANIM_TIME` (0.35s) was a guess made before any art existed. The real `Great Sword Slash` render log says `frame range taken from animation: 1-39` — 39 frames at 30fps = 1.3s, more than triple the guess. The code was switching the sprite away from `attack` a third of a second into a 1.3s swing, every single time — which is exactly what "looks unfinished" was. Fixed with `_attack_anim_duration()`, which reads the real clip length from the rendered `SpriteFrames` instead of trusting the constant; the constant is now only a fallback for when there is no `attack` clip to measure yet.
    2. **A thrower that backs off to its preferred range kept firing with its back turned.** `flip_h` was only ever set from horizontal velocity ("Sprites are rendered facing left... flip when pushed right"), so once a thrower finished retreating (moving right, `flip_h = true`) and came to a stop to fire, nothing ever pointed it at the player again — it just kept the last direction it happened to be moving in. Fixed in `_drive_sprite`'s shared tail: below the walk-speed threshold, face the player directly instead of freezing on the last motion. Affects both kinds, though the rusher rarely showed it (it is almost always moving left, toward the player, so the wrong-facing case barely came up).
  - **Both re-renders done and confirmed good on device (2026-08-10):** rusher at `-Height 190`, gunman at `-Height 162` (matching the hero). Neither reads too small any more.
  - **Melee range: 100 px confirmed working** with the fixed (full-length) attack animation. Was 70 (placeholder) → tried 100-120 → settled at 100. Update `Tuning.RUSHER_MELEE_RANGE`'s constant to 100 next time the file is touched; the live value is already there from the panel.
  - **Debug panel density caps confirmed working (2026-08-10).** `Debug.max_rusher_alive` / `max_thrower_alive`, sliders "kolko bezcov/strelcov naraz (test)". Used to isolate a single rusher and judge its animation/size without a pile of enemies in the way - which is how the two re-renders above got confirmed at all.
  - **Thrower facing-on-stop fix confirmed working.** Retreats, stops, turns to face the player before firing - no more shooting with its back turned.
  - **New, found once the attack animation played in full: the swing reaches out to the SIDE, past the player, not into them.** Not fixed - left alone per Pavel for now. Likely the `Great Sword Slash` clip's own choreography (a swing that travels sideways) rather than a Slavs placement bug, but not confirmed either way.
  - **METHOD addition, earned by missing the above:** test a new animation next to the player character, not alone. Watching the rusher's own render in isolation is how a swing that misses to the side went unnoticed - there was nothing in frame to miss. Add the player (or at least its silhouette/reach) to any future animation-judging step.
  - **Open, low priority (Pavel: "zatiaľ mi to nevadí"):** the Great Sword animations don't close the hands fully around the shaft — both hands sit slightly off the mesh rather than gripping it. Root cause unknown (Mixamo rig quirk, not a Slavs placement issue — `inspect_grip.py` only checks hand-to-hand spacing, not hand-to-mesh contact). Not blocking; revisit only if it reads badly once coloured.
  - Colour is still the flat default WOOD, deliberately untouched — Pavel wants to do the club's colour last, after the shape is settled.
- [x] **Music prototype wired in (2026-08-10), not yet tested on device.** `ref/audio/Protomusic.mp3` (Suno) copied to `slavs/audio/music/protomusic.mp3`, new autoload `Music` (`music_player.gd`) plays it on loop via a plain `AudioStreamPlayer`. Godot imports MP3 natively and `AudioStreamMP3` has its own `loop` property, so **no format conversion was needed to hear music in the prototype** — deferred, per Pavel, is the OGG Vorbis conversion tooling for final tracks, which needs a Suno subscription for WAV export first (licence requirement, not yet purchased). Debug panel got a `HUDBA` checkbox next to `NESMRTELNOST`, wired to `Music.set_enabled()`. Not yet run on device — check on next deploy.
  - Open for later: separate level/boss tracks (`play_track()` already takes a path, so this is just adding files + a call site), and the actual OGG conversion step once real WAV masters exist.
- [~] **KROK 4 (S = 2) — code side DONE 2026-08-12, waiting on Pavel's re-render.**
  Pavel asked for resolution first, layers second — the reverse of §8's order.
  The steps are independent, so this cost nothing; parallax (KROK 1–3) is
  untouched and still to do.
  - `Tuning.PLAYER_SPRITE_SCALE` / `ENEMY_SPRITE_SCALE` → `0.5`.
  - `player.gd` / `enemy.gd` / `sprite_test.gd` → `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`.
    `main.gd` (background) stays NEAREST while the background is S = 1.
  - 402 `.import` files in the seven shipped character folders → `compress/mode=2`,
    `mipmaps/generate=true`, `detect_3d/compress_to=0`. `env_03` deliberately untouched.
  - **`[importer_defaults]` added to `project.godot`** so re-renders can't
    silently land back on `mode=0`. Existing `.import` files keep their own
    values, so this does not reach the background.
  - `-NoOutline` switch added to `render_pixel_test.ps1`; `-Colours` / `-NoOutline`
    passthrough added to `render_enemy.ps1`.
  - **Bug found and fixed while doing this:** `render_enemy.ps1` read `colours`
    and `iron_from` from `<name>.settings.json`, printed them in its header, and
    then never passed them to the renderer. Every render through the wrapper came
    out with default weapon colours and no iron section while the log said
    otherwise. Would have hit the gunman's arquebus on the very next re-render.
  - **Until Pavel runs the three render commands (PRIKAZY.md, top section:
    hero 324, gunman 324, rusher 380, `-Colours 64 -NoOutline`), every character
    in the game is drawn at half size.** That is expected, not a bug.
  - **To verify on device afterwards:** does ETC2 leave blocks on the sprites'
    alpha edges, and does the drawn height come out ~240 / ~240 / ~280 (measure,
    do not assume). Hitbox and muzzle need no re-calibration — both go through
    `SPRITE_SCALE` already, so double the render at half the scale is a no-op
    for them.
  - **The repo was NOT green when this started** — the rusher club pass, the
    music player and ~330 re-rendered PNGs were already uncommitted. My changes
    are mixed into that pile, so `git checkout` will not cleanly undo S = 2
    alone. Commit in pieces.
- [x] **S = 2 REVERTED 2026-08-13. The game is pixel art. Do not re-raise S
  without asking Pavel the style question first, in those words.**
  - S = 2 worked technically and Pavel confirmed it looked sharper on device.
    But its unavoidable consequence — LINEAR instead of NEAREST, 64 colours,
    no outline — **stopped the game being pixel art**, and that is what Slavs
    is. Pavel: "ani vlastne neviem preco claude postavu vyhladil".
  - **The mistake was mine and it was not technical.** The consequence was
    written in `DIZAJN_pozadie_a_rozlisenie.md` §4 and I executed it as a step.
    I never said the one sentence that mattered: *"this stops the game being
    pixel art."* A change to how the whole game looks is Pavel's decision, and
    writing it in an assignment document is not the same as saying it.
  - **Standing rule from this:** if a technical step changes the game's style,
    say so out loud and wait for an answer. Do not execute it because a
    document said so.
  - **His actual complaint was never "characters aren't sharp enough"** — it
    was *"characters are finer-grained than the background"*. Measured:
    character 16.0 % neighbour difference, background 4.8 %. The background was
    3x coarser. The fix is a **finer background**, not smoother characters.
  - Reverted: both `SPRITE_SCALE` back to `1.0`, all three character filters
    back to `NEAREST`, 385 `.import` files back to `compress/mode=0` with no
    mipmaps, `[importer_defaults]` removed from `project.godot`.
  - **The hero's pixel-art frames were restored from commit `42ba8a8`. The
    gunman's and rusher's were NOT recoverable** — the good 162/190 pixel-art
    renders were overwritten by the smooth ones before they were ever
    committed, and `42ba8a8` only has the older, too-small 98x130 versions.
    Both must be re-rendered; the commands are at the top of `PRIKAZY.md`.
- [x] **New background `env_04.png`, generated 2026-08-13, on a live switch.**
  Pavel regenerated it after the style token in `ref/PROMPTY.md` §4b was
  identified as the cause: it said `detailed pixel art, 16 bit`, and "16 bit"
  is what made the generator draw 2–3 px blocks. New prompt pushes fine grain.
  - Measured on the walkable band: **39.1 %** neighbour difference against
    `env_03`'s 4.8 %. The mismatch has now **flipped** — the ground is finer
    than the character (16.0 %). Whether that reads well is a device question.
  - Drop-in: same 2816x1536, palisade ends ~530, river starts ~1215, against
    `BG_WALK_TOP`/`BOTTOM`'s 560/1210. Tiles cleanly (seam 15.2 against its own
    7.7 neighbour noise; `env_03`'s is 11.2 against 2.6, i.e. relatively worse).
  - Contrast rule (§6): band luma **80.0**, exactly on the ≥80 line, down from
    `env_03`'s 88.9. Hero 42.2, difference 37.8 against the ≥35 rule. Both
    pass but with much less margin than before — worth watching.
  - `Debug.alt_background` (panel: "NOVE POZADIE") swaps the texture live, so
    the two can be judged **in motion**. The one thing a still cannot show is
    whether ground this dense shimmers while scrolling, and whether a crowd of
    enemies still reads against it (design pillar 1).
- [x] **Background filter is a dead end — measured, do not retry.** With the
  characters now smooth, `env_03` reads badly next to them. A live NEAREST ↔
  LINEAR switch was added (`Debug.smooth_background`, panel "HLADKE POZADIE")
  and Pavel saw **no difference at all** on device. Measured: the two filters
  differ by **0.36 %** on the walkable band at 1.5×. The blockiness is
  *painted into* `env_03` (2–3 px stroke, imitation pixel art per §1 of the
  design doc) — sampling cannot remove what the generator drew. The only fix
  is a new background (P1, KROK 3). Switch kept as a measuring aid.
- [x] **Enemies teleported sideways when switching animation. Fixed 2026-08-13.**
  Pavel: "strelci ... keď sa zastavia a začnú strieľať, preblknú a teleportujú
  sa o kúsok vedľa". **Not a regression from S = 2** — the same offset existed
  before at half the pixels and the same world size; sharper art just made it
  visible.
  - **Cause:** Blender frames each clip on the *animation's origin*, and Mixamo
    clips disagree about where the character stands relative to it. Measured
    from the rendered PNGs: the gunman's body sits **33 world units further
    right** in `fire` than in `idle`. The rusher had it too, smaller (walk −7,
    attack −2.5), which nobody had noticed.
  - **Fix:** `SpriteSequence.body_centre_offset()` measures each clip's body
    position once per art folder (statically cached — the pool builds ~34
    enemies), and `enemy.gd` cancels it on the sprite's `position.x` when the
    clip changes, negating it when `flip_h` is set.
  - **Why the median of alpha mass and not the bounding box:** a rifle barrel
    is a long way from the body but only a few pixels of mass, so the bounding
    box tracks the gun, not the man. The median tracks the torso to within half
    a pixel across a whole clip. Verified the quarter-size shrink the runtime
    uses agrees with a full-resolution measurement to ~1 world unit.
  - **Two dictionaries, not one:** both kinds have a clip called `walk`, so a
    single shared dictionary had them overwriting each other.
  - **Not yet done:** the player has the same exposure the moment `idle_px`
    exists — `run` and `idle` will not agree either. Wire the same measurement
    into `player.gd` when that idle is rendered.
- [x] **Outline colour: from the body, not black. Pavel's call 2026-08-13.**
  `pixelize_sprites.py` and `coarsen_sprites.py` both take `--outline-darken`;
  **0.55 is what Slavs uses.** The 1 px ring stays — it is a readability
  device and design pillar 1 needs it — but each ring pixel now takes the
  colour of the body it touches, multiplied by 0.55. Measured: 66–74 distinct
  ring colours per frame instead of one. A red coat gets a dark red edge.
  - Why: against `env_04`'s painted ground a flat black ring read as a sticker
    laid on the picture. Worst with coarse pixels (the ring is thicker in world
    units), but present at every size.
  - **Coarse pixels are rejected and removed** — Pavel tried the switch on
    device: the thicker black ring made it worse, and the lost detail was not
    worth it. `Tuning.art_dir()`, `COARSE_FACTOR`, the scale helpers,
    `Debug.coarse_sprites` and the panel button are all gone; `art/*_px_b` is
    Pavel's to delete. `tools/coarsen_sprites.py` stays — it is what resized
    the hero from the 243x324 raw render, and it is the cheap way to try a
    pixel size again without a Blender night.
  - **Topic closed 2026-08-13.** Reopen only on a real symptom, and the symptom
    to watch for is named: **the player cannot tell which objects are
    interactive.** If cages, barricades and barrels stop reading as "I can
    shoot this" once there are props on screen, the answer is likely to give
    outlines a MEANING (Metal Slug: everything interactive is outlined,
    scenery is not) and to regenerate the background with its own contours.
    That is a design decision, not a tuning one — do not slide into it.
  - **A test was wrong before it was right, and the lesson generalises:** the
    first outline comparison recoloured a ring on art that *already had a black
    outline baked into the PNG*, so "no outline" only meant "no second
    outline". Pavel spotted it from the picture ("každý obrázok má čierny
    obrys"). Measured after: ring luma 25 against body 45. **Before testing a
    pipeline stage, check the input has not already been through it.**
  - All sets were regenerated from `render/*_raw` — the frames as they leave
    Blender, before any pixel pass. Those turned out to still be on disk at
    the right heights (gunman 121x162, rusher 142x190, hero 243x324), which is
    why no Blender re-render was needed.
- [x] **Enemies no longer slide while attacking (2026-08-13).** Pavel: a
  thrower that stopped to fire kept travelling toward him through the whole
  firing animation, feet planted. `enemy.gd` now zeroes velocity while
  `_is_attacking()` — deliberately for every kind, not just the thrower: an
  attack is a commitment, and it gives the player a readable beat where an
  enemy has chosen to shoot rather than chase.
  - **A trap found on the way, worth remembering:** `_fire_timer` used to be
    counted down inside `_thrower_clip()`, which is only reached from
    `_drive_sprite()` — and that returns immediately when there is no sprite.
    Any enemy still on the coloured-box fallback would therefore have frozen
    permanently after its first shot the moment the timer started rooting the
    body. The timer moved to `_physics_process`. **State does not live in the
    drawing code**, however convenient the call site looks.
- [x] **`env_05.png` is the background as of 2026-08-14, and it is the last one
  generated as a single flat picture.** Pavel: "rozlisenie postav uz skoro
  vobec nerusi... takto je to ok."
  - Measured on the walkable band: grain **65.9 %** (env_04 39.1, env_03 4.8,
    character ~16), band luma **103.7** (env_04 was 80.0, sitting exactly on
    the ≥80 rule with no margin). It won on contrast as much as on detail.
  - Drop-in: `BG_WALK_TOP`/`BOTTOM` 560/1210 unchanged, verified by drawing the
    hero standing on both limits rather than by arithmetic.
  - Arrived as JPEG, converted once to PNG. **Ask for PNG next time** — JPEG
    rings every hard pixel edge and pixel art is all hard edges.
  - **Two real faults, both measured, both for the parallax session:**
    - **It does not tile.** Seam left-vs-right edge is 39.5 against its own
      16.5 neighbour noise = **2.39x**, where env_04 was 1.99x. Pavel sees a
      break at the first repeat and again mid-screen on the second.
    - **The riverbank is not horizontal — it drops 484 px from left to right**
      (env_04 dropped 10 px, i.e. level). So the bottom edge of the walkable
      area is a slope in the picture while `BG_WALK_BOTTOM` is a straight line
      in the code. They disagree by nearly a third of the picture's height.
  - Neither is worth fixing in the picture: both dissolve once the ground is
    its own layer. That is the next assignment.
- [ ] **TODO — melee enemies on a 2.5D field are not solved, and Pavel has
  raised whether they should exist at all. Left alone deliberately 2026-08-14;
  do NOT try to tune it away.**
  - **The dilemma, in his words:** rushers all converge on the player, so they
    either overlap (which looks wrong) or they are separated on X — and once
    separated on X they cannot reach him. Pushing them apart on Y is worse:
    a rusher above or below the player swings along X and hits nothing but air,
    because `Great Sword Slash` is authored as a sideways swing on a flat
    stage, not as an attack in a depth field.
  - So the separation added on 2026-08-14 (`Tuning.enemy_separation`) treats
    the symptom. It stops bodies occupying one point; it does not make a
    depth-offset swing mean anything.
  - **Options not yet weighed:** fewer, tougher rushers (Pavel's own
    suggestion — but it argues against the mass-shooter pillar); an attack that
    resolves in a radius rather than along the swing; approaching to the
    player's own row before closing; or dropping melee types entirely.
  - **This is a design decision, not a tuning one.** It changes what the game
    is about, so it belongs to Pavel and probably to an Opus session.
- [x] **Depth sorting fixed 2026-08-14.** Draw order came from the enemy pool
  array, so an enemy standing further UP the screen covered one standing lower
  — backwards for a field seen from slightly above. `Tuning.depth_z()` now sets
  `z_index` from world Y on enemies, the player and bullets. Godot's own
  `y_sort_enabled` would also work, but it interacts with the `z_index = -1`
  the sprites carry so the aim line stays on top, and explicit beats "it should
  sort".
- [x] **Enemy hurtbox fixed 2026-09-15.** Reported by Pavel 2026-08-13: shots
  passed through an enemy's upper body, only the lower part registered.
  `enemy.gd:_ready()` sized the hurtbox as `SIZE * 1.15` = 34.5 x 59.8,
  centred on the enemy origin and never touched again - the drawn enemy is
  120-190 world units tall (gunman/rusher differ), so the box covered
  roughly the bottom 45% of the body.
  - Fixed with the same approach as the player's own `_fit_hurtbox`: sized
    from the DRAWN height (`SpriteSequence.foot_margin()`/`head_margin()`),
    not the collision box. Computed once per kind in `_build_sprite_from()`
    (`_thrower_drawn_height` / `_rusher_drawn_height`, since the two kinds
    are different heights), applied in `spawn()` and re-applied every
    physics frame so the new debug-panel slider (`enemy_hurt_height_fraction`)
    is live. `Tuning.ENEMY_HURT_WIDTH` = 24 / `ENEMY_HURT_HEIGHT_FRACTION`
    = 0.72, same precedent as the player's constants.
  - **Not yet deployed to a phone.** Confirm on device before trusting it in
    a real run - the fraction (0.72) is carried over from the player's own
    measured value, not separately measured for either enemy kind.
- [x] **Art pipeline switched to PixelLab, 2026-10-02/03.** The 3D chain
  (image -> Meshy -> Mixamo -> Blender -> pixelize) took several sessions per
  character and was the bottleneck. Characters and their animations are now
  generated in PixelLab (pixel-art generator) - side view, then shown in game
  at an INTEGER 2x. Pavel on device: matches the env_08 background much better
  than the renders did.
  - **Access:** PixelLab is connected as a local MCP server in Pavel's Claude
    desktop app (claude_desktop_config.json, `npx mcp-remote` with the API
    key) - tools appear as `pixellab__*`. `*.pixellab.ai` is on the network
    allowlist (Settings -> Capabilities), so frames download straight from
    backblaze.pixellab.ai into the project. API key also in
    tools/.pixellab_token (git-ignored).
  - **Free trial:** 40 generations total, then 5/day (store up to 20). Costs
    seen: character v3 at 64-76 px = 2; template animation = 1 per direction;
    custom v3 animation at <=76 px, 6-8 frames = 1. Free tier runs ONE job at a
    time and sometimes rejects jobs under load (429) - those are not charged,
    just retry. Paid Tier 1 = 12 USD/month, 2000 generations.
  - **Method that worked:** generate only the `east` direction of each
    animation; mirror enemy frames to face west on export (enemy.gd assumes
    west-facing art); pad every clip onto one square canvas (104 px for the
    rusher) so feet sit on the same row; hard alpha. Show Pavel the base sprite
    for approval before animating. Template "fight-stance" is an unarmed boxing
    guard - wrong for armed enemies; describe a custom ready stance instead.
    Weapon swings need a custom v3 description; a one-frame strike reads too
    fast, so hold frames in frames.gd and slow the clip (see
    art/rusher_pl_attack/frames.gd).
  - **Done:** hero (art/hero_pl_run, hero_pl_idle; 2x via the debug-panel
    switch) and rusher (art/rusher_pl_*; RUSHER_SPRITE_SCALE 2, RUSHER_ANIM_FPS
    10, attack 6 fps, hit at 0.70 and melee range 100 both confirmed on device
    2026-10-03). The rusher no longer has the turban - helmet + spiked mace -
    so the ethnicity TODO is closed FOR THE RUSHER; the gunman is still the old
    render with the turban.
  - **Deviation to know about:** the rusher's weapon came out as a one-handed
    spiked mace, not the two-handed club decided 2026-08-06. Pavel accepted it
    2026-10-02. Lesson recorded with him: when an instruction ("copy it")
    conflicts with a written rule (the ethnicity rule), say so BEFORE acting.
  - **Old art untouched** in run_px / rusher_*_px; tuning.gd comments say how
    to switch back.
- [~] **Hero weapon: thrown axe that returns + one breakable barrel
  (2026-10-03), coded and checked headless, NOT yet tested on device.**
  - **Decided with Pavel:** no melee attack. A melee reach equal to the
    rusher's turns the game into dodging single swings, which a mass shooter
    has no time for. The weapon is a hand-axe thrown along the aim, flying
    `Tuning.axe_range` (350, panel slider "dosah sekery" 150-700) and coming
    back like a boomerang, hitting everything it passes through once out and
    once back (`axe.gd`). Next throw only after the catch. Firearms come later.
    Panel switch "SEKERA (vypnute = gulky)" puts the old bullets back.
  - Hero holds the axe -> `hero_pl_axe_idle` / `hero_pl_axe_run`; throw ->
    `hero_pl_axe_throw` (axe leaves on `AXE_RELEASE_FRAME` 5); while the axe
    flies he is drawn with the old empty-handed run/idle.
  - **Art made cheaply on purpose (Pavel: functionality first, final art
    will be redone):** PixelLab could not add the axe by img2img (it came out
    as a few pixels), so the axe was drawn by hand into the east rotation
    (`art/pixellab/hero_axe_base_east.png`) at ~45 deg and the three clips
    were v3 animations from that custom start frame (1 generation each).
    The thrown axe sprite is the same hand-drawn axe (`art/axe_thrown`).
    Whole task cost 6 generations (1 failed img2img, barrel, barrel break,
    3 hero clips) - 22 left on 2026-10-03.
  - **Pavel for the next hero redraw:** remove the wrist chains; the axe
    should be held diagonally (the current run clip lets it wander).
  - Barrels (`barrel.gd`, art `barrel_pl`): 3 hits from axe or bullets
    (same LAYER_TARGET + hit() as enemies), shake + flash per hit, then the
    PixelLab burst clip (9 fps), wreck stays. Four of them, stood ahead of
    the hero (`Tuning.BARREL_OFFSETS`, clamped to the walk band) at the
    start, again whole after every death, and on the panel button
    "NOVE SUDY". They do not block movement.
  - **First device test 2026-10-03 (Pavel: "výborné", hero clips "super"):**
    axe too fast -> 650 (was 1100) + slider "rychlost sekery"; thrown axe
    read smaller than the one in hand -> redrawn 17x27 (was 12x19), same
    pixel size; and a real bug: dying with the axe in the air left the
    hero with no weapon for good - `_clear_field()` recalled the axe
    without telling the player. `axe.recall()` now emits `caught`, and
    `revive()` resets the hand too. Verified headless (death mid-flight,
    broken barrel restored).
  - **Second device test 2026-10-03 (Pavel: much better, barrel burst
    "výborný"; range and speed OK for now - faster/further later as hero
    upgrades):** thrown axe +20% (now 21x34 px); the yellow aim stick is
    gone from `player._draw()`; barrels now BLOCK the hero (StaticBody2D on
    new `LAYER_PROP`, only the player masks it - enemies pass through, they
    have no way round obstacles yet; the wreck stops blocking). Blocking is
    by FEET in depth (+-`BARREL_BLOCK_DEPTH`), worked out from the hero's
    54-tall box - see `barrel._set_blocking()`. Plus a wall of 6 barrels
    side by side in Y, 40 apart, `BARREL_WALL_X` 600 ahead, centred on the
    hero's row, rebuilt with the rest after every death. Verified headless:
    the wall blocks every feet row it spans, breaking one opens that row;
    rendered under xvfb to check the look.
  - **Headless check method that worked (no phone needed):** Godot 4.7.1
    Linux binary in the cloud workspace, project copied over as a tar,
    `--headless --import` then `--quit-after N` with a temporary
    `_physics_process` test appended to a COPY of main.gd (forces
    Touch.aim_active, prints state). `xvfb-run ... --rendering-driver
    opengl3` + `get_viewport().get_texture().get_image().save_png()` gives a
    real screenshot.
  - New tool: `tools/pixellab_export.py` - downloads a PixelLab clip, pads it
    onto the shared canvas at a given offset, hard alpha, erase boxes, holds,
    writes frames.gd. Hero offsets on the 96 canvas: rotation (20,16); v3
    clips from a custom start frame (20,4) idle, (20,2) run, (18,4) throw -
    measured by locating the reference frame inside each v3 canvas.
- [x] **Hero stopped INSIDE a barrel - fixed 2026-10-03, not yet on device.**
  `BARREL_BLOCK_WIDTH` 40 -> 118, derived from the art (barrel 48 wide, hero
  front edge ~44 past his centre, box half 15, ~6 gap); headless test stops
  centres exactly 74 apart, screenshot shows a small gap. Live slider
  "sud: odstup postavy" (40-180) if it needs tuning on device.
- [x] **HP raised 2026-10-03 (Pavel), because the returning axe hits twice
  per throw:** rusher 1 -> 2, thrower/gunman 2 -> 4, barrel 3 -> 6. Not yet
  on device.
- [~] **Hit/death effects (2026-10-03), code-drawn, not yet on device.**
  `fx.gd`: square pixel particles on the 2-unit grid, 2.5D (ground spot +
  height): blood on every enemy hit (8) and death (30 + dust puff), wood
  splinters on every barrel hit (6) and burst (30 + smoke). Blood/splinters
  land and lie as stains for `fx_stain_time` (3 s), then fade. Two layers:
  stains just above the ground (walked over), flying bits on top. Signals:
  `enemy.hurt(feet, height, fatal)`, `barrel.damaged(feet, broke)`; spray
  goes away from the hero. Chosen over PixelLab because Pavel wanted to test
  the mechanic (0 generations); PixelLab clips can replace the look later.
  Measured: 700 particles (the cap) update in ~0.15 ms. Panel: "EFEKTY"
  toggle + "ako dlho lezi krv na zemi". No explosion yet - nothing explodes.
- [~] **Effects round 2 + vibration (2026-10-03), not yet on device.**
  Pavel on device: mechanic works; splinters read as gold coins and the
  square smoke does not fit (both accepted for now); the death cloud was odd.
  Smoke puffs removed (code kept, unused). Hero now bleeds when hit
  (`player.hurt`, emitted before the god-mode check so it shows while testing;
  god mode now also takes iframes). Vibration (`Input.vibrate_handheld`)
  works on device. **Moved 2026-10-03 (Pavel): buzz only when the HERO is
  hit** (120 ms, amplitude 1.0), not on kills/barrel bursts - those felt
  odd. Max one per 0.08 s. Panel "VIBRACIE", "sila vibracii",
  "dlzka vibracie pri zasahu (ms)".
  **Needs the Vibrate permission ticked in the Android export preset on
  Pavel's PC** (PRIKAZY.md -> VIBRACIE) - export_presets.cfg is not in git.
- [ ] **TODO (Pavel 2026-10-03, later) — rusher flickers after a swing when
  the player has moved on Y.** If the player steps down/up the field while the
  rusher is mid-swing, the moment the swing ends and he moves to catch up, the
  sprite briefly "preblikne". Pavel's read: the catch-up is a mostly-vertical
  move, and the walk clip is made for X movement - so it probably flips
  facing or toggles walk/idle on the near-zero X component. Was there with the
  old rusher too. Not urgent; look at _drive_sprite's facing/animation choice
  when |velocity.x| is small but |velocity.y| is not.
- [ ] **TODO — unify the colour palette across background, enemies and props
  before final art is generated.** Pavel, 2026-08-13. `env_04` was generated
  independently of the characters, so nothing ties their palettes together
  yet. Cheapest moment to fix this is BEFORE eight enemy types are produced,
  not after — same lesson as the ethnicity rule and the enemy-size one.
  Likely mechanism: extract a shared palette from the chosen background and
  pass it into `pixelize_sprites.py` instead of letting each character
  quantise to its own 16 colours.
- [x] **Parallax + background assignment (opened 2026-08-12) closed for now, 2026-09-15.** Full brief was in `DIZAJN_pozadie_a_rozlisenie.md` §8; most of the detail below predates where it actually landed (background is env_08, not env_03/05; per-column walk edges replaced the flat bounds; see the 2026-09-15 commits). Pavel reviewed the current state on device and is satisfied with it for now - reopens only if he asks. Left as historical context below rather than rewritten; do not treat the S = 2 / four-variant-layer-count plan below as still active without checking the current code first.
  - **Closed 2026-08-12, do not re-open:** parallax (not water shaders, not frame-animated backgrounds); **S = 2** (assets at 2 px per world unit, drawn at `scale 0.5`); **P1** for the background — detail by layer, far layers may be soft; **P2 cancelled**; **P3 (background rendered in Blender) deferred** with an objective trigger — it returns only when the style is settled *and* more than two environments are needed, i.e. at F3; **the environment is daylight**.
  - **The one thing still open, and it is Pavel's:** how many parallax layers. He answers it by looking at four variants on the phone after step 2. Nothing else is open.
  - **Two corrections to what was written earlier here — both were wrong and would have cost a session:**
    - `default_texture_filter` being unset does **not** mean the game renders through LINEAR. All four drawing sites set `TEXTURE_FILTER_NEAREST` themselves (`main.gd:120`, `player.gd:134`, `enemy.gd:143`, `sprite_test.gd:27`). There is no "free Nearest win" to collect — it is already done. What the device actually shows at 1.5× with Nearest is *uneven pixels*, not blur.
    - The "night scene" question came from reading `ref/env_03.png` (a night graveyard **style reference**) instead of `slavs/art/env_03.png` (**what is in the game**: daylight conifer forest, palisade, grass and dirt, river with boulders). Two different files with the same name in two folders. The question is void.
  - **Consequence of S = 2 that must not be discovered by accident:** at S = 2 the asset is *minified* (2 asset px per world unit against the device's 1.5), and **NEAREST is the wrong filter when minifying** — it drops every fourth pixel and crawls in motion. Character sprites move to `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`. This means **strict pixel art stops being achievable at S = 2**, since that needs an integer asset-to-display ratio, which varies by phone. That is a consequence, not a new decision — S = 2 does not reopen because of it.
  - **S = 2 is a much smaller change than it sounds:** `Tuning.PLAYER_SPRITE_SCALE` and `ENEMY_SPRITE_SCALE` already exist and the code already multiplies by them (`player.gd:152`, `enemy.gd:151`), so hurtbox, muzzle height and foot placement all follow by themselves. The change is those two constants to `0.5`, re-render at double height (hero 162 → 324, gunman 162 → 324, rusher 190 → 380), the filter change, and mipmaps + `compress/mode=2` in the imports.
  - **The constraint that will bite if forgotten:** the ground never goes into the parallax layer array. `_build_background()` draws it and is not touched — that is factor 1.0 by construction. The walkable field is numbers (`BG_WALK_TOP` / `BG_WALK_BOTTOM`) mapped onto a picture; scroll that picture at a different rate and the grass slides under the character's feet. Vertical `scroll_scale` stays 1.0 on every layer because the camera travels up and down.
  - **Contrast is a measured number now, not a feeling:** walkable band luma ≥ 80, and character-to-band difference ≥ 35. Today: band 88.9, hero 42.6, difference 46.3 — both pass. `tools/check_contrast.py` (step 5) makes this checkable for every new background and enemy.
  - **Order matters and the steps are separate sessions:** parallax plumbing (no visual change, a green-state checkpoint) → one foreground strip at factor ~1.3, which is the only layer that can be added without cutting and repainting `env_03` → Pavel decides the layer count → S = 2 → the contrast script.
- [ ] **Enemy art and weapons in progress.** Weapons attach to the hand bone in Blender **after** rigging (`tools/blender_attach_weapon.py`, has arquebus / club / spear / sword / bow), because Mixamo refuses to rig a model holding anything — and the animation has to match the weapon, so a rifle needs a rifle animation.
  - **Rusher: done through Mixamo.** Three animations in `ref/characters/`: `Great Sword Idle`, `Walking`, `Standing Melee Attack Downward`. All verified — 35 bones, UV map present, textures embedded.
  - **The rusher's club is two-handed (1.25 m), decided 2026-08-06.** The Great Sword animations put both hands on a shaft, so a 0.72 m one-handed club left the left hand closing on air. Lengthening the club was chosen over re-downloading three animations. Do not shorten it back without swapping to one-handed animations at the same time.
  - **Open: `Walking` is probably the wrong cycle for a rusher** — a rusher closes and presses, and a walk reads too slow. `Great Sword Run` is the replacement to try.
  - **Gunman: done through Mixamo too.** Three animations in `ref/characters/`: `Rifle Idle`, `Rifle Walk`, `Firing Rifle`. All verified — 53 bones, UV map present, textures embedded. They match the **arquebus**, which is correct for the 15th century and not an anachronism.
  - Next for both: attach the weapon in Blender (`blender_attach_weapon.py --weapon club` / `--weapon arquebus`), render to `slavs/art/`, then tune the offsets **from the render**, never by reasoning.
  - Housekeeping: `ref/objects/*" - Copy".glb` are duplicates (~28 MB) and `ref/characters/Hitem3d-1785662322779.fbx` is 242 MB. Do not let them into git.
- [ ] **Still missing an `idle` animation for the hero.** Without it the character freezes mid-stride when standing. Render it to `slavs/art/idle_px/` and the game picks it up by itself.
- [ ] F2: vertical slice
- [ ] F3: content production
- [ ] F4: polish + closed testing (12 testers / 14 days — mandatory for new personal Google Play accounts)
- [ ] F5: launch
