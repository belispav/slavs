# Pozadie: parallax + zjednotenie rozlíšenia — zadanie pre ďalšiu session

Napísané 2026-08-12 (Opus), upravené po Pavlových rozhodnutiach v tej istej
session. Určené na prácu v samostatnej Sonnet session.

## Rozhodnuté

- **Statickosť sa rieši parallaxom.** Ostatné možnosti (shader na vode,
  animované pozadie po snímkach, plné rozvrstvenie hneď) sú na to, čo prinesú,
  príliš drahé. Otestuje sa **1 vrstva navyše proti viacerým** a rozhodne sa
  z obrazu, nie z popisu.
- **Rozlíšenie sa zjednocuje smerom NAHOR** — na najvyššie, ktoré má zmysel,
  nie na najnižšie. Dôvod je Pavlov a je správny: **zmenšiť a rozmazať sa dá
  vždy, dorobiť detail sa nedá.** A keďže je otvorené, či sa vôbec ostane pri
  pixel arte, podklady musia prežiť aj zmenu štýlu.
- **Pixel art nie je istý.** Nič sa nesmie postaviť tak, aby sa to bez neho
  rozsypalo. Kvantizácia na 17 farieb je posledný krok pipeline, nie jej
  základ — a musí sa dať vypnúť.

---

## 1. Namerané fakty

| vec | hodnota |
|---|---|
| herné rozlíšenie (`project.godot`) | 1280 × 720 |
| stretch mód | `canvas_items`, aspect `expand` |
| filter textúr | **nenastavený → Godot default = LINEAR** |
| `env_03.png` | 2816 × 1536, kreslí sa 1:1, **46 885 farieb, žiadna pixelová mriežka** |
| hrdina `run_px` | 122 × 162 px, **17 farieb** |
| telefón (SM-S731B) | 2340 × 1080 → obraz sa naťahuje **1,5×** |
| import textúr | `compress/mode=0` (bez VRAM kompresie) |

**Čo to znamená:** hra už teraz kreslí do plného rozlíšenia telefónu. Čo plné
rozlíšenie nevyužíva, sú **podklady** — postava vysoká 122 px sa na telefóne
naťahuje na 183 pixelov displeja. To sa nedá zaostriť nastavením; chýbajú
pixely v súbore.

---

## 2. Rozlíšenie — jedno číslo, ktoré treba rozhodnúť

Celé zjednotenie sa dá zredukovať na jednu otázku:

> **Koľko pixelov podkladu pripadá na jednu hernú jednotku?**

Toto číslo (ďalej **S**) musí byť **rovnaké pre postavy aj pre pozadie**. To
je celé „zjednotenie rozlíšenia" — nič viac za tým nie je.

| S | čo to znamená | ako to vyzerá na telefóne |
|---|---|---|
| **1** (dnes) | postava 122 px, pozadie 2816 px | naťahuje sa 1,5× → mäkké, „zväčšená fotka" |
| **2** (odporúčané) | postava 244 px, pozadie 5632 px, kreslí sa `scale 0.5` | 1,33 pixelu podkladu na 1 pixel displeja → ostré na každom telefóne až po 1440p |
| 1,5 | presne na Pavlov telefón | zle — viaže hru na jedno zariadenie |

**S = 2 je štandardná odpoveď** a je to presne to, čo Pavel navrhol: vyrobiť
vysoko, znížiť podľa potreby.

### Čoho sa to NEDOTKNE (dôležité)

- Herné jednotky ostávajú. Hracia plocha, rýchlosti, dostrel, hitboxy — nič.
- **Namerané hodnoty ovládania v `control_config.tres` ostávajú nedotknuté.**
  Sú v milimetroch na displeji, nie v pixeloch podkladu.
- `main.gd`, `enemy.gd`, `player.gd` — logika sa nemení.

### Čoho sa to dotkne

| vec | dopad |
|---|---|
| render v Blenderi | 4× dlhšie a 4× väčšie súbory. Renderuje sa cez noc, nie je to problém. |
| veľkosť gitu | reálny problém pri 8 typoch nepriateľov. Treba to riešiť (LFS alebo podklady mimo repa). |
| pamäť na telefóne | 4× viac. **Musí sa zapnúť VRAM kompresia** (dnes je `compress/mode=0`, čiže sa do pamäte nahráva surové RGBA — pozadie samo 17 MB, pri S=2 by to bolo 69 MB). |
| `BG_WALK_TOP` / `BOTTOM` | prepočítať raz, na jednom mieste. |
| `pixelize_sprites.py` | ostáva, ale ako **voliteľný posledný krok**, nie ako súčasť základu. |

> **VRAM kompresia a pixel art si odporujú** — ETC2/ASTC robí na tvrdých
> hranách bloky. Na mäkkej vysoko-rozlíšenej grafike je bezproblémová. To je
> ďalší argument v prospech smeru, ktorý Pavel zvažuje: **čím menej pixel
> artu, tým lacnejšia hra na pamäť.**

### Jediná skutočná prekážka: pozadie

Postavy sa vyrobia v S = 2 triviálne — v Blenderi sa zmení jedno číslo.
**Pozadie nie**, lebo nevychádza z Blenderu, ale z generátora, a ten toľko
pixelov nedá. 5632 × 3072 je nad tým, čo generátory kreslia; zväčšiť
vygenerovaný obrázok znamená zväčšiť ho, nie pridať detail.

Tri cesty, treba vybrať jednu:

**P1 — vzdialené vrstvy nechať v nižšom rozlíšení, blízke vo vysokom.**
Parallax to aj tak rozdeľuje na vrstvy. Vzdialené hory a nebo majú byť mäkké
(fyzikálne správne), takže tam S = 1 nikoho neurazí. Ostrý musí byť len pás,
po ktorom sa chodí, a popredie — a to sú úzke pruhy, ktoré generátor zvládne.
*Najlacnejšie, zapadá do parallaxu, odporúčané.*

**P2 — pozadie skladať z dlaždíc.** Generovať po kusoch a zliepať.
*Funguje, ale švy sú práca navyše pri každom novom pozadí.*

**P3 — pozadie renderovať v Blenderi ako postavy.** Rozlíšenie si potom
určujeme sami, parallaxové vrstvy vypadnú z renderu zadarmo (každá hĺbka je
vlastný priechod) a nesúlad štýlu zmizne natrvalo, lebo všetko ide z jedného
zdroja.
*Najlepší výsledok a najnižšia zložitosť do budúcna — ale znamená to postaviť
3D prostredie, čo je nová disciplína. CC0 balíky existujú. Toto je jediná
možnosť, ktorá otázku „pozadie vs. postavy" zavrie navždy; stojí za to ju
zvážiť skôr než sa vyrobí 12 pozadí generátorom.*

---

## 3. Parallax — riziko a obmedzenie #1, vysvetlené

### V čom je problém

Zem, po ktorej sa chodí, je **obrázok**, ale hranice, kam smie postava
stúpiť, sú **čísla** (`BG_WALK_TOP` = 560, `BG_WALK_BOTTOM` = 1210). Dnes
sedia na seba, lebo sa obrázok aj postava posúvajú rovnako.

Parallax znamená „posúvaj túto vrstvu inou rýchlosťou". Ak sa tá vrstva
obsahuje zem, obrázok trávy sa začne posúvať oproti neviditeľným hraniciam —
a postava chodí po tráve, ktorá jej uteká pod nohami, alebo ju hra zastaví
uprostred lúky, prípadne ju pustí do rieky.

### Dá sa to ošetriť?

**Áno, úplne, a nestojí to nič.** Nie je to riziko, ktoré treba strážiť — je
to pravidlo, ako sa vrstvy rozdelia:

- **Vrstva so zemou má faktor 1,0** — čiže je to presne ten Sprite2D, čo je
  v hre dnes. Nemení sa.
- **Parallax dostane len to, čo je ZA ňou** (nebo, hory, les, palisáda) —
  faktor menší než 1.
- **A prípadne úzky pruh PRED nohami** (tráva, plot, balvany na spodnej hrane)
  — faktor väčší než 1. Ten musí byť jasne rozpoznateľný ako popredie, inak
  to vyzerá ako druhá zem, ktorá sa kĺže.

**Druhé pravidlo, ktoré riziko dorazí: parallax len vodorovne, zvislý faktor
nechať 1,0 pre všetky vrstvy.** Kamera chodí hore-dole a keby sa palisáda
posúvala zvislo inak než zem, prestane sedieť s hornou hranicou poľa.
Vodorovný parallax dáva celý efekt; zvislý pridá málo a rozbije mapovanie.

Pri týchto dvoch pravidlách je obmedzenie #1 vybavené a nie je sa čoho báť.

### Ako to postaviť, aby sa dal počet vrstiev testovať

Vrstvy majú byť **údaj, nie kód** — pole `{textúra, faktor}`. Pridanie vrstvy
je potom jeden riadok a otázka „stačí jedna alebo treba tri" sa zodpovie
pohľadom na telefón, nie prestavbou. Godot 4.7 má na to `Parallax2D`, ktorý
vie aj opakovanie.

Testovacia zostava:
1. dnešný stav (0 vrstiev navyše) — referencia
2. + 1 vrstva vzadu (hory/les, faktor ~0,5)
3. + pruh popredia (faktor ~1,3)
4. všetko naraz (3–4 vrstvy)

---

## 4. Odporúčané poradie

1. **Nearest filter** — dve minúty, pozrieť na telefóne. Kým je grafika mäkká
   a nerozhodnutá, môže byť Linear naopak lepší; treba to vedieť, nie hádať.
2. **Rozhodnúť S** (2 alebo 1) a **rozhodnúť P1/P2/P3** pre pozadie. Bez toho
   nemá zmysel vyrábať žiadny nový obrázok.
3. **Parallax na existujúcom `env_03`**, aj keď je len S = 1 — na overenie
   počtu vrstiev a faktorov postačí. Zistí sa tým, koľko vrstiev sa oplatí.
4. **Zapnúť VRAM kompresiu** a zmerať pamäť pred a po.
5. Až potom vyrábať finálne podklady v S = 2.

Bod 3 sa dá robiť hneď a nezávisí od bodu 2 — parallax je o pohybe, nie
o rozlíšení, a faktory zistené na starom obrázku platia aj na novom.

---

## 5. Tvrdé obmedzenia

1. **Vrstva so zemou má parallax faktor 1,0.** Viď §3.
2. **Parallax len vodorovne.** Zvislý faktor 1,0 pre všetky vrstvy.
3. **Hracia plocha sa berie z obrázka** (`BG_WALK_TOP` / `BOTTOM` v `main.gd`),
   a pri každej zmene mierky sa **prepočíta a odmeria**, nie odhadne.
4. **Každá vrstva musí bezšvovo tilovať** a nesmie obsahovať nič výrazné a
   jedinečné — level má 12 000 jednotiek, obrázok 2816.
5. **Nič sa nesmie diať vľavo.** Ambientné objekty smú zľava prilietať,
   hrozby nie.
6. **Kvantizácia na pixel art je posledný a vypnuteľný krok.** Nič sa nesmie
   postaviť tak, že bez nej nefunguje.
7. **Nič o obrázku sa nerozhoduje slovami** — vyrenderovať varianty, mriežka
   (`make_grid.py`), Pavel povie číslo.

## 6. Čo nerobiť

- Nedoostrovať `env_03` filtrom „sharpen" — na obrázku bez pixelovej mriežky
  to spraví halo okolo hrán.
- Nepúšťať parallax a zmenu rozlíšenia v jednom kroku. Nedá sa potom povedať,
  čo pomohlo.
- Negenerovať nové pozadia, kým nie je rozhodnuté S a P1/P2/P3. Inak sa budú
  generovať dvakrát.

## 7. Otvorené — pre Pavla

1. **S = 2, alebo ostať na 1?** (Odporúčanie: 2. Cena je git a pamäť, nie
   práca.)
2. **P1, P2 alebo P3 pre pozadie?** P3 — pozadie z Blenderu — je jediná
   možnosť, ktorá celý problém zavrie natrvalo, a čím skôr sa o nej rozhodne,
   tým menej vygenerovaných pozadí sa zahodí.
3. **Nočná scéna ako hlavné prostredie — zámer?** Tmavý obrázok zhoršuje
   kontrast postáv aj viditeľnosť čohokoľvek ambientného.
