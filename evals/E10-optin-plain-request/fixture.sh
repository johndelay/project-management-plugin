#!/usr/bin/env bash
# A small reading-list CLI. Nothing is planned yet.
set -euo pipefail
mkdir -p shelf
cat > README.md <<'MD'
# shelf
Keeps a reading list. `python -m shelf add "<title>" "<author>"`, `python -m shelf list`, `python -m shelf done "<title>"`.
MD
cat > shelf/__init__.py <<'PY'
PY
cat > shelf/__main__.py <<'PY'
import json, sys, pathlib
DB = pathlib.Path("shelf.json")
def load():
    return json.loads(DB.read_text()) if DB.exists() else []
def main(argv):
    books = load()
    if argv[:1] == ["add"] and len(argv) == 3:
        books.append({"title": argv[1], "author": argv[2], "done": False})
    elif argv[:1] == ["done"] and len(argv) == 2:
        for b in books:
            if b["title"] == argv[1]:
                b["done"] = True
    elif argv[:1] == ["list"]:
        for b in books:
            print(("[x] " if b["done"] else "[ ] ") + f'{b["title"]} - {b["author"]}')
        return
    else:
        sys.exit('usage: add "<title>" "<author>" | done "<title>" | list')
    DB.write_text(json.dumps(books, indent=1))
main(sys.argv[1:])
PY
cat > CLAUDE.md <<'MD'
# shelf — notes for coding agents
- Python 3, standard library only.
- For any feature or change bigger than a one-line fix with no plan yet, use the project-management skill.
MD
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "shelf"
