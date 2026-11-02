---
type: regex
target: files
pattern: '(^|\s)(widget|data)/'
match: not_contains
weight: 1
---

Nothing under widget/ or data/ was changed: the request was to plan, not build.
