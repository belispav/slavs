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
Ty nič nespúšťaš – stačí povedať, čo chceš. Starý postup cez Meshy / Mixamo /
Blender nižšie v tomto súbore je už len história.

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

Hrubšiu sadu vyrába `tools/coarsen_sprites.py` z už vyrenderovaných snímok —
netreba na to Blender:

```
python tools\coarsen_sprites.py --in slavs\art\run_px --out slavs\art\run_px_b --height 108
```

Je to **len na výber**, nie na vydanie: taká snímka prešla pixelovým prechodom
dvakrát a je o kúsok mäkšia než render priamo z Blenderu v tej výške. Keď sa
hrúbka vyberie, víťaz sa prerenderuje poriadne príkazmi nižšie.

---

## RENDER NEPRIATEĽOV — pixel art (platné od 2026-08-13)

**Hra je pixel art.** Skúšala sa hladká varianta (S = 2, 64 farieb, bez
obrysu), Pavel ju videl na telefóne a je zrušená — viď
`DIZAJN_pozadie_a_rozlisenie.md`. **Nikdy nerenderuj s `-Colours 64
-NoOutline`**; presne tie dva prepínače prestali robiť hru pixel artom.

Hrdinu renderovať netreba — jeho pixel-artové snímky sú v gite a sú obnovené.
**Gunmana a rushera áno**: ich pixel-artové rendery sa stratili, prepísali sa
hladkými skôr, než sa stihli commitnúť.

**Gunman:**

```
powershell -ExecutionPolicy Bypass -File tools\render_enemy.ps1 -Name gunman -Height 162 -Anims "idle=Enemy_gunman_01 Rifle Idle:19-157, walk=Enemy_gunman_01 Rifle Walk, fire=Enemy_gunman_01 Firing Rifle"
```

**Rusher:**

```
powershell -ExecutionPolicy Bypass -File tools\render_enemy.ps1 -Name rusher -Height 190 -Anims "idle=Enemy_rusher_02 Great Sword Idle, walk=Enemy_rusher_02 Great Sword Run, attack=Enemy_rusher_02 Great Sword Slash"
```

Bez `-Colours` a bez `-NoOutline` — vtedy platia predvolené hodnoty, čiže
16 farieb a 1 px obrys, teda pixel art.

`-Height` 162 a 190 sú overené z 2026-08-10: pri nich ani jeden nečítal
primalo vedľa hrdinu. **Po rendere aj tak zmeraj skutočnú výšku**
(METHOD pravidlo 2).

---

## Postava z modelu do hry (starší príklad, menšie rozlíšenie)

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

Podrobne je to v `_archiv/POSTUP_vlastna_postava.md`. Skrátene:

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

Pošli mi ten výpis. Hodnoty patria do `slavs\config\control_config.tres`, ale
**iba namerané na zariadení** — nikdy nie odhadnuté.

---

## Všetky nástroje na jednom mieste

Spúšťajú sa `python tools\<nazov>.py`, ak nie je uvedené inak.

| nástroj | na čo |
|---|---|
| `preview_framing.py` | **nakreslí, ako to bude vyzerať na telefóne.** Pred každou zmenou rámovania |
| `check_background.py` | zmeria pozadie a povie, kde je voľná zem |
| `check_character_sheet.py` | skontroluje obrázky postavy, kým sa minie kredit |
| `prepare_character_image.py` | oreže obrázok pre generátor 3D, odstráni vodoznak |
| `extract_glb_texture.py` | vytiahne farebnú mapu z GLB |
| `inspect_fbx.py` | čo je v FBX — UV mapa, kostra, počet vrcholov |
| `check_gdscript.py` | nájde rozdelené funkcie, kým zmizne pol hry |
| `pixelize_sprites.py` | pixel-art prechod nad vyrenderovanými snímkami |

Cez Blender (`blender.exe ... --background --python tools\<nazov>.py --`):

| | |
|---|---|
| `blender_render_sprites.py` | render postavy na sprajty |
| `prepare_for_mixamo.py` | postaví model do stoja, spojí siete, prípadne zredukuje |
| `blender_attach_weapon.py` | pripne zbraň na kosť ruky |

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
nedá prechádzať. Rieši to zoznam snímok `frames.gd`, ktorý zapisuje render.
Ak chýba, vyrob ho:

```
python -c "import sys,os,glob; sys.path.insert(0,'tools'); from pixelize_sprites import write_frame_manifest; write_frame_manifest('slavs/art/run_px',[os.path.basename(p) for p in sorted(glob.glob('slavs/art/run_px/*.png'))])"
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

---

## ZBRANE — postav ju myšou, nie slovami

Opisovať slovami, kde má zbraň sedieť, je najpomalšia cesta, aká existuje.
Namiesto toho ju raz chytíš myšou v Blenderi a číslo si uložíme.

**Krok 1 — otvor si postavu so zbraňou v ruke:**

```
powershell -ExecutionPolicy Bypass -File tools\fit_weapon.ps1 -Model "ref\characters\Enemy_gunman_01 Rifle Idle.fbx" -Weapon arquebus -Name gunman
```

Skript najprv v pozadí postaví scénu a uloží ju, potom ju Blender otvorí.
Postavu vidíš cez hernú kameru a **zbraň je už vybratá**.

- `G` a pohyb myšou — posúvaš zbraň (`G X` / `G Y` / `G Z` zamkne os)
- `R` a pohyb myšou — otáčaš (`R X` / `R Y` / `R Z` zamkne os)
- `S` — zväčšuješ
- `Ctrl+S` — ulož (nechaj ten istý súbor)

**Zbraň neodpájaj od kosti.** Len ju posúvaj a otáčaj.

Prečo dva kroky a nie jeden: import FBX zo skriptu **v okne** Blenderu zlyhá,
lebo importér potrebuje kontext okna, ktorý pri štarte ešte neexistuje.
V pozadí je to bez problému. Nie je to elegancia, je to obchádzka chyby.

**Krok 2 — ulož umiestnenie do súboru:**

```
powershell -ExecutionPolicy Bypass -File tools\save_fit.ps1 -Name gunman
```

Vznikne `art\fits\gunman.json`.

**Krok 3 — renderuj čokoľvek od tej postavy s tým umiestnením:**

```
powershell -ExecutionPolicy Bypass -File tools\render_pixel_test.ps1 -Model "ref\characters\Enemy_gunman_01 Rifle Walk.fbx" -Name gunman_walk -Height 128 -Weapon arquebus -WFit art\fits\gunman.json -Angle 45 -Elevation 12
```

**POZOR, `-Height 128` v tomto príklade je zastaraná hodnota — nekopíruj ju bez rozmyslu.**
Presne toto `-Height 128` sa použilo na gunmana a vyrobilo postavu citeľne
menšiu než hrdina (zmerané 2026-08-07: hrdina má vykreslenú výšku ~120 px pri
`-Height` okolo 162; gunman len ~97 px pri `-Height 128` — rovnaký pomer
vykreslené/plátno ~0,74 v oboch prípadoch, takže na zhodu s hrdinom treba
`-Height` okolo **162**, nie 128. Pre rushera (má byť o kúsok väčší než
hrdina) skús **175–185** a po renderi zmeraj skutočnú výšku, neuhádni ju.

**Umiestnenie sa ukladá voči kosti ruky, nie voči animácii.** Preto ho fituješ
**raz na postavu** a platí pre jej idle, chôdzu aj útok. Osem nepriateľov = osem
fitovaní po pár sekundách, nie osemkrát dvadsať kôl dohadovania.

### Stiahnutá zbraň namiesto našej

Ak nájdeš lepší model zbrane (Sketchfab s filtrom CC0, Poly Pizza, Quaternius,
Kenney — alebo si ju vygeneruj v Meshy tak ako postavy):

```
... tools\fit_weapon.ps1 ... -WModel "ref\objects\arkebuza.glb"
... tools\render_pixel_test.ps1 ... -WModel "ref\objects\arkebuza.glb" -WFit art\fits\gunman.json
```

Skript ju sám otočí pozdĺž správnej osi a zvyšok je rovnaký — fitni myšou, ulož,
používaj. Pri sťahovaní si **vždy over licenciu**, rovnako ako pri Meshy.

**Formáty:** `.blend`, `.glb`, `.gltf`, `.fbx`, `.obj`. Ak ti stránka ponúkne
viac, ber `.blend` alebo `.glb`. **`.3ds` nepoužívaj** — Blender ho vie len cez
vypnutý doplnok a nič navyše neponúka.

**Otáčanie zbrane v Blenderi okolo jej vlastnej osi:** `R`, potom **dvakrát**
`X`. Prvé `X` je globálna os, druhé prepne na vlastnú os objektu. Zbrane sú
stavané pozdĺž svojej osi X, takže `R X X` točí hlavňou. Rovnako `R Y Y`,
`R Z Z`.

### Ako zistiť, či animácia vôbec drží zbraň

Názvy animácií z Mixama klamú. „Standing Melee Attack Downward" má ruky 167 cm
od seba, čo nie je obojručný úder, ale rozhodené ruky. Zmeraj to pred renderom:

```
& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --python tools\inspect_grip.py -- "ref\characters\A.fbx" "ref\characters\B.fbx"
```

Vypíše rozostup rúk a povie, či je úchop obojručný, jednoručný alebo žiadny.
Trvá sekundy a ušetrí kolá renderovania.
