# Hotové prompty pre generovanie referencií

Skopíruj celý blok, vymeň len obsah v `[HRANATÝCH ZÁTVORKÁCH]`. Zvyšok nemeň —
tie frázy tam sú preto, aby generátor nespravil hrdinský portrét namiesto
herného záberu.

`[ŠTÝL]` je jediné, čo sa má medzi obrázkami naozaj líšiť. Skús na tú istú
scénu 3–4 rôzne štýly — až potom sa dá porovnávať. Príklady na koniec súboru.

**Dôležité:** rozhoduje pomer strán, nie presné rozlíšenie. Ak tvoj generátor
nedá 2400 × 1080, stačí čokoľvek v pomere 20:9 alebo 21:9.

---
***** PAvel pridal popist scen ktore pouzil*****
at wheat field
in the wild river which is walkable but wild, full of curves, strong stream, sharp dangerous stones everywhere
haunted castle
underground cave with horror atmosphere at night
old cemetery with horror atmosphere at night
deep woods with horror atmosphere at night



## 1. Herný záber — `gameplay_01.png`

**Pomer 20:9**

### Pozitívny prompt

```
side-scrolling video game screenshot, orthographic side view, flat camera at
character height, no perspective distortion, wide establishing shot, [ŠTÝL],
9th century Slavic river trade route, [MIESTO: napr. wooden palisade fort on a
riverbank at dusk], one escaped slave protagonist running left to right in the
foreground, three armed enemies further right defined only by their role and
equipment — an overseer with a coiled whip, a raider with a short spear, a
caravan guard with a round shield, all figures are small in the frame at roughly
one seventh of the image height, large amount of sky and background visible
above them, ground line in the lower third, layered background with midground
timber structures and a distant treeline, strong readable silhouettes, cohesive
limited colour palette, stylised violence
```

### Negatívny prompt

```
close-up, portrait, cinematic camera, dramatic low angle, dutch angle, three
quarter view, perspective distortion, vanishing point, depth of field, bokeh,
hero filling the frame, oversized characters, gore, blood spray,
dismemberment, severed limbs, children, civilians, unarmed villagers, religious
icons, crosses, modern clothing, fantasy monsters, orcs, dragons, text, letters,
UI, HUD, watermark, signature
```




---

## 2. Dav — `crowd_01.png`

Najtvrdší test. Tu sa rozhodne, či sa štýl dá vôbec hrať.

**Pomer 20:9**

### Pozitívny prompt

```
side-scrolling video game screenshot, orthographic side view, flat camera at
character height, no perspective distortion, wide establishing shot, [ŠTÝL],
9th century Slavic river trade route, [MIESTO], one lone escaped slave
protagonist on the far left facing right, eight to ten armed enemies spread
across the rest of the frame at different distances and heights — overseers
with whips, raiders with spears, shield guards, a Varangian warband leader in
mail, each distinguished only by armour, weapon and body shape, all figures
small in the frame at roughly one seventh of the image height, dense but
readable composition, every figure recognisable by silhouette alone, ground
line in the lower third, cohesive limited colour palette, stylised violence
```

### Negatívny prompt

Rovnaký ako pri obrázku 1.

---

## 3. Postava samostatne — `char_01.png`

**Pomer 2:3** (napr. 1024 × 1536)

### Pozitívny prompt

```
character reference sheet, single full body figure, orthographic side profile
view, neutral standing pose, [ŠTÝL], 9th century Eastern European escaped
slave fighter, [DETAILY: napr. torn linen tunic, broken iron collar, leather
arm wraps, short spear], plain flat neutral grey background, even diffuse
lighting, entire figure visible from head to feet with margin, sharp readable
silhouette, limited colour palette
```

### Negatívny prompt

```
background scenery, environment, multiple characters, crowd, close-up, cropped
limbs, cut off head, cut off feet, dramatic rim lighting, motion blur, action
pose, three quarter view, front view, gore, modern clothing, text, letters,
watermark, signature, colour swatches, multiple views
```

> Ak chceš aj nepriateľa, použi ten istý prompt a nahraď postavu za
> `slaver overseer with a coiled whip` alebo `river raider with a spear and
> round shield`. Nepriateľa nikdy needefinuj pôvodom ani farbou pleti —
> vždy rolou a výstrojom. Je to pravidlo projektu aj podmienka pre Google Play.

---

## 4. Pozadie — `env_01.png`

Tu úmyselne nie je ani `full body`, ani `character height`, ani `silhouette` —
všetko tri by ti do scény natlačili postavy.

**Pomer 20:9**

### Pozitívny prompt

```
side-scrolling video game background layer, orthographic side view, flat
camera, no perspective distortion, [ŠTÝL], 9th century Slavic river trade
route, [MIESTO: napr. burnt riverside village at dawn], completely empty
uninhabited landscape, layered parallax composition — flat foreground ground
plane in the lower third, midground [PRVOK: napr. timber palisade and a beached
longboat], background distant pine forest and low hills, cohesive limited
colour palette, even ambient light, flat readable shapes, no focal subject
```

### Negatívny prompt

```
people, person, human, man, woman, figure, character, silhouette of a person,
crowd, soldier, warrior, animals, horses, close-up, perspective distortion,
vanishing point, three quarter view, aerial view, depth of field, text,
letters, UI, watermark, signature
```

---

## Nastavenia podľa nástroja

| Nástroj | Ako zadať |
|---|---|
| **Midjourney** | Za prompt pridaj `--ar 20:9 --style raw`. Negatívny prompt zadaj ako `--no people, close-up, gore, text` (celý zoznam sa nezmestí, vyber 6–8 najdôležitejších slov). |
| **Stable Diffusion / Flux / ComfyUI** | Negatívny prompt má vlastné pole, vlož ho celý. Rozmer 1536 × 688 (20:9) a potom upscale — natívne 2400 px zvládne málo modelov. |
| **DALL·E, Imagen, Gemini, ChatGPT** | Negatívny prompt neexistuje. Prelož ho do kladných viet a pridaj na konec, napr. *"The scene is completely empty of people. The camera is flat and orthographic, not cinematic. No text anywhere in the image."* Pomer zadaj slovom: *"ultra wide 20:9 landscape format"*. |

---

## Príklady do `[ŠTÝL]`

Vyber 3–4 a použi ich na tú istú scénu. Označil som, čo je z Blenderu
dosiahnuteľné.

| Štýl do promptu | Dosiahnuteľné? |
|---|---|
S0 | `style of visual is mix of Metal Slug game serie, Shinobi game serie and Commando game serie, so pixel art extravaggated mass shooter
S1 | `cel shaded 3D render, thick dark outlines, flat colour fills` | áno, presne toto |
S2 | `pre-rendered 3D sprite art in the style of 1990s Donkey Kong Country, soft plastic shading` | áno |
S3 | `dark pre-rendered 3D art in the style of Diablo 1, muted earth tones, heavy shadow` | áno |
S4 | `low poly 3D render, flat untextured colour, hard shadows` | áno, najlacnejšie |
S5 | `clay diorama, matte sculpted figures, soft studio light` | áno |
S6 | `high contrast silhouette art, black figures against a coloured sky, single accent colour` | áno |
S7 | `painterly 2D illustration with visible brush strokes` | čiastočne, cez post-processing |
S8 | `hand drawn 2D animation, inked lines, in the style of Cuphead` | **nie** — to je ručná kresba |
S9 | `detailed hand placed pixel art, 16 bit, in the style of Metal Slug` | **nie** touto cestou |

Tie dva „nie" si aj tak vygeneruj — nech vidíme, o čo presne prichádzame, a či
sa k tomu nedá priblížiť shaderom.
