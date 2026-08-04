# VOLYA — príkazy, ktoré si nikto nepamätá

Ťahák. Všetko sa spúšťa z PowerShellu **z priečinka `D:\2026\Slavs figh back`**.

Ak si nie si istý, kde si, napíš `cd "D:\2026\Slavs figh back"`.

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

## Postava z modelu do hry

Vyrenderuje sprajty a uloží ich rovno tam, odkiaľ ich hra načítava. Po ňom už
stačí spustiť nasadenie vyššie.

```
powershell -ExecutionPolicy Bypass -File tools\render_pixel_test.ps1 -Model "tools\blender\hrdina_run.fbx" -Texture "ref\characters\Meshy_AI_The_Tattered_Wanderer_0802131405_texture_basecolor.jpg" -Height 128
```

**Postava má dve animácie.** Chôdzu vyrenderuj do `run_px`, státie do
`idle_px` — hra si obe načíta sama:

```
powershell -ExecutionPolicy Bypass -File tools\render_pixel_test.ps1 -Model "tools\blender\hrdina_idle.fbx" -Name idle -Height 160 -Texture "ref\characters\Meshy_AI_The_Tattered_Wanderer_0802131405_texture_basecolor.jpg"
```

(Rozhoduje `-Name` — z neho vznikne názov priečinka `<name>_px`.)

Čo sa dá meniť:

| | |
|---|---|
| `-Height 128` | výška postavy v pixeloch. Väčšie číslo = väčšia postava |
| `-Colours 16` | koľko farieb má paleta |
| `-Bands 3` | koľko stupňov svetla a tieňa |
| `-Model` | `.fbx`, `.glb` aj `.blend` — Blender otvárať netreba |
| `-Texture` | farebná mapa. Bez nej je postava sivá |

Otvorí sa prehľad a jedna animácia s rýchlosťami 30 / 15 / 10 fps vedľa seba.

---

## Nová postava — celá cesta

Podrobne je to v `POSTUP_vlastna_postava.md`. Skrátene:

**1. Skontrolovať obrázky, kým sa minie kredit**

```
python tools\check_character_sheet.py ref\characters\02_main
```

**2. Orezať obrázok pre generátor 3D** (odstráni vodoznak, vycentruje)

```
python tools\prepare_character_image.py ref\characters\02_main_front.png
```

**3. Vytiahnuť farbu z GLB**, ktoré príde z generátora

```
python tools\extract_glb_texture.py ref\characters\model.glb
```

**4. Pripraviť model pre Mixamo** — postaví do stoja, spojí do jednej siete

```
& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --python "tools\prepare_for_mixamo.py" -- --in "ref\characters\model.glb" --tris 0 --out "ref\characters\hrdina_pre_mixamo.fbx"
```

Vo výpise musí byť **`UV mapy: 1`**. Bez nej bude postava navždy sivá.

**5. Skontrolovať, čo je v súbore**, kým sa niekam nahrá

```
python tools\inspect_fbx.py "ref\characters\hrdina_pre_mixamo.fbx"
```

**6.** Nahrať na `mixamo.com` → Upload Character → označiť kĺby → Animations →
`Fast Run` → **In Place** → Download: FBX Binary, 30 fps, With Skin,
Keyframe Reduction none → uložiť do `tools\blender\`

**7.** Spustiť render (príkaz vyššie) a nasadiť do telefónu.

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

Pošli mi ten výpis. Hodnoty patria do `volya\config\control_config.tres`, ale
**iba namerané na zariadení** — nikdy nie odhadnuté.

---

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
python tools/check_gdscript.py "volya/scripts/*.gd"
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
nedá prechádzať. Rieši to zoznam snímok `frames.gd`, ktorý zapisuje render.
Ak chýba, vyrob ho:

```
python -c "import sys,os,glob; sys.path.insert(0,'tools'); from pixelize_sprites import write_frame_manifest; write_frame_manifest('volya/art/run_px',[os.path.basename(p) for p in sorted(glob.glob('volya/art/run_px/*.png'))])"
```

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
