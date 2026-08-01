# Vlastná postava — od obrázka po sprajt v hre

Cesta, ktorou sa dá dostať postava z referencie do hry bez modelovania:

```
obrázok (T-póza, 3 pohľady)  →  AI: obrázok → 3D  →  FBX
        →  Mixamo auto-rigger (kostra)  →  Mixamo animácie
        →  tools/render_pixel_test.ps1  →  sprajty  →  hra
```

Prvé tri kroky robíš ty, posledné dva skript. Prvý raz to zaberie večer,
každá ďalšia postava potom hodinu.

**Prečo je to pre nás v poriadku, aj keď AI modely majú povesť škaredých:**
výsledok je sprajt vysoký 96 pixelov. Zlá topológia, nepresné prsty a rozmazané
detaily — teda presne to, čo sa AI modelom vyčíta — v tejto veľkosti fyzicky
nevidno. Rozhoduje silueta a tri-štyri farebné plochy.

---

## Krok 1 — Character sheet v T-póze

Toto je jediný krok, kde sa dá celý postup pokaziť. **T-póza nie je estetická
voľba, je to technická podmienka** — Mixamo podľa nej hľadá ramená, lakte a
kolená. Postava v akčnej póze sa nedá spoľahlivo origgovať.

### Tvrdé podmienky (porušenie = postup zlyhá o dva kroky ďalej)

| Podmienka | Prečo |
|---|---|
| T-póza, ruky vodorovne do strán, dlane nadol | Mixamo hľadá kostru podľa nej |
| Nohy mierne od seba, rovno | Aby sa dali oddeliť |
| **Žiadne zbrane v rukách** | Voľne visiaci predmet auto-rigger rozhodí |
| Žiadny plášť, šatka vo vetre, dlhé voľné látky | To isté |
| Nič sa nesmie „vznášať" oddelene od tela | Auto-rigger to odmietne |
| Rovnomerné svetlo, žiadne dramatické tiene | Tieň sa zapečie do 3D modelu |
| Čisté jednofarebné pozadie | Aby sa dala postava oddeliť |
| Tri pohľady: spredu, z boku, zozadu | Bez nich si AI bok a chrbát vymyslí |

Dýky, sekeru a podobne pridáme neskôr — buď ako samostatný malý model, alebo
sa dokreslia až do sprajtu. Do modelu na riggovanie nepatria.

### Prompt

Vygeneruj **tri samostatné obrázky** (nie jeden list s tromi postavami — AI
nástroje na 3D chcú samostatné pohľady). Do `[POHĽAD]` daj postupne
`front view`, `left side profile view`, `back view`.

```
character reference for 3D modelling, single full body humanoid figure,
strict symmetrical T-pose with both arms stretched straight out horizontally
to the sides, palms facing down, legs straight and slightly apart,
[POHĽAD], orthographic, no perspective distortion,
15th century Eastern European escaped slave fighter, bearded, bare muscular
arms, torn sleeveless linen tunic, broken iron collar at the neck, leather
wraps on forearms, simple cloth trousers, worn leather boots,
empty hands, no weapons, no cape, no loose flowing fabric,
plain flat light grey background, even flat diffuse lighting, no cast shadows,
no rim light, entire figure visible from head to feet with margin,
neutral colours, clear readable silhouette
```

### Negatívny prompt

```
action pose, dynamic pose, walking, running, contrapposto, arms down, arms
bent, holding weapon, sword, axe, dagger, shield, cape, cloak, flowing fabric,
loose hair, floating objects, detached parts, dramatic lighting, rim light,
strong shadows, background scenery, environment, multiple characters, close-up,
cropped limbs, cut off head, cut off feet, perspective, foreshortening, text,
letters, watermark, signature, colour swatches
```

**Kontrola pred pokračovaním:** máš tri obrázky tej istej postavy, vo všetkých
je v T-póze, v rukách nič nedrží a nič z nej nevisí voľne.

> Poznámka k obsahu: postava sa opisuje rolou a výstrojom, nikdy pôvodom ani
> farbou pleti. Platí to aj pre nepriateľov. Je to pravidlo projektu
> (CLAUDE.md) aj podmienka Google Play.

---

## Krok 2 — Obrázky na 3D model

Dve možnosti. Odporúčam začať prvou, druhá je záloha, ak ti prekáža podmienka
uvádzať autora nástroja.

### A) Meshy (rýchle, zadarmo, s podmienkou)

1. `https://www.meshy.ai` → **Image to 3D**
2. Nahraj **všetky tri** pohľady naraz (nástroj ich vie skrížiť; z jedného
   obrázka si bok a chrbát vymyslí a býva to zle)
3. Stiahni ako **FBX**

Čo treba vedieť:

- Bezplatný plán dáva **100 kreditov mesačne**, jedna generácia stojí 20 —
  teda **päť pokusov za mesiac**. Plánuj ich, nie je to nekonečné.
- Modely z bezplatného plánu sú pod licenciou **CC BY 4.0**. Komerčné použitie
  je povolené, ale **musíš uviesť Meshy v kreditoch hry a v popise na Google
  Play**. Napríklad: *„3D models created with Meshy – CC BY 4.0"*.
- Ak by ti tá podmienka prekážala, platený plán ju ruší. **Rozhodni sa skôr,
  než postavíš celú hru na modeloch z bezplatného plánu** — meniť to spätne
  znamená vygenerovať všetko znova.

### B) Hunyuan3D 2.1 (zadarmo, bez podmienok, ale prácnejšie)

Plne otvorený model od Tencentu, vrátane váh. Beží u teba lokálne, takže
žiadne kredity a žiadna povinnosť uvádzať autora. Cena: treba to nainštalovať
a potrebuješ na to slušnú grafickú kartu.

Ak chceš ísť touto cestou, povedz a rozpíšem inštaláciu.

**Kontrola:** máš `.fbx` alebo `.obj` súbor a v Blenderi (File → Import) sa
otvorí ako postava v T-póze.

---

## Krok 3 — Mixamo: kostra a animácie

1. `https://www.mixamo.com` → **Upload Character**
2. Nahraj FBX z kroku 2

Auto-rigger je vyberavý. Ak model odmietne alebo pokrivkáva, príčina je skoro
vždy jedna z týchto:

| Problém | Riešenie |
|---|---|
| Model nie je v T-póze | Späť na krok 1 |
| V súbore je aj kamera, svetlo alebo pomocný objekt | V Blenderi zmaž všetko okrem tela, ulož znova |
| Postava sa skladá z viacerých oddelených kusov | V Blenderi označ všetko a `Ctrl+J` (spojiť) |
| Postava nestojí v strede sveny | V Blenderi `Object → Set Origin → Origin to Geometry`, potom `Alt+G` |
| Model je obrovský alebo maličký | Nevadí, náš render si kameru zarámuje sám |

3. Keď je kostra hotová, prepni na **Animations** a stiahni si postupne:
   `run`, `idle`, `jump`, prípadne `death`
4. Pri každej: **In Place** zaškrtnuté, formát **FBX Binary**, **30 fps**,
   **With Skin**, Keyframe Reduction: none
5. Ulož do `tools/blender/`

---

## Krok 4 — Do Blenderu a do hry

1. Blender: nová prázdna scéna (`A`, `X` → Delete), `File → Import → FBX`
2. Medzerníkom over, že sa postava hýbe
3. `File → Save As` → `tools/blender/hrdina_run.blend`
4. V PowerShelli:

```
powershell -ExecutionPolicy Bypass -File tools\render_pixel_test.ps1 -Blend "tools\blender\hrdina_run.blend"
```

Skript vyrenderuje sprajty do `volya/art/run_px/` a hra ich načíta sama —
nemusíš v Godote nič nastavovať.

**Kontrola:** spusti hru, na mieste sivého obdĺžnika stojí postava.

---

## Čo sa bude ladiť potom

- **Farby.** Textúra z AI modelu býva fotorealistická. Zmenšíme ju a prípadne
  prefarbíme; paleta hry je zatiaľ neurčená a rieši sa samostatne.
- **Veľkosť.** Sprajt má 96 px, hitbox 54 px. Je to zámer — menší hitbox
  nadŕža hráčovi (pilier 1) — ale hodnota sa ešte doladí na telefóne.
- **Tvár.** Pri 96 px má hlava ~12 px. Rozhodnuté: skúsime to bez prilby a
  posúdime na výsledku.
- **Uhly na mierenie.** Zatiaľ renderujeme jeden bočný pohľad. Neskôr trup
  v ôsmich uhloch, aby postava mierila tam, kam strieľa.
