# KDE JE ČO — mapa priečinka Slavs fight back

Stav k 2026-10-05. Prehľad pre človeka: `KDE_JE_CO.html` (dashboard, otvor dvojklikom).
Claude: túto mapu aktualizuj pri každom presune alebo pridaní súboru v koreni.

## ToDo's (otvorené úlohy; MASTER = CLAUDE.md "Open", ZACNI_TU_dalsia_session.md, DIZAJN_core_loop.md §3-4)

Claude: pri zmene stavu aktualizuj zdroje aj tento zoznam aj `KDE_JE_CO.html`.
ID (T01...) sú STÁLE: Pavel na ne odkazuje ("T07"). Nikdy ich neprečísluj; nová vec dostane ďalšie číslo (posledné pridelené: T40).
Tu a v dashboarde sú LEN otvorené úlohy. Keď je úloha hotová, zrušená alebo zavretá: presuň jej riadok do `_archiv/TODO_hotove.md` (tam ho Claude nečíta, len na požiadanie) a zmaž ho odtiaľto aj z `KDE_JE_CO.html`. Hotové veci sa v dashboarde nezobrazujú.

### Čaká na Pavla
T04 Offline: prerobiť príbeh; Claude nezačne, kým Pavel neprinesie návrh. [Open 12, Open Brain Biznis P3]
T06 Schváliť hlášky v `HLASKY.md` (angl.). [HLASKY.md]
T07 AKTÍVNE (Pavel urobí v najbližších dňoch): krátky test (cca 10 min) na inom telefóne: ovládanie a či sedí obrazovka pri inom pomere strán (zamknutá scéna, horný pás). Plné ladenie DPI až neskôr. [Open 7]
T08 ODLOŽENÉ (Pavel 2026-10-06): kontrola Google Play pravidiel/IARC až keď bude hotová kostra hry (príbeh, hlášky...). Nemá zmysel kontrolovať hru, ktorá je z 10 % hotová. [Open 10]
T09 AKTÍVNE (Pavel 2026-10-06): základy grafiky sú hotové, teraz sa riešia herné mechanizmy: čo ukončí beh, ekonomika klietok, zoznam vylepšení, odomykanie levelov, prepínanie zbraní poklepaním. [DIZAJN_core_loop §3-4]
T10 ODLOŽENÉ (Pavel 2026-10-06, zatiaľ nevieme): monetizácia (premium 5,99 EUR vs. F2P). [core_loop §4]
T21 Po 2026-10-12: zmazať zálohu `slavs_zaloha_...` v D:\2026 (Pavel, v Prieskumníku). Priečinok `slavs_cisty_...` sa maže hneď. [T20]

### Čaká na Claude (po OK od Pavla alebo na Pavlov test)
T17 AKTÍVNE, DÔLEŽITÉ (Pavel 2026-10-06): farebná paleta nie je zjednotená (PixelLab je primárny zdroj grafiky). MUSÍ sa vyriešiť PRED generovaním finálnej hernej grafiky; kým robíme prototypy, nemusí byť rozhodnuté. [Open 6]
T22 HOTOVÉ V KÓDE 2026-10-06, ČAKÁ NA TEST NA TELEFÓNE: pevné telá. Hrdina aj nepriatelia sa neprechádzajú (hrdina ↔ nepriateľ aj nepriateľ ↔ nepriateľ), pevné sú len nohy (box 30 × 22 px zavesený na nohách, panel: hĺbka a šírka nôh), horné telá sa môžu prekrývať. Mäkké rozstrkávanie (`_separate_enemies`) sa pri zapnutých pevných telách preskakuje (panel: vypínač PEVNE TELA, vypnutý = staré správanie). Postavy majú `MOTION_MODE_FLOATING` (bez podlahy). Sudy a kotly počítajú pás blokovania z výšky nôh. Sledovať: zasekávanie pri 30+ nepriateľoch; brutov úchop funguje (počas úchopu sa hrdina a brut neblokujú). (Pavel 2026-10-06)
T33 HOTOVÉ V KÓDE 2026-10-07, ČAKÁ NA TEST NA TELEFÓNE (zapni z NESMRTELNOSTI, inak hrdina odhodenie nedostane): odhodenie obojsmerne, v smere útoku, o dĺžku v px podľa zbrane (panel ODHODENIE PO ZASAHU). Bežec odhodí hrdinu o 90 px, guľka strelca o 35 px, brut nič (len chytá). Sekera odhodí bežca aj strelca o 70 px (brut je príliš veľký, neodhodí sa); cesta sekery SPÄŤ odhadzuje tiež (posuvník 0 = nie, 1 = rovnako; Pavel si nie je istý, ako to bude vyzerať). Odhodený nepriateľ je na chvíľu omráčený (nechodí, švih alebo výstrel sa zruší). Sudy a kotly sa neodhadzujú (otvorený nápad: neskôr zvážiť). (Pavel 2026-10-07)

### Neskôr, nápady a na zváženie
T23 NÁPAD (neskôr, dizajn): nepriatelia hľadajú inú trasu a obídu hrdinu. Dôsledok: obkľúčia ho a nebude vedieť ujsť. Rozhodnúť neskôr, či to chceme. (Pavel 2026-10-06)
T34 NA ZVÁŽENIE/VYSKÚŠANIE: úder zbrane má mať okolo seba „vlnu“ znázorňujúcu švih alebo sek (oblúk švihu, pich v tvare U alebo V), nakreslenú akoby zo vzduchu. To isté skúsiť pri zásahu nepriateľa, aby bol vidieť „úder“, hoci tam už je krv. (Pavel 2026-10-06)
T35 Vo vzduchu má občas niečo poletovať podľa prostredia: lístie, dážď, sneh, hmla. Rôzna veľkosť (ten istý tvar raz v pôvodných pixeloch, inokedy 2x alebo 3x väčší). (Pavel 2026-10-06)
T36 NA ZVÁŽENIE: ako miznú nepriatelia po smrti. Zatiaľ úvaha o strate v dyme, možno príde iný nápad. (Pavel 2026-10-06)
T37 NA VYSKÚŠANIE: za postavami pri chôdzi občas efekt zvíreného prachu, snehu alebo dymu; v podstate tá istá animácia, farba podľa podkladu, po ktorom chodia. (Pavel 2026-10-06)
T38 Útočníci vo vzduchu a hádzané veci s oblúkovou dráhou sa napodobnia tieňom: predmet opustí ruku a opisuje oblúk, tieň ide lineárne po zemi a nakoniec sa stretnú, čo vytvorí dojem letu. (Pavel 2026-10-06)
T39 Niektoré veci majú znázorniť vietor: vlajky, trsy trávy, hmla, dym. (Pavel 2026-10-06)
T40 Používať shadery, napr. na osvetlenú oblasť (fakľa, oheň, chvíľu po výbuchu kotla), asi aj na hmlu. Pridá hre hĺbku a rozmanitosť. (Pavel 2026-10-06)

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
| `slavs/` | 205 MB | Hra (Godot projekt). `.godot/` a `build/` sú cache |
| `tools/` | 1 MB | Skripty (nasadenie, PixelLab, zem, kontrola kódu) |
| `ref/` | 368 MB | Štýlové referencie (obrázky). 22 voľných obrázkov z júla je staré, mimo gitu |
| `art/` | 1 MB | PixelLab podklady |
| `docs/vyskum/` | 1 MB | Výskum: analýza pravidiel Google Play |
| `Claude outputs/` | 8 MB | Obrázky z pracovných session (2.-4. 10.) |
| `_archiv/` | 506 MB | Archív. Claude ho NEČÍTA a nebere do úvahy, len ak Pavel požiada |
| `_archiv/3d_stary/` | 505 MB | Starý 3D reťazec (Meshy/Mixamo/Blender): renderov, modely, skripty, `*_px` sprity, staré sekcie PRIKAZY. LEN lokálne, gitignored, NIE na GitHube. Nepoužívať |
| `_archiv/draupnir_koncept/` | 0 MB | Iný koncept príbehu od druhej AI, neodsúhlasený |

## Upratané 2026-10-05

- `CLAUDE.md`: duplicitná sekcia „Current status" zlúčená do jednej (26 KB -> 22 KB).
- Draupnir koncept + lexikón -> `_archiv/draupnir_koncept/` (s poznámkou).
- `ZACNI_TU_pozadie_pixellab.md` -> `_archiv/` (úloha hotová).
- Zmluva o aute -> `_archiv/mimo_projektu/` (nepatrí do projektu; vyber ju z repa ručne, ak chceš).
- Gemini analýza -> `docs/vyskum/`.
- `.gitattributes` (`* text=auto`) odstraňuje falošné „zmeny" kvôli koncovkám riadkov.
- Starý 3D reťazec (`render/`, `art/fits/`, `tools/blender/`, staré skripty, 3D modely z `ref/`, staré `*_px` sprity, staré sekcie `PRIKAZY.md`) -> `_archiv/3d_stary/`, gitignored; v `CLAUDE.md` je pravidlo, že sa neberie do úvahy.
- `tools/preview_framing.py` prepnutý na PixelLab hrdinu (`hero_pl_run`, 2x).
- GitHub: história vyčistená od 3D súborov (T20), dnes ~417 MiB; zvyšok sú obrázky v `ref/` a pozadia.
