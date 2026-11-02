---
type: llm
focus: trace
weight: 2
---

Before relying on the spec, the agent checks at least one of its "Current state — measured" claims against the repo as it is now, and says what changed since the plan was written (2026-10-20). The repo has a later commit that moved the feed to a v2 URL with new field names and added the first test, so "there are no tests" and the v1 URL are now false. PASS only if the agent notices at least one of those changes and says the spec needs updating because of it. FAIL if it never compares the spec with the current code or git history.
