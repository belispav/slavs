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

## Posuvníky v hre — čo je čo

Panel má desať posuvníkov v troch skupinách. Zhora nadol:

**Skok** (prvých šesť)

| | |
|---|---|
| `PRAH` | ako prudko treba švihnúť palcom, aby to bol skok |
| `ROZSAH` | dosah palca v milimetroch — koľko ho vieš natiahnuť |
| `VLAVO+` | dovnútra sa palec ohýba inak než von, toto je tá nesúmernosť |
| `VPRAVO-` | to isté na druhú stranu |
| `DNO` | najnižší prah, pod ktorý sa nikdy nejde |
| `REARM` | ako ďaleko musí palec cúvnuť, než smie skočiť znova |

**Beh** (dva)

| | |
|---|---|
| `BEH_L` | koľko treba posunúť palec doľava pre plnú rýchlosť |
| `BEH_P` | to isté doprava |

Malá hodnota = beh naskočí hneď naplno (ako Metal Slug). Veľká = plynulejšie.

**Mierenie** (dva)

| | |
|---|---|
| `MIER` | **toto hľadáš, keď terč lieta.** Malé číslo = terč lieta, veľké = pokojné a presné, ale otočenie stojí viac pohybu palca |
| `MIER_OTOC` | **nechaj na 0.** Skúšalo sa a prepadlo — počas otáčania prestane streľba |

### Keď si hodnoty vyladíš

V hre stlač `VYPIS DO LOGU`, potom spusti:

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

**Git sa sťažuje na zámok** (`Unable to create ... .lock`). Toto je najčastejší
príkaz zo všetkých — zámok vzniká, keď sa commit prerušil:

```
Remove-Item -Force .git\HEAD.lock, .git\index.lock -ErrorAction SilentlyContinue
```

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
