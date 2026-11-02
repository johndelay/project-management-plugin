---
type: regex
target: files
pattern: '(^|\s)\S*(review|prompt|reviewer)\S*\.md'
flags: i
weight: 1
---

A reviewer prompt file was written inside the project (a changed file whose name mentions review or prompt).
