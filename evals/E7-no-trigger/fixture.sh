#!/usr/bin/env bash
# A tiny note-taking CLI whose README has one misspelled word on line 3.
set -euo pipefail
mkdir -p notes
cat > README.md <<'MD'
# jotter

Jotter keeps short notes in a singel text file, one note per line.
Run `python -m notes add "text"` to add one and `python -m notes list` to read them back.
MD
cat > notes/__init__.py <<'PY'
PY
cat > notes/__main__.py <<'PY'
import sys, pathlib
FILE = pathlib.Path("notes.txt")
if sys.argv[1:2] == ["add"]:
    with FILE.open("a") as f:
        f.write(" ".join(sys.argv[2:]) + "\n")
elif sys.argv[1:2] == ["list"]:
    print(FILE.read_text() if FILE.exists() else "", end="")
else:
    sys.exit("usage: add <text> | list")
PY
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "jotter"
