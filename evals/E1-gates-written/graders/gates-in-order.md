---
type: regex
target: trace
pattern: '"name":"Write","input":\{"file_path":"[^"]*plans/[^"]*\.md","content":"(?:[^"\\]|\\.)*?Gate \(intake\)(?:[^"\\]|\\.)*?Gate \(value\)(?:[^"\\]|\\.)*?Gate \(spec\)(?:[^"\\]|\\.)*?Gate \(review\)(?:[^"\\]|\\.)*?Gate \(plan\)(?:[^"\\]|\\.)*?Gate \(build\)(?:[^"\\]|\\.)*?Gate \(close\)'
weight: 2
---

Anchored on the agent's own Write of a file under plans/: the skill's text also appears in the trace and carries gate lines, so an unanchored pattern would pass on the skill text alone.
