# VOLYA — Kompletný plán hry, business case a stratégia nasadenia

**Pracovný názov:** VOLYA (staroslovanské „sloboda/vôľa"; alternatívy: OKOVY, SAQALIBA)
**Žáner:** 2D side-scrolling run-and-gun / horde shooter (štýl Metal Slug)
**Platforma:** Android (v1.0), neskôr iOS a Steam
**Model:** Premium 5,99 € pri launchi, bez IAP; DLC a kozmetika neskôr
**Tvorca:** 1 osoba, vývoj s pomocou AI, nulová predchádzajúca znalosť game devu
**Dátum dokumentu:** 19. 7. 2026

---

## 1. Zhrnutie (Executive Summary)

Hra o slovanskom otrokovi, ktorý sa prebije na slobodu cez hordy otrokárov. Extrémne jednoduché dvojpalcové ovládanie (podľa priloženej špecifikácie „Zero Thumb-Lifting"), prepálená absurdná akcia, krátke levely na mobilné sessions. Historicky ukotvené v reálnom obchode so slovanskými otrokmi (9.–18. storočie) — čo je zároveň najväčšie marketingové aktívum aj najväčšie riziko projektu.

Kľúčové rozhodnutia tohto plánu:

- **Engine: Godot 4.7** — zadarmo, ľahký, výborný pre 2D, AI nástroje ho poznajú dokonale.
- **Prvá éra: 9.–10. storočie** (obchodné cesty Volga/Dneper) — nepriateľské frakcie sú historicky presné a etnicky rôznorodé (Varjagovia, Chazari, stepní nájazdníci, arabskí obchodníci), čo je fakticky správne a zároveň jediná cesta cez schvaľovací proces storov.
- **Monetizácia: premium 5,99 €**, žiadne IAP vo verzii 1.0. DLC kampane (nové éry = noví otrokári) a kozmetické balíky až po validácii. Žiadna gacha, žiadne reklamy — v platenej hre by generovali „anger factor" (viď vlastná analýza, kap. 4.5 a 6).
- **Časový plán: ~6 mesiacov part-time** do launchu na Google Play.
- **Break-even: ~160 predajov.** Realistický scenár prvý rok: 2 000–4 000 predajov ≈ 9 000–18 000 € hrubého príjmu pre teba.

---

## 2. Citlivá téma: fakty a nepriestrelné pravidlá

Toto je najdôležitejšia kapitola. Tvoj koncept („bieli otroci vs. primárne arabskí a africkí otrokári") v doslovnej podobe **neprejde** cez Google Play a Apple. Obe platformy majú politiku proti obsahu, ktorý démonizuje etnickú alebo náboženskú skupinu; hra, kde je nepriateľ definovaný rasou, bude klasifikovaná ako hate content a odstránená — bez ohľadu na historickú presnosť argumentácie.

Riešenie nie je tému opustiť, ale definovať nepriateľa **rolou a frakciou, nie etnikom**. A tu hrá história v tvoj prospech, lebo obchod so slovanskými otrokmi (tzv. saqaliba) bol multietnický biznis:

| Éra | Frakcia otrokárov | Historický základ |
|---|---|---|
| 9.–10. stor. (v1.0) | Varjagovia (Vikingovia), Chazari, stepní nájazdníci, strážcovia arabských karaván | Volžská a dneperská obchodná cesta, trh v Itile a Bulgare |
| 10.–12. stor. (DLC) | Benátski a janovskí obchodníci, Byzancia | Stredomorské trhy, Kaffa |
| 15.–17. stor. (DLC) | Krymský chanát, Nogajci, Osmani | „Žatva stepi", odhadom 2+ mil. odvlečených z Ukrajiny/Ruska/Poľska |
| 16.–18. stor. (DLC) | Barbarskí korzári | Nájazdy na pobrežia Európy, otroci v Alžíri a Tunise |

Všimni si: v1.0 začína érou, kde hlavní otrokári sú **Vikingovia a Chazari** — teda prevažne „bieli". To je historicky korektné (Varjagovia boli najväčší dodávatelia slovanských otrokov na východné trhy) a úplne to rozbíja obvinenie z rasovej agendy. Arabskí, tatárski a osmanskí otrokári prídu neskôr ako súčasť historickej progresie, keď už hra bude mať etablovanú reputáciu „historickej akčnej hry".

**Nepriestrelné pravidlá (nikdy neporušiť):**

1. Nepriatelia sú vždy pomenovaní rolou/frakciou: „otrokár", „nájazdník", „dozorca", „korzár", „karavánová stráž" — nikdy etnikom.
2. Civilisti danej kultúry sa v hre nezabíjajú a ideálne sa v nej vyskytujú aj pozitívne postavy z každej kultúry (napr. arabský kupec, ktorý hrdinovi pomôže — historicky doložené prípady vykúpenia otrokov).
3. Marketing nikdy nepoužije rasový frame. Slogan je „otrok proti otrokárom", „cesta na slobodu" — nie „my proti nim". Kontroverzia „biely otrok" sa v komunikácii nepoužíva ani ako clickbait; internet si ju vygeneruje sám a hra musí byť v tej chvíli obhájiteľná obsahom.
4. Do hry patrí krátky historický kontext (1 obrazovka na začiatku kampane + odomykateľný „kódex" s faktami a zdrojmi). Lacné na výrobu, obrovská hodnota pri obhajobe hry aj v PR.
5. Žiadne náboženské symboly v roli terčov.

Toto nastavenie zachováva plný emocionálny náboj (skutočná, málo známa história, silný pocit zadosťučinenia) a znižuje riziko odstránenia zo storu z „takmer isté" na „bežné riziko akčnej hry". Rating bude PEGI 16 (násilie) — s pixel-art štylizáciou bez realistického gore to je bezpečné pásmo.

---

## 3. Popis hry (Game Design)

### 3.1 Fantázia hráča

„Som otrok, ktorý pretrhol reťaze, a teraz sa cez hordy otrokárov prebíjam na slobodu — a beriem so sebou každého otroka, ktorého cestou oslobodím." Jadro pocitu: masívna, absurdná, prepálená akcia. Desiatky nepriateľov na obrazovke, všetko vybuchuje, hráč sa cíti ako nezastaviteľná sila. Žiadne komplexné súboje, žiadny stealth, žiadne puzzle.

### 3.2 Core loop (30–60 s)

Bež doprava → koss hordy → osloboď otrokov v klietkach (= skóre/mena) → naplň „Hnev" → aktivuj rage mód (screen-clear) → mini-boss → koniec levelu → utrať korisť na upgrade → ďalší level.

### 3.3 Ovládanie

Presne podľa priloženej špecifikácie „Zero Thumb-Lifting" — bez zmien, je kompletná a implementovateľná:

- Pravý palec: virtuálny joystick mierenia, auto-attack počas mierenia.
- Ľavý palec: beh + skok cez Y-prahovú zónu s tromi kritickými UX prvkami: **oblúková hranica** („windshield wiper"), **reset skoku** návratom do Run Zone, **plávajúca kotva** (dynamický stred podľa položenia palca).
- Implementácia ovládania je **prvý míľnik projektu** (fáza 1) a testuje sa na reálnom telefóne skôr, než sa postaví čokoľvek iné. Ak ovládanie nesedí, nič ostatné nemá zmysel.

### 3.4 Zbrane a akcia (éra 9.–10. stor.)

Historické jadro + absurdné prepálenie (presne v duchu Metal Slug, ktorý tiež nebol simulátor):

- **Základ:** sekera (hod, vracia sa ako bumerang), luk (rýchlostreľba ako guľomet), oštepy, kladivo (AoE).
- **Prepálené power-upy:** „Perúnov hnev" (blesky z neba), horiaci sud, stádo splašených koní naprieč obrazovkou, obliehacia balista na rameno.
- **Rage mód „VOLYA":** naplní sa oslobodzovaním otrokov; postava na 8 s zoserie celú obrazovku. Toto je hlavný dopamínový moment hry.
- Nepriatelia umierajú vo veľkom a rýchlo (1–3 zásahy bežný mob), na obrazovke ich je 15–30 naraz. Hitboxy štedré v prospech hráča.

### 3.5 Štruktúra obsahu v1.0

- **12 levelov** (3 svety × 4 levely: Osada v plameňoch → Riečna cesta → Trh v Itile), každý 2–4 minúty.
- **8 typov nepriateľov** + 3 bossovia (varjažský jarl na drakkare, chazarský beg s jazdou, obchodný magnát na trhu).
- **Meta-progresia:** oslobodení otroci = mena; strom vylepšení (zbrane, zdravie, rage). Dôvod na opakovanie levelov.
- **Endless aréna** („Jama") — 1 mapa, nekonečné vlny, leaderboard lokálny. Lacný obsah s vysokou hernou hodnotou.
- Pixel art, 16-bit štylizácia — najlacnejšia na AI-asistovanú výrobu a žánrovo očakávaná.

### 3.6 Čo v hre zámerne NIE JE (efektivita)

Príbehové cutscény (len textové karty), dabing, multiplayer, online služby, účty, cloud save, viac jazykov než EN+SK pri launchi. Všetko v addon backlogu (kap. 9).

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
| **F3 — Produkcia obsahu** | 7–8 týž. | 12 levelov, 8 nepriateľov, 3 bossovia, meta-progresia, endless aréna, menu, tutoriál (integrovaný do levelu 1) |
| **F4 — Polish + uzavretý test** | 4 týž. + 14 dní | Balance, výkon (60 fps na 150 € telefóne), IARC dotazník. **Povinný uzavretý test: 12 testerov, 14 súvislých dní** (podmienka nových osobných účtov Google Play). Testerov nabrať v F3 (Reddit r/AndroidGaming, r/playtesters, SK/CZ gamedev Discordy) |
| **F5 — Launch** | 1–2 týž. | Store listing (screenshoty, video, popis), žiadosť o produkčný prístup, staged rollout 20 % → 100 % |

**Celkom: ~6 mesiacov.** Najčastejšie zlyhanie sólo projektov je nafukovanie rozsahu — čokoľvek nad rámec kap. 3.5 ide automaticky do backlogu (kap. 9), nie do v1.0.

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
5. **PR angle:** „málo známa história obchodu so slovanskými otrokmi" je legitímny hák pre médiá (herné aj mainstreamové v SK/CZ/PL/UA). Kódex s historickými faktami (kap. 2) je podklad pre tieto rozhovory.

### 6.5 Monetizačná stratégia dlhodobo

Z tvojej analýzy preberáme, čo je kompatibilné s platenou hrou, zvyšok vedome zahadzujeme:

| Mechanika | Verdikt | Dôvod |
|---|---|---|
| Premium cena 5,99 € | ÁNO (v1.0) | Tvoja preferencia; férové, nulový anger factor |
| DLC kampane (nové éry, ~2,99 €) | ÁNO (rok 1–2) | Prirodzené rozšírenie: noví otrokári = nový obsah = nový príjem od existujúcich hráčov |
| Kozmetické balíky (skiny postavy/zbraní) | ÁNO (po validácii) | Najnižší anger factor, monetizuje fanúšikov navyše |
| Battle pass („sezónna kampaň") | NESKÔR (backlog) | Dáva zmysel až pri 10 000+ aktívnych hráčoch; predtým je to práca bez publika |
| Gacha / lootboxy | NIE | V platenej hre reputačná samovražda + regulačné riziko (Belgicko, Holandsko) |
| Reklamy (aj rewarded) | NIE | Hráč zaplatil; reklamy by zabili recenzie |
| Pay-to-skip | NIE | Anger factor, v single-player premium hre nedáva zmysel |

Psychologické háky z analýzy, ktoré použijeme **bez monetizácie** (na retenciu): denná výzva v endless aréne, meta-progresia (sunk cost v dobrom zmysle), počítadlo oslobodených otrokov ako celoživotná štatistika, náhodné power-up drops v leveloch (variabilná odmena bez peňazí).

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
| Mesiac 6–9 | **DLC 1: „Žatva stepi"** (Krymský chanát, 4 levely, nový boss, 2,99 €) | Prvý test ochoty platiť za obsah |
| Mesiac 9–12 | iOS port (Apple 99 $/rok + cloud Mac build ~20 €/mes.) — len ak Android+Steam validovali dopyt | Rozšírenie trhu |
| Rok 2 | DLC 2 (Barbarskí korzári), kozmetické balíky, prípadne battle pass ak MAU > 10 000 | LiveOps light |

Pravidlo: každé rozšírenie musí prejsť testom „prinesie to hráčov alebo peniaze úmerne námahe?" — inak backlog.

---

## 9. Addon backlog (vedome odložené)

Nápady so zlým pomerom námaha/prínos pre sólo tvorcu teraz, zaznamenané pre budúcnosť: online co-op a multiplayer (rádovo najdrahšia položka), globálne leaderboardy s účtami, cloud save, battle pass so sezónami, príbehové cutscény/dabing, lokalizácia nad EN+SK (PL/UA/CZ dáva tematicky zmysel ako prvá vlna, DE/FR/ES neskôr), procedurálne generované levely, druhá hrateľná postava, konzolové porty.

---

## 10. Riziká

| Riziko | Pravdepodobnosť | Dopad | Mitigácia |
|---|---|---|---|
| Odmietnutie/odstránenie zo storu pre citlivú tému | Stredná | Fatálny | Kap. 2 dodržať bez výnimky; frakcie nie etniká; v1.0 začína varjažsko-chazarskou érou; historický kódex v hre |
| Mediálna kontroverzia (z oboch strán) | Stredná | Obojsečný | Nekŕmiť; odpovedať vecne historickými zdrojmi; hra musí byť obhájiteľná obsahom, nie vyhláseniami |
| Premium hra sa organicky nepredáva | Vysoká | Vysoký | TikTok/Shorts od F2, demo/Trials, Play Pass, Steam port |
| Ovládanie v praxi nefunguje | Nízka–stredná | Fatálny | F1 ako Go/No-Go míľnik pred akoukoľvek ďalšou investíciou |
| Scope creep / vyhorenie sólo tvorcu | Vysoká | Vysoký | Fixný rozsah v1.0 (kap. 3.5), všetko navyše do backlogu; malé týždenné míľniky |
| AI-generovaný kód sa stane neudržiavateľným | Stredná | Stredný | Git od 1. dňa, malé úlohy, týždenný refactor |
| Neprejdenie 12-testerov/14-dní testu | Nízka | Odklad | Nábor 15–20 testerov s rezervou už vo F3, denné pripomienky testerom |

---

## 11. Prvé tri kroky (tento týždeň)

1. Založ Google Play developer účet (overenie trvá dni až týždne — kritická cesta).
2. Nainštaluj Godot 4.7 + Android export šablóny, sprav „Hello world" build na svoj telefón (návod ti dám krok za krokom).
3. Začni F1: prines mi priloženú špecifikáciu ovládania a spravíme z nej prvý funkčný prototyp.
