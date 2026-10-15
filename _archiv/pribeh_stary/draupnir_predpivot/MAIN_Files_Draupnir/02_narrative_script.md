# 02 — NARRATIVE SCRIPT (Narrative Writer Agent)

> **Agent role:** Narrative writer. Produce the complete in-game script and string tables.
> **Inputs:** `SPEC_MASTER.md` (canonical), `anti-illegal-immigration-lexicon.md` (slogan source), `art_bible.md` (names/visuals, if available).
> **Gate:** `GATE B` (human) after this package.

---

## 1. Goal

Produce every word the player reads or hears in-game, mapped to exact moments, in a consistent voice, fully compliance-safe.

---

## 2. Inputs

| Input | File | Required? |
|-------|------|-----------|
| Canonical spec | `SPEC_MASTER.md` | Yes — characters §2, factions §3, runs §5, glossary §8 |
| Slogan lexicon | `anti-illegal-immigration-lexicon.md` | Yes — §14, §15, §18 |
| Art bible | `art_bible.md` | If available (names/visual consistency) |
| Compliance authority | `.inbound/.../Gemini - Analyza pravidiel Google Play.md` §1 | Yes |

---

## 3. Rules & Constraints

### 3.1 Voice bible (non-negotiable tone)
| Character | Voice | Rules |
|-----------|-------|-------|
| Vladan | Terse, serious, gallows-humored BY CONTEXT not by joke-telling | ≤12 words per line; no puns; anger turns to coldness |
| Zorica | Sharp, brave, warm | ≤15 words; defiant but never cruel |
| Morthax | Theatrical, vain, elegant | Long sentences allowed; self-aggrandizing; never racial |
| Thorn | Cold, professional | ≤10 words; "just doing my job" |
| Krut | Cruel, cowardly | Short; cruelty + fear |
| Hazar | Oily, transactional | Business metaphors; no hate, only profit |
| Goran | Heavy, guilt-ridden | Sparse; regret |
| NPCs | Per SPEC_MASTER §2.5 | Warm/sage/neutral per character |

### 3.2 Compliance hard rules `[HARD]`
- **Target the institution, not a people.** Hero lines attack "tyrants," "wardens," "the Empire," "the Collar" — NEVER an ethnicity, nationality, or religion.
- **Forbidden terms** (SPEC_MASTER §3) never appear in any string.
- **No hate speech, slurs, or dehumanizing a protected group.** The Empire dehumanizes *individuals as property* (fine — that's the villain's ideology being shown as wrong), but never asserts an ethnic group is inferior.
- **Moral diversity:** neutral/friendly characters exist from the antagonist region (Ghoul Merchant, Deserter Mirko, neutral traders). Their lines must show they are ordinary, not evil.
- **No self-harm/suicide** content in any line or codex entry.
- **Codex entries** (EDSA) must be historically accurate, neutral, global in scope, and not blame any single modern ethnic/religious group.

### 3.3 Slogan mapping rules
- Use the approved slogan table (§4.4) — do NOT invent new political slogans beyond the lexicon; the lexicon is the source of truth for slogan-style lines.
- Slogans are placed as **hero lines, villain-logic lines, NPC lines, chapter titles, achievement names, loading tips** — never as literal real-world political references to current events. The game is fiction.

### 3.4 Format rules
- All dialogue is ENGLISH.
- Every line tagged with `[speaker]`, `[moment_id]`, `[run]`.
- No `TODO`/placeholder. No unfilled brackets.

---

## 4. Outputs

Produce ONE file `narrative_script.md` with these sections.

### 4.1 Cinematics (5 total)
For each: scene heading, location, characters, full dialogue (screenplay-ish, but terse), and camera/action beats.
1. **Intro** — raid on Podhradie, Zorica taken.
2. **Run 1 end** — Zorica's explosion, cliffhanger.
3. **Run 2 end** — Zorica's message about the Sparks.
4. **Run 3 end** — final battle epilogue, collars shatter.
5. **Epilogue** — hillside at sunrise.

### 4.2 Level beats (24)
One intro + one outro line/moment per level (can be 1–2 lines or a short action description with a line). Format:
```
### W2-3 Wardens' Barracks — Intro
[speaker: Vladan] "..." 
[beat: description]
```

### 4.3 Boss dialogue (5 bosses × 3 runs = 15 sets)
Each: pre-fight, mid-fight (trigger), death line. Include villain-logic lines showing their worldview (see §4.4 villain column).

### 4.4 Slogan mapping table (CANONICAL — must be filled exactly)
| # | Line (ENG) | Speaker | Moment_id | Type | Lexicon source |
|---|-----------|---------|-----------|------|----------------|
Provide ≥15 rows. Use these approved hero lines + villain-logic lines + NPC lines from the GDD/lexicon. Each row must reference its lexicon section.

### 4.5 NPC dialogue (7 NPCs)
Per NPC: every line across their appearance windows (run-scoped), plus one "theme" line.

### 4.6 Item/weapon/ability strings
Name + one-line description (English) for: all weapons, all 6 magic abilities, 4 Spark summons, Fragments currency, health pick-up.

### 4.7 Codex entries (20+)
Title + 80–150 word neutral, historically-grounded entry each. Topics must be GLOBAL (e.g., "The medieval slave trade in Europe," "Slavery in antiquity," "Manumission," "The Saqaliba," "Maritime slave routes," "Resistance and revolt"). Neutral tone, no modern political commentary.

### 4.8 UI string table
Every HUD/menu/achievement/loading-tip string. Include:
- 24 achievement names + descriptions (several drawn from lexicon §18 top-25).
- 10 loading tips (slogan-flavored, fiction-safe).
- Chapter titles (5 worlds × name + subtitle).

### 4.9 Disclaimer & store text
- First-launch Disclaimer (verbatim from SPEC_MASTER §9.4).
- Store short/long description drafts (genre-focused, EDSA sentence included, no clickbait keywords).

---

## 5. Output Format

- Single `narrative_script.md`, UTF-8, English.
- Use headers per section; tables for the slogan mapping and UI strings.
- Every dialogue line carries `[speaker]`, `[moment_id]`, `[run]` tags.
- `[moment_id]` must match SPEC_MASTER level IDs (e.g., `W2-3`).

---

## 6. Quality Checks (self-run before submitting)

- [ ] 5 cinematics + 24 level beats + 15 boss dialogue sets present.
- [ ] Slogan mapping table ≥15 rows, each with lexicon source.
- [ ] 20+ Codex entries, all neutral/global/accurate.
- [ ] Zero forbidden terms (grep against SPEC_MASTER §3 forbidden list).
- [ ] No hero line attacks an ethnicity/religion (only "the Empire/wardens/tyrants/collar").
- [ ] Neutral friendly characters present from antagonist region (Ghoul Merchant, Mirko, traders) with non-evil lines.
- [ ] No self-harm/suicide content.
- [ ] Zorica ≤ age-appropriate, no romanticization of a minor.
- [ ] UI string table complete (24 achievements, 10 tips, 5 chapter titles).
- [ ] Voice bible respected (line-length limits per character).
- [ ] No `TODO`/placeholder/filled-with-lorem.

---

## 7. Human Checkpoint — GATE B

Human must verify:
1. Tone matches voice bible; no character drift.
2. No hate speech or ethnic/religious targeting anywhere.
3. Slogan mapping feels organic, not forced; slogan count sensible.
4. Codex entries are genuinely educational and neutral.
5. Store text avoids clickbait keywords and includes EDSA language.

**Rejection → return with reasons. No level design/audio starts until approved.**
