---
type: regex
target:
  source: file
  path: plans/faq-search.md
pattern: '(?:[Rr]e-?measure|[Rr]eview date|[Mm]easure (?:again|on))[^\n]{0,160}\b20\d\d-\d\d-\d\d\b'
weight: 2
---

The plan names an absolute re-measure date (YYYY-MM-DD) on the re-measure line, not "a month after launch".
