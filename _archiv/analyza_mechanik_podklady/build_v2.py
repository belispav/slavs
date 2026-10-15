import json, re, subprocess

subprocess.run(["python3", "v2data.py"], check=True)
data = json.load(open("data-v2.json", encoding="utf-8"))
M, SRC = data["mechanics"], data["sources"]
LESS = "menej vhodné pre príbehovú hru"

ADAPT = {
    "MCH46": "Fiktívna krajina a fiktívni politici, ktorých sľuby pozná každý (dane, nemocnice, cesty) – zrozumiteľné v Európe aj Amerike, bez reálnych mien.",
    "MCH54": "Každá kapitola končí odhalením, že ďalší sľub je už vopred predaný – hráč chce vedieť komu.",
    "MCH06": "Jedna kapitola = jedno „volebné obdobie“ na 10–15 minút, dohrateľné cestou v MHD.",
    "MCH45": "Medzi misiami titulka „Sľúbili sme / Urobili sme“ – hotový obrázok na zdieľanie.",
    "MCH11": "Po smrti hneď znova, s krátkou hláškou typu „Toto sme nesľúbili“.",
    "MCH51": "Každý dialóg na max. 2 riadky: sľub v jednej vete, realita v druhej.",
    "MCH58": "Voľby typu „splniť sľub, alebo zradiť ľudí?“, o ktorých môže hlasovať chat streamera.",
    "MCH28": "Jedna cena bez nákupov v hre – „cena, ktorá sa po voľbách nezmení“.",
    "MCH13": "Na konci kapitoly „Plnenie sľubov: 37 %“ – hodnotenie hráča aj politika.",
    "MCH18": "Nepriatelia a nariadenia pomenované úradným žargónom („Pracovná skupina“, „Konsolidačný balík“) – ľudia ich citujú, žiadne reálne mená.",
}

statuses = ["nové", "upravené", "bez zmeny", LESS]
codes = [m["code"] for m in M]
assert len(codes) == len(set(codes))
for m in M:
    assert m["status"] in statuses, m["code"]
    for k in ("D", "M", "S", "I"):
        assert 1 <= m[k] <= 5, (m["code"], k)
    for z in m["src"]:
        assert z in SRC, (m["code"], z)
    for z in re.findall(r"\[(Z\d\d)\]", m["why"] + m["v2note"]):
        assert z in m["src"], (m["code"], "missing src", z)

ratio = lambda m: m["I"] / m["D"]
key = lambda m: (-ratio(m), -m["I"], -m["M"], -m["S"], m["code"])
fit = sorted([m for m in M if m["status"] != LESS], key=key)
top = fit[:10]
top_codes = [m["code"] for m in top]
assert set(top_codes) == set(ADAPT), top_codes
for m in M:
    m["top"] = ADAPT.get(m["code"], "")

fmt = lambda x: f"{x:.1f}".replace(".", ",")
hi = [m for m in fit[10:] if m["I"] == 5]
next_note = ("Najvyšší vplyv (5) mimo Top 10: " + "; ".join(f"{m['code']} {m['name']} (pomer {fmt(ratio(m))})" for m in hi)
             + ". Sú náročnejšie, preto nižšie v poradí – no pre príbehovú hru patria k jadru.")

cnt = {s: sum(m["status"] == s for m in M) for s in statuses}
old_in_top = [m for m in top if int(m["code"][3:]) <= 40]
changes = [
    f"Smer hry: z „survivor“ hry na príbehovú akčnú strieľačku. Preto {cnt[LESS]} mechaník z 1. kola (automatická streľba, výber vylepšení, kryštály, trvalé vylepšenia, energia, reklamy…) je teraz „menej vhodné“ – stavajú na nekonečnom opakovaní kôl, no hráč sa po dohraní príbehu nevráti.",
    f"Pribudlo {cnt['nové']} mechaník z príbehových a satirických hier (Papers, Please, Katana ZERO, Reigns, Beholder, Not Tonight): práca pre systém, dilemy, viac koncov, cliffhanger, krátke texty, fiktívny svet.",
    f"{cnt['upravené']} mechaník je upravených (napr. časovač → dĺžka kapitoly, bezplatná ukážka → prvá kapitola zadarmo, nízka cena → jednorazová cena), {cnt['bez zmeny']} platí bez zmeny (hlavne pocit zo streľby, okamžitý reštart, hudba).",
    f"Top 10 sa zmenila: {10 - len(old_in_top)} mechaník je nových z príbehových hier. Z 1. kola ostali: " + ", ".join(f"{m['code']} {m['name']} ({m['status']})" for m in old_in_top) + ". Vypadli: " + ", ".join(c for c in ["MCH35","MCH01","MCH06","MCH03","MCH11","MCH36","MCH28","MCH13","MCH18","MCH25"] if c not in top_codes) + " (MCH35 ostáva upravený ako „Silný úvod“ tesne za Top 10).",
    "Ovládanie: z hry na výšku jedným palcom na šírku 640×360. Najvhodnejšie je automatické mierenie s tlačidlami (MCH21); Katana ZERO ukazuje, že PC ovládanie prenesené na dotyk recenzenti kritizujú [Z59].",
    "Monetizácia: z hry zadarmo s reklamami na jednorazovú cenu alebo prvú kapitolu zadarmo. Príjem po vydaní nesú nové kapitoly a pokračovania (Reigns, Beholder) [Z62][Z64].",
    "Publikum: z Ázie na Európu a Ameriku – preklady do hlavných európskych jazykov (MCH38).",
    "Nové riziká: aktuálna politika rozdeľuje publikum (Not Tonight) [Z66] a sľúbený obsah, ktorý roky nepríde (Katana ZERO) [Z60].",
]

# ---------- MD ----------
rows = ["| Kód | Stav | Mechanika | Hry | Kategória | Čo to je | Prečo funguje | Poznámka v2 | Nár. | Mob. | Sat. (+ nápad) | Vpl. | Pomer |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
for m in sorted(M, key=lambda m: m["code"]):
    star = f" **TOP {top_codes.index(m['code']) + 1}**" if m["code"] in top_codes else ""
    rows.append(f"| {m['code']}{star} | {m['status']} | {m['name']} | {', '.join(m['games'])} | {m['cat']} | {m['what']} | {m['why']} | {m['v2note']} | {m['D']} | {m['M']} | {m['S']} – {m['sIdea']} | {m['I']} | {fmt(ratio(m))} |")
table = "\n".join(rows)

top_md = "\n".join(
    f"{i}. **{m['code']} {m['name']}** ({m['status']}; pomer {fmt(ratio(m))}; vplyv {m['I']}, náročnosť {m['D']}, mobil {m['M']}, satira {m['S']}) – {m['top']}"
    for i, m in enumerate(top, 1))
changes_md = "\n".join(f"- {c}" for c in changes) + "\n\nPočty: " + ", ".join(f"{s}: {cnt[s]}" for s in statuses) + f" (spolu {len(M)})."
src_md = "\n".join(f"- **{k}** [{v[0]}]({v[1]})" for k, v in SRC.items())

md = open("template-v2.md", encoding="utf-8").read()
for k, v in {"{{TABLE}}": table, "{{TOP10}}": top_md, "{{NEXT}}": next_note, "{{CHANGES}}": changes_md, "{{SOURCES}}": src_md}.items():
    md = md.replace(k, v)
assert "{{" not in md
assert "mass shooter" not in md.lower()
open("analyza-mechanik-v2.md", "w", encoding="utf-8").write(md)

# ---------- HTML ----------
payload = {"mechanics": M, "sources": SRC, "top10": top_codes, "nextNote": next_note, "changes": changes}
html = open("template-v2.html", encoding="utf-8").read()
html = html.replace("{{DATA}}", json.dumps(payload, ensure_ascii=False).replace("</", "<\\/"))
assert "{{" not in html and "mass shooter" not in html.lower()
open("analyza-mechanik-v2.html", "w", encoding="utf-8").write(html)

# every [Zxx] cited anywhere exists
for z in set(re.findall(r"\[(Z\d\d)\]", md)) | set(re.findall(r'data-src="(Z\d\d)"', html)):
    assert z in SRC, z
print("TOP10:", top_codes)
print("HI5 outside:", [m["code"] for m in hi])
print("counts:", cnt, "total", len(M))
