---
type: regex
target: files
pattern: '(^|\s)(rooms|tests)/'
match: not_contains
weight: 2
---

No file under rooms/ or tests/ was created or changed: a go given while an owner question is open is not the build go.
