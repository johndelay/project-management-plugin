# pm.config.md — Seedling (test fixture)

```yaml
owner: Gardener
step_tags: {owner: "[O]", claude: "[C]"}
status_map:                 # lifecycle phase -> this project's status words
  intake: idea
  value: idea
  spec: designing
  review: designing
  planned: building
  building: building
  parked: on-hold
  closed: done
  abandoned: dropped
max_parallel: 2
```
