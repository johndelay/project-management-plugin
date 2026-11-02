<!-- pm-template: v3 -->
# {{Title}}

**ID:** {{id}} · **Priority:** *(the owner sets it at Checkpoint A)* · **Updated:** {{YYYY-MM-DD}}
**Size:** {{small | standard | major}} · **Depth:** {{general | general+adversarial}} · **Streams:** {{one | several}} — *reason:* {{why}}
**Owner:** {{name}}

## Origin
> {{the owner's words, verbatim}} — {{YYYY-MM-DD}}

**Readback:**
1. {{ask}} — {{build now | defer | needs decision}}

**Constraints & Gotchas:**
- {{a hard rule stated in passing}}

**Idea parking lot:**
- *(ideas and process risks raised during the work; reconciled at close)*

Gate (intake): pending

## Value
| Field | Content | Evidence (asked/observed/assumed) |
|---|---|---|
| Already exists (all or part) | {{what exists; the real gap}} | {{…}} |
| Who benefits | {{…}} | {{…}} |
| Problem, in their words | {{…}} | {{…}} |
| Riskiest assumption | {{…}} | {{…}} |
| Cheapest test of it | {{cheaper than the build; able to fail}} | {{…}} |
| Appetite (sessions) | {{n}} | {{…}} |
| Cost of delay | {{…}} | {{…}} |
| Success metric | {{…}} | {{…}} |
| Re-measure date | {{YYYY-MM-DD}} — not measured by then ⇒ "not measured - why", re-ask | |
| Re-measured result | *(filled on the re-measure date: date — value vs metric — keep / revisit / kill)* | |
| Kill criteria + trigger | effort: 1.5× appetite ⇒ stop and ask · value: {{trigger ⇒ pre-agreed action}} | {{…}} |

Recommended roadmap position: {{…}}

Gate (value): pending - recommend {{GO | NO-GO | SPIKE-FIRST}}

## Current state — measured ({{YYYY-MM-DD}})
{{what is there now, with how each fact was measured}}

## Goal
{{one sentence}}

## Non-goals
- {{…}}

## Design
{{…}}

## Constraints
- {{…}}

## Decisions (owner)
- *(none yet)*

## Recommendations (not decisions)
- {{…}}

## Definition of Done
- [ ] {{condition}} — **observed by:** {{screenshot / live read / measurement}}

## Risks
| Risk | Mitigation |
|---|---|
| {{…}} | {{…}} |

## Rollback
{{…}}

Gate (spec): pending

## Review (append-only)
Log: `{{review folder}}/{{review_naming, kind review-log; default <plan-slug>-review-log.md}}` — one row per finding: # · pass · lens · finding · confirmed/relayed ·
verdict · route · refuses if ignored. Passes: *(none yet)*

Gate (review): pending

## Steps
- [ ] **[C]** {{step}}
- [ ] **[O]** {{owner step}}

## Workstreams
| Stream | Slice shipped (observable) | Mode | Wave | Branch | Owned (globs) | Notes |
|---|---|---|---|---|---|---|

**Hotspots:** *(none)*

Gate (plan): pending go-ahead

## Build log
| Stream | Base SHA | Commits | Status clean | Ancestor ok | Verified on merged tree | Kill check |
|---|---|---|---|---|---|---|

**Log:**
- *(dated entries: what ran, what changed, deploys by name)*

Gate (build): pending

## Close
- DoD observations (with evidence rung): *(at close)*
- Ideas reconciled: *(at close)*
- Re-measure line booked: *(at close)*
- Checker rc: *(at close)*

Gate (close): pending
