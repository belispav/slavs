# Pozadie: parallax + zjednotenie rozlíšenia

Napísané 2026-08-12 (Opus). Rozhodnutia doplnené v ten istý deň po Sonnet
session. **Toto je zadanie na vykonanie, nie na ďalšie rozhodovanie.**

---

## Rozhodnuté

- **ROZHODNUTÉ 2026-08-12, neotvárať: statickosť sa rieši parallaxom.**
  Nie shader na vode, nie animované pozadie po snímkach.
- ~~**ROZHODNUTÉ 2026-08-12: S = 2.**~~ **ZRUŠENÉ 2026-08-13 Pavlom. Späť na
  S = 1.** S = 2 fungovalo technicky — postavy boli ostrejšie a Pavel to na
  telefóne potvrdil — ale jeho nevyhnutný dôsledok (§4: LINEAR namiesto
  NEAREST, 64 farieb, bez obrysu) **prestal robiť hru pixel artom**, a to je
  to, čo VOLYA je.
  - **Čo sa naozaj pokazilo, a nebolo to S = 2:** dôsledok bol v tomto
    dokumente napísaný, ale Pavlovi nikdy nebol povedaný tou vetou —
    „týmto hra prestáva byť pixel art". Vykonalo sa to ako technický krok.
    Bola to zmena vzhľadu celej hry a mala byť jeho vedomé rozhodnutie.
  - **Pravidlo, ktoré z toho platí:** ak nejaký technický krok mení štýl hry,
    povie sa to nahlas a čaká sa na odpoveď. Nestačí to zapísať do zadania.
  - Pôvodný Pavlov problém nebol „postavy sú málo ostré", ale **„postavy sú
    jemnejšie než pozadie"**. Zmerané: postava 16,0 %, pozadie 4,8 % — pozadie
    bolo 3× hrubšie. Riešenie je jemnejšie POZADIE, nie hladšie postavy.
- **ROZHODNUTÉ 2026-08-12, neotvárať: pozadie ide cestou P1** — detail podľa
  vrstvy. Vzdialené vrstvy smú byť mäkké a v nižšom rozlíšení, ostré musí byť
  len to, čo je v hĺbke postavy a pred ňou. Zdôvodnenie a cena v §5.
- **ROZHODNUTÉ 2026-08-12, neotvárať: P3 (pozadie z Blenderu) sa nezavrhuje,
  odkladá sa** s objektívnym spúšťačom: vráti sa na stôl vtedy, keď bude
  **štýl uzavretý** a zároveň bude treba **viac než dve rôzne prostredia**
  (čiže na začiatku F3), nie skôr. Do vtedy sa o ňom nediskutuje.
- **ROZHODNUTÉ 2026-08-12, neotvárať: P2 (dlaždice z generátora) je zrušené.**
  Riešilo problém, ktorý P1 nemá — viď §5.
- **ROZHODNUTÉ 2026-08-12, neotvárať: prostredie je denné.** Otázka „nočná
  scéna — zámer, alebo náhoda?" bola moja chyba, nie Pavlova nejasnosť; viď
  §3. Namiesto nej platí merateľné pravidlo kontrastu v §6.
- **Rozlíšenie sa zjednocuje smerom NAHOR.** Zmenšiť a rozmazať sa dá vždy,
  dorobiť detail nie.
- **Pixel art nie je istý** a kvantizácia je posledný, vypnuteľný krok
  pipeline. Pri S = 2 to prestáva byť voľba — viď §4.

---

## 1. Namerané fakty

| vec | hodnota |
|---|---|
| herné rozlíšenie (`project.godot`) | 1280 × 720, stretch `canvas_items`, aspect `expand` |
| telefón (SM-S731B) | 2340 × 1080 → obraz sa naťahuje **1,5×** |
| `volya/art/env_03.png` | 2816 × 1536, kreslí sa 1:1, tiluje sa vodorovne |
| farby v `env_03.png` | **46 885** |
| veľkosť črty v `env_03.png` | ~2–3 px (pri bloku 2 sa líši 7,6 % pixelov — **napodobenina pixel artu, nie pixel art**) |
| hrdina `run_px` | 122 × 162 px, **17 farieb**, ostrosť na úrovni 1 px |
| jas hrdinu (priemer cez alfa masku) | **42,6** |
| jas pásu, po ktorom sa chodí (riadky 560–1210) | **88,9** |
| `Tuning.PLAYER_SPRITE_SCALE` / `ENEMY_SPRITE_SCALE` | 1.0 (existujú a kód s nimi počíta) |
| import textúr | `compress/mode=0` — bez VRAM kompresie |

**Nesúlad postáv a pozadia je na dvoch osiach naraz:** pozadie má viac farieb
(46 885 : 17), ale hrubšie črty (2–3 px : 1 px). Preto vyzerá zároveň
„fotograficky" aj „rozmazane" vedľa postavy. Nie je to rozdiel v rozlíšení
súborov — hustota je v oboch 1 px = 1 herná jednotka.

---

## 2. Oprava predchádzajúceho zápisu — filter už nastavený je

V predošlej verzii tohto dokumentu stálo, že `default_texture_filter` nie je
nastavený a LINEAR všetko rozmazáva. **To je nepravda a bolo by to vyšlo
najavo až pri práci.** Všetky štyri miesta, kde sa niečo kreslí, si filter
nastavujú samy:

- `volya/scripts/main.gd:120` (pozadie)
- `volya/scripts/player.gd:134`
- `volya/scripts/enemy.gd:143`
- `volya/scripts/sprite_test.gd:27`

Všetky na `TEXTURE_FILTER_NEAREST`. Projektový default sa teda neuplatní a
**„zapnúť Nearest" nie je čo — je to už spravené.** Čo sa na telefóne
skutočne deje pri 1,5× a Nearest, nie je rozmazanie, ale **nerovnomerné
pixely** (raz 1, raz 2 pixely displeja na jeden pixel podkladu) a šum pri
pohybe.

### ZMERANÉ 2026-08-13: filter na pozadí je slepá ulička

Pavel po prechode postáv na S = 2 hlásil, že pozadie vedľa nich vyzerá zle.
Pridaný bol živý prepínač `Debug.smooth_background` (panel: HLADKE POZADIE),
NEAREST ↔ LINEAR. **Pavel na telefóne nevidel absolútne žiadny rozdiel.**
Nie je to porucha prepínača — zmerané na výreze pásu, po ktorom sa chodí,
zväčšenom 1,5× oboma filtrami:

| | |
|---|---|
| priemerný rozdiel medzi NEAREST a LINEAR | **0,91 z 255 = 0,36 %** |
| najväčší rozdiel na jednom pixeli | 37 z 255 |

**Prečo:** kockatosť `env_03` je **namaľovaná v obrázku**, nie vyrobená
vzorkovaním. Generátor kreslil napodobeninu pixel artu s črtou 2–3 px (§1).
Filter mení iba hranu medzi vzorkami, čiže rozmazáva bloky o pol pixelu —
bloky samotné ostávajú. Žiadne nastavenie v hre to nezlepší.

**Dôsledok:** jediná cesta k lepšiemu pozadiu je **nový obrázok** (P1, KROK 3).
Prepínač sa nechá, stojí nič a je to meracia pomôcka pre budúce pozadia —
ale ako riešenie je uzavretý. Neskúšať znova, je to zmerané.

---

## 3. Oprava — prostredie NIE JE nočné

Otázka „nočná scéna ako hlavné prostredie?" vznikla tak, že som sa pozrel na
`ref/env_03.png` (nočný cintorín — **štýlová referencia**) a nie na
`volya/art/env_03.png` (**to, čo je v hre**). Sú to dva rôzne súbory s
rovnakým menom v dvoch priečinkoch.

To, čo je v hre, je **denná scéna**: ihličnatý les, drevená palisáda, pás
trávy a hliny, breh a rieka s balvanmi. Je to v súlade so zadaním v
`ref/PROMPTY.md` §4b a s prostredím 15. storočia. **Nič sa nemení, otázka
zaniká.** Namiesto nej platí §6.

---

## 4. Dôsledok S = 2, ktorý sa musí zapísať skôr, než sa na to príde omylom

S = 2 znamená, že podklad má **2 pixely na hernú jednotku**, a displej
zobrazuje **1,5 pixelu na hernú jednotku**. Podklad sa teda **zmenšuje**
(0,75×), nie zväčšuje.

**NEAREST je pri zmenšovaní zlý filter** — zahadzuje každý štvrtý pixel, čo
sa pri pohybe prejaví ako blikanie a lezenie hrán. Pri zmenšovaní je správny
LINEAR s mipmapami.

Z toho vyplýva jedna vec, ktorú treba povedať nahlas:

> **Pri S = 2 prestáva byť prísny pixel art dosiahnuteľný.** Ostrý pixel art
> vyžaduje, aby bol pomer podklad : displej celé číslo, a to sa na rôznych
> telefónoch nedá zaručiť. Je to v súlade s tým, že pixel art aj tak nie je
> istý — ale je to **dôsledok, nie ďalšie rozhodnutie**, a S = 2 sa kvôli
> tomu neotvára.

Praktický dopad: pri KROKU 4 sa filter na postavách mení na LINEAR + mipmapy
a `pixelize_sprites.py` sa buď vynechá, alebo pustí bez obrysu a s vyšším
počtom farieb.

---

## 5. ROZHODNUTIE: P1 — prečo, čo to stojí, čo sa zahadzuje

### Prečo nie P2 (dlaždice z generátora)

P2 riešilo, že generátor nedá 5632 px. Lenže to nerieši — **žiadna
generátorová cesta nedá skutočný detail na úrovni S = 2**; zväčšenie
vygenerovaného obrázka je zväčšenie, nie detail. P2 teda kupuje šírku sveta,
nie ostrosť, a platí za ňu švami pri každom novom pozadí. Šírku sveta rieši
KROK 3 lacnejšie (tileovateľná zem + rozsypané objekty). **Zrušené.**

### Prečo nie teraz P3 (pozadie z Blenderu)

P3 je jediná cesta k naozaj ostrému pozadiu a zavrela by nesúlad štýlov
natrvalo. Napriek tomu sa teraz nerobí, z troch dôvodov:

1. **Štýl nie je uzavretý.** Stavať drahú pipeline pre štýl, ktorý sa možno
   zmení, je opačné poradie.
2. **Je to nová disciplína.** Nie renderovanie — to už vieme — ale stavanie
   a nasvietenie 3D prostredia. Atmosféru, ktorú generátor dá zadarmo (hmla,
   svetlo cez stromy), treba v Blenderi vyrobiť, a prvé pokusy budú vyzerať
   sterilne.
3. **Hra nemá vertikálny rez.** Kulisa nie je to, čo má F2 dokázať.

**Čo by sa zahodilo, keby sa šlo do P3 teraz:** promptová knižnica
(`ref/PROMPTY.md` §4b vrátane mierky 1 m = 67 px), `env_01`–`env_03` a celý
generátorový postup. To sa neoplatí, kým nie je isté, že sa nahrádza niečím
lepším.

### Čo P1 znamená v praxi

Detail sa priradí podľa hĺbky. Mäkké pozadie za ostrou postavou **nie je
chyba, je to hĺbka ostrosti** — funguje to tak v každej hre aj v každom
fotoaparáte.

| vrstva | obsah | parallax faktor | S vrstvy | prečo |
|---|---|---|---|---|
| L0 | nebo, vzdialené kopce | 0,15 | 0,5 | nikto tam neostrí, súbor je malý |
| L1 | pás lesa | 0,45 | 1 | silueta, nie detail |
| L2 | palisáda | 0,75 | 1 | hrany sú tvrdé, ale je za postavou |
| **L3** | **zem, po ktorej sa chodí** | **1,0** | 1 → 2 | jediná vrstva v hĺbke postavy |
| L4 | pruh popredia pred nohami | 1,35 | 2 | najbližšie k oku, úzky pruh, lacné |

**Cena P1:** promptová práca na vrstvách s priehľadnosťou a viac generovania.
Žiadna nová disciplína, žiadny nový nástroj. **Zahadzuje sa nič** — `env_03`
ostáva použiteľné ako L3 celý čas vývoja.

---

## 6. Kontrast — merateľné pravidlo namiesto pocitu

Stojace pravidlo „skontroluj kontrast postavy proti pozadiu" bolo doteraz
dojem. Odteraz je to číslo, ktoré vie zmerať skript:

- **jas pásu, po ktorom sa chodí, ≥ 80** (dnes 88,9 — vyhovuje)
- **rozdiel jasu postavy a pásu pod ňou ≥ 35** (dnes 88,9 − 42,6 = **46,3 —
  vyhovuje**)

Jas = 0,299 R + 0,587 G + 0,114 B, priemer cez alfa masku postavy a cez
riadky `BG_WALK_TOP`–`BG_WALK_BOTTOM` pozadia. Každé nové pozadie a každý nový
nepriateľ sa tým premeria pred tým, než sa zapíše do hry.

---

## 7. Otvorené — kto rozhoduje a na základe čoho

Zostala jediná otvorená vec a dá sa odpovedať pohľadom:

| čo | kto | na základe čoho | kedy |
|---|---|---|---|
| **Koľko parallaxových vrstiev** (1 pruh popredia stačí, alebo treba aj vrstvy vzadu) | **Pavel** | pozrie na telefóne štyri varianty vedľa seba po KROKU 2 a povie číslo | po KROKU 2 |

Všetko ostatné je rozhodnuté. Sonnet nemá čo dopĺňať úvahou; ak na niečo
narazí, čo tu nie je, je to nové zistenie a patrí sem zapísať, nie odhadnúť.

---

## 8. Kroky vykonania

### KROK 1 — parallaxový systém, bez novej grafiky

Cieľ: po tomto kroku hra vyzerá **presne rovnako** ako predtým. Mení sa
inštalatérstvo, nie obraz. To je kontrolný bod.

1. `volya/scripts/main.gd`: **`_build_background()` sa nesmie dotknúť.** Zem
   ostáva presne ten `Sprite2D`, čo je tam dnes (riadky 111–127), faktor 1,0
   z definície, lebo cez `Parallax2D` vôbec neprejde.
2. Pridať konštantu s vrstvami ako **údaj**:

```gdscript
## Vrstvy navyše. Zem tu NIE JE - tá sa kreslí v _build_background() a
## nikdy sa neposúva inak než postava.
const BG_LAYERS := [
    # {"path": ..., "factor": 0.45, "asset_scale": 1.0, "y": -260.0},
]
```

3. Pridať `_build_parallax_layers()`, volané hneď za `_build_background()`.
   Pre každý záznam: `Parallax2D` s
   `scroll_scale = Vector2(factor, 1.0)` — **zvislá zložka vždy 1,0** —
   `repeat_size = Vector2(texture.get_width() / asset_scale, 0.0)`,
   `repeat_times = 8`, a v ňom `Sprite2D` s
   `centered = false`, `scale = Vector2.ONE / asset_scale`,
   `texture_filter = NEAREST`, `position.y = background_top() + y`.
   `z_index`: vrstvy s faktorom < 1 dostanú −101 a menej, vrstva s faktorom
   > 1 dostane +50 (pred postavu).
4. Prázdne pole → nič sa nezmení. Nasadiť, overiť na telefóne, `git commit`.

### KROK 2 — jedna vrstva popredia (najlacnejší možný test)

Toto je jediná vrstva, ktorá sa dá pridať **bez toho, aby sa `env_03` muselo
rozrezať a domaľovať** — ide pred neho, nie zaň. Preto sa začína ňou.

1. Vygenerovať `volya/art/env_03_fg.png`, **2816 × 240 px, RGBA,
   priehľadné všade okrem spodnej hrany.** Obsah: trsy trávy, nízke balvany,
   zlomený plot — pás, ktorý je jasne rozpoznateľný ako popredie. Musí
   bezšvovo tilovať vodorovne. Prompt zapísať do `ref/PROMPTY.md` ako §4c,
   s mierkou z §4b (1 m = 67 px pri S = 1).
2. Zapísať do `BG_LAYERS`:
   `{"path": "res://art/env_03_fg.png", "factor": 1.3, "asset_scale": 1.0,
   "y": 1536.0 - 240.0}`
3. Faktor spraviť živý na paneli (`Debug`, jazdec „rychlost popredia",
   rozsah 1,0–1,8), aby sa dal ladiť na zariadení bez nasadzovania.
4. Vyskúšať 1,15 / 1,3 / 1,5 a nechať Pavla vybrať.

### KROK 3 — počet vrstiev (rozhoduje Pavel, viď §7)

Ak jeden pruh popredia stačí, KROK 3 sa nekoná a ide sa na KROK 4.
Ak treba hĺbku aj vzadu, až vtedy sa `env_03` nahrádza vrstvami podľa
tabuľky v §5 — a vtedy sa zároveň zem prestaví na **tileovateľnú textúru
(512 × 512, bezšvová) + rozsypané objekty** namiesto jedného veľkého obrázka.
To je jediná vec, ktorá natrvalo zbaví zem viditeľného opakovania, a je to
zároveň dôvod, prečo bolo P2 zrušené. **Nezačínať to skôr, než Pavel povie,
že jedna vrstva nestačí.**

### KROK 4 — S = 2

Zásah je menší, než sa zdá: `Tuning.PLAYER_SPRITE_SCALE` a
`ENEMY_SPRITE_SCALE` **už existujú a kód s nimi počíta** — `player.gd:152`
násobí `drawn` scale-om, `enemy.gd:151` tiež. Hitbox, výška hlavne aj
posadenie nôh sa teda prepočítajú samy.

1. `volya/scripts/tuning.gd`: `PLAYER_SPRITE_SCALE` a `ENEMY_SPRITE_SCALE`
   z `1.0` na `0.5`.
2. Prerenderovať postavy s dvojnásobnou výškou:
   - hrdina: `-Height 162` → **324**
   - gunman: `-Height 162` → **324**
   - rusher: `-Height 190` → **380**
   Postup podľa `PRIKAZY.md`, sekcia ZBRANE / render. Nič iné sa v príkaze
   nemení.
3. **Filter na postavách z NEAREST na LINEAR** (viď §4): `player.gd:134`,
   `enemy.gd:143`, `sprite_test.gd:27` na
   `CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`.
   `main.gd:120` (pozadie) ostáva NEAREST, kým je pozadie v S = 1.
4. V `.import` súboroch priečinkov s postavami zapnúť `mipmaps/generate=true`
   a `compress/mode=2` (VRAM). Zmerať APK a pamäť pred a po.
5. `pixelize_sprites.py` pustiť s `--colours 64 --no-outline`, alebo úplne
   vynechať — 1 px obrys je pri `scale 0.5` polovica jednotky a pri
   zmenšovaní zmizne aj tak.
6. Nasadiť, pozrieť, `git commit`. **Toto je samostatná session** — nemiešať
   s parallaxom.

### KROK 5 — kontrolný skript

`tools/check_contrast.py`: dostane pozadie a priečinok so snímkami postavy,
vypíše obe čísla z §6 a povie VYHOVUJE / NEVYHOVUJE. Pustí sa na každé nové
pozadie a každého nového nepriateľa.

---

## 9. Tvrdé obmedzenia

1. **Zem sa nikdy nedostane do `BG_LAYERS`.** Kreslí ju `_build_background()`
   a ten sa nemení. Hracia plocha je mapovanie čísel
   (`BG_WALK_TOP` / `BG_WALK_BOTTOM`) na obrázok; iná rýchlosť posunu = tráva
   uteká pod nohami a neviditeľné hranice prestanú sedieť s palisádou a
   riekou.
2. **Zvislá zložka `scroll_scale` je vždy 1,0.** Kamera chodí hore-dole.
3. **Každá vrstva musí bezšvovo tilovať** a nesmie obsahovať nič výrazné a
   jedinečné — level má 12 000 jednotiek.
4. **Nič sa nesmie diať vľavo.** Ambientné objekty smú zľava prilietať,
   hrozby nie.
5. **Kvantizácia na pixel art je posledný a vypnuteľný krok.**
6. **Nič o obrázku sa nerozhoduje slovami** — varianty, `make_grid.py`,
   Pavel povie číslo.
7. **Jedna session, jedna téma.** Parallax a S = 2 sú dve.
