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
T20 HOTOVÉ 2026-10-05, OVERENÉ 2026-10-06: história GitHubu vyčistená od starých 3D súborov (`tools/github_cistenie.py`, jednorazový). Kontrola: v histórii nie je `render/`, `art/fits`, `tools/blender`, `.blend`/`.fbx`; 130 commitov, 417 MiB (z toho `ref/` 371 MB); `origin/master` na GitHube sedí s lokálnou históriou; `slavs_cisty_...` je zmazaný, `slavs_zaloha_...` ostáva do T21. Zvyšok histórie ~26 MB (staré sprity v zmazanej zložke `volya/`, Meshy obrázky v `ref/`) sa nechal.
T21 Po 2026-10-12: zmazať zálohu `slavs_zaloha_...` v D:\2026 (Pavel, v Prieskumníku). Priečinok `slavs_cisty_...` sa maže hneď. [T20]

### Čaká na Claude (po OK od Pavla)
T12 HOTOVÉ 2026-10-06 (test na telefóne OK; objekty na okraji majú limit výšky): horný okraj zeme je nerovný (zarezaný do zeme až 44 px), stmavený, s trsmi a kameňmi; hráč chodí podľa neho. Pavel vybral najsilnejšie stmavenie a najviac prvkov (nasadené, okraj je jednofarebný bez prasklín); ak test na telefóne prejde, uzavrieť. Plot/zábrana na okraji až pri finálnom dizajne levelov. [Open 3a]
T13 ZRUŠENÉ 2026-10-06: mechanika je dohodnutá (hra na určitom mieste zamkne vodorovný scroll). Samotné zamykanie sa naprogramuje spolu s bossmi a klietkami, nie ako samostatná úloha.
T14 ZMAZANÉ 2026-10-06: počet ani obsah scén nie je určený; vypálená dedina bola len skúška grafiky, nepadlo rozhodnutie, že je druhou scénou.
T15 UZAVRETÉ 2026-10-06: boj na blízko. Prekrývanie bežcov je prijateľné (Pavel: "je to srandovné, hlavne keď ich je veľa"). Konkrétne zlepšenia sú T22-T24.
T16 HOTOVÉ 2026-10-06 (Pavel: blikanie aj kĺzanie zmizlo): bežec bliká po švihu pri pohybe v Y. Príčina: na hranici dosahu sa prepínal stoj/chôdza každú snímku (bez hysterézy, cieľ sa kýval). Oprava: bežec, ktorý sa zastavil, ostane stáť, kým hráč nie je 1,2x dosah ďalej; kývanie cieľa zamrznuté počas státia; chôdza sa zapne až nad 40 px/s a vypne pod 12 px/s. [Open 5]
T17 AKTÍVNE, DÔLEŽITÉ (Pavel 2026-10-06): farebná paleta nie je zjednotená (PixelLab je primárny zdroj grafiky). MUSÍ sa vyriešiť PRED generovaním finálnej hernej grafiky; kým robíme prototypy, nemusí byť rozhodnuté. [Open 6]
T18 ZAVRETÉ 2026-10-06: gunman idle netreba (stojí, ako keď si ho nevšimol); brute úchop nesedí, ale nič z toho sa teraz nerieši, nevieme, či tieto postavy budú vo finálnej verzii.
T22 Pevné telá pre všetkých (Pavel 2026-10-06, upresnené): hrdina aj nepriatelia nemôžu prejsť jeden cez druhého (hrdina ↔ nepriateľ aj nepriateľ ↔ nepriateľ), podobne ako pri sudoch a kotli. Kolízia sa kontroluje len na SPODNEJ časti postavy (asi 40 % výšky, pri nohách), lebo kamera je spredu a postavy majú môcť chodiť poza seba (horné telá sa môžu prekrývať). Nahradí mäkké rozstrkávanie (`_separate_enemies`, `ENEMY_SEPARATION`). Riziká: pri veľkom počte (cca 32+) sa zablokujú a nebudú sa kopiť do jednej kopy; treba dať pozor na zaseknutie (obchádzanie T28 to čiastočne rieši) a na nepriateľa zamknutého pri švihu. NEZAČATÉ, čaká na zadanie.
T23 NÁPAD (neskôr, dizajn): nepriatelia hľadajú inú trasu a obídu hrdinu. Dôsledok: obkľúčia ho a nebude vedieť ujsť. Rozhodnúť neskôr, či to chceme. (Pavel 2026-10-06)
T24 HOTOVÉ 2026-10-06 (test OK): nepriateľ sa pri švihu (aj strelec pri výstrele) uzamkne na mieste. Príčina kĺzania: funkcia, čo rozstrkáva prekrývajúcich sa nepriateľov (`_separate_enemies` v main.gd), posúvala aj švihajúcich; teraz je uzamknutý nepriateľ pevný a odtlačí sa ten druhý. Neskôr lepší nepriatelia dostanú animáciu útoku za pohybu. (Pavel 2026-10-06)

T25 HOTOVÉ 2026-10-06 (Pavel: sudy blokujú nepriateľov, obchádzanie funguje): sudy majú blokovať nepriateľov rovnako ako hrdinu (nepriatelia cez ne prechádzali). Oprava: maska kolízií nepriateľa obsahuje vrstvu rekvizít. Pozor na zaseknutie nepriateľov za stenou sudov. (Pavel 2026-10-06)
T26 HOTOVÉ 2026-10-06 (nahradené kruhovou zónou T29): zóna zásahu bežca nebola vycentrovaná na hrdinu. Príčina: dosah sa meral k cieľovému bodu posunutému o hĺbkový posun bežca + kývanie (až ±80 px). Teraz sa dosah meria k hrdinovi samotnému. Dosah je stále kruh (rovnaký v X aj Y); či má byť v hĺbke menší, je rozhodnutie na neskôr. (Pavel 2026-10-06)
T27 OPRAVENÉ V KÓDE 2026-10-06, ČAKÁ NA TEST NA TELEFÓNE: poskočenie hrdinu po zásahu patrí len bežcovi (strelec ho mal omylom). Každý nepriateľ má v `tuning.gd` vlastný účinok zásahu (`RUSHER_HIT_KNOCKBACK`, `THROWER_HIT_KNOCKBACK`, `BRUTE_HIT_KNOCKBACK`; neskôr môže byť spomalenie, otrava...). Výbuch kotla má pôvodný odhod. (Pavel 2026-10-06)
T28 HOTOVÉ 2026-10-06 (Pavel: obchádzanie funguje dobre): nepriatelia sa zasekávali za stenou sudov. Teraz: ak sa dlhšie nehýbu, hoci chcú k hrdinovi, vyberú si JEDEN smer v osi Y (k riadku hrdinu) a idú ním, kým sa môžu znova posunúť v X k hrdinovi alebo kým nenarazia na okraj plochy (vtedy sa otočia). Nastavenia `DETOUR_*` v `tuning.gd`. (Pavel 2026-10-06)
T29 HOTOVÉ 2026-10-06 (Pavel: oveľa lepšie, ideálne hodnoty pre bežca 40 / 50 / 40 = dopredu / výška / polomer, nastavené ako predvolené): zóna úderu bežca je KRUH so stredom v mieste dopadu zbrane (dopredu 40 px, výška nad nohami 50 px) a polomerom 40 px. Hrdina je zasiahnutý, ak sa jeho zraniteľný obdĺžnik (telo od nôh nahor) dotýka kruhu. Bežec sa zastaví, hneď ako sa hrdina kruhu dotkne (preto zmizol slider „na akú vzdialenosť sa zastaví“). Panel: slidery dopredu / výška / polomer a prepínač „UKAZ ZONU UDERU BEZCA“ (kruh; po zásahu tmavší).
T30 HOTOVÉ 2026-10-06 (test OK): nepriatelia sa zastavia na spodnom okraji ako hrdina (OK). Pruh pri spodnom okraji bol príliš široký (odstup 20 px) → spodný odstup zmenšený na polovicu, 10 px, pre hrdinu aj nepriateľov (`WALK_BOTTOM_INSET`, slider „odstup od SPODNEHO okraja“); horný odstup ostáva 20 px. Nepriateľ nesmie mať ani pixel pod hracou plochou (`Enemy.clamp_to_field`).

### Zapísané 2026-10-06 (Pavel: len zapísať, v tejto session sa neriešia)
T31 Postavy a veci majú mať tieň. (Pavel 2026-10-06)
T32 Zvuky majú mať náhodnosť, aby nezneli mechanicky: mierne náhodná hlasitosť (nie veľmi) a náhodná výška tónu (pitch). (Pavel 2026-10-06)
T33 Odhodenie po zásahu (knockback) má fungovať obojsmerne a pre viac zbraní. Pri zásahu nepriateľa hrdinom majú obaja odskočiť, každý na opačnú stranu. Odskok hrdinu po zásahu bežcom má byť vždy v smere útoku nepriateľa. Vzdialenosť odskoku môže škálovať podľa sily úderu (veľké zbrane odstrčia viac). Stav kódu: odhodenie je zatiaľ len od bežca, X smeruje od bežca, Y zložka je vždy hore (-320), takže nie je vždy v smere útoku. (Pavel 2026-10-06)
T34 NA ZVÁŽENIE/VYSKÚŠANIE: úder zbrane má mať okolo seba „vlnu“ znázorňujúcu švih alebo sek (oblúk švihu, pich v tvare U alebo V), nakreslenú akoby zo vzduchu. To isté skúsiť pri zásahu nepriateľa, aby bol vidieť „úder“, hoci tam už je krv. (Pavel 2026-10-06)
T35 Vo vzduchu má občas niečo poletovať podľa prostredia: lístie, dážď, sneh, hmla. Rôzna veľkosť (ten istý tvar raz v pôvodných pixeloch, inokedy 2x alebo 3x väčší). (Pavel 2026-10-06)
T36 NA ZVÁŽENIE: ako miznú nepriatelia po smrti. Zatiaľ úvaha o strate v dyme, možno príde iný nápad. (Pavel 2026-10-06)
T37 NA VYSKÚŠANIE: za postavami pri chôdzi občas efekt zvíreného prachu, snehu alebo dymu; v podstate tá istá animácia, farba podľa podkladu, po ktorom chodia. (Pavel 2026-10-06)
T38 Útočníci vo vzduchu a hádzané veci s oblúkovou dráhou sa napodobnia tieňom: predmet opustí ruku a opisuje oblúk, tieň ide lineárne po zemi a nakoniec sa stretnú, čo vytvorí dojem letu. (Pavel 2026-10-06)
T39 Niektoré veci majú znázorniť vietor: vlajky, trsy trávy, hmla, dym. (Pavel 2026-10-06)
T40 Používať shadery, napr. na osvetlenú oblasť (fakľa, oheň, chvíľu po výbuchu kotla), asi aj na hmlu. Pridá hre hĺbku a rozmanitosť. (Pavel 2026-10-06)

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
