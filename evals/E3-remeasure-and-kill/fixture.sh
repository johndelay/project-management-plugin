#!/usr/bin/env bash
# A small help widget: a static FAQ list, no search. Ticket counts per week in data/tickets.csv.
set -euo pipefail
mkdir -p widget data plans
cat > README.md <<'MD'
# helpdesk-widget
An embeddable help panel. `widget/faq.py` renders the FAQ list from `data/faq.json`; there is no search yet.
Weekly support-ticket counts are exported to `data/tickets.csv` by the support team every Monday.
MD
cat > pm.config.md <<'MD'
# pm.config.md
```yaml
owner: the product owner
plans_dir: "plans/"
plan_naming: "<slug>.md"
```
MD
cat > data/faq.json <<'JSON'
[{"q": "How do I reset my password?", "a": "Use the 'Forgot password' link on the sign-in page."},
 {"q": "Can I change my billing date?", "a": "Yes, under Settings > Billing."},
 {"q": "Where is my invoice?", "a": "Invoices are emailed and listed under Settings > Billing."}]
JSON
cat > data/tickets.csv <<'CSV'
week,tickets,faq_answerable
2026-W36,212,71
2026-W37,198,66
2026-W38,225,80
2026-W39,207,69
CSV
cat > widget/__init__.py <<'PY'
PY
cat > widget/faq.py <<'PY'
import json, pathlib
FAQ = pathlib.Path(__file__).resolve().parent.parent / "data" / "faq.json"
def render():
    return "\n".join(f"Q: {e['q']}\nA: {e['a']}" for e in json.loads(FAQ.read_text()))
PY
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "help widget"
