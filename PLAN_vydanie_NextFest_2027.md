# Plán vydania: Steam Next Fest február 2027 (návrh 2026-10-12)

Stav: **predbežne schválené Pavlom 2026-10-12.** Body v časti „Na rozhodnutie“ sú otvorené.
Kým ich Pavel neuzavrie, v `PLAN_hry.md` platí pôvodný plán a tento súbor je návrh, ktorý ho má nahradiť.
Pripravené v session o marketingu a monetizácii. Prehľad 65 možností marketingu, virality a monetizácie
(kódy R01–R07, M01–M36, P01–P22) je v dashboarde: https://claude.ai/artifact/KzDZLCw7TSZr5ufxqNAP4U

## Posolstvo a pravidlá komunikácie

- Téma marketingu: **satira na politikov, ktorí pred voľbami sľubujú a sľuby neplnia** (ľudia majú pocit, že ich nikto nepočúva).
- **Žiadny imigračný rámec** v príbehu ani v marketingu (Pavel 2026-10-12). Nepriatelia sú roly (nájazdníci, domobrana, garda), nie zástupcovia dnešných ľudí alebo skupín.
- Platí `PLAN_hry.md` kap. 2 bez výnimky: nepriateľ = rola, nie etnikum; žiadne „my proti nim“. Od 15. 10. aj §2 príbehu (`20261015 - Handoff Slavs fight back.md`).
- V textoch, tagoch a reklamách nikdy výraz „mass shooter“. Používať: run-and-gun, akčná strieľačka, horde shooter.
- Satira mieri na moc a sľuby (napr. Kamenná rada), nie na žiadnu reálnu osobu, stranu ani skupinu.

## Navrhovaný model monetizácie (rieši T10)

| Kde | Model | Cena | Poznámka |
|---|---|---|---|
| Steam (PC) | platená hra | 9,99 € | pred vydaním bezplatné demo na Next Feste |
| Android | prvá časť zadarmo + jednorazové odomknutie celej hry | 4,99 € | bez reklám; v `NAPADY_vylepsenia.md` je to možnosť Z3 |
| Web | bezplatné demo (to isté ako na Steame) | 0 € | odkaz z videí rovno do hry; Godot web export treba overiť |
| Po vydaní | platené rozšírenia (pokračovanie príbehu / kapitoly) | ~2,99 € | zhoda s `PLAN_hry.md` 6.5 (pokračovanie príbehu) |

Jeden obsah (prvá časť hry) slúži ako Steam demo, web demo aj bezplatná časť na Androide.
Odhad (návrh 2026-10-12, predpoklady, nie predpoveď): pri 10 000 kupujúcich na mobile a 5 000 na PC ~58 000 € pred daňou;
na kus zostane ~3,5 € (mobil 5 €) a ~4,5 € (Steam 10 €).

## Míľniky (kódy PL sú stále)

Pevné termíny (nedajú sa posunúť) sú označené **!**.

| Kód | Do | Úloha | Hotové keď |
|---|---|---|---|
| PL01 | 18. 10. 2026 | Rozhodnúť body „Na rozhodnutie“ nižšie | Rozhodnutia zapísané v `CLAUDE.md` a `PLAN_hry.md` |
| PL02 | 25. 10. 2026 | Ovládanie pre PC (klávesnica + myš, gamepad) ako samostatná vrstva vedľa dotyku; overiť export PC + web. Mení ovládanie → Opus session, `SPEC_ovladanie_implementacia.md` zostáva zdroj pravdy | Testovací level beží na PC, Androide aj v prehliadači |
| PL03 | 31. 10. 2026 | Steamworks (Steam Direct 100 USD, vráti sa po 1 000 USD tržieb) + Google Play Console (25 USD) | Oba účty overené |
| PL04 | 22. 11. 2026 | Vertical slice = fáza F2 z `PLAN_hry.md`: 1 level vo finálnej grafike. Predtým T17 (paleta) | Level vyzerá a hrá sa ako finálna hra |
| PL05 | od 23. 11. 2026 | 3 krátke videá týždenne (TikTok, Shorts, Reels, X), sobota Reddit Screenshot Saturday; strih cez AI | Pravidelne vonku |
| PL06 **!** | 6. 12. 2026 | Verejná Steam stránka „Coming soon“ (kapsula, 5 screenshotov, 30 s teaser, popis EN + SK/CZ, sekcia o AI obsahu). Kontrola Steamu 1–5 dní → odoslať do 1. 12. | Dá sa pridať do zoznamu prianí |
| PL07 | 6. 12. 2026 | Discord s pravidlami a automatickou moderáciou, e-mailový zoznam | Odkazy na Steam stránke a pod videami |
| PL08 **!** | 10. 1. 2027 | Registrácia na Next Fest v Steamworks | Potvrdené |
| PL09 | 17. 1. 2027 | Demo (20–30 min) hotové, končí háčikom; preklad | Demo sa dá dohrať bez chýb |
| PL10 | 25. 1. 2027 | Demo + stránka na Press Preview; trailer do 18. 1. | Odoslané |
| PL11 **!** | 8. 2. 2027 | Všetko pre Next Fest schválené; press kit; demo streamerom (Keymailer) a e-maily 100 tvorcom | Schválené, odoslané |
| PL12 **!** | 22. 2.–1. 3. 2027 | Next Fest: demo na Steame + web demo + predregistrácia Google Play. **Demo nikde nezverejniť pred 22. 2.** | Spätná väzba spísaná |
| PL13 **!** | podľa variantu | Plná hra (F3 + F4) + uzavretý test Google Play 12 testerov × 14 dní | Test beží |
| PL14 **!** | podľa variantu | Vydanie Steam + Android, web demo zostáva | V predaji |
| PL15 | po vydaní | Prvé rozšírenie; Letný výpredaj Steamu 24. 6.–8. 7. 2027 (hra vonku min. 30 dní); iOS až keď Android zarába | Vonku |

### Varianty termínu vydania (na rozhodnutie)

- **A — vydanie 8. 4. 2027:** plná hra do 15. 3. 2027. Pri dnešnom stave (balík 4, prototypy, T17 pred finálnou grafikou, treba 8 typov nepriateľov a 3 bossov) veľmi tesné.
- **B — Next Fest február, vydanie máj–jún 2027:** reálnejšie; zoznamy prianí z festivalu čiastočne vychladnú.
- **C — Next Fest jún 2027 (14.–21. 6.), vydanie júl–august 2027:** najviac času; registrácia na jún treba overiť v Steamworks.

Pravidlá Next Festu: vydanie až po skončení festivalu; Steam stránka musí byť verejná; demo hrateľné od začiatku festivalu;
obsah už dostupný zákazníkom (napr. vydaný prológ) sa nemusí uznať ako demo; každá hra môže ísť na Next Fest len raz.

## Na rozhodnutie (Pavel)

| Téma | Doteraz v súboroch | Návrh 2026-10-12 |
|---|---|---|
| Model | premium 5,99 €, bez nákupov a reklám (`PLAN_hry.md`, `CLAUDE.md`); T10 odložené | tabuľka vyššie |
| Poradie platforiem | najprv Android, Steam 2–4 mesiace po vydaní, iOS o 9–12 mesiacov | Steam demo vo februári, Steam a Android naraz |
| Cena Steam | 5,99–7,99 € | 9,99 € |
| Demo | — | Akt I (príbeh v5: Akt I ide na mobile zadarmo) |
| Jazyky | EN + SK pri vydaní | EN + SK + AI preklad 5–7 jazykov EÚ |
| Google Play účet | odložený (T08, F4) | založiť do 31. 10. 2026 |
| Termín vydania | ~6 mesiacov popri práci | variant A, B alebo C |

## Zdroje

- Steam Next Fest február 2027, termíny: https://www.steampageanalyzer.com/blog/steam-next-fest-february-2027 a https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/feb_2027
- Steamworks onboarding (21 dní po poplatku, 2 týždne „coming soon“, kontrola 1–5 dní): https://partner.steamgames.com/doc/gettingstarted/onboarding
- Google Play, test 12 testerov × 14 dní: https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB
- Steam výpredaje 2026–2027: https://partner.steamgames.com/doc/marketing/upcoming_events?l=english
