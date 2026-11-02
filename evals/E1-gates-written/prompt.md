---
description: A plain planning request with two asks and one constraint, in a repo where one ask is half-built. Does the skill write a v3 plan with all seven gate lines, state its capabilities and defaults, read back both asks and the constraint, and find the half-built code?
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Can you plan two things for this recipe CLI: a shopping-list export that combines several recipes, and a --servings option that scales a recipe up or down. Please don't touch data/recipes.json; our mobile app reads that file directly. Just plan it for now, don't build anything.
