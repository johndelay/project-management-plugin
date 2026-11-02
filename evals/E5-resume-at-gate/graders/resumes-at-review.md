---
type: llm
focus: trace
weight: 2
---

The agent identifies review as the next phase of plans/empty-dock-alerts.md (the spec gate is drafted and the review gate pending) and works on the review, not on building. It does not write the `watch` command or any code under docks/ or tests/. FAIL if it starts building, or treats the plan as being in the build phase.
