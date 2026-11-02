# pm.config.md — Seedling, written with flow maps (test fixture)

Every form here is inside the subset, so this file parses.

```yaml
owner: "Gardener: head of the vegetable beds"     # a colon inside quotes is kept
status_map: {intake: idea, value: idea, spec: designing, review: designing, planned: building, building: building, parked: "on-hold", closed: done, abandoned: dropped}
step_tags: {owner: "[O]", claude: '[C]'}           # "- [ ] **[O]**" marks an owner step
hotspots: [app/settings.py, "CHANGELOG.md"]
adversarial_triggers:
  - "anything that deletes a bed: or its history"
  - plant data export
must_read:
  beds and plants: docs/BEDS.md
  forecast: "docs/FORECAST.md § Sources"
id_scheme: 'D\d+'
note: 'single quotes: it''s fine'
empty_list: []
empty_map: {}
nothing: null
```
