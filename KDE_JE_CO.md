# KDE JE ČO — mapa priečinka Slavs fight back

Stav k 2026-10-05. Prehľad pre človeka: `KDE_JE_CO.html` (dashboard, otvor dvojklikom).
Claude: túto mapu aktualizuj pri každom presune alebo pridaní súboru v koreni.

## ToDo's (snímka 2026-10-05; MASTER = CLAUDE.md "Open", ZACNI_TU_dalsia_session.md, DIZAJN_core_loop.md §3-4)

Claude: pri zmene stavu aktualizuj zdroje aj túto snímku aj `KDE_JE_CO.html`.

### Čaká na Pavla
1. Test na telefóne: zem (výber, scéna bez scrollu, objekty na prechod) a verzie pozadia. [CLAUDE Open 1-2, ZACNI 1]
2. Rozhodnutie: hod sekerou, hrdina sa šmýka. Zastaviť pri hode, alebo nový klip "hod za pohybu" (1-2 generácie). [Open 3, ZACNI 2]
3. Rozhodnutie: scény alebo dlhý pás; ak scény, návrh prepínania. [ZACNI 3, Open 2]
4. Offline: prerobiť príbeh; Claude nezačne, kým Pavel neprinesie návrh. [Open 12, Open Brain Biznis P3]
5. Pri nasadení skontrolovať: viac HP, efekty zásahov kolo 2, zvuky, kotol, brute, nepriatelia za obrazovkou ho dobehnú. [Open 3b, 9]
6. Schváliť hlášky v `HLASKY.md` (angl.). [HLASKY.md]
7. Druhý telefón s iným DPI (ovládanie overené len na 450 dpi). [Open 7]
8. Google Play: pravidlá a IARC (jeho stopa); developer účet odložený; uzavreté testovanie 12 testerov/14 dní = F4; licencie generovaných assetov. [Open 10]
9. Rozhodnutia o jadre pred stavaním: čo ukončí beh, ekonomika klietok, zoznam vylepšení, odomykanie levelov, prepínanie zbraní poklepaním. [DIZAJN_core_loop §3-4]
10. Odložené: monetizácia (premium 5,99 EUR vs. F2P). [core_loop §4]
11. Na jeho PC: `git push` (commity čakajú). [stav gitu]

### Čaká na Claude (po OK od Pavla)
12. Horný okraj chodnej zeme je odrezaný rovno; treba prirodzený prechod. [Open 3a]
13. Prepínanie chôdza <-> zamknutá obrazovka (zoom-in), bossovia a klietky, sudy v zamknutej obrazovke. [Open 2]
14. Scéna B (vypálená dedina) v PixelLab pixen, 1 generácia na pokus; bez opakujúcich sa vzorov. [ZACNI 4]
15. Boj na blízko v 2.5D nevyriešený (dizajnové rozhodnutie, Opus). [Open 4]
16. Bežec bliká po švihu pri pohybe v Y. [Open 5]
17. Zjednotiť farebnú paletu; v pamäti zapísané ako uzavreté, overiť s Pavlom. [Open 6]
18. Gunman: chýba idle a ready idle. Brute: úchop nesedí (zatiaľ ignorovať). [Open 8]

### Neskôr
19. F2 vertikálny rez, F3 obsah, F4 doladenie + uzavreté testovanie, F5 vydanie. [Open 11, PLAN_hry]

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
- GitHub: história už obsahuje ~305 MiB starých súborov; nové sa nepridávajú. Zbaviť sa ich = prepísať históriu (rozhodnutie Pavla, zatiaľ nie)
