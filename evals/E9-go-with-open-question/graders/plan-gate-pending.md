---
type: regex
target:
  source: file
  path: plans/room-export.md
pattern: 'Gate \(plan\):\s*\**pending(?:[^\n]*\n)+?[^\n]*Gate \(build\):\s*\**pending'
weight: 2
---

The plan gate still reads pending (no complete build go was given) and the build gate is still pending.
