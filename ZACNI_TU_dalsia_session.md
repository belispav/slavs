# Start of the next session (updated 2026-10-07)

Project Slavs. Read `CLAUDE.md` (short now; full history in `_archiv/CLAUDE_historia.md`, read only on demand).
Communicate in Slovak; code and commits in English. Use the `token-saver` skill.
Starting a session: `git pull` first. Ending: commit and push to `master`.
Local Claude Desktop and cloud both work - never in both at once.

CLAUDE.md was shortened on 2026-10-05 (done, no longer a task).

## WORK PACKAGES (Pavel 2026-10-07) - read `BALIKY_poradie.md` FIRST
Pavel now works in packages of ToDo items, each in a clean Sonnet session. `BALIKY_poradie.md` says which package is NEXT (now: **Package 3 - Féroví a čitateľní nepriatelia**: F2, D4, T42; Packages 1 and 2 are closed), what already exists in code, and how to close a package. Work only on that package unless Pavel says otherwise. Package 3 status 2026-10-10: dirt variants built (see `BALIKY_poradie.md`), phone test pending; F2 + D4 built 2026-10-10 (phone test pending), T42 catalog started; then close the package. Research ideas with codes A1...Z8: `NAPADY_vylepsenia.md`.

## What comes next (Pavel's call; he brings device-test feedback himself)
IDs [T..] = Pavel's ToDo list, see `KDE_JE_CO.md`.
1. [T12] DONE 2026-10-06 (irregular dark edge with low objects, hero walks along it; see CLAUDE.md 3a). Nothing left to do unless Pavel's phone test finds a problem.
2. [T09] Core mechanics (what ends a run, cage economy, upgrades, unlocks, weapon switching) - marked active, but Pavel decides WHEN to start. Do not start it unprompted.
3. [T07] Pavel tests on another phone in the coming days (controls + screen at another aspect ratio); wait for his feedback.
4. [T04] **TODO - story rework (Pavel, 2026-10-05).** Pavel works on a new story offline, no rush. Do not start it; wait until he brings his draft. Draupnir material in `_archiv/draupnir_koncept/` is not agreed.
5. [T22, T25, T26, T28-T33, T45, T46] DONE and tested on phone 2026-10-06/07 (details in `_archiv/TODO_hotove.md`). Baked 2026-10-07: solid body 60x30, push 0.4 s, axe hit radius 20, axe damages only OUT, HP rusher 2 / thrower 1 / brute 1. **[T44] waits for Pavel** (`PANEL_prvky.xlsx`, A/N column; then `python3 tools/panel_catalog.py import`). [T34-T43, T47] are ideas / final-tuning notes only, not started (T41/T42 stun + effect catalog: when tuning final characters; T47: left-stick feel for boss freeze fights).

## State after package 1 (2026-10-08)
Default game now starts with brutes OFF and max 1 gunman (`debug_state.gd`; Pavel's wish, panel can turn them back on). New open items from the package-1 test: **T48** enemies get stuck at a barrel/cauldron near the screen edge (seen: 4 rushers stacked above each other at a cauldron, endlessly dodging each other) - Pavel said "we tune this later", do not start unprompted; T49 vibration by attacker/lives lost; T50 weapon features list (crit chance per weapon); T51 damage number font + size at final tuning.
