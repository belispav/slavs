# Katalóg efektov (T42, začatý 2026-10-10)

Zoznam efektov, ktoré môžu mať nepriatelia na nás a my na nich. Pri každom novom nepriateľovi
alebo zbrani sa z neho vyberá. Stav: **hotové** = je v hre, **plán** = nápad, nič sa nestavia.
Hodnoty sú z kódu (`tuning.gd`); finálne sa ladia až s finálnou grafikou (T17).

## A. Efekty nepriateľov na hrdinu

| Efekt | Čo to robí | Kto ho má | Hodnoty | Stav |
|---|---|---|---|---|
| Odhodenie (T33) | Zásah posunie hrdinu o pevnú vzdialenosť v smere útoku (hĺbka x0,6), po dobu `knockback_time` 0,4 s sa spomaľuje | bežec (palcát), strelec (guľka) | bežec 90 px, strelec 35 px, obor 0 | hotové |
| Výbuch kotla | Odhodí hrdinu (god mode ho blokuje) | kotol | 140 px | hotové |
| Zranenie + nesmrteľnosť po zásahu (A14) | Strata 1 života, potom 0,9 s nezraniteľnosť s červeným blikaním | všetci | 0,9 s | hotové |
| Chytenie | Hrdina je držaný pred hrudníkom, každú 1 s strata 1 života, nemôže sa hýbať | obor | tick 1,0 s, dosah 80 x 30 px, pauza po uvoľnení 2,5 s | hotové |
| Omráčenie na mieste (T41) | Hrdina stojí, točí sa mu hlava, krátko sa nehýbe | zatiaľ nikto | — | plán, až s finálnymi postavami |
| Pád na zem (T41) | Hrdina padne a vstáva (dlhšie než omráčenie) | zatiaľ nikto | — | plán, až s finálnymi postavami |
| Spomalenie, zmrazenie, otrava | Zmena rýchlosti alebo postupná strata života | zatiaľ nikto | — | nápad |

## B. Efekty hrdinu na nepriateľov

| Efekt | Čo to robí | Kto ho zažíva | Hodnoty | Stav |
|---|---|---|---|---|
| Odhodenie sekerou (T33) | Zásah posunie nepriateľa v smere letu; odhodený nepriateľ je omráčený (zahodí útok, nechodí) | bežec, strelec (obor sa nehýbe) | 70 px, 0,4 s; seker na ceste späť nezraňuje | hotové |
| Zastavenie hry + biely zablesk + trasenie + kopnutie kamery (A1–A4) | Pocit ťažkého úderu | všetci | stop 30 ms, zablesk 40 ms, trasenie a kopnutie x1,5 | hotové |
| Kritický zásah (A6) | Viac poškodenia a silnejšie efekty | všetci | 15 % šanca, 2 životy | hotové |
| Brnenie | Seker sa odrazí, iskry, žiadna krv | obor (predné brnenie) | — | hotové |
| Výbuch kotla | Poškodenie, brnenie nepomáha | všetci | 10 životov obora = jeden výbuch | hotové |
| Smrť s pointou (A9, T36, A10) | Telo odletí, otočí sa, dopadne, zmizne v dyme; spomalenie pri poslednom zabití | všetci | pozri `tuning.gd` (CORPSE_*, SLOWMO_*) | hotové |
| Omráčenie na mieste, pád na zem (T41) | To isté ako v A, ale na nepriateľovi | — | — | plán |
| Spomalenie, zmrazenie, otrava | Budúce zbrane a kúzla | — | — | nápad |

## C. Efekty bez účinku na hru (vzhľad, čitateľnosť)

| Efekt | Čo to robí | Stav |
|---|---|---|
| Varovanie pred útokom (F2, D4) | Pred úderom/výstrelom/chytením nepriateľ bliká do červena a vydá svoj zvuk; obor má pred chytením výmah 0,4 s, v ktorom sa dá uhnúť | hotové v kóde, čaká na test na telefóne |
| Špina na nepriateľoch | 5 vzhľadov so škvrnami, obor nemá škvrny na hlave | hotové, čaká na finálne čísla |
| Náhodnosť (pravidlo 7) | Každý nepriateľ a efekt sa trochu líši | hotové, posuvník NAHODNOST |

Poznámka: pri každom novom efekte doplň riadok sem (kto → koho, čo robí, hodnoty, stav).
