# Úvodný prompt pre session: útoky hrdinu + zničiteľný objekt

Skopíruj všetko medzi čiarami do nového, prázdneho Cowork okna
(odporúčaný model: Opus – mení sa bojový systém, nie len parameter).

---

Projekt Slavs, priečinok `D:\2026\Slavs figh back`.
Prečítaj `CLAUDE.md` (hlavne časť „Art pipeline switched to PixelLab“) a `PRIKAZY.md`.
Komunikuj po slovensky, kód a komentáre po anglicky.

**Téma tejto session: útoky hlavnej postavy a jeden zničiteľný objekt.** Nič iné neotváraj.

## Cieľ
1. Hrdina dostane zbraň a bude útočiť. Dve verzie:
   - **útok na blízko** (zbraň v ruke, zásah pred hrdinom),
   - **útok na diaľku** (hádzaná / strelná zbraň, projektil).
   Medzi nimi sa dá **prepínať v debug paneli** (rovnako ako ostatné ladenie), aby som ich porovnal na telefóne.
2. **Jeden zničiteľný objekt** na scéne (napr. sud, voz, plot, klietka – navrhni), ktorý sa dá rozbiť útokmi hrdinu a viditeľne sa rozpadne.

## Ako postupovať
1. **Najprv sa ma opýtaj na zbrane – jednu otázku naraz**, s tvojím odporúčaním.
   Podľa plánu (`PLAN_hry.md` §3.4) prichádzajú do úvahy sekera (hod, vracia sa ako bumerang),
   luk, oštep, kladivo. Odporuč, čo sa najlepšie hodí na blízko a čo na diaľku.
2. Skontroluj zostatok PixelLabu (`get_balance`) a povedz mi rozpočet celej úlohy
   v generovaniach ešte pred prvým generovaním. Na začiatku tejto úlohy ich bolo 28.
3. Hrdina je PixelLab postava `59fbf845-37c5-4799-bfe9-f1b5e1b67849` (64 px, bočný pohľad).
   Zbraň v ruke skús cez novú **state** tej istej postavy (`create_character_state`),
   aby ostala rovnaká tvár a oblečenie. Ak to nevyjde, povedz mi to skôr, než vygeneruješ novú postavu.
4. **Základný obrázok (hrdina so zbraňou, objekt) mi ukáž na schválenie pred animáciami.**
   Animácie už môžeš robiť sám.
5. Hrdina potrebuje so zbraňou minimálne: postoj, beh, útok na blízko, útok na diaľku.
   Objekt: celý stav + rozbitie (animácia alebo rozbitý stav).
6. Pred zmenou `main.gd` / `tuning.gd` / `debug_overlay.gd` mi daj krátky plán a počkaj na moje áno.
7. Po každej funkčnej zmene: nasadiť → ja otestujem → commit. Nikdy nepokračovať na rozbitom stave.

## Pravidlá, ktoré platia
- Ak je môj pokyn v rozpore so zapísaným pravidlom (napr. obsahové pravidlá pre Google Play),
  **povedz mi to pred akciou** a rozhodnem ja.
- PixelLab postup podľa CLAUDE.md: generuj len smer `east`, zrkadli tam, kde to kód potrebuje,
  jeden spoločný štvorcový canvas pre všetky klipy, tvrdá alfa, v hre celočíselná mierka 2×.
  Šablóna „fight-stance“ je boxerský postoj bez zbrane – pre ozbrojenú postavu použi vlastný popis.
  Úder s jednou snímkou švihu pôsobí príliš rýchlo – rátaj s podržaním snímok.
- Nedotýkaj sa: melee prekrývania nepriateľov, farebnej palety, rozlíšenia/obrysov (uzavreté veci).
- Písať mi po každej úlohe 2–3 vety, čo sa spravilo a prečo. Žiadne prednášky.

---
