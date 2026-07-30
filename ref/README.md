# ref/ — štýlové referencie

Sem ukladaj vygenerované obrázky. Ja ich odtiaľ čítam priamo, netreba ich
nikam nahrávať.

## Rozmery

| Typ | Rozmer | Pomer | Pomenuj ako |
|---|---|---|---|
| Herný záber (hrdina + nepriatelia) | 2400 × 1080 | 20:9 | `gameplay_01.png` |
| Herný záber s davom (6–10 nepriateľov) | 2400 × 1080 | 20:9 | `crowd_01.png` |
| Postava samostatne | 1024 × 1536 | 2:3 | `char_01.png` |
| Prostredie / parallax bez postáv | 2400 × 1080 | 20:9 | `env_01.png` |

Formát PNG. Ak generátor nezvládne 20:9, použi 21:9 (2560 × 1080).

## Prečo 20:9 a nie 16:9

Hra renderuje 1280 × 720 jednotiek, na telefóne sa škáluje na výšku a po
stranách sa odkryje viac — reálne viditeľná plocha je **1600 × 720 jednotiek**,
čo je pomer 20:9.

## Veľkosť postavy — najdôležitejší parameter

Hrdina má zaberať **1/7 výšky obrázka** (pri 1080 px teda 140–160 px).

Na 6,5-palcovom telefóne je postava vysoká **približne 1 cm**. Tak to má aj
Metal Slug. Pri tejto veľkosti je detail fyzicky nevidieľný a rozhoduje
silueta — preto sa referencia s hrdinom na pol obrazovky nedá použiť na
rozhodovanie.

## Do promptu patrí

`orthographic side view`, `side-scrolling game screenshot`,
`camera at character height`, `full body`, `ground line in lower third`

## Do promptu nepatrí

`cinematic`, `dramatic angle`, `close-up`, `portrait`, `epic`, `concept art`

## Ku každému obrázku jednu vetu

Do súboru `poznamky.md` v tomto priečinku napíš k názvu obrázka, čo konkrétne
sa ti na ňom páči: silueta / paleta / obrys / svetlo / textúra / nálada.
Bez toho hádam, a veľmi často je to paleta — a tá je zadarmo.

## Počet

4–8 obrázkov celkovo. Viac referencií neznamená jasnejšie zadanie, znamená
rozmazané zadanie.
