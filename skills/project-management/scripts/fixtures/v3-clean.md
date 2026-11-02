<!-- pm-template: v3 -->
# SEED-12 — Frost alerts for the Seedling garden tracker

**ID:** SEED-12 · **Priority:** P2 · **Status:** done · **Updated:** 2031-04-18
**Depth:** general · streams multi — *reason:* two independent pieces, the forecast store and the alert card.

## Origin
> A gardener, 2031-04-02: *"Tell me the evening before a frost so I can cover the tomatoes."*

Readback: 1. a frost warning the evening before · 2. a per-bed opt-out.

**Constraints & Gotchas:**
- No paid weather service.
- The card must work offline from the last stored forecast.

**Idea parking lot:**
- A soil-temperature graph (later).
- Process risk: the free forecast changes its format without notice.

Gate (intake): captured — readback items 1–2 above

## Value
| Field | Content | Evidence (asked/observed/assumed) |
|---|---|---|
| Already exists (all or part) | the app stores each bed's plants; it has no alerts | observed |
| Who benefits | gardeners with frost-tender plants | asked |
| Problem, in their words | "I lost the tomatoes twice last spring" | asked |
| Riskiest assumption | the free forecast gives a usable overnight low | assumed |
| Cheapest test of it | compare 14 nights of forecast lows with a backyard thermometer | observed |
| Appetite (sessions) | 3 | asked |
| Cost of delay | one more frost season | assumed |
| Success metric | no frost loss reported next spring | assumed |
| Re-measure date | 2031-06-01 | asked |
| Re-measured result | *filled in at the re-measure: date, value against the metric, keep / revisit / kill* | |
| Kill criteria + trigger | effort: past 5 sessions, stop and re-ask · value: no alert opened in 30 days, remove the card | asked |

Gate (value): GO — D1

## Current state — measured (2031-04-03)
The forecast module stores daily highs only; it has no overnight field.

## Goal
A gardener sees a frost warning on the evening before a forecast frost.

## Non-goals
- Push notifications.

## Design
The forecast store keeps the overnight low; the alert card reads it at 18:00 local time.
Card text uses the template string `{{bed_name}} may see frost tonight`, filled in by the card.

```text
{{bed_name}}: cover before dusk
```

## Constraints
- Offline first: the card reads the last stored forecast.

## Decisions (owner)
- D1 — Build it; appetite 3 sessions.
- **D2** — The alert threshold is 2 °C.
- `D3` — The per-bed opt-out ships in the first slice.
- D4 — Push notifications become their own plan.

## Recommendations (Claude — not decisions)
- ⚑ Show the card at 18:00 local time. Accepted with the threshold, D2.
- Keep the opt-out on the bed's settings page (a detail, not an owner call).

## Definition of Done
- [x] The card warns when the stored low is under 2 °C. — **observed by:** a test with a planted forecast of 1 °C
- [x] A bed with the opt-out shows no warning.
  — **observed by:** the same test with that bed opted out
- ~~A push notification~~ — not delivered (moved to its own plan, D4)

## Risks
| Risk (pre-mortem seeded) | Mitigation |
|---|---|
| The forecast drops the overnight field | the card says "no forecast" instead of "no frost" |

## Rollback
Remove the card; the stored low is then unused.

Gate (spec): drafted — open decisions: none

## Review (append-only)
| # | pass | lens | finding | confirmed/relayed | verdict | route | refuses if ignored |
|---|---|---|---|---|---|---|---|
| 1 | 1 | general | a stale forecast must not read as "no frost" | confirmed | REAL | fix now | the stale-forecast test |

Gate (review): 1 pass, 1 finding, 0 open — declared general, delivered general

## Steps
- [x] **[C]** Store the overnight low.
- [x] **[C]** Render the alert card.
- [ ] **[O]** Look at the card on the kitchen tablet one evening.

## Workstreams
| Stream | Slice | Mode | Wave | Branch | Owned (globs) | Notes |
|---|---|---|---|---|---|---|
| S-1 store | the overnight low is stored | subagent | 1 | `frost-store` | `app/forecast/*`, `tests/forecast/*` | |
| S-2 card | the card shows the warning | main session | 1 | `frost-card` | `app/cards/frost*`, `tests/cards/*` | reads `app/forecast/store.py` only |

**Hotspots:** `app/settings.py`, `CHANGELOG.md` · Merge order: S-1, then S-2

Gate (plan): go — D1, D2

## Build log
| Stream | Base SHA | Commits | Status clean | Ancestor ok | Verified on merged tree | Kill check |
|---|---|---|---|---|---|---|
| S-1 | 1a2b3c4 | 2 | yes | yes | tests pass | 2 of 3 sessions used |
| S-2 | 1a2b3c4 | 3 | yes | yes | tests pass | 3 of 3 sessions used |

Gate (build): built + verified — 2031-04-16, streams merged 2/2

## Log
- 2031-04-16 — both streams merged; the planted 1 °C forecast shows the card.

## Close
- DoD observations: items 1–2 by the planted-forecast test, re-run on the merged tree · item 3 struck (D4)
- Ideas reconciled: the soil-temperature graph went to the backlog.

Gate (close): DONE — 2031-04-18, D1..D4
