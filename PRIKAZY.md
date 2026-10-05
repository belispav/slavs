# Slavs — príkazy, ktoré si nikto nepamätá

Ťahák. Všetko sa spúšťa z PowerShellu **z priečinka `D:\2026\Slavs figh back`**.

Ak si nie si istý, kde si, napíš `cd "D:\2026\Slavs figh back"`.

---

## PO PREMENOVANÍ volya → slavs (2026-10-03) — raz, na PC

`git pull` presunie všetky súbory z gitu do `slavs\`. Súbory, ktoré v gite
nie sú, ostanú v starom `volya\` – hlavne **`export_presets.cfg`**, bez
ktorého sa APK nezostaví. Raz spusti:

```
cd "D:\2026\Slavs figh back"
git pull
Move-Item volya\export_presets.cfg slavs\
Get-ChildItem volya\*.keystore | Move-Item -Destination slavs\
Remove-Item -Recurse -Force volya\.godot, volya\build
Get-ChildItem -Recurse -Force volya
```

Posledný príkaz vypíše, čo vo `volya\` ešte zostalo. Ak nič – zmaž ho
(`Remove-Item volya`). Ak niečo áno, pošli mi výpis skôr, než to zmažeš.

Potom v Godot editore (ak ho používaš) importuj `slavs\project.godot` –
starý záznam `volya` v zozname projektov odstráň. ID balíka v telefóne
(`sk.pavel.volya`) ostáva rovnaké, hra sa nainštaluje cez tú starú.

---

## AK `git pull` HLÁSI „Your local changes ... would be overwritten“

Najčastejšie `slavs\project.godot` – Godot editor ho prepíše vždy, keď ho
otvoríš (napr. kvôli povoleniu vibrácií). Tvoje zmeny v ňom nie sú potrebné,
všetko dôležité je na GitHube. Zahoď ich a stiahni znova:

```
cd "D:\2026\Slavs figh back"
git checkout -- slavs/project.godot
git pull
git log --oneline -1
```

Ak hlási iný súbor, pošli Claudovi výpis – nezahadzuj ho naslepo.

---

## ZVUKY — kam dať súbory (2026-10-04)

Každá udalosť má svoj priečinok v `slavs\audio\sfx\`. Hra z neho pri každej
udalosti vyberie náhodný súbor (.wav, .ogg alebo .mp3). Prázdny priečinok =
ticho, nič sa nepokazí.

| priečinok | kedy zaznie |
|---|---|
| `gunshot` | strelec vystrelí |
| `axe_throw` | hrdina hodí sekeru |
| `enemy_hit` / `enemy_death` | zásah / smrť nepriateľa (efekt) |
| `enemy_death_voice` | výkrik umierajúceho (30 % smrtí) |
| `barrel_hit` / `barrel_break` | zásah / rozbitie suda |
| `armor_clang` | sekera sa odrazí od brnenia tučniaka |
| `brute_grab` | tučniak chytí hrdinu |
| `cauldron_whistle` / `explosion` | pískanie kotla (slučka) / výbuch |
| `hero_hurt` / `hero_death` | „au“ hrdinu / smrť hrdinu |
| `rusher_shout` | bežec zakričí pri údere (40 % úderov) |
| `enemy_bark` / `hero_bark` | náhodné hlášky |

Súbory `ph_*.wav` sú dočasné, vyrobené v kóde
(`python tools\make_placeholder_sfx.py`) - keď dáš skutočný zvuk, `ph_` zmaž.
Viac súborov v priečinku = viac variácií.

---

## VIBRÁCIE — povolenie v exporte (raz, na PC, 2026-10-03)

Android dovolí hre vibrovať, len ak má v exporte povolenie **VIBRATE**.
`export_presets.cfg` nie je v gite, takže to musíš zapnúť ty:

1. Otvor projekt `slavs\project.godot` v Godot editore.
2. **Project → Export…** → preset **Android** → záložka **Options**.
3. Zroluj na **Permissions** a zaškrtni **Vibrate**.
4. Zavri okno (uloží sa samo) a nasaď ako vždy.

Bez toho hra beží normálne, len nevibruje.

---

## PIXELLAB — takto teraz vzniká všetka grafika (od 2026-10-02)

Postavy, ich animácie, predmety aj efekty generuje Claude v PixelLabe.
Ty nič nespúšťaš – stačí povedať, čo chceš. Starý postup cez Meshy / Mixamo / Blender je v archíve `_archiv/3d_stary/`
(mimo GitHubu); nepoužívať a nebrať do úvahy.

- **Ako je to napojené:** PixelLab je pripojený v aplikácii Claude na tvojom PC
  (Settings → Developer → Edit Config, položka `pixellab`). Doména `*.pixellab.ai`
  je povolená v Settings → Capabilities → Domain allowlist. API kľúč je aj v
  `tools\.pixellab_token` (nikdy nejde do gitu).
- **Ak ho Claude nevidí:** úplne zavri aplikáciu Claude (aj z lišty pri hodinách)
  a otvor ju znova.
- **Cena:** bezplatná verzia = 40 generovaní, potom 5 denne (max 20 nasporených).
  Postava ≈ 2, animácia ≈ 1. Platená verzia 12 $/mesiac = 2 000 generovaní.
- **Postup:** Claude ti najprv ukáže základný obrázok postavy na schválenie,
  až potom robí animácie a dá ich do hry. V hre je všetko 2× zväčšené.
- **Pozadia** sa v PixelLabe robiť nedajú (sú príliš veľké) – tie ostávajú po starom.
- **Snímky do hry** dáva Claude cez `tools\pixellab_export.py` (stiahne,
  zarovná nohy na spoločné plátno, tvrdá alfa, zapíše `frames.gd`). Ty to
  nespúšťaš.

---

## Nasadiť hru do telefónu

Toto je ten hlavný. Označí build, vyexportuje, nainštaluje, spustí a nechá
bežať logy z telefónu. Trvá asi 40 sekúnd.

```
powershell -ExecutionPolicy Bypass -File tools\deploy_android.ps1
```

Prepínače, keď treba:

| | |
|---|---|
| `-Clean` | najprv appku z telefónu odinštaluje (úplne čistý stav) |
| `-NoLaunch` | nainštaluje, ale nespustí |
| `-NoLogs` | nebude vypisovať logy |

Napríklad: `powershell -ExecutionPolicy Bypass -File tools\deploy_android.ps1 -Clean`

**Predtým:** telefón pripojený káblom, odomknutý, s povoleným ladením cez USB.

---

## Čo je na paneli a čo je zapnuté pri štarte

Od 2026-08-13 sa hra spúšťa rovno v testovacom nastavení, aby sa to nemuselo
klikať pri každom spustení: **nesmrteľnosť ZAPNUTÁ, hudba VYPNUTÁ, oboch typov
nepriateľov najviac 3.** Je to v `debug_state.gd` a `music_player.gd`.
**Pred vydaním sa to musí vrátiť** — nesmrteľnosť preč, hudba späť, počty späť
na `Tuning.ENEMY_MAX_ALIVE`.

Prepínače na porovnávanie grafiky:

| prepínač | čo robí |
|---|---|
| `HRUBSIE PIXELY POSTAV` | prepne postavy na sadu `art/*_b` — tie isté postavy, rovnako veľké, len s 1,5× väčšími pixelmi. **Reštartuje scénu**, lebo sprajty sa stavajú raz pri štarte. |
| `STARE POZADIE` | vráti `env_03`. Nové `env_04` je predvolené. |
| `HLADKE POZADIE` | NEAREST ↔ LINEAR na pozadí. Zmerané: robí rozdiel 0,36 %, čiže skoro nič. Nechané ako meracia pomôcka. |

Hrubšiu sadu `art/*_b` robil starý 3D reťazec (nástroje sú v archíve `_archiv/3d_stary/`, nepoužívať).

---

## Posuvníky v hre — čo každý robí

Panel stavia **len tie posuvníky, ktoré v danom režime naozaj niečo robia.**
Keď prepneš režim, panel sa prestaví. Preto ich zoznam nie je stále rovnaký.

Ku každému je napísané, čo sa stane, keď ho zdvihneš a keď znížiš, a čo na
telefóne sledovať.

---

### POHYB — keď je zapnuté „POHYB KOPIRUJE PALEC"

Postava kopíruje pohyb palca. Keď palec zastaví, zastaví aj postava — aj keď
ho stále držíš.

**`o kolko dalej ide postava nez palec`** — rozsah 1–8, teraz 3

Násobok. Pri 1 sa postava posunie presne o toľko, o koľko si posunul palec.
Pri 3 sa posunie trikrát ďalej.

- **Zvýšiš** → prejdeš level menším počtom ťahov, ale ťažšie sa trafíš presne.
- **Znížiš** → veľmi presné, ale palec sa ti minie skôr než level a budeš
  musieť ťahať znova a znova.

Sleduj: koľkokrát musíš „prehmatnúť", kým prejdeš obrazovku. Ak často, zdvihni.

---

### POHYB — keď je „POHYB KOPIRUJE PALEC" vypnuté

Palec funguje ako páčka: kam ho vychýliš od miesta, kde si ho položil, tam
postava ide, a **ide dovtedy, kým výchylku držíš.**

**`posun palca pre plnu rychlost vlavo`** a **`vpravo`** — rozsah 2–30 mm

Koľko milimetrov musíš palec posunúť, aby postava išla naplno.

- **Znížiš** (napr. na 3) → akýkoľvek dotyk = plná rýchlosť. Ostré, digitálne,
  presne ako Metal Slug.
- **Zvýšiš** (napr. na 20) → dá sa ísť aj pomaly, plynule, ale plná rýchlosť
  stojí veľa pohybu.

Sú dva, lebo palec sa dovnútra dlane ohýba inak než von. Doľava mu treba menej.

---

### POHYB — spoločné pre oba štýly

**`o kolko pomalsi je pohyb hore-dole`** — rozsah 0,2–1,0, teraz 0,62

Násobok rýchlosti do hĺbky oproti rýchlosti do strán.

- **1,0** → hore-dole rovnako rýchlo ako do strán. Postava pôsobí, že sa
  vznáša, nie že kráča.
- **0,3** → do hĺbky sa hýbe pomaly, uhýbanie je ťažšie.

Klasické hry tohto typu majú hĺbku pomalšiu. Preto 0,62.

---

### MIERENIE

Teraz je zapnuté mierenie od postavy, takže je tam jeden posuvník.

**`ako blizko k postave prestane mierit`** — rozsah 2–30 mm, teraz 9

Keď je palec bližšie k postave než toto, smer sa prestane prepočítavať a
podrží sa posledný. Streľba beží ďalej.

Je to preto, že tesne pri postave stačí milimeter a smer sa preklopí o 180°.

- **Zvýšiš** → pokojnejšie, ale okolo postavy vznikne väčšia „mŕtva" oblasť,
  kde sa smer nemení.
- **Znížiš** → mieriš aj celkom nablízko, ale bude to divoké.

---

### NEPRIATELIA

**`rychlost bezcov`** a **`rychlost strelcov`** — rozsah 0,2–2,0, teraz 1,0

Násobok. 1,0 = pôvodná rýchlosť, 0,5 = polovičná, 2,0 = dvojnásobná.

Bežci sú tí červení, čo idú priamo na teba. Strelci sú tí fialoví, čo zastanú
v diaľke a hádžu.

---

### ZONA PRE LAVY PALEC

Obdĺžnik, v ktorom sa dotyk berie ako pohyb. Všade inde sa berie ako mierenie.
**Na displeji ho vidíš orámovaný.**

**`sirka`** — 0,2–0,8, teraz 0,5. Aká široká časť obrazovky patrí pohybu.

**`kolko zospodu patri miereniu`** — 0,0–0,6, teraz 0,28

Spodný pás sa z tej zóny vyberie a patrí miereniu.

- **Zvýšiš** → ukazovákom pravej ruky dosiahneš nižšie doľava bez toho, aby to
  spustilo pohyb. Ale ľavý palec musíš držať vyššie.
- **Znížiš** → viac miesta pre ľavý palec, ale mierenie dole doľava sa začne
  meniť na chôdzu.

---

### Posuvníky, ktoré tu už nenájdeš

Šesť posuvníkov obsluhovalo švih na skok (`PRAH`, `ROZSAH`, `VLAVO+`,
`VPRAVO-`, `DNO`, `REARM`). Vo voľnom pohybe skok neexistuje, takže sa
nestavajú. Objavia sa len vtedy, ak vypneš „VOLNY POHYB".

`MIER_OTOC` sa tiež nestavia — patrí k starému spôsobu mierenia a na telefóne
prepadol, lebo počas otáčania prestávala streľba.

### Keď si hodnoty vyladíš

**Dva kroky, oba treba.** V hre stlač `VYPIS DO LOGU` — tým sa hodnoty uložia
do telefónu. Potom ich z neho stiahni:

```
powershell -ExecutionPolicy Bypass -File tools\get_tuning.ps1
```

Pošli mi ten výpis. Hodnoty patria do `slavs\config\control_config.tres`, ale
**iba namerané na zariadení** — nikdy nie odhadnuté.

---

## Všetky nástroje na jednom mieste

Spúšťajú sa `python tools\<nazov>.py`, ak nie je uvedené inak.

| nástroj | na čo |
|---|---|
| `preview_framing.py` | **nakreslí, ako to bude vyzerať na telefóne.** Pred každou zmenou rámovania |
| `check_background.py` | zmeria pozadie a povie, kde je voľná zem |
| `check_gdscript.py` | nájde rozdelené funkcie, kým zmizne pol hry |
| `pixellab_export.py` | stiahne snímky z PixelLabu a zapíše ich do hry (spúšťa Claude) |
| `bake_pixen_grounds.py` | upečie zem z obrázkov pixen |
| `deploy_android.ps1`, `get_tuning.ps1`, `diag_android.ps1` | nasadenie do telefónu, hodnoty z panelu, diagnostika |

Starý 3D reťazec (Blender, Mixamo, Meshy a nástroje k nemu) je v `_archiv/3d_stary/`, mimo GitHubu. Nepoužívať.

## Keď niečo nejde

**Diagnostika nasadzovania** — spusti a pošli mi celý výpis:

```
powershell -ExecutionPolicy Bypass -File tools\diag_android.ps1
```

**Vytiahnuť z telefónu hodnoty ovládania** — v hre najprv stlač `VYPIS DO LOGU`:

```
powershell -ExecutionPolicy Bypass -File tools\get_tuning.ps1
```

**Zmizli nepriatelia / postava / niečo v hre celé chýba.** Skoro vždy to
znamená, že sa nejaký skript neskompiloval — vtedy prestane fungovať celý,
nie len chybný riadok. Skontroluj:

```
python tools/check_gdscript.py "slavs/scripts/*.gd"
```

**Git sa sťažuje na zámok** (`Unable to create ... .lock`). Toto je najčastejší
príkaz zo všetkých — zámok vzniká, keď sa commit prerušil:

```
Remove-Item -Force .git\HEAD.lock, .git\index.lock -ErrorAction SilentlyContinue
```

**Keď mi commit nechodí ani po tomto**, pripravím ti text do `commit_msg.txt`
v hlavnom priečinku a ty spustíš:

```
Remove-Item -Force .git\HEAD.lock, .git\index.lock -ErrorAction SilentlyContinue
git add -A
git commit -F commit_msg.txt
```

**Prečo na tom záleží:** číslo buildu, ktoré vidíš v hre a vo výpise hodnôt,
sa berie z posledného commitu. Keď commity nechodia, **všetky buildy sa hlásia
rovnakým číslom** a nedá sa rozoznať, ktorá verzia je v telefóne.

**V editore postava beží, v telefóne je sivý box.** Godot pri exporte obrázky
prebalí a pôvodné `.png` v nainštalovanej hre už nie sú, takže sa priečinok
nedá prechádzať. Rieši to zoznam snímok `frames.gd`, ktorý zapisuje
`tools/pixellab_export.py`. Ak chýba, povedz to Claudovi, vyrobí ho.

**Vidí telefón vôbec počítač?**

```
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```

Musí vypísať riadok končiaci slovom `device`. Ak je tam `unauthorized`, pozri
sa na displej telefónu a povoľ ladenie.

---

## Dve pravidlá, ktoré sa vypomstia

**Do `.ps1` súborov nesmie ísť nič mimo ASCII.** Žiadne pomlčky „—", žiadna
diakritika ani v komentároch. Windows PowerShell číta tie súbory ako
Windows-1252, pomlčka sa mu rozpadne na tri znaky a jeden z nich vyzerá ako
úvodzovka. Skript potom prestane fungovať na mieste, ktoré s chybou nesúvisí.

**Po každej funkčnej zmene commit.** Nikdy nepokračuj na rozbitom stave.

```
git add -A
git commit -m "popis toho, co sa zmenilo"
```

---

