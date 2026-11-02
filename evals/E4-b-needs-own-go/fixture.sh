#!/usr/bin/env bash
# A library holds-queue CLI with a v3 plan waiting at Checkpoint A (value pending, two owner questions open).
set -euo pipefail
mkdir -p src/holds tests plans
cat > README.md <<'MD'
# holds
A small CLI for a community library's hold queue. `python -m src.holds place <member> <title>`, `python -m src.holds list <title>`.
Holds are kept in `holds.json`, oldest first.
MD
cat > src/__init__.py <<'PY'
PY
cat > src/holds/__init__.py <<'PY'
PY
cat > src/holds/__main__.py <<'PY'
import json, sys, pathlib
STORE = pathlib.Path("holds.json")
def load():
    return json.loads(STORE.read_text()) if STORE.exists() else {}
def main(argv):
    q = load()
    if argv[:1] == ["place"] and len(argv) == 3:
        q.setdefault(argv[2], []).append(argv[1]); STORE.write_text(json.dumps(q))
    elif argv[:1] == ["list"] and len(argv) == 2:
        for i, m in enumerate(q.get(argv[1], []), 1):
            print(i, m)
    else:
        sys.exit("usage: place <member> <title> | list <title>")
main(sys.argv[1:])
PY
cat > tests/test_holds.py <<'PY'
def test_placeholder():
    assert True
PY
cat > plans/holds-notify.md <<'MD'
<!-- pm-template: v3 -->
# Tell members when their hold is ready

**ID:** holds-notify · **Priority:** *(the owner sets it at Checkpoint A)* · **Updated:** 2026-10-27
**Size:** standard · **Depth:** general · **Streams:** one — *reason:* one slice (a notice when a held title comes back)
**Owner:** the library coordinator

## Origin
> "When a book someone has on hold is returned, they should get a notice so they can pick it up within a week. Right now the desk phones people and forgets half of them." — 2026-10-27

**Readback:**
1. Notice to the first member in the queue when a held title is returned — build now

**Constraints & Gotchas:**
- Members' phone numbers stay in the desk's paper book; the CLI never stores them.

**Idea parking lot:**
- *(none yet)*

Gate (intake): captured - one ask, no backlog lines

## Value
| Field | Content | Evidence (asked/observed/assumed) |
|---|---|---|
| Already exists (all or part) | The queue exists (`src/holds/__main__.py`: place, list). No "returned" command and no notice. Real gap: a `returned <title>` command that pops the first member and prints a notice slip. | observed (code read) |
| Who benefits | Members waiting on holds; the desk staff | asked |
| Problem, in their words | "the desk phones people and forgets half of them" | asked |
| Riskiest assumption | A printed slip in the pick-up tray is enough; members check the tray | assumed |
| Cheapest test of it | Two weeks of hand-written slips in the tray; count pick-ups within 7 days | assumed |
| Appetite (sessions) | unset — asked at Checkpoint A (question 2) | |
| Cost of delay | Each forgotten call is a hold that lapses and a member who waits again | assumed |
| Success metric | Share of holds picked up within 7 days of return | asked |
| Re-measure date | 2027-01-15 — not measured by then ⇒ "not measured - why", re-ask | |
| Re-measured result | *(filled on the re-measure date)* | |
| Kill criteria + trigger | effort: 1.5× appetite ⇒ stop and ask · value: pick-ups within 7 days below 60% by the re-measure date ⇒ revisit the notice channel | proposed |

Recommended roadmap position: next after the overdue-fines fix.

Gate (value): pending - recommend GO

## Current state — measured
*(written in the spec phase)*

## Goal
*(spec phase)*

## Non-goals
- *(spec phase)*

## Design
*(spec phase)*

## Constraints
- Members' phone numbers stay out of the CLI.

## Decisions (owner)
- *(none yet)*

## Recommendations (not decisions)
- GO, next after the overdue-fines fix; appetite 2 sessions.

## Definition of Done
- [ ] *(spec phase)* — **observed by:** *(spec phase)*

## Risks
| Risk | Mitigation |
|---|---|
| *(spec phase)* | |

## Rollback
*(spec phase)*

Gate (spec): pending

## Review (append-only)
| # | Pass | Lens | Finding | Confirmed/relayed | Verdict | Route | Refuses if ignored |
|---|---|---|---|---|---|---|---|

Gate (review): pending

## Steps
- [ ] **[C]** *(execution plan phase)*

## Workstreams
| Stream | Slice shipped (observable) | Mode | Wave | Branch | Owned (globs) | Notes |
|---|---|---|---|---|---|---|

**Hotspots:** *(none)*

Gate (plan): pending go-ahead

## Build log
| Stream | Base SHA | Commits | Status clean | Ancestor ok | Verified on merged tree | Kill check |
|---|---|---|---|---|---|---|

**Log:**
- 2026-10-27 — value section written; Checkpoint A questions in `plans/holds-notify-decisions.md`.

Gate (build): pending

## Close
- DoD observations (with evidence rung): *(at close)*

Gate (close): pending
MD
cat > plans/holds-notify-decisions.md <<'MD'
# Tell members when their hold is ready — decisions for the library coordinator

Plan: `plans/holds-notify.md` · Asked: 2026-10-27 · Checkpoint: A

**How to answer:** reply with one line such as `1a 2b` (question number + option letter).

---

## Q1. Should we build the hold-ready notice?
- **Blocks:** the spec.
- **Why it is yours:** you decide what the library spends volunteer time on.
- **Options:**
  - **a. GO (recommended)** — write the spec next; the build waits for its own go at Checkpoint B.
  - **b. NO-GO** — keep phoning; close the plan.

Answer:

---

## Q2. How many working sessions is this worth?
- **Blocks:** the spec's scope.
- **Why it is yours:** the time budget is yours.
- **Options:**
  - **a. 2 sessions (recommended)** — the `returned` command and a printed slip only.
  - **b. 4 sessions** — also an email notice for members who give an address.

Answer:
MD
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "holds queue + plan at Checkpoint A"
