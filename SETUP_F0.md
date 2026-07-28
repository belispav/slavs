# VOLYA — F0 setup + ako budeme vyvíjať a testovať

Tento dokument je návod na jedno posedenie. Rob kroky presne v poradí.
Po každom kroku je **Kontrola:** — ak nesedí, nepokračuj, napíš mi čo vypísalo.

---

## 0. Ako budeme pracovať (prečítaj si to, je to dôležitejšie ako inštalácia)

Nepoužívame žiadny špeciálny "game maker" softvér. **Kód píšem ja**, ty ho
spúšťaš a hodnotíš pocit. Konkrétne:

| Kto | Čo robí |
|---|---|
| Ja (Claude) | Píšem GDScript súbory priamo do tohto foldra. Nespúšťam Godot ani telefón — nemám k nim prístup. |
| Ty | Otvoríš projekt v Godote, stlačíš tlačidlo, hráš, povieš čo je zlé. |
| Godot editor | Kompiluje, nahráva do telefónu, zobrazuje chyby. |

**Tri rýchlosti testovania** — používaj vždy tú najrýchlejšiu, ktorá stačí:

1. **PC, F5 (2 sekundy).** Myš = jeden prst, klávesnica ako záloha
   (A/D pohyb, medzerník skok, I/J/K/L mierenie). Na logiku, kolízie, chyby.
   Nedá sa tu overiť cit dvoch palcov — na to je bod 2.
2. **Telefón cez USB, one-click deploy (20 sekúnd).** Toto je hlavný režim
   pre F1. Godot zbuildí APK, nahrá ho a spustí, a logy aj chyby ti pošle
   späť do editora. Toto nastavujeme nižšie.
3. **Ladenie priamo v telefóne bez rebuildu (0 sekúnd).** V hre je debug
   panel s posuvníkmi (J0_MM, K_ARC, HYSTEREZA, RUN_SAT). Cit ovládania
   ladíš prstom počas hrania. Až keď nájdeš dobré čísla, nadiktuješ mi ich
   a ja ich zapíšem natrvalo do `control_config.tres`.

Bod 3 je dôvod, prečo som debug overlay staval ako prvý — bez neho by si
ladil naslepo a stratil dni.

---

## 1. Godot (15 minút)

1. Choď na `https://godotengine.org/download/windows/` a stiahni
   **Godot Engine 4.7.1 — Standard** (NIE .NET/C# verziu, tú nepotrebujeme).
2. Je to ZIP s jedným `.exe`. Rozbaľ ho napr. do `D:\Tools\Godot\`.
   Godot sa neinštaluje, len sa spúšťa.
3. Spusti `Godot_v4.7.1-stable_win64.exe`.
4. V Project Manageri klikni **Import** → **Browse** → vyber súbor
   `D:\2026\Slavs figh back\volya\project.godot` → **Import & Edit**.

**Kontrola:** otvorí sa editor, projekt sa volá VOLYA, vľavo hore v strome
je scéna `Main`. V paneli **Output** dole nesmie byť žiadny červený riadok.

5. Stlač **F5** (alebo tlačidlo Play vpravo hore).

**Kontrola:** otvorí sa okno hry — sivá postava na tmavom podklade, tri
plošiny, štyri červenkasté pohyblivé terče, vľavo hore biely debug text,
vpravo hore panel s posuvníkmi. Skús A/D, medzerník, I/J/K/L. Potom podrž
ľavé tlačidlo myši v ľavej polovici okna a ťahaj hore — má sa nakresliť
zelený oblúk a postava skočiť.

Ak toto funguje, **prvá hrateľná verzia beží**. Zvyšok návodu je o telefóne.

---

## 2. Android toolchain (45–60 minút, robí sa raz za život)

### 2a. JDK 17

1. `https://adoptium.net/temurin/releases/?version=17` → **Windows x64 → JDK → .msi**.
2. Nainštaluj s predvolenými voľbami. Zapamätaj si cestu, štandardne
   `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`.

**Kontrola:** otvor PowerShell a napíš `java -version` → vypíše `17.x`.

> Godot 4.7 vyžaduje **OpenJDK 17**. Novšie JDK síce často fungujú, ale
> nemiešaj to — 17 je odporúčaná verzia a chyby s Gradle sú inak neriešiteľné.

### 2b. Android SDK

Najjednoduchšia cesta je Android Studio — nebudeš v ňom pracovať, ide len
o SDK, ktoré prináša.

1. `https://developer.android.com/studio` → stiahni a nainštaluj.
2. Pri prvom spustení nechaj **Standard** setup, nech si stiahne SDK.
3. Po dokončení: **More Actions → SDK Manager → SDK Tools** a zaškrtni
   **Android SDK Platform-Tools** (verzia 35.0.0 alebo vyššia) a
   **Android SDK Build-Tools**. Apply.
4. Zapamätaj si SDK cestu, štandardne
   `C:\Users\belis\AppData\Local\Android\Sdk`.

**Kontrola:** v PowerShelli
`C:\Users\belis\AppData\Local\Android\Sdk\platform-tools\adb.exe version`
→ vypíše verziu.

### 2c. Prepojenie s Godotom

1. V Godote: **Editor → Editor Settings → Export → Android**.
2. **Java SDK Path** = cesta k JDK 17 (koreň, nie `bin`).
3. **Android SDK Path** = `C:\Users\belis\AppData\Local\Android\Sdk`.
4. **Debug Keystore** nechaj prázdne — Godot si vytvorí vlastný.
   Ak by hlásil chybu, vytvor si ho ručne (PowerShell v priečinku `volya`):

   ```
   & "C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\bin\keytool.exe" `
     -keyalg RSA -genkeypair -alias androiddebugkey -keypass android `
     -keystore debug.keystore -storepass android -validity 9999 `
     -dname "CN=Android Debug,O=Android,C=US" -deststoretype pkcs12
   ```
   a jeho cestu vlož do poľa Debug Keystore.

5. **Editor → Manage Export Templates → Download and Install**
   (cca 800 MB, chvíľu to trvá).

**Kontrola:** v Editor Settings pri Java SDK Path aj Android SDK Path
nie je červený výkričník.

### 2d. Export preset

1. **Project → Export… → Add… → Android**.
2. V sekcii **Package → Unique Name** nastav `sk.pavel.volya`.
3. Nič iné zatiaľ nemeň. Zavri okno (preset sa uloží sám).

---

## 3. Telefón a one-click deploy

1. V telefóne: **Nastavenia → Informácie o telefóne** → 7× ťukni na
   **Číslo zostavy (Build number)** → objaví sa "Ste vývojár".
2. **Nastavenia → Systém → Možnosti pre vývojárov** → zapni
   **Ladenie cez USB (USB debugging)**.
3. Pripoj telefón káblom, v notifikácii zvoľ režim **Prenos súborov (MTP)**.
4. Na telefóne potvrď dialóg **Povoliť ladenie cez USB?** → zaškrtni
   "vždy povoliť z tohto počítača" → OK.

**Kontrola:** `C:\Users\belis\AppData\Local\Android\Sdk\platform-tools\adb.exe devices`
→ vypíše riadok so sériovým číslom a slovom `device`
(ak píše `unauthorized`, nepotvrdil si dialóg v telefóne).

5. V Godote sa vpravo hore, vedľa tlačidla Play, objaví **ikona Androidu**
   s názvom tvojho telefónu. Klikni na ňu.

**Kontrola:** hra sa sama nainštaluje a spustí v telefóne. V paneli
**Output** v Godote bežia logy priamo z telefónu — `print()` z kódu,
chyby aj zásobník. Toto je náš pracovný cyklus na celý zvyšok projektu.

> **Bonus — bez kábla.** Keď to raz funguje cez USB, môžeš prejsť na
> bezdrôtové: `adb tcpip 5555`, potom `adb connect IP_TELEFONU:5555`
> (IP nájdeš v Nastavenia → Wi-Fi → detail siete). Ostane to platné do
> reštartu telefónu. Na dlhé ladiace session je to pohodlnejšie.

---

## 4. Git (10 minút, nepreskakuj)

1. Nainštaluj **Git for Windows** z `https://git-scm.com/download/win`
   (predvolené voľby).
2. PowerShell:

   ```
   cd "D:\2026\Slavs figh back"
   git init
   git add .
   git commit -m "F0: Godot project + F1 control prototype scaffold"
   ```

Odteraz po každej funkčnej zmene commit. Keď niečo rozbijeme, vrátiš sa
jedným príkazom namiesto toho, aby sme prišli o deň práce.

---

## 5. Ako testujeme F1 (protokol pre GO/NO-GO)

Testuj **v telefóne**, na PC sa cit dvoch palcov overiť nedá.

1. Hraj **10 minút v kuse** (SPEC PART C, bod 1). Nesnaž sa hrať dobre,
   snaž sa hrať prirodzene.
2. Sleduj počítadlo **SKOKY** vľavo hore. Po skončení porovnaj s tým,
   koľkokrát si skočiť *chcel*. Zapíš si:
   - koľko skokov nastalo nechcene,
   - koľkokrát si chcel skočiť a nestalo sa nič.
3. Otestuj **oblúk**: to isté, ale s palcom vysunutým čo najviac doľava
   a potom čo najviac doprava. Práve tam sa lacné riešenia rozpadnú.
4. Otestuj **reťaz** bez zdvihnutia palca: beh → skok → korekcia vo
   vzduchu → dopad → potiahnutie dole → ďalší skok.
5. Otestuj **súbeh**: strieľaj do terčov 360° pravým palcom, kým ľavým
   bežíš a skáčeš.
6. Keď niečo nesedí, **nepíš mi hneď** — najprv pohni posuvníkom:
   - skáče samo od seba → zväčši `J0_MM`,
   - musíš ťahať príliš vysoko → zmenši `J0_MM`,
   - pri krajnej polohe palca skáče/neskáče → mení sa `K_ARC`,
   - druhý skok sa nedá vyvolať / vyvolá sa sám → `HYSTEREZA_MM`,
   - postava je príliš citlivá / lenivá do strán → `RUN_SAT_MM`.
7. Nadiktuj mi finálne čísla + čo stále nesedí. Ja to zapíšem do konfigu
   a opravím kód.

**Kritérium GO:** body 1–4 zo SPEC PART C splnené po ladení.
**Kritérium NO-GO:** ani po ladení sa nedá dosiahnuť nula nechcených
skokov → zastavujeme a prerábame ovládanie, nie level dizajn.

---

## 6. Keď niečo nejde

| Symptóm | Príčina / riešenie |
|---|---|
| `adb devices` píše `unauthorized` | Nepotvrdený dialóg v telefóne. Odpoj/pripoj kábel. |
| Ikona Androidu sa v Godote neobjaví | Zlá cesta k SDK v Editor Settings, alebo telefón nie je v `adb devices`. |
| Build padne na Gradle chybe | Skoro vždy zlá verzia JDK. Over `java -version` = 17. |
| Hra beží, ale ovládanie nereaguje | Pošli mi obsah panelu Output. |
| Skoky sa počítajú, ale postava neskáče | Postava nie je na zemi — správanie je zámerné, skok vo vzduchu neexistuje. |
| Nízke FPS | Napíš mi číslo z debug HUD a model telefónu. |

---

Zdroje: [Godot 4.7 — Exporting for Android](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html),
[Godot download](https://godotengine.org/download/windows/),
[Adoptium Temurin JDK 17](https://adoptium.net/temurin/releases/?version=17),
[Android Studio](https://developer.android.com/studio)
