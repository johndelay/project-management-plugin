---
type: llm
focus: last_message
weight: 1
---

The agent's final reply is a handoff: its FIRST line says what is not done yet; it then gives the current state, what is decided, what is open, the next actions, who does what (the owner vs the agent), a prompt that could be pasted to continue, and a date. PASS if the first line says what is not done and at least four of the other six are present. FAIL otherwise.
