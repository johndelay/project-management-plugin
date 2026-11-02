---
type: llm
focus: trace
weight: 1
---

Before closing, the agent re-reads the plan's Origin or readback (the two asks: a list of what expires soon, and a Monday digest email) and checks each ask against what was actually delivered, noting that the email part depends on the owner's unconfirmed step. FAIL if it closes without comparing the asks to what shipped.
