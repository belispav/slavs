#!/usr/bin/env python3
"""Zoznam ovladacich prvkov ladiaceho panela -> Excel, a spat -> panel_hidden.gd.

Pouzitie (z korena repozitara):
  1) godot --headless --path slavs --script ../tools/panel_catalog_dump.gd -- tools/panel_catalog.json
  2) python3 tools/panel_catalog.py build   -> PANEL_prvky.xlsx (stlpec "Zobrazit" A/N)
  3) Pavel v Exceli prepise A/N
  4) python3 tools/panel_catalog.py import  -> slavs/scripts/panel_hidden.gd

Rozhodnutia sa viazu na kluc "typ|nazov" - pri novom builde sa zachovaju z
existujuceho xlsx (nove prvky dostanu A). Skryte prvky ostavaju v kode, len
sa nezobrazia. Na vratenie staci v xlsx dat A a znova import.
"""
import json
import sys
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.worksheet.datavalidation import DataValidation

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "tools" / "panel_catalog.json"
XLSX = ROOT / "PANEL_prvky.xlsx"
GD = ROOT / "slavs" / "scripts" / "panel_hidden.gd"

# Popis (co prvok robi) a odporucanie (A = nechat viditelne, N = skryt).
INFO = {
    "NESMRTELNOST": ("Hrdina nedostane zranenie ani odhodenie. Na testovanie ostatnych vecí.", "A"),
    "DOTYKY NA OBRAZOVKE": ("Ukaze body dotyku prstov.", "N"),
    "scena: vyska horneho pasu": ("Kolko pixelov hore je neprechodny pas (obloha/ plot).", "N"),
    "CELA OBRAZOVKA HLINA (bez scrollu)": ("Zem na celu obrazovku, bez posuvania pozadia.", "N"),
    "OBJEKTY NA ZEMI (prechodne)": ("Zapne prechodne dekoracie na zemi.", "N"),
    "objekty: kolko na obrazovku": ("Pocet dekoracii na obrazovke.", "N"),
    "HLADKE POZADIE": ("Pozadie bez dekoracii.", "N"),
    "rychlost pozadia": ("Ako rychlo sa posuva pozadie.", "N"),
    "odstup od okraja": ("Ako blizko k bocnemu okraju moze hrdina ist.", "N"),
    "odstup od SPODNEHO okraja": ("Ako blizko k spodnemu okraju moze hrdina ist.", "N"),
    "sud: odstup postavy": ("Ako daleko pred hrdinom sa postavi novy sud.", "N"),
    "EFEKTY (krv, triesky, dym)": ("Zapne/vypne vizualne efekty.", "N"),
    "ako dlho lezi krv na zemi (s)": ("Ako dlho ostane krv na zemi.", "N"),
    "kotol: odpocet do vybuchu (s)": ("Za kolko sekund kotol vybuchne po zasahu.", "A"),
    "kotol: dosah vybuchu": ("Polomer vybuchu kotla v px.", "A"),
    "VYBUCH ZRANI AJ HRDINU": ("Ak je vypnute, vybuch kotla zraňuje len nepriatelov.", "A"),
    "ZVUKY": ("Zapne/vypne zvukove efekty.", "A"),
    "hlasitost efektov (dB)": ("Hlasitost zvukovych efektov.", "N"),
    "hlasitost hlasov (dB)": ("Hlasitost hlasov nepriatelov.", "N"),
    "nahodnost efektov: hlasitost +- (dB)": ("Nahodna zmena hlasitosti (odladene 2,5).", "N"),
    "nahodnost efektov: vyska tonu +- (%)": ("Nahodna zmena vysky tonu (odladene 25).", "N"),
    "ako casto hovoria nepriatelia (s)": ("Interval hlasok nepriatelov.", "N"),
    "VIBRACIE": ("Vibracie telefonu pri zasahu.", "N"),
    "sila vibracii": ("Sila vibracie.", "N"),
    "dlzka vibracie pri zasahu (ms)": ("Dlzka vibracie.", "N"),
    "ZASTAVENIE PRI ZASAHU": ("Pri zasahu tvojej zbrane sa hra na okamih zastavi (pocit tazkeho uderu).", "A"),
    "zastavenie pri zasahu (ms)": ("Ako dlho trva zastavenie pri zasahu (pri zabiti dlhsie).", "A"),
    "TELO PO SMRTI": ("Zabity nepriatel odleti v smere uderu, pretoci sa, dopadne a poskoci; telo chvilu lezi.", "A"),
    "sila odletu tela": ("Nasobok sily odletu tela (1 = zakladna).", "A"),
    "ako dlho telo lezi (s)": ("Kolko sekund telo lezi, kym zmizne.", "A"),
    "TELO ZMIZNE V DYME": ("Telo zmizne v oblaku dymu (vypnute = len sa vytrati).", "A"),
    "SPOMALENIE PRI POSLEDNOM ZABITI": ("Cas sa na chvilu spomali po zabiti posledneho nepriatela v boji a po kazdom brutovi.", "A"),
    "dlzka spomalenia (ms)": ("Ako dlho trva spomalenie (skutocne ms).", "A"),
    "rychlost pocas spomalenia": ("Aky rychly je cas pocas spomalenia (1 = normalne).", "A"),
    "BIELY ZABLESK": ("Zasiahnuty nepriatel na chvilu cely zbeli.", "A"),
    "dlzka bieleho zablesku (ms)": ("Ako dlho je nepriatel biely.", "A"),
    "TRASENIE OBRAZU PRI ZASAHU": ("Obrazovka sa zatrasie pri zasahu a zabiti sekerou.", "A"),
    "sila trasenia pri zasahu": ("Nasobok sily trasenia (1.0 = zakladna).", "A"),
    "KOPNUTIE KAMERY": ("Kamera sa na okamih trhne v smere letu seker/strely.", "A"),
    "sila kopnutia kamery": ("Nasobok sily kopnutia (1.0 = zakladna).", "A"),
    "VIBRACIA PRI MOJOM ZASAHU": ("Kratke zavibrovanie telefonu, ked tvoja zbran zasiahne nepriatela.", "A"),
    "dlzka vibracie pri mojom zasahu (ms)": ("Dlzka vibracie pri tvojom zasahu.", "A"),
    "TEST VIBRACIE (rovnaka ako pri mojom zasahu)": ("Tlacidlo: jedna vibracia presne taka, ako pri tvojom zasahu (na zistenie, ci telefon vibruje).", "A"),
    "CISLA POSKODENIA": ("Nad zasiahnutym nepriatelom vyleti cislo poskodenia.", "A"),
    "velkost cisel poskodenia": ("Velkost pisma cisel poskodenia.", "A"),
    "KRITICKY ZASAH": ("Cast zasahov je kritickych (2 zivoty, zlte cislo, silnejsie efekty).", "A"),
    "sanca na kriticky zasah (%)": ("Kolko percent zasahov je kritickych (100 = vzdy na test).", "A"),
    "HUDBA": ("Zapne/vypne hudbu.", "A"),
    "hlasitost hudby (dB)": ("Hlasitost hudby.", "N"),
    "ZMRAZIT SVET (hybe sa len hrdina)": ("Zastavi nepriatelov, kotly a ich strely; hybe sa len hrdina.", "A"),
    "VYPNUT BEZCOV": ("Nebudu sa objavovat bezci.", "A"),
    "VYPNUT STRELCOV": ("Nebudu sa objavovat strelci.", "A"),
    "VYPNUT TUCNAKOV": ("Nebudu sa objavovat tucniaci.", "A"),
    "kolko bezcov naraz (test)": ("Kolko bezcov je naraz v hre.", "A"),
    "kolko strelcov naraz (test)": ("Kolko strelcov je naraz v hre.", "A"),
    "kolko tucnakov naraz (test)": ("Kolko tucniakov je naraz v hre.", "A"),
    "posun palca pre plnu rychlost vlavo": ("Ako daleko od stredu paky treba posunut palec pre plnu rychlost (mensie cislo = rychlejsie plna rychlost, kratsia pomala zona).", "A"),
    "posun palca pre plnu rychlost vpravo": ("To iste, vpravo; plati aj pre pohyb hore a dole.", "A"),
    "o kolko pomalsi je pohyb hore-dole": ("1 = hore/dole rovnako rychlo ako do stran; menej = pomalsie.", "A"),
    "ako blizko k postave prestane mierit": ("Mierenie sa vypne, ked je palec blizko postavy.", "N"),
    "rychlost postavy": ("Nasobok rychlosti hrdinu.", "A"),
    "pohyb pocas hodu (0 = stoji)": ("Ako rychlo sa hrdina hybe pocas hodu.", "N"),
    "rychlost zamachu pri hode (1 = povodna)": ("Rychlost animacie hodu.", "N"),
    "HRDINA 2x (vypnute = 1x)": ("Velkost hrdinu.", "N"),
    "SEKERA (vypnute = gulky)": ("Prepina zbran: sekera alebo gulky.", "A"),
    "dosah sekery": ("Ako daleko sekera doletí.", "A"),
    "rychlost sekery": ("Rychlost sekery smerom k cielu (spat je 1,5x).", "A"),
    "NOVE SUDY (postavi ich pred hrdinu)": ("Tlacidlo: znova postavi sudy.", "A"),
    "aky vysoky kus tela hraca sa da trafit (0-1)": ("Vyska zasiahnutelnej casti hrdinu.", "N"),
    "rychlost bezcov": ("Nasobok rychlosti bezcov.", "A"),
    "rychlost strelcov": ("Nasobok rychlosti strelcov.", "A"),
    "na aku vzdialenost si bezec vsimne hraca (px)": ("Dosah, od ktoreho bezec zacne prenasledovat.", "N"),
    "UKAZ ZONY ZASAHU (sekera, nepriatelia, hrdina)": ("Nakresli kruh sekery a obdlzniky zasahu nepriatelov a hrdinu.", "A"),
    "sekera: polomer zasahu (px)": ("Velkost kruhu sekery; sekera zasiahne kazdeho, koho obdlznik sa dotkne kruhu.", "A"),
    "UKAZ ZONU UDERU BEZCA": ("Nakresli kruh, kam dopadne uder bezca.", "N"),
    "zona uderu: ako daleko pred bezcom dopadne zbran (px)": ("Poloha zony uderu.", "N"),
    "zona uderu: vyska dopadu nad nohami bezca (px)": ("Poloha zony uderu.", "N"),
    "zona uderu: polomer kruhu okolo miesta dopadu (px)": ("Velkost zony uderu.", "N"),
    "kedy v animacii uderu zasah plati (0 = hned, 1 = na konci)": ("Casovanie zasahu v animacii.", "N"),
    "aky vysoky kus tela nepriatela sa da trafit (0-1)": ("Vyska zasiahnutelnej casti nepriatela.", "N"),
    "PEVNE TELA (nikto cez nikoho neprejde)": ("Zapne pevne nohy postav; nikto cez nikoho neprejde.", "A"),
    "pevne telo: hlbka nohy (px; 54 = cele telo)": ("Hlbka pevneho tela (odladene 30).", "N"),
    "pevne telo: sirka nohy (px)": ("Sirka pevneho tela (odladene 60).", "N"),
    "ako daleko od seba sa nepriatelia odtlacaju (px; len bez pevnych tiel)": ("Stary mak odtlacania; funguje len ked su PEVNE TELA vypnute.", "N"),
    "bezec odhodi hrdinu (px)": ("Dlzka odhodenia hrdinu po zasahu bezca.", "A"),
    "strela strelca odhodi hrdinu (px)": ("Dlzka odhodenia hrdinu po zasahu strely.", "A"),
    "sekera odhodi nepriatela (px)": ("Dlzka odhodenia nepriatela po zasahu sekery.", "A"),
    "vybuch kotla odhodi hrdinu (px)": ("Dlzka odhodenia hrdinu pri vybuchu kotla.", "A"),
    "odhodenie: ako dlho trva (s)": ("Trvanie odhodenia (odladene 0,4).", "N"),
    "srdiecka nad postavami: 0 vypnute, 1 hrdina + ranene, 2 vsetci": ("Zivoty nad postavami.", "A"),
    "tien pod postavami: sila (0 = vypnuty)": ("Sila tiena (odladene 0,3).", "N"),
    "tien pod postavami: velkost (x)": ("Velkost tiena (odladene 1).", "N"),
    "sirka": ("Sirka zony pre lavy palec.", "N"),
    "kolko zospodu patri miereniu": ("Spodna cast zony patri miereniu.", "N"),
    "MIERIT OD POSTAVY": ("Mierenie zacina od postavy.", "N"),
    "VOLNY POHYB (bez skoku)": ("Hrdina nechodi skokom k prstu.", "N"),
    "POHYB KOPIRUJE PALEC": ("Hrdina kopiruje pohyb palca.", "N"),
}


def key(it):
    return f"{it['type']}|{it['name']}"


def old_choices():
    out = {}
    if XLSX.exists():
        ws = load_workbook(XLSX)["Panel"]
        for r in ws.iter_rows(min_row=2, values_only=True):
            if r[0] and r[7]:
                out[r[7]] = str(r[6]).strip().upper()
    return out


def build():
    items = json.loads(CATALOG.read_text(encoding="utf-8"))
    old = old_choices()
    wb = Workbook()
    ws = wb.active
    ws.title = "Panel"
    head = ["S", "Sekcia", "Typ", "Nazov", "Hodnota", "Popis", "Zobrazit (A/N)", "kluc"]
    ws.append(head)
    n = 0
    for it in items:
        if it["type"] == "section":
            continue
        n += 1
        desc, rec = INFO.get(it["name"], ("", "A"))
        ws.append([f"S{n}", it["section"], it["type"], it["name"], it["value"],
                   desc, old.get(key(it), rec), key(it)])
    bold = Font(bold=True, color="FFFFFF")
    for c in ws[1]:
        c.font = bold
        c.fill = PatternFill("solid", fgColor="444444")
    for col, w in zip("ABCDEFGH", (6, 22, 9, 52, 10, 58, 14, 10)):
        ws.column_dimensions[col].width = w
    ws.column_dimensions["H"].hidden = True
    ws.freeze_panes = "A2"
    ws.auto_filter.ref = f"A1:G{ws.max_row}"
    dv = DataValidation(type="list", formula1='"A,N"', allow_blank=False)
    ws.add_data_validation(dv)
    dv.add(f"G2:G{ws.max_row}")
    green = PatternFill("solid", fgColor="D9EAD3")
    red = PatternFill("solid", fgColor="F4CCCC")
    from openpyxl.formatting.rule import CellIsRule
    ws.conditional_formatting.add(f"G2:G{ws.max_row}", CellIsRule(operator="equal", formula=['"A"'], fill=green))
    ws.conditional_formatting.add(f"G2:G{ws.max_row}", CellIsRule(operator="equal", formula=['"N"'], fill=red))
    for row in ws.iter_rows(min_row=2):
        row[5].alignment = Alignment(wrap_text=True, vertical="top")
        row[3].alignment = Alignment(wrap_text=True, vertical="top")
    wb.save(XLSX)
    print(f"xlsx: {n} prvkov -> {XLSX}")


def do_import():
    ws = load_workbook(XLSX)["Panel"]
    hidden = [r[7] for r in ws.iter_rows(min_row=2, values_only=True)
              if r[0] and str(r[6]).strip().upper() == "N"]
    body = ",\n".join(f'\t"{k}"' for k in hidden)
    txt = ("extends RefCounted\n\n"
           "## Generated by tools/panel_catalog.py from PANEL_prvky.xlsx (column A/N).\n"
           "## Do not edit by hand. Hidden rows stay in code; this only hides them in the panel.\n"
           "const HIDDEN: Array[String] = [\n" + body + (",\n" if body else "") + "]\n")
    GD.write_bytes(txt.replace("\n", "\r\n").encode("utf-8"))
    print(f"hidden: {len(hidden)} -> {GD}")


if __name__ == "__main__":
    {"build": build, "import": do_import}[sys.argv[1]]()
