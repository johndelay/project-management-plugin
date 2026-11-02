---
type: llm
focus:
  source: file
  path: plans/expiry-warnings.md
weight: 2
---

The Value table's "Re-measured result" row is filled in (the re-measure date 2026-09-15 has passed). PASS if the row itself gives either (a) a dated measurement against the success metric (items thrown away per week, read from data/waste-log.csv) together with a verdict of keep, revisit or kill, or a recommended verdict explicitly left to the owner; or (b) "not measured" with the reason and a re-ask of the owner. FAIL if the row is still the placeholder, or the result is written somewhere else and the row left empty.
