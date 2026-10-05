# KDE JE ČO — mapa priečinka Slavs fight back

Stav k 2026-10-05. Prehľad pre človeka: `KDE_JE_CO.html` (dashboard, otvor dvojklikom).
Claude: túto mapu aktualizuj pri každom presune alebo pridaní súboru v koreni.

## Odsúhlasený príbeh a popis hry (kde to je)

Samostatný scenár neexistuje. Odsúhlasené je jadro:

- Hrdina: utečený slovanský otrok, 15. storočie, bojuje proti otrokárom (rola, nikdy etnikum).
  Bez mena, bez cutscén (len textové karty).
- Hra: 2D side-scroller run-and-gun (štýl Metal Slug), Android, Godot 4.7, premium 5,99 €, bez reklám a IAP.
- Jadro hry: run-based score attack; klietky so zajatcami (mena = prežili zajatci); vracajúca sa
  sekera; nepriatelia len sprava; voľný 2.5D pohyb bez skákania.
- Zdroje: `PLAN_hry.md` (§1, §3; éra v texte zastaraná, platí 15. storočie), `DIZAJN_core_loop.md`
  (štruktúra, nahrádza §3.2 a §3.5 plánu), `CLAUDE.md` (aktuálny stav).
- Draupnir koncept (Vladan, Zorica, 24 levelov) NIE je odsúhlasený, je v `_archiv/draupnir_koncept/`.
- Príbeh sa bude prerábať (Pavel pracuje offline), viď ToDo nižšie.

## Súbory v koreni

| Súbor | Pre koho | Čo to je |
|---|---|---|
| `CLAUDE.md` | Claude | Pamäť projektu, číta sa na začiatku každej session |
| `ZACNI_TU_dalsia_session.md` | Claude | Štartovací prompt ďalšej session |
| `KDE_JE_CO.md` / `.html` | obaja | Táto mapa |
| `PRIKAZY.md` | Pavel | Ťahák príkazov (nasadenie, PixelLab, riešenie problémov) |
| `SETUP_F0.md` | Pavel | Inštalácia a testovanie na telefóne |
| `POSTUP_cloud_github.md` | Pavel | Práca v cloude a GitHub |
| `HLASKY.md` | Pavel | Návrh hlášok (angl.) na schválenie |
| `PLAN_hry.md` | obaja | Plán hry, business case, fázy; kap. 2 (citlivá téma) je nemenná |
| `DIZAJN_core_loop.md` | obaja | Štruktúra hry: run-based, klietky |
| `SPEC_ovladanie_implementacia.md` | obaja | Ovládanie, jediný zdroj pravdy |
| `DIZAJN_pozadie_a_rozlisenie.md` | obaja | Pozadie a rozlíšenie; uzavreté 2026-09-15, kód naň odkazuje |
| `commit_msg.txt` | technické | Záložný text commitu (PRIKAZY.md); gitom ignorovaný |
| `.mcp.json`, `.gitignore`, `.gitattributes`, `.claude/` | technické | Konfigurácia, git |

## Priečinky

| Priečinok | Veľkosť | Čo to je |
|---|---|---|
| `slavs/` | 211 MB | Hra (Godot projekt). `.godot/` a `build/` sú cache |
| `tools/` | 147 MB | Skripty (nasadenie, PixelLab). `tools/blender/` 146 MB = starý 3D reťazec |
| `ref/` | 607 MB | Štýlové referencie. 22 voľných obrázkov z júla je staré, `preview/` je v gite |
| `render/` | 114 MB | STARÝ 3D reťazec (výstupy); nepoužívať, mimo gitu |
| `art/` | 1 MB | `fits/` = nastavenia zbraní pre starý 3D reťazec |
| `docs/vyskum/` | 1 MB | Výskum: analýza pravidiel Google Play |
| `Claude outputs/` | 8 MB | Obrázky z pracovných session (2.–4. 10.) |
| `_archiv/` | 2 MB | Dokončené prompty, história, `draupnir_koncept/`, `mimo_projektu/` |

## Upratané 2026-10-05

- `CLAUDE.md`: duplicitná sekcia „Current status" zlúčená do jednej (26 KB -> 22 KB).
- Draupnir koncept + lexikón -> `_archiv/draupnir_koncept/` (s poznámkou).
- `ZACNI_TU_pozadie_pixellab.md` -> `_archiv/` (úloha hotová).
- Zmluva o aute -> `_archiv/mimo_projektu/` (nepatrí do projektu; vyber ju z repa ručne, ak chceš).
- Gemini analýza -> `docs/vyskum/`.
- `.gitattributes` (`* text=auto`) odstraňuje falošné „zmeny" kvôli koncovkám riadkov.
- Ponechané (používajú ich staré skripty): `render/`, `art/fits/`, `tools/blender/`, voľné obrázky v `ref/`.

## Čaká na Pavla (ToDo a rozhodnutia)

1. **TODO: prerobiť príbeh.** Pavel na ňom pracuje offline, bez termínu. Claude ho nezačína, kým Pavel neprinesie návrh. Draupnir koncept v archíve je len možný zdroj nápadov (mená, kódex s históriou); zosúladenie s `DIZAJN_core_loop.md` je dizajnové rozhodnutie (Opus). Úloha je aj v Open Brain (Biznis, P3).
2. Presunúť starý 3D reťazec (`render/`, `art/fits/`, `tools/blender/`) do archívu? Rozbijú sa staré skripty, ktoré sa nemajú používať.
