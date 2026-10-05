# 03 — LEVEL DESIGN (Level Designer Agent)

> **Agent role:** Level designer. Produce a complete, implementable design doc for all 24 levels × 3 run-layers.
> **Inputs:** `SPEC_MASTER.md` (canonical), `art_bible.md` (asset IDs), `narrative_script.md` (beats/bosses).
> **Gate:** `GATE D` (human) after this package.

---

## 1. Goal

Specify every level so an implementation agent can build it with zero ambiguity: layout, enemies, traps, pick-ups, secrets, boss patterns, and the 3-run variation.

---

## 2. Inputs

| Input | File | Required? |
|-------|------|-----------|
| Canonical spec | `SPEC_MASTER.md` §4 (structure), §5 (runs), §6 (mechanics, backtracking) | Yes |
| Art bible | `art_bible.md` (enemy IDs, prop IDs, boss VFX) | Yes |
| Narrative script | `narrative_script.md` (level beats, boss lines to trigger) | Yes |

---

## 3. Rules & Constraints

### 3.1 Hard rules `[HARD]`
- **No civilian damage.** Level design must never place civilians in a line of fire or as targets. Neutral NPCs are placed in safe zones or as background; their hitboxes are player-inert (implemented per mechanics, but level design must not create situations where the player is incentivized to shoot toward them).
- **No torture/interrogation mini-games.** No level objective may be "torture X to get Y."
- **No self-harm content** in level set-dressing or objectives.
- **Distant perspective:** side-scrolling; violence read at distance; no close-up gore moments.
- **Every level is beatable** in all 3 run-layers; secrets must not block the critical path.

### 3.2 Roguelite 3-layer rule
Every level MUST specify three layers (per SPEC_MASTER §5):
| Layer | Run | What's present |
|-------|-----|----------------|
| L1 | Run 1 | Base route, base enemies, 1 secret |
| L2 | Run 2 | +alternate routes, +new enemies (anomalies/agents), +1 secret, +ability gate |
| L3 | Run 3 | fully open, Corrupted boss variant, legendary weapon secret, elite waves |

### 3.3 Metroidvania rule
Secrets locked behind abilities MUST reference the SPEC_MASTER §6.4 dependency table. A locked door must state WHICH ability unlocks it.

### 3.4 Structure rule
- Boss levels: `W1-4`, `W2-5`, `W3-5`, `W4-6`, `W5-4` (SPEC_MASTER §4).
- Each level has exactly one objective line ("reach the gate," "destroy the warden tower," "escape the mines," etc.).

---

## 4. Outputs

Produce ONE file `level_design.md`, plus ONE table-of-contents index at top.

### 4.1 Per-level template — fill for ALL 24 levels

```
## W{n}-{m} — {Level Name}

### Overview
- Objective: (one line)
- Theme/mood: (one line)
- Estimated length: (minutes)

### Layout
- ASCII or tiled sketch of the level (segments labeled A, B, C…)
- Parallax/background layers used (from art bible)

### Enemies (per run-layer)
| Layer | Enemy ID | Count | Placement notes |
|-------|----------|-------|-----------------|

### Traps & Hazards
| ID | Type | Layer | Placement |
|----|------|-------|-----------|

### Pick-ups & Collectibles
| ID | Type | Layer | Location | Notes |

### Secrets
| Secret ID | Run-layer | Unlock condition (ability, if any) | Reward |
|-----------|-----------|------------------------------------|--------|

### Boss (boss levels only)
- Phases (R1/R2/R3) with attack patterns and telegraphs
- Arena hazards

### Narrative beat
- moment_id + which narrative_script.md beat fires here (intro/outro/boss lines)

### Run-layer variation summary
| Layer | Routes | New enemies | New secrets | Boss (if any) |
|-------|--------|-------------|-------------|----------------|
```

### 4.2 Backtracking dependency map
A table of every ability-gated secret across the game: `| secret_id | location | required ability | ability source |` — must match SPEC_MASTER §6.4 exactly.

### 4.3 Difficulty curve
One table: per world, expected player power level vs enemy HP/damage scaling across Run 1→3.

---

## 5. Output Format

- Single `level_design.md`, UTF-8, English.
- ASCII sketches are fine (no image files required).
- All enemy/prop/pick-up IDs must match `art_bible.md` asset master list.
- All moment_ids must match `narrative_script.md`.

---

## 6. Quality Checks (self-run before submitting)

- [ ] All 24 levels present, each with the full template filled (no `TODO`).
- [ ] Every level has all 3 run-layers specified.
- [ ] Boss levels (5) have full R1/R2/R3 phase patterns.
- [ ] Every secret has an unlock condition; ability-gated secrets match §6.4 of SPEC_MASTER.
- [ ] No civilian is placed in a harm-zone or as a target.
- [ ] No torture/self-harm content in any objective or set-dressing.
- [ ] Critical path is always beatable regardless of secrets.
- [ ] All IDs resolve to assets/enemies in the art bible.
- [ ] Backtracking map is complete and consistent.

---

## 7. Human Checkpoint — GATE D

Human must verify:
1. All 24 levels covered, 3 layers each.
2. Boss patterns sane and escalating.
3. No compliance violations in any level (civilians, torture, self-harm).
4. Backtracking logic coherent and rewarding.
5. Difficulty curve reasonable.

**Rejection → return with reasons. Audio/QA must not assume level design is final.**
