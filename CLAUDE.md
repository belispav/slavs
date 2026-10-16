# Slavs fight back — Project Memory (read this first)

> **NAME (Pavel, 2026-10-03): the game is "Slavs fight back", working name
> "Slavs".** The old AI-invented name was removed from the whole repo on
> 2026-10-03 (folder is now `slavs/`, Godot project name "Slavs fight back",
> `PLAN_hry.md`, docs, tools, Blender object names, env var `SLAVS_BLENDER`).
> Do not reintroduce it anywhere. **The ONE exception is the Android package
> id `sk.pavel.volya`** (`export_presets.cfg`, `deploy_android.ps1`,
> `get_tuning.ps1`, `SETUP_F0.md`): it never changes - a new id installs as a
> second app and loses the data on the phone.
> **Reconfirmed 2026-10-15:** the new story files (written with another AI) still
> say "VOLYA" as the game title - the title stays "Slavs fight back". VOLYA
> survives only as the name of the rage in story v5 (open point, Pavel decides).

You are the AI development partner for Slavs fight back, a 2D side-scrolling run-and-gun mobile game (Metal Slug style) built in **Godot 4.7 / GDScript** for **Android first**. The developer (Pavel) is a solo creator with **zero prior game-dev knowledge** — you write the code, he directs, tests on his phone, and learns by reading. Communicate in Slovak; code, comments and commit messages in English.

> **ALL GAME ART IS MADE IN PIXELLAB (since 2026-10-02) — Pavel's choice, and he is very happy with it.**
> Characters, their animations, props and effects are generated with the PixelLab
> MCP tools (`pixellab__*`, connected locally in Pavel's Claude app; frames download
> from `*.pixellab.ai`, which is allowlisted) and shown in game at an integer 2x.
> Do NOT go back to the old 3D chain (Meshy -> Mixamo -> Blender -> pixelize) or
> propose another generator unless Pavel asks. Method, costs and limits: section
> "Art pipeline switched to PixelLab" under Current status, and `PRIKAZY.md`
> -> "PIXELLAB". Backgrounds too: since 2026-10-05 a whole
> screen is ONE `create_image_pixen` image (672x384 art px = 1344x768 at 2x, 1
> generation) - see the 2026-10-05 ground entry at the end of Current status.

## Key documents in this folder

- **STORY - current since 2026-10-15:** `20261015 - Handoff Slavs fight back.md` is the working truth for story, setting, cast and names, levels, the core "Rescue" mechanic, visual set pieces and the first scene pack (S01-S10). `Slavs fight back — príbeh, aktéri a motivácie (v5).html` and `Slavs fight back — mená pre globálnu anglickú verziu (v6).html` are Pavel's dashboards of the same - **do not edit them unless Pavel asks.** Written with another AI, Pavel keeps editing it; open points in its §12. **`PRIBEH_rozhodnutia.md` is newer and wins over the handoff** (character cards, decisions, open questions). The v5 HTML still uses old names: Radko = Vojtek, Mstislav = Jarek, Bohuš = Bohdan. It mentions that AI's `SPEC_MASTER.md` / `STORY_BIBLE.md` - they are NOT in this folder: for controls use our SPEC, for content rules its §2 + the rules below. It wins over everything older in this folder except controls and values measured on the device (conflicts: Open item 12).
- `POSTAVY_karty.html` — Pavel's dashboard of the character cards (he reads this, AI reads `PRIBEH_rozhodnutia.md`). **Update it after every character card or story decision.**
- `PRIBEH_rozhodnutia.md` — running list of Pavel's story decisions made after the handoff (newer, wins over the handoff) + open story questions. Record every new story decision there.
- `_archiv/CLAUDE_historia.md` — the full dated history that used to be the Current status section of this file (every measured number, old pipeline and reasoning, verbatim). Read it only on demand, not every session.
- `KDE_JE_CO.md` — one-page map of the folder: what is for Pavel, what is for Claude, what is archived. Update it whenever files are moved or added in the root. The same map as a dashboard for Pavel: `KDE_JE_CO.html`.
- `_archiv/` — finished and old material. **Do NOT read it and do NOT take it into account** unless Pavel explicitly asks (only exception: `_archiv/CLAUDE_historia.md`, on demand). Two parts are dead: `_archiv/3d_stary/` = the old Meshy -> Mixamo -> Blender -> pixelize chain (render outputs, .blend/.fbx models, old scripts, old `*_px` sprites, old PRIKAZY sections); it exists ONLY on Pavel's local disk (gitignored, not on GitHub) - never use it, never propose going back, never refer to it. `_archiv/pribeh_stary/` = the old story (escaped slave vs slavers, the old `PLAN_hry.md`, `DIZAJN_core_loop.md`, `HLASKY.md`, the pre-pivot concept of the other AI), superseded 2026-10-15.
- `ZACNI_TU_dalsia_session.md` — the starting prompt for the next session. Old prompts, the superseded 3D character pipeline and other finished documents are in `_archiv/`.

- `PRIKAZY.md` — **the command cheat sheet.** Deploy, render, the character
  pipeline, troubleshooting. Pavel does not memorise commands; put anything he
  will need to type again in here.

- `PLAN_hry.md` — full plan: game design, business case, phase plan (F0–F5), deployment, roadmap, risks. Chapters 1-3 rewritten 2026-10-15 from the new story; the old version is in `_archiv/pribeh_stary/`.
- `PLAN_vydanie_NextFest_2027.md` — release + monetization PROPOSAL of 2026-10-12 (Steam Next Fest Feb 2027, milestones PL01-PL15, model Steam 9,99 € / Android free start + 4,99 € unlock / web demo). Preliminarily approved by Pavel; open points listed there (T53). Until he closes them, `PLAN_hry.md` stays valid. Marketing theme: satire of politicians breaking election promises; **no immigration frame** (Pavel 2026-10-12); never the phrase "mass shooter" in public copy.
- `DIZAJN_pozadie_a_rozlisenie.md` — **closed 2026-09-15** (Pavel satisfied with the parallax/background state; reopens only if he asks). Kept in the root because code comments point at it. Parallax for the static background, and unifying asset resolution between characters and background. Contains the measured facts, the decisions already made, the hard constraints, and the three questions only Pavel answers. Read it before touching anything about the background, `env_*`, sprite scale or texture filtering.
- `DIZAJN_core_loop.md` — archived 2026-10-15 to `_archiv/pribeh_stary/` (superseded by story §4). Its open questions (what ends a run, cage economy, upgrade list, unlocks, weapon switching) live on in T09.
- `SPEC_ovladanie_implementacia.md` — the control system spec + implementation addendum. This is the single source of truth for controls. Controls are the product; everything else comes second.
- `_archiv/Phone controls instrucitons.txt` — original control philosophy document (superseded by the SPEC file, kept for reference).
- `_archiv/F2P Monetization Strategies Analysis.md` — background research only; the game is PREMIUM (5,99 €), no IAP in v1.0, no ads, no gacha. Ever. (T10 reopened 2026-10-12: a free-start + one-time unlock proposal is in `PLAN_vydanie_NextFest_2027.md`; not decided. No ads and no gacha stand either way.)
- `SETUP_F0.md` — Pavel's setup + testing guide (Godot, JDK 17, Android SDK, one-click USB deploy, F1 test protocol).
- `slavs/` — the Godot 4.7 project itself. Scenes are built in code (`main.gd`); only `main.tscn` exists as a scene file. Control tunables live in `slavs/config/control_config.tres`, gameplay constants in `slavs/scripts/tuning.gd`.

## Design pillars (never violate)

1. **Overwhelming, absurd action.** 15–30 enemies on screen, generous hitboxes favoring the player, enemies die in 1–3 hits. No complex combat, no stealth, no puzzles.
2. **Zero thumb-lifting controls** per the SPEC. If a feature conflicts with the control scheme, the feature loses.
   - Consequence discovered on device: **the left thumb physically covers the left third of the screen.** Lethal threats must never arrive from the left — the player cannot see them. Enemies advance from the right. This constrains level design, spawn logic and boss arenas for the whole game.
3. **Short sessions.** Levels 2–4 minutes. Instant restart.
4. **Fixed v1.0 scope** (plan §3.4, from story v5): 3 acts, 9 levels + playable epilogue, the bosses named in the story, the village as meta-progression (9 vs 7-8 levels still open). Anything beyond → suggest adding to the backlog section of the plan, do NOT implement.

## Content rules (hard constraints — store policy + project ethics)

The tuning-art turban issue is closed (turban and glowing eyes removed from rusher and gunman, see Standing decisions).

- **Setting (story v5, 2026-10-15): fictional feudal Central Europe, ~1420-1480** - not a real country, not a real war. Replaces the old "15th century Eastern Europe, escaped Slavic slave, harvest of the steppe, Crimean/Nogai/Ottoman raid captains" (archived; do not use it any more). Firearms of the era (arquebus, hand cannon) stay plausible. Myth budget: one stag, one portal, one sorcerer - brief, never explained. Zora's power (she senses whether a person BELIEVES what he says or writes - sincerity, not facts; fanatics pass, liars and cynics fail; no VFX) and Jaga's hints are on the cards in `PRIBEH_rozhodnutia.md`.
- **Hero = Vlad** (Codex: Vladan, called the Storm): appears from nowhere, serious, no quips. Cast and names: story §5 (short ASCII name in game, full Slavic name + meaning in the Codex).
- **The 10 compliance rules of story §2 apply to every asset, string and scene:** enemies only by political/military/economic role, never ethnicity, nationality or religion (exception, Pavel 2026-10-16: Ordan's people are foreigners from an invented foreign realm - foreignness yes, a real nation, religion or real-world markers never; no compass direction); no real religious symbols anywhere (fictional heraldry only); the player can never damage a non-combatant (no hitbox, enforced in code); enemies may harm non-combatants only implied, at distance; no dismemberment or decapitation; no torture; no contemporary political reference; forbidden terms; moral diversity; EDSA disclaimer at first launch.
- Our own rules on top: no immigration frame (Pavel 2026-10-12); never the phrase "mass shooter" in public copy; PEGI 16, stylized pixel violence.
- The in-game Codex holds full names + meanings and real background (e.g. Slavic mythology, Perun), not citations about a real war.

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

## Tokens - read before working (Pavel, 2026-10-05)

- **Use the `token-saver` skill** (Skill tool, `anthropic-skills:token-saver`) on
  long or file-heavy work. Pavel forgets to ask for it, so Claude should invoke it
  by itself at the start of any session that reads big files or runs many steps.
- **Images cost real tokens** - roughly 1-5k each depending on size, and every
  image stays in the context for the rest of the session, so it is paid for again
  on every later turn. Pavel did not know this. Rules: show an image only when a
  decision needs it; put several options on ONE contact sheet instead of many
  files; keep sheets small (a 1280x2880 sheet is ~5k); never "look" at an image
  that a number can answer (measure it instead); when Pavel pastes images, do not
  re-open them. Prefer sending Pavel the file over reading it back myself.
- One session, one subject (already a rule); do not re-read documents already read.

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
  `export_presets.cfg`, `ref/*.png`, `_archiv/3d_stary/`. Deploy stays on Pavel's PC.

## Local Claude Desktop AND cloud (from 2026-10-05)

Pavel may now work either in a cloud session or in Claude Desktop on his PC
(his credits there). **GitHub `belispav/slavs`, branch `master`, is the single
shared state.** Rules for switching:

- **Pavel does not have to remember any of this - Claude does it, and a hook enforces it**
  (`.claude/settings.json`): at session start `tools/git_sync_start.sh` pulls a clean
  `master` (fast-forward only) and reports if the copy is behind, diverged or has unpushed
  commits; when Claude is about to finish, `tools/git_sync_stop.sh` blocks once if anything
  is uncommitted or unpushed. If either message appears, act on it before doing anything
  else. Claude must also say "pushnute" with the commit hash at the end of each task.
- Whoever finishes a piece of work **commits and pushes to `master`** (always;
  that is what makes the other side current). The deploy to the phone stays local
  (`tools/deploy_android.ps1`, `export_presets.cfg` is not in git).
- Whoever starts a session **runs `git pull` first** (cloud sessions clone fresh,
  local ones may be behind).
- **Never work in both at once** on the same files - the changes diverge. Push on
  the old side before starting on the new one.
- Local Claude has the PixelLab MCP as `pixellab__*` (Pavel's desktop config);
  cloud has `mcp__pixellab__*` plus the proxy credential. Same account, same
  generation balance, so check `get_balance` either way. Files that are not in git
  (`ref/*.png`, `_archiv/3d_stary/`, `tools/.pixellab_token`) exist only on the PC.
- Cloud sessions are told to use a designated branch; if so, push there AND to
  `master` only when Pavel says so. On the PC, push straight to `master`.

## Working rules

1. **Small tasks.** One feature per task. Never large rewrites without explicit approval.
2. **Green state discipline.** After every change: run on device/editor → works? → `git commit`. Never continue on a broken state. Git from day one.
3. **Explain as you go.** Pavel is learning — after each task, 2–3 sentences on what was done and why (in Slovak). No lectures.
3b. **Anything about framing, sizes or proportions: draw it first.** `tools/preview_framing.py` composites the real background, the real sprite and the real camera arithmetic into a picture of the finished shot. Five rounds were lost describing framing in numbers, each making it worse, because a number cannot say whether the water is on screen. Produce the picture, agree on it, then build.
4. **Weekly refactor.** When asked (or when a file exceeds ~300 lines), clean up before adding features.
5. **Performance target:** 60 fps on a ~150 € Android phone. Object pooling for enemies/projectiles from the start.
6. **Tunables in one place.** All gameplay constants (control thresholds, damage, speeds) in exported variables / a single config resource so Pavel can tune without code.
7. **Randomness by default (Pavel 2026-10-09).** Every enemy behaviour and effect gets a small random variation per instance - always, without being asked (e.g. +-10-25 % of the tuned value, agreed ranges are listed in `tuning.gd` under RANDOMNESS). Use `Tuning.jitter(base, frac)`; the panel sliders hold the MIDDLE value and the panel slider NAHODNOST scales all spreads (0 = off). Applies to the corpse power/animation speed/lying time, slow-motion length and speed and the white flash so far; apply it to every new enemy, attack, sound and effect. Sizes too (2026-10-09): every enemy's body height and every barrel/pot is scaled +-5 % (`RAND_SIZE`), props come in two size classes (`PROP_SIZE_CLASSES`).

## Know-how from the market analysis (2026-10-12, apply without asking)

Lessons from `2026.10.12 - analyza-mechanik-updated.md` (comparable games). Pavel does not review these; apply them in every session.

- **World:** fictional, with a clear parallel to real politics (Pavel 2026-10-12). Never real people, parties or current named events; Not Tonight (Brexit) was rejected by part of its audience as propaganda.
- **No dated promises in public.** Never announce chapters, DLC or features with a date we may miss (Katana ZERO's free DLC announced 2019, still undated 2025). For a game about broken promises this would be a PR disaster. Public roadmap = only what is done or nearly done.
- **Translations early.** Every player-facing string goes through one translation table from the first line of text (no text baked into images, no strings hard-coded in scripts). Check the longest language (German) fits 640x360 and the large font. Reigns slipped its launch a week over translations.
- **Text on 640x360:** one thought per box, max 2 lines, large font. Reigns pattern: short question, quick answer, clear consequence.
- **Touch first, PC is the port.** Never carry PC controls over to touch (Katana ZERO on mobile was criticised for it; Papers, Please spent months reworking its phone UI). The SPEC controls stay the reference; PC/keyboard is the adaptation.
- **Weak-phone testing.** Test on the weakest phone we support, with the worst case on screen (max enemies + all effects + corpses). 20 Minutes Till Dawn slowed down with many enemies. Target stays 60 fps on a ~150 EUR phone (working rule 5).
- **Difficulty must not stop the story.** Instant restart, checkpoint at the start of each action section; very hard modes only as options (Hotline Miami 2 lost players by being too hard).
- **A chapter needs its own climax.** A cliffhanger ending is good, but without a resolved peak the ending reads as abrupt (Katana ZERO criticism).
- **Name the free part clearly** (e.g. "Chapter 1 free"); 10 vs 20 Minutes Till Dawn confused players.
- **No grind.** If unlocks/upgrades exist, keep them generous and the tree small and clear (Army of Ruin, Spirit Hunters failed on grind and an unclear tree). Strong weapons must look strong on screen.
- **No pay-to-win, energy or ads** (standing decision, confirmed by the analysis).

## Work packages (Pavel 2026-10-07)

ToDo work is done in numbered packages, one clean session per package. `BALIKY_poradie.md` is the master: which package is NEXT, its item codes, what already exists in code, closing procedure. Read it right after this file.

## Current status (SHORT - the full dated history is in `_archiv/CLAUDE_historia.md`)

> The history file holds every dated entry, measured number and old pipeline,
> verbatim. Read it only when a topic below says "see history" or you need the
> reason behind a decision. Update THIS section briefly as you work; put long
> dated detail straight into the history file, not here.

### What is in the game (as of 2026-10-05)
- Godot 4.7 project `slavs/`, Android deploy via `tools/deploy_android.ps1` (F0 done, F1 controls GO).
- **Movement:** free 2.5D movement, NO jumping (decided 2026-08-03). Control values in `control_config.tres` are measured on device - never change them by guessing. Enemies come only from the right.
- **Hero:** PixelLab art at 2x (`hero_pl_*`). Weapon = thrown axe that returns like a boomerang (`axe.gd`), no melee; panel switch can put bullets back.
- **Enemies (all PixelLab, 2x):** rusher (helmet + spiked mace, melee swing with its own hit beat), gunman (iron helmet, arquebus, shot leaves on the muzzle flash), brute (front armour, grabs = slow death, 10 HP = one cauldron blast). Awareness split (unaware idle vs ready idle) built for the rusher only.
- **Props:** barrels and ceramic pots (same `barrel.gd`, block the hero by feet depth, 6 HP, scattered at random, 3 + 3), explosive cauldron (fuse, blast ellipse, chain reaction).
- **Package 2 DONE 2026-10-09:** enemy death (clips for rusher and gunman, brute bursts), slow-motion on the last kill, longer blood stains, smoke vanish, randomness everywhere.
- **Package 3 DONE 2026-10-10:** enemy dirt variants (`enemy_dirt.gd`, 5 baked variants per kind, panel switch + slider 50-200, brute head clean). Warning blink / brute wind-up / synthesised warning sounds were tried and REJECTED by Pavel (code removed); real warning voices come later (D4). Effect catalog: `KATALOG_efektov.md` (T42). **Package 4 is NEXT** (see `BALIKY_poradie.md`).
- **Effects/feel:** code-drawn blood/splinter particles (`fx.gd`), god mode ignores hits fully. **Package 1 "Uder ma vahu" DONE 2026-10-08:** a hit by the hero's weapon (`Enemy.weapon_hit` -> `main._on_weapon_hit`) gives hit-stop 30 ms (`Engine.time_scale`, ended by real clock in `_process`), white flash 40 ms (shader on the sprite), shake and camera kick x1.5, floating damage number (size 16, `fx.damage_number`), 15 % crits (2 damage, effects x1.5) and a 200 ms buzz; every effect has a panel switch + description. Default game: no brutes, 1 gunman (`debug_state.gd`).
- **Sound:** `sfx.gd` event folders under `audio/sfx/<event>/`, generic effects are placeholders, voice folders empty (lines are Pavel's, English; the old drafts were archived 2026-10-15 with the old story - new lines follow story v5: hero serious, no quips). Music prototype `Music` autoload.
- **Background:** `env_08` with per-column walk edges (closed 2026-09-15). Ground work 2026-10-05 is on `master` but not yet on a phone: PixelLab pixen one-screen ground pictures (1 generation each, 672x384 art px = 1 screen at 2x), debug-panel ground picker, "SCENA BEZ SCROLLU" fixed camera with shallow walk band (`scene_walk_depth` 330), walk-through ground objects. Tools in `tools/` (`bake_pixen_grounds.py` etc.), details in history.
- **Debug panel:** autoload `Debug`, never ships; PAUZA, god mode, enemy toggles/caps, many live sliders. Pattern: find a value live on the phone, Pavel confirms, then bake it into `tuning.gd` and reset the slider.

### Open (Pavel decides unless stated)
> **ToDo IDs:** `[T01]`... tags map these items to Pavel's ToDo list (master: `KDE_JE_CO.md` + dashboard `KDE_JE_CO.html`). When Pavel says "T07", look it up there. IDs are permanent; never renumber. Research ideas of 2026-10-07 carry permanent letter codes A1...Z8 (category letter + number; detail and sources in `NAPADY_vylepsenia.md`, category Z = monetization); they live in the same ToDo with fields cat/imp/eff (see `KDE_JE_CO.md` header) and keep their code when Pavel picks them. The dashboard and `KDE_JE_CO.md` list ONLY open tasks: when a task is done/cancelled/closed, move its line to `_archiv/TODO_hotove.md` and remove it from both (Pavel 2026-10-06; Claude does not read that archive unless asked).
1. [T01] **Graphics for the ground are DONE (Pavel 2026-10-05): pixen A + walk-through objects** (he tried 100, would take more; tune count/placement/QUALITY later and approve before the final version). Other grounds removed (B had borders; D/E/F/burned village had a repeating "checkerboard" pattern - **watch for repeating patterns in every future ground**).
2. [T03] **Scene camera (2026-10-05; TESTED OK on device 2026-10-06, Pavel: "funguje presne ako som si predstavoval").** One rule for walking AND frozen screens: walkable ground = exactly one screen tall (`Tuning.SCENE_FIELD_HEIGHT` 720 from picture row `SCENE_GROUND_ROW` 350) with the dynamic top strip above it, about one hero tall (`scene_strip_height` 190, panel slider). Vertical scroll is allowed only between "strip gone" (down) and "hero's head at the top edge" (up). Frozen screens (panel button "CELA OBRAZOVKA HLINA", boss/cage fights) differ ONLY by locking horizontal scroll - same vertical logic and game logic as walking (Pavel 2026-10-06). The strip on top is extra height only so the whole hero body stays on screen at the back edge; the real playing area is exactly one screen. Pavel's fallback if the screen feels small: shrink the characters slightly (enemies maybe a bit large). The lock itself (the game locks horizontal scroll at certain places) is agreed and gets built together with bosses and cages, not as a separate task [T13 closed 2026-10-06]. Scene B / burned village was only a graphics test, NOT a decided second scene; number and content of scenes are not decided [T14 deleted].
3. [T02] **DONE 2026-10-06 - hero no longer slides during the axe throw:** `THROW_MOVE_FACTOR` = 0 (cannot walk while throwing; a feature: pick the moment) and `THROW_WINDUP_SPEED` = 3.0 (picked by Pavel on device, baked in `tuning.gd`, sliders stay in the panel). Idea: start the game at a lower wind-up speed (1.0) and let the hero level it up. Later weapons (spells) will need an attack animation tied to movement; the axe is fine as is. No new PixelLab clip needed.
3a. [T12] **DONE 2026-10-06 (art + walk limit), Pavel picked lip 3 + density many; device test OK 2026-10-06, graphics OK for now:** the top edge of `ground_pixen_a.png` was a ruled line at picture row 350. `tools/bake_ground_edge.py` now cuts an irregular edge into the dirt (0-44 px below row 350, so the field is never taller than one screen), darkens it (`--lip 1|2|3`, now 3 = strongest; the edge band is a SOLID colour, no cracks: mean dirt colour darkened, then 3 plain rows) and sets tufts + stones on it (`--density few|mid|many`, now many; Pavel still finds it sparse but parks it - objects are weak prototypes; a barrier object such as a fence on the edge is an idea for the final level design). Edge objects have a height/width limit (`MAX_OBJ_H` 20, `MAX_OBJ_W` 50 art px; tall tufts with a moss blob floated in the air) and tufts need a nearly flat stretch of edge (`MAX_EDGE_SLOPE`). `ground_pixen_a_top.json` is the per-column edge row, so the hero walks along the edge (existing `set_dynamic_top`). Pavel (2026-10-06): tufts look badly planted (maybe the art of tufts/stones is just weak - revisit them for the final art), wants some stones among them, (`python tools/bake_ground_edge.py --preview` renders the variants). Straight source: `ref/ground_pixen_a_straight.png` (local only; script is idempotent). If `bake_pixen_grounds.py` is rerun, delete the straight copy and rerun the edge script after it.
3b. [T05] **DONE 2026-10-05: enemies left behind off-screen are no longer recycled** (Pavel: they must keep existing and chase at their own speed). `ENEMY_CULL_BEHIND` 900 -> 4000 (pool safety only); enemies farther than `ENEMY_COUNT_RANGE` (2200) do not count against `ENEMY_MAX_ALIVE`. Check on device that running ahead and coming back finds them.
4. [T15 closed, T22-T24] **Melee on 2.5D (Pavel 2026-10-06):** overlapping rushers is acceptable ("funny"). Planned: solid bodies like barrels for the hero AND enemies - nothing passes through anybody, collision only on the LOWER ~40% of each body (feet) because the camera is frontal and characters may walk behind each other, replaces the soft `_separate_enemies` push, watch for jams at 32+ enemies (**T22 DONE IN CODE 2026-10-06, awaiting phone test:** every character's collision body is a feet-only box `Tuning.BODY_FEET_WIDTH` 30 x `BODY_FEET_HEIGHT` 22 hanging from its feet; masks include the enemy layer and, for enemies, the player layer; `motion_mode` is FLOATING in free movement (otherwise a body touched from above counts as a floor and drags the other along); `_separate_enemies` returns early while `Tuning.solid_bodies` is on; a brute holding the hero and the hero ignore each other's bodies; barrel/cauldron blocking strips are computed from `body_feet_height` and re-fitted by `main.gd _refit_prop_blocks`; panel switch PEVNE TELA + 2 sliders; headless test: settled penetration <= 2 px, physics cost +1.1 ms/frame with 34 enemies on the cloud CPU; side effect: contact damage from a non-melee enemy body no longer happens because the hero's hurtbox is narrower than the touching feet boxes - brute and thrower hurt through grab/shot only); lock an enemy in place when a swing starts, same as the hero throw, later better enemies get attack-while-moving clips (T24; **fixed in code 2026-10-06, awaiting phone test**: the slide came from `main.gd _separate_enemies` nudging swinging enemies; `Enemy.is_locked()` now pins them and the other enemy takes the whole push); idea for later: enemies path around the hero and can surround him (T23, decide later).
4a. [T25, T26, T27] **2026-10-06 (Pavel's phone test):** T25 barrels now block enemies (enemy mask includes `LAYER_PROP`; awaiting test, watch for enemies stuck behind a barrel wall). T26 rusher REACH is now measured to the hero, not to the offset goal point (the zone was shifted up/down by depth offset + weave, up to +-80 px; the offset now only shapes the approach); reach is still a circle (X = Y), an ellipse with smaller depth reach is a later design call. T27 (closed 2026-10-07, superseded by T33) hero hop after a hit belonged to the rusher only: knockback is per enemy kind in `tuning.gd` (`RUSHER_/THROWER_/BRUTE_HIT_KNOCKBACK`, passed through `melee_hit` -> `take_damage(..., knockback)`; bullets pass none; cauldron blast keeps `PLAYER_KNOCKBACK`). Each enemy should own its hit effect (later slow/poison). T28 (works, Pavel 2026-10-06) enemies walk round obstacles (`enemy.gd _avoid_obstacles`, `Tuning.DETOUR_*`): stuck while wanting to approach -> pick one Y direction (towards the hero's row) until X towards the hero is free again or the field edge (`Player.walk_y_limits`) is reached, then turn. T29 (approved by Pavel 2026-10-06; round 2 after his phone test, awaiting test): the rusher's strike zone is a CIRCLE in screen space centred where the club lands: `RUSHER_STRIKE_FORWARD` 40 px in front of the rusher, `RUSHER_STRIKE_HEIGHT` 50 px above its feet, `RUSHER_STRIKE_RADIUS` 40 px (Pavel's ideal values 40 / 50 / 40, DONE 2026-10-06). The hero is hit if his hurt rectangle (`Player.hurt_rect`, hung from his feet) touches the circle (`enemy.gd _hero_in_strike`, `_strike_connects`). The rusher stops to swing as soon as the hero touches the circle (stays stopped within `RUSHER_MELEE_LEAVE_FACTOR` x radius); the old stop-distance slider is gone from the panel (`rusher_melee_range` only serves the non-free legacy branch). Panel: 3 sliders + toggle `UKAZ ZONU UDERU BEZCA` (circle overlay while swinging). T30: bottom strip halved (`WALK_BOTTOM_INSET` 10 px, was the shared 20; top still 20; panel slider `odstup od SPODNEHO okraja`; hero and enemies); no enemy pixel below the playing field (`Enemy.clamp_to_field`, bottom limit = hero's `Player.walk_y_limits`, also called after `_separate_enemies`); top is not limited yet.
4b. [T33 DONE and tested 2026-10-07; T31/T32 tested and closed; T27 closed] **T33 push (Pavel 2026-10-07):** a hit moves the victim a set distance along the attack (`Tuning.push_vector`, depth part x0.6, over `knockback_time` 0.22 s, linear slow-down; running push is added after `move_and_slide` via `move_and_collide`, `velocity` untouched so the control feel is unchanged): rusher club -> hero 90 px (`melee_hit` carries the push, `Enemy.hit_push`), gunman bullet -> hero 35 px (`bullet.gd`), brute pushes nothing and cannot be pushed; hero's axe -> enemy 70 px (`hit_from(travel, dist)`; the axe's way BACK counts too, panel factor `axe_return_push_factor`, Pavel unsure how it will look), a pushed enemy is stunned (attack/shot dropped, no walking). Barrels/cauldrons are NOT pushed (open idea). The cauldron blast keeps the old velocity hop (`PLAYER_KNOCKBACK`). God mode skips the hero's push. Panel block ODHODENIE PO ZASAHU. **Older ideas and tasks recorded 2026-10-06 (Pavel: only record, do not start; full wording in `KDE_JE_CO.md`):** T31 shadows under characters/props (**DONE IN CODE 2026-10-06, awaiting phone test:** `shadow.gd`, flat ellipse child with its own absolute z `Tuning.shadow_z` = ground z + 3 so it lies under every character; width from drawn height `SHADOW_WIDTH_PER_HEIGHT` 0.55; barrel/cauldron lose it when destroyed; panel: strength + size); **2026-10-06 phone test (Pavel): values baked** - shadow strength 0.3 (size 1.0), sound volume jitter 2.5 dB, pitch 25 %. **Panel PAUZA reworked into ZMRAZIT SVET (hybe sa len hrdina):** tree pause with `main.gd` ALWAYS and enemies, cauldrons, enemy shots, spawner PAUSABLE (hero, his axe/shots, effects, sounds keep running) - for testing solid bodies. T32 random volume + pitch on sounds (**DONE IN CODE 2026-10-06, awaiting phone test:** pitch randomness already existed in `sfx.gd` (effects +-8 %, voices +-3 %); added per-play volume +-1.5 dB effects / +-1 dB voices; panel: 2 sliders); T33 two-way knockback along the attack direction, scaled by weapon strength (currently rusher-only, X away from the rusher, Y always up); T34 swing/slash arc visual on attacks and hits (to try); T35 airborne ambience (leaves, rain, snow, fog; sizes 1x/2x/3x); T36 how enemies vanish on death (smoke?); T37 dust/snow/smoke puffs behind walking characters (to try); T38 airborne flight faked with a linear ground shadow; T39 wind on flags/grass/fog/smoke; T40 shaders for light areas (torch, fire, cauldron blast) and fog.
4c. [2026-10-07, TESTED OK by Pavel] **Pavel's batch after the T33 test:** pevne telo 60 x 30 baked (`BODY_FEET_WIDTH` 60, `BODY_FEET_HEIGHT` 30; barrel/cauldron strips derive from body width via `BODY_FEET_REF_WIDTH`); asymmetry fix = `main._refit_prop_blocks()` refits ALL bodies incl. frozen enemies (`refit_body()`); `knockback_time` 0.4 s; **axe**: `AXE_RETURN_HURTS` false (damage + push only while OUT), back flight alpha `AXE_RETURN_ALPHA` 0.5, `AXE_RETURN_FACTOR` 1.5, own shadow; **cauldron blast** pushes the hero `CAULDRON_PUSH_DIST` 140 px (god mode still blocks it); `free_move_y_ratio` default 1.0 (was 0.6, vertical was slower on purpose, slider kept); **hearts** `hearts.gd` (`Tuning.hearts_mode` 0/1/2); **panel declutter**: `tools/panel_catalog_dump.gd` + `tools/panel_catalog.py` (build/import `PANEL_prvky.xlsx`), `scripts/panel_hidden.gd` (generated, key `type|name`), `debug_overlay._apply_hidden()`. The old `PLAYER_KNOCKBACK` velocity hop and `axe_return_push_factor` are gone. Ideas recorded (not started): T41 stun/knockdown animations, T42 effect catalog per enemy, T43 axe boomerang upgrade. **T46:** `Debug.show_hit_zones` (panel UKAZ ZONY ZASAHU: axe circle, enemy/hero hurt rects), `Tuning.axe_hit_radius` live; left stick anchor slides (`free_move_anchor_slides`, `touch_controller._update_left_free`). **Baked after test:** axe hit radius 20, HP rusher 2 / thrower 1 / brute 1. **T47** (later, final tuning): left stick feel for boss freeze fights.
5. [T16, DONE 2026-10-06, flicker and sliding gone on device] **Rusher flicker after a swing** when the player moved on Y. **Fixed in code 2026-10-06.** Cause: at the melee-range boundary the rusher alternated stop/walk every frame (single range threshold, goal point wobbling with the weave, single speed threshold for the clip). Fix in `enemy.gd`: `_stopped` hysteresis (`Tuning.RUSHER_MELEE_LEAVE_FACTOR` 1.2, so a standing rusher also reaches ~120 px), weave frozen while standing, walk clip on above `RUSHER_WALK_START_SPEED` 40 / off below `ENEMY_WALK_SPEED_MIN` 12. If it still flickers: test with the panel melee-range slider and report what the player was doing.
6. [T17] **IMPORTANT: unify the colour palette** across background, enemies, props. PixelLab is the primary source but the palette is not unified. MUST be solved BEFORE generating final game graphics; for prototypes it can stay open (Pavel 2026-10-06).
7. [T07] **Second device with different DPI** (control criterion 5) - all control tuning is verified only at 450 dpi.
8. [T18 closed 2026-10-06] Gunman needs no idle clip (he just stands); brute grab animation mismatch is parked. Not solved now: unknown whether these characters survive to the final version.
9. [T05] **Items "not yet on device":** HP raise, hit effects round 2, sound system, explosive cauldron, brute, round after first device test - check on the next deploy.
10. [T08] **Google Play:** policy/IARC review is Pavel's parallel track; Developer account deferred; closed testing (12 testers / 14 days) is F4. Licence/credit questions for generated assets still open.
11. [T19 deleted 2026-10-06] Phases F2-F5 are the production plan in `PLAN_hry.md`, not tasks; when all tasks are done, take the next step from the plan.

12. [T04] **STORY v5 TAKEN OVER 2026-10-15** (Pavel worked on it with another AI and will keep editing it). Source: `20261015 - Handoff Slavs fight back.md` + the two HTML dashboards in the root; everything older is in `_archiv/pribeh_stary/`. Decisions made after the handoff are in `PRIBEH_rozhodnutia.md` and win over it. **Now (Pavel 2026-10-15): the story is finished before any generation, character by character** (motivation, goal, role, relations - one card per character in `PRIBEH_rozhodnutia.md`; Zora and Vlad DONE, next character Pavel's choice). Generating scene pack S01-S10 of story §10 [T54] waits for that. Open inside the story: `PRIBEH_rozhodnutia.md` -> Otvorené, and handoff §12 (Vojtek's name, L5/L6 bosses, L8, names Jarek/Radim, scope 9 vs 7-8 levels, guard marker, final form core + roguelite) + the rage name VOLYA. **Conflicts between story v5 and the game as built - Pavel decides; until then the built and measured state stays in code:** (a) playing field: story says "bottom of screen + 1.5 screen heights", the game has one screen + top strip, tested OK (T03); story §4 itself says the controls SPEC wins, so T03 stays; (b) blood: story wants particles fading in ~2 s and no persistent pools, the game has longer blood stains (package 2); (c) hero weapons: story has melee / ranged / thrown gear, our standing decision is no hero melee (thrown axe); Pavel 2026-10-16: weapons will be varied, the axe is only the prototype the game was built on (melee itself not decided); (d) rage: Pavel's idea 2026-10-16 (Vlad card, T09): rage is the core emotion - injustice episodes in levels fill the bar, then a massacre phase; outside rage the game is slow and oppressive, which would change design pillar 1 - decide consciously in T09; story makes it an ~8 s screen-clear filled by freeing prisoners, the archived core loop of 2026-07-31 had rejected a screen-clear rage - story wins on paper, rage is not built yet; (e) title: story says VOLYA, the title stays Slavs fight back; (f) endless arena "Jama" of the old plan is not in the story. **Risk raised once (Pavel's own rule "no immigration frame"):** in Act III the "sworn" are Ordan's men among eager volunteers nobody knows, with a secret mark - the thread most likely to be read as an infiltration/immigration frame. Keep the sworn defined only by paid political loyalty to Ordan, never by origin or look, and keep this thread out of store copy.

### Standing decisions (keep; reasons are in history)
- **Style = pixel art. Do not re-raise smoothing / S = 2 / LINEAR filtering without asking Pavel the style question first, in those words** (reverted 2026-08-13). If a technical step changes how the game looks, say so out loud and wait for an answer.
- **All art in PixelLab** (see banner). Show Pavel the base sprite for approval before animating. Generate only the `east` direction, mirror enemies to face west, pad clips on one canvas, hard alpha, hold frames in `frames.gd`. Tool: `tools/pixellab_export.py`. Balance: Tier 1, 2000 generations/month - save credits, check `get_balance`.
- **Outlines come from the body colour** (ring darkened 0.55), not black; coarse pixels rejected. Reopen only if the player cannot tell which objects are interactive.
- **Backgrounds:** the ground is never in the parallax layer array; walkable field = numbers mapped onto the picture; vertical scroll scale stays 1.0. Contrast rule: walk band luma >= 80, character-to-band difference >= 35 (`tools/check_contrast.py`). Ground look: the PixelLab ground texture, calm, grass always grows from a moss patch; Nano Banana grounds rejected.
- **METHOD:** (1) anything about a picture is decided from a picture (numbered contact sheet, Pavel says a number); (2) anything about a number is measured, not guessed; (3) a tool that ends in "look at these" must produce the picture itself; (4) test a new animation next to the player; (5) check contrast against the background for every new character; (6) before testing a pipeline stage check the input has not already been through it; (7) state lives in logic, not in drawing code.
- **Combat design:** no hero melee (mass shooter has no time for dodging single swings; story v5 lists melee gear - conflict, Open item 12c). Enemy attack = commitment: velocity zero while attacking. Enemy hurtboxes are sized from the DRAWN height. Depth sort by world Y (`Tuning.depth_z`).
- **Enemy rules:** two idles per enemy type (unaware vs ready); roles/factions never ethnicity (turban/glowing eyes removed from rusher and gunman, the ethnicity TODO is closed for both - applies to every new enemy). Hero is Vlad; setting is fictional Central Europe ~1420-1480 (story v5, 2026-10-15).
- **Headless check before every push:** Godot 4.7.1, `--headless --import`, then `--quit-after N` with a temporary test appended to a COPY of `main.gd`; `xvfb-run ... --rendering-driver opengl3` for screenshots (method in history, "Hero weapon" entry).
- **Everything is a prototype for now (Pavel 2026-10-09):** all sounds (placeholders, synthesised pot sounds) and every other game aspect get a full review at final tuning; do not polish or re-raise them before then.
- Pavel's one-line verdicts on device are the acceptance test; "zatial mi to nevadi" means parked, not forgotten.
