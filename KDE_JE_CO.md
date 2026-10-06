# KDE JE ČO — mapa priečinka Slavs fight back

Stav k 2026-10-05. Prehľad pre človeka: `KDE_JE_CO.html` (dashboard, otvor dvojklikom).
Claude: túto mapu aktualizuj pri každom presune alebo pridaní súboru v koreni.

## ToDo's (snímka 2026-10-05; MASTER = CLAUDE.md "Open", ZACNI_TU_dalsia_session.md, DIZAJN_core_loop.md §3-4)

Claude: pri zmene stavu aktualizuj zdroje aj túto snímku aj `KDE_JE_CO.html`.
ID (T01...) sú STÁLE: Pavel na ne odkazuje ("T07"). Nikdy ich neprečísluj; nová vec dostane ďalšie číslo, hotová ostane v zozname označená ako HOTOVÉ.

### Čaká na Pavla
T01 HOTOVÉ 2026-10-06: test na telefóne. Pozadie A (pokojná hlina) + objekty na zemi (skúšal 100, môže byť aj viac, ladenie neskôr); ostatné pozadia zrušené. Grafika zeme považovaná za vyriešenú.
T02 HOTOVÉ 2026-10-06: hod sekerou. Počas hodu sa hrdina nehýbe (0 = vlastnosť, treba vybrať moment hodu), zamach 3x rýchlejší; zapečené v `tuning.gd`. Nápad: v hre začať s nižším číslom (napr. 1) a levelovať. Nový klip netreba; pri iných zbraniach (kúzla) bude animácia spojená s útokom.
T03 HOTOVÉ 2026-10-06: chôdza aj boss scény majú ROVNAKÚ vertikálnu logiku (jemný zvislý scroll, hracia plocha = výška obrazovky, horný pás navyše len aby bolo vidieť celé telo). Pri bossoch/klietkach sa zamkne LEN horizontálny scroll (nedá sa odísť vľavo ani vpravo). Prepínanie (zoom-in) ostáva v T13.
T04 Offline: prerobiť príbeh; Claude nezačne, kým Pavel neprinesie návrh. [Open 12, Open Brain Biznis P3]
T05 HOTOVÉ 2026-10-06: skontrolované na telefóne, všetko v poriadku (viac HP, efekty zásahov, zvuky, kotol, brute, nepriatelia za obrazovkou ho dobehnú).
T06 Schváliť hlášky v `HLASKY.md` (angl.). [HLASKY.md]
T07 AKTÍVNE (Pavel urobí v najbližších dňoch): krátky test (cca 10 min) na inom telefóne: ovládanie a či sedí obrazovka pri inom pomere strán (zamknutá scéna, horný pás). Plné ladenie DPI až neskôr. [Open 7]
T08 ODLOŽENÉ (Pavel 2026-10-06): kontrola Google Play pravidiel/IARC až keď bude hotová kostra hry (príbeh, hlášky...). Nemá zmysel kontrolovať hru, ktorá je z 10 % hotová. [Open 10]
T09 AKTÍVNE (Pavel 2026-10-06): základy grafiky sú hotové, teraz sa riešia herné mechanizmy: čo ukončí beh, ekonomika klietok, zoznam vylepšení, odomykanie levelov, prepínanie zbraní poklepaním. [DIZAJN_core_loop §3-4]
T10 ODLOŽENÉ (Pavel 2026-10-06, zatiaľ nevieme): monetizácia (premium 5,99 EUR vs. F2P). [core_loop §4]
T11 HOTOVÉ 2026-10-05: zmeny poslané na GitHub pri čistení histórie (T20).
T20 HOTOVÉ 2026-10-05: história GitHubu vyčistená od starých 3D súborov (`tools/github_cistenie.py`, jednorazový). Pavel: priečinok `slavs_cisty_...` v D:\2026 zmazať hneď, `slavs_zaloha_...` po týždni.
T21 Po 2026-10-12: zmazať zálohu `slavs_zaloha_...` v D:\2026 (Pavel, v Prieskumníku). Priečinok `slavs_cisty_...` sa maže hneď. [T20]

### Čaká na Claude (po OK od Pavla)
T12 HOTOVÉ 2026-10-06 (test na telefóne OK; objekty na okraji majú limit výšky): horný okraj zeme je nerovný (zarezaný do zeme až 44 px), stmavený, s trsmi a kameňmi; hráč chodí podľa neho. Pavel vybral najsilnejšie stmavenie a najviac prvkov (nasadené, okraj je jednofarebný bez prasklín); ak test na telefóne prejde, uzavrieť. Plot/zábrana na okraji až pri finálnom dizajne levelov. [Open 3a]
T13 ZRUŠENÉ 2026-10-06: mechanika je dohodnutá (hra na určitom mieste zamkne vodorovný scroll). Samotné zamykanie sa naprogramuje spolu s bossmi a klietkami, nie ako samostatná úloha.
T14 ZMAZANÉ 2026-10-06: počet ani obsah scén nie je určený; vypálená dedina bola len skúška grafiky, nepadlo rozhodnutie, že je druhou scénou.
T15 UZAVRETÉ 2026-10-06: boj na blízko. Prekrývanie bežcov je prijateľné (Pavel: "je to srandovné, hlavne keď ich je veľa"). Konkrétne zlepšenia sú T22-T24.
T16 HOTOVÉ 2026-10-06 (Pavel: blikanie aj kĺzanie zmizlo): bežec bliká po švihu pri pohybe v Y. Príčina: na hranici dosahu sa prepínal stoj/chôdza každú snímku (bez hysterézy, cieľ sa kýval). Oprava: bežec, ktorý sa zastavil, ostane stáť, kým hráč nie je 1,2x dosah ďalej; kývanie cieľa zamrznuté počas státia; chôdza sa zapne až nad 40 px/s a vypne pod 12 px/s. [Open 5]
T17 AKTÍVNE, DÔLEŽITÉ (Pavel 2026-10-06): farebná paleta nie je zjednotená (PixelLab je primárny zdroj grafiky). MUSÍ sa vyriešiť PRED generovaním finálnej hernej grafiky; kým robíme prototypy, nemusí byť rozhodnuté. [Open 6]
T18 ZAVRETÉ 2026-10-06: gunman idle netreba (stojí, ako keď si ho nevšimol); brute úchop nesedí, ale nič z toho sa teraz nerieši, nevieme, či tieto postavy budú vo finálnej verzii.
T22 Nepriatelia majú mať pevné telo: nedá sa cez nich prejsť a ani oni cez seba (ako sud). Dôsledok: pri mnohých (cca 32+) sa vzájomne zablokujú a nenakopia sa na jednu kopu; treba dať pozor na zaseknutie. (Pavel 2026-10-06)
T23 NÁPAD (neskôr, dizajn): nepriatelia hľadajú inú trasu a obídu hrdinu. Dôsledok: obkľúčia ho a nebude vedieť ujsť. Rozhodnúť neskôr, či to chceme. (Pavel 2026-10-06)
T24 HOTOVÉ 2026-10-06 (test OK): nepriateľ sa pri švihu (aj strelec pri výstrele) uzamkne na mieste. Príčina kĺzania: funkcia, čo rozstrkáva prekrývajúcich sa nepriateľov (`_separate_enemies` v main.gd), posúvala aj švihajúcich; teraz je uzamknutý nepriateľ pevný a odtlačí sa ten druhý. Neskôr lepší nepriatelia dostanú animáciu útoku za pohybu. (Pavel 2026-10-06)

T25 OPRAVENÉ V KÓDE 2026-10-06, ČAKÁ NA TEST NA TELEFÓNE: sudy majú blokovať nepriateľov rovnako ako hrdinu (nepriatelia cez ne prechádzali). Oprava: maska kolízií nepriateľa obsahuje vrstvu rekvizít. Pozor na zaseknutie nepriateľov za stenou sudov. (Pavel 2026-10-06)
T26 OPRAVENÉ V KÓDE 2026-10-06, ČAKÁ NA TEST NA TELEFÓNE: zóna zásahu bežca nebola vycentrovaná na hrdinu. Príčina: dosah sa meral k cieľovému bodu posunutému o hĺbkový posun bežca + kývanie (až ±80 px). Teraz sa dosah meria k hrdinovi samotnému. Dosah je stále kruh (rovnaký v X aj Y); či má byť v hĺbke menší, je rozhodnutie na neskôr. (Pavel 2026-10-06)
T27 OPRAVENÉ V KÓDE 2026-10-06, ČAKÁ NA TEST NA TELEFÓNE: poskočenie hrdinu po zásahu patrí len bežcovi (strelec ho mal omylom). Každý nepriateľ má v `tuning.gd` vlastný účinok zásahu (`RUSHER_HIT_KNOCKBACK`, `THROWER_HIT_KNOCKBACK`, `BRUTE_HIT_KNOCKBACK`; neskôr môže byť spomalenie, otrava...). Výbuch kotla má pôvodný odhod. (Pavel 2026-10-06)
T28 OPRAVENÉ V KÓDE 2026-10-06, ČAKÁ NA TEST NA TELEFÓNE: nepriatelia sa zasekávali za stenou sudov. Teraz: ak sa dlhšie nehýbu, hoci chcú k hrdinovi, vyberú si JEDEN smer v osi Y (k riadku hrdinu) a idú ním, kým sa môžu znova posunúť v X k hrdinovi alebo kým nenarazia na okraj plochy (vtedy sa otočia). Nastavenia `DETOUR_*` v `tuning.gd`. (Pavel 2026-10-06)
T29 OTVORENÉ (Pavel 2026-10-06): zásah bežca sa počíta ako vzdialenosť stredu bežca od stredu hrdinu (obaja v úrovni kolien), nie podľa zbrane ani podľa tela hrdinu. Otázka, či prerobiť na zónu zásahu v mieste švihu, voči zraniteľnej zóne hrdinu. Čaká na rozhodnutie.

### Neskôr
T19 ZMAZANÉ 2026-10-06: fázy F2-F5 sú plán výroby, nie úloha; keď sa odrobia všetky úlohy, ďalší krok sa berie z `PLAN_hry.md`.

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
