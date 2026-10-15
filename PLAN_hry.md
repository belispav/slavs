# Slavs fight back — plán hry, business case a stratégia nasadenia

**Názov:** Slavs fight back (pracovne „Slavs"; Pavel 2026-10-03, potvrdené 2026-10-15)
**Žáner:** 2D side-scrolling run-and-gun (štýl Metal Slug) + roguelite score-attack
**Platforma:** Android (Google Play), offline, jeden hráč; Steam podľa plánu vydania
**Jazyk v hre:** angličtina (dialógy, UI, kódex); slovenčina len v dizajnových dokumentoch
**Model:** pôvodne premium 5,99 € bez IAP; návrh 2026-10-12 (Akt I zadarmo na mobile + odomknutie) je v `PLAN_vydanie_NextFest_2027.md`, otvorené body T53
**Tvorca:** 1 osoba, vývoj s pomocou AI, nulová predchádzajúca znalosť game devu
**Dátum dokumentu:** 19. 7. 2026, kap. 1–3 prepísané 15. 10. 2026

> **2026-10-15 — nový príbeh.** Kapitoly 1–3 sú prepísané podľa príbehu v5
> (`20261015 - Handoff Slavs fight back.md` + HTML dashboardy príbehu a mien v koreni).
> Pri rozpore platí príbeh, okrem ovládania a už nameraných hodnôt v hre (tie platia
> podľa `SPEC_ovladanie_implementacia.md` a `CLAUDE.md`). Starý plán (otrok proti
> otrokárom, éry, 12 levelov) je v `_archiv/pribeh_stary/PLAN_hry_do_2026-10-15.md`.

---

## 1. Zhrnutie (Executive Summary)

Fiktívna feudálna stredná Európa, ~1420–1480. **Vlad** sa objaví z ničoho v horiacej
dedine, nevie, kto je, a zasiahne. Tri akty, **9 levelov + hrateľný epilóg**:
Akt I nájazdníci (jasné zlo), Akt II zákon Kamennej rady vymáhaný vlastnými susedmi,
Akt III zmiešaná garda a odhalenie, komu Rada slúži. Akt I vychádza na mobile zadarmo.

Jadro: jedna mechanika **Záchrana** v troch podobách (ľudia → živobytie → pravda),
roguelite behy z dediny, dedina ako trvalá meta-progresia, výstroj namiesto štatistík.
Dvojpalcové ovládanie bez skákania, prepálená akcia, krátke behy (2–4 min).

Platí ďalej: **Godot 4.7**, cieľ 60 fps na ~150 € telefóne, ~6 mesiacov part-time,
nízky break-even (kap. 6). Detail príbehu, postáv, levelov a scén: príbehový súbor.

---

## 2. Citlivá téma: pravidlá (nikdy neporušiť)

Platí **10 pravidiel z §2 príbehu** bez výnimky (nepriateľ len politickou, vojenskou
alebo ekonomickou rolou; žiadna skutočná náboženská symbolika, len vymyslená
heraldika; hráč nikdy nezraní necivilistu; žiadne gore, rozčlenenie ani mučenie;
žiadne odkazy na dnešnú politiku; zakázané výrazy; morálna rôznorodosť; disclaimer
pri prvom spustení). K nim naše vlastné:

1. Svet je fiktívny s jasnou paralelou na politikov, ktorí neplnia sľuby; nikdy
   skutoční ľudia, strany ani pomenované aktuálne udalosti.
2. **Žiadny imigračný rámec** v príbehu ani v marketingu (Pavel 2026-10-12).
3. Verejné texty nikdy nepoužijú výraz „mass shooter".
4. Rating PEGI 16 (štylizované pixelové násilie).

---

## 3. Popis hry (Game Design)

### 3.1 Fantázia hráča

„Som cudzinec bez minulosti a nedokážem sa pozerať, ako ľuďom berú život, živobytie
a pravdu." Hrdina je vážny, absurdnosť a čierny humor prinášajú svet a nepriatelia,
nikdy hrdina. Desiatky nepriateľov na obrazovke, nepriatelia padajú po 1–3 zásahoch,
hitboxy v prospech hráča. Žiadny stealth, žiadne puzzle.

### 3.2 Core loop

Výprava z dediny → beh doprava, hordy len sprava → **Záchrana** (klietka / voz /
sklad / archív; čím viac zachrániš, tým väčšia odmena) → napĺňa sa rage „VOLYA"
(~8 s, vietor, biele oči, blesky z hrdinu) → vetvenie (ťažšia cesta = viac na
záchranu, silnejší boss, viac zlata) → boss → návrat do dediny: zlato na výstroj
u obchodníka, zachránené veci stavajú dedinu. Smrť = návrat do dediny, zachránené
ostáva.

### 3.3 Ovládanie

Podľa `SPEC_ovladanie_implementacia.md`, ktorý je jediný zdroj pravdy a má prednosť
pred každým nápadom na level alebo scénu: dva palce, voľný pohyb v dvoch osiach,
bez gravitácie a bez skákania, smrteľné hrozby len sprava. **Rift Step** (značka na
zemi → okamžitý presun, bez nového tlačidla) sa odomyká a otvára len voliteľný obsah.

### 3.4 Rozsah v1.0 (podľa príbehu, rozsah ešte otvorený)

- **Akt I – Neznámy (zadarmo):** L1 Horiaca dedina (boss Kapitán nájazdu), L2 Rada
  náčelníkov (boss Radim), L3 Spojené dediny (boss Ordanov veliteľ).
- **Akt II – Zákon:** L4 Vývesná tabuľa (boss Jarek), L5 Les s pascami (boss Bor),
  L6 Zlom (boss Milo). Pomalá erózia sa deje v dedine medzi levelmi.
- **Akt III – Odhalenie:** L7 Garda (boss Miran), L8 otvorený (návrh „Návrat"),
  L9 Majster pisárov (boss Teodor, jediný s mágiou). Potom hrateľný epilóg.
- **Nepriatelia podľa aktu:** Ordanovi nájazdníci → domobrana vlastných dedín →
  zmiešaná garda (odvedení + zaprisahaní).
- **Postup:** zlato → výstroj (brnenie = viac sŕdc; zbrane blízko / na diaľku /
  hádzané s živlom oheň, blesk, ľad) a dedina, ktorá viditeľne rastie.
- **Endless aréna „Jama"** je z pôvodného plánu; príbeh ju nerieši, rozhodne Pavel.
- Pixel art, 2x zväčšenie, celá grafika v PixelLab.

### 3.5 Čo v hre zámerne NIE JE (efektivita)

Filmové cutscény (príbeh nesú textové karty, dedina a hrateľný epilóg), dabing,
multiplayer, online služby, účty, cloud save. Všetko v addon backlogu (kap. 9).

---

## 4. Technológia a AI-asistovaný vývoj

### 4.1 Stack

| Oblasť | Nástroj | Cena | Poznámka |
|---|---|---|---|
| Engine | Godot 4.7 (GDScript) | 0 € | Najlepšia voľba pre 2D sólo dev; AI modely píšu GDScript spoľahlivo; jednoduchý Android export |
| Kód | Claude (Cowork/Claude Code) | existujúce predplatné | Píšeš zadania, AI píše kód; ty sa učíš čítať, nie písať |
| Pixel art | PixelLab / Retro Diffusion + úpravy v Aseprite (~20 €) | ~20–40 €/mes. počas produkcie | AI generuje sprity a animácie, ručne sa len čistia |
| Hudba | Suno / CC0 knižnice | 0–10 €/mes. | 4–5 trackov stačí |
| SFX | CC0 (freesound, Kenney) + ElevenLabs SFX | ~0–20 € | |
| Verzovanie | Git + GitHub (private) | 0 € | Povinné od prvého dňa — AI vývoj bez gitu = strata práce |
| Testovanie | vlastný telefón + Godot remote deploy | 0 € | |

### 4.2 Pracovný postup pre neprogramátora

1. Každú feature zadávaš AI ako samostatnú, malú úlohu („implementuj oblúkovú hranicu jump zóny podľa tejto špecifikácie").
2. Po každej funkčnej zmene: spusti na telefóne → funguje? → git commit. Nikdy nepokračuj na rozbitom stave.
3. Priložený dokument o ovládaní použiješ doslovne ako zadanie pre AI — je napísaný presne tak, ako má vyzerať dobrá špecifikácia.
4. Raz týždenne „refactor deň": necháš AI upratať kód. Inak sa projekt po 3 mesiacoch stane neudržiavateľným.

---

## 5. Plán vývoja (míľniky)

Predpoklad: ~10–15 h/týždeň. Pri full-time deľ časy dvomi.

| Fáza | Trvanie | Výstup / kritérium ukončenia |
|---|---|---|
| **F0 — Setup** | 1–2 týž. | Godot nainštalovaný, „Hello world" beží na tvojom telefóne cez export; Google Play dev účet založený (25 $) — založ HNEĎ, lebo overenie trvá |
| **F1 — Prototyp ovládania** | 3–4 týž. | Šedé obdĺžniky: beh, skok, mierenie, auto-strelba podľa špecifikácie. Kritérium: 10 min hrania bez jediného nechceného skoku. **Go/No-Go bod projektu** |
| **F2 — Vertical slice** | 5–6 týž. | 1 kompletný level s finálnou grafikou, 3 typy nepriateľov, 1 boss, rage mód, zvuk. Kritérium: cudzí človek sa hrá 10 min a baví ho to |
| **F3 — Produkcia obsahu** | 7–8 týž. | Levely a bossovia podľa kap. 3.4 (príbeh), dedina ako meta-progresia, menu, tutoriál (integrovaný do L1) |
| **F4 — Polish + uzavretý test** | 4 týž. + 14 dní | Balance, výkon (60 fps na 150 € telefóne), IARC dotazník. **Povinný uzavretý test: 12 testerov, 14 súvislých dní** (podmienka nových osobných účtov Google Play). Testerov nabrať v F3 (Reddit r/AndroidGaming, r/playtesters, SK/CZ gamedev Discordy) |
| **F5 — Launch** | 1–2 týž. | Store listing (screenshoty, video, popis), žiadosť o produkčný prístup, staged rollout 20 % → 100 % |

**Celkom: ~6 mesiacov.** Najčastejšie zlyhanie sólo projektov je nafukovanie rozsahu — čokoľvek nad rámec kap. 3.4 ide automaticky do backlogu (kap. 9), nie do v1.0.

---

## 6. Business case

### 6.1 Náklady (prvý rok)

| Položka | Suma |
|---|---|
| Google Play účet (jednorazovo) | ~23 € |
| AI art nástroje (~6 mes. produkcie) | ~150–240 € |
| Aseprite, audio, drobnosti | ~50 € |
| Marketingová rezerva (assets, prípadne malá kampaň) | ~200 € |
| **Spolu** | **~450–520 €** |

Tvoj čas (~350–400 h) je hlavná investícia; pri hodnote 15 €/h je to ~5 500–6 000 € imputovaných nákladov — uvádzam pre triezvosť, nie ako výdavok.

### 6.2 Jednotková ekonomika

Cena 5,99 €. Google si od 30. 6. 2026 berie 10 % service fee + 5 % billing fee (EEA/US/UK, do 1 M$ ročne) ⇒ ~15 % efektívne. Z ceny s DPH (Google odvádza DPH kupujúceho): 5,99 € → základ ~4,99 € (DPH ~20 %) → po 15 % poplatku **~4,25 € netto na predaj**. Príjem je zdaniteľný — na Slovensku rieš živnosť/autorské príjmy s účtovníkom pred launchom, nie po ňom.

**Break-even: ~120 predajov** na priame náklady (~160 vrátane rezervy). To je zámerne nízko položená latka — projekt je de facto nezničiteľný finančne; rizikom je len tvoj čas.

### 6.3 Scenáre (1. rok, len Android)

| Scenár | Predaje | Netto príjem | Komentár |
|---|---|---|---|
| Pesimistický | 500 | ~2 100 € | Bez virality, organika Google Play. Najpravdepodobnejší výsledok bez marketingového ťahu |
| Realistický | 3 000 | ~12 750 € | Téma + ovládanie zaujmú niekoľko YouTuberov/TikTok; dobré recenzie |
| Optimistický | 20 000 | ~85 000 € | Virálny moment (téma je naň stavaná), feature od Googlu, PR pokrytie |

Triezvy fakt: premium hry na Google Play sa bez marketingu predávajú zle — organické objavenie platenej hry je takmer nulové. Preto:

### 6.4 Distribučné páky (kritické pre premium model)

1. **Krátke videá (TikTok/YT Shorts/Reels) od fázy F2.** Horde-shooter s desiatkami nepriateľov je ideálny formát na 15 s klipy. Toto je hlavný marketingový kanál, cena 0 €, 2–3 klipy týždenne z vývoja („building my game" formát má vlastné publikum).
2. **Google Game Trials / demo** — Google aktívne tlačí platené hry cez skúšobné verzie; znižuje bariéru 5,99 € naslepo.
3. **Play Pass prihláška** po 3–6 mesiacoch — kurátorovaný katalóg premium hier, historicky silný kanál pre indie tituly (Dead Cells, Slay the Spire).
4. **Steam port** (kap. 8) — premium model funguje na Steame rádovo lepšie ako na mobile; Godot export je takmer zadarmo. Reálne môže Steam prekonať mobilný príjem.
5. **PR angle:** satira na politikov a úradnícku mašinériu vo fiktívnom stredoveku + slovanská mytológia (Perún, búrka) a slovanské mená. Bez imigračného rámca (kap. 2).

### 6.5 Monetizačná stratégia dlhodobo

Z tvojej analýzy preberáme, čo je kompatibilné s platenou hrou, zvyšok vedome zahadzujeme:

| Mechanika | Verdikt | Dôvod |
|---|---|---|
| Premium cena 5,99 € | ÁNO (v1.0) | Tvoja preferencia; férové, nulový anger factor |
| Pokračovanie / DLC (~2,99 €) | ÁNO (rok 1–2) | Príbeh končí dvomi hrozbami (Ordan chce zem, majster chce Zoru) = prirodzené pokračovanie |
| Kozmetické balíky (skiny postavy/zbraní) | ÁNO (po validácii) | Najnižší anger factor, monetizuje fanúšikov navyše |
| Battle pass („sezónna kampaň") | NESKÔR (backlog) | Dáva zmysel až pri 10 000+ aktívnych hráčoch; predtým je to práca bez publika |
| Gacha / lootboxy | NIE | V platenej hre reputačná samovražda + regulačné riziko (Belgicko, Holandsko) |
| Reklamy (aj rewarded) | NIE | Hráč zaplatil; reklamy by zabili recenzie |
| Pay-to-skip | NIE | Anger factor, v single-player premium hre nedáva zmysel |

Psychologické háky z analýzy, ktoré použijeme **bez monetizácie** (na retenciu): denná výzva v endless aréne, meta-progresia (sunk cost v dobrom zmysle), počítadlo zachránených ako celoživotná štatistika, náhodné power-up drops v leveloch (variabilná odmena bez peňazí).

---

## 7. Plán nasadenia (launch checklist)

1. **F0:** Google Play dev účet (overenie identity, ~23 €). D-U-N-S netreba pre osobný účet.
2. **F3:** nábor 15–20 testerov (rezerva nad povinných 12 — testeri odpadávajú a 14 dní musí byť súvislých).
3. **F4:** uzavretý test 14+ dní; testeri musia hru reálne používať (Google od 2026 zamieta žiadosti pre „insufficient testing engagement", nie len pre počet). Priebežne zbieraj feedback na ovládanie.
4. IARC dotazník → čakaj PEGI 16 (násilie). Pravdivo vyplniť; pixel-art štylizácia bez realistického gore.
5. Store listing: 6–8 screenshotov s akciou (nie menu), 30 s video, popis s dôrazom na ovládanie a Metal Slug DNA. Kľúčové slová: run and gun, metal slug style, offline, premium, no ads.
6. Žiadosť o produkčný prístup → staged rollout 20 % → sleduj crash rate (Android vitals) → 100 %.
7. Launch deň: posty na r/AndroidGaming, TouchArcade fórum, SK/CZ herné weby, vlastné TikTok publikum nazbierané počas vývoja.

---

## 8. Plán rozvoja (roadmap po launchi)

| Kedy | Čo | Cieľ |
|---|---|---|
| Mesiac 1–2 | Hotfixy, balance podľa recenzií; odpovedať na KAŽDÚ recenziu | Rating 4,3+ (podmienka feature/Play Pass) |
| Mesiac 2–4 | **Steam port** (5,99–7,99 €) + Steam Deck verifikácia | Druhý, pravdepodobne väčší trh |
| Mesiac 3–6 | Update 1.1 zadarmo: nové zbrane, denná výzva, achievementy | Retencia, recenzie, signál že hra žije |
| Mesiac 4–6 | Prihláška do Play Pass; Game Trials | Distribúcia |
| Mesiac 6–9 | **DLC 1: pokračovanie príbehu** (Ordan alebo portál, podľa príbehu §7; 2,99 €) | Prvý test ochoty platiť za obsah |
| Mesiac 9–12 | iOS port (Apple 99 $/rok + cloud Mac build ~20 €/mes.) — len ak Android+Steam validovali dopyt | Rozšírenie trhu |
| Rok 2 | DLC 2, kozmetické balíky, prípadne battle pass ak MAU > 10 000 | LiveOps light |

Pravidlo: každé rozšírenie musí prejsť testom „prinesie to hráčov alebo peniaze úmerne námahe?" — inak backlog.

---

## 9. Addon backlog (vedome odložené)

Nápady so zlým pomerom námaha/prínos pre sólo tvorcu teraz, zaznamenané pre budúcnosť: online co-op a multiplayer (rádovo najdrahšia položka), globálne leaderboardy s účtami, cloud save, battle pass so sezónami, príbehové cutscény/dabing, lokalizácia nad EN+SK (PL/UA/CZ dáva tematicky zmysel ako prvá vlna, DE/FR/ES neskôr), procedurálne generované levely, druhá hrateľná postava, konzolové porty.

---

## 10. Riziká

| Riziko | Pravdepodobnosť | Dopad | Mitigácia |
|---|---|---|---|
| Odmietnutie/odstránenie zo storu pre citlivú tému | Stredná | Fatálny | Kap. 2 dodržať bez výnimky; fiktívny svet; nepriatelia len rolou; disclaimer pri prvom spustení |
| Mediálna kontroverzia (z oboch strán) | Stredná | Obojsečný | Nekŕmiť; odpovedať vecne historickými zdrojmi; hra musí byť obhájiteľná obsahom, nie vyhláseniami |
| Premium hra sa organicky nepredáva | Vysoká | Vysoký | TikTok/Shorts od F2, demo/Trials, Play Pass, Steam port |
| Ovládanie v praxi nefunguje | Nízka–stredná | Fatálny | F1 ako Go/No-Go míľnik pred akoukoľvek ďalšou investíciou |
| Scope creep / vyhorenie sólo tvorcu | Vysoká | Vysoký | Fixný rozsah v1.0 (kap. 3.4), všetko navyše do backlogu; malé týždenné míľniky |
| AI-generovaný kód sa stane neudržiavateľným | Stredná | Stredný | Git od 1. dňa, malé úlohy, týždenný refactor |
| Neprejdenie 12-testerov/14-dní testu | Nízka | Odklad | Nábor 15–20 testerov s rezervou už vo F3, denné pripomienky testerom |

---

## 11. Prvé tri kroky (tento týždeň)

1. Založ Google Play developer účet (overenie trvá dni až týždne — kritická cesta).
2. Nainštaluj Godot 4.7 + Android export šablóny, sprav „Hello world" build na svoj telefón (návod ti dám krok za krokom).
3. Začni F1: prines mi priloženú špecifikáciu ovládania a spravíme z nej prvý funkčný prototyp.
