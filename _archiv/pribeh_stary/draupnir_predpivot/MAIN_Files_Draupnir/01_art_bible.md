# 01 — ART BIBLE (Art Director Agent)

> **Agent role:** Art Director. Produce the visual foundation every other discipline references.
> **Inputs:** `SPEC_MASTER.md` (read first). Optional: `game-design-doc-storm-in-chains.md` for flavor.
> **Gate:** `GATE A` (human) after this package.

---

## 1. Goal

Produce a complete, unambiguous art bible so that asset-production agents can generate consistent sprites, environments, UI, and VFX without further creative decisions.

---

## 2. Inputs

| Input | File | Required? |
|-------|------|-----------|
| Canonical spec | `SPEC_MASTER.md` | Yes — all values verbatim |
| Flavor reference | `game-design-doc-storm-in-chains.md` | Optional |
| Compliance authority | `.inbound/.../Gemini - Analyza pravidiel Google Play.md` §1.2, §2 | Yes — for iconography & gore rules |

---

## 3. Rules & Constraints

### 3.1 Hard rules `[HARD]`
- **No real-world religious or hate symbols** anywhere (no crescents, no calligraphy, no SS-like runes, no real national flags). Only the fictional heraldry from SPEC_MASTER §3.
- **No dismemberment/decapitation** in any sprite or animation. Enemies fall intact.
- **No gore-heavy visuals.** Blood = small pixel particles that fade ≤2s. No persistent blood pools, no visible organs.
- **No sexualized/minor risk** for Zorica (age 16). Keep her design age-appropriate. `[HARD]`
- **Civilians/neutrals must be visually distinct** from enemies (different color language) so players can read them at a glance.
- Palettes must be **consistent** across a world (defined once, reused).

### 3.2 Style rules
- Pixel-art, Metal Slug-influenced but original. Sprite resolution ~2× Metal Slug (modernized).
- Character animations at 12–16 fps, fluid.
- Each world has a distinct palette (SPEC_MASTER §4) — no cross-world color leakage.
- Silhouette-first design: every enemy type must be readable by silhouette alone.

### 3.3 Compliance-sensitive directions
- Enemy heraldry: use ONLY the 5 approved fictional symbols. Design them from geometric/nature motifs.
- No audio-visual caricature of any real culture in enemy designs. Enemy "foreignness" comes from fantasy elements (masks, runes, crystals), not ethnic features.

---

## 4. Outputs

Produce ONE file `art_bible.md` with these sections. Each section must be complete (no placeholders).

### 4.1 Style guide
- Resolution, palette philosophy, lighting, outline policy, animation fps standard.
- 3 example color ramps (light/normal/shadow) used across all sprites.

### 4.2 Character sheets — per character: hero (3 run variants), heroine (3 run variants), villain (3 run variants), 5 bosses (each 3 run variants), 7 NPCs.
For EACH, a table:
| Field | Value |
|-------|-------|
| ID | `<name>` (e.g., `vladan_r1`) |
| Silhouette description | 1–2 lines |
| Color palette | primary/secondary/accent hex |
| Key visual features | list |
| Run variant | R1/R2/R3 (or N/A for NPCs) |
| Animation list | idle, run, jump, shoot, melee, hurt, death, special |

### 4.3 Environment sheets — per world (5): palette table, prop list, background layers (parallax), lighting/atmosphere, 3 "mood board" descriptors.

### 4.4 Enemy roster — per world: every enemy type with ID, silhouette, palette, animation list, attack telegraph, distinct-from-civilian note.

### 4.5 Boss sheets — per boss: arena description, boss phases (R1/R2/R3), attack telegraphs, VFX cues.

### 4.6 Prop & pick-up inventory — weapons (9 legendaries + categories), magic ability VFX, pick-ups (Fragments, health), collars (before/after broken states).

### 4.7 UI kit — HUD layout, menu screens, chapter titles, achievement icons, loading tips, Disclaimer screen layout, Codex UI.

### 4.8 VFX list — explosion, blood (fading particles), magic (fire/lightning/earth/wind/water/void), collar-break effect, portal/anomaly effect.

### 4.9 Asset master list — flat table of EVERY asset: `| asset_id | type | world | dimensions | frames | animation | owner_package |`

### 4.10 Fictional heraldry reference — the 5 approved symbols rendered as text/ASCII/description + explicit "forbidden" reference list.

---

## 5. Output Format

- Single `art_bible.md`, UTF-8, English.
- Tables for all structured data. Use `[HARD]`-compliant descriptions only.
- Palette hex values must be real, valid 6-digit hex.
- The Asset Master List (4.9) is the canonical inventory — every later package (narrative, audio, QA) references asset IDs from it.

---

## 6. Quality Checks (self-run before submitting)

- [ ] All 14 character sheets (3+3+3+5) present and complete with animations.
- [ ] All 5 world environment sheets present with palettes.
- [ ] Every enemy type has an ID, silhouette, and a "distinct from civilian" note.
- [ ] All 9 legendary weapons + 6 magic abilities have VFX descriptions.
- [ ] Asset Master List contains every asset mentioned elsewhere (no orphans).
- [ ] Zero real-world religious/hate symbols; only approved fictional heraldry.
- [ ] No dismemberment/gore in any animation description.
- [ ] Zorica design age-appropriate.
- [ ] Every palette hex is valid and consistent per world.
- [ ] No `TODO` / empty sections.

---

## 7. Human Checkpoint — GATE A

Human must verify (and may reject with reasons):
1. Visual tone matches "over-the-top action, dark backdrop" pillars.
2. No forbidden iconography in any description.
3. Every world's palette is visually distinct and cohesive.
4. Civilian vs enemy readability is obvious.
5. Asset Master List is complete enough to hand to an art-production agent.

**Rejection → return package to agent with reasons. No downstream package starts.**
