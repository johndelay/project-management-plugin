# pm.config.md — Seedling, with one line outside the subset (test fixture)

The flow maps and quoted colons parse; line 10 does not (a plain value holding ': ' is ambiguous).

```yaml
owner: "Gardener: head of the vegetable beds"
status_map: {intake: idea, closed: done, parked: "on-hold"}
step_tags: {owner: "[O]", claude: "[C]"}
hotspots: [app/settings.py, "CHANGELOG.md"]
release: run the deploy: then tag it
```
