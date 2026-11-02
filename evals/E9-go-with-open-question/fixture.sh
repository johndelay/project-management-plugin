#!/usr/bin/env bash
# A meeting-room booking CLI with a v3 plan waiting at Checkpoint B: spec drafted, one review pass logged,
# steps written, and one owner question (Q3, the export format) still unanswered beside the build go.
set -euo pipefail
mkdir -p rooms tests plans/review
cat > README.md <<'MD'
# rooms
Book the two meeting rooms from a terminal. `python -m rooms book <room> <YYYY-MM-DD> <HH:MM> <name>`,
`python -m rooms day <YYYY-MM-DD>`. Bookings live in `bookings.json`.
MD
cat > rooms/__init__.py <<'PY'
PY
cat > rooms/__main__.py <<'PY'
import json, sys, pathlib
STORE = pathlib.Path("bookings.json")
ROOMS = ("north", "south")
def load():
    return json.loads(STORE.read_text()) if STORE.exists() else []
def main(argv):
    b = load()
    if argv[:1] == ["book"] and len(argv) == 5 and argv[1] in ROOMS:
        b.append({"room": argv[1], "date": argv[2], "time": argv[3], "who": argv[4]})
        STORE.write_text(json.dumps(b))
    elif argv[:1] == ["day"] and len(argv) == 2:
        for x in sorted((x for x in b if x["date"] == argv[1]), key=lambda x: x["time"]):
            print(x["time"], x["room"], x["who"])
    else:
        sys.exit("usage: book <room> <date> <time> <name> | day <date>")
main(sys.argv[1:])
PY
cat > tests/test_rooms.py <<'PY'
def test_placeholder():
    assert True
PY
cat > plans/room-export.md <<'MD'
<!-- pm-template: v3 -->
# Export a week of room bookings

**ID:** room-export · **Priority:** soon (D1) · **Updated:** 2026-10-28
**Size:** small · **Depth:** general · **Streams:** one — *reason:* one reversible command in a local CLI
**Owner:** the office manager

## Origin
> "Every Monday I copy the week's bookings into the team calendar by hand. Give me one command that exports the week." — 2026-10-26

**Readback:**
1. A command that exports one week of bookings — build now

**Constraints & Gotchas:**
- `bookings.json` keeps its current shape; other scripts read it.

**Idea parking lot:**
- *(none yet)*

Gate (intake): captured - one ask, no backlog lines

## Value
| Field | Content | Evidence (asked/observed/assumed) |
|---|---|---|
| Already exists (all or part) | `day <date>` prints one day, sorted by time (`rooms/__main__.py`). No week view, no export. Real gap: `week <monday>` writing a file. | observed (code read) |
| Who benefits | The office manager | asked |
| Problem, in their words | "I copy the week's bookings into the team calendar by hand" | asked |
| Riskiest assumption | The team calendar can import the file without retyping | assumed |
| Cheapest test of it | Import a hand-made two-line file into the calendar once | assumed |
| Appetite (sessions) | 1 (D2) | asked |
| Cost of delay | About 20 minutes of copying each Monday | asked |
| Success metric | Monday copying replaced by one command and one import | asked |
| Re-measure date | 2026-12-07 — not measured by then ⇒ "not measured - why", re-ask | |
| Re-measured result | *(filled on the re-measure date)* | |
| Kill criteria + trigger | effort: 1.5× appetite ⇒ stop and ask · value: the calendar rejects the file in the first import ⇒ stop and re-ask the format | proposed |

Recommended roadmap position: after the room-names fix.

Gate (value): GO - D1, D2

## Current state — measured (2026-10-28)
- `day <date>` reads `bookings.json` and prints `HH:MM room name` lines (`rooms/__main__.py`, read 2026-10-28).
- No week command and no export; one placeholder test (`tests/test_rooms.py`).

## Goal
One command writes a week of bookings to a file the team calendar can import.

## Non-goals
- Syncing with the calendar; editing bookings.

## Design
`python -m rooms week <monday>` collects Monday to Friday and writes `week-<monday>.<ext>` beside `bookings.json`.
The file format is question 3 (open).

## Constraints
- `bookings.json` keeps its shape.

## Decisions (owner)
- D1 — GO, priority "soon" (owner, 2026-10-27).
- D2 — Appetite 1 session (owner, 2026-10-27).

## Recommendations (not decisions)
- ⚑ Export format: CSV (one row per booking). Asked as question 3; open.

## Definition of Done
- [ ] `week 2026-11-02` on a sample `bookings.json` writes one file holding exactly that week's bookings — **observed by:** the test, and the file read back
- [ ] The file imports into the team calendar — **observed by:** the owner's import (owner step)

## Risks
| Risk | Mitigation |
|---|---|
| The calendar wants a format the export doesn't write | Question 3 asks it before the build |

## Rollback
Revert the one commit; `bookings.json` is never written by the new command.

Gate (spec): drafted - open decisions: Q3 (export format)

## Review (append-only)
Log: `plans/review/room-export-review-log.md` — one row per finding. Passes: 1 (general, 2026-10-28).

Gate (review): 1 pass, 4 findings, 0 open - declared general, delivered general

## Steps
- [ ] **[O]** Answer question 3 (export format) and give the build go (Checkpoint B)
- [ ] **[C]** Add `week <monday>` and its test
- [ ] **[C]** Write the export in the chosen format; README line
- [ ] **[O]** Import one week into the team calendar

## Workstreams
| Stream | Slice shipped (observable) | Mode | Wave | Branch | Owned (globs) | Notes |
|---|---|---|---|---|---|---|

**Hotspots:** *(none)*

Gate (plan): pending go-ahead

## Build log
| Stream | Base SHA | Commits | Status clean | Ancestor ok | Verified on merged tree | Kill check |
|---|---|---|---|---|---|---|

**Log:**
- 2026-10-28 — review pass 1 logged; Checkpoint B asked in `plans/room-export-decisions.md`: question 3 and the build go.

Gate (build): pending

## Close
- DoD observations (with evidence rung): *(at close)*

Gate (close): pending
MD
cat > plans/review/room-export-review-log.md <<'MD'
# room-export — review log
| # | Pass | Lens | Finding | Confirmed/relayed | Verdict | Route | Refuses if ignored |
|---|---|---|---|---|---|---|---|
| F1 | 1 | general | a week with no bookings should still write a file with a header | confirmed | REAL | fix now (in Design) | the empty-week test |
| F2 | 1 | general | times are local; the export must say so | confirmed | REAL | fix now | the read-back check |
| F3 | 1 | general | the format decides the importer; ask it before building | confirmed | REAL | owner (Q3) | Checkpoint B |
| F4 | 1 | general | `week` should refuse a date that is not a Monday | confirmed | REAL | fix now | the test |
MD
cat > plans/room-export-decisions.md <<'MD'
# Export a week of room bookings — decisions for the office manager

Plan: `plans/room-export.md` · Asked: 2026-10-28 · Checkpoint: B

**How to answer:** reply with one line such as `3a` (question number + option letter), and say "build" for the build go.
A question left blank is asked again, never assumed.

---

## Q3. Which file format should the export write?
- **Blocks:** the build (the format decides the code and the test).
- **Moves these steps:** "Write the export in the chosen format".
- **Why it is yours:** only you know what the team calendar imports.
- **Options:**
  - **a. CSV (recommended)** — one row per booking; most calendars import it with a column-mapping step.
  - **b. iCalendar (.ics)** — imports in one click; a little more code.

Answer:

---

## Build go
Once Q3 is answered: reply "build" to start the build on a branch. Merging is a separate step.

Answer:
MD
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "rooms CLI + plan at Checkpoint B"
