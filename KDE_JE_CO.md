# KDE JE ČO — mapa priečinka Slavs fight back

Stav k 2026-10-08. Prehľad pre človeka: `KDE_JE_CO.html` (dashboard, otvor dvojklikom).
Claude: túto mapu aktualizuj pri každom presune alebo pridaní súboru v koreni.

## Balíky – poradie práce (master: `BALIKY_poradie.md`)

Pavel rieši každý balík v novej session (Sonnet). Na rade je balík so stavom NA RADE. Pri uzavretí balíka zmeň stav tu, v `BALIKY_poradie.md` aj v poli `BALIKY` v `KDE_JE_CO.html`; úlohy v balíku majú v dashboarde pole `b` (číslo balíka).

1. **Úder má váhu** – HOTOVÉ 2026-10-08 (kódy sú v `_archiv/TODO_hotove.md`)
2. **Smrť nepriateľa a stopy boja** – NA RADE – A9, T36, A10, A12, A11
3. **Féroví a čitateľní nepriatelia** – čaká – F2, D4, T42
4. **Prvá odmena: zber a séria (+ T09)** – čaká – A15, D1, A16, J4, H1, H3, T09
5. **Hrdina v pohybe** – čaká – B1, T37, B2, A17

## ToDo's (otvorené úlohy; MASTER = CLAUDE.md "Open", ZACNI_TU_dalsia_session.md, DIZAJN_core_loop.md §3-4)

Claude: pri zmene stavu aktualizuj zdroje aj tento zoznam aj `KDE_JE_CO.html`.
ID (T01...) sú STÁLE: Pavel na ne odkazuje ("T07"). Nikdy ich neprečísluj; nová vec dostane ďalšie číslo (posledné pridelené: T51).
Každá úloha má v zátvorke {oblasť prínos námaha}: oblasť = písmeno A–Z (zoznam nižšie), prínos ★★★ zásadné / ★★ veľký rozdiel / ★ drobnosť, námaha nízka/stredná/vysoká. V dashboarde (`TODOS` v `KDE_JE_CO.html`) sú to polia `cat`, `imp` (3/2/1), `eff` (N/S/V); skupina `g`: teba / claude / later / napad. Nápady z výskumu 2026-10-07 majú STÁLE kódy A1…Z8 (písmeno oblasti + poradie, detail a zdroje v `NAPADY_vylepsenia.md`); keď Pavel nápad vyberie, kód ostáva, len sa zmení skupina. Nová úloha mimo výskumu dostane ďalšie T-číslo.
Tu a v dashboarde sú LEN otvorené úlohy. Keď je úloha hotová, zrušená alebo zavretá: presuň jej riadok do `_archiv/TODO_hotove.md` (tam ho Claude nečíta, len na požiadanie) a zmaž ho odtiaľto aj z `KDE_JE_CO.html`. Hotové veci sa v dashboarde nezobrazujú.

### Čaká na Pavla
T04 Offline: prerobiť príbeh; Claude nezačne, kým Pavel neprinesie návrh. [Open 12, Open Brain Biznis P3] {Q ★★★ vysoká}
T06 Schváliť hlášky v `HLASKY.md` (angl.). [HLASKY.md] {D ★★ nízka}
T07 AKTÍVNE (Pavel urobí v najbližších dňoch): krátky test (cca 10 min) na inom telefóne: ovládanie a či sedí obrazovka pri inom pomere strán (zamknutá scéna, horný pás). Plné ladenie DPI až neskôr. [Open 7] {O ★★★ nízka}
T08 ODLOŽENÉ (Pavel 2026-10-06): kontrola Google Play pravidiel/IARC až keď bude hotová kostra hry (príbeh, hlášky...). Nemá zmysel kontrolovať hru, ktorá je z 10 % hotová. [Open 10] {U ★★★ stredná}
T09 AKTÍVNE (Pavel 2026-10-06): základy grafiky sú hotové, teraz sa riešia herné mechanizmy: čo ukončí beh, ekonomika klietok, zoznam vylepšení, odomykanie levelov, prepínanie zbraní poklepaním. [DIZAJN_core_loop §3-4] {J ★★★ vysoká}
T10 ODLOŽENÉ (Pavel 2026-10-06, zatiaľ nevieme): monetizácia (premium 5,99 EUR vs. F2P). [core_loop §4] {Z ★★★ stredná}
T21 Po 2026-10-12: zmazať zálohu `slavs_zaloha_...` v D:\2026 (Pavel, v Prieskumníku). Priečinok `slavs_cisty_...` sa maže hneď. [T20] {U ★ nízka}
T44 ČAKÁ NA PAVLA: skrývanie posuvníkov. Otvor `PANEL_prvky.xlsx` (stĺpec Zobraziť A/N, S-čísla), prepíš a daj Claudovi vedieť; ten spustí `python3 tools/panel_catalog.py import` (zapíše `slavs/scripts/panel_hidden.gd`). Skryté prvky ostávajú v kóde. Teraz skrytých 44 z 75 (odporúčanie Claude). (Pavel 2026-10-07) {U ★ nízka}

### Čaká na Claude (po OK od Pavla alebo na Pavlov test)
T17 AKTÍVNE, DÔLEŽITÉ (Pavel 2026-10-06): farebná paleta nie je zjednotená (PixelLab je primárny zdroj grafiky). MUSÍ sa vyriešiť PRED generovaním finálnej hernej grafiky; kým robíme prototypy, nemusí byť rozhodnuté. [Open 6] {C ★★★ stredná}
T48 CHYBA (Pavel 2026-10-07, len zapísané, zatiaľ sa nerieši): nepriatelia sa zasekávajú, keď je sud blízko okraja obrazovky, najčastejšie pri spodnom okraji (sudy sa tam objavujú často). Pozorované 2026-10-07: pri kotli sa zasekli 4 bežci nad sebou, akoby sa neustále vyhýbali jeden druhému a prekážali si (Pavel: doladíme). Možná súvislosť: obchádzanie prekážok T28 a spodná hranica pola T30. Pri riešení najprv nájsť príčinu, potom opraviť. {F ★★ stredná}

### Neskôr, nápady a na zváženie
T50 ZOZNAM VLASTNOSTÍ ZBRANÍ (Pavel 2026-10-07, priebežne dopĺňať): čo sa môže líšiť podľa zbrane a jej vylepšení. Zatiaľ: šanca na kritický zásah (teraz 15 % pre sekeru, `Tuning.CRIT_CHANCE`; kritický zásah berie 2 životy a efekty zásahu sú o polovicu silnejšie, `CRIT_DAMAGE`, `CRIT_FX_FACTOR`); dosah zásahu sekery (`AXE_HIT_RADIUS` 20); odhodenie (`AXE_PUSH_DIST`); zraňovanie aj cestou späť (T43). {I ★★ nízka}
T51 NA FINÁLNE LADENIE (Pavel 2026-10-07): čísla poškodenia nad nepriateľom: veľkosť písma 16 (odladené), ale Pavlovi sa nepáči hlavne samotné písmo (teraz štandardný font hry). Vybrať pixelový font a dolaďovať veľkosť pri ladení finálnej hry. {A ★ nízka}
T49 NÁPAD (Pavel 2026-10-07, na neskôr): vibrácia podľa toho, KTO nás zasiahne a koľko životov nám zobral (nie jedna dĺžka pre všetko). Odladené na telefóne: pod 100 ms nič, ~100 ms slabé cuknutie, 200 ms cítiť ako zásah, 300 ms ešte lepší zásah. Teraz je pri zásahu hrdinu 180 ms, pri zásahu sekerou 200 ms. {E ★★ nízka}
T23 NÁPAD (neskôr, dizajn): nepriatelia hľadajú inú trasu a obídu hrdinu. Dôsledok: obkľúčia ho a nebude vedieť ujsť. Rozhodnúť neskôr, či to chceme. (Pavel 2026-10-06) {F ★★ stredná}
T34 NA ZVÁŽENIE/VYSKÚŠANIE: úder zbrane má mať okolo seba „vlnu“ znázorňujúcu švih alebo sek (oblúk švihu, pich v tvare U alebo V), nakreslenú akoby zo vzduchu. To isté skúsiť pri zásahu nepriateľa, aby bol vidieť „úder“, hoci tam už je krv. (Pavel 2026-10-06) {A ★★ stredná}
T35 Vo vzduchu má občas niečo poletovať podľa prostredia: lístie, dážď, sneh, hmla. Rôzna veľkosť (ten istý tvar raz v pôvodných pixeloch, inokedy 2x alebo 3x väčší). (Pavel 2026-10-06) {C ★ stredná}
T36 NA ZVÁŽENIE: ako miznú nepriatelia po smrti. Zatiaľ úvaha o strate v dyme, možno príde iný nápad. (Pavel 2026-10-06) {A ★★ stredná}
T37 NA VYSKÚŠANIE: za postavami pri chôdzi občas efekt zvíreného prachu, snehu alebo dymu; v podstate tá istá animácia, farba podľa podkladu, po ktorom chodia. (Pavel 2026-10-06) {B ★ stredná}
T38 Útočníci vo vzduchu a hádzané veci s oblúkovou dráhou sa napodobnia tieňom: predmet opustí ruku a opisuje oblúk, tieň ide lineárne po zemi a nakoniec sa stretnú, čo vytvorí dojem letu. (Pavel 2026-10-06) {C ★ stredná}
T39 Niektoré veci majú znázorniť vietor: vlajky, trsy trávy, hmla, dym. (Pavel 2026-10-06) {C ★ stredná}
T40 Používať shadery, napr. na osvetlenú oblasť (fakľa, oheň, chvíľu po výbuchu kotla), asi aj na hmlu. Pridá hre hĺbku a rozmanitosť. (Pavel 2026-10-06) {C ★★ vysoká}
T41 NA NESKÔR (Pavel 2026-10-07, riešiť pri ladení finálnych postáv, teraz nie, „vyhodené kredity“): niektoré útoky a výbuchy majú vedieť hrdinu odhodiť alebo omráčiť s animáciou. Dve varianty: omráčenie na mieste (točí sa hlava) alebo pád na zem (dlhšie). {B ★★ stredná}
T42 KATALÓG EFEKTOV (Pavel 2026-10-07): postupne spisovať efekty, ktoré môžu mať nepriatelia na nás a my na nich (odhodenie, omráčenie na mieste, pád na zem, spomalenie, zmrazenie atď.). Pri každom nepriateľovi si potom vyberieme z katalógu. Začiatok katalógu: odhodenie (hotové, T33), omráčenie na mieste a pád na zem (T41). {F ★★ nízka}
T43 NÁPAD, VYLEPŠENIE SEKERY (Pavel 2026-10-07): sekera zraňujúca aj cestou späť (bumerang) môže byť neskôr vylepšenie. Aj vtedy cesta späť NESMIE odhadzovať. V kóde je vypínač `Tuning.AXE_RETURN_HURTS` (false). {I ★★ nízka}
T47 NA FINÁLNE LADENIE (Pavel 2026-10-07): ovládanie páčky ľavého palca (rýchlosť rastie od stredu, pri otočke palec prechádza blízko stredu a hrdina spomalí) je teraz dobré (stred páčky sa ťahá za palcom, `free_move_anchor_slides`). Doladiť pri záverečnom teste hry: najviac to bude vadiť pri zamknutých súbojoch s bossmi (freeze fight), lebo pri behu doprava je hrdina v strede obrazovky a palec je ďaleko od neho; blízko sa palec dostane len pri ceste hrdinu k ľavému okraju. Nastroje: posuvníky „posun palca pre plnú rýchlosť“ (vľavo, vpravo + hore/dole), pomer hore-dole, zastavenie počas hodu `throw_move_factor` (0). {O ★★ nízka}

### Nápady z výskumu 2026-10-07 (138 otvorených z 148; čakajú na Pavlov výber; detail a zdroje v `NAPADY_vylepsenia.md`)

Oblasti: A Pocit z úderu, B Hrdina a pohyb, C Vizuál a atmosféra, D Zvuk a hudba, E Vibrácie, F Nepriatelia, G Bossovia, H Klietky a zajatci, I Zbrane a schopnosti, J Beh a level, K Meta-progresia, L Odmeny (dopamín), M Udržanie hráča, N Prvé minúty, O Ovládanie a HUD, P Prístupnosť, Q Príbeh a svet, R Virálnosť, S Marketing, Z Monetizácia, U Technika a kvalita, V Stránka v Google Play.

A7 Iskry a kúsky v mieste zásahu {A ★★ stredná}
A9 Smrť nepriateľa s pointou {A ★★★ stredná}
A10 Spomalenie pri poslednom zabití {A ★★ nízka}
A11 Rozbitné prostredie {A ★★ stredná}
A12 Stopy boja zostávajú na zemi {A ★★ stredná}
A13 Náprah a podržaná snímka úderu {A ★★ nízka}
A15 Odmeny sa „vcucnú“ k hrdinovi {A ★★★ nízka}
A16 Rastúci tón pri sérii {A ★★ nízka}
A17 Červený okraj obrazovky pri nízkom zdraví {A ★★ nízka}
B1 Úskok (dash) s krátkou nesmrteľnosťou {B ★★★ stredná}
B2 Stlačenie a natiahnutie (squash & stretch) {B ★ nízka}
B3 Oneskorený pohyb vlasov, plášťa, reťaze {B ★★ stredná}
B4 Idle animácia s osobnosťou {B ★ stredná}
B5 Hrdina vizuálne rastie s vylepšeniami {B ★★ vysoká}
C1 Čitateľnosť v dave {C ★★★ stredná}
C2 Denná doba a počasie medzi behmi {C ★★ stredná}
C3 Prostredie reaguje na hrdinu {C ★ stredná}
C4 Záblesk farieb pri level-upe a odomknutí {C ★★ nízka}
C5 Animované prechody a menu {C ★ nízka}
C6 Parallax pozadie (ak ešte nie je) {C ★ stredná}
D1 Podpisový zvuk zberu {D ★★★ nízka}
D2 Hudba podľa intenzity {D ★★ stredná}
D3 Slovanský zvukový podpis {D ★★ stredná}
D4 Zvukové varovanie pred útokom {D ★★ nízka}
D5 Zajatci ďakujú v slovanských jazykoch {D ★★ nízka}
D6 Stíšenie hudby pri dôležitej udalosti {D ★ nízka}
F1 Odlišné siluety podľa role {F ★★★ stredná}
F2 Varovanie pred každým útokom {F ★★★ nízka}
F3 Elitní nepriatelia s istou odmenou {F ★★★ stredná}
F4 Zlatý nepriateľ (vzácny utečenec) {F ★★★ nízka}
F5 Komické správanie nepriateľov {F ★★ stredná}
F6 Nepriateľ unesie zajatca {F ★★ stredná}
F7 Zmes typov vo vlne {F ★★ stredná}
F8 Štítonosič zraniteľný zozadu {F ★★ stredná}
F9 Nepriatelia s živlom {F ★ stredná}
F10 Nepriatelia, ktorí sa vzdajú {F ★ nízka}
G1 Fázy bossa {G ★★★ stredná}
G2 Trojité varovanie útokov bossa {G ★★★ nízka}
G3 Objaviteľná slabina {G ★★ stredná}
G4 Úvodná karta bossa {G ★★ nízka}
G5 Veľký pás zdravia bossa {G ★★ nízka}
G6 Boss reaguje na hráča {G ★ nízka}
H1 Viditeľné ohrozenie zajatcov {H ★★★ nízka}
H2 Oslobodení sa pridajú k boju {H ★★★ stredná}
H3 Hodnotenie záchrany {H ★★★ nízka}
H4 Vzácni zajatci s darom {H ★★★ stredná}
H5 Rôzne typy klietok {H ★★ stredná}
H6 Tábor, ktorý rastie s oslobodenými {H ★★★ vysoká}
H7 Celoživotné počítadlo oslobodených {H ★★ nízka}
H8 Časomiera záchrany {H ★ nízka}
I1 Výber 1 z 3 vylepšení počas behu {I ★★★ stredná}
I2 Kombinácie (evolúcie) {I ★★★ stredná}
I3 Reťazové reakcie živlov {I ★★★ stredná}
I4 Dočasné zviera alebo vozidlo {I ★★★ vysoká}
I5 Vtipné premeny hrdinu {I ★★ stredná}
I6 Zbraň viditeľne rastie s úrovňou {I ★★ stredná}
I7 Schopnosť nabíjaná zabíjaním {I ★★ nízka}
I8 Prehodiť / vyradiť ponuku {I ★ nízka}
J1 Krátky beh s jasným koncom {J ★★★ stredná}
J2 Nič nie je stratený beh {J ★★★ nízka}
J3 „Takmer“ obrazovka {J ★★★ nízka}
J4 Séria zabití s násobičom {J ★★★ nízka}
J5 Výsledková obrazovka s počítaním {J ★★★ nízka}
J6 Tlačidlo „Ešte raz“ {J ★★★ nízka}
J7 Náhodné udalosti počas behu {J ★★ stredná}
J8 Ťažšia cesta = viditeľne lepšia odmena {J ★★ nízka}
J9 Oživenie raz za beh {J ★★ nízka}
J10 Tajomstvá v leveli {J ★★ stredná}
K1 Strom vylepšení so silnými skokmi {K ★★★ stredná}
K2 Achievementy cez Google Play Games {K ★★★ stredná}
K3 Úlohy, ktoré odomykajú obsah {K ★★ stredná}
K4 Kódex / bestiár {K ★★ nízka}
K5 Ďalšie postavy z oslobodených {K ★★ vysoká}
K6 Vyššie obtiažnosti po dohraní {K ★★ stredná}
K7 Kozmetika odomykaná hraním {K ★ stredná}
L1 Truhla s napínavým otváraním {L ★★★ stredná}
L2 Odmena každých 20–30 sekúnd {L ★★★ nízka}
L3 Vrstvy odmien {L ★★★ nízka}
L4 Prvý beh nastavený na úspech {L ★★★ stredná}
L5 Farby vzácnosti {L ★★ nízka}
L6 Čísla, ktoré bežia nahor {L ★★ nízka}
M1 Denná výzva s rovnakým behom pre všetkých {M ★★ stredná}
M2 Týždenné pravidlá navyše {M ★★ stredná}
M3 Etická séria dní {M ★ nízka}
M4 Upozornenia striedmo {M ★ nízka}
M5 Osobný rekord a „duch“ v Jame {M ★ stredná}
M6 Merať, či hráči ostávajú {M ★★ nízka}
N1 Akcia do 10 sekúnd {N ★★★ nízka}
N2 Jedna mechanika naraz {N ★★★ nízka}
N3 Jasný cieľ v prvej minúte {N ★★★ nízka}
N4 Prvá klietka: všetci prežijú {N ★★★ nízka}
N5 Ochutnávka plnej sily {N ★★ stredná}
N6 Nápoveda vždy v pauze {N ★ nízka}
O1 Nastaviteľné ovládanie {O ★★ stredná}
O2 Voliteľný ľahší režim útoku {O ★★ stredná}
O3 Podpora ovládača {O ★★ stredná}
O4 Čistá obrazovka {O ★★ nízka}
O5 Okamžitá pauza pri prerušení {O ★★★ nízka}
O6 Šípky na nepriateľov mimo obrazovky {O ★★ nízka}
P2 Nespoliehať sa len na farbu {P ★ nízka}
P3 Ľahší režim {P ★★ stredná}
P4 Titulky hlášok {P ★ nízka}
Q1 Príbeh po kúskoch po každom behu {Q ★★ stredná}
Q2 Postavy v tábore s osobnosťou {Q ★★ stredná}
Q3 Slovanská mytológia ako fantasy vrstva {Q ★★ stredná}
Q4 Ľudoví hrdinovia ako odomykateľné skiny {Q ★★ stredná}
Q5 Vtipné opisy predmetov {Q ★ nízka}
R1 Test klipu pri každom nápade {R ★★★ nízka}
R2 Masa nepriateľov na jednom zábere {R ★★★ stredná}
R3 Jeden screenshot vysvetlí hru {R ★★★ stredná}
R4 Zdieľateľná karta výsledku {R ★★ nízka}
R5 Vtipné zlyhania {R ★★ stredná}
R6 Záznam posledných sekúnd {R ★ vysoká}
S1 Krátke videá 2–3× týždenne {S ★★★ nízka}
S2 Príbeh tvorcu ako hák {S ★★★ nízka}
S3 Malí tvorcovia namiesto veľkých {S ★★ nízka}
S4 Platené zosilnenie len víťazných videí {S ★ nízka}
S5 Steam stránka a demo včas {S ★★ stredná}
S6 Spolupráca s inou indie hrou {S ★ nízka}
Z1 Možnosť 1: Premium 5,99 € (súčasný plán) {Z ★★★ nízka}
Z2 Doplnok k možnosti 1: Google Play Game Trials {Z ★★★ nízka}
Z3 Možnosť 2: Zadarmo + jednorazové odomknutie {Z ★★ nízka}
Z4 Možnosť 3: Zadarmo s voliteľnými reklamami {Z ★★ nízka}
Z5 Možnosť 4: F2P s nákupmi (model Archero / Survivor.io) {Z ★★ vysoká}
Z6 Možnosť 5: Hybrid {Z ★★ stredná}
Z7 Možnosť 6: Predplatné služby {Z ★ nízka}
Z8 Možnosť 7: Steam ako hlavný premium trh {Z ★★ stredná}
U1 Stabilita pod prahmi Google {U ★★★ nízka}
U2 60 fps na lacnom telefóne pri 30+ nepriateľoch {U ★★★ stredná}
U3 Hra funguje offline {U ★★ nízka}
U4 Postup cez Play Games Services {U ★★ stredná}
U5 Analytika správania {U ★★ stredná}
U6 Rýchly štart a malá aplikácia {U ★★ stredná}
U7 Šetrenie batérie {U ★ nízka}
V1 Ikona čitateľná v malom {V ★★ nízka}
V2 Prvé screenshoty s akciou a krátkym textom {V ★★ nízka}
V3 Video začína najväčšou akciou {V ★★ nízka}
V4 Testovať aspoň týždeň {V ★ nízka}

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
| `NAPADY_vylepsenia.md` | obaja | Výskum 2026-10-07: 148 nápadov s popisom a zdrojmi; otvorené nápady sú v ToDo (kódy A1…Z8) |
| `BALIKY_poradie.md` | Claude | Balíky práce (poradie, stav, čo už v kóde je, ako balík uzavrieť); číta sa na začiatku každej session |
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
