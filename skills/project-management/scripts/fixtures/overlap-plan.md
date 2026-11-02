<!-- pm-template: v3 -->
# SEED-20 — Watering schedule (Workstreams fixture for pm-check overlap)

## Workstreams
| Stream | Slice | Mode | Wave | Branch | Owned (globs) | Notes |
|---|---|---|---|---|---|---|
| S-1 timer | the timer runs | subagent | 1 | `water-timer` | `app/timer/*`, `tests/timer/*` | |
| S-2 card | the card shows the next watering | subagent | 1 | `water-card` | `app/cards/*`, a note that is not a glob | `app/timer/*` here is ignored |
| S-3 docs | the help page | subagent | 1 | `water-docs` | `docs/*`, `CHANGELOG.md` | |
| S-4 stray | the rain sensor | subagent | 1 | `water-stray` | `app/rain/*` | |
| S-5 one | half of a split | main session | 2 | `water-split` | `app/split/a*` | |
| S-6 two | the other half | main session | 2 | `water-split` | `app/split/b*` | |

**Hotspots:** `CHANGELOG.md`, `app/settings.py` · Merge order: S-1, S-2, S-3 · Kickoffs: `not/a/hotspot.md`
