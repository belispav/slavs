# 06 — QA & COMPLIANCE (QA / Compliance Agent)

> **Agent role:** QA + compliance. Produce test plans, the compliance audit checklist, and the final IARC answer sheet.
> **Inputs:** ALL prior packages (`SPEC_MASTER`, art bible, narrative, level design, mechanics, audio) + the Google Play policy analysis.
> **Gate:** `GATE F` (human) = final sign-off before store submission.

---

## 1. Goal

Guarantee (a) the game works as specified and (b) it will pass Google Play review. Produce the artifacts that prove both.

---

## 2. Inputs

| Input | File | Required? |
|-------|------|-----------|
| Canonical spec | `SPEC_MASTER.md` (esp. §9 compliance) | Yes |
| All outputs | `art_bible.md`, `narrative_script.md`, `level_design.md`, `gameplay_mechanics.md`, `audio_spec.md` | Yes |
| Policy authority | `.inbound/.../Gemini - Analyza pravidiel Google Play.md` (whole file) | Yes |

---

## 3. Rules & Constraints

### 3.1 Compliance authority
- The Google Play policy analysis is the FINAL authority on policy questions. If any prior package conflicts with it, the conflict must be flagged and routed back to that package.
- This package does NOT change creative content; it AUDITS it and reports violations.

### 3.2 Hard rules `[HARD]`
- No hate speech / protected-group targeting (policy §1).
- No religious iconography misuse (policy §1.2).
- No gross violence (dismemberment/decapitation), no torture loops, no civilian harm (policy §2).
- No self-harm/suicide content (policy §2.3).
- EDSA disclaimer + codex + store text present (policy §1.3, §4.2).
- No misleading IARC answers (policy §3 — "Deceptive Behavior").

---

## 4. Outputs

Produce THREE files.

### 4.1 `test_plan.md` — Functional QA test plan
- Test cases per system (combat, abilities, co-op, progression, save/load, level traversal, backtracking, secrets).
- Format: `| TC_ID | Area | Steps | Expected result | Priority (P0/P1/P2) |`.
- Coverage matrix: every level (24) × every run-layer (3) has smoke-test coverage.
- Regression list: what to re-test after any patch (compliance-critical paths first).

### 4.2 `compliance_audit.md` — Compliance audit checklist
- One checklist row per policy requirement (from the Google Play analysis), each mapped to the game artifact that satisfies it.
- Format: `| # | Policy requirement | Where satisfied (file/artifact) | Status (PASS/FAIL/RISK) | Evidence/note |`.
- A "FAIL/RISK" section listing every open issue, severity, and the package it must return to.
- Store-listing audit: title, short/long description, screenshots/trailer guidance (no gore, no forbidden imagery), keyword check (no clickbait terms).

### 4.3 `iarc_sheet.md` — Final IARC answer sheet
- The full IARC questionnaire answers (per SPEC_MASTER §9.5), each with a one-line justification tied to the implemented game.
- A "self-check" confirming the storefront visuals match the declared rating (no blood in store screenshots regardless of in-game rating).

---

## 5. Output Format

- Three Markdown files (`test_plan.md`, `compliance_audit.md`, `iarc_sheet.md`), UTF-8, English.
- Tables for all checklists.
- Statuses must be concrete (PASS/FAIL/RISK), never "probably fine."

---

## 6. Quality Checks (self-run before submitting)

- [ ] Test plan covers every system and every level × run smoke test.
- [ ] Compliance audit has one row per policy requirement, each with a concrete artifact + status.
- [ ] Every FAIL/RISK is assigned a severity and a return-package.
- [ ] IARC sheet complete with justifications; storefront-vs-rating self-check done.
- [ ] No policy requirement from the Google Play analysis is left unaddressed.

---

## 7. Human Checkpoint — GATE F (final)

Human must verify:
1. Zero open FAIL/RISK items (or explicitly accepted risks with rationale).
2. Test plan is realistic and covers the compliance-critical paths.
3. IARC answers honestly reflect the shipped game.
4. Store listing is compliant.

**This is the final gate before submission. Only a human signs off here.**
