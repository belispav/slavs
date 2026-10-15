# 00 — ORCHESTRATION & PIPELINE

> Read this FIRST. It defines how the six work packages fit together, their order, dependencies, and the human checkpoints (gates) between them.

---

## 1. The Six Work Packages

| ID | Package | Agent role | Produces | Depends on |
|----|---------|------------|----------|------------|
| **01** | `01_art_bible.md` | Art director | Art bible, asset list, palettes, animation & VFX list | SPEC_MASTER |
| **02** | `02_narrative_script.md` | Narrative writer | Full script, dialogue, codex, UI strings, slogan mapping | SPEC_MASTER, lexicon, (art bible for names/visuals) |
| **03** | `03_level_design.md` | Level designer | 24 level design docs (layout, enemies, traps, secrets, bosses, 3-run variation) | SPEC_MASTER, art bible, narrative script |
| **04** | `04_gameplay_mechanics.md` | Systems designer | Mechanics spec (weapons, abilities, progression, economy, difficulty, co-op) | SPEC_MASTER |
| **05** | `05_audio_spec.md` | Audio designer | Music/SFX/VO spec | SPEC_MASTER, art bible, narrative script |
| **06** | `06_qa_compliance.md` | QA + compliance | Test plans, compliance checklist, IARC sheet | ALL of the above |

---

## 2. Execution Order & Dependencies

```
SPEC_MASTER  ──►  01 Art Bible  ──►  02 Narrative  ──►  03 Level Design
     │                   │                 │                  │
     │                   └──────► 05 Audio ◄─┘                  │
     │                                                          │
     └──► 04 Mechanics  (can run parallel with 01–03)          │
                                                                 │
                       06 QA/Compliance  ◄── ALL ───────────────┘
```

### Phases
- **Phase 0 — Foundation:** SPEC_MASTER.md is frozen (approved). No work package starts before this.
- **Phase 1 — Art Bible (01).** Foundation for visual consistency. `GATE A` (human).
- **Phase 2 — Narrative (02) + Mechanics (04) in parallel.** Mechanics does not need art; narrative benefits from art but can proceed with SPEC_MASTER. `GATE B` (human) on narrative; `GATE C` (human) on mechanics.
- **Phase 3 — Level Design (03) + Audio (05) in parallel.** Both need narrative. `GATE D` (human) on level design; `GATE E` (human) on audio.
- **Phase 4 — QA/Compliance (06).** Needs all prior outputs frozen. `GATE F` (human) = final sign-off.

---

## 3. Human Checkpoint Gates (summary)

| Gate | When | Human must verify | Blocking if |
|------|------|-------------------|-------------|
| **A** | After art bible | Visual tone consistent; no forbidden iconography; palettes complete | Inconsistent style, missing assets, forbidden symbols |
| **B** | After narrative | Tone per character; no hate speech; slogans mapped; codex neutral | Ethnic/religious framing, tone drift, missing content |
| **C** | After mechanics | Numbers sane; no torture loops; no dismemberment; no self-harm | Missing values, prohibited mechanics |
| **D** | After level design | All 24 levels covered; 3-run variation; secrets documented; no civilian damage | Gaps, missing run layers, backtracking errors |
| **E** | After audio | No real religious chants; no ethnic caricature; full coverage | Forbidden audio, missing SFX/VO |
| **F** | Final | Whole game compliance (vs. Google Play policy); IARC sheet matches reality | Any §9 violation |

**Rule:** A downstream package must NOT begin until its upstream gate is approved. If a gate fails, return the package to its agent with the rejection reasons; do not patch downstream.

---

## 4. File & Format Conventions (all packages)

### 4.1 Output format
- All agent outputs are **Markdown** (`.md`), UTF-8.
- All in-game strings are **English**.
- Canonical values copied from SPEC_MASTER must be **verbatim** (do not paraphrase names, faction labels, or slogans).
- Use tables for structured data (enemies, weapons, abilities, assets). Use short prose only for flavor.

### 4.2 Naming conventions
- Level IDs: `W{n}-{m}` (e.g., `W2-3`). Boss levels: `W1-4`, `W2-5`, `W3-5`, `W4-6`, `W5-4`.
- Asset IDs: `<world>_<type>_<name>` (e.g., `w2_enemy_warden`, `w3_boss_hazar`).
- Sprite sheet naming: `<asset>_<animation>_<frame>` (e.g., `vladan_run_03`).

### 4.3 Status tracking
- Every work package output ends with a **"Definition of Done"** checklist the agent self-reports against.
- The human reviewer checks the same checklist at the gate.

---

## 5. How to Hand a Package to a Lower-Level Agent

Provide the agent:
1. `SPEC_MASTER.md` (context)
2. The specific work package file (its instructions)
3. Its upstream dependency files (per §2)
4. This instruction: *"Read SPEC_MASTER first. Follow your work package exactly. Produce the outputs in §Outputs with the format in §Output Format. Run the Quality Checks in §Quality Checks and fix failures before submitting. Stop and flag anything that conflicts with a `[HARD]` rule — do not invent exceptions."*

---

## 6. Definition of a "good" agent submission

A submission is accepted only if:
1. Every output file listed in the package's §Outputs exists and is complete (no `TODO`, no empty sections).
2. All `[HARD]` compliance rules are respected (a compliance agent will also re-check in package 06).
3. Every value that SPEC_MASTER canonically defines is reproduced verbatim.
4. The package's own Quality Checks pass (agent attests, with evidence where possible).
5. Nothing is invented that contradicts SPEC_MASTER (new content is allowed; contradictions are not).

---

## 7. Escalation rule

If an agent finds a genuine conflict or gap in SPEC_MASTER (not a creative choice), it must **flag, not improvise silently.** Flag format:

```
> ⚠️ SPEC CONFLICT: <describe conflict> — proposed resolution: <proposal> — AWAITING HUMAN DECISION
```

The human resolves it in SPEC_MASTER, then the agent resumes.
