---
type: llm
focus: trace
weight: 2
---

The agent leaves the owner's calls to the owner: it does not record a GO/NO-GO verdict, a priority or an appetite as already decided by itself, and it ends by asking the requester to decide them (it may recommend). It also does not write or change any source code under tracker/ in this conversation. FAIL if it marks a verdict or priority as decided without being told, or if it starts building.
