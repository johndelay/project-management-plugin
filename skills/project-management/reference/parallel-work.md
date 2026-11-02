# Parallel work — Workstreams, handoffs and checker compatibility

Loaded at Phase 4 when there is more than one stream, and at every handoff.

## Workstreams
1. **Vertical slices.** Each stream ships something observable on its own — not "backend half / frontend half". An optional
   wave 0 walking skeleton proves the pieces connect before anyone builds out.
2. **File-ownership matrix.** The Workstreams table has columns
   `Stream · Slice shipped (observable) · Mode · Wave · Branch · Owned (globs) · Notes`. Owned globs are repo-relative and
   backticked, comma-separated (`src/search/*`, `docs/search.md`); prose goes in Notes. A file owned by two streams, or listed
   in config `hotspots`, is owned by one stream or moved to a later wave. Registration and build-sequence files count: a file
   listed in two build steps is two hotspots.
3. **Hotspots line** under the table: `**Hotspots:**` followed by backticked repo-relative globs that only the orchestrator
   (you) edits — the plan itself, shared config, the backlog.
4. **Waves and merge order.** Parallel only within a wave. Merge order is written down.
5. **Mode per stream:** a sub-agent in its own worktree (files disjoint from everyone else's) · a separate session (long, or
   needs the owner) · an owner step.
6. **Cap:** config `max_parallel` (default 3) streams at once.

## Before each merge — the build-time overlap guard
From the repo, for each stream branch about to merge:
`python3 <skill folder>/scripts/pm-check overlap --base <base sha> <branch>… --plan <plan.md>`
It diffs each named branch against the base (`git diff --name-only <base>...<branch>`, three dots) and reports a file
touched by two branches, a file a branch touched outside its row's Owned globs, and any hotspot a branch touched. Exit 0
clean, 1 a finding, 2 could not check (e.g. a branch that matches two rows). Your own branch is never passed. Resolve every
finding before merging: move the file to its owner, or re-plan the wave.

## Kickoffs
Each stream starts from `templates/KICKOFF.md`, filled at dispatch: the base SHA taken **after** `git fetch`, the owned globs
copied from its row, the must-read docs, its Definition of Done items with how each is observed, the verification command
and the handoff block. The orchestrator re-checks the handoff with git (the six evidence steps).

## Plan audit before any handoff
A plan written earlier is not a description of the code now. Before handing items to another session or agent:
- **Pre-audit each item against current code:** open what it touches and confirm the premise still holds.
- **Label confidence** per item: verified now / believed / unverified.
- **Batch:** more than 5 items ⇒ groups of at most 3, each group handed off and checked before the next.
- **Carry the line** "audit each remaining item against current code before acting" in every handoff and kickoff.
- Reviewers' kickoffs carry a no-write clause.

## Ids, claims and environment (when several sessions share a project)
- Set every environment variable the config's `env` names before running an allocator or claim command.
- **Ids:** use the config `id_allocator` if there is one; otherwise plan-scoped ids (`D1`, `F1`), which cannot collide across
  plans. Never pick the next id by reading the highest one visible.
- **Claims:** if the config names `claim`/`release`, claim shared files before editing and release after. Without a
  coordination tool, keep an advisory `CLAIMS.md` beside the plan (file · who · why · since) and read it first.
- Never `git commit -a` in a shared tree; commit named paths.

## Checker compatibility (projects with their own plan checker)
- Some project checkers find sections by exact heading text: rename no template heading, and never write a heading's text
  (hash marks included) anywhere else in the plan, or a substring check matches the copy.
- If the project's checker rejects a plan that has no roadmap row yet, write the draft under config `draft_naming` (a name
  the checker skips) and promote it at Checkpoint A: number, rename and roadmap row in one change.
- A plan in parts (one file per system, a decision point) names each part with config `companion_naming`. Never give a part that
  has steps a name the checker skips (such as a `_` prefix) just to get a clean run: the clean result then covers none of
  those steps. If the checker cannot see parts, fix the checker or ask.
- Config `decisions_naming`, `review_dir` and `review_naming` put decisions and review files where that checker expects them.
