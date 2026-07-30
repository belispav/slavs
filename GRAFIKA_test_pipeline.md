# VOLYA — test grafického pipeline (jedna postava end-to-end)

**Cieľ:** za jeden večer zistiť, či ti Blender sadne, a vidieť vlastnú
animovanú postavu bežať v Godote. Nie je to výroba grafiky — je to test cesty.
Nič z toho neblokuje F1, rob to až keď máš ovládanie odovzdané.

Postavu zatiaľ neriešime obsahovo. Vezmi hocijakú z Mixama, aj rytiera aj
robota. Ide o to, či sa dostane z Blenderu do hry.

---

## 1. Čo si nainštalovať (30 minút)

1. **Blender** — `https://www.blender.org/download/`, verzia 4.x LTS.
   Inštaluj s predvolenými voľbami.
2. **Účet na Mixame** — `https://www.mixamo.com`. Je zadarmo, patrí Adobe,
   stačí bezplatný Adobe účet. Postavy aj animácie sa smú použiť v komerčnej
   hre; nesmú sa len ďalej predávať ako samostatné assety.

---

## 2. Mixamo — postava a animácia (10 minút)

1. Na Mixame prepni na záložku **Characters** a vyber si hocijakú postavu.
2. Prepni na **Animations**, do vyhľadávania napíš `run` a vyber bežecký cyklus.
3. Vpravo zaškrtni **In Place** (postava beží na mieste — pre sprajt to
   potrebujeme, pohyb rieši Godot).
4. **Download** s nastavením:
   - Format: **FBX Binary (.fbx)**
   - Frames per Second: **30**
   - Skin: **With Skin**
   - Keyframe Reduction: none
5. Ulož si súbor napr. do `D:\2026\Slavs figh back\tools\blender\hero_run.fbx`.

**Kontrola:** máš `.fbx` súbor rádovo 5–20 MB.

---

## 3. Blender — import a uloženie (10 minút)

1. Spusti Blender, v úvodnej scéne stlač `A` a potom `X` → **Delete**
   (zmaže kocku, svetlo a kameru — skript si vytvorí vlastné).
2. **File → Import → FBX (.fbx)** → vyber svoj súbor.
3. Postava sa objaví. Môže byť obrovská alebo maličká — **nevadí**, skript si
   kameru zarámuje sám.
4. V spodnej časti stlač **medzerník** — postava by mala bežať. Ak stojí,
   posuň časovú os myšou; ak je časová os prázdna, animácia sa neimportovala,
   stiahni FBX znova.
5. **File → Save As** → `tools/blender/hero_run.blend`.

**Kontrola:** máš `.blend` súbor a postava sa v ňom hýbe.

---

## 4. Render do PNG sekvencie (5 minút)

### Cesta A — príkazový riadok (odporúčam, dá sa opakovať)

V PowerShelli, na jeden riadok (cestu k `blender.exe` si over podľa svojej
verzie):

```
& "C:\Program Files\Blender Foundation\Blender 4.5\blender.exe" `
  "D:\2026\Slavs figh back\tools\blender\hero_run.blend" `
  --background `
  --python "D:\2026\Slavs figh back\tools\blender_render_sprites.py" `
  -- --out "D:\2026\Slavs figh back\volya\art\hero_run" --name run --height 96 --step 3
```

### Cesta B — v Blenderi

Prepni na záložku **Scripting**, **Open** → `tools/blender_render_sprites.py`,
v bloku `DEFAULTS` hore uprav `out` a `height`, stlač **Run Script**.

### Čo tie parametre robia

| Parameter | Význam |
|---|---|
| `--height 96` | výška snímky v pixeloch (postava v hre je teraz 54 px) |
| `--step 3` | z 30 fps mocapu spraví 10 fps sprajt — menej snímok, retro cit |
| `--angles 1` | 1 = bočný pohľad; neskôr 8 = otočka po 45° pre mierenie |
| `--name run` | predpona názvov súborov |

**Kontrola:** v `volya/art/hero_run/` je 10–20 PNG súborov s priehľadným
pozadím, v konzole posledný riadok `VOLYA: done — 1 angle(s) x N frames`.

---

## 5. Godot — pozri sa na to (2 minúty)

1. Otvor projekt v Godote. PNG súbory si sám naimportuje (chvíľu to trvá).
2. V paneli FileSystem otvor `scenes/art_test.tscn` a stlač **F6**
   (spustí aktuálnu scénu, nie hlavnú).
3. Vľavo stojí sivý box — súčasná postava v hre (54 px). Vpravo beží tvoj sprajt.

Klávesy: `←/→` mení FPS, `↑/↓` mierku, `medzerník` pauza, `R` znovunačítanie.

---

## 6. Čo hodnotiť (a čo ignorovať)

**Hodnoť:**

- Je postava **čitateľná pri hernej veľkosti**? Zmenši mierku tak, aby bola
  vysoká ako sivý box, a pozri sa z bežnej vzdialenosti od monitora.
- Drží **silueta**? Spoznáš, čo robí, aj keby bola celá čierna?
- Sedí počet snímok? Skús `--step 2`, `3`, `4` a porovnaj.
- Ako veľmi ti Blender liezol na nervy. Toto je najdôležitejšia odpoveď.

**Ignoruj:** farby, materiály, osvetlenie, tvár, oblečenie, štýl. To všetko
je nastavenie shaderu a rieši sa až potom, keď bude jasný cieľový štýl.

---

## 7. Keď niečo nejde

| Symptóm | Riešenie |
|---|---|
| `blender: command not found` | Zlá cesta k `blender.exe`. Nájdi ju v Prieskumníkovi. |
| Vyrenderuje sa 1 snímka | Animácia sa neimportovala — over v Blenderi medzerníkom. |
| PNG sú prázdne / priehľadné | Postava je mimo záberu. Pošli mi výpis z konzoly. |
| Postava je sivá bez textúr | Mixamo textúry sa nenapojili. Pre tento test to nevadí. |
| Godot PNG nevidí | Klikni do okna Godotu, aby sa spustil import, potom `R` v scéne. |
| Sprajt je rozmazaný | Nemal by byť — filter je nastavený na nearest. Napíš mi. |

---

## 8. Čo z toho vznikne ďalej

Ak test dopadne dobre, postavíme z toho plný pipeline: rozdelenie postavy na
**nohy** (7 animácií) a **trup × 8 uhlov** (mierenie), automatický render
všetkého jedným príkazom a kompozit v Godote. To už je len rozšírenie tohto
istého skriptu.
