---
type: llm
focus: trace
weight: 1
---

Somewhere in its replies or in the plan file, the agent (a) states which helper capabilities or companion skills are present or missing and what it falls back to, and (b) says there is no project config and names the defaults it is using, including the owner/agent step tags and at least one of: where the plan file goes, the id format. FAIL if (a) or (b) is missing, or if the stated defaults leave out the step tags.
