# Slavs fight back – presun na GitHub a do cloudu

Cieľ: Claude pracuje na hre v cloude (nie na tvojom PC), kód je na GitHube.
Na PC ostáva len jedna vec: nasadenie do telefónu cez kábel.

**Ako sa so mnou rozprávaš potom:** v Claude desktop aplikácii (záložka
**Code**, prepínač **Cloud**), alebo v prehliadači na **claude.ai/code**, alebo
v mobilnej aplikácii. Je to tá istá session, dá sa prepínať medzi zariadeniami.

Podľa dokumentácie sú cloud session súčasťou plánov **Pro, Max a Team**.
Neoveril som, či sa na ne vzťahujú tvoje skúšobné kredity – to uvidíš pri
prvom spustení.

---

## Krok 0 – commit (raz, na PC)

Najprv musí byť commitnuté všetko z poslednej session (príkazy sú v správe
od Clauda). Bez toho by sa na GitHub dostal starý stav.

## Krok 1 – súkromný repozitár na GitHube (raz, ~3 min)

HOTOVO 2026-10-03: **github.com/belispav/slavs** (musí byť **Private** a
prázdny – bez README, .gitignore, license).

## Krok 2 – nahrať projekt (raz, na PC, PowerShell, ~5 min)

```
cd "D:\2026\Slavs figh back"
git remote add origin https://github.com/belispav/slavs.git
git push -u origin master
```

Pri prvom `push` vyskočí okno na prihlásenie do GitHubu – prihlás sa.
Projekt má ~350 MB, nahrávanie môže trvať niekoľko minút.
API kľúč PixelLabu (`tools\.pixellab_token`) sa NENAHRÁ – je vylúčený.

## Krok 3 – pustiť Clauda k repozitáru (raz, ~2 min)

1. Otvor **github.com/apps/claude/installations/new**
2. Vyber svoj účet → **Only select repositories** → `slavs` → **Install**.

## Krok 4 – prepojiť Claude s GitHubom (raz)

1. Otvor **claude.ai/code** a prihlás sa svojím Claude účtom.
2. Stránka ťa vyzve na prepojenie GitHubu → potvrď na GitHube.
3. Vytvorí sa prostredie **Default**.

## Krok 5 – nastaviť prostredie (raz, ~5 min)

Na claude.ai/code otvor prostredie **Default** na úpravu (výber prostredia
pri poli na písanie → ikona úprav).

1. **Network access:** zvoľ **Custom**, do **Allowed domains** napíš:
   ```
   *.pixellab.ai
   ```
   a zaškrtni **Also include default list of common package managers**.
2. **API credentials** → pridaj:
   - **Name:** `PixelLab`
   - **Allowed websites:** `api.pixellab.ai`
   - **Custom headers:** Name `Authorization`, Prefix `Bearer`,
     Value = obsah súboru `tools\.pixellab_token` (otvor ho v Poznámkovom
     bloku a skopíruj).
   Kľúč tak Claude používa, ale nikdy ho nevidí.
3. **Setup script:** vlož
   ```
   bash tools/cloud_setup.sh
   ```
   (nainštaluje Godot, aby Claude vedel hru skontrolovať bez telefónu).
4. Ulož.

## Krok 6 – prvá cloud session

1. Desktop aplikácia → **Code** → **Cloud** (alebo claude.ai/code).
2. Vyber repozitár **slavs**, režim **Accept edits**.
3. Prvá správa:
   > Prečítaj CLAUDE.md (časť „Cloud sessions“). Najprv over, že
   > funguje PixelLab (get_balance) a Godot (import projektu). Potom
   > pokračujeme na: …

## Každodenná práca potom

1. Píšeš Claudovi v cloude, on mení kód, kontroluje ho v Godote bez
   obrazovky a nahrá zmenu na GitHub (vetva `master`).
2. Keď ti napíše „nasaď“, na PC spustíš:
   ```
   cd "D:\2026\Slavs figh back"
   git pull
   powershell -ExecutionPolicy Bypass -File tools\deploy_android.ps1
   ```
3. Otestuješ a napíšeš mu výsledok.

**Zmena oproti doterajšku:** commit vzniká pred tvojím testom (inak sa zmena
na PC nedostane). Ak test zlyhá, Claude opraví ďalším commitom.

## Čo ostáva lokálne a nejde na GitHub

- `tools\.pixellab_token` (kľúč), `export_presets.cfg` (nastavenie exportu
  do Androidu), veľké referencie v `ref\`, priečinok `render\`.
- Desktop aplikácia na PC teraz nie je potrebná – len Git a deploy skript.
