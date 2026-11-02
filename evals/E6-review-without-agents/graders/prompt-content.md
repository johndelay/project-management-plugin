---
type: llm
focus: trace
weight: 2
---

Look at the reviewer prompt file(s) the agent WROTE (Write tool calls), not at any skill text it read. The prompt carries the owner's Origin quote word for word ("Riders keep walking to an empty dock..."), the owner's decisions (GO, next up, 2 sessions) and the plan's requirements (goal, constraints, definition of done) or a pointer to the plan file, and asks a fresh reviewer to improve or find faults in the plan. It does NOT include the author's own leads, such as a list of the weaknesses the author already suspects. FAIL if no prompt file was written, the Origin quote is missing, or the author's leads are included.
