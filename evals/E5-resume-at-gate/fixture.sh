#!/usr/bin/env bash
# A bike-share dock-status CLI with a v3 plan: spec drafted, review pending, and a stale "Phase: build" header.
# A commit made after the plan was written adds tests and moves the feed URL, so a spot-check has something to find.
set -euo pipefail
mkdir -p docks plans
cat > README.md <<'MD'
# dockwatch
Shows how many bikes each dock has. `python -m docks status` reads the city's open dock feed.
MD
cat > docks/__init__.py <<'PY'
PY
cat > docks/feed.py <<'PY'
FEED_URL = "https://feeds.example.invalid/docks/v1.json"
def parse(payload):
    return {d["id"]: d["bikes"] for d in payload["docks"]}
PY
cat > docks/__main__.py <<'PY'
import json, sys
from . import feed
def main(argv):
    if argv[:1] == ["status"] and len(argv) == 2:
        for dock, bikes in sorted(feed.parse(json.load(open(argv[1]))).items()):
            print(dock, bikes)
    else:
        sys.exit("usage: status <feed.json>")
main(sys.argv[1:])
PY
cat > plans/empty-dock-alerts.md <<'MD'
<!-- pm-template: v3 -->
# Alert riders when their usual dock is empty

**ID:** empty-dock-alerts · **Priority:** next up (D2) · **Updated:** 2026-10-20
**Phase:** build
**Size:** standard · **Depth:** general · **Streams:** one — *reason:* one slice (an alert when a watched dock hits zero)
**Owner:** the dockwatch maintainer

## Origin
> "Riders keep walking to an empty dock. Let them watch one dock and get told when it hits zero bikes." — 2026-10-18

**Readback:**
1. Watch one dock per rider; alert when it reaches zero bikes — build now

**Constraints & Gotchas:**
- The city feed is rate-limited to one request per minute per client.

**Idea parking lot:**
- *(none yet)*

Gate (intake): captured - one ask, no backlog lines

## Value
| Field | Content | Evidence (asked/observed/assumed) |
|---|---|---|
| Already exists (all or part) | `status` prints counts; nothing watches or alerts. Gap: a `watch <dock>` loop and an alert line. | observed |
| Who benefits | Daily riders | asked |
| Problem, in their words | "Riders keep walking to an empty dock." | asked |
| Riskiest assumption | Polling once a minute is fresh enough to be useful | assumed |
| Cheapest test of it | Log one busy dock for a morning; count how often it empties and refills within a minute | assumed |
| Appetite (sessions) | 2 (D3) | asked |
| Cost of delay | Wasted walks every commute | assumed |
| Success metric | Riders who watch a dock report fewer wasted walks in a two-week trial | asked |
| Re-measure date | 2027-01-10 — not measured by then ⇒ "not measured - why", re-ask | |
| Re-measured result | *(filled on the re-measure date)* | |
| Kill criteria + trigger | effort: 1.5× appetite ⇒ stop and ask · value: no fewer wasted walks after the trial ⇒ revisit | proposed |

Recommended roadmap position: next up.

Gate (value): GO - D1

## Current state — measured (2026-10-20)
- `docks/feed.py` reads `FEED_URL = https://feeds.example.invalid/docks/v1.json` (file read).
- There are no tests in the repo (`git ls-files`).
- `status` takes a saved feed file, not a live request (code read).

## Goal
A rider can watch one dock and is told, within a minute, when it reaches zero bikes.

## Non-goals
- Push notifications to phones (a terminal line only, for now).
- More than one watched dock per rider.

## Design
A `watch <dock>` command polls the feed once a minute (the rate limit) and prints `EMPTY <dock>` when bikes reach 0, once per empty spell.

## Constraints
- One request per minute per client.

## Decisions (owner)
- D1 — GO.
- D2 — Priority: next up.
- D3 — Appetite: 2 sessions.

## Recommendations (not decisions)
- Print the alert once per empty spell, not every minute.

## Definition of Done
- [ ] `watch` prints `EMPTY <dock>` once when a recorded feed sequence goes 2 → 0 → 0 — **observed by:** a test that replays three saved feed files
- [ ] No more than one request per minute — **observed by:** a test with a fake clock counting requests

## Risks
| Risk | Mitigation |
|---|---|
| The feed URL changes | Keep it in one constant |

## Rollback
Remove the `watch` command; nothing else changes.

Gate (spec): drafted - open decisions: none

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
- 2026-10-20 — spec drafted; review not started.

Gate (build): pending

## Close
- DoD observations (with evidence rung): *(at close)*

Gate (close): pending
MD
git init -q && git add -A
GIT_AUTHOR_DATE="2026-10-20T10:00:00" GIT_COMMITTER_DATE="2026-10-20T10:00:00" \
  git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "dockwatch + plan (spec drafted)"
mkdir -p tests
cat > docks/feed.py <<'PY'
FEED_URL = "https://feeds.example.invalid/docks/v2.json"
def parse(payload):
    return {d["id"]: d["bikes_available"] for d in payload["stations"]}
PY
cat > tests/test_feed.py <<'PY'
from docks import feed
def test_parse_v2():
    assert feed.parse({"stations": [{"id": "A1", "bikes_available": 0}]}) == {"A1": 0}
PY
git add -A
GIT_AUTHOR_DATE="2026-10-24T16:00:00" GIT_COMMITTER_DATE="2026-10-24T16:00:00" \
  git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "feed moved to v2: new URL and field names; first test"
