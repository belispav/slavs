# Analýza mechaník: úspešné pixel-art akčné strieľačky

Stav k 12. 10. 2026. Pre hru: pixel-art horde shooter (hráč proti vlnám nepriateľov), najprv Android s dotykovým ovládaním, neskôr iOS a Steam. Jeden autor bez kapitálu, práca s AI. Satira na fiktívnych politikov, ktorí neplnia sľuby; žiadne odkazy na reálnych ľudí ani skupiny.

## Ako čítať tento dokument

- **Fakt** = overené v zdroji, kód zdroja v hranatej zátvorke, napr. [Z17]. Zoznam zdrojov s odkazmi je na konci.
- **Názor** = moje hodnotenie herného dizajnéra, nie je doložené zdrojom.
- Všetky skóre 1–5 v tabuľke sú môj odhad (názor). Náročnosť: 1 = ľahké, 5 = veľmi ťažké pre jedného človeka s AI. Ostatné: 5 = najlepšie.
- Tržby a stiahnutia hier 1–11 sú tvoje vstupné odhady (Raijin.gg k 11. 10. 2026, Google Play, mobilegamer.biz). Kde som našiel iné číslo, uvádzam ho.

**Pojmy (vysvetlené raz):**
- **Roguelite** – hra, kde každá hra začína odznova, s náhodnými vylepšeniami, ale niečo si hráč odnáša trvalo.
- **Meta-postup** – trvalé vylepšenia medzi hrami (za menu zarobenú v hre).
- **F2P** – hra zadarmo, zarába na nákupoch v hre alebo reklamách.
- **Retencia D1 / D7 / D30** – koľko percent hráčov sa vráti po 1 / 7 / 30 dňoch od stiahnutia.
- **Získavanie hráčov (UA)** – platená reklama, ktorou sa kupujú stiahnutia.
- **Wishlist** – „prianie“ na Steame; hráč dostane upozornenie pri vydaní alebo zľave.
- **Prológ / ukážka** – bezplatná krátka verzia hry.

## Hlavné zistenia (5 bodov)

1. **Žáner na mobile stojí na troch veciach:** automatická streľba + výber vylepšení pri leveli + trvalé vylepšenia medzi hrami. Majú ich všetky úspešné horde shootery v analýze (Vampire Survivors, Survivor.io, Magic Survival, 20 Minutes Till Dawn, Halls of Torment).
2. **Úspechy jedného autora alebo malého tímu** (Vampire Survivors, 20 Minutes Till Dawn, Magic Survival) predávali buď za veľmi nízku cenu (~3 $), alebo zadarmo s miernou monetizáciou (dobrovoľné reklamy, jednorazové vypnutie reklám). Žiadna z nich nepoužila energiu ani tvrdé balíčky.
3. **Tvrdá F2P ekonomika (Survivor.io) zarába najviac, ale stojí na obrovskom reklamnom rozpočte** – odhadom polovica ide na TikTok [Z02] – a dlhodobo drží len 4 % hráčov po 30 dňoch [Z01].
4. **Viralitu robili streameri a festivaly, nie sociálne siete autora.** 20 Minutes Till Dawn mal 720 sledovateľov na Twitteri; rozhodla bezplatná ukážka, festival na Steame a videá YouTuberov [Z17]. Vampire Survivors sa rozbehol po videu kanála Splattercat [Z11].
5. **Slabšie hry neprehrali na grafike, ale na drine a opakovaní:** pomalé odomykanie, prefarbené postavy, zbrane bez viditeľného efektu, neférová obťažnosť [Z40][Z42][Z43].

## 1. Profily hier

Poradie podľa tržieb. Pri každej hre 10 bodov zo zadania: (1) háčik, (2) hlavná slučka, (3) čo bolo nové, (4) postup a dôvod vracať sa, (5) vizuál a pocit, (6) dĺžka hry a vhodnosť pre mobil, (7) ovládanie, (8) monetizácia, (9) viralita, (10) recenzie.

### 1.1 Survivor.io (Habby) – vzor monetizácie na mobile
Tržby: 55 mil.+ stiahnutí, 170 mil. $+ za ~6 mesiacov (tvoj vstup). Po 3 rokoch stále ~5 mil. $ mesačne [Z05]. Nie je pixel art ani indie.
1. **Háčik:** fakt – rýchle učenie a rýchly nárast sily [Z01]. Názor: v prvých 30 s kosíš davy jedným palcom; do 5 minút máš 3–4 zbrane a prvého bossa.
2. **Slučka:** postava útočí sama, z nepriateľov padajú kryštály, level = výber schopnosti [Z06].
3. **Nové:** slučka z Vampire Survivors zabalená do osvedčeného systému Habby (výbava, hrdinovia, kapitoly, energia) z ich staršej hry Archero [Z06][Z03].
4. **Postup:** výbava, spájanie predmetov, vylepšovanie štatistík, kapitoly [Z05][Z03]. Fakt: po rýchlom začiatku príde stena v postupe, kde hra ponúkne lacné balíčky [Z01].
5. **Vizuál:** názor – čistý kreslený štýl, veľké čitateľné efekty.
6. **Dĺžka:** názor (z poznania hry) – kapitola ~15 minút. Veľmi vhodné pre mobil.
7. **Ovládanie:** jeden palec, telefón na výšku; ovládanie jednou rukou znižuje bariéru vstupu (slabší zdroj) [Z50].
8. **Monetizácia:** nákupy v hre, balíčky, energia na každú hru (doplnenie za drahokamy) [Z04]. Retencia D1 44 %, D7 15 %, D30 4 % [Z01].
9. **Viralita:** konzultant odhaduje, že ~50 % reklamného rozpočtu ide na TikTok a tam sa hra stala virálnou [Z02].
10. **Recenzie:** chvália návykovosť a začiatok; sťažujú sa na „plať a vyhrávaj“ a steny v postupe [Z50].

### 1.2 Soul Knight (ChillyRoom)
Stiahnutia: 100 mil.+ na Google Play (tvoj vstup).
1. **Háčik:** názor – hneď v prvej miestnosti strieľaš, zbrane padajú často, hra mieri za teba.
2. **Slučka:** náhodne poskladané podzemie → miestnosti s nepriateľmi → nové zbrane → boss → ďalšie poschodie [Z08].
3. **Nové:** fakt – automatické mierenie pre veľmi jednoduché ovládanie [Z08]. Názor: v roku 2017 jeden z mála plnohodnotných roguelike na mobile s dotykovým ovládaním, ktoré funguje.
4. **Postup:** 20+ postáv, 400+ zbraní, vylepšenia postáv za drahokamy [Z08][Z07].
5. **Vizuál:** pixel art s detailnými portrétmi v anime štýle [Z08].
6. **Dĺžka:** názor – jedno poschodie pár minút, celá hra ~15–25 minút. Vhodné pre mobil.
7. **Ovládanie:** virtuálny joystick + tlačidlá streľby a schopnosti, automatické mierenie, podpora ovládača [Z08].
8. **Monetizácia:** v roku 2017 bez vnútených reklám; reklama len dobrovoľne za drahokamy; 3 postavy po 1 $; trvalé oživenie za 2 $ [Z07]. Dnes navyše náhodné balíčky vzhľadov a sezónne odmeny; drahokamy 0,99–3,99 $ [Z08].
9. **Viralita:** názor – spoločná hra 2–4 hráčov [Z08] a dlhé roky pravidelných aktualizácií.
10. **Recenzie:** chvália férovosť bez „ždímania“ [Z07] a množstvo zbraní [Z08]; sťažnosť: časť úspechov vyžaduje platené postavy [Z08].

### 1.3 Vampire Survivors (poncle) – PC aj mobil
~6,5 mil. kópií, ~26 mil. $ (tvoj vstup). Mobil: 1 mil. stiahnutí za prvý týždeň bez platenej reklamy [Z15], 5,1 mil. za 3 mesiace [Z16].
1. **Háčik:** názor – prvých 30 s stačí chodiť; do 5 minút je obrazovka plná a padne prvá truhla.
2. **Slučka:** chodíš, zbierajú sa kryštály, vyberáš z náhodne ponúknutých vylepšení [Z10].
3. **Nové:** automatický útok, mimo mobilu vtedy neobvyklý; inšpirácia mobilnou hrou Magic Survival [Z09].
4. **Postup:** zlato na trvalé bonusy; obrovský zoznam úspechov dáva stále vedľajšie ciele [Z10].
5. **Vizuál:** jednoduchý pixel art, ktorý mnohí považovali za lacný [Z10]; efektné otváranie truhlíc pripomína lootboxy [Z09]. Autor predtým pracoval v hazardnom priemysle [Z12].
6. **Dĺžka:** ~30 minút (všeobecne známe); recenzenti ho volajú hrou na obedňajšiu prestávku [Z09]. Na mobile funguje, no 30 min je dlhých (názor).
7. **Ovládanie:** iba pohyb.
8. **Monetizácia:** PC 4,99 $ (pri vydaní 2,69 €) [Z10] + platené DLC [Z09]. Mobil: zadarmo, žiadne nákupy, len reklama po hre za životy alebo zlato, dá sa ignorovať [Z13]. Mobilnú verziu urobili sami, lebo partneri chceli „predátorskú“ monetizáciu, a ponáhľali sa kvôli klonom [Z14].
9. **Viralita:** predaj sa rozbehol po videu kanála Splattercat [Z11].
10. **Recenzie:** chvália návykovosť „ešte jedno kolo“ [Z12]; výhrady: vzhľad a jednoduchosť (názor + [Z10]).

### 1.4 20 Minutes Till Dawn (flanne, jeden autor) – PC aj mobil
~750 tis. kópií, ~3 mil. $ (tvoj vstup). Prvé 4 dni: 220 tis. kópií za 2,99 $, hrubo 538 tis. $ [Z17].
1. **Háčik:** názor – v 30 s strieľaš sám (nie automaticky), v 5 min máš „rozbitú“ kombináciu vylepšení.
2. **Slučka:** ako Vampire Survivors (kryštály → level → výber), ale ručné mierenie a prebíjanie [Z17].
3. **Nové:** aktívne mierenie a prebíjanie; autor chcel hĺbku pri krátkych hrách [Z17]. Anime štýl kvôli ázijskému publiku – podľa autora veľká časť úspechu [Z17].
4. **Postup:** trvalé vylepšenia naprieč hrami, odomykanie postáv a zbraní [Z51].
5. **Vizuál:** temný pixel art s hororovou témou (horor dobre funguje na itch.io) [Z17].
6. **Dĺžka:** 20 minút (ukážka 10 minút) [Z18]. Vhodné pre mobil.
7. **Ovládanie:** na PC myš; na mobile dva palce (názor).
8. **Monetizácia:** PC 2,99 $ bez zľavy pri vydaní [Z17]; mobil platená verzia + bezplatná verzia (tvoj vstup), mobilné práva prenechal vydavateľovi Erabit [Z18].
9. **Viralita:** ukážka na itch.io → spätná väzba na Reddite → festival Steamu → YouTuberi Wanderbots a Splattercat → bezplatný prológ v rebríčku „Nové a populárne“ → 143 tis. prianí pri vydaní [Z17]. Priemerný hráč ukážky hral 1 h 15 min [Z17]. Vývoj aj marketing trvali ~2 mesiace [Z17].
10. **Recenzie:** hráči chceli viac rôznych zostáv, nepriateľov a obťažnosti [Z17]; pri veľa nepriateľoch sa hra spomaľuje [Z51].

### 1.5 Hotline Miami (Dennaton, 2 ľudia) – len PC a konzoly
~5,3 mil. kópií, ~43 mil. $ (tvoj vstup); 1,5 mil. kópií do roku 2015 [Z22].
1. **Háčik:** názor – prvých 30 s: surová rýchlosť a hudba; 5 min: prvá zvládnutá úroveň po desiatkach smrtí.
2. **Slučka:** vyčistiť poschodie, zomrieť, okamžite reštartovať, skúsiť inak [Z19].
3. **Nové:** smrť na jeden zásah pre hráča aj nepriateľa; vždy vieš, čo sa stalo, a povieš si „bola to moja chyba“ [Z19].
4. **Postup:** masky s bonusmi (pridané až neskôr) [Z21]; hodnotenie úrovne (názor, z poznania hry).
5. **Vizuál a zvuk:** hudba bola podľa autorov najväčšou výzvou vývoja [Z20].
6. **Dĺžka:** úroveň pár minút. Na mobile nevyšla (názor: ovládanie myšou sa ťažko prenáša).
7. **Ovládanie:** myš + klávesnica, ručné mierenie.
8. **Monetizácia:** platená hra, vydavateľ Devolver Digital [Z22].
9. **Viralita:** názor – hudba a štýl sa šírili samy; videá rýchlych prechodov.
10. **Recenzie:** názor – chvália tempo a hudbu. Pokračovanie bolo pre mnohých príliš ťažké, autori v tom vidia dôvod slabšieho úspechu [Z21].

### 1.6 Broforce (Free Lives) – satira, len PC a konzoly
~2,3 mil. kópií, ~20 mil. $ (tvoj vstup).
1. **Háčik:** názor – v 30 s prvý výbuch, ktorý zborí pol úrovne.
2. **Slučka:** misia → zabi zloduchov → zachráň väzňov → boss → útek vrtuľníkom; akčný film premenený na mechaniku [Z23].
3. **Nové:** úplne zničiteľný terén – pridaný, lebo pôsobí drsne, taktika vznikla ako bonus [Z24]; záchrana väzňa dá život a náhodnú novú postavu [Z25].
4. **Postup:** viac zachránených väzňov = viac postáv [Z23].
5. **Vizuál:** chaos, výbuchy, rozpadajúci sa terén [Z23].
6. **Dĺžka:** úroveň pár minút (názor). Na mobile nevyšla.
7. **Ovládanie:** gamepad / klávesnica.
8. **Monetizácia:** platená hra, vydavateľ Devolver Digital [Z23].
9. **Viralita:** spoločná hra až 4 hráčov a paródia [Z23]. **Pozor:** Broforce paroduje skutočné filmové postavy (Rambo, Terminátor…) – to tvoje pravidlo zakazuje, preber len princíp paródie na archetypy.
10. **Recenzie:** chvália terén a postavy [Z26]; sťažnosť: náhodná výmena občas dá nevhodnú postavu [Z26].

### 1.7 Enter the Gungeon (Dodge Roll) – len PC a konzoly
~2,1 mil. kópií, ~19 mil. $ (tvoj vstup). Na zisku od prvého dňa predaja [Z30].
1. **Háčik:** názor – v 30 s prevrátiš stôl a uskočíš pred guľkami; v 5 min prvá bláznivá zbraň.
2. **Slučka:** poschodia s miestnosťami, zbrane, boss; každá hra iná [Z28].
3. **Nové:** úskok s nezraniteľnosťou podľa Dark Souls ako prvá mechanika po streľbe [Z27]; prevracanie stolov, sudy, lustre [Z27].
4. **Postup:** 200+ zbraní [Z29]; podzemie sa mení podľa splnených cieľov [Z28].
5. **Vizuál:** pixel art, množstvo narážok na iné hry a filmy – „možno najviac odkazujúca hra“ podľa autora [Z29].
6. **Dĺžka:** celá hra desiatky minút, bez ukladania medzi poschodiami [Z30]. Na mobile nevyšla.
7. **Ovládanie:** dve páčky (pohyb + mierenie), úskok.
8. **Monetizácia:** platená hra, vydavateľ Devolver.
9. **Viralita:** humor, slovné hračky so zbraňami [Z30].
10. **Recenzie:** chvália zbrane a humor; sťažnosť: vysoká obťažnosť bez kontrolných bodov [Z30].

### 1.8 Halls of Torment (Chasing Carrots)
~820 tis. kópií, ~4,4 mil. $ (tvoj vstup); 1 mil. hráčov ešte pred finálnou verziou [Z34].
1. **Háčik:** názor – okamžité rozpoznanie vzhľadu starého Diabla.
2. **Slučka:** survivor slučka (automatický útok voliteľný) + výbava v štýle Diablo [Z33].
3. **Nové:** spojenie dvoch publík; zadanie znelo „ak je Diablo trojchodové menu, toto je čokoládová tyčinka“; prototyp za pár dní [Z31]. Predpoklad, že sa publiká prekrývajú, sa potvrdil [Z32].
4. **Postup:** výbava v truhle v základni, talenty, ťažší režim [Z35].
5. **Vizuál:** verná napodobenina vzhľadu Diablo z 90. rokov [Z53].
6. **Dĺžka:** 30 minút [Z31]; mobilnú verziu som v zdrojoch nenašiel.
7. **Ovládanie:** pohyb + voliteľné ručné útočenie [Z33].
8. **Monetizácia:** platená hra okolo 5 $ [Z35].
9. **Viralita:** názor – nostalgia v snímkach obrazovky.
10. **Recenzie:** chvália atmosféru a že vždy sa dá poskladať funkčná zostava; výhrada: málo rozmanitá výbava [Z33]. Autori si myslia, že „zlatý vek“ žánru prevažne skončil [Z34].

### 1.9 Nuclear Throne (Vlambeer)
~400 tis. kópií, ~2,9 mil. $ (tvoj vstup); v predbežnom prístupe 100 tis.+ kópií a 1 mil. $ [Z39].
1. **Háčik:** fakt – každý výstrel má zvuk, spätný ráz kamery, trasenie a mikro-zastavenie pri zásahu [Z36].
2. **Slučka:** rýchle úrovne, zbrane, mutácie pri leveli (názor, z poznania hry).
3. **Nové:** „pocit“ zo streľby dovedený do extrému [Z36]; vývoj ako predstavenie naživo [Z37].
4. **Postup:** postavy (voľba postavy je zdroj znovuhrateľnosti) [Z52]; denné a týždenné výzvy [Z38].
5. **Vizuál:** šťavnatý pixel art, trasenie, výrazná hudba [Z39].
6. **Dĺžka:** krátke, rýchle hry (názor). Na mobile nevyšla.
7. **Ovládanie:** myš + klávesnica, ručné mierenie.
8. **Monetizácia:** platená hra; prvá hra predávaná aj cez predplatné na Twitchi [Z38].
9. **Viralita:** vývoj vysielaný naživo 2× týždenne a týždenné aktualizácie [Z38]; výslovne povolené zarábať na videách z hry [Z38]; komunita sama vytvorila wiki [Z37].
10. **Recenzie:** názor – chvália pocit zo streľby, kritizujú obťažnosť.

### 1.10 Army of Ruin (Milkstone Studios) – slabšia hra
~65 tis. kópií, ~420 tis. $ (tvoj vstup). **Iný odhad:** Vaporlens ~188 tis. kópií, ~1,5 mil. $ pri cene 8 $ [Z41] – odhady sa líšia ~3×, ber obe ako hrubé.
**Čo chýbalo oproti úspešným:**
- Zábava na začiatku, potom opakovanie a drina pri odomykaní [Z40].
- Vyvinuté zbrane nevyzerajú silno, plochý vizuál [Z40].
- Postavy sa líšia len farbou [Z42].
- Málo obsahu prekrytého 550+ výzvami [Z42].
- Hráči ju vnímajú ako neoriginálnu kópiu [Z40]. Názor: vyšla v júni 2023, keď bol trh už plný, a stála 8 $ oproti 3–5 $ u konkurencie.

### 1.11 Spirit Hunters: Infinite Horde (Creature Cauldron) – slabšia hra
~41 tis. kópií, ~260 tis. $ (tvoj vstup).
**Čo chýbalo oproti úspešným:**
- Nevyvážená, frustrujúca obťažnosť [Z43].
- Rozsiahly, ale nejasný strom vylepšení [Z43].
- Neuspokojivé vylepšenia a slabé vyváženie zbraní [Z43].
- Časti hráčov chýba „survivor“ pocit [Z43].
- V predbežnom prístupe bez väčšej pozornosti médií [Z45]. Pritom má peknú grafiku a vlastný nápad (boss v klietke) [Z44] – dôkaz, že grafika nestačí.

### 1.12 Navyše: Magic Survival (Leme) – mobilná hra zadarmo
Doplnená, lebo je to mobilný pôvodca žánru a vzor pre jedného autora. **6,4 mil. stiahnutí od februára 2020** (Appmagic cez mobilegamer.biz) [Z16]. Malé kórejské indie štúdio [Z16].
1. **Háčik:** hra nedá hráčovi pocit slabosti, rýchlo vrství kúzla [Z46].
2. **Slučka:** kúzla sa zosielajú automaticky podľa nabitia, hráč len chodí [Z46].
3. **Nové:** pôvodný vzor, ktorým sa inšpiroval Vampire Survivors [Z09][Z16].
4. **Postup:** 24 tried postáv, „výskum“ za body = trvalé bonusy [Z46].
5. **Vizuál:** jednoduchý tmavý pixel art (recenzia: na snímkach vyzerá skromne) [Z46].
6. **Dĺžka / mobil:** stavaná pre mobil.
7. **Ovládanie:** jeden palec, pohyb.
8. **Monetizácia:** zadarmo, reklama po smrti, jednorazové vypnutie reklám za 3,99 $ [Z46].
9. **Viralita:** rast stiahnutí vďaka popularite Vampire Survivors [Z16].
10. **Recenzie:** chvália kombinácie kúziel a hĺbku [Z46].

Ďalšie 2 miesta som nevyužil: silné mobilné hry, ktoré som našiel (Otherworld Legends, Archero), nie sú pixel-art strieľačky proti hordám alebo k nim nemám overené čísla.

## 2. Tabuľka mechaník a prvkov

Stĺpce: kód, názov, hry, kategória, čo to je, prečo funguje, Nár. = náročnosť (1 = ľahké, 5 = ťažké), Mob. = vhodnosť pre mobil, Sat. = väzba na satiru (+ nápad), Vpl. = odhadovaný vplyv na predaj/príjem, Pomer = Vpl. / Nár. Všetky skóre sú môj odhad.

{{TABLE}}

## 3. Top 10 mechaník na prevzatie

Zoradené podľa pomeru vplyv / náročnosť. Pri rovnosti rozhoduje vyšší vplyv, potom vhodnosť pre mobil, potom väzba na satiru.

{{TOP10}}

{{NEXT}}

## 4. Platená hra vs. zadarmo s nákupmi (mobil, jeden autor)

Nerozhodujem za teba. Nižšie sú oba modely, každý v dvoch variantoch, s príkladmi z analýzy.

**Čo vyplýva z analyzovaných hier (fakty):**
- Najvyšší príjem má tvrdý F2P model (Survivor.io, 170 mil. $+), ale za ním stojí veľký reklamný rozpočet (~50 % na TikTok) [Z02] a retencia D30 iba 4 % [Z01].
- Hry jedného autora / malých tímov, ktoré uspeli na mobile, mali mäkkú monetizáciu: Vampire Survivors (len dobrovoľné reklamy) [Z13], Magic Survival (reklamy + vypnutie za 3,99 $) [Z46], 20 Minutes Till Dawn (platená + bezplatná verzia).
- Na PC je cena žánru 3–5 $ (Vampire Survivors 4,99 $, 20 Minutes Till Dawn 2,99 $ [Z17], Halls of Torment ~5 $ [Z35]).

### Model A – Platená hra

| | A1: Jednorazová cena | A2: Zadarmo začiatok, plná hra za jednu platbu |
|---|---|---|
| **Čo to je** | Hráč zaplatí pred stiahnutím. | Stiahnutie zadarmo, po časti hry jedna platba odomkne všetko. Alebo dve verzie v obchode: bezplatná a platená. |
| **Príklady** | 20 Minutes Till Dawn (mobil, platená verzia); PC verzie všetkých hier 3–8. | 20 Minutes Till Dawn (bezplatný prológ na PC, bezplatná verzia na mobile) [Z17]; Loop Hero a Shapez na mobile fungovali, TMNT sklamal [Z47]; Beholder: platená + skúšobná verzia = 5× viac než samotná platená [Z48]. |
| **Plusy** | Najjednoduchšie na výrobu; žiadna ekonomika v hre; férové recenzie; Google Play od 2026 podporuje platené hry (skúška zadarmo, kúp raz – hraj na mobile aj PC) [Z49]. | Dosah ako hra zadarmo + férová jednorazová platba; žiadny tlak na hráča. |
| **Mínusy** | Podľa vydavateľa Playdigious potrebuje indie hra na mobile už predtým úspech a komunitu [Z47]; bez reklamného rozpočtu málo stiahnutí (názor). | Treba nájsť správne miesto, kde žiadať platbu; konverzia je neistá [Z47]. |
| **Čo musíš urobiť** | Nastaviť cenu, vydať. | Rozdeliť hru (napr. prvá kapitola zadarmo), jeden nákup v aplikácii. |

### Model B – Zadarmo s nákupmi / reklamami

| | B1: Mäkká (dobrovoľné reklamy + jednorazové vypnutie, drobné nákupy) | B2: Tvrdá F2P ekonomika (energia, balíčky, náhodné odmeny) |
|---|---|---|
| **Čo to je** | Hra je celá zadarmo; reklama len keď ju hráč chce (oživenie, zlato); voliteľne platba za vypnutie reklám, lacné postavy a vzhľady. | Energia na hranie, stena v postupe, balíčky, prípadne náhodné balíčky vzhľadov. |
| **Príklady** | Vampire Survivors mobil [Z13]; Magic Survival 3,99 $ [Z46]; Soul Knight (postavy 1 $, trvalé oživenie 2 $) [Z07]. | Survivor.io [Z01][Z04]; Soul Knight dnes čiastočne (náhodné balíčky vzhľadov) [Z08]. |
| **Plusy** | Najväčší dosah; dobré recenzie; jednoduchá implementácia (reklamná knižnica + 1–3 nákupy). Vampire Survivors: 1 mil. stiahnutí za týždeň bez platenej reklamy [Z15]. | Najvyšší strop príjmu (Survivor.io ~5 mil. $ mesačne aj po 3 rokoch [Z05]). |
| **Mínusy** | Príjem na hráča je nízky – potrebuješ veľa stiahnutí (názor); poncle nezverejnil, koľko reklamy zarábajú. | Vyžaduje veľký rozpočet na reklamu [Z02], neustále udalosti a vyvažovanie ekonomiky (názor: pre jedného autora nereálne); sťažnosti na „plať a vyhrávaj“ [Z50]; poncle odmietol partnerov práve kvôli tomuto [Z14]. |
| **Čo musíš urobiť** | Pridať reklamy s odmenou + 1 nákup „bez reklám“. | Navrhnúť ekonomiku, obchod, udalosti, analytiku; platiť reklamu. |

## 5. Čomu sa vyhnúť

1. **Drina pri odomykaní** – Army of Ruin: zábava sa mení na povinnosť [Z40].
2. **Klon bez vlastného nápadu, neskoro na trhu** – Army of Ruin vnímaný ako neoriginálny [Z40]; autori Halls of Torment si myslia, že zlatý vek žánru prevažne skončil [Z34]. Tvoja satira je odlíšenie – drž ju v každej mechanike.
3. **Prefarbené postavy** – kritizované v Army of Ruin [Z42].
4. **Silné veci, ktoré nevyzerajú silno** – vyvinuté zbrane v Army of Ruin [Z40].
5. **Nevyvážená obťažnosť a nejasný strom vylepšení** – Spirit Hunters [Z43]; Hotline Miami 2 príliš ťažké [Z21]; Enter the Gungeon bez kontrolných bodov [Z30].
6. **Agresívna monetizácia** – „plať a vyhrávaj“, steny v postupe (Survivor.io) [Z50].
7. **Spomalenie pri veľa nepriateľoch** – 20 Minutes Till Dawn [Z51]; na lacných Androidoch ešte horšie (názor). Testuj na najslabšom telefóne, ktorý chceš podporovať.
8. **Náhoda, ktorá berie kontrolu** – náhodná výmena postavy v Broforce [Z26].
9. **Mätúce názvy** – autor 20 Minutes Till Dawn priznal, že dvojica názvov 10/20 Minutes Till Dawn bola mätúca [Z17].
10. **Spoliehanie sa na vlastné sociálne siete** – 20 Minutes Till Dawn mal 720 sledovateľov; rozhodli festivaly, ukážka a streameri [Z17].
11. **Klony na mobile** – Vampire Survivors musel vydať mobilnú verziu narýchlo, lebo sa objavili presné kópie s ukradnutým kódom [Z14]. Názor: ak uspeješ na PC, mobil vydaj čo najskôr.
12. **Reálne osoby v satire** – Broforce paroduje skutočné filmové postavy [Z23]; tvoje pravidlo to zakazuje. Archetypy áno, mená a podoby reálnych ľudí nie.

## 6. Postup, ktorý fungoval jednému autorovi (20 Minutes Till Dawn)

Fakty z [Z17]: malá hra namiesto veľkej (vývoj ~2 mesiace) → ukážka na itch.io a spätná väzba na Reddite → úprava podľa hráčov → bezplatný prológ a festival na Steame → YouTuberi → vydanie za 2,99 $ bez zľavy. Autor mal marketingový plán ešte pred začiatkom vývoja.

## Zdroje

{{SOURCES}}
