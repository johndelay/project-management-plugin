---
type: regex
target:
  source: file
  path: README.md
pattern: 'in a single text file'
weight: 1
---

The typo on line 3 ("singel") is fixed in the file itself. Scored only so the case has a score; E7 is judged on the fired count (it must be 0).
