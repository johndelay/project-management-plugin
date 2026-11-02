---
name: project-management
description: Plans software work before it is built. Use it whenever someone asks to plan one or more features, changes or a project - "can you plan...", "plan these two things", "just plan it for now, don't build yet", "plan it and get it moving", "spec this", "break this into steps or workstreams" - asks whether something is worth building, or resumes a plan or answers its questions ("1a 2b, go ahead"). It writes one plan file with a gate line per phase - intake readback, a value check (does it already exist, who benefits, riskiest assumption, appetite, kill criteria), a spec, independent review, an execution plan split into parallel workstreams, a build verified on the merged tree, and a close that re-measures value - and ships a read-only plan checker. Not for a one-line fix, a typo or a quick question.
---

# Project management

**The one idea:** value first, then a spec, then someone *other than the author* improves it and tries to break it, then
work is split so parallel agents cannot collide, and nothing is "done" on anyone's say-so, only on evidence. Each phase is a
section of one plan file ending in a gate line.

```
0 Intake -> 1 Value -> [A owner] -> 2 Spec -> 3 Review -> 4 Plan -> [B owner] -> 5 Build -> 6 Close
```
"The owner" = whoever decides priorities (the person asking, unless the config names someone).

## Step 0 - every invocation
1. **Config.** Read the nearest `pm.config.md` walking up from cwd (`templates/pm.config.md`). None, or a field absent ⇒
   the Defaults below; say so in one `Defaults:` line naming each one used (location, backlog, ids, step tags, outward
   rule, checker).
2. **Capabilities line.** Your first reply has one line (after the handoff's first line, if it ends in one): what is present, and each missing companion with its fallback, e.g.
   `Capabilities: capture none → inline readback · adversarial-review none → reference/review.md · sub-agents yes ·
   page tool none → decisions file`.
3. **Repos.** `git fetch && git status -sb` in every repo the work touches; report divergence first.
4. **Read** the config's `must_read`, else the nearest status file and agent instructions (`CLAUDE.md`, `AGENTS.md`), else
   the README; plus any existing plan.
5. **Resume?** Find the plan; resume at the first gate that is pending (see Gates). First spot-check one or two load-bearing
   claims behind the last filled gate against the code or system, and say what happened since it was written. Never redo a
   filled phase. A header line that disagrees with the gates (a stale `Phase:`) is removed in the same edit. Then carry on
   to the next owner checkpoint: research, reviews and plan edits need no extra go.
6. **Workspace.** Write only inside the project unless the owner names a place; scratch files too (git-ignored there, or
   deleted). No installs, clones or network writes before Checkpoint B without asking. Credentials by reference, never by value. Run `date` before writing any time.

### Defaults (no config, or a field absent)
- **Plan location:** config `plans_dir` → the project's existing plan convention → `plans/` at the git top level → `plans/`
  under cwd. **Backlog:** an existing backlog file near the plans, else `<plans dir>/BACKLOG.md`.
- **Ids:** plan-scoped `D1, D2…` (decisions) and `F1…` (findings), minted when the owner answers; config `id_scheme` overrides.
- **Step tags:** `[O]` owner · `[C]` agent.
- **Outward or running systems** (accounts, DNS, credentials, deploys, messages): an `[O]` step or an explicit go. A grant
  counts only if it is in config `pre_approved` or recorded in the plan as an owner decision.
- **Checker:** `python3 <this skill's folder>/scripts/pm-check <plan>` after every gate change. Exit 2 = could not check,
  never clean.
- **Without X:** no search index ⇒ grep or `git log -S`; a hit is a pointer to open, not evidence · no status file ⇒ the
  plan's gate lines are the status · no coordination scripts
  ⇒ plan-scoped ids and an advisory `CLAIMS.md` (file · who · why) · no hooks ⇒ these rules are plain text · model choice
  ⇒ a cheap model for sweeps, a stronger one for review · no save skill ⇒ the
  plan's dated Log section; say "no save step configured".

## Size and tier - state each with a reason
- **Size class.** **small** = one shippable change, ≤1 session, reversible, internal, no adversarial trigger ⇒ Value rows
  may read `n/a - small` except Already exists, Riskiest assumption, Appetite, Success metric and Kill; ≤2 owner questions
  per checkpoint, inline (bundle the rest: "take my picks, or name changes"); plan ≤10 KB; one general
  review; no Workstreams. Outgrown ⇒ re-class, say so. **standard** = the full flow. **major** = more than one system
  or repo, or the owner asks ⇒ also load `reference/major-feature.md`.
- **Review depth.** `general`, or `general+adversarial`: required when the work is outward-facing, touches money, auth,
  identity or data about people, or is irreversible. Config `adversarial_triggers` add to this, never subtract.
- **Decomposition.** One stream unless there is more than one independently shippable slice.

## Gates - the only status source
A v3 plan's first line is `<!-- pm-template: v3 -->`. Seven gate lines, in this order, each `Gate (<name>): <state> - text`:

| Gate | States |
|---|---|
| intake | `pending` · `captured` |
| value | `pending` · `SPIKE-FIRST` · `GO` · `NO-GO` |
| spec | `pending` · `drafted` |
| review | `pending` · `<N> pass(es)` · `waived` |
| plan | `pending go-ahead` · `go (<scope>)` · `go` |
| build | `pending` · `in progress` · `built + verified` · `built, awaiting owner observation` |
| close | `pending` · `partial` · `DONE` · `ABANDONED` |

Any gate may read `PARKED — re-entry: <trigger>; exposed: <what stays exposed>`. A state starting `pending`, and
`SPIKE-FIRST`, count as pending when resuming. Update a gate in the same edit as the step it reflects. No `Phase:` line;
`Status:` only when the config has a `status_map`, and then it must match the gates.

## Phase 0 - Intake
More than one distinct ask (things that could ship separately, or a part needing something not built yet) ⇒ first a
numbered readback, each ask tagged *build now / defer / needs decision*, plus **Constraints & Gotchas** (hard rules said
in passing), into Origin and the backlog. Use the `capture` skill if installed. Copy the owner's words verbatim into Origin.
Create the plan from `templates/PLAN.md`. `Gate (intake): captured - <backlog lines>`.

## Phase 1 - Value
Research, don't imagine; mark each evidence line asked / observed / assumed. Research output (yours or a sub-agent's) is a
lead: verify one load-bearing claim before relying on it; say whether a missing signal was absent or existed and was ignored.
- **Already exists?** First: search code, running services and the backlog; shrink the ask to the real gap.
- Who benefits · the problem in their words · **riskiest assumption** · **cheapest test** (cheaper than the build, able to fail).
- **Appetite** in sessions, set before the spec (unset is stated, never blank) · **cost of delay**.
- **Success metric** + **re-measure date as an absolute `YYYY-MM-DD`**, with a fallback: not measured by then ⇒ record
  "not measured - why" and re-ask.
- **Kill criteria:** an effort trigger (1.5× appetite) and value triggers, each with a pre-agreed action; checked at every merge.
- Recommend GO / NO-GO / SPIKE-FIRST and a roadmap position. No numeric scoring.
SPIKE-FIRST = a time-boxed, read-only spike whose verdict is written back before Checkpoint A. Answers the owner gave
before A, in a spike or in their own words before the plan, count: record each with its quote; re-ask only where research
contradicts it; none is the build go.
`Gate (value): pending - recommend <verdict>`. Only the owner turns it into a verdict.

### Checkpoint A (owner)
One round of numbered questions: the verdict, the priority (the owner's, never yours) and any decision the spec needs.
3 or more ⇒ `templates/decisions-page.html` if you can publish a page, else `templates/decisions.md` in the project; the
questions also go inline (detail: `reference/owner-communication.md`). First re-check each question against what changed since it was asked; record answers as ids, then re-check
appetite.
**Silence is not an answer:** a question the reply skips stays open and is re-asked by number; never record your own
recommendation as the owner's choice.
**Checkpoint A never authorizes the build.**

## Phase 2 - Spec
Current state, measured and dated · Goal (one sentence) · Non-goals · Design · Constraints · **Decisions** (the owner's,
with ids) apart from **Recommendations** (yours). A choice users will notice, or the plan's statement of purpose, drafted as
a recommendation is marked ⚑; a ⚑ is resolved only by citing the decision id that answered it. Every Definition of Done item
says how it is **observed**. Risks · Rollback. Keep the plan small: review log, build detail and long Origin material go in
sibling files; 25 KB is a warning, never a gate. `Gate (spec): drafted - open decisions: <list or none>`.

## Phase 3 - Review
Never review in the authoring context. Copy the requirements (Origin verbatim, decisions, Value, Constraints, DoD) to a
file; run a general review ("improve it") and, for `general+adversarial`, three lenses (omission, correctness,
consistency): the `adversarial-review` skill if installed, else `reference/review.md`. Reviewers get the owner's words,
never your leads (no "look in particular for" list). **No sub-agents** ⇒ write each prompt to a file in the project;
the owner pastes it into a fresh session and saves the reply beside it; you read, log and route it. Same-session review is a labelled last resort.
Log every finding; re-verify before acting (confirmed vs relayed); route **fix now / defer (backlog id) / owner**; a
problem the plan caused is never deferred; name what refuses if it is ignored. Counting passes (more than 3 needs an owner decision)
and rewriting, never a banner: `reference/review.md`.
`Gate (review): <N> passes, <M> findings, <K> open - declared <depth>, delivered <what ran>`.

## Phase 4 - Execution plan
Steps tagged owner/agent (owner for anything outward). More than one stream ⇒ Workstreams: vertical slices, an ownership
matrix of globs, waves, a mode per stream, a cap (detail: `reference/parallel-work.md`). Before any handoff, audit each
item against current code and label confidence.
### Checkpoint B (owner)
Show what review changed (re-ask any owner decision it contradicts), open findings, the steps, every owner step, and which
steps each answer moves. **The build needs its own explicit go**: an earlier "go ahead" never covers it, nor does a go
given while any owner question is open, even one you offered to build without (re-ask it); if unclear, ask which go. `Gate (plan): go - <id>`.

## Phase 5 - Build + verify
With the go, work continuously; approved work is done next; route around a blocked step. A finding is not a deliverable;
scope growth is a stop-and-ask. Confirm the branch before the first commit; "commit and push" never authorizes a merge to
the default branch (config `branch_rule`).
A stream is done only on evidence you gathered: the six steps in `reference/verification.md`, ending with verification
re-run on the **merged** tree and each DoD item checked the way it says. Before each merge: `pm-check overlap --base
<base> <branch>… --plan <plan>`; each merge records a kill check. Verify at the live system; a check you have not seen fail,
or "could not check", is not clean. Before recommending a reset, wipe or removal, say what it removes,
gentlest step first. Deploy only with a go, and name which deploy ran.
`Gate (build): in progress - merged <n>/<total>`, then `built + verified - <date>`.

## Phase 6 - Close
Re-read Origin and the readback before calling anything handled. Tick each DoD item with its observation and evidence rung
(re-run on the merged tree > live read > recorded result); one only the owner can observe gets a due date and a fallback,
not a tick. Undelivered items lose their box: `- ~~item~~ - not delivered (why)`. Protections and corrected facts: closing.md. Some slices done ⇒ `partial`. Reconcile ideas raised vs
shipped; book the re-measure line (detail: `reference/closing.md`). `Gate (close): DONE - <date>` or `ABANDONED - <why, id>`.

## Hard rules
- Never send outbound communication: draft it, label it a draft, hand it over.
- Never set or reorder priorities: propose, label, ask.
- An agent's report is not evidence; git and observation are.
- Never `git commit -a` in a shared tree; commit named paths.
- Never read an exit status through a pipe (`out=$(cmd); rc=$?`).
- Date every measurement.
- A gate protects something real; when its premise is gone, drop it and say so.
- Owner-facing writing: define terms, give numbers units, make each question stand alone.
- **Handoff at every stop:** the first line says what is not done yet; then state, decided, open, the next 3 actions, who
  does what, a paste-ready prompt, the date. "DONE" and "queued next" never share a handoff. Hand off before context runs
  low; split a session whose steps run over.

## Honest limits
Nothing enforces invocation. The agent that wants to proceed fills the gates; the reviews and the two owner checkpoints are
the outside checks. pm-check checks shape, not truth.
