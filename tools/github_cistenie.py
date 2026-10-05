"""
Slavs - jednorazove vycistenie historie na GitHube (odstrani stare 3D subory z historie).

Spusti z priecinka hry:   python tools\github_cistenie.py

Co robi a preco je to bezpecne:
  1. Spravi uplnu zalohu celej historie do priecinka vedla projektu
     (slavs_zaloha_<datum>.git). Z nej sa da vsetko obnovit.
  2. Stiahne cistu kopiu z GitHubu a odstrani z jej historie stare 3D subory.
  3. Overi, ze POSLEDNY stav projektu je po cisteni IDENTICKY (porovna odtlacok
     stromu suborov). Ak sa lisi, nic sa neodosle.
  4. Spyta sa ta (napis ANO) a az potom prepise GitHub.
  5. Tvoj pracovny priecinok sa nemeni (subory, necommitnute zmeny aj ignorovane
     subory ostanu); prestavi sa mu len historia na novu.

Ak sa nieco pokazi po odoslani, obnova zo zalohy:
  git push --force --mirror <url> (spustene v priecinku zalohy)
"""
import argparse
import datetime
import os
import re
import shutil
import subprocess
import sys

DEFAULT_URL = "https://github.com/belispav/slavs.git"

# Co sa z historie odstrani: stary 3D retaz (Meshy -> Mixamo -> Blender -> pixelize).
FILTER_ARGS = [
    "--path", "tools/blender",
    "--path", "art/fits",
    "--path", "ref/objects/Club",
    "--path-regex", r"^slavs/art/[^/]*_px/",
    "--path-regex", r"^slavs/art/hero_run/",
    "--path-glob", "*.blend",
    "--path-glob", "*.blend1",
    "--path-glob", "*.fbx",
    "--path-glob", "*.FBX",
    "--path-glob", "*.glb",
    "--path-glob", "*.max",
    "--path-glob", "*.obj",
    "--path-glob", "*.mtl",
]


def say(text=""):
    print(text, flush=True)


STATE = {"rewritten": False}


def die(text):
    say("")
    say("STOP: " + text)
    if STATE["rewritten"]:
        say("Historia na GitHube UZ BOLA prepisana, ale posledny krok sa nedokoncil.")
        say("Posledny stav projektu je v poriadku. Napis mi, co sa vypisalo, a dokoncim to.")
    else:
        say("Nic sa na GitHube nezmenilo.")
    sys.exit(1)


def git(args, cwd=None, check=True):
    result = subprocess.run(["git"] + args, cwd=cwd, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, text=True,
                            encoding="utf-8", errors="replace")
    if check and result.returncode != 0:
        die("git %s zlyhalo:\n%s" % (" ".join(args), result.stderr.strip()))
    return result.stdout.strip()


def git_live(args, cwd=None):
    """Same as git() but shows progress (clone, push can take a while)."""
    result = subprocess.run(["git"] + args, cwd=cwd)
    if result.returncode != 0:
        die("git %s zlyhalo." % " ".join(args))


def content_size(cwd):
    """Total size of all files ever stored in the history (not compressed), in MB."""
    text = git(["cat-file", "--batch-all-objects", "--batch-check=%(objecttype) %(objectsize)"], cwd=cwd)
    total = 0
    for line in text.splitlines():
        kind, _, size = line.partition(" ")
        if kind == "blob":
            total += int(size)
    return "%.0f MB" % (total / (1024.0 * 1024.0))


def shrink(cwd):
    git(["reflog", "expire", "--expire=now", "--all"], cwd=cwd)
    git(["gc", "--prune=now", "-q"], cwd=cwd)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default=DEFAULT_URL)
    parser.add_argument("--repo", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    parser.add_argument("--yes", action="store_true", help="bez otazky (len na testy)")
    parser.add_argument("--min-gb", type=float, default=3.0, help="minimum volneho miesta (len na testy)")
    opts = parser.parse_args()
    repo = os.path.abspath(opts.repo)
    parent = os.path.dirname(repo)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M")
    backup = os.path.join(parent, "slavs_zaloha_%s.git" % stamp)
    clean = os.path.join(parent, "slavs_cisty_%s" % stamp)

    say("== Slavs: vycistenie historie GitHubu ==")
    say("Projekt:  " + repo)
    say("GitHub:   " + opts.url)

    # 0. tools and disk space (backup + clean copy + work area, about 3 GB)
    git(["--version"])
    free_gb = shutil.disk_usage(parent).free / (1024.0 ** 3)
    if free_gb < opts.min_gb:
        die("na disku je volne len %.1f GB, treba aspon %.0f GB." % (free_gb, opts.min_gb))
    try:
        import git_filter_repo  # noqa: F401
    except ImportError:
        say("Instalujem git-filter-repo (jednorazovo)...")
        code = subprocess.run([sys.executable, "-m", "pip", "install", "--user", "git-filter-repo"]).returncode
        if code != 0:
            die("nepodarilo sa nainstalovat git-filter-repo (pip install --user git-filter-repo).")

    # 1. local state vs GitHub
    main_branch = git(["rev-parse", "--abbrev-ref", "HEAD"], cwd=repo)
    if main_branch in ("HEAD", ""):
        die("projekt nie je na vetve (detached HEAD).")
    git(["fetch", "origin"], cwd=repo)
    counts = git(["rev-list", "--left-right", "--count", "HEAD...origin/" + main_branch], cwd=repo).split()
    ahead, behind = int(counts[0]), int(counts[1])
    if behind > 0:
        die("na GitHube je novsia verzia (%d commitov). Najprv spusti: git pull" % behind)
    if ahead > 0:
        say("Posielam %d cakajuce commity na GitHub (obycajny push)..." % ahead)
        git_live(["push", "origin", main_branch], cwd=repo)
    local_head = git(["rev-parse", "HEAD"], cwd=repo)

    # 2. backup
    say("")
    say("1/6 Zaloha celej historie -> " + backup)
    git_live(["clone", "--mirror", "--no-hardlinks", repo, backup])

    # 3. clean clone
    say("")
    say("2/6 Cista kopia z GitHubu -> " + clean)
    git_live(["clone", opts.url, clean])
    if git(["rev-parse", "HEAD"], cwd=clean) != local_head:
        die("cista kopia nema rovnaky posledny commit ako tvoj projekt.")

    # 4. other remote branches must be fully merged, else we would lose work
    others = []
    for name in git(["branch", "-r", "--format=%(refname:short)"], cwd=clean).splitlines():
        name = name.strip()
        if not name.startswith("origin/") or name in ("origin/HEAD", "origin/" + main_branch):
            continue
        merged = subprocess.run(["git", "merge-base", "--is-ancestor", name, "origin/" + main_branch],
                                cwd=clean).returncode == 0
        if not merged:
            die("vetva %s ma necommitnutu pracu, ktora nie je v %s. Najprv ju zluc alebo zmaz." % (name, main_branch))
        others.append(name[len("origin/"):])
    say("Dalsie vetvy na GitHube (vsetky zlucene, zmazu sa): " + (", ".join(others) if others else "ziadne"))

    # 5. rewrite
    say("")
    say("3/6 Meriam velkost pred cistenim...")
    before = content_size(clean)
    old_tree = git(["rev-parse", "HEAD^{tree}"], cwd=clean)
    old_count = git(["rev-list", "--count", "HEAD"], cwd=clean)

    say("4/6 Odstranujem stare 3D subory z historie...")
    code = subprocess.run([sys.executable, "-m", "git_filter_repo", "--force", "--invert-paths"] + FILTER_ARGS,
                          cwd=clean).returncode
    if code != 0:
        die("git-filter-repo zlyhal.")
    shrink(clean)
    after = content_size(clean)
    new_tree = git(["rev-parse", "HEAD^{tree}"], cwd=clean)
    new_count = git(["rev-list", "--count", "HEAD"], cwd=clean)

    say("")
    say("5/6 Kontrola:")
    say("   obsah historie (subory bez kompresie): %s  ->  %s" % (before, after))
    say("   pocet commitov:    %s  ->  %s" % (old_count, new_count))
    say("   stav projektu (odtlacok stromu): %s" % ("IDENTICKY" if old_tree == new_tree else "ROZDIELNY"))
    if old_tree != new_tree:
        die("posledny stav projektu by sa po cisteni zmenil. Nic neposielam.")

    # 6. confirm + push
    say("")
    say("Zaloha je v: " + backup)
    say("Teraz sa PREPISE historia na GitHube a zmazu sa vetvy: " + (", ".join(others) if others else "(ziadne)"))
    if not opts.yes:
        answer = input("Napis ANO a stlac Enter (cokolvek ine = koniec, nic sa neodosle): ").strip()
        if answer != "ANO":
            say("Koncim. Nic sa na GitHube nezmenilo. Zalohu a pomocny priecinok mozes zmazat.")
            return
    git(["remote", "add", "origin", opts.url], cwd=clean)
    say("6/6 Odosielam...")
    git_live(["push", "--force", "origin", main_branch], cwd=clean)
    STATE["rewritten"] = True
    for name in others:
        git_live(["push", "origin", "--delete", name], cwd=clean)

    # 7. re-point the working folder at the new history, files untouched
    git(["fetch", "--prune", "origin"], cwd=repo)
    git(["reset", "--mixed", "origin/" + main_branch], cwd=repo)
    shrink(repo)
    say("")
    say("HOTOVO.")
    say("  Obsah historie: %s -> %s (stiahnutie je zhruba o 30 % mensie)" % (before, after))
    say("  Tvoj projekt: subory a necommitnute zmeny su nedotknute, historia je nova.")
    say("  Zaloha (zmazat po tyzdni, ak je vsetko v poriadku): " + backup)
    say("  Pomocny priecinok (mozes hned zmazat): " + clean)
    say("  Cloudove session sa budu klonovat uz z cistej verzie. Rozpracovane stare cloud session ukonci.")
    say("  GitHub uvolni miesto na svojej strane casom (vlastny upratovaci proces).")


if __name__ == "__main__":
    main()
