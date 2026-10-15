"""Vytvorí data-v2.json z data.json (1. kolo) + zmeny pre príbehovú hru."""
import json

d = json.load(open("data.json", encoding="utf-8"))

NEW_SRC = {
    "Z54": ["Game Developer – Designing the bleak genius of Papers, Please (L. Pope)", "https://www.gamedeveloper.com/design/designing-the-bleak-genius-of-i-papers-please-i-"],
    "Z55": ["Wikipedia – Papers, Please (predaj, platformy, konce, ocenenia)", "https://en.wikipedia.org/wiki/Papers,_Please"],
    "Z56": ["TouchArcade – Papers, Please na iPhone a Android (2022)", "https://toucharcade.com/2022/07/24/papers-please-iphone-android-release-date-price-free-update-universal-ipad-ios/"],
    "Z57": ["Droid Gamers – Papers, Please na mobile: prerobené rozhranie na výšku", "https://www.droidgamers.com/2022/07/24/papers-please-mobile-portrait/"],
    "Z58": ["GameRevolution – rozhovor s autorom Katana ZERO", "https://www.gamerevolution.com/features/520685-katana-zero-interview"],
    "Z59": ["Wikipedia – Katana Zero (predaj, rozpočet, mobil, DLC, recenzie)", "https://en.wikipedia.org/wiki/Katana_Zero"],
    "Z60": ["3DNews – bezplatné DLC Katana ZERO stále vo vývoji (apríl 2025)", "https://3dnews.ru/1121113/masshtabnoe-dopolnenie-k-katana-zero-vernulos-iz-nebitiya-s-novim-treylerom-ono-vsyo-eshchyo-besplatnoe-i-pochti-gotovo"],
    "Z61": ["PCGamesInsider – Reigns predal 1,8 mil. kópií (rozhovor s autorom)", "https://www.pcgamesinsider.biz/success-story/66428/how-tinder-meets-game-of-thrones-title-reigns-sold-18m-copies/"],
    "Z62": ["Wikipedia – Reigns (mechaniky, text, pokračovania)", "https://en.wikipedia.org/wiki/Reigns_(video_game)"],
    "Z63": ["MCV/Develop – Reigns 600 tis. kópií, hlavne mobil", "https://www.mcvuk.com/business-news/mobile/reigns-becomes-latest-premium-mobile-poster-child-with-over-600000-sales/"],
    "Z64": ["Wikipedia – Beholder (mechaniky, mobil, DLC, pokračovania, recenzie)", "https://en.wikipedia.org/wiki/Beholder_(video_game)"],
    "Z65": ["Wikipedia – Not Tonight (mechaniky, DLC, pokračovanie, recenzie)", "https://en.wikipedia.org/wiki/Not_Tonight_(video_game)"],
    "Z66": ["Malay Mail (AFP) – Not Tonight: autor, tím, reakcie hráčov", "https://www.malaymail.com/news/tech/gadgets/2018/08/24/brexit-nightmare-video-game-shows-grim-vision-of-life-after-eu/1665527"],
    "Z67": ["Wikipedia – Death Road to Canada (preverené, predaj nezverejnený)", "https://en.wikipedia.org/wiki/Death_Road_to_Canada"],
    "Z68": ["Inven Global – INMOST 1,2 mil. hráčov, mobil od 10/2025", "https://www.invenglobal.com/articles/19787/inmost-surpasses-over-1-million-players-as-dark-puzzle-platformer-heads-to-mobile"],
}
d["sources"].update(NEW_SRC)

LESS = "menej vhodné pre príbehovú hru"
# kód -> zmeny (status, nové skóre, poznámka v2, prípadne nový názov / hry / prečo)
UPD = {
 "MCH01": dict(status=LESS, I=2, v2note="V príbehovej akcii hráč mieri sám alebo s pomocou (MCH21). Automatickú streľbu nechaj najviac ako ľahký režim."),
 "MCH02": dict(status=LESS, I=2, v2note="Výber vylepšení pri leveli slúži nekonečným kolám. V príbehu ho nahrádzajú voľby s následkami (MCH43)."),
 "MCH03": dict(status=LESS, I=1, v2note="Zbieranie kryštálov patrí k slučke „survivor“ hier."),
 "MCH04": dict(status=LESS, I=2, v2note="Systém pre opakované kolá; v príbehu stačí pár zbraní pridaných dejom."),
 "MCH05": dict(status=LESS, I=2, v2note="Hazardný efekt truhlíc nesedí na príbehovú hru bez opakovania."),
 "MCH06": dict(status="upravené", name="Kapitola s jasnou dĺžkou na jedno posedenie", I=4,
               what="Úroveň alebo kapitola trvá 5–15 minút a má jasný koniec, dá sa dohrať v MHD.",
               v2note="Z časovača pre opakované kolá sa stala dĺžka kapitoly. Názor: na mobile kratšie úseky."),
 "MCH07": dict(status=LESS, I=2, v2note="Trvalé vylepšenia motivujú opakovať kolá; hráč sa po dohraní príbehu nevracia."),
 "MCH08": dict(status="upravené", name="Malý počet výziev naviazaných na príbeh", I=2, D=1,
               v2note="Namiesto stoviek výziev pár výziev za príbehové voľby (napr. „Splnené sľuby“)."),
 "MCH09": dict(status=LESS, I=2, v2note="Príbeh má dané postavy; náhradou je občasná iná hrateľná postava v úrovni (Katana ZERO) [Z59].", src_add=["Z59"]),
 "MCH10": dict(status="bez zmeny", games_add=["Katana ZERO"], v2note="Platí naplno – pocit zo streľby je to hlavné, čo sa z akčných hier preberá."),
 "MCH11": dict(status="bez zmeny", games_add=["Katana ZERO"],
               why_add=" Autor Katana ZERO chce hru, ktorá je „okamžitá smrť, veľmi ťažká, veľmi zhovievavá“ [Z58].", src_add=["Z58"],
               v2note="Kľúčové pre akčné príbehové hry s ťažkými úsekmi."),
 "MCH12": dict(status="upravené", I=3, games_add=["Katana ZERO"],
               why_add=" Katana ZERO to používa tiež, no na mobile Pocket Gamer kritizoval, že dotyk nestačí na potrebnú presnosť [Z59].", src_add=["Z59"],
               v2note="Na mobile radšej ako voliteľný ťažký režim, nie základ."),
 "MCH13": dict(status="bez zmeny", v2note="Hodnotenie na konci kapitoly sedí na príbehovú hru aj na satiru."),
 "MCH14": dict(status="bez zmeny", games_add=["Katana ZERO"], v2note="Úskok má aj Katana ZERO [Z59].", src_add=["Z59"]),
 "MCH15": dict(status="bez zmeny", games_add=["Katana ZERO"], v2note="Katana ZERO používa nebezpečenstvá v prostredí (lasery) [Z59].", src_add=["Z59"]),
 "MCH16": dict(status="bez zmeny", v2note="Funguje aj v príbehovej úrovni, ale je náročný."),
 "MCH17": dict(status="upravené", name="Záchrana postáv, ktoré sa pridajú k príbehu", I=3,
               v2note="Namiesto náhodnej výmeny postavy: zachránení ľudia sa stávajú súčasťou deja."),
 "MCH18": dict(status="upravené", I=4, v2note="Vyšší vplyv: hra sa má šíriť cez tému, a vtipné názvy sú to, čo ľudia citujú."),
 "MCH19": dict(status=LESS, I=2, v2note="Stovky zbraní sú obsah pre opakované kolá; drahé na výrobu."),
 "MCH20": dict(status="bez zmeny", v2note="Na mobile stále ťažké (dva palce); pozri MCH21."),
 "MCH21": dict(status="upravené", I=5, games_add=["Beholder"],
               why_add=" Ovládanie Beholdera recenzenti chválili ako ľahké aj na telefóne [Z64]; Katana ZERO na mobile kritizovali za dotykové ovládanie [Z59].", src_add=["Z64", "Z59"],
               v2note="Pre akčnú hru na šírku 640×360 najbezpečnejšia voľba ovládania."),
 "MCH22": dict(status="upravené", name="Boss ako vyvrcholenie kapitoly", I=4,
               v2note="Boss nie je časová vlna, ale dramatický vrchol príbehu kapitoly."),
 "MCH23": dict(status=LESS, I=1, v2note="Energia nesedí s jednorazovou cenou ani s príbehom."),
 "MCH24": dict(status=LESS, I=1, v2note="Reklamy nie sú v žiadnom z tvojich troch variantov ceny."),
 "MCH25": dict(status=LESS, I=1, v2note="Bez reklám nie je čo vypínať."),
 "MCH26": dict(status=LESS, I=1, v2note="Vzhľady za peniaze v platenej príbehovej hre majú malý význam."),
 "MCH27": dict(status="upravené", name="Prvá kapitola zadarmo, zvyšok za jednu platbu", I=5, games_add=["Beholder"],
               what="Hráč si zadarmo zahrá prvú kapitolu a zvyšok príbehu odomkne jednou platbou.",
               v2note="Je to jeden z tvojich troch variantov. Beholder na Androide s bezplatnou skúšobnou verziou zarobil 5× viac [Z48]."),
 "MCH28": dict(status="upravené", name="Jednorazová cena bez nákupov v hre", I=4, games_add=["Reigns", "Papers, Please"],
               what="Jedna cena za celú hru, na každej platforme rovnaká alebo podľa platformy.",
               why_add=" Reigns predáva za rovnakú cenu na všetkých platformách, autor to považuje za férové; 80 % predaja mobil [Z61]. Papers, Please vyšiel na mobile ako prémiová hra [Z56].", src_add=["Z61", "Z56"],
               v2note="Tvoj variant: ~5 € mobil, ~10 € PC."),
 "MCH29": dict(status="upravené", name="Príbeh, ktorý streameri radi hrajú", I=4,
               v2note="Pri príbehovej hre platí aj riziko: kto video pozrie, nemusí hru kúpiť (názor). Pomáhajú voľby, ktoré každý hrá inak (MCH43, MCH58)."),
 "MCH30": dict(status="bez zmeny", v2note="Funguje aj pre príbehovú hru (bez prezradenia deja)."),
 "MCH31": dict(status=LESS, I=2, v2note="Spoločná hra je drahá a príbeh je pre jedného hráča."),
 "MCH32": dict(status=LESS, I=1, v2note="Denné výzvy predpokladajú návrat hráča po dohraní."),
 "MCH33": dict(status="bez zmeny", games_add=["Katana ZERO"],
               why_add=" Synthwave hudbu Katana ZERO kritici chválili [Z59]; autor ju viaže na dej – hudba z Walkmanu sa spomalí so spomalením času [Z58].", src_add=["Z59", "Z58"],
               v2note="Hudba nesie príbeh aj identitu."),
 "MCH34": dict(status="bez zmeny", v2note="Platí; tvoj štýl je vlastný, len princíp nostalgie."),
 "MCH35": dict(status="upravené", name="Silný úvod: akcia a téma hneď v prvej minúte", D=2, I=5,
               what="Hra začne akciou a do minúty ukáže tému (prvý porušený sľub).",
               v2note="Namiesto rýchleho nárastu sily: rýchly vstup do príbehu. Názor: pri príbehovej hre o kúpe rozhoduje prvých pár minút."),
 "MCH36": dict(status=LESS, I=1, v2note="Rozhodol si sa pre šírku 640×360."),
 "MCH37": dict(status=LESS, I=2, v2note="Davy tisícov nepriateľov patria k „survivor“ hrám a zaťažujú slabé telefóny."),
 "MCH38": dict(status="upravené", name="Preklad do hlavných jazykov Európy a Ameriky", I=4,
               what="Hra od vydania v angličtine a hlavných európskych jazykoch (nemčina, francúzština, španielčina…).",
               why_add=" Vydanie Reigns sa o týždeň oneskorilo kvôli problémom s prekladmi [Z62].", src_add=["Z62"],
               v2note="Cieľ sa zmenil z Ázie na Európu a Ameriku."),
 "MCH39": dict(status="bez zmeny", v2note="Masky ako „tváre kampane“ sedia na satiru."),
 "MCH40": dict(status="upravené", I=4, v2note="Pri 640×360 a texte v príbehu je čitateľnosť dôležitejšia než v 1. kole."),
}

NEW = [
 {"code":"MCH41","name":"Hráč robí prácu pre moc (je súčasťou systému)","games":["Papers, Please","Not Tonight","Beholder"],"cat":"hlavná slučka",
  "what":"Hráč nie je hrdina, ale „obyčajný“ vykonávateľ (colník, vyhadzovač, domovník), a satiru zažíva cez svoju prácu.",
  "why":"Fakt: Pope chcel hrať za byrokratického inšpektora namiesto hrdinu [Z54]; Not Tonight – vyhadzovač, ktorý pracuje pre autoritársku vládu [Z66]; Beholder – domovník, ktorý špehuje nájomníkov [Z64].",
  "src":["Z54","Z66","Z64"],"D":3,"M":4,"S":5,"sIdea":"Hráč je ochrankár fiktívneho politika a plní jeho „úlohy“ – a na vlastné oči vidí, ako sa sľuby menia na opak.","I":5},
 {"code":"MCH42","name":"Dilemy s osobnou cenou (peniaze, rodina, úplatok)","games":["Papers, Please","Beholder","Not Tonight"],"cat":"hlavná slučka",
  "what":"Správne rozhodnutie hráča niečo stojí – peniaze na nájom, zdravie rodiny, dôveru.",
  "why":"Fakt: dilemy ako manželia s nezhodnými dokladmi alebo úplatok pri chorom dieťati [Z54]; každý deň rozpočet na nájom, jedlo, kúrenie – dlh končí hru [Z55]; v Not Tonight úplatky stoja sociálny kredit [Z65].",
  "src":["Z54","Z55","Z65"],"D":2,"M":5,"S":5,"sIdea":"Politik ponúkne prémiu za misiu, ktorá ublíži obyčajným ľuďom. Vezmeš ju, aby si zaplatil nájom?","I":5},
 {"code":"MCH43","name":"Voľby s následkami a viac koncov","games":["Papers, Please","Beholder","Katana ZERO","Not Tonight"],"cat":"postup",
  "what":"Rozhodnutia menia, čo sa stane neskôr, a hra má viac koncov.",
  "why":"Fakt: Papers, Please má 20 koncov [Z55]; Beholder viac koncov podľa rozhodnutí [Z64]; autor Katana ZERO: každá malá voľba má malé následky [Z58]; Not Tonight – voľba medzi vládou a odbojom [Z65].",
  "src":["Z55","Z64","Z58","Z65"],"D":3,"M":5,"S":5,"sIdea":"Konce podľa toho, či hráč sľuby pomáhal plniť, sabotoval ich, alebo pravdu zverejnil.","I":5},
 {"code":"MCH44","name":"Pravidlá, ktoré sa menia každý deň (nariadenie ako pointa)","games":["Papers, Please","Not Tonight"],"cat":"hlavná slučka",
  "what":"Každý deň/kapitola prinesie nové nariadenie, ktoré mení hrateľnosť a je zároveň vtipom.",
  "why":"Fakt: pravidlá v Papers, Please pribúdajú a komplikujú sa [Z54]; v Not Tonight sa menia (národnosti, oblečenie, zoznam hostí) [Z65].",
  "src":["Z54","Z65"],"D":2,"M":5,"S":5,"sIdea":"Každá kapitola začne novým „nariadením“, ktoré popiera sľub z predchádzajúcej.","I":4},
 {"code":"MCH45","name":"Satira v detailoch: titulky novín medzi kapitolami","games":["Papers, Please","Beholder","Not Tonight"],"cat":"viralita",
  "what":"Medzi úrovňami krátka „správa“ alebo titulka, ktorá ukáže dôsledok hráčovej práce.",
  "why":"Názor (z poznania hier, nedoložené zdrojom): denné noviny v Papers, Please zhŕňajú dopady rozhodnutí a sú to obľúbené screenshoty.",
  "src":[],"D":1,"M":5,"S":5,"sIdea":"Titulka „Sľúbili sme / Urobili sme“ medzi misiami – hotový obrázok na zdieľanie.","I":4},
 {"code":"MCH46","name":"Fiktívny, všeobecný svet namiesto aktuálnej politiky","games":["Papers, Please","Not Tonight"],"cat":"viralita",
  "what":"Vymyslená krajina a situácie, ktoré pozná každý, bez konkrétnych reálnych udalostí.",
  "why":"Fakt: Pope zámerne nechal svet všeobecný a vyhol sa konkrétnym reálnym krivdám, aby hráč neprišiel s hotovým názorom [Z54]. Protipríklad: Not Tonight o Brexite časť hráčov označila za propagandu a podľa odborníka môže publikum rozdeliť [Z66].",
  "src":["Z54","Z66"],"D":1,"M":5,"S":5,"sIdea":"Fiktívna krajina a politici, ktorých sľuby pozná každý (dane, nemocnice, cesty) – zrozumiteľné v Európe aj Amerike.","I":5},
 {"code":"MCH47","name":"Jednoduché zobrazenie, ktoré necháva priestor fantázii","games":["Papers, Please"],"cat":"vizuál a pocit",
  "what":"Dôležité veci (rodina, obete) sú zobrazené len naznačene, hráč si ich dosadí sám.",
  "why":"Fakt: rodina v Papers, Please je „pár bodiek s textom“, aby si hráč predstavil vlastnú; jednoduchá technika podľa Popea uľahčila udržať jemné nuansy [Z54].",
  "src":["Z54"],"D":1,"M":5,"S":3,"sIdea":"Ľudí, ktorým sľuby ublížili, ukáž jednoducho (silueta + jedna veta), nech si hráč dosadí vlastnú skúsenosť.","I":3},
 {"code":"MCH48","name":"Dvojvoľba potiahnutím doľava/doprava","games":["Reigns"],"cat":"ovládanie",
  "what":"Rozhodnutie jedným potiahnutím prsta: áno / nie.",
  "why":"Fakt: Reigns spojil potiahnutie z Tinderu s prostredím Game of Thrones [Z61]; karta sa potiahne doľava alebo doprava [Z62]; 80 % predaja bolo na mobile [Z61].",
  "src":["Z61","Z62"],"D":2,"M":5,"S":5,"sIdea":"Medzi misiami politik podsúva dokumenty: podpísať, alebo odmietnuť?","I":4},
 {"code":"MCH49","name":"Ukazovatele rovnováhy, prehra pri extréme","games":["Reigns"],"cat":"hlavná slučka",
  "what":"Niekoľko ukazovateľov (napr. ľud, armáda, cirkev, pokladnica); keď je ktorýkoľvek prázdny alebo plný, je koniec.",
  "why":"Fakt: každé rozhodnutie v Reigns posúva štyri ukazovatele; plný alebo prázdny ukončí vládu [Z62].",
  "src":["Z62"],"D":2,"M":5,"S":5,"sIdea":"Dôvera ľudí, Kasa, Médiá, Sponzori – politik nemôže vyhovieť všetkým; ak niečo „pretečie“, padá.","I":4},
 {"code":"MCH50","name":"Prehra nie je koniec príbehu – prichádza nástupca","games":["Reigns"],"cat":"postup",
  "what":"Keď postava padne, pokračuje nová a dlhý príbeh beží ďalej.",
  "why":"Fakt: po konci vlády nastupuje nový kráľ; úlohy odomykajú karty a dlhodobý cieľ (kliatba) beží naprieč vládami [Z62].",
  "src":["Z62"],"D":2,"M":5,"S":5,"sIdea":"Keď politik padne, príde nový – s tými istými sľubmi.","I":3},
 {"code":"MCH51","name":"Krátky text: otázka – rýchla odpoveď – následok","games":["Reigns","Papers, Please"],"cat":"vizuál a pocit",
  "what":"Každý text má jednu myšlienku a zmestí sa na malú obrazovku.",
  "why":"Fakt: karty v Reigns idú vzorcom krátka priama otázka, rýchla odpoveď, vážny následok [Z62]; Papers, Please pre mobil dostal úplne nové rozhranie [Z57].",
  "src":["Z62","Z57"],"D":1,"M":5,"S":4,"sIdea":"Každý dialóg na max. 2 riadky: sľub v jednej vete, realita v druhej.","I":4},
 {"code":"MCH52","name":"Dialóg v reálnom čase s možnosťou prerušiť","games":["Katana ZERO"],"cat":"hlavná slučka",
  "what":"Hráč môže skočiť postave do reči; časté prerušovanie má následky.",
  "why":"Fakt: kto prerušuje, môže postavy nahnevať – prestanú hovoriť, hráč príde o informácie, kontakt ho môže zradiť [Z58]; kritici dialógový systém chválili [Z59].",
  "src":["Z58","Z59"],"D":3,"M":4,"S":5,"sIdea":"Hráč môže politikovi skočiť do prejavu – keď to robí často, politik sa urazí a zatají dôležitú informáciu.","I":3},
 {"code":"MCH53","name":"Úroveň ako „plán“: neúspech = to by nefungovalo","games":["Katana ZERO"],"cat":"háčik",
  "what":"Pokusy o úroveň sú rámcované ako možné scenáre, ktoré hrdina predvída; až úspech je „skutočnosť“.",
  "why":"Fakt: každá z 11 úrovní je rámcovaná ako scenár, ktorý hrdina predvídal [Z59]. Názor: smrť tak nepretrhne príbeh.",
  "src":["Z59"],"D":2,"M":5,"S":5,"sIdea":"Neúspešný pokus = „tento sľub sa nesplní“, úspech = „tak to bude“.","I":3},
 {"code":"MCH54","name":"Koniec kapitoly s napätím (cliffhanger)","games":["Katana ZERO","Beholder"],"cat":"háčik",
  "what":"Kapitola končí otázkou alebo odhalením, ktoré núti hrať ďalej.",
  "why":"Fakt: Katana ZERO končí v napätí (zmiznutie postavy) [Z59]. Riziko: časť kritikov koniec označila za náhly a sľúbené DLC s pokračovaním sa odkladá od 2019 [Z59][Z60].",
  "src":["Z59","Z60"],"D":1,"M":5,"S":4,"sIdea":"Kapitola končí odhalením, že ďalší sľub je už vopred predaný – a hráč chce vedieť komu.","I":5},
 {"code":"MCH55","name":"Ďalšie hry/kapitoly v rovnakom formáte (séria)","games":["Reigns","Beholder","Not Tonight"],"cat":"monetizácia",
  "what":"Po úspechu autor vydáva nové príbehy na tom istom systéme.",
  "why":"Fakt: Reigns: Her Majesty, Game of Thrones, Beyond, Three Kingdoms [Z62]; autor: je to mechanika, takže sa dá rozprávať akýkoľvek príbeh [Z61]. Beholder 2, 3 a Conductor [Z64]; Not Tonight 2 [Z65].",
  "src":["Z62","Z61","Z64","Z65"],"D":3,"M":5,"S":5,"sIdea":"Každá nová kapitola = nové „volebné obdobie“ s novými sľubmi.","I":4},
 {"code":"MCH56","name":"Platená príbehová kapitola (DLC)","games":["Beholder","Not Tonight"],"cat":"monetizácia",
  "what":"Samostatný príbehový príbeh za malý poplatok po vydaní.",
  "why":"Fakt: Beholder – Blissful Sleep (2017) [Z64]; Not Tonight – One Love (2019) [Z65]. Papers, Please DLC nemá – autor hru zámerne nerozširoval [Z55].",
  "src":["Z64","Z65","Z55"],"D":3,"M":5,"S":5,"sIdea":"DLC ako „mimoriadne zasadnutie“: jeden nový zákon a jeho dopady.","I":4},
 {"code":"MCH57","name":"Ovládanie navrhnuté pre dotyk od začiatku","games":["Papers, Please","Beholder","Katana ZERO"],"cat":"ovládanie",
  "what":"Rozhranie a ovládanie sa navrhujú pre prsty a malú obrazovku, nie prenášajú z PC.",
  "why":"Fakt: prerobenie Papers, Please pre telefóny trvalo mnoho mesiacov aj s pôvodnou grafikou [Z57]; Beholder chválený za ľahké ovládanie na telefóne [Z64]; Katana ZERO na mobile kritizovaný za dotyk [Z59].",
  "src":["Z57","Z64","Z59"],"D":3,"M":5,"S":1,"sIdea":"Bez priamej väzby.","I":5},
 {"code":"MCH58","name":"Voľby, o ktorých sa dá debatovať (hra v skupine, na streame)","games":["Reigns"],"cat":"viralita",
  "what":"Rozhodnutia sú jednoduché, ale sporné, takže skupina alebo chat streamera sa o ne háda.",
  "why":"Fakt: autor Reigns: ľudia radi hrajú v skupine, preto hra sedí na YouTube a Twitch [Z61].",
  "src":["Z61"],"D":1,"M":4,"S":4,"sIdea":"Voľby typu „splniť sľub, alebo zradiť ľudí?“, o ktorých hlasuje chat streamera.","I":4},
]

for m in d["mechanics"]:
    u = UPD[m["code"]]
    m["status"] = u["status"]
    for k in ("name", "what", "D", "M", "S", "I"):
        if k in u:
            m[k] = u[k]
    if "why_add" in u:
        m["why"] += u["why_add"]
    for z in u.get("src_add", []):
        if z not in m["src"]:
            m["src"].append(z)
    for g in u.get("games_add", []):
        if g not in m["games"]:
            m["games"].append(g)
    m["v2note"] = u["v2note"]
    # zdroje spomenuté v poznámke
    import re
    for z in re.findall(r"\[(Z\d\d)\]", m["v2note"]):
        if z not in m["src"]:
            m["src"].append(z)

for n in NEW:
    n["status"] = "nové"
    n["v2note"] = "Nová mechanika z príbehových hier."
    d["mechanics"].append(n)

assert set(UPD) == {m["code"] for m in d["mechanics"] if m["status"] != "nové"}
json.dump(d, open("data-v2.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(len(d["mechanics"]), "mechanics,", len(d["sources"]), "sources")
