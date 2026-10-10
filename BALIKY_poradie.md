# BALIKY - work packages, order and status (read this at the start of every session)

Created 2026-10-07 (Opus session, from the research `NAPADY_vylepsenia.md`). Pavel works each
package in a **clean session with Sonnet**. This file tells that session which package is next,
what is in it, what already exists in code, and how to close it. Pavel's dashboard shows the same
plan (`KDE_JE_CO.html`, section "Balíky", and chip filter "Balík" in ToDo's).

## Current state

| # | Package (Slovak name for Pavel) | Status |
|---|---|---|
| 1 | Úder má váhu | DONE 2026-10-08 |
| 2 | Smrť nepriateľa a stopy boja | DONE 2026-10-09 (A9, T36, A10, A12, A11; tested by Pavel). Rusher/gunman fall by PixelLab clips, brute bursts, slow-mo, ceramic pots (first extra breakable prop; fences/tents later), randomness everywhere (rule 3b) |
| 3 | Féroví a čitateľní nepriatelia | **NEXT** (in progress 2026-10-10: dirt variants tested by Pavel, final numbers pending; F2 + D4 done in code, awaiting phone test; T42 catalog started in `KATALOG_efektov.md`) |
| 4 | Prvá odmena: zber a séria (+ T09) | waiting |
| 5 | Hrdina v pohybe | waiting |

Order agreed by Pavel 2026-10-07: 1 -> 2 -> 3 -> 4 -> 5. When a package is closed, set it to DONE
here and the next one to NEXT. Pavel may come back with feedback or reorder; his word wins.

## Rules for every package session

1. Start: `git pull`, read `CLAUDE.md`, then this file. Work ONLY on the package marked NEXT
   (or the one Pavel names). Do not jump ahead into other packages or other ToDo items.
2. Item codes (A1, E1, T36 ...) are permanent; full wording, importance and sources are in
   `NAPADY_vylepsenia.md` and in the ToDo of `KDE_JE_CO.md`. Content rules of `PLAN_hry.md` §2 always apply.
3. Pavel has zero game-dev knowledge: Slovak, plain words, one question at a time, 2-3 sentences
   after each step on what changed. Code/comments/commits in English.
3b. **Randomness (Pavel 2026-10-09):** every enemy behaviour and effect varies a little per instance by default (`Tuning.jitter`, panel NAHODNOST scales it); see CLAUDE.md working rule 7.
4. Every new effect gets an **on/off switch and a strength slider in the debug panel** (existing
   pattern: Pavel tunes live on the phone, confirms, then the value is baked into `tuning.gd`).
   Add new panel elements to the panel catalog (`tools/panel_catalog.py`, `PANEL_prvky.xlsx`) the same way as existing ones.
5. Build and deploy for Pavel's phone test as usual (`PRIKAZY.md`). Package is closed only after
   his phone test.
6. Closing a package: bake the confirmed values; move every finished or rejected code from
   `KDE_JE_CO.md` + the `TODOS` array in `KDE_JE_CO.html` to `_archiv/TODO_hotove.md` (rejected = note "zamietnuté");
   items Pavel postpones stay open; set status here and in the dashboard `BALIKY` array; update
   `ZACNI_TU_dalsia_session.md`; commit and push.
7. New ideas or feedback from Pavel that are not in the package get the next T-number
   (see `KDE_JE_CO.md`) and are NOT built in the same session unless he says so.
8. Never run the local Claude Desktop session and a cloud session at the same time (git conflicts;
   a stuck `.git/index.lock` blocks commits).

## Package 1 - Úder má váhu (hit feel) - DONE 2026-10-08

Closed after Pavel's phone test. Baked: hit-stop 30 ms, white flash 40 ms, shake and kick x1.5, axe-hit buzz 200 ms, damage number size 16, crit 15 %. Code: `enemy.gd` signal `weapon_hit` (only hero-weapon hits) -> `main.gd _on_weapon_hit`; numbers in `fx.gd`; white flash = shared shader material on the sprites (`enemy.gd _set_white`). Note for package 2: a killed enemy is hidden at once, so the white flash is not seen on kills - the corpse visual belongs there. Open: T48 (enemies stuck at barrels/cauldron near the screen edge, esp. bottom), T49 vibration by attacker, T50 weapon features list, T51 damage number font. Original brief below (kept for reference).

Codes: **A1** hit-stop, **A2** full white hit flash, **A3** screen shake also on axe hits/kills,
**A4** small camera kick in the throw direction, **A5** damage numbers, **A6** critical hit,
**A8** hit sound by material, **E1** vibration when the hero's axe hits, **P1** switches for the
effects (panel now; a real settings menu later). Also **A14**: already in the game (hero
invulnerable 0.9 s after a hit, red blinking: `Tuning.PLAYER_IFRAMES`, `player.gd`); ask Pavel
to confirm and then archive it as done.

What already exists (checked 2026-10-07):
- Enemy hit flash exists but is weak: `enemy.gd` `_flash` (set 1.0 in `damage()`, fades `delta*6`)
  lerps the tint only to `Color(1.0, 0.96, 0.92)` (~line 1137). A2 = truly white for 1-2 frames.
- Screen shake exists: `player.shake(strength)` (camera offset decays `delta*40`), used only by
  the cauldron blast (`main.gd` ~1291, `player.shake(14.0)`).
- Vibration exists: `main._vibrate(ms)` with `VIBRATE_MIN_GAP`, `vibrate_enabled`,
  `vibrate_strength`, used only when the hero is hit. E1 = short, weaker buzz on axe hits.
- Hit particles exist: `fx.gd` `body_hit`, `wood_hit`, `sparks`, `explosion`. Sounds by event in
  `slavs/audio/sfx/<event>/` (there is `armor_clang`, `enemy_hit`, `barrel_hit`); `sfx.gd` plays them.
- NOT present: hit-stop, damage numbers, critical hits.

Notes: hit-stop 30-80 ms (Vlambeer uses 10-20 ms per hit), longer on kills/crits. If done with
`Engine.time_scale`, make sure the touch controls, the debug panel and the timer that restores the
speed are not frozen by it; alternative is freezing only the hit enemy + hero animation. Test with
30+ enemies: many hits per second must not make the game stutter (cap hit-stop frequency).
Effort: low, code only, no PixelLab credits.

## Package 2 - Smrť nepriateľa a stopy boja - DONE 2026-10-09

Closed after Pavel's phone test. Code: `corpses.gd` (pooled corpse visuals: PixelLab clips `art/rusher_pl_death`, `art/gunman_pl_death`; brute `burst()` into pieces), `main.gd _try_slowmo` / `_hitstop_tick`, `fx.gd` stains (`FX_STAIN_TIME` 12 s) and smoke puff; props: `barrel.gd` serves barrels AND ceramic pots (`art/pot_pl`, sounds `pot_hit`/`pot_break` are synthesised placeholders, `tools/make_pot_sfx.py`), `main.gd _place_barrel_once` scatters 3 barrels + 3 pots at random (no wall), two size classes x +-5 %. Randomness: `Tuning.jitter`, `RAND_*` (power, anim, linger, slow-mo, white flash, SIZE 5 % for enemies and props), panel slider NAHODNOST. Open: pot art is 1 base + 1 clip only (cheap prototype); more prop kinds (fence, tent, crate) with final art/palette T17; real ceramic sounds. Original brief below.

Codes: **A9** death with a punchline (body flies along the hit, spins, lands, bounces),
**T36** how the body disappears (smoke?), **A10** short slow-motion on the last kill (e.g. last
enemy on screen or a brute), **A12** longer-lasting battle marks, **A11** more breakable props.
Existing: an enemy that dies calls `despawn()` at once (`enemy.gd damage()`), enemies are POOLED
and counted against `ENEMY_MAX_ALIVE`, so the corpse must be a separate visual (e.g. in `fx.gd`),
not a living enemy. Blood stains last `FX_STAIN_TIME` 3 s. Barrels/cauldrons already break.
Effort: low-medium, can be done in code without new PixelLab clips.

## Package 3 - Féroví a čitateľní nepriatelia (only the cheap part now)

Codes now: **F2** warning before every enemy attack (wind-up tint/blink + sound at the start of the
swing/aim/grab), **D4** own warning sound per enemy type, **T42** start the effect catalog (a
section in a doc listing effects enemies can have on us and we on them; first entries: push T33,
stun and knockdown T41). Later, with final art and palette (T17): C1 readability in crowds, F1
silhouettes, T41 animations. Existing: rusher swing clip, thrower fire clip (muzzle flash on frame
5), brute grab (`enemy.gd _think_*`). Sounds need new files (CC0 / ElevenLabs SFX), ask Pavel.

**FIRST THING in package 3 (Pavel 2026-10-09): enemy variety by dirt - DONE IN CODE 2026-10-10, awaiting phone test.** Built as `slavs/scripts/enemy_dirt.gd` (`EnemyDirt`): 5 baked SpriteFrames variants per kind (rusher, thrower=gunman, brute) with 32 mud-brown spots (`Tuning.DIRT_COLOR`, weight `dirt_weight` 0.8; 1-3 px; blended with `Image.blend_rect` + `blit_rect_mask`, only on opaque pixels, same pixels on every frame of a variant); `enemy.gd _register_dirt` / `_apply_dirt` (spawn picks a variant, death clip carries the same dirt, corpses/bursts get it through the frame texture); panel: switch SPINA NA NEPRIATELOCH + slider spina: pocet skvrn (0-80), count is also scaled by NAHODNOST; changing the slider re-bakes lazily at the next spawn. Headless test: bake 9-19 ms per kind on the PC, 5 distinct variants, spots only on opaque pixels, clean sheet restored when the switch is off. Preview tool: `tools/preview_dirt.py` (`ref/dirt_preview_mud.png`). Phone test 2026-10-10: looks good; 32 spots showed nothing, so slider is now 50-200 (default 80) and the brute's head (top 25 % of the body, `Tuning.DIRT_HEAD_FREE`) stays clean; final numbers to be confirmed by Pavel at the next check. Open after the phone test: strength/colour (rusher is brown so spots show little), bake values into `tuning.gd`, then archive. Original plan text follows:  Pavel's idea: more randomness for the mass-shooter crowd without a design change. Colour shade +-5 % (`RAND_TINT`) and size +-5 % (`RAND_SIZE`) are already done. Next: a few dark "dirt" pixels on clothes and helmets. Plan: at game start bake 4-5 variants of each enemy's `SpriteFrames` (rusher, gunman, brute) with random dark/dirty pixels placed only on already opaque pixels, the same pixel positions on every frame of a variant; at spawn pick one variant (no per-frame cost, no PixelLab credits, only a little load time and memory). The spots are fixed to the canvas, so they may "swim" a little on the body while walking - keep them small. Colour swaps of whole items (helmet, clothes) would need a palette-swap shader: separate, harder step, ask Pavel first. Use `Tuning.jitter` / panel NAHODNOST rules (CLAUDE.md rule 7); add a panel switch with a description. Also still open from package 2: real ceramic sounds (the pot sounds are synthesised placeholders).

### Package 3 progress 2026-10-10 - F2 warning + D4 warning sounds (done in code, awaiting phone test)
`enemy.gd`: `_start_warning(duration, event)` / `_update_warning` blink the visible sprite between its shade and `Tuning.WARN_COLOR` (1.9, 0.75, 0.65), `WARN_BLINK_HZ` 8, jittered by `RAND_WARN` 0.2, and play `warn_rusher` / `warn_thrower` / `warn_brute` (placeholder wavs from `tools/make_warn_sfx.py`, replace at final tuning). Rusher: blink from swing start to the hit moment; gunman: during `THROWER_SHOT_DELAY`; brute: NEW wind-up `Tuning.brute_windup` 0.4 s (0 = old instant grab) in which it stands still, and the grab happens only if the hero is still in reach (`_begin_grab`), else `BRUTE_WINDUP_RECOVER` 0.8 s pause. A pushed enemy drops its warning. Panel: switches VAROVANIE PRED UTOKOM + ZVUK VAROVANIA, sliders sila blikania and obor: vymah. Headless test: blink on/off and restore OK; brute wind-up -> grab OK; stepping away during the wind-up -> no grab. Phone test: is the red blink readable in a crowd, is 0.4 s enough for the brute dodge, is 8 Hz right. Then bake values, archive F2/D4 (T42 stays open as a growing catalog) and close the package.

## Package 4 - Prvá odmena: zber a séria (together with T09)

Codes: **A15** rewards fly to the hero (magnet), **D1** signature pickup sound, **A16** rising
pitch in a series, **J4** kill streak with multiplier, **H1** visible danger to captives,
**H3** rescue rating. Depends on **T09** (what ends a run, cage economy, currency). Start with the
T09 questions to Pavel, one at a time; do not write reward code before he decides the basics.

## Package 5 - Hrdina v pohybe

Codes: **B1** dash with short invulnerability, **T37** dust behind feet, **B2** squash & stretch,
**A17** red screen edge + heartbeat at low health. Later: T23 (surrounding), T47 (left stick final
tuning). WARNING: B1 changes the controls; `SPEC_ovladanie_implementacia.md` is the single source
of truth ("Zero Thumb-Lifting"). First propose gesture options to Pavel (one question), test the
conflict with jump/aim, only then build. `fx.gd` already has `_puff` (usable for T37).
