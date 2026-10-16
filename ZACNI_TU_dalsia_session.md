# Start of the next session (updated 2026-10-15)

Project Slavs. Read `CLAUDE.md` (short now; full history in `_archiv/CLAUDE_historia.md`, read only on demand).
Communicate in Slovak; code and commits in English. Use the `token-saver` skill.
Starting a session: `git pull` first. Ending: commit and push to `master`.
Local Claude Desktop and cloud both work - never in both at once.

CLAUDE.md was shortened on 2026-10-05 (done, no longer a task).

## STORY SESSION (updated 2026-10-15 evening) - read first if the topic is the story
**Cards DONE: Zora (2026-10-15), Vlad (2026-10-16). Next character: ORDAN** (Pavel 2026-10-16), after Pavel confirms the Vlad card.
Pavel finishes the story before any generation, going character by character: motivation, what he/she is after, role, relations to the others. Read `PRIBEH_rozhodnutia.md` FIRST (section Postup, the Zora card as the model for a card, decisions table, Otvorené) - it wins over `20261015 - Handoff Slavs fight back.md`; then the handoff only for the parts you need (cast §5, levels §6, Zora §7, set pieces §8, §12). Do not edit the two story HTML dashboards; the v5 one uses old names (Radko = Vojtek, Mstislav = Jarek, Bohuš = Bohdan).
How to work: first list everything the files say about the character (as was done for Zora), then let Pavel react; record his answers as a card in `PRIBEH_rozhodnutia.md` AND update his dashboard `POSTAVY_karty.html` (same content, plain Slovak; move the character from 'neprejdené' to a full card, fix the counts in the tiles), one question at a time, flag weak spots briefly. When a new card changes an older one, update the older card too, in the md AND the dashboard (Pavel 2026-10-16). Next planned: ORDAN. Read the Zora and Vlad cards before any other card - other characters are defined against them (Vlad pushes people to take responsibility; Zora senses whether statements are true; truth differs per person).
Not now: currency, why replay, cages, how a level ends (T09) - Pavel is still thinking.
Commit every change; Pavel pushes himself (`git push`; the device shell has no GitHub login, and git there leaves `.git/*.lock` files - move a stale one away, e.g. `mv .git/HEAD.lock .git/stale-HEAD-lock`).

## WORK PACKAGES (Pavel 2026-10-07) - read `BALIKY_poradie.md` FIRST
Pavel now works in packages of ToDo items, each in a clean Sonnet session. `BALIKY_poradie.md` says which package is NEXT (now: **Package 4 - Prvá odmena: zber a séria (+ T09)**; Packages 1, 2 and 3 are closed), what already exists in code, and how to close a package. Work only on that package unless Pavel says otherwise.

## What comes next (Pavel's call; he brings device-test feedback himself)
IDs [T..] = Pavel's ToDo list, see `KDE_JE_CO.md`.
1. [T12] DONE 2026-10-06 (irregular dark edge with low objects, hero walks along it; see CLAUDE.md 3a). Nothing left to do unless Pavel's phone test finds a problem.
2. [T09] Core mechanics (what ends a run, cage economy, upgrades, unlocks, weapon switching) - marked active, but Pavel decides WHEN to start. Do not start it unprompted.
3. [T07] Pavel tests on another phone in the coming days (controls + screen at another aspect ratio); wait for his feedback.
4. [T04] **Story v5 taken over 2026-10-15.** The story is in `20261015 - Handoff Slavs fight back.md` (+ two HTML dashboards in the root, do not edit them). Old story material is in `_archiv/pribeh_stary/`. Open points and conflicts with the built game: CLAUDE.md Open item 12. Next step: generate scenes/levels and characters, first batch S01-S10 of story §10 [T54].
5. [T22, T25, T26, T28-T33, T45, T46] DONE and tested on phone 2026-10-06/07 (details in `_archiv/TODO_hotove.md`). Baked 2026-10-07: solid body 60x30, push 0.4 s, axe hit radius 20, axe damages only OUT, HP rusher 2 / thrower 1 / brute 1. **[T44] waits for Pavel** (`PANEL_prvky.xlsx`, A/N column; then `python3 tools/panel_catalog.py import`). [T34-T43, T47] are ideas / final-tuning notes only, not started (T41/T42 stun + effect catalog: when tuning final characters; T47: left-stick feel for boss freeze fights).

## State after package 1 (2026-10-08)
Default game now starts with brutes OFF and max 1 gunman (`debug_state.gd`; Pavel's wish, panel can turn them back on). New open items from the package-1 test: **T48** enemies get stuck at a barrel/cauldron near the screen edge (seen: 4 rushers stacked above each other at a cauldron, endlessly dodging each other) - Pavel said "we tune this later", do not start unprompted; T49 vibration by attacker/lives lost; T50 weapon features list (crit chance per weapon); T51 damage number font + size at final tuning.
