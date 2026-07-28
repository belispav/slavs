# VOLYA — Kickoff: čím a ako pokračovať

## Odporúčaný nástroj a model

**Nástroj: Claude Code alebo Cowork, spustený priamo v tomto foldri.** Oba automaticky načítajú `CLAUDE.md` (pamäť projektu) a majú prístup k súborom, terminálu a gitu — presne to, čo vývoj v Godote potrebuje. Obyčajný chat NEPOUŽÍVAJ na písanie kódu (nevidí projekt, nespustí ho, kód sa rozsype po 3. iterácii). Codex/iné ekosystémy: nemiešať — jeden ekosystém, jedna pamäť projektu.

**Model:**
- **Sonnet** = default na 90 % práce (implementácia úloh, iterácie, drobné opravy). Rýchly a lacný.
- **Opus** = na F1 ovládanie (state machine, ladenie citu), architektonické rozhodnutia, zapeklité bugy a týždenný refactor.
- Praktické pravidlo: začni úlohu na Sonnete; ak sa dvakrát zasekne, prepni na Opus.

## Prompt pre prvú session (skopíruj celý)

```
Pracuješ na hre VOLYA v tomto foldri. Najprv si prečítaj CLAUDE.md,
potom VOLYA_plan_hry.md (sekcie 3–5) a celý SPEC_ovladanie_implementacia.md.

Aktuálna fáza: F0 → F1.

Úloha 1 (F0): Preveď ma krok za krokom cez setup — overenie inštalácie
Godot 4.7.1, inštalácia JDK 17 a Android SDK, export šablóny, prvý
"hello world" APK na mojom telefóne. Ja som na Windows, nulové znalosti,
všetko mi vysvetľuj po slovensky a po jednom kroku.

Úloha 2 (F1): Po funkčnom API builde inicializuj git repozitár a založ
Godot projekt. Potom implementuj ovládanie PRESNE podľa
SPEC_ovladanie_implementacia.md, v tomto poradí:
1. TouchController autoload + debug overlay (SPEC B5) — overlay ako prvý,
2. state machine ľavého palca (B2) s tunables (B4),
3. mierenie a auto-fire pravého palca (B3),
4. testovacia scéna podľa PART C.

Pravidlá práce: malé úlohy, po každej funkčnej zmene git commit, nikdy
nepokračuj na rozbitom stave. Všetky konštanty do ControlConfig.tres.
Cieľom F1 sú akceptačné kritériá v SPEC PART C — je to Go/No-Go míľnik.
```

## Harmonogram (potvrdený kontext)

- Launch najskôr o 3–4 mesiace (osobné dôvody) — vyhovuje, nič neblokuje.
- Vývoj F0–F3 za 1–2 mesiace je reálny pri ~25–30 h/týždeň s AI; pri ~10–15 h/týždeň počítaj s 3 mesiacmi. F1 (prvé 2 týždne) ukáže reálne tempo — podľa neho sa harmonogram spresní.
- Google Play účet: založiť najneskôr ~1 mesiac pred plánovaným uzavretým testom (overenie identity + rezerva). Do vývoja nevstupuje.
- Nezabudnúť: uzavretý test 12 testerov / 14 súvislých dní je povinný — nábor testerov začať už počas F3.

## Čo je hotové (nič z toho netreba robiť znova)

Plán + business case (`VOLYA_plan_hry.md`), implementačná špecifikácia ovládania vrátane vzorcov, tunables a akceptačných kritérií (`SPEC_ovladanie_implementacia.md`), pamäť projektu pre AI (`CLAUDE.md`). Sekciu "Current status" v CLAUDE.md priebežne aktualizuje AI, s ktorou pracuješ.
