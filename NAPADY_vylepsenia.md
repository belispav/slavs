# Nápady na vylepšenie hry Slavs fight back

Výskum z internetu, 2026-10-07. Spolu **148 nápadov** v 22 oblastiach. Otvorené nápady sú v ToDo dashboarde `KDE_JE_CO.html` (rovnaké kódy). Tento súbor = detail a zdroje, snímka výskumu; kategória monetizácie má písmeno Z.

Dôležitosť: ★★★ zásadné (bez toho hra nebude chytľavá) · ★★ veľký rozdiel · ★ drobnosť, ale počíta sa.  
Námaha: nízka / stredná / vysoká (odhad pre váš projekt: Godot + PixelLab + AI).  
Nič z toho nie je rozhodnuté ani začaté. Pravidlá z PLAN_hry.md §2 platia pre všetky nápady.

## Najlepší pomer: zásadné a lacné (27)

- **A1 Zastavenie času pri zásahu (hit-stop)** (Pocit z úderu a zásahu (game feel))
- **A2 Biely záblesk zasiahnutého nepriateľa** (Pocit z úderu a zásahu (game feel))
- **A3 Otras obrazovky podľa sily** (Pocit z úderu a zásahu (game feel))
- **A14 Krátka nesmrteľnosť hrdinu po zásahu** (Pocit z úderu a zásahu (game feel))
- **A15 Odmeny sa „vcucnú“ k hrdinovi** (Pocit z úderu a zásahu (game feel))
- **D1 Podpisový zvuk zberu** (Zvuk a hudba)
- **F2 Varovanie pred každým útokom** (Nepriatelia)
- **F4 Zlatý nepriateľ (vzácny utečenec)** (Nepriatelia)
- **G2 Trojité varovanie útokov bossa** (Bossovia)
- **H1 Viditeľné ohrozenie zajatcov** (Klietky a zajatci (vaše jadro))
- **H3 Hodnotenie záchrany** (Klietky a zajatci (vaše jadro))
- **J2 Nič nie je stratený beh** (Beh a level)
- **J3 „Takmer“ obrazovka** (Beh a level)
- **J4 Séria zabití s násobičom** (Beh a level)
- **J5 Výsledková obrazovka s počítaním** (Beh a level)
- **J6 Tlačidlo „Ešte raz“** (Beh a level)
- **L2 Odmena každých 20–30 sekúnd** (Dopamínová slučka a odmeny)
- **L3 Vrstvy odmien** (Dopamínová slučka a odmeny)
- **N1 Akcia do 10 sekúnd** (Prvé minúty hry)
- **N2 Jedna mechanika naraz** (Prvé minúty hry)
- **N3 Jasný cieľ v prvej minúte** (Prvé minúty hry)
- **N4 Prvá klietka: všetci prežijú** (Prvé minúty hry)
- **O5 Okamžitá pauza pri prerušení** (Ovládanie a obrazovka (HUD))
- **R1 Test klipu pri každom nápade** (Virálnosť a zdieľanie)
- **S1 Krátke videá 2–3× týždenne** (Marketing)
- **S2 Príbeh tvorcu ako hák** (Marketing)
- **U1 Stabilita pod prahmi Google** (Technika a kvalita)

## Už máte v zozname (výskum to potvrdzuje, preto tu nie sú znova)

- **T31** Tieň pod postavami – potvrdené (hrdina aj nepriatelia, sekera).
- **T32** Náhodná výška a hlasitosť zvukov – potvrdené (Nuclear Throne).
- **T33** Odhodenie po zásahu – potvrdené (Mega Cat, Vlambeer).
- **T34** Oblúk švihu („smear“) – potvrdené (princípy animácie).
- **T35** Poletujúce častice prostredia (lístie, sneh).
- **T36** Ako miznú nepriatelia – rozšírené v A „Smrť nepriateľa s pointou“.
- **T37** Prach spod nôh – potvrdené (3-snímkový obláčik pri dopade).
- **T38** Tieň letiaceho predmetu po zemi.
- **T39** Vietor na vlajkách, tráve, dyme.
- **T40** Svetlo, fakle, záblesk po výbuchu – potvrdené (Mega Cat: krátky svetelný zdroj pri výbuchu).
- **T41/T42** Omráčenie a katalóg efektov.
- **T43** Sekera ako bumerang ako vylepšenie.
- **T45** Srdiečka nad postavami.
- **T17** Jednotná farebná paleta – potvrdené (čitateľnosť).
- **Plán** Živly zbraní, vetvenie ciest, aréna Jama, denná výzva, kódex, Perúnov hnev, stádo koní, Steam port, Play Pass.

## A. Pocit z úderu a zásahu (game feel)

_Malé efekty, vďaka ktorým má každý úder váhu. Najlacnejšie a najviditeľnejšie zlepšenia._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| A1 | Zastavenie času pri zásahu (hit-stop) | Pri zásahu sa hra na zlomok sekundy (asi 30–80 ms, Vlambeer používa 10–20 ms na každý zásah) zmrazí: útočník aj zasiahnutý. Pri slabom zásahu kratšie, pri bossovi a kritickom zásahu dlhšie. Najlacnejší spôsob, ako dať úderu váhu. | ★★★ zásadné | nízka | [Jan Willem Nijman (Vlambeer, Nuclear Throne) – čo sa deje pri jednom výstrele](https://infovore.org/?p=5275) |
| A2 | Biely záblesk zasiahnutého nepriateľa | Zasiahnutý nepriateľ je 1–2 snímky celý biely. Hráč okamžite vidí, že trafil, aj v dave 30 postáv. | ★★★ zásadné | nízka | [Jan Willem Nijman (Vlambeer, Nuclear Throne) – čo sa deje pri jednom výstrele](https://infovore.org/?p=5275) |
| A3 | Otras obrazovky podľa sily | Malý pri sekere, väčší pri výbuchu kotla, najväčší pri bossovi; rýchlo doznie. Musí sa dať vypnúť v nastaveniach. | ★★★ zásadné | nízka | [Mega Cat Studios – Juice Guide (shooter / run'n'gun)](https://megacatstudios.com/blogs/game-development/mega-cat-developer-juice-guide-v1-0-08-23-17) |
| A4 | Mierny posun kamery v smere hodu | Kamera sa pri hode posunie o 2–4 px v smere útoku a vráti sa. Hod pôsobí silnejšie, hráč to vedome nevníma. | ★ drobnosť | nízka | [Jan Willem Nijman (Vlambeer, Nuclear Throne) – čo sa deje pri jednom výstrele](https://infovore.org/?p=5275) |
| A5 | Čísla poškodenia nad nepriateľmi | Vyskakujúce čísla pri zásahu; kritické väčšie a inou farbou. Archero aj Vampire Survivors ich majú ako odmenu pri každom zásahu. Vypínateľné. | ★★ veľký rozdiel | nízka | [Deconstructor of Fun – prečo Archero zarobilo](https://www.deconstructoroffun.com/blog/2019/8/9/why-archero-banked-25m-but-leaves-25m-hanging-hlx9n) |
| A6 | Kritický zásah | Náhodne 5–10 % zásahov urobí dvojnásobok, s iným zvukom a väčším číslom. Malá náhodná odmena v každom hode. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| A7 | Iskry a kúsky v mieste zásahu | 2–3 snímky efektu presne tam, kde sekera trafila; iný pre telo, drevo a kov (štít, prilba). | ★★ veľký rozdiel | stredná | [Mega Cat Studios – Juice Guide (shooter / run'n'gun)](https://megacatstudios.com/blogs/game-development/mega-cat-developer-juice-guide-v1-0-08-23-17) |
| A8 | Zvuk zásahu podľa materiálu | Zvuk zásahu = materiál (mäso, drevo, kov) zmiešaný s výkrikom postavy. Takto to robí Nuclear Throne. | ★★ veľký rozdiel | stredná | [Jan Willem Nijman (Vlambeer, Nuclear Throne) – čo sa deje pri jednom výstrele](https://infovore.org/?p=5275) |
| A9 | Smrť nepriateľa s pointou | Telo odletí v smere zásahu, pretočí sa, dopadne a poskočí. Každá smrť je malá odmena. (Súvisí s vaším T36 – ako miznú.) | ★★★ zásadné | stredná | [Mega Cat Studios – Juice Guide (shooter / run'n'gun)](https://megacatstudios.com/blogs/game-development/mega-cat-developer-juice-guide-v1-0-08-23-17) |
| A10 | Spomalenie pri poslednom zabití | Posledný nepriateľ vlny alebo boss: pol sekundy spomalený čas a mierny zoom. Klasický moment na klip. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| A11 | Rozbitné prostredie | Sudy, debny, ploty a stany sa rozletia na kúsky a zostanú trosky. Broforce bolo chválené práve za ničiteľné prostredie. | ★★ veľký rozdiel | stredná | [Wikipedia – Broforce (záchrana zajatcov = nová postava)](https://en.wikipedia.org/wiki/Broforce) |
| A12 | Stopy boja zostávajú na zemi | Štylizované škvrny, trosky, zapichnuté šípy. Miesto po boji vyzerá ako po boji (Vlambeer to preferuje pred čistou stenou). Pozor na PEGI: štylizovane, nie realisticky. | ★★ veľký rozdiel | stredná | [Jan Willem Nijman (Vlambeer, Nuclear Throne) – čo sa deje pri jednom výstrele](https://infovore.org/?p=5275) |
| A13 | Náprah a podržaná snímka úderu | 1 snímka náprahu pred hodom (60–80 ms) a snímka zásahu podržaná dlhšie (120–200 ms). Rozdiel medzi amatérskou a profesionálnou animáciou. Riešiť pri PixelLab animáciách. | ★★ veľký rozdiel | nízka | [Princípy animácie v pixel arte (časovanie, anticipácia, smear)](https://www.sprite-ai.art/guides/animation-principles) |
| A14 | Krátka nesmrteľnosť hrdinu po zásahu | Po zásahu hrdina 0,5–1 s bliká a nedá sa zraniť. Hráč vidí, že dostal, a má chvíľu na útek; v dave 30 nepriateľov inak umrie za sekundu. | ★★★ zásadné | nízka | [Mega Cat Studios – Juice Guide (shooter / run'n'gun)](https://megacatstudios.com/blogs/game-development/mega-cat-developer-juice-guide-v1-0-08-23-17) |
| A15 | Odmeny sa „vcucnú“ k hrdinovi | Mena / duše zajatcov letia magnetom k hrdinovi, každá s krátkym zvukom. Zber je jeden z najsilnejších príjemných pocitov vo Vampire Survivors. | ★★★ zásadné | nízka | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| A16 | Rastúci tón pri sérii | Každý ďalší zásah alebo zber v rýchlej sérii má o kúsok vyšší tón. Mozog to vníma ako stupňovanie (Peggle, Balatro). | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| A17 | Červený okraj obrazovky pri nízkom zdraví | Pri posledných srdiečkach sa okraj obrazovky zafarbí a ozve sa tlkot srdca. Napätie bez jediného slova. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## B. Hrdina a pohyb

_Ako sa hrdina hýbe a ako vyzerá, keď rastie._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| B1 | Úskok (dash) s krátkou nesmrteľnosťou | Rýchly úskok na pár desiatok px, počas neho hrdina nedostane zásah. Dá hráčovi aktívny nástroj na únik z obkľúčenia (riziko z vášho T23). Dead Cells má úskok aj na mobile (potiahnutím). | ★★★ zásadné | stredná | [TouchArcade – Dead Cells mobilné ovládanie (Auto-Hit, nastaviteľné tlačidlá)](https://toucharcade.com/2019/05/07/dead-cells-mobile-blog-post/) |
| B2 | Stlačenie a natiahnutie (squash & stretch) | Pri dopade, odhodení a štarte sa postava na 1 snímku o 1–2 px stlačí/natiahne. Pôsobí živo a pružne. | ★ drobnosť | nízka | [Princípy animácie v pixel arte (časovanie, anticipácia, smear)](https://www.sprite-ai.art/guides/animation-principles) |
| B3 | Oneskorený pohyb vlasov, plášťa, reťaze | Vlasy alebo zvyšok reťaze na zápästí sa hýbu o snímku neskôr ako telo. Reťaz je zároveň vizuálny symbol príbehu. | ★★ veľký rozdiel | stredná | [Princípy animácie v pixel arte (časovanie, anticipácia, smear)](https://www.sprite-ai.art/guides/animation-principles) |
| B4 | Idle animácia s osobnosťou | Keď hráč 5 s nič nerobí, hrdina si pretiahne ramená, pohodí sekerou. Drobnosť, ktorú hráči zachytia na videách. | ★ drobnosť | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| B5 | Hrdina vizuálne rastie s vylepšeniami | Po vylepšeniach pribúda výstroj (kožušina, prilba, lepšia sekera) a reťaz ubúda. Progres vidno na postave, nie len v číslach. | ★★ veľký rozdiel | vysoká | Všeobecne známa herná prax (bez jedného zdroja) |

## C. Vizuál a atmosféra

_Pixel art, svetlo, prostredie, čitateľnosť v dave._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| C1 | Čitateľnosť v dave | Hrdina a nepriatelia sa musia odlíšiť od pozadia aj pri 30 postavách: tmavý obrys, sýtejšie farby postáv, tlmenejšie pozadie. Bez toho je dav len šum. | ★★★ zásadné | stredná | [Bugnet – čitateľný dizajn nepriateľov](https://bugnet.io/blog/how-to-design-a-readable-enemy-design) |
| C2 | Denná doba a počasie medzi behmi | Ten istý level ráno, za súmraku, v daždi, v snehu. Lacná rozmanitosť pre hru, kde sa úsek opakuje desiatky ráz. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| C3 | Prostredie reaguje na hrdinu | Vtáky vyletia, keď prebehne, pes zašteká, sliepky utekajú pred bojom. Metal Slug je známy takýmito drobnosťami. | ★ drobnosť | stredná | [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug) |
| C4 | Záblesk farieb pri level-upe a odomknutí | Svetelný lúč, konfety pixelov, krátky jas. Jasne oddelí „niečo dôležité sa stalo“ od bežného boja. | ★★ veľký rozdiel | nízka | [Mega Cat Studios – Juice Guide (shooter / run'n'gun)](https://megacatstudios.com/blogs/game-development/mega-cat-developer-juice-guide-v1-0-08-23-17) |
| C5 | Animované prechody a menu | Prechody medzi obrazovkami (posun, stmievanie), tlačidlá reagujú pohybom a zvukom. Hra pôsobí hotovo. | ★ drobnosť | nízka | [Mega Cat Studios – Juice Guide (shooter / run'n'gun)](https://megacatstudios.com/blogs/game-development/mega-cat-developer-juice-guide-v1-0-08-23-17) |
| C6 | Parallax pozadie (ak ešte nie je) | Viac vrstiev pozadia, ktoré sa hýbu rôznou rýchlosťou, dáva hĺbku aj pixel artu. Overiť, čo už je v DIZAJN_pozadie. | ★ drobnosť | stredná | Všeobecne známa herná prax (bez jedného zdroja) |

## D. Zvuk a hudba

_Polovica pocitu z hry je zvuk._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| D1 | Podpisový zvuk zberu | Jeden výrazný, príjemný zvuk zberu meny/zajatca, ktorý si hráč spojí s hrou (ako zvuk mince v Mariovi). Hrá sa najčastejšie zo všetkých. | ★★★ zásadné | nízka | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| D2 | Hudba podľa intenzity | Vrstvy hudby: pokoj → boj → klietka v ohrození → boss. Pridáva/uberá sa nástroj podľa situácie. | ★★ veľký rozdiel | stredná | [Bugnet – adaptívna hudba pre začiatočníkov](https://bugnet.io/blog/adaptive-music-a-beginners-guide) |
| D3 | Slovanský zvukový podpis | Fujara, gajdy, gusle, viachlasný ženský spev zmiešané s tvrdými bicími. Jedinečná identita a silný hák na videá. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| D4 | Zvukové varovanie pred útokom | Každý typ nepriateľa má pred útokom vlastný krátky zvuk. Hráč sa dá „počuť“ aj keď nevidí. | ★★ veľký rozdiel | nízka | [Wayline – návrh bossov (varovanie, fázy, slabiny)](https://www.wayline.io/blog/crafting-legendary-boss-battles) |
| D5 | Zajatci ďakujú v slovanských jazykoch | Oslobodení zajatci zakričia „Ďakujem! Dziękuję! Děkuji! Дякую!“. Pre SK/CZ/PL/UA publikum vtipný a zdieľateľný detail. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| D6 | Stíšenie hudby pri dôležitej udalosti | Pri zjavení bossa, otvorení truhly alebo záchrane klietky sa hudba na chvíľu stíši, aby vynikol dôležitý zvuk. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## E. Vibrácie telefónu

_Haptika – silný nástroj na mobile, ak sa nepreženie._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| E1 | Vibrácie pri dôležitých momentoch | Krátka vibrácia pri zásahu sekerou, silnejšia pri výbuchu, iný vzor pri zásahu hrdinu. Nie pri každom kroku. Vypínač a sila v nastaveniach. | ★★ veľký rozdiel | nízka | [Wayline – vibrácie: menej je viac](https://www.wayline.io/blog/haptic-feedback-less-is-more) |

## F. Nepriatelia

_Rozmanitosť, čitateľnosť a humor nepriateľov._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| F1 | Odlišné siluety podľa role | Rýchly nepriateľ je štíhly, ťažký široký, strelec má zbraň čitateľnú v obryse. Hráč rozozná typ za zlomok sekundy. | ★★★ zásadné | stredná | [Bugnet – čitateľný dizajn nepriateľov](https://bugnet.io/blog/how-to-design-a-readable-enemy-design) |
| F2 | Varovanie pred každým útokom | Náprah + blik + zvuk pred útokom nepriateľa. Hra je férová, smrť je chyba hráča, nie náhoda. | ★★★ zásadné | nízka | [Bugnet – čitateľný dizajn nepriateľov](https://bugnet.io/blog/how-to-design-a-readable-enemy-design) |
| F3 | Elitní nepriatelia s istou odmenou | Väčší, so žiarou, viac zdravia a vždy pustí predmet. V Metal Slugu vojak v žltom (seržant) vždy niečo pustí. | ★★★ zásadné | stredná | [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug) |
| F4 | Zlatý nepriateľ (vzácny utečenec) | Raz za čas sa objaví vzácny nepriateľ s truhlou, ktorý uteká. Ak ho dobehneš, veľká odmena. Náhodná odmena, ktorú si hráč zapamätá. | ★★★ zásadné | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| F5 | Komické správanie nepriateľov | Rozprávajú sa, jedia pri ohni, utekajú s krikom, keď ich zostane málo, panika po smrti veliteľa. Humor Metal Slugu. | ★★ veľký rozdiel | stredná | [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug) |
| F6 | Nepriateľ unesie zajatca | Nepriateľ schmatne zajatca z klietky a uteká s ním doprava. Hráč sa musí rozhodnúť: dobehnúť ho, alebo brániť klietku. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| F7 | Zmes typov vo vlne | Rýchli + ťažkí + strelci + štítonosiči + podporný (lieči/posilňuje ostatných). Kombinácie sú zaujímavejšie než ďalší nový typ. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| F8 | Štítonosič zraniteľný zozadu | Spredu blokuje sekeru, hráč ho musí obísť (2.5D pohyb to umožňuje). Núti hýbať sa. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| F9 | Nepriatelia s živlom | Ohnivý, ľadový nepriateľ – učí hráča živly skôr, než stretne bossa so slabinou na živel. | ★ drobnosť | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| F10 | Nepriatelia, ktorí sa vzdajú | Keď je hrdina veľmi silný, slabší nepriatelia padnú na kolená alebo utečú. Posilní pocit nezastaviteľnej sily. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## G. Bossovia

_Najlepšie momenty na klipy a najväčšie odmeny._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| G1 | Fázy bossa | Pri 66 % a 33 % zdravia boss zmení útoky alebo bojisko, prechod je jasne oznámený. Nie len viac zdravia a poškodenia. | ★★★ zásadné | stredná | [Wayline – návrh bossov (varovanie, fázy, slabiny)](https://www.wayline.io/blog/crafting-legendary-boss-battles) |
| G2 | Trojité varovanie útokov bossa | Každý útok: vizuálny signál (červený blik) + zvuk + veľký náprah. Signály rovnaké celý boj. | ★★★ zásadné | nízka | [Wayline – návrh bossov (varovanie, fázy, slabiny)](https://www.wayline.io/blog/crafting-legendary-boss-battles) |
| G3 | Objaviteľná slabina | Napr. boss sa po sérii útokov prehreje a je zraniteľný; nápoveda je vo svete (para, iskry). Sedí na váš plán slabšieho/silnejšieho bossa. | ★★ veľký rozdiel | stredná | [Wayline – návrh bossov (varovanie, fázy, slabiny)](https://www.wayline.io/blog/crafting-legendary-boss-battles) |
| G4 | Úvodná karta bossa | 2–3 s: meno, prezývka, póza, nápis. Stojí málo a je to najzdieľanejší moment v akčných hrách. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| G5 | Veľký pás zdravia bossa | Hore cez celú šírku, rozdelený na fázy. Hráč vidí, koľko mu chýba (aj „takmer“ moment pri smrti). | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| G6 | Boss reaguje na hráča | Posmešky, keď hráča zrazí, zlosť pri nízkom zdraví. Osobnosť bez cutscén. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## H. Klietky a zajatci (vaše jadro)

_Nápady priamo pre váš hlavný mechanizmus._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| H1 | Viditeľné ohrozenie zajatcov | Nad klietkou počet živých zajatcov; keď niekoho udrú, krátky výkrik a blik. Hráč cíti naliehavosť, ktorá je jadrom vášho dizajnu. | ★★★ zásadné | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| H2 | Oslobodení sa pridajú k boju | Zachránení vybehnú a 10–20 s bojujú po boku hrdinu (hádžu kamene, mlátia palicami). Rastúci dav za hrdinom je presne obraz z virálnych reklám s rastúcou armádou (Last War, Count Masters) a napĺňa vetu z plánu „beriem so sebou každého“. | ★★★ zásadné | stredná | [AppGrowing – Last War, reklamy s rastúcou armádou](https://appgrowing.net/blog/en/how-last-war-uses-proxy-minigames-to-package-strategy-gameplay/) |
| H3 | Hodnotenie záchrany | Všetci zachránení = „PERFEKTNÉ“ + bonus; 1–3 hviezdičky za klietku. Okamžitá spätná väzba a dôvod opakovať. | ★★★ zásadné | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| H4 | Vzácni zajatci s darom | Kováč (vylepší zbraň v behu), bylinkárka (vylieči), lukostrelec (zostane do konca behu). V Metal Slugu zajatci dávajú predmety; v Broforce záchrana = nová postava. | ★★★ zásadné | stredná | [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug) |
| H5 | Rôzne typy klietok | Drevená klietka, voz s klietkou, ktorý odchádza (časový tlak), jama, loď. Rozmanitosť bez nového systému. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| H6 | Tábor, ktorý rastie s oslobodenými | Medzi behmi tábor/dedina, kde pribúdajú domy a ľudia podľa počtu zachránených. Výsledok snahy vidno. V Hades je domov medzi behmi srdcom hry. | ★★★ zásadné | vysoká | [Hades – smrť ako posun príbehu](https://criticalvideogamestudies.com/hades-death-and-the-players-experience/) |
| H7 | Celoživotné počítadlo oslobodených | Veľké číslo na hlavnej obrazovke („Oslobodených: 12 480“). Zdieľateľné a hrdé číslo. (Je už v pláne – potvrdzujem prioritu.) | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| H8 | Časomiera záchrany | Viditeľný čas záchrany a osobný rekord pre každú klietku. Súťaž sám so sebou. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## I. Zbrane, schopnosti, buildy

_Variabilita behov a pocit, že hráč skladá vlastnú silu._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| I1 | Výber 1 z 3 vylepšení počas behu | Po naplnení skúseností si hráč vyberie 1 z 3 náhodných vylepšení. Hlavný motor Vampire Survivors a Archera: každý beh je iný. Treba zladiť s vaším pravidlom „max 3 zbrane pred štartom“. | ★★★ zásadné | stredná | [Deconstructor of Fun – prečo Archero zarobilo](https://www.deconstructoroffun.com/blog/2019/8/9/why-archero-banked-25m-but-leaves-25m-hanging-hlx9n) |
| I2 | Kombinácie (evolúcie) | Dve konkrétne veci spolu = nová silnejšia (sekera + oheň = horiaca sekera). Hráči ich objavujú, píšu o nich a zdieľajú ich. | ★★★ zásadné | stredná | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| I3 | Reťazové reakcie živlov | Horiaci nepriateľ uteká a podpaľuje ostatných, blesk preskakuje medzi nepriateľmi. Najvďačnejší záber na video v hordovej hre. | ★★★ zásadné | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| I4 | Dočasné zviera alebo vozidlo | Jazda na zubrovi/medveďovi alebo na vojnovom voze 15 s. V Metal Slugu sú vozidlá ikonou série. Klip na TikTok sám od seba. | ★★★ zásadné | vysoká | [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug) |
| I5 | Vtipné premeny hrdinu | Metal Slug má premenu na tučného alebo mumiu. U vás napr. medvedia sila 10 s alebo „medovina“ (kľukatý pohyb, silnejšie údery). | ★★ veľký rozdiel | stredná | [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug) |
| I6 | Zbraň viditeľne rastie s úrovňou | Sekera na vyššej úrovni je väčšia, horí, nechá stopu. Vylepšenie vidno, nie len v čísle. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| I7 | Schopnosť nabíjaná zabíjaním | Silná schopnosť (váš Hnev) sa nabíja zabíjaním, hráč ju spustí sám v pravej chvíli. Odmeňuje agresívnu hru. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| I8 | Prehodiť / vyradiť ponuku | Pri výbere vylepšení možnosť raz prehodiť ponuku alebo vyradiť vylepšenie navždy z behu. Hráč má kontrolu nad náhodou. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## J. Beh a level

_Štruktúra jedného behu, napätie, koniec behu._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| J1 | Krátky beh s jasným koncom | 3–8 minút. Medián dĺžky mobilnej session je 5–6 min, najlepších 25 % hier 8–9 min. Súvisí s vaším otvoreným T09 (čo ukončí beh). | ★★★ zásadné | stredná | [GameAnalytics benchmarky (cez GameDev Reports)](https://gamedevreports.substack.com/p/gameanalytics-mobile-gaming-benchmarks) |
| J2 | Nič nie je stratený beh | Aj pri smrti si hráč odnesie aspoň niečo (menu, pokrok k odomknutiu). Vampire Survivors: aj krátky beh dá trvalý pokrok, preto hráč hneď skúša znova. | ★★★ zásadné | nízka | [The Conversation – Vampire Survivors a psychológia hazardu](https://theconversation.com/vampire-survivors-how-developers-used-gambling-psychology-to-create-a-bafta-winning-game-203613) |
| J3 | „Takmer“ obrazovka | Na konci behu: „Ešte 37 zajatcov do ohnivej sekery“, pás pokroku takmer plný. Pocit „skoro“ je najsilnejší dôvod na ďalší beh. | ★★★ zásadné | nízka | [The Conversation – Vampire Survivors a psychológia hazardu](https://theconversation.com/vampire-survivors-how-developers-used-gambling-psychology-to-create-a-bafta-winning-game-203613) |
| J4 | Séria zabití s násobičom | Rýchle zabíjanie zvyšuje násobič skóre a meny (x2, x3…); keď prestaneš, padá. Devil May Cry tým odmeňuje štýlové a agresívne hranie. | ★★★ zásadné | nízka | [Giant Bomb – Style Meter (násobič za štýlové hranie)](https://giantbomb.com/wiki/Concepts/Style_Meter) |
| J5 | Výsledková obrazovka s počítaním | Známka S/A/B/C a rozpis (zabití, zachránení, najdlhšia séria, čas), čísla bežia nahor so zvukmi. Balatro je postavené na čísle, ktoré rastie. | ★★★ zásadné | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| J6 | Tlačidlo „Ešte raz“ | Z výsledkov jedným ťuknutím rovno do nového behu, bez načítavania a menu. | ★★★ zásadné | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| J7 | Náhodné udalosti počas behu | Obchodník, oltár (obetuj srdce za silu), zranený zajatec. Archero strieda zručnosť a šťastie (anjel/diabol pred bossom). | ★★ veľký rozdiel | stredná | [Deconstructor of Fun – prečo Archero zarobilo](https://www.deconstructoroffun.com/blog/2019/8/9/why-archero-banked-25m-but-leaves-25m-hanging-hlx9n) |
| J8 | Ťažšia cesta = viditeľne lepšia odmena | Pri vetvení (už rozhodnuté) ukázať pred výberom, čo na ťažšej ceste čaká. Riziko a odmena musia byť zreteľné. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| J9 | Oživenie raz za beh | Hráč so silným buildom nechce prísť o beh. Jedno oživenie (zadarmo, za predmet, alebo v F2P za reklamu). V Archere je to najsilnejší bod predaja. | ★★ veľký rozdiel | nízka | [Deconstructor of Fun – prečo Archero zarobilo](https://www.deconstructoroffun.com/blog/2019/8/9/why-archero-banked-25m-but-leaves-25m-hanging-hlx9n) |
| J10 | Tajomstvá v leveli | Skrytý zajatec za stenou, truhla v kope sena, zničiteľný objekt s odmenou. Metal Slug skrýva predmety aj zajatcov v pozadí. | ★★ veľký rozdiel | stredná | [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug) |

## K. Meta-progresia (medzi behmi)

_Dôvod hrať ďalší beh a ďalší deň._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| K1 | Strom vylepšení so silnými skokmi | Prvé vylepšenia musia byť citeľne silné; neskôr skôr nové možnosti než +5 %. Ale nikdy tak silné, aby beh vyhral sám. | ★★★ zásadné | stredná | [Bugnet – návrh meta-progresie v roguelite](https://bugnet.io/blog/how-to-design-a-roguelite-meta-progression) |
| K2 | Achievementy cez Google Play Games | Google ich od 2025 ukazuje priamo v obchode a vie ich odmeňovať Play Points. Odporúča aspoň 15, najlepšie 40+; najlepšie fungujú hry, kde hráč získa 5 achievementov za prvé 2 hodiny. | ★★★ zásadné | stredná | [Android Developers Blog – Play Games Services, achievementy, Play Points (2025)](https://android-developers.googleblog.com/2025/06/get-ready-for-next-generation-gameplay-play-games-services.html) |
| K3 | Úlohy, ktoré odomykajú obsah | „Zabi 50 nepriateľov ohňom“ → odomkne novú zbraň. Vampire Survivors tak vedie hráčov vyskúšať všetko a vytvára pocit hojnosti. | ★★ veľký rozdiel | stredná | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| K4 | Kódex / bestiár | Zbierka nepriateľov, zbraní a historických faktov, odomyká sa hraním. (Kódex je v pláne; spojiť ho so zbieraním = motivácia.) | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| K5 | Ďalšie postavy z oslobodených | V Broforce záchrana zajatcov odomyká nové postavy s inou zbraňou. Lacná verzia: rovnaká kostra, iná zbraň a vzhľad. | ★★ veľký rozdiel | vysoká | [Wikipedia – Broforce (záchrana zajatcov = nová postava)](https://en.wikipedia.org/wiki/Broforce) |
| K6 | Vyššie obtiažnosti po dohraní | „Žatva II, III…“: silnejší nepriatelia, lepšie odmeny. Survivor.io má tzv. Trials, Hades tzv. Heat. Obsah sa spotrebuje znova. | ★★ veľký rozdiel | stredná | [Naavik – Survivor.io v stopách Archera](https://naavik.co/deep-dives/survivorio-archeros-footsteps/) |
| K7 | Kozmetika odomykaná hraním | Vzhľad sekery, farba plášťa, efekt hodu. Cieľ pre hráčov, ktorým už nechýba sila. | ★ drobnosť | stredná | Všeobecne známa herná prax (bez jedného zdroja) |

## L. Dopamínová slučka a odmeny

_Rytmus odmien, ktorý drží hráča pri hre._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| L1 | Truhla s napínavým otváraním | Pomalé otvorenie, svetlo, rastúci zvuk, náhodne 1–5 predmetov. Vampire Survivors požičal techniky z výherných automatov; prvé truhly sú nastavené štedro. Bez platenia skutočnými peniazmi = bez rizika regulácie lootboxov. | ★★★ zásadné | stredná | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| L2 | Odmena každých 20–30 sekúnd | Vo Vampire Survivors príde nejaké vylepšenie asi každých 23 s. Pravidlo pre balans vašich levelov. | ★★★ zásadné | nízka | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| L3 | Vrstvy odmien | V behu (vylepšenia), po behu (mena), dlhodobo (odomknutia, achievementy). Vždy je niečo blízko. | ★★★ zásadné | nízka | [The Conversation – Vampire Survivors a psychológia hazardu](https://theconversation.com/vampire-survivors-how-developers-used-gambling-psychology-to-create-a-bafta-winning-game-203613) |
| L4 | Prvý beh nastavený na úspech | Prvá klietka ľahká, prvá truhla štedrá, silný moment v prvej minúte. VS má prvé truhly napevno lepšie. | ★★★ zásadné | stredná | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| L5 | Farby vzácnosti | Biela / modrá / fialová / zlatá + svetelný lúč nad vzácnym predmetom. Hráč z diaľky vidí, že padlo niečo dobré. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| L6 | Čísla, ktoré bežia nahor | Skóre, mena a zabití sa nepripočítajú naraz, ale „nabehnú“ so zvukom. Malý, ale silný pocit. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## M. Dlhodobé udržanie hráča

_Návrat o deň, o týždeň, o mesiac._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| M1 | Denná výzva s rovnakým behom pre všetkých | Každý deň iné nastavenie, pre všetkých rovnaké. Neskôr rebríček. (Je v pláne – potvrdené.) | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| M2 | Týždenné pravidlá navyše | „Tento týždeň všetci nepriatelia horia“, „dvojnásobná rýchlosť“. Nový pocit bez nového obsahu. | ★★ veľký rozdiel | stredná | [Deconstructor of Fun – prečo Archero zarobilo](https://www.deconstructoroffun.com/blog/2019/8/9/why-archero-banked-25m-but-leaves-25m-hanging-hlx9n) |
| M3 | Etická séria dní | Odmena za návrat, ale bez trestu za vynechaný deň (zamrazenie série, „47 z 50 dní“). Bez platenia za obnovu série. | ★ drobnosť | nízka | [UX Magazine – psychológia sérií (etické série)](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design) |
| M4 | Upozornenia striedmo | Najviac 1 za deň a len s dôvodom (nová denná výzva). Inak hráč hru vypne alebo zmaže. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| M5 | Osobný rekord a „duch“ v Jame | V aréne Jama ukázať osobný rekord a priesvitného „ducha“ najlepšieho behu. | ★ drobnosť | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| M6 | Merať, či hráči ostávajú | Od uzavretého testu sledovať: koľko % sa vráti na druhý deň (top 25 % hier ~27 %) a 7. deň (medián ~3,5–4 %, top 25 % 7–8 %). Bez čísel sa nedá zlepšovať. | ★★ veľký rozdiel | nízka | [GameAnalytics benchmarky (cez GameDev Reports)](https://gamedevreports.substack.com/p/gameanalytics-mobile-gaming-benchmarks) |

## N. Prvé minúty hry

_Rozhodujú, či hráč hru nezmaže._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| N1 | Akcia do 10 sekúnd | Žiadne menu pri prvom spustení: hrdina pretrhne reťaze a hneď bojuje. Tutoriál je samotná prvá minúta. | ★★★ zásadné | nízka | [Supersonic – optimalizácia prvých minút (FTUE)](https://supersonic.com/learn/blog/optimizing-ftue/) |
| N2 | Jedna mechanika naraz | Supersonic: rýchle striedanie mechaník spôsobilo 60 % odchod už v tutoriáli. Najprv pohyb, potom hod, potom klietka. | ★★★ zásadné | nízka | [Supersonic – optimalizácia prvých minút (FTUE)](https://supersonic.com/learn/blog/optimizing-ftue/) |
| N3 | Jasný cieľ v prvej minúte | Žiadna minúta voľného hrania bez cieľa – to podľa Supersonicu spôsobovalo zmätok a odchod. | ★★★ zásadné | nízka | [Supersonic – optimalizácia prvých minút (FTUE)](https://supersonic.com/learn/blog/optimizing-ftue/) |
| N4 | Prvá klietka: všetci prežijú | Hráč pochopí odmenu (zachránení = mena) na úspechu, nie na neúspechu. | ★★★ zásadné | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| N5 | Ochutnávka plnej sily | Prvých 30 s s plne vylepšeným hrdinom (ohnivá sekera, zviera), potom stratí všetko. Hráč vie, za čím ide. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| N6 | Nápoveda vždy v pauze | Ovládanie a ciele kedykoľvek v menu pauzy. | ★ drobnosť | nízka | [GameAnalytics – prístupnosť v hrách](https://www.gameanalytics.com/blog/access-all-areas-how-to-make-your-game-more-accessible) |

## O. Ovládanie a obrazovka (HUD)

_Mobilné ovládanie a čistá obrazovka._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| O1 | Nastaviteľné ovládanie | Posunúť a zväčšiť ovládacie zóny/tlačidlá. Dead Cells to umožňuje pre každé tlačidlo. | ★★ veľký rozdiel | stredná | [TouchArcade – Dead Cells mobilné ovládanie (Auto-Hit, nastaviteľné tlačidlá)](https://toucharcade.com/2019/05/07/dead-cells-mobile-blog-post/) |
| O2 | Voliteľný ľahší režim útoku | Dead Cells má na mobile Auto-Hit (automatický útok na blízko), Archero automatické mierenie. Vaše ovládanie má auto-strelbu pri mierení; zvážiť režim aj bez mierenia pre príležitostných hráčov. | ★★ veľký rozdiel | stredná | [TouchArcade – Dead Cells mobilné ovládanie (Auto-Hit, nastaviteľné tlačidlá)](https://toucharcade.com/2019/05/07/dead-cells-mobile-blog-post/) |
| O3 | Podpora ovládača | Hráči Metal Slug štýlu radi hrajú s ovládačom; pre Steam je to nutnosť. | ★★ veľký rozdiel | stredná | [TouchArcade – Dead Cells mobilné ovládanie (Auto-Hit, nastaviteľné tlačidlá)](https://toucharcade.com/2019/05/07/dead-cells-mobile-blog-post/) |
| O4 | Čistá obrazovka | Minimum prvkov, nič pod palcami, dôležité pri okrajoch. Čistý obraz robí lepšie videá (Schedule I). | ★★ veľký rozdiel | nízka | [Influencer Marketing Hub – ako sa Schedule I stala virálnou](https://influencermarketinghub.com/how-schedule-i-became-a-viral-content-machine/) |
| O5 | Okamžitá pauza pri prerušení | Hovor, notifikácia, prepnutie aplikácie = hra sa zastaví a počká. Strata behu kvôli hovoru = zlá recenzia. | ★★★ zásadné | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| O6 | Šípky na nepriateľov mimo obrazovky | Na okraji obrazovky ukazovateľ, odkiaľ ide nepriateľ alebo kde je unášaný zajatec. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## P. Prístupnosť a nastavenia

_Rozširujú publikum a zlepšujú recenzie._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| P1 | Vypínače efektov | Otrasy, záblesky, vibrácie, čísla poškodenia – každé zvlášť. Záblesky môžu vyvolať migrénu alebo záchvat. | ★★ veľký rozdiel | nízka | [GameAnalytics – prístupnosť v hrách](https://www.gameanalytics.com/blog/access-all-areas-how-to-make-your-game-more-accessible) |
| P2 | Nespoliehať sa len na farbu | Typ nepriateľa či vzácnosť ukázať aj tvarom/ikonou; otestovať simulátorom farbosleposti. | ★ drobnosť | nízka | [GameAnalytics – prístupnosť v hrách](https://www.gameanalytics.com/blog/access-all-areas-how-to-make-your-game-more-accessible) |
| P3 | Ľahší režim | Pomalšia hra, viac sŕdc. Rozširuje publikum a zlepšuje recenzie (recenzie sú pre indie hru hlavný motor). | ★★ veľký rozdiel | stredná | [GameAnalytics – prístupnosť v hrách](https://www.gameanalytics.com/blog/access-all-areas-how-to-make-your-game-more-accessible) |
| P4 | Titulky hlášok | Hlášky hrdinu a nepriateľov aj ako text (mnoho ľudí hrá bez zvuku). | ★ drobnosť | nízka | [GameAnalytics – prístupnosť v hrách](https://www.gameanalytics.com/blog/access-all-areas-how-to-make-your-game-more-accessible) |

## Q. Príbeh, humor, svet

_Identita hry, ktorú si ľudia zapamätajú._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| Q1 | Príbeh po kúskoch po každom behu | Po každom behu krátka hláška alebo scéna v tábore. V Hades sa príbeh posúva práve smrťou, preto smrť neštve. Vstup pre vašu prerábku príbehu (T04). | ★★ veľký rozdiel | stredná | [Hades – smrť ako posun príbehu](https://criticalvideogamestudies.com/hades-death-and-the-players-experience/) |
| Q2 | Postavy v tábore s osobnosťou | Kováč, bylinkárka, starec-rozprávač reagujú na úspechy hráča. Lacné (text + portrét), veľa srdca. | ★★ veľký rozdiel | stredná | [Hades – smrť ako posun príbehu](https://criticalvideogamestudies.com/hades-death-and-the-players-experience/) |
| Q3 | Slovanská mytológia ako fantasy vrstva | Perúnove blesky, Veles, Baba Jaga ako obchodníčka, domovoj ako pomocník. Jedinečná identita a nulové riziko voči pravidlám (mytológia, nie etnikum). | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| Q4 | Ľudoví hrdinovia ako odomykateľné skiny | Napr. valaška a klobúk v štýle Jánošíka. Lokálny hák pre SK/CZ/PL publikum a médiá. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| Q5 | Vtipné opisy predmetov | Krátke, vtipné texty pri zbraniach a vylepšeniach. Humor sa šíri. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## R. Virálnosť a zdieľanie

_Čo v hre robí z hráčov propagátorov._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| R1 | Test klipu pri každom nápade | Pri každej novej veci sa opýtať: vznikne z toho 15-sekundové video? Princíp hier stavaných pre streamerov. | ★★★ zásadné | nízka | [Streamer-bait design – princípy](https://playbooks.com/skills/omer-metin/skills-for-antigravity/streamer-bait-design) |
| R2 | Masa nepriateľov na jednom zábere | Desiatky nepriateľov, ktoré padnú naraz (reťazová reakcia, výbuch). Hordové hry sa šíria práve týmto obrazom. | ★★★ zásadné | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| R3 | Jeden screenshot vysvetlí hru | Ako Vampire Survivors: jeden obrázok ukáže, o čo ide (hrdina, dav, klietka, čísla). | ★★★ zásadné | stredná | [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors) |
| R4 | Zdieľateľná karta výsledku | Po behu obrázok s číslami, buildom a logom, zdieľanie jedným ťuknutím. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| R5 | Vtipné zlyhania | Nepriateľ sa pošmykne na vlastnom sude, reťazová reakcia zabije aj hrdinu. Vtipné, napraviteľné zlyhania sa zdieľajú (Schedule I, streamer-bait). | ★★ veľký rozdiel | stredná | [Influencer Marketing Hub – ako sa Schedule I stala virálnou](https://influencermarketinghub.com/how-schedule-i-became-a-viral-content-machine/) |
| R6 | Záznam posledných sekúnd | Tlačidlo, ktoré uloží posledných 10–15 s ako video/GIF. Technicky náročnejšie; lacnejšia náhrada je karta výsledku. | ★ drobnosť | vysoká | Všeobecne známa herná prax (bez jedného zdroja) |

## S. Marketing

_Ako hru dostať k ľuďom (premium hra sa sama nepredá)._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| S1 | Krátke videá 2–3× týždenne | 15–30 s, hák v prvej polsekunde, video v slučke, séria „Deň X“, pred/po. Asi 1–2 h týždenne. Väčšina organických TikTokov má pod 1 000 videní – rozhoduje vytrvalosť. | ★★★ zásadné | nízka | [presskit.gg – TikTok marketing pre indie hry](https://presskit.gg/field-guides/tiktok-indie-game-marketing) |
| S2 | Príbeh tvorcu ako hák | „Sólo tvorca, nula skúseností, hru robí s AI“ je sám osebe zaujímavý príbeh pre Reddit (r/gamedev, r/IndieDev). Schedule I odštartoval úprimný post na Reddite. | ★★★ zásadné | nízka | [Influencer Marketing Hub – ako sa Schedule I stala virálnou](https://influencermarketinghub.com/how-schedule-i-became-a-viral-content-machine/) |
| S3 | Malí tvorcovia namiesto veľkých | Survivor.io: videá od malých tvorcov, ktoré vyzerali ako bežný obsah, nie reklama; ukazovali snahu a tipy, nie falošnú hru. | ★★ veľký rozdiel | nízka | [CreatorDB – Survivor.io a TikTok marketing](https://www.creatordb.app/blog/case-study/lessons-from-survivor-io-tiktok-marketing/) |
| S4 | Platené zosilnenie len víťazných videí | Spark Ads za 50–100 $ len pre video, ktoré už má ~50 000 organických videní. Inak sa platená reklama indie hre nevráti. | ★ drobnosť | nízka | [presskit.gg – TikTok marketing pre indie hry](https://presskit.gg/field-guides/tiktok-indie-game-marketing) |
| S5 | Steam stránka a demo včas | Pixel-art hry vo vrchu Steam Next Fest boli najmä stratégie a hry typu Vampire Survivors. Do top 25 treba ~70 000 wishlistov pred festivalom; po dohraní dema výzva na wishlist. | ★★ veľký rozdiel | stredná | [How To Market A Game – Steam Next Fest feb 2025](https://howtomarketagame.com/2025/03/04/steam-next-fest-feb-2025/) |
| S6 | Spolupráca s inou indie hrou | Dve podobné hry ohlásili spoločný balík počas Next Festu – príklad lacnej spolupráce. | ★ drobnosť | nízka | [How To Market A Game – Steam Next Fest feb 2025](https://howtomarketagame.com/2025/03/04/steam-next-fest-feb-2025/) |

## Z. Monetizácia – možnosti na rozhodnutie (T10)

_Všetky modely s plusmi a mínusmi. Rozhodnutie je tvoje._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| Z1 | Možnosť 1: Premium 5,99 € (súčasný plán) | + Žiadne reklamy ani tlak, férové, jednoduché na výrobu. − Premium hry sú len 4 % mobilných stiahnutí (2025); medián premium hry na mobile zarobil ~30 000 $ (dáta 2022); dobre sa predávajú hlavne hry úspešné najprv na PC (Slay the Spire 13,7 M$, Dead Cells 6,5 M$ na mobile). Počet premium vydaní v 2025 vzrástol o 77 %. | ★★★ zásadné | nízka | [Pocket Tactics – premium mobilné hry rastú (2025)](https://www.pockettactics.com/premium-mobile-games-increase) |
| Z2 | Doplnok k možnosti 1: Google Play Game Trials | Od marca 2026 môžu vybrané platené hry mať tlačidlo „Try“ – hráč skúsi hru zadarmo (príklad Dredge: 60 minút), potom kúpi alebo odinštaluje. Znižuje bariéru kúpy naslepo. | ★★★ zásadné | nízka | [Storyboard18 – Google Play Game Trials (marec 2026)](https://www.storyboard18.com/gaming-news/google-play-rolls-out-game-trials-to-let-users-test-paid-games-before-purchase-91960.htm) |
| Z3 | Možnosť 2: Zadarmo + jednorazové odomknutie | Prvé levely zadarmo, zvyšok jedným nákupom. + Nízka bariéra, žiadne reklamy. − Konverzia na nákup je nízka (overené číslo som nenašiel); obchod hru vníma ako F2P. | ★★ veľký rozdiel | nízka | Všeobecne známa herná prax (bez jedného zdroja) |
| Z4 | Možnosť 3: Zadarmo s voliteľnými reklamami | Model Vampire Survivors na mobile: reklama len keď hráč chce (druhý život, viac zlata na konci). 1 mil. stiahnutí za prvý týždeň, 3 mil. za ~6 týždňov bez marketingu. + Najlepšie šírenie. − Nízky príjem na hráča. | ★★ veľký rozdiel | nízka | [MobileGamer – Vampire Survivors mobile 3 mil. stiahnutí](https://mobilegamer.biz/vampire-survivors-mobile-hits-3m-downloads/) |
| Z5 | Možnosť 4: F2P s nákupmi (model Archero / Survivor.io) | Výbava, truhly, battle pass, ponuky po kapitole. Survivor.io: 15 M$ za prvý mesiac, 75 M$ za dva mesiace. − Za tým je veľký tím, marketing a stály nový obsah; pre sólo tvorcu ťažké, horšie recenzie, regulácia lootboxov. | ★★ veľký rozdiel | vysoká | [Naavik – Survivor.io v stopách Archera](https://naavik.co/deep-dives/survivorio-archeros-footsteps/) |
| Z6 | Možnosť 5: Hybrid | Zadarmo s voliteľnými reklamami + jednorazový nákup „bez reklám + bonus“ + platené DLC éry. Kompromis medzi šírením a príjmom. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| Z7 | Možnosť 6: Predplatné služby | Google Play Pass / Apple Arcade – príjem podľa hrania. Funguje ako doplnok k premium modelu. | ★ drobnosť | nízka | [Jules Baculard – sú premium hry na mobile mŕtve? (dáta 2022)](https://julesbaculard.substack.com/p/are-premium-games-on-mobile-dead) |
| Z8 | Možnosť 7: Steam ako hlavný premium trh | Premium model funguje na PC rádovo lepšie; Godot export je lacný. Úspech na PC potom ťahá mobil. | ★★ veľký rozdiel | stredná | [Pocket Tactics – premium mobilné hry rastú (2025)](https://www.pockettactics.com/premium-mobile-games-increase) |

## U. Technika a kvalita

_Bez tohto Google hru stiahne z očí._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| U1 | Stabilita pod prahmi Google | Pády pod 1,09 % a zamrznutia (ANR) pod 0,47 % (priemer za 28 dní). Inak Google zníži viditeľnosť hry a ukáže varovanie v obchode. | ★★★ zásadné | nízka | [Android vitals – prahy zlého správania](https://developer.android.com/games/optimize/vitals) |
| U2 | 60 fps na lacnom telefóne pri 30+ nepriateľoch | Už je to váš cieľ – výskum potvrdzuje: plynulosť je základ pocitu z hry. | ★★★ zásadné | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| U3 | Hra funguje offline | Vampire Survivors mobile je celý offline. Hranie v metre/lietadle = viac sessions. | ★★ veľký rozdiel | nízka | [MobileGamer – Vampire Survivors mobile 3 mil. stiahnutí](https://mobilegamer.biz/vampire-survivors-mobile-hits-3m-downloads/) |
| U4 | Postup cez Play Games Services | Prihlásenie a prenos postupu medzi zariadeniami. Pozor: od mája 2026 sa dá publikovať len s verziou v2. | ★★ veľký rozdiel | stredná | [Android Developers Blog – Play Games Services, achievementy, Play Points (2025)](https://android-developers.googleblog.com/2025/06/get-ready-for-next-generation-gameplay-play-games-services.html) |
| U5 | Analytika správania | Kde hráči končia, ktorá klietka je priťažká, koľko trvá beh. Firebase/GameAnalytics majú bezplatnú úroveň. | ★★ veľký rozdiel | stredná | [GameAnalytics benchmarky (cez GameDev Reports)](https://gamedevreports.substack.com/p/gameanalytics-mobile-gaming-benchmarks) |
| U6 | Rýchly štart a malá aplikácia | Pár sekúnd od ikony k akcii, malá inštalácia. Každá sekunda čakania stráca hráčov. | ★★ veľký rozdiel | stredná | Všeobecne známa herná prax (bez jedného zdroja) |
| U7 | Šetrenie batérie | V menu a na pauze nižšia snímková frekvencia. | ★ drobnosť | nízka | Všeobecne známa herná prax (bez jedného zdroja) |

## V. Stránka v Google Play

_Premena návštevy obchodu na stiahnutie._

| ID | Nápad | O čo ide | Dôležitosť | Námaha | Zdroj |
|---|---|---|---|---|---|
| V1 | Ikona čitateľná v malom | Jednoduchý, výrazný motív. Ikona je prvá vec na otestovanie (A/B test v Play Console je zadarmo, bez nového buildu). | ★★ veľký rozdiel | nízka | [Sonar – čo testovať na Play Store stránke](https://trysonar.app/blog/play-store-listing-experiments-what-to-test.md) |
| V2 | Prvé screenshoty s akciou a krátkym textom | 3–5 slov na screenshote, akcia, nie menu. Prvé 2–3 obrázky vidí najviac ľudí. | ★★ veľký rozdiel | nízka | [Sonar – čo testovať na Play Store stránke](https://trysonar.app/blog/play-store-listing-experiments-what-to-test.md) |
| V3 | Video začína najväčšou akciou | Prvé sekundy = najväčší chaos na obrazovke, nie logo. | ★★ veľký rozdiel | nízka | [presskit.gg – TikTok marketing pre indie hry](https://presskit.gg/field-guides/tiktok-indie-game-marketing) |
| V4 | Testovať aspoň týždeň | A/B test na Play Store minimálne týždeň (pracovné dni aj víkend); pri malej návštevnosti 3–4 týždne. | ★ drobnosť | nízka | [Sonar – čo testovať na Play Store stránke](https://trysonar.app/blog/play-store-listing-experiments-what-to-test.md) |

## Zdroje

- [Jan Willem Nijman (Vlambeer, Nuclear Throne) – čo sa deje pri jednom výstrele](https://infovore.org/?p=5275)
- [Mega Cat Studios – Juice Guide (shooter / run'n'gun)](https://megacatstudios.com/blogs/game-development/mega-cat-developer-juice-guide-v1-0-08-23-17)
- [Game feel primer: hit stop, flash, shake, sound](https://uhiyama-lab.com/en/notes/unity/unity-game-feel-hit-feedback/)
- [Princípy animácie v pixel arte (časovanie, anticipácia, smear)](https://www.sprite-ai.art/guides/animation-principles)
- [The Secret Sauce of Vampire Survivors](https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors)
- [The Conversation – Vampire Survivors a psychológia hazardu](https://theconversation.com/vampire-survivors-how-developers-used-gambling-psychology-to-create-a-bafta-winning-game-203613)
- [MobileGamer – Vampire Survivors mobile 3 mil. stiahnutí](https://mobilegamer.biz/vampire-survivors-mobile-hits-3m-downloads/)
- [Kotaku – Vampire Survivors mobile, len voliteľné reklamy](https://kotaku.com/vampire-survivors-free-iphone-steam-mobile-smartphone-1849955308)
- [Deconstructor of Fun – prečo Archero zarobilo](https://www.deconstructoroffun.com/blog/2019/8/9/why-archero-banked-25m-but-leaves-25m-hanging-hlx9n)
- [Naavik – Survivor.io v stopách Archera](https://naavik.co/deep-dives/survivorio-archeros-footsteps/)
- [CreatorDB – Survivor.io a TikTok marketing](https://www.creatordb.app/blog/case-study/lessons-from-survivor-io-tiktok-marketing/)
- [Bugnet – návrh meta-progresie v roguelite](https://bugnet.io/blog/how-to-design-a-roguelite-meta-progression)
- [Bugnet – čitateľný dizajn nepriateľov](https://bugnet.io/blog/how-to-design-a-readable-enemy-design)
- [Wayline – návrh bossov (varovanie, fázy, slabiny)](https://www.wayline.io/blog/crafting-legendary-boss-battles)
- [TV Tropes – Metal Slug (zajatci, komickí vojaci, premeny, vozidlá)](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/MetalSlug)
- [Wikipedia – Broforce (záchrana zajatcov = nová postava)](https://en.wikipedia.org/wiki/Broforce)
- [Hades – smrť ako posun príbehu](https://criticalvideogamestudies.com/hades-death-and-the-players-experience/)
- [Wayline – vibrácie: menej je viac](https://www.wayline.io/blog/haptic-feedback-less-is-more)
- [Bugnet – adaptívna hudba pre začiatočníkov](https://bugnet.io/blog/adaptive-music-a-beginners-guide)
- [GameAnalytics – prístupnosť v hrách](https://www.gameanalytics.com/blog/access-all-areas-how-to-make-your-game-more-accessible)
- [TouchArcade – Dead Cells mobilné ovládanie (Auto-Hit, nastaviteľné tlačidlá)](https://toucharcade.com/2019/05/07/dead-cells-mobile-blog-post/)
- [Supersonic – optimalizácia prvých minút (FTUE)](https://supersonic.com/learn/blog/optimizing-ftue/)
- [GameAnalytics benchmarky (cez GameDev Reports)](https://gamedevreports.substack.com/p/gameanalytics-mobile-gaming-benchmarks)
- [UX Magazine – psychológia sérií (etické série)](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design)
- [Android Developers Blog – Play Games Services, achievementy, Play Points (2025)](https://android-developers.googleblog.com/2025/06/get-ready-for-next-generation-gameplay-play-games-services.html)
- [Android vitals – prahy zlého správania](https://developer.android.com/games/optimize/vitals)
- [Storyboard18 – Google Play Game Trials (marec 2026)](https://www.storyboard18.com/gaming-news/google-play-rolls-out-game-trials-to-let-users-test-paid-games-before-purchase-91960.htm)
- [Pocket Tactics – premium mobilné hry rastú (2025)](https://www.pockettactics.com/premium-mobile-games-increase)
- [Jules Baculard – sú premium hry na mobile mŕtve? (dáta 2022)](https://julesbaculard.substack.com/p/are-premium-games-on-mobile-dead)
- [presskit.gg – TikTok marketing pre indie hry](https://presskit.gg/field-guides/tiktok-indie-game-marketing)
- [Influencer Marketing Hub – ako sa Schedule I stala virálnou](https://influencermarketinghub.com/how-schedule-i-became-a-viral-content-machine/)
- [Streamer-bait design – princípy](https://playbooks.com/skills/omer-metin/skills-for-antigravity/streamer-bait-design)
- [How To Market A Game – Steam Next Fest feb 2025](https://howtomarketagame.com/2025/03/04/steam-next-fest-feb-2025/)
- [Sonar – čo testovať na Play Store stránke](https://trysonar.app/blog/play-store-listing-experiments-what-to-test.md)
- [Giant Bomb – Style Meter (násobič za štýlové hranie)](https://giantbomb.com/wiki/Concepts/Style_Meter)
- [AppGrowing – Last War, reklamy s rastúcou armádou](https://appgrowing.net/blog/en/how-last-war-uses-proxy-minigames-to-package-strategy-gameplay/)
- [Chasing Carrots (Halls of Torment, Godot) – rozhovor](https://www.w4games.com/blog/w4-games-news-1/interview-with-chasing-carrots-developer-of-halls-of-torment-120)
