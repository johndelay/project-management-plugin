---
type: regex
target:
  source: file
  path: plans/expiry-warnings.md
pattern: 'Gate \(close\):\s*\**(?:partial|pending)'
weight: 2
---

The close gate is partial or still pending, not DONE: one DoD item and an owner step are still open.
