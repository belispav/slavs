# Úvodný prompt pre Sonnet session: parallax + walkable layer

Skopíruj všetko medzi čiarami do nového, prázdneho Cowork okna so Sonnetom.

---

Projekt VOLYA, priečinok `D:\2026\Slavs figh back`.
Prečítaj `CLAUDE.md` a `DIZAJN_pozadie_a_rozlisenie.md`. Komunikuj po slovensky,
kód a komentáre po anglicky.

**Jedna téma na túto session: rozdeliť pozadie na vrstvy a oddeliť hraciu
plochu od obrázka.** Nič iné neotváraj.

## Kde to stojí

Rozlíšenie je vyriešené a uzavreté (13.–14. 8.). Hra je pixel art, S = 1,
NEAREST, obrys vo vlastnej farbe postavy (`--outline-darken 0.55`).
**Toto sa neotvára.** V hre je pozadie `volya/art/env_05.png`.

Dnes sa pozadie kreslí ako **jeden Sprite2D** v `main.gd:_build_background()`,
2816 × 1536, dlaždicovaný vodorovne na GPU. Hracia plocha je dvojica čísel —
`BG_WALK_TOP = 560`, `BG_WALK_BOTTOM = 1210` — namapovaná na ten obrázok.

## Prečo to treba rozdeliť: dva namerané problémy

Oba nahlásil Pavel a oba sú zmerané, nie dojem:

1. **`env_05` netiluje.** Rozdiel ľavého a pravého okraja je 39,5 proti jeho
   vlastnému bežnému rozdielu susedov 16,5, čiže **2,39×**. Vidno to ako zlom
   pri prvom opakovaní a znova v strede obrazovky pri druhom.
2. **Breh rieky nie je vodorovný — klesá o 484 px zľava doprava.** Pre
   porovnanie `env_04` klesalo o 10 px, čiže bolo rovné. Spodná hranica
   chodenia je teda v obrázku šikmá, ale `BG_WALK_BOTTOM` je v kóde priamka.
   Nesúhlasia o skoro tretinu výšky obrázka.

**Ani jedno sa nemá opravovať v obrázku.** Oboje zmizne, keď bude zem vlastná
vrstva: zem dostane bezšvovú tileovateľnú textúru a rovnú hranicu, a rieka aj
les sa odsunú do vrstiev, ktoré sa nemusia trafiť do žiadnej čiary.

## Čo je rozhodnuté a nesmie sa znovu otvárať

Všetko je v `DIZAJN_pozadie_a_rozlisenie.md`. Zhrnutie:

- **Statickosť sa rieši parallaxom.** Nie shaderom na vode, nie animovaným
  pozadím po snímkach.
- **Cesta P1** — detail podľa vrstvy. Vzdialené vrstvy smú byť mäkšie a
  v nižšom rozlíšení. P2 (dlaždice z generátora) je zrušené.
  **P3 (pozadie z Blenderu) je odložené** s objektívnym spúšťačom: vráti sa,
  až keď bude štýl uzavretý a bude treba viac než dve prostredia, čiže na F3.
- **Prostredie je denné.**
- **Vrstvy sú ÚDAJ, nie kód** — pole `{textúra, faktor}` v `main.gd`. Pridať
  vrstvu má byť jeden riadok.

## Tvrdé obmedzenia (§9 dokumentu) — poruš ich a hra sa rozsype

1. **Vrstva so zemou má parallax faktor 1,0** a nikdy sa nedostane do poľa
   vrstiev. Kreslí ju `_build_background()`. Iná rýchlosť posunu = tráva uteká
   postave pod nohami a neviditeľné hranice prestanú sedieť s obrázkom.
2. **Zvislá zložka `scroll_scale` je vždy 1,0 pre každú vrstvu.** Kamera chodí
   hore-dole; zvislý parallax rozbije mapovanie hracej plochy.
3. **Každá vrstva musí bezšvovo tilovať** a nesmie obsahovať nič výrazné a
   jedinečné — level má 12 000 jednotiek, obrázok 2816.
4. **Nič sa nesmie diať vľavo.** Ľavý palec zakrýva ľavú tretinu displeja.
   Ambientné objekty smú zľava prilietať, hrozby nikdy.
5. **Hracia plocha sa berie z obrázka a pri každej zmene sa ODMERIA**, nie
   odhadne.

## Postup — §8 dokumentu, KROK 1 až 3

**KROK 1 — parallaxové inštalatérstvo, bez novej grafiky.**
Po tomto kroku musí hra vyzerať **presne rovnako** ako predtým. To je kontrolný
bod. Prázdne pole vrstiev = žiadna zmena. Nasadiť, overiť, commitnúť.

**KROK 2 — jedna vrstva popredia.** Jediná vrstva, ktorá sa dá pridať bez
rozrezania `env_05` — ide pred neho, nie zaň. Faktor daj živý na debug panel
(rozsah 1,0–1,8), aby sa dal ladiť na zariadení bez nasadzovania.

**KROK 3 — počet vrstiev. Rozhoduje Pavel, pohľadom na telefón.** Toto je
jediná otvorená otázka celého zadania. Až keď povie, že jedna vrstva nestačí,
sa `env_05` nahrádza vrstvami a zem sa prestavia na **tileovateľnú textúru
(512 × 512, bezšvová) + rozsypané objekty**. To je zároveň jediná vec, ktorá
natrvalo zbaví zem viditeľného opakovania.

## Ako pracovať (METHOD pravidlá z CLAUDE.md — dodrž ich)

1. **Nič o obraze sa nerozhoduje slovami.** Vyrenderuj varianty, poskladaj do
   mriežky, Pavel povie číslo. `tools/preview_framing.py` skladá skutočné
   pozadie, skutočný sprajt a skutočnú aritmetiku kamery do obrázka hotového
   záberu. Päť kôl sa už raz stratilo popisovaním rámovania číslami.
2. **Nič o čísle sa nehádа, meria sa.**
3. **Nástroj, ktorý končí vetou „pozri sa na toto", musí ten obrázok sám
   vyrobiť.**
4. **Ak nejaký technický krok mení štýl hry, povedz to nahlas a počkaj na
   odpoveď.** Nevykonávaj to preto, že to tak píše dokument. Toto pravidlo
   vzniklo 13. 8., keď sa hra prestala byť pixel artom ako „dôsledok kroku".

## Praktické

- Nasadenie: `powershell -ExecutionPolicy Bypass -File tools\deploy_android.ps1`
- Ostatné príkazy sú v `PRIKAZY.md`. Čo bude Pavel písať znova, patrí tam.
- Po každej funkčnej zmene: nasadiť → funguje? → `git commit`. Nikdy
  nepokračovať na rozbitom stave.
- Pavel je solo tvorca bez predchádzajúcich skúseností s vývojom hier. Píš mu
  po každej úlohe 2–3 vety o tom, čo sa spravilo a prečo. Žiadne prednášky.
- Debug panel sa spúšťa v testovacom nastavení (nesmrteľnosť zapnutá, hudba
  vypnutá, oboch nepriateľov max 3). Pred vydaním sa to musí vrátiť.

## Čoho sa v tejto session NEDOTÝKAJ

- Rozlíšenie, obrysy, veľkosť pixelov — uzavreté 13.–14. 8.
- Zásahová plocha nepriateľov — je to zapísané TODO v `CLAUDE.md` aj
  s diagnózou, ale je to iná téma.
- Melee nepriatelia a ich prekrývanie — otvorené TODO, je to rozhodnutie
  o návrhu hry, patrí Pavlovi a pravdepodobne Opusu.
- Zjednotenie farebnej palety — otvorené TODO, patrí k výrobe finálnych artov.

---
