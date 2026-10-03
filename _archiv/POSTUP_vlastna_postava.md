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

Do `[POSTAVA]` opis konkrétnej postavy — vždy rolou a výstrojom, nikdy pôvodom
ani farbou pleti. Príklad hrdinu je nižšie.

```
character reference for 3D modelling, single full body humanoid figure,
strict symmetrical T-pose, both arms stretched perfectly straight out and
exactly horizontal at shoulder level, palms facing down, fingers together and
straight, legs straight and slightly apart,
[POHĽAD], orthographic, no perspective distortion,
[POSTAVA],
empty hands, no weapons, no chains, no hanging straps, no dangling cords,
no cape, no loose flowing fabric, nothing hanging off the body,
plain flat neutral grey background, no floor, no ground plane, no cast shadow,
even flat diffuse lighting, no rim light,
entire figure visible from head to feet with margin, clear readable silhouette
```

Hrdina do `[POSTAVA]`:

```
15th century Eastern European escaped slave fighter, thick dark beard, short
messy hair above the shoulders, bare muscular arms, torn sleeveless light linen
tunic, dark brown cloth trousers, worn dark leather boots, tight leather wraps
on the forearms, a plain closed iron band on one wrist
```

### Negatívny prompt

```
action pose, dynamic pose, walking, running, contrapposto, arms down, arms
bent, holding weapon, sword, axe, dagger, shield, cape, cloak, flowing fabric,
chain, hanging chain, dangling strap, loose cord, loose hair, floating objects,
detached parts, dramatic lighting, rim light, strong shadows, cast shadow,
floor, ground, background scenery, environment, multiple characters, close-up,
cropped limbs, cut off head, cut off feet, perspective, foreshortening, text,
letters, watermark, signature, colour swatches
```

### Kontrolný zoznam pred krokom 2

Prejdi ho poctivo. Generovanie obrázkov je zadarmo, kredit na 3D nie —
a chyba z tohto kroku sa prejaví až o dva kroky ďalej.

- [ ] Vo všetkých troch je tá istá postava a **rovnaké vlasy**
- [ ] Ruky sú **vodorovné**, nie klesajúce
- [ ] Dlane **nadol**, prsty spolu
- [ ] V rukách nič nedrží
- [ ] **Nič z postavy nevisí** — žiadna reťaz, remienok, šnúrka
- [ ] Na zemi **nie je tieň**
- [ ] Pozadie je rovnomerné, bez prechodu
- [ ] Postava je na všetkých troch **rovnako vysoká**

Posledný bod sa okom neodhadne. Zmerať sa dá takto:

```
python tools/check_character_sheet.py ref/characters/02_main
```

> Prvá sada obrázkov padla na troch veciach naraz: z jedného zápästia visela
> reťaz s tenkými článkami, vlasy boli spredu kratšie než zozadu, a na zemi bol
> tieň. Ani jedna z nich sa nedá opraviť neskôr — tenká visiaca geometria je to,
> čo rekonštrukcia z obrázkov zvláda najhoršie, protirečiace si pohľady kazia
> práve to miesto, kde si protirečia, a tieň sa zapečie do textúry.
>
> Nápad rozbitého puta prežil ako **pevný krúžok na zápästí**. Pri 96 px
> vyzerá rovnako a nič neriskuje.

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
   `idle`, `walk` alebo `run`, neskôr `death`

   **`idle` je povinná, nie voliteľná.** Bez nej postava po zastavení zamrzne
   v snímke z chôdze — na jednej nohe a naklonená dopredu. Hra si ju načíta
   sama, keď ju vyrenderuješ do `slavs/art/idle_px/`.

   Skok už nepotrebujeme, hra ho nemá.
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

Skript vyrenderuje sprajty do `slavs/art/run_px/` a hra ich načíta sama —
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
