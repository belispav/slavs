# VOLYA — jadro hry (revízia dizajnu, 31. 7. 2026)

Tento dokument nahrádza kapitolu 3.2 a 3.5 pôvodného plánu v tom, čo sa týka
**štruktúry hry a dôvodu opakovať levely**. Zvyšok `VOLYA_plan_hry.md` platí,
vrátane **kapitoly 2 (citlivá téma), ktorá je nemenná za každých okolností**.

Vznikol z rozhovoru po prvom hrateľnom prototype hôrd, keď bolo potvrdené, že
kosenie davov je zábavné aj so sivými boxami.

---

## 1. Čo sa zmenilo oproti pôvodnému plánu

Pôvodne: 12 ručne postavených levelov, prejdeš ich a máš.

Teraz: **run-based score attack s meta-progresiou.** Level je úsek, do ktorého
sa vraciaš. Hráš ho, dokedy vládzeš. Odmena sa počíta z výkonu, míňa sa na
vylepšenia, s vylepšeniami sa dostaneš ďalej.

Dôvody, prečo je to lepšia kostra pre tento projekt:

- Jeden úsek obsahu sa spotrebuje desiatky ráz namiesto raz. Pri jednom
  človeku a nulovom rozpočte na grafiku je to rozhodujúce.
- Sedí na krátke mobilné sessions.
- Rieši výhradu voči Metal Slugu: level dohráš a nikdy sa k nemu nevrátiš.

---

## 2. Dohodnuté jadro

### Beh levelom

Scrollujúci úsek, jednoduchý terén — rovina a debny ako plošiny. **Žiadne
komplikované plošinovkárske pasáže.** Pohyb vľavo–vpravo, skok cez prekážku.
Zložitejšie skákanie je kandidát na druhý diel, nie na v1.0.

Nepriatelia prichádzajú **výhradne sprava** (ľavý palec zakrýva ľavú tretinu
displeja — pozri CLAUDE.md, pilier 2).

### Klietky — hlavný mechanizmus, nahrádza pôvodný Hnev

Toto je srdce hry a najsilnejší nápad revízie.

1. Scroll sa zastaví, hráč je uzamknutý v scéne s klietkou.
2. Nepriatelia sa vrhnú **na klietku** a začnú zabíjať zajatcov.
3. Hráč musí pozabíjať nepriateľov skôr, než pobijú zajatcov.
4. Klietka sa otvorí, mena = **počet zajatcov, ktorí prežili**.

Prečo to funguje: **premieňa silu hráča priamo na menu.** Nie „zabil si 200
nepriateľov, tu máš body", ale „bol si o pätinu rýchlejší, tak prežili traja
namiesto jedného". Zlepšenie je okamžite viditeľné a vytvára tlak na ďalšie.

Zamietnuté: strieľanie do klietok kvôli menej (pôvodný plán) — odvádzalo by
pozornosť od nepriateľov a nevytváralo žiadny tlak.

### Rage / Hnev

**Nie je automatika a nie je „zniš všetko na obrazovke".** Stáva sa z neho
jedna z voliteľných schopností. Screen-clear ako základná mechanika bol
zamietnutý.

### Vetvenie a dvaja bossovia

Raz za level **výber z dvoch ciest** — ľahšia a ťažšia. Nahrádza pôvodný
nápad jedného bossa na konci.

- **Slabší boss:** zabiteľný zbraňami, ktoré hráč práve má, rádovo po 5–10
  opakovaniach levelu. Je to métа, ktorá sa dá dosiahnuť vytrvalosťou.
- **Silnejší boss:** má slabinu na konkrétny živel alebo schopnosť (oheň,
  elektrina), ktorú hráč získa až neskôr. Je to zámok, ktorý dáva
  dlhodobý cieľ a dôvod vrátiť sa do starého levelu s novou zbraňou.

Dôsledok, ktorý treba prijať: **zbrane musia mať živly.** Je to lacné a dáva
to zmysel aj pre absurdno-fantasy smerovanie.

### Zbrane a schopnosti

- Nové zbrane sa získavajú **v ďalších leveloch** — aby hráč chcel postupovať
  dopredu, nielen opakovať jeden úsek.
- Vylepšenia zbraní sa kupujú **za hernú menu** — aby musel opakovať.
- Do levelu si hráč vyberá **maximálne 3** zbrane/schopnosti pred štartom.
- Prepínanie počas hry: **poklepanie pravým palcom.**

### Levely s voľným pohybom

Niektoré levely bez gravitácie — plávanie, let. Pohyb v oboch osiach, skok sa
vypne. Technicky lacné, spestruje to.

### Aréna „Jama"

Dostupná od začiatku ako skúška schopností. Bez online rebríčka (účty a
backend sú v backlogu). Ak by online rebríček niekedy bol, musí byť
clusterovaný, inak je na prvom mieste stále ten istý hráč.

---

## 3. Otvorené, treba rozhodnúť pred stavaním

1. **Čo presne ukončí beh.** Len smrť? Alebo aj dosiahnutie konca úseku?
2. **Ekonomika klietok.** Koľko klietok na level, koľko zajatcov v jednej,
   ako rýchlo ich nepriatelia zabíjajú, koľko meny je zajatec.
3. **Zoznam vylepšení.** Musia zrýchľovať a zosilňovať zabíjanie, keďže mena
   sú zachránení zajatci.
4. **Odomykanie ďalších levelov** — za menu, alebo za zabitie slabšieho bossa?
5. **Poklepanie na prepínanie zbraní** — technické riziko, viď nižšie.

---

## 4. Známe riziká tohto dizajnu

**Poklepanie pravým palcom.** Musí sa odlíšiť od začiatku mierenia: krátky
dotyk bez posunu. Pri zúrivom hraní sa to nutne občas pomýli a hráč prepne
zbraň namiesto streľby. Treba otestovať skoro a mať v zálohe malé tlačidlo
v HUD.

**Monetizácia nie je rozhodnutá.** Pôvodný plán: premium 5,99 € bez IAP.
Zvažuje sa F2P. Rozhodnutie sa **odkladá**, lebo nemení kód ani mechaniku —
mení len tvrdosť grindu a obchodné čísla.

Dve veci, ktoré však platia už teraz:

- **Kombinácia premium + IAP je najhoršia možnosť.** Hráč, ktorý raz zaplatil,
  vníma ďalšiu platbu ako podvod; recenzie idú dole a pri indie hre bez
  marketingu sú recenzie jediný distribučný motor.
- Ak sa pôjde do F2P, **business case v kapitole 6 plánu prestáva platiť**
  (break-even 160 predajov, 2 000–4 000 predajov za rok) a treba ho prerobiť
  od nuly. Nie je to detail.

**Termín rozhodnutia:** pred F3, teda pred balansovaním ekonomiky a pred
prípravou store listingu. Nie skôr, ale ani nie neskôr.
