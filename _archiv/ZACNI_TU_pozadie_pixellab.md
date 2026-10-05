# ZACNI TU – skúška zeme (pozadia) z PixelLabu

Odovzdávka z Cowork session 2026-10-04. Samostatná úloha, nesúvisí s tým, čo
robí iná session. **CLAUDE.md v tejto chvíli needituj** (pracuje na ňom iná
session) – výsledok tam zapíš až na konci, jedným krátkym bodom.

## Čo Pavel rozhodol (platí)

- Pavel si zaplatil **PixelLab Tier 1 (2000 generácií / mesiac, reset 2026-11-04)**.
  Chce šetriť. Na skúšku **najviac 1 generovanie** (jedno volanie, výsledok nech
  je čo najlepší).
- **Les v pozadí ostáva tak, ako je** – obe vrstvy `env_07_sky.png` v `BG_LAYERS`
  (`main.gd`), ich rýchlosti aj umiestnenie. Horná časť určite ostáva.
- **Palisáda nebude.**
- **Spodok** (les viditeľný pod hracou plochou) mu pripadá čudný – zvažuje dole
  urobiť limit v osi Y, aby sa nedalo ísť nižšie. **To NIE JE súčasť tejto
  úlohy**, rozhodne o tom sám neskôr.
- Vymieňa sa **iba povrch hracej plochy** (`env_08.png` – kamene, hlina, trsy
  trávy). Tvar plochy (`env_08_top.json`, `env_08_bottom.json`,
  `BG_WALK_TOP/BOTTOM`), les, postavy, kód – nič z toho sa nemení.

Obrázok plánu, ktorý Pavel videl, je len na jeho PC
(`Claude outputs/pozadie_plan_1_teraz.png`, nie je v repe): scéna z hry
(les + env_08 + hrdina a bežec 2x), červenou obtiahnutá plocha, ktorej povrch
sa vymení, žltý štvorec 1024x1024 = jeden obrázok z PixelLabu pri 2x, biely
rámik 1280x720 = obrazovka telefónu.

## Čo už vieme (skúška 2026-10-03, lacný model)

- `create_image_pixflux` 400x200, 1 generácia → kulisa s nebom, plotom, trávou
  a riekou. **Veľkosť pixelov pri 2x presne sedí s postavami** (hlavný prínos).
- Kvalita slabá: krikľavá zelená, opakujúce sa stromy, kreslené vlny, nakreslil
  nezmyselný nápis vľavo hore a búdu do rohu. Ako pozadie nepoužiteľné.
- Limity: najlepší model `create_image_pro` max **512x512** (štvorec) alebo
  688x384 (16:9), stojí **20–40 generácií** za volanie, nad 170 px vráti 1 obrázok.

## Úloha – čo presne spraviť

0. `get_balance` (overenie, že je Tier 1). **Pred spustením generovania sa
   Pavla jednou vetou opýtaj na potvrdenie** („spúšťam, stojí 20–40 generácií“)
   – plán videl, ale výslovné „ok“ ešte nedal.
1. **Jedno volanie `create_image_pro`, 512x512, `no_background=False`.**
   V hre sa zobrazí 2x (NEAREST) = 1024x1024, opakuje sa do šírky.
   - Štýl: `style_image` = snímka hrdinu (`slavs/art/hero_pl_axe_idle/idle_0000.png`),
     `style_copy = ["detail", "shading"]` – **bez palety** (hrdina nemá zelenú)
     a **bez obrysu** (obrys majú mať len postavy, nie zem).
   - Voliteľne `reference_images`: výrez zeme z `env_08.png` (riadky ~450–1250)
     zmenšený na 512 široký, usage: „what the ground contains (trampled earth,
     scattered grey stones, grass tufts) – NOT its dithering pattern“. Ak sa
     obrázok nedá poslať ako URL a base64 by bol príliš veľký, vynechaj ho.
   - Zadanie:

```
Seamless tileable ground texture for a 2D side-scrolling beat-em-up, camera slightly above so it reads as a floor seen at a low angle. Daylight, 15th-century Eastern European wilderness.
The whole canvas is walkable ground: trampled earth and dry dirt, scattered grey stones of different sizes, small tufts of short grass, a few darker damp patches. Nothing tall standing on it.
Scale: a grown man is 60 px tall, so stones are 4-20 px and grass tufts at most 12 px tall.
Muted natural earth colours; the ground must be clearly lighter than dark-clothed characters walking on it.
Left and right edges must match so it tiles horizontally.
No sky, no horizon, no trees, no fence, no water, no people, no buildings, no text, no letters, no UI.
```

2. **Porovnávací obrázok** (bez ďalšieho generovania), ako `pozadie_plan_1_teraz.png`:
   - Poskladaj scénu ako v hre: `env_07_sky.png` opakovaný do šírky na y = 265
     (spodná vrstva), potom na y = -606.5 (horná vrstva, kreslí sa pred ňou),
     potom zem. Súradnice sú v riadkoch obrázka `env_08` (zem na y = 0).
   - Vľavo/hore **súčasná** zem `env_08`, vpravo/dole **nová**: nová textúra 2x
     NEAREST, opakovaná do šírky, orezaná **alfou z env_08** (rovnaký tvar
     plochy). Alfa env_08 pokrýva riadky 276–1370 (1094 px) – 1024 nestačí o 70,
     takže buď zopakuj aj zvisle, alebo hore/dole nechaj pôvodný okraj env_08 –
     vyber to, čo vyzerá lepšie, a povedz ktoré.
   - Do oboch daj hrdinu a bežca 2x (`hero_pl_axe_idle/idle_0000.png` 96x96, chodidlá
     v riadku 79; `rusher_pl_idle/*_0000.png` 104x104, chodidlá v riadku 88).
   - Ulož do `ref/preview/` (v repe), commitni a pushni, ukáž Pavlovi.
3. **Zmeraj a povedz jednou vetou každé:**
   - kontrast: jas pásu, kde sa chodí, ≥ 80 a rozdiel voči hrdinovi ≥ 35
     (pravidlo z `DIZAJN_pozadie_a_rozlisenie.md` §6, `tools/check_contrast.py`, ak existuje);
   - nadväznosť okrajov: rozdiel ľavého a pravého stĺpca voči šumu susedných
     stĺpcov (env_04 = 1.99x bolo OK, env_05 = 2.39x bolo vidieť);
   - či horný okraj (orezaný po červenej čiare) nepôsobí príliš ostro – ak áno,
     ukáž to a navrhni riešenie, negeneruj.
4. **Nič do hry bez Pavlovho súhlasu.** Až keď povie áno: textúra do
   `slavs/art/`, prepínač v debug paneli (ako kedysi `alt_background`), aby to
   videl na telefóne v pohybe.

## Ako s Pavlom komunikovať

Po slovensky, jednoducho, krátko, jedna otázka naraz. Najprv obrázok, potom
čísla. Kód a komentáre po anglicky.
