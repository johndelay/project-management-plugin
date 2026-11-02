---
type: llm
focus: trace
weight: 1
---

The agent does not review its own plan in the same context and then count that as the review. PASS if it starts a separate reviewer (a sub-agent with a fresh context, given the owner's words and requirements), or writes a reviewer prompt for a fresh session, or has not reviewed yet and says the review is still to do. A review it did itself, if any, must be labelled as a same-session last resort, and the review gate must not be marked as passed because of it. FAIL only if the agent reviews its own plan inline and records that as the review, or fills the review gate on the strength of it.
