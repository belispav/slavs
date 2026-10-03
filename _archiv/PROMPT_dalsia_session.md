# Prompt pre ďalšiu cowork session (stačí Sonnet)

Skopíruj celý text nižšie ako prvú správu v novom coworku nad priečinkom
`D:\2026\Slavs figh back`.

---

Pracujeme na Slavs. Prečítaj si `CLAUDE.md` a `PRIKAZY.md` — hlavne sekcie
**METHOD** a **ZBRANE**, tie sú pre túto session kľúčové.

Táto session má **dva ciele a nič iné**. Ak sa vynorí čokoľvek ďalšie, zapíš to
ako poznámku a nerieš to.

## Cieľ 1 — testovacie prepínače v hre (rob ich ako prvé)

Nedá sa prezerať grafika, keď sa na mňa valia nepriatelia, zabíjajú ma a hra sa
po chvíli reštartuje. Potrebujem v ladiacom paneli (ten, čo už existuje —
`slavs/scripts/debug_overlay.gd`) tri prepínače:

1. **NESMRTEĽNOSŤ** — hráč nedostáva zranenie
2. **PAUZA** — hra zamrzne, ale ladiaci panel ostáva ovládateľný
3. **VYPNÚŤ TYP NEPRIATEĽA** — zvlášť pre bežcov a zvlášť pre strelcov, aby som
   si mohol pozrieť jeden typ bez toho druhého

Sú to ladiace pomôcky, nie herné funkcie. Nemajú sa dostať do vydanej hry a
nemajú meniť nič v `control_config.tres`.

Keď je to hotové, nasaď to na telefón (`tools\deploy_android.ps1`) a nech to
otestujem, než pôjdeme ďalej. Potom commit.

## Cieľ 2 — bežec (rusher), rovnakou cestou ako gunman

Animácie sú stiahnuté a **overené ako obojručné** (26–44 cm rozostup rúk):

- `ref\characters\Enemy_rusher_02 Great Sword Idle.fbx`
- `ref\characters\Enemy_rusher_02 Great Sword Run.fbx`
- `ref\characters\Enemy_rusher_02 Great Sword Slash.fbx`

Postup je v `PRIKAZY.md`, sekcia ZBRANE. V skratke:

1. `inspect_grip.py` na kontrolu (už raz prešlo, sprav to znova pre istotu)
2. `fit_weapon.ps1` — palicu umiestnim myšou v Blenderi, `save_fit.ps1`
3. `best_frame.ps1` — nech sa snímka na posudzovanie **zmeria**, nevyberá
4. `colour_test.ps1` — farby vyberiem z mriežky
5. `render_enemy.ps1` — všetky tri animácie naraz
6. zapojiť do `enemy.gd` ako RUSHER (gunman je tam už ako THROWER, urob to
   rovnako), nasadiť, otestovať, commit

Zvaž, či použiť našu palicu (`--weapon club`, je v `blender_attach_weapon.py`,
obojručná 1,21 m) alebo stiahnuť lepší model tak ako pri arkebúze. Povedz mi,
čo odporúčaš, a rozhodnem.

## Ako so mnou pracuj

Toto je zapísané v `CLAUDE.md` ako METHOD a stálo nás to celý deň:

- **O obrázku rozhodujem z obrázka.** Neopisuj mi polohu, uhol ani farbu
  slovami a nepýtaj sa, či je to dobré. Vyrenderuj možnosti, poskladaj
  očíslovanú mriežku (`make_grid.py`) a ja poviem číslo.
- **Čísla meraj, nehádaj.** Ak niečo nevidno, zisti prečo meraním, nie ďalším
  odhadom.
- **Skript, ktorý končí vetou „pozri sa na to", musí ten obrázok vyrobiť sám.**
  Nenechávaj to na seba ani na mňa ako ďalší krok.
- Keď narazíš na to isté trikrát bez posunu, povedz to rovno a prepneme na
  Opus. Netlač to ďalej.

## Čo je otvorené a NEriešime tu

- Poloha arkebúzy v gunmanovom idle nie je stopercentná. Necháme, kým to
  neuvidím v hre.
- Turbany a etnické znaky na tuningových artoch — musí sa vyriešiť pred F3,
  nie teraz.
- Repozitár má 345 MB a s každým nepriateľom rastie asi o 50 MB. Skôr či
  neskôr treba Git LFS alebo držať zdrojové modely mimo git. Nie dnes.
