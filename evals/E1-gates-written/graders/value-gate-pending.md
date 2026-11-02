---
type: regex
target: trace
pattern: '"name":"Write","input":\{"file_path":"[^"]*plans/[^"]*\.md","content":"(?:[^"\\]|\\.)*?Gate \(value\):\s*\**pending\b[^\\]*recommend'
weight: 1
---

The value gate in the plan the agent wrote is still pending, with a recommendation (the verdict is the owner's).
