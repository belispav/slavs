# Hotové, zrušené a zavreté úlohy (archív)

Presunuté z `KDE_JE_CO.md` a z dashboardu 2026-10-06 (Pavel: v dashboarde chce vidieť len to, čo ho čaká). ID (T01...) sú STÁLE a nikdy sa nepoužijú znova.
Claude tento súbor NEČÍTA, len ak o to Pavel požiada. Aktuálne úlohy sú v `KDE_JE_CO.md` a v dashboarde `KDE_JE_CO.html`.

T01 HOTOVÉ 2026-10-06: test na telefóne. Pozadie A (pokojná hlina) + objekty na zemi (skúšal 100, môže byť aj viac, ladenie neskôr); ostatné pozadia zrušené. Grafika zeme považovaná za vyriešenú.
T02 HOTOVÉ 2026-10-06: hod sekerou. Počas hodu sa hrdina nehýbe (0 = vlastnosť, treba vybrať moment hodu), zamach 3x rýchlejší; zapečené v `tuning.gd`. Nápad: v hre začať s nižším číslom (napr. 1) a levelovať. Nový klip netreba; pri iných zbraniach (kúzla) bude animácia spojená s útokom.
T03 HOTOVÉ 2026-10-06: chôdza aj boss scény majú ROVNAKÚ vertikálnu logiku (jemný zvislý scroll, hracia plocha = výška obrazovky, horný pás navyše len aby bolo vidieť celé telo). Pri bossoch/klietkach sa zamkne LEN horizontálny scroll (nedá sa odísť vľavo ani vpravo). Prepínanie (zoom-in) ostáva v T13.
T05 HOTOVÉ 2026-10-06: skontrolované na telefóne, všetko v poriadku (viac HP, efekty zásahov, zvuky, kotol, brute, nepriatelia za obrazovkou ho dobehnú).
T11 HOTOVÉ 2026-10-05: zmeny poslané na GitHub pri čistení histórie (T20).
T12 HOTOVÉ 2026-10-06 (test na telefóne OK; objekty na okraji majú limit výšky): horný okraj zeme je nerovný (zarezaný do zeme až 44 px), stmavený, s trsmi a kameňmi; hráč chodí podľa neho. Pavel vybral najsilnejšie stmavenie a najviac prvkov (nasadené, okraj je jednofarebný bez prasklín); ak test na telefóne prejde, uzavrieť. Plot/zábrana na okraji až pri finálnom dizajne levelov. [Open 3a]
T13 ZRUŠENÉ 2026-10-06: mechanika je dohodnutá (hra na určitom mieste zamkne vodorovný scroll). Samotné zamykanie sa naprogramuje spolu s bossmi a klietkami, nie ako samostatná úloha.
T14 ZMAZANÉ 2026-10-06: počet ani obsah scén nie je určený; vypálená dedina bola len skúška grafiky, nepadlo rozhodnutie, že je druhou scénou.
T15 UZAVRETÉ 2026-10-06: boj na blízko. Prekrývanie bežcov je prijateľné (Pavel: "je to srandovné, hlavne keď ich je veľa"). Konkrétne zlepšenia sú T22-T24.
T16 HOTOVÉ 2026-10-06 (Pavel: blikanie aj kĺzanie zmizlo): bežec bliká po švihu pri pohybe v Y. Príčina: na hranici dosahu sa prepínal stoj/chôdza každú snímku (bez hysterézy, cieľ sa kýval). Oprava: bežec, ktorý sa zastavil, ostane stáť, kým hráč nie je 1,2x dosah ďalej; kývanie cieľa zamrznuté počas státia; chôdza sa zapne až nad 40 px/s a vypne pod 12 px/s. [Open 5]
T18 ZAVRETÉ 2026-10-06: gunman idle netreba (stojí, ako keď si ho nevšimol); brute úchop nesedí, ale nič z toho sa teraz nerieši, nevieme, či tieto postavy budú vo finálnej verzii.
T19 ZMAZANÉ 2026-10-06: fázy F2-F5 sú plán výroby, nie úloha; keď sa odrobia všetky úlohy, ďalší krok sa berie z `PLAN_hry.md`.
T20 HOTOVÉ 2026-10-05, OVERENÉ 2026-10-06: história GitHubu vyčistená od starých 3D súborov (`tools/github_cistenie.py`, jednorazový). Kontrola: v histórii nie je `render/`, `art/fits`, `tools/blender`, `.blend`/`.fbx`; 130 commitov, 417 MiB (z toho `ref/` 371 MB); `origin/master` na GitHube sedí s lokálnou históriou; `slavs_cisty_...` je zmazaný, `slavs_zaloha_...` ostáva do T21. Zvyšok histórie ~26 MB (staré sprity v zmazanej zložke `volya/`, Meshy obrázky v `ref/`) sa nechal.
T24 HOTOVÉ 2026-10-06 (test OK): nepriateľ sa pri švihu (aj strelec pri výstrele) uzamkne na mieste. Príčina kĺzania: funkcia, čo rozstrkáva prekrývajúcich sa nepriateľov (`_separate_enemies` v main.gd), posúvala aj švihajúcich; teraz je uzamknutý nepriateľ pevný a odtlačí sa ten druhý. Neskôr lepší nepriatelia dostanú animáciu útoku za pohybu. (Pavel 2026-10-06)
T25 HOTOVÉ 2026-10-06 (Pavel: sudy blokujú nepriateľov, obchádzanie funguje): sudy majú blokovať nepriateľov rovnako ako hrdinu (nepriatelia cez ne prechádzali). Oprava: maska kolízií nepriateľa obsahuje vrstvu rekvizít. Pozor na zaseknutie nepriateľov za stenou sudov. (Pavel 2026-10-06)
T26 HOTOVÉ 2026-10-06 (nahradené kruhovou zónou T29): zóna zásahu bežca nebola vycentrovaná na hrdinu. Príčina: dosah sa meral k cieľovému bodu posunutému o hĺbkový posun bežca + kývanie (až ±80 px). Teraz sa dosah meria k hrdinovi samotnému. Dosah je stále kruh (rovnaký v X aj Y); či má byť v hĺbke menší, je rozhodnutie na neskôr. (Pavel 2026-10-06)
T28 HOTOVÉ 2026-10-06 (Pavel: obchádzanie funguje dobre): nepriatelia sa zasekávali za stenou sudov. Teraz: ak sa dlhšie nehýbu, hoci chcú k hrdinovi, vyberú si JEDEN smer v osi Y (k riadku hrdinu) a idú ním, kým sa môžu znova posunúť v X k hrdinovi alebo kým nenarazia na okraj plochy (vtedy sa otočia). Nastavenia `DETOUR_*` v `tuning.gd`. (Pavel 2026-10-06)
T29 HOTOVÉ 2026-10-06 (Pavel: oveľa lepšie, ideálne hodnoty pre bežca 40 / 50 / 40 = dopredu / výška / polomer, nastavené ako predvolené): zóna úderu bežca je KRUH so stredom v mieste dopadu zbrane (dopredu 40 px, výška nad nohami 50 px) a polomerom 40 px. Hrdina je zasiahnutý, ak sa jeho zraniteľný obdĺžnik (telo od nôh nahor) dotýka kruhu. Bežec sa zastaví, hneď ako sa hrdina kruhu dotkne (preto zmizol slider „na akú vzdialenosť sa zastaví“). Panel: slidery dopredu / výška / polomer a prepínač „UKAZ ZONU UDERU BEZCA“ (kruh; po zásahu tmavší).
T30 HOTOVÉ 2026-10-06 (test OK): nepriatelia sa zastavia na spodnom okraji ako hrdina (OK). Pruh pri spodnom okraji bol príliš široký (odstup 20 px) → spodný odstup zmenšený na polovicu, 10 px, pre hrdinu aj nepriateľov (`WALK_BOTTOM_INSET`, slider „odstup od SPODNEHO okraja“); horný odstup ostáva 20 px. Nepriateľ nesmie mať ani pixel pod hracou plochou (`Enemy.clamp_to_field`).
T27 ZAVRETÉ 2026-10-07: poskočenie hrdinu po zásahu patrilo len bežcovi, funguje (test na telefóne). Nahradené T33 (odhodenie obojsmerne).
T31 HOTOVÉ 2026-10-07: tiene pod hrdinom, nepriateľmi, sudmi a kotlami (`shadow.gd`), otestované na telefóne; zapečené: sila 0,3, veľkosť 1.
T32 HOTOVÉ 2026-10-07: náhodnosť zvukov, otestované na telefóne; zapečené: efekty ±2,5 dB hlasitosť a ±25 % výška tónu, hlasy ±1 dB a ±3 %.
Rýchlosť hore-dole 2026-10-07: pomer `free_move_y_ratio` bol zámerne 0,6 (pomalší pohyb v Y), preto sa hrdina hore-dole zdal pomalší a šikmo rýchlejší. Predvolené teraz 1,0 (rovnako rýchlo), posuvník ostáva.
T22 HOTOVÉ 2026-10-07 (Pavel: zmeny OK): pevné telá hrdinu a nepriateľov; šírka 60, hĺbka 30, oprava asymetrie (zamrznutí nepriatelia si nepreskladali box nôh).
T33 HOTOVÉ 2026-10-07 (Pavel: OK): odhodenie po zásahu 0,4 s; bežec 90, strela 35, sekera 70, výbuch kotla 140 px; sekera zraňuje a odhadzuje len cestou k nepriateľom, späť z polovice priehľadná a 1,5x rýchlejšia; zásah preruší útok nepriateľa.
T45 HOTOVÉ 2026-10-07 (Pavel: OK): srdiečka nad postavami (`hearts.gd`, panel 0/1/2, predvolené 2).
T46 HOTOVÉ 2026-10-07 (Pavel: OK): panel UKAZ ZONY ZASAHU (kruh sekery, obdĺžniky zásahu); polomer sekery zapečený na 20; páčka ľavého palca s posúvajúcim sa stredom (pohyb je oveľa lepší).
ŽIVOTY 2026-10-07 (Pavel): bežec 2 (bez zmeny), strelec 1 (bolo 4), tučniak/brut 1 (bolo 10). Hrdina 5.
BALÍK 1 Úder má váhu HOTOVÝ 2026-10-08 (Pavel: otestované na telefóne, sedí)
A1 HOTOVÉ 2026-10-08 (Pavel: OK): zastavenie pri zásahu sekery 30 ms (pri zabití 1,8x dlhšie, najmenší odstup 0,18 s medzi zastaveniami); vypínač + posuvník v paneli.
A2 HOTOVÉ 2026-10-08 (Pavel: OK): biely záblesk zasiahnutého nepriateľa 40 ms (len ak zásah nezabije; mŕtvy zmizne hneď, telo rieši balík 2).
A3 HOTOVÉ 2026-10-08 (Pavel: OK): otras obrazovky pri zásahu sekerou a zabití, zapečené x1,5 (3,75 / 7,5).
A4 HOTOVÉ 2026-10-08 (Pavel: OK): kopnutie kamery v smere letu sekery, zapečené x1,5 (7,5 / 13,5). Pavel: otras a kopnutie sa zlievajú, rozlíši ich vypnutím jedného.
A5 HOTOVÉ 2026-10-08 (Pavel: OK): čísla poškodenia nad nepriateľom, veľkosť písma 16; samotné písmo sa Pavlovi nepáči, vyberie sa pri finálnom ladení (T51).
A6 HOTOVÉ 2026-10-08 (Pavel: OK): kritický zásah 15 % (berie 2 životy, žlté 'KRIT 2!', efekty x1,5); šanca sa bude líšiť podľa zbrane a vylepšení (T50).
A8 HOTOVÉ 2026-10-08 (Pavel: OK): zvuk zásahu podľa materiálu: telo `enemy_hit`, brnenie `armor_clang`, drevo `barrel_hit`; kotol je teraz kov (`armor_clang`). Zvuky sú zatiaľ náhradné, nové súbory na materiál ešte nie sú.
E1 HOTOVÉ 2026-10-08 (Pavel: OK): vibrácia pri zásahu sekerou 200 ms (pri zabití 300 ms); pod 100 ms nič necítiť. Jemnejšie podľa útočníka a počtu životov: T49.
P1 HOTOVÉ 2026-10-08 (Pavel: OK): každý nový efekt balíka 1 má vypínač a posuvník v paneli s popisom; tlačidlo TEST VIBRACIE.
A14 HOTOVÉ 2026-10-08 (Pavel: OK): potvrdené: po zásahu je hrdina 0,9 s nesmrteľný a červeno bliká (`Tuning.PLAYER_IFRAMES`).
A9 HOTOVÉ 2026-10-09 (Pavel: OK): smrť s pointou. Bežec padá podľa PixelLab klipu `rusher_pl_death`, gunman sa zosype na kolená a padne dopredu (`gunman_pl_death`), brute sa rozpadne na kúsky (kód, `corpses.gd burst`). Sila odletu 1,0, rýchlosť animácie 8 fps, ležanie 0,5-1 s.
T36 HOTOVÉ 2026-10-09 (Pavel: OK): telá po ležaní zmiznú v dymovom obláčiku (vypínač TELO ZMIZNE V DYME).
A10 HOTOVÉ 2026-10-09 (Pavel: OK): spomalenie pri poslednom zabití / brutovi: 600 ms pri rýchlosti 0,4 (náhodne 500-700 ms, 0,35-0,45), séria zabití do 8 s; 4 posuvníky v paneli. Biely záblesk 20 ms (15-25).
A12 HOTOVÉ 2026-10-09 (Pavel: OK): krv a triesky ostávajú na zemi dlhšie (`FX_STAIN_TIME` 12 s, ladiť pri finálnej hre).
A11 HOTOVÉ 2026-10-09 (Pavel: OK, prvá časť): okrem sudov sú keramické hrnce (PixelLab, animácia rozbitia), mix 3 sudy + 3 hrnce rozhodené náhodne, dve veľkosti +-5 %, vlastné zvuky (náhradné). Ploty, stany a debny prípadne neskôr s finálnou grafikou.
