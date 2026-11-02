#!/usr/bin/env bash
# A small recipe CLI. A shopping-list helper is half-built: the aggregation exists, nothing calls it.
set -euo pipefail
mkdir -p recipes data tests
cat > README.md <<'MD'
# recipe-box
A command-line recipe book. `python -m recipes list`, `python -m recipes show <name>`.
Recipes live in `data/recipes.json`.
MD
cat > data/recipes.json <<'JSON'
[{"name": "pancakes", "servings": 4, "ingredients": [["flour", 200, "g"], ["milk", 300, "ml"], ["egg", 2, ""]]},
 {"name": "omelette", "servings": 1, "ingredients": [["egg", 3, ""], ["butter", 10, "g"]]}]
JSON
cat > recipes/__init__.py <<'PY'
PY
cat > recipes/store.py <<'PY'
import json, pathlib
DATA = pathlib.Path(__file__).resolve().parent.parent / "data" / "recipes.json"
def load():
    return json.loads(DATA.read_text())
def find(name):
    return next((r for r in load() if r["name"] == name), None)
PY
cat > recipes/shopping.py <<'PY'
# Shopping list: sum ingredients across several recipes.
# Started but not wired to the CLI yet (no command calls this).
from collections import defaultdict
def combine(recipes):
    totals = defaultdict(float)
    for r in recipes:
        for item, qty, unit in r["ingredients"]:
            totals[(item, unit)] += qty
    return [(item, qty, unit) for (item, unit), qty in sorted(totals.items())]
PY
cat > recipes/__main__.py <<'PY'
import sys
from . import store
def main(argv):
    if argv[:1] == ["list"]:
        for r in store.load():
            print(r["name"])
    elif argv[:1] == ["show"] and len(argv) == 2:
        r = store.find(argv[1])
        if not r:
            sys.exit("no such recipe")
        for item, qty, unit in r["ingredients"]:
            print(f"{qty:g}{unit} {item}")
    else:
        sys.exit("usage: list | show <name>")
main(sys.argv[1:])
PY
cat > tests/test_store.py <<'PY'
from recipes import store
def test_find():
    assert store.find("pancakes")["servings"] == 4
PY
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "recipe box"
