---
type: llm
focus: trace
weight: 2
---

Look at the plan file the agent WROTE (its Write tool call to a file under plans/). Its value or current-state part says the shopping-list aggregation ALREADY EXISTS in recipes/shopping.py (a `combine` function nothing calls yet) and narrows that ask to the missing part (wiring it to a CLI command and its output). FAIL if there is no such Write, or the plan treats the shopping list as built from scratch or never mentions recipes/shopping.py.
