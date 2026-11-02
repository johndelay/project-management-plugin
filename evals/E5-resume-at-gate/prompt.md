---
description: Resume a plan whose spec is drafted and review pending, with a stale "Phase - build" header and a commit since the spec that contradicts it. Does the skill resume at review, name the stale header, spot-check the spec against the code and say what happened since, leave the build alone, and end with a full handoff?
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

Pick up plans/empty-dock-alerts.md where it left off.
