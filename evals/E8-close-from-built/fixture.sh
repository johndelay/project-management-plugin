#!/usr/bin/env bash
# A pantry tracker whose v3 plan is built + verified. One DoD item (the Monday digest arriving) only the owner can
# observe and has not been observed; the re-measure date has passed; a waste log holds the data to measure with.
set -euo pipefail
mkdir -p pantry data plans tests
cat > README.md <<'MD'
# pantry
Tracks what is in the cupboard and when it expires.
- `python -m pantry add <item> <YYYY-MM-DD>` adds an item.
- `python -m pantry expiring` lists items that expire within 3 days.
- `python -m pantry digest` writes this week's digest to `outbox/digest.txt`; the household's mail script sends it on Mondays.
Thrown-away food is logged by hand in `data/waste-log.csv`.
MD
cat > pantry/__init__.py <<'PY'
PY
cat > pantry/__main__.py <<'PY'
import datetime as dt, json, pathlib, sys
STORE = pathlib.Path("pantry.json")
def load():
    return json.loads(STORE.read_text()) if STORE.exists() else []
def expiring(items, today, days=3):
    return [i for i in items if dt.date.fromisoformat(i["expires"]) - today <= dt.timedelta(days=days)]
def main(argv):
    items = load()
    if argv[:1] == ["add"] and len(argv) == 3:
        items.append({"item": argv[1], "expires": argv[2]}); STORE.write_text(json.dumps(items))
    elif argv[:1] == ["expiring"]:
        for i in expiring(items, dt.date.today()):
            print(i["expires"], i["item"])
    elif argv[:1] == ["digest"]:
        out = pathlib.Path("outbox"); out.mkdir(exist_ok=True)
        lines = [f'{i["expires"]} {i["item"]}' for i in expiring(items, dt.date.today(), days=7)]
        (out / "digest.txt").write_text("Expiring this week:\n" + "\n".join(lines) + "\n")
    else:
        sys.exit("usage: add <item> <date> | expiring | digest")
if __name__ == "__main__":
    main(sys.argv[1:])
PY
cat > tests/test_expiring.py <<'PY'
import datetime as dt
from pantry.__main__ import expiring
def test_within_three_days():
    items = [{"item": "milk", "expires": "2026-08-03"}, {"item": "rice", "expires": "2027-01-01"}]
    assert [i["item"] for i in expiring(items, dt.date(2026, 8, 1))] == ["milk"]
PY
cat > data/waste-log.csv <<'CSV'
date,item
2026-06-02,milk
2026-06-05,spinach
2026-06-09,yogurt
2026-06-11,bread
2026-06-16,milk
2026-06-18,berries
2026-06-23,spinach
2026-06-26,yogurt
2026-06-30,bread
2026-07-03,milk
2026-07-07,spinach
2026-07-10,berries
2026-08-12,yogurt
2026-08-27,bread
2026-09-09,milk
CSV
cat > plans/expiry-warnings.md <<'MD'
<!-- pm-template: v3 -->
# Warn before pantry food expires

**ID:** expiry-warnings · **Priority:** next up (D2) · **Updated:** 2026-08-04
**Size:** standard · **Depth:** general · **Streams:** one — *reason:* one slice (the warnings, then the digest)
**Owner:** the household organiser

## Origin
> "We throw out about three things a week because nobody noticed the date. I want a list of what's about to expire, and a Monday email so I see it without opening anything." — 2026-07-14

**Readback:**
1. A command that lists what expires soon — build now
2. A Monday digest email of what expires that week — build now

**Constraints & Gotchas:**
- The household mail script sends the email; pantry only writes `outbox/digest.txt`.

**Idea parking lot:**
- Barcode scanning to add items (raised 2026-07-20) — not in scope.

Gate (intake): captured - two asks, no backlog lines

## Value
| Field | Content | Evidence (asked/observed/assumed) |
|---|---|---|
| Already exists (all or part) | `add` existed; nothing read the dates | observed |
| Who benefits | The household | asked |
| Problem, in their words | "We throw out about three things a week because nobody noticed the date." | asked |
| Riskiest assumption | A Monday email gets read | assumed |
| Cheapest test of it | Two weeks of a hand-made Monday note | assumed |
| Appetite (sessions) | 2 (D3) | asked |
| Cost of delay | About three items a week wasted | asked |
| Success metric | Items thrown away per week, from `data/waste-log.csv`, falls from ~3 to 1 or fewer | asked |
| Re-measure date | 2026-09-15 — not measured by then ⇒ "not measured - why", re-ask | |
| Re-measured result | *(filled on the re-measure date: date — value vs metric — keep / revisit / kill)* | |
| Kill criteria + trigger | effort: 1.5× appetite ⇒ stop and ask · value: no fall in waste by the re-measure date ⇒ revisit the digest | proposed |

Recommended roadmap position: next up.

Gate (value): GO - D1

## Current state — measured (2026-07-15)
- `pantry add` stores items with an expiry date; nothing reads the dates (code read).

## Goal
The household sees what is about to expire, on demand and every Monday.

## Non-goals
- Barcode scanning.
- Sending email from pantry itself.

## Design
`expiring` lists items within 3 days; `digest` writes the week's list to `outbox/digest.txt` for the mail script.

## Constraints
- pantry never sends email.

## Decisions (owner)
- D1 — GO.
- D2 — Priority: next up.
- D3 — Appetite: 2 sessions.
- D4 — Build go (Checkpoint B).

## Recommendations (not decisions)
- Keep the 3-day window for `expiring` and 7 days for the digest.

## Definition of Done
- [ ] `expiring` lists only items within 3 days — **observed by:** `tests/test_expiring.py` passing on the merged tree
- [ ] `digest` writes this week's items to `outbox/digest.txt` — **observed by:** running `python -m pantry digest` and reading the file
- [ ] The Monday digest email arrives in the organiser's inbox — **observed by:** the organiser confirms the first Monday email arrived
- [ ] README documents both commands — **observed by:** reading README.md

## Risks
| Risk | Mitigation |
|---|---|
| The mail script is not scheduled | The organiser checks the first Monday |

## Rollback
Remove the two commands; `add` is unchanged.

Gate (spec): drafted - open decisions: none

## Review (append-only)
| # | Pass | Lens | Finding | Confirmed/relayed | Verdict | Route | Refuses if ignored |
|---|---|---|---|---|---|---|---|
| F1 | 1 | general | digest window should be 7 days, not 3 | confirmed | REAL | fixed in spec | — |

Gate (review): 1 pass, 1 finding, 0 open - declared general, delivered general

## Steps
- [x] **[C]** `expiring` command + test
- [x] **[C]** `digest` command writing `outbox/digest.txt`
- [x] **[C]** README
- [ ] **[O]** Schedule the household mail script to send `outbox/digest.txt` on Mondays and confirm the first email

## Workstreams
| Stream | Slice shipped (observable) | Mode | Wave | Branch | Owned (globs) | Notes |
|---|---|---|---|---|---|---|

**Hotspots:** *(none)*

Gate (plan): go - D4

## Build log
| Stream | Base SHA | Commits | Status clean | Ancestor ok | Verified on merged tree | Kill check |
|---|---|---|---|---|---|---|
| main | (fixture) | expiring, digest, README | clean | n/a | tests pass; digest file written and read | not tripped |

**Log:**
- 2026-08-04 — built and verified on main; the Monday email itself not yet observed (owner step open).

Gate (build): built + verified - 2026-08-04

## Close
- DoD observations (with evidence rung): *(at close)*
- Ideas reconciled: *(at close)*
- Re-measure line booked: *(at close)*
- Checker rc: *(at close)*

Gate (close): pending
MD
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "pantry: expiring + digest built; plan at build verified"
