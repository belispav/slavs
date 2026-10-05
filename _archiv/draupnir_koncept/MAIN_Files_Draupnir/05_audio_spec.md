# 05 — AUDIO SPEC (Audio Designer Agent)

> **Agent role:** Audio designer. Produce the complete music, SFX, and voice-over specification.
> **Inputs:** `SPEC_MASTER.md` (canonical), `art_bible.md` (mood/asset IDs), `narrative_script.md` (VO lines).
> **Gate:** `GATE E` (human) after this package.

---

## 1. Goal

Specify every sound in the game so an audio-production agent can create/compose with no ambiguity, fully compliance-safe.

---

## 2. Inputs

| Input | File | Required? |
|-------|------|-----------|
| Canonical spec | `SPEC_MASTER.md` §2 (characters), §4 (worlds), §9.2 (audio compliance) | Yes |
| Art bible | `art_bible.md` (world moods, boss VFX cues) | Yes |
| Narrative script | `narrative_script.md` (every VO line) | Yes |
| Compliance authority | `.inbound/.../Gemini - Analyza pravidiel Google Play.md` §1.2 (audio stereotypes) | Yes |

---

## 3. Rules & Constraints

### 3.1 Hard rules `[HARD]`
- **No real religious chants, prayers, or sacred music** in any context. `[HARD]`
- **No ethnic/linguistic caricature.** No mocking a real language, accent, or musical tradition. `[HARD]`
- **Enemy "foreign" voice** = a **fictional invented language** ("collar-speech"), not a real language or a parody of one.
- **No gore SFX** (no bone-cracking, no wet dismemberment sounds). Hits = metal/impact/energy.
- **No audio that implies torture** as an interactive mechanic.

### 3.2 Style rules
- Music: original compositions inspired by Slavic folk motifs for the hero's side; fantasy/orchestral for the Empire. The "East" of the game world is FICTIONAL — do not use real regional religious motifs.
- Each world (W1–W5) has a distinct musical identity per SPEC_MASTER §4 moods.
- SFX layer must distinguish: player weapons, enemy attacks, magic, pick-ups, UI, collars breaking.
- VO: minimal, terse, matching narrative_script.md exactly.

### 3.3 Coverage rule
- Every asset in `art_bible.md` asset master list that is audible (weapons, enemies, bosses, pick-ups, VFX) MUST have a corresponding SFX entry. No audible asset without a sound.

---

## 4. Outputs

Produce ONE file `audio_spec.md`.

### 4.1 Music spec (per world + per run variation)
| Track ID | World | Mood/description | Tempo | Duration | Instruments/motifs | Run variation (if any) |
|----------|-------|------------------|-------|----------|---------------------|------------------------|
Plus: main theme, boss themes (5), menu theme, epilogue theme.

### 4.2 SFX list
| SFX ID | Trigger (asset/event) | Description | Layer (UI/world/combat) | Fictional/invented? |
|--------|------------------------|-------------|-------------------------|---------------------|
Cover: all weapons (9 legendary + categories), 6 abilities, 4 Sparks, pick-ups (Fragments, health), collar-break, explosions, blood-fade (subtle), enemy attacks per type, boss attacks, UI clicks, level transitions, anomaly/portal.

### 4.3 VO list
| VO ID | moment_id (from narrative_script) | Speaker | Line (verbatim) | Tone direction |
|-------|-----------------------------------|---------|-----------------|----------------|
Cover EVERY dialogue line in narrative_script.md (cinematics, level beats, boss lines, NPC lines). No line omitted.

### 4.4 Fictional "collar-speech" spec
- Phonetic rules for the invented enemy language (vowels/consonants/melody), so it sounds consistent but matches no real language.
- Sample "phrases" and what they mean (grunt/alert/command).

### 4.5 Mixing & implementation notes
- Volume hierarchy (music < SFX < VO), ducking rules, loop points, streaming vs. memory-resident.

---

## 5. Output Format

- Single `audio_spec.md`, UTF-8, English.
- Tables for music/SFX/VO. VO lines copied verbatim from narrative_script.md.

---

## 6. Quality Checks (self-run before submitting)

- [ ] Music spec covers all 5 worlds + 5 boss themes + main/menu/epilogue.
- [ ] Every audible asset in art bible has an SFX entry (no orphans).
- [ ] Every VO line in narrative_script.md has a VO entry (no omissions).
- [ ] No real religious chant/prayer, no ethnic caricature, no gore SFX.
- [ ] Collar-speech spec is clearly fictional and self-consistent.
- [ ] No `TODO`/placeholders.

---

## 7. Human Checkpoint — GATE E

Human must verify:
1. No real religious/ethnic audio content.
2. Collar-speech is clearly invented, not a parody.
3. Full coverage (music/SFX/VO complete).
4. Tone matches world moods.

**Rejection → return with reasons.**
