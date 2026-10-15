import json

data = json.load(open("data.json", encoding="utf-8"))
M, SRC = data["mechanics"], data["sources"]

ADAPT = {
    "MCH35": "Prvé 2 minúty nazvi „medové týždne po voľbách“ – vylepšenia padajú rýchlo, potom „realita“ pritvrdí.",
    "MCH01": "Postava automaticky „strieľa“ pripomienkami sľubov, hráč sa sústredí len na uhýbanie davom.",
    "MCH06": "Jedna hra = jedno „volebné obdobie“ (4 „roky“ po 3 minútach), finále sú „voľby“ s bossom.",
    "MCH03": "Z nepriateľov padajú „podpisy pod petíciou“; plná petícia = nový level.",
    "MCH11": "Po smrti jedno tlačidlo „Predčasné voľby“ a hráš znova.",
    "MCH36": "Celá hra na výšku jedným palcom, aby sa dala hrať v MHD – satira tu nie je potrebná.",
    "MCH28": "Len pri platenom modeli: cena okolo 3 $ s textom „lacnejšie ako jeden predvolebný leták“.",
    "MCH13": "Na konci úrovne „Plnenie sľubov: 37 %“ a známka ako od ratingovej agentúry – obrázok na zdieľanie.",
    "MCH18": "Nepriatelia a zbrane pomenované podľa úradného žargónu („Pracovná skupina“, „Konsolidačný balík“), nikdy podľa reálnych ľudí.",
    "MCH25": "Len pri modeli zadarmo: jedna platba vypne reklamy s textom „Tento sľub dodržíme“.",
}

# sanity checks
codes = [m["code"] for m in M]
assert len(codes) == len(set(codes)), "duplicate codes"
for m in M:
    for k in ("D", "M", "S", "I"):
        assert 1 <= m[k] <= 5, (m["code"], k)
    for z in m["src"]:
        assert z in SRC, (m["code"], z)
    import re
    for z in re.findall(r"\[(Z\d\d)\]", m["why"]):
        assert z in SRC, (m["code"], z)
        assert z in m["src"], (m["code"], "src list missing", z)

ratio = lambda m: m["I"] / m["D"]
key = lambda m: (-ratio(m), -m["I"], -m["M"], -m["S"], m["code"])
ranked = sorted(M, key=key)
top = ranked[:10]
assert set(x["code"] for x in top) == set(ADAPT), [x["code"] for x in top]
for m in M:
    m["top"] = ADAPT.get(m["code"], "")
top_codes = [m["code"] for m in top]

# items just below top 10 with maximum impact
r11 = ratio(ranked[10])
nxt = [m for m in ranked[10:] if ratio(m) == r11]
next_note = (f"Tesne za Top 10 (pomer {str(round(r11,1)).replace('.', ',')}): "
             + ", ".join(f"{m['code']} {m['name']}" for m in nxt)
             + " – vplyv " + "/".join(str(m["I"]) for m in nxt)
             + ", len o stupeň náročnejšie. MCH02 a MCH07 sú základ žánru – majú ich všetky úspešné horde shootery v analýze.")

fmt = lambda x: f"{x:.1f}".replace(".", ",")

# ---------- MD ----------
rows = ["| Kód | Mechanika | Hry | Kategória | Čo to je | Prečo funguje | Nár. | Mob. | Sat. (+ nápad) | Vpl. | Pomer |",
        "|---|---|---|---|---|---|---|---|---|---|---|"]
for m in sorted(M, key=lambda m: m["code"]):
    star = " **TOP " + str(top_codes.index(m["code"]) + 1) + "**" if m["code"] in top_codes else ""
    rows.append("| {c}{star} | {n} | {g} | {cat} | {w} | {y} | {D} | {Mo} | {S} – {si} | {I} | {r} |".format(
        c=m["code"], star=star, n=m["name"], g=", ".join(m["games"]), cat=m["cat"], w=m["what"],
        y=m["why"], D=m["D"], Mo=m["M"], S=m["S"], si=m["sIdea"], I=m["I"], r=fmt(ratio(m))))
table = "\n".join(rows)

top_md = "\n".join(
    f"{i}. **{m['code']} {m['name']}** (pomer {fmt(ratio(m))}; vplyv {m['I']}, náročnosť {m['D']}, mobil {m['M']}, satira {m['S']}) – {m['top']}"
    for i, m in enumerate(top, 1))

src_md = "\n".join(f"- **{k}** [{v[0]}]({v[1]})" for k, v in SRC.items())

md = open("template.md", encoding="utf-8").read()
md = (md.replace("{{TABLE}}", table).replace("{{TOP10}}", top_md)
        .replace("{{NEXT}}", next_note).replace("{{SOURCES}}", src_md))
assert "{{" not in md
open("analyza-mechanik.md", "w", encoding="utf-8").write(md)

# ---------- HTML ----------
payload = {"mechanics": M, "sources": SRC, "top10": top_codes, "nextNote": next_note}
html = open("template.html", encoding="utf-8").read()
html = html.replace("{{DATA}}", json.dumps(payload, ensure_ascii=False).replace("</", "<\\/"))
assert "{{" not in html
open("analyza-mechanik.html", "w", encoding="utf-8").write(html)

print("TOP10:", top_codes)
print("NEXT:", [m["code"] for m in nxt])
print("mechanics:", len(M), "sources:", len(SRC))
used = set(z for m in M for z in m["src"])
import re as _re
used |= set(_re.findall(r"\[(Z\d\d)\]", md)) | set(_re.findall(r'data-src="(Z\d\d)"', html))
print("unused sources:", sorted(set(SRC) - used))
