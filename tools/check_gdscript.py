"""
VOLYA - catch GDScript edits that split a function in half.

A script that fails to compile takes everything with it: the class stops
existing, so an enemy pool builds sixty-four nodes that do nothing and the game
comes up with no enemies at all. Nothing says why - not the export, not the
device - and the symptom looks like a gameplay bug rather than a syntax one.

This has happened twice, both times the same way: an edit inserted a function
definition in the middle of another function, and the code below it kept
referring to the parameters of the function it used to be in.

So that is what is checked. For each function, any identifier that is a
parameter of some OTHER function in the file, but not of this one and not a
local or a member, is reported. Narrow on purpose - it does not try to be a
type checker, and it does not guess at Godot's built-ins.

    python tools/check_gdscript.py volya/scripts/*.gd

Exits nonzero if anything is found, so it can gate a deploy.
"""

import glob
import re
import sys

FUNC = re.compile(r"^(\t*)func\s+([A-Za-z_]\w*)\s*\((.*?)\)\s*(?:->\s*[\w\.\[\], ]+)?\s*:")
MEMBER = re.compile(r"^(?:@export\S*\s+)?(?:var|const|signal)\s+([A-Za-z_]\w*)")
LOCAL = re.compile(r"^\s*(?:var|const)\s+([A-Za-z_]\w*)")
FOR_LOOP = re.compile(r"^\s*for\s+([A-Za-z_]\w*)\s+in\b")
IDENT = re.compile(r"[A-Za-z_]\w*")

# Identifiers that appear on the left of a colon in a signature are parameters.
PARAM = re.compile(r"([A-Za-z_]\w*)\s*(?::|=|,|$)")


def parse_params(text):
    names = []
    depth = 0
    current = ""
    for ch in text:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            names.append(current)
            current = ""
        else:
            current += ch
    if current.strip():
        names.append(current)

    out = []
    for chunk in names:
        chunk = chunk.strip()
        if not chunk:
            continue
        match = PARAM.match(chunk)
        if match:
            out.append(match.group(1))
    return out


def strip_code(line):
    """Drop comments and string literals so their contents are not read as code."""
    line = re.sub(r'"[^"]*"', '""', line)
    line = re.sub(r"'[^']*'", "''", line)
    hash_at = line.find("#")
    if hash_at >= 0:
        line = line[:hash_at]
    return line


def check(path):
    lines = open(path, encoding="utf-8").read().split("\n")

    members = set()
    functions = []          # (name, line_index, params, body_line_indices)
    for i, raw in enumerate(lines):
        code = strip_code(raw)
        m = MEMBER.match(code.strip()) if not code.startswith(("\t", " ")) else None
        if m:
            members.add(m.group(1))
        f = FUNC.match(code)
        if f:
            members.add(f.group(2))
            functions.append([f.group(2), i, parse_params(f.group(3)), []])

    for index, entry in enumerate(functions):
        start = entry[1] + 1
        end = functions[index + 1][1] if index + 1 < len(functions) else len(lines)
        entry[3] = list(range(start, end))

    all_params = set()
    for name, _, params, _ in functions:
        all_params.update(params)

    problems = []
    for name, header_line, params, body in functions:
        known = set(params) | members
        for i in body:
            code = strip_code(lines[i])
            local = LOCAL.match(code)
            if local:
                known.add(local.group(1))
            loop = FOR_LOOP.match(code)
            if loop:
                known.add(loop.group(1))
            # lambdas bring their own parameters
            for lam in re.finditer(r"func\s*\((.*?)\)", code):
                known.update(parse_params(lam.group(1)))

            for token in IDENT.finditer(code):
                word = token.group(0)
                if word in known or word not in all_params:
                    continue
                before = code[:token.start()].rstrip()
                if before.endswith(".") or before.endswith("func "):
                    continue
                problems.append(
                    (i + 1, name, word,
                     "je parameter inej funkcie, tu nie je definovany"))
    return problems


def main():
    paths = []
    for arg in sys.argv[1:]:
        paths.extend(sorted(glob.glob(arg)))
    if not paths:
        sys.exit(__doc__.strip())

    total = 0
    for path in paths:
        found = check(path)
        if not found:
            continue
        total += len(found)
        print()
        print("== %s" % path)
        for line_no, func, word, why in found:
            print("  riadok %d, vo funkcii %s: '%s' %s"
                  % (line_no, func, word, why))

    print()
    if total:
        print("VOLYA: %d podozrivych miest. Skript sa pravdepodobne "
              "neskompiluje a hra pride o cely tento uzol." % total)
        return 1
    print("VOLYA: ziadne rozdelene funkcie.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
