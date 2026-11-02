---
type: regex
target:
  source: file
  path: plans/holds-notify.md
pattern: 'Gate \(plan\):\s*\**pending(?:[^\n]*\n)+?[^\n]*Gate \(build\):\s*\**pending'
weight: 2
---

The plan gate still reads pending (no build go was given) and the build gate is still pending.
