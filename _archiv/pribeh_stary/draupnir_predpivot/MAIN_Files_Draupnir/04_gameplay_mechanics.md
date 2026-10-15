# 04 — GAMEPLAY MECHANICS (Systems Designer Agent)

> **Agent role:** Systems/gameplay designer. Produce the complete mechanics & progression specification with exact numbers.
> **Inputs:** `SPEC_MASTER.md` (canonical mechanics §6).
> **Gate:** `GATE C` (human) after this package.

---

## 1. Goal

Specify every system, value, and rule so an implementation agent can code gameplay with no numeric ambiguity.

---

## 2. Inputs

| Input | File | Required? |
|-------|------|-----------|
| Canonical spec | `SPEC_MASTER.md` §6 (mechanics), §5 (runs), §9 (compliance) | Yes |
| Compliance authority | `.inbound/.../Gemini - Analyza pravidiel Google Play.md` §2 (violence limits), §3 (IARC) | Yes |

---

## 3. Rules & Constraints

### 3.1 Hard rules `[HARD]`
- **No torture/interrogation mechanics.** No gameplay loop that rewards prolonging an enemy's suffering.
- **No dismemberment/decapitation** mechanics; no ragdoll gore; blood = fading particles (≤2s).
- **Civilians/neutrals have NO hitbox for player attacks** (both melee and AoE). If an AoE would hit a civilian, the game must not register it (or the level must prevent overlap). NO penalty mechanic that *encourages* harming civilians — instead, make it impossible.
- **No self-harm / suicide / choking-game mechanics.**
- **Crafting must be abstract** (icon + icon → item; no real-world weapon recipes).
- **No real-world weapon-making instructions.**

### 3.2 Design rules
- Every numeric value must be specified (damage, cooldown, duration, cost, drop rate).
- Health system: 3–5 hit points baseline + a 1-hit "hardcore" optional mode.
- All SPEC_MASTER canonical values reproduced verbatim (weapon categories §6.2, abilities §6.3, meta-progression §6.5, Sparks §6.6).

### 3.3 Balance rule
- Provide a progression curve across 3 runs (§4.7). Player power must scale up notably each run (pillar #2 "the storm builds").

---

## 4. Outputs

Produce ONE file `gameplay_mechanics.md`.

### 4.1 Combat spec
- Health/damage model, hit detection, i-frames, knockback, stun.
- Weapon behavior table: every weapon with `| id | damage | range | rate | ammo/energy | special |`.

### 4.2 Ability spec (6 + Dawn Flame)
Per ability: `| id | effect | duration | cooldown | level 1/2/3 progression | unlock condition |`.

### 4.3 Spark summon spec (4)
Per Spark: `| id | effect | duration | cooldown | unlock |`.

### 4.4 Progression & economy
- Fragments of Memory: earn rates (boss, secret, challenge), spend costs for each permanent upgrade tier.
- Armory/loadout system rules.
- Bestiary completion reward.
- Difficulty modes (Normal 3–5 HP; Hardcore 1 HP) and their reward multipliers.

### 4.5 Co-op spec (Run 3, Zorica)
- How 2-player local co-op works, Zorica's kit, combined attack ("Fire and Lightning").

### 4.6 Compliance-enforcement spec (how the engine enforces §9)
- Exact implementation notes for: civilian no-hitbox, no dismemberment, blood fade timer, abstract crafting, no torture loop.

### 4.7 Progression curve
- Table: per world × per run, player HP/damage vs enemy HP/damage. Show the power ramp.

### 4.8 IARC-relevant mechanics summary
- One-page note confirming which IARC answers the mechanics support (per SPEC_MASTER §9.5) and why (e.g., "distant perspective" because side-scrolling; "innocents not killable" because no-hitbox).

---

## 5. Output Format

- Single `gameplay_mechanics.md`, UTF-8, English.
- Tables for all numeric data. No "balance later" or "TBD" values.
- Canonical values verbatim from SPEC_MASTER.

---

## 6. Quality Checks (self-run before submitting)

- [ ] Every weapon, ability, Spark has full numeric spec (no blanks).
- [ ] Progression curve table filled for all worlds × runs.
- [ ] No prohibited mechanic present (torture, dismemberment, self-harm, civilian damage).
- [ ] Compliance-enforcement spec explicitly covers each SPEC_MASTER §9 violence rule.
- [ ] Canonical values match SPEC_MASTER §6 verbatim.
- [ ] Economy numbers are internally consistent (costs ≤ achievable earnings).
- [ ] Co-op spec complete.

---

## 7. Human Checkpoint — GATE C

Human must verify:
1. No prohibited mechanics.
2. Numbers are sane and the power ramp is satisfying.
3. Compliance-enforcement spec is concrete and implementable.
4. IARC summary accurate.

**Rejection → return with reasons.**
