---
type: llm
focus: trace
weight: 2
---

Look at the plan file the agent WROTE (its Write tool call to a file under plans/), not at any skill or template text it read. That plan lists BOTH requested asks — (1) a shopping-list export combining several recipes and (2) a --servings option that scales a recipe — and records the constraint "don't touch data/recipes.json (the mobile app reads it)" as a constraint or gotcha. FAIL if there is no such Write, either ask is missing from it, or the constraint is not recorded in it.
