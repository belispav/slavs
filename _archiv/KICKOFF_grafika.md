# Kickoff pre novú session — výber grafického štýlu

Otvor nový Cowork v tomto priečinku a skopíruj mu celý prompt nižšie.

---

```
Pracuješ na hre VOLYA v tomto priečinku. Najprv si prečítaj CLAUDE.md, potom
DIZAJN_core_loop.md a GRAFIKA_test_pipeline.md. Plán VOLYA_plan_hry.md čítaj
len ak potrebuješ kontext — jeho kapitoly 3.2 a 3.5 už neplatia, nahrádza ich
DIZAJN_core_loop.md. Kapitola 2 (citlivá téma) platí absolútne a bez výnimky.

Stav: F1 (ovládanie) je GO. Hordy nepriateľov sú postavené a hranie je zábavné.
Grafika je zatiaľ sivé obdĺžniky a to je jediné, čo teraz riešime.

Úloha: vygeneroval som 20 štýlových referencií. Sú v ref/ v plnom rozlíšení a
v ref/preview/ ako zmenšené JPEG (tie používaj na prezeranie, plné rozlíšenie
otváraj len keď potrebuješ detail). Popis, čo mali zachytiť, je v ref/README.md
a prompty vrátane zoznamu štýlov S0–S9 v ref/PROMPTY.md.

Chcem:
1. Prejsť ich so mnou kus po kuse a povedať mi pri každom, či je ten štýl
   dosiahnuteľný cestou 3D v Blenderi → pre-renderované 2D sprity, ktorú sme
   zvolili (dôvody v CLAUDE.md a GRAFIKA_test_pipeline.md). Rozpočet je 0 €,
   som jediný človek a neviem kresliť.
2. Vybrať jeden smer a spísať z neho štýlovú bibliu: paleta, pravidlá siluety,
   shading model, obrys, post-processing.
3. Preložiť ju do konkrétnych nastavení render skriptu tools/blender_render_sprites.py
   a do zodpovedajúceho shaderu v Godote.
4. Dostať prvú skutočnú postavu do hry namiesto sivého obdĺžnika.

Pravidlá práce: malé úlohy, po každej funkčnej zmene git commit, nikdy
nepokračuj na rozbitom stave. Vysvetľuj po slovensky, stručne, bez žargónu —
game dev robím prvýkrát. Nasadzovanie do telefónu robí
tools/deploy_android.ps1 (build stamp → export → inštalácia → spustenie →
živé logy).
```

---

## Čo si nová session musí všimnúť

- **Veľkosť postavy.** Hráč má teraz 54 jednotiek zo 720 výšky obrazovky, čo je
  7,5 %. Žáner má okolo 16 % (Metal Slug). Cieľ je ~96–112 jednotiek, sprity
  renderovať vo výške 96 px. Zmena sa má urobiť **s grafikou naraz**, lebo
  ovplyvní rozmery levelov a výšky skokov.
- **Nepriatelia chodia výhradne sprava.** Ľavý palec zakrýva ľavú tretinu
  displeja. Platí to aj pre kompozíciu pozadí a umiestnenie klietok.
- **Pomer obrazovky je 20:9**, viditeľná plocha 1600 × 720 jednotiek.
- **Nepriateľ sa nikdy nedefinuje etnicitou**, vždy rolou a výstrojom. Týka sa
  to aj art directionu a promptov.
- Smerovanie je absurdno-fantasy vrátane hororu a nadprirodzena; historicky
  verné musí zostať len citlivé jadro (otrok proti otrokárom).
