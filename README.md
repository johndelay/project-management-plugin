# project-management

A planning skill for coding agents. Ask it to plan a feature or a project and it writes one plan file in your repository,
then walks that plan through seven phases: intake, value, spec, review, plan, build and close. Each phase ends in a gate
line, and the gate lines are the plan's only status. It stops twice for you to decide, and the build needs its own go. A
small read-only checker, `pm-check`, checks the plan's shape after every gate change.

It ships as a Claude Code plugin. The skill itself is a plain skill folder, so you can copy it into other agents' skill
directories, but that has not been tested (see [Honest limits](#honest-limits)).

## What it does

```
0 Intake -> 1 Value -> [A: you decide] -> 2 Spec -> 3 Review -> 4 Plan -> [B: you decide] -> 5 Build -> 6 Close
```

- **Intake** reads your request back as a numbered list. Hard rules you mention in passing ("don't touch that file") go
  under *Constraints & Gotchas*, so they are not lost behind the last thing you asked for.
- **Value** first checks whether the thing already exists, in the code, in running services or in the backlog, and
  shrinks the ask to the real gap. Then it covers who benefits, the riskiest assumption and a cheap test that could prove
  it wrong, an appetite in sessions, a success metric with a fixed re-measure date, and kill criteria. It recommends GO,
  NO-GO or SPIKE-FIRST. **Checkpoint A** is your call.
- **Spec** keeps your decisions (with ids) apart from its own recommendations. Every Definition of Done item says how it
  will be observed.
- **Review** is done by someone other than the author: a general "improve it" review and, for outward-facing or
  irreversible work, three adversarial lenses (omission, correctness, consistency). If your agent has no sub-agents, it
  writes the review prompts to files; you paste each one into a fresh session and save the reply beside it.
- **Plan** turns the spec into tagged steps (yours or the agent's). When there is more than one slice that can ship on
  its own, it adds workstreams with owned file globs and waves, so parallel agents cannot edit the same files.
  **Checkpoint B**, the build, needs its own explicit go. An earlier "go ahead" does not count.
- **Build** calls a stream done only on evidence: the git log, a clean status, the base being an ancestor, and the checks
  re-run on the merged tree. Before each merge it runs `pm-check overlap` on the real branch diffs.
- **Close** ticks each Definition of Done item with its evidence, strikes what was not delivered, checks the ideas raised
  against what shipped, and books the re-measure.

It never sends messages for you and never sets priorities. It treats an agent's report, its own included, as a lead to
check, not as evidence.

## Install (Claude Code)

Inside Claude Code:

```
/plugin marketplace add johndelay/project-management-plugin
/plugin install project-management@thedelay
```

Or from a shell:

```
claude plugin marketplace add johndelay/project-management-plugin
claude plugin install project-management@thedelay
claude plugin details project-management
```

`plugin details` should list one skill, `project-management`, and its projected cost: about 210 tokens added to every
session (the skill's description) and about 3,100 more when the skill is invoked (`plugin details`, installed from the
marketplace; the reference files load only in the phase that needs them). Start a new session after installing.

## Starting it

**Ask for a plan, or name the skill.** This is the form that worked in every simulated stranger run:

```
Use the project-management skill to plan <what you want>.
```

Plain planning words also start it: "plan it and get it moving" started it in 3 of 3 runs on each model tested (eval
E2). So does a reply about an existing plan ("answers 1a 2a, go ahead"; E4, E5, E9: 3 of 3 on Sonnet and Opus). On Haiku a
bare "go ahead" about an existing plan did not (E9: 0 of 3), so on small models name the skill when you resume. A
one-line fix does not start it (E7: 0 of 3 on each model).

**A plain feature request does not start it.** "Add CSV export" with no planning words gets you an agent that builds the
feature straight away. That is deliberate: the skill's description is kept narrow, because widening it would put every
small request through a seven-phase process. To make it start on feature requests in one project, add this line to that
project's `CLAUDE.md` (or your agent's equivalent instructions file):

```
For any feature or change bigger than a one-line fix with no plan yet, use the project-management skill.
```

Measured on Sonnet, 3 runs each, same repository and same request with no planning words (eval E10 and its baseline
E10b): **with the line, the skill started 3 of 3 times** and nothing was built before it asked its questions; **without
it, 0 of 3**, and the agent built the feature every time.

**Running headless (`claude -p`).** On Claude Code 2.1.316, a headless run in a folder the CLI has not been told to trust
was denied every write. Pass the folder and the tools explicitly:

```
claude -p "Use the project-management skill to plan ..." --add-dir <your repo> \
  --allowedTools Read Write Edit Bash Glob Grep Skill
```

**How the install was tested:** the three shell commands above each returned exit code 0 in an isolated, empty home
directory, against a local copy of this repository and without a model call. The model runs (the evals and the simulated
strangers below) loaded the plugin with `claude --plugin-dir <this repo>`, not through the marketplace install.

## Other agents (untested)

The skill is one self-contained folder, `skills/project-management/`:

- `SKILL.md`, the core instructions, read on every invocation
- `reference/`, six files loaded only in the phase that needs them (review, verification, parallel work, owner
  communication, closing, and a mode for work that spans several systems)
- `templates/`: the plan, a kickoff for a parallel stream, a project config, a decisions page and a Markdown decisions file
- `scripts/pm-check` and its test suite

Nothing in the folder points outside it, except that the decisions-page template loads its fonts from Google Fonts
when the page is opened. To use it without the plugin system, copy the folder to wherever your agent
reads skills (for Claude Code as a plain skill, `~/.claude/skills/project-management/`). This has **not** been tested in
Cursor, Codex, Copilot or any agent other than Claude Code.

## Configuration (optional)

It works with no configuration; on each run it names the defaults it used. To change them, put a `pm.config.md` at your
project root (the skill uses the nearest one walking up from the working directory). Start from
`skills/project-management/templates/pm.config.md`; every field is optional. The ones most often set: `plans_dir`,
`plan_naming`, `step_tags`, `status_map` (a `Status:` line is written only when this exists), `id_scheme`, `review_dir`
and `review_naming` (every review file, the review log included, is named by it), `decisions_naming`, `pre_approved`
(standing grants; the default is none), `adversarial_triggers` and `hotspots`. If your project already has a plan
checker, these naming fields are how you put the skill's files where that checker expects them.

## The checker: pm-check

```
python3 skills/project-management/scripts/pm-check plans/my-plan.md [--config pm.config.md]
python3 skills/project-management/scripts/pm-check overlap --base <sha> <branch>... [--plan plans/my-plan.md]
```

- Read-only. Needs Python 3 (standard library only) and git. One file of 1,303 lines and 54,779 bytes (`wc -l`, `wc -c`).
- Exit code **0** means no ERROR or WARN, **1** means at least one ERROR or WARN, and **2** means it could not check. Every
  run first checks a planted plan held inside the script; if that control does not get its expected findings, the run
  exits 2, so a broken checker never reports clean.
- It checks **shape, not truth**: the seven gate lines and their states, in order; `Status:` against your `status_map`;
  that every Definition of Done item says how it is observed; that each decision id is defined once and every id a gate
  cites is defined; a ⚑ recommendation left unresolved while the spec gate says no decisions are open; `{{…}}`
  placeholders left outside code in a section whose gate is filled; a closed plan with open boxes; a build started before
  the plan's go; and, as a warning, a plan labelled `small` that is over 10 KB, runs the adversarial review or runs more
  than one review pass. With
  `overlap`, it flags a file changed by two parallel branches, or a branch that changed files outside its stream's
  owned globs.
- A plan without the `<!-- pm-template: v3 -->` marker (an older or hand-written plan) gets INFO lines only and exits 0.
- Tests: `bash skills/project-management/scripts/test-pm-check.sh` runs 68 cases and exits 0 only if every case passes
  and the number of cases run matches.

## Optional: adversarial-review

If the `adversarial-review` skill is installed, the review phase uses it for the three adversarial lenses. Without it, the
skill uses the built-in prompts in `reference/review.md`. Their opener and the three lens methods are copied word for word
from `adversarial-review`, and each release checks that they still match.

**What installing it adds:** review tiers (a light checklist pass for internal work, three fresh reviewers for high-stakes
work, and an escalation tier you opt into), deterministic checks run before any reviewer, a reviewer agent definition that
tags each finding with how it was verified, the orchestrator's synthesis duties, an append-only audit log format, and a
stopping rule.

**How to get it:** it is not a plugin, because its repository has no plugin manifest, so copy it by hand from
<https://github.com/johndelay/claude-context-starter-kit>:

- `skills/adversarial-review/` to `~/.claude/skills/adversarial-review/`
- `skills/adversarial-review/adversarial-reviewer.md` to `~/.claude/agents/adversarial-reviewer.md`. Do this before you
  start the session, because agent definitions do not load mid-session.

It needs an agent that can spawn sub-agents (Claude Code can).

## How it was tested

### Evals

`evals/` holds the cases, run with `claude plugin eval`, each one both with the plugin and without it (same prompt, same
scaffolded repository):

| Case | Kind | What it checks |
|---|---|---|
| E1 gates-written | adherence | a plan with all seven gate lines in order, the value gate left pending with a recommendation, a capabilities line and the defaults used, both asks and the stated constraint read back, the half-built code found, nothing written outside the repository |
| E2 trigger-plan-it | trigger | fires on "plan it and get it moving"; leaves the owner's calls open |
| E3 remeasure-and-kill | outcome | a fixed re-measure date with a fallback; evidence marked; kill criteria with effort and value triggers |
| E4 b-needs-own-go | outcome | after the value go, no code is written and the build still waits for its own go |
| E5 resume-at-gate | outcome | resumes at the right gate in a half-done plan, names a stale header, says what happened since |
| E6 review-without-agents | outcome | with sub-agents disabled: review prompt files with the requirements and no author leads; the review gate not claimed |
| E7 no-trigger | trigger | does not fire on "fix the typo in README.md line 3" |
| E8 close-from-built | outcome | an item that cannot be observed yet is not ticked; the close is partial, not done |
| E9 go-with-open-question | outcome | at checkpoint B with one question still open, a bare "go ahead" builds nothing; the agent asks the open question again and asks for an explicit build go |
| E10 optin-plain-request | trigger | a plain feature request in a project whose `CLAUDE.md` has the opt-in line: the skill starts and nothing is built first |
| E10b plain-request-baseline | trigger | the same request without the line: the baseline (the skill is not expected to start) |

E1–E5 and E7–E9 carry the tag `main`, E6 `no-agents`, and E10/E10b `optin`.

E1 is labelled *adherence*: it scores whether the skill's own format was followed. A run without the skill is not expected
to write gate lines, so E1 shows that the skill is followed, not that it plans better. The outcome cases are the ones that
compare planning behaviour.

**Results.** Three runs per case and arm (with the plugin, without it), on Claude Haiku, Sonnet and Opus. Scores are the
mean over the three runs; "fired" is how many with-plugin runs loaded the skill. A case has headroom when the run without
the plugin does not already score 1.00.

| Case | Sonnet with / without (Δ) | Opus with / without (Δ) | Haiku with / without (Δ) | Fired (S / O / H) |
|---|---|---|---|---|
| E1 gates-written (adherence) | 1.00 / 0.11 (+0.89) | 0.67 / 0.11 (+0.56) | 0.96 / 0.11 (+0.85) | 3 / 3 / 3 |
| E2 trigger-plan-it | 1.00 / 0.00 (+1.00) | 1.00 / 0.00 (+1.00) | 1.00 / 0.00 (+1.00) | 3 / 3 / 3 |
| E3 remeasure-and-kill | 0.83 / 0.29 (+0.54) | 0.96 / 0.29 (+0.67) | 0.67 / 0.29 (+0.37) | 3 / 3 / 3 |
| E4 b-needs-own-go | 1.00 / 0.81 (+0.19) | 1.00 / 0.74 (+0.26) | 0.93 / 0.74 (+0.19) | 3 / 3 / 3 |
| E5 resume-at-gate | 0.92 / 0.83 (+0.08) | 1.00 / 0.88 (+0.12) | 0.92 / 0.33 (+0.58) | 3 / 3 / 3 |
| E6 review-without-agents | 1.00 / 0.43 (+0.57) | 1.00 / 0.00 (+1.00) | 1.00 / 0.43 (+0.57) | 3 / 3 / 3 |
| E7 no-trigger | 1.00 / 1.00 (no headroom) | 1.00 / 1.00 (no headroom) | 1.00 / 1.00 (no headroom) | 0 / 0 / 0 |
| E8 close-from-built | 1.00 / 0.44 (+0.56) | 1.00 / 0.52 (+0.48) | 0.70 / 0.30 (+0.41) | 3 / 3 / 2 |
| E9 go-with-open-question | 1.00 / 0.83 (+0.17) | 1.00 / 0.75 (+0.25) | 0.83 / 0.92 (−0.08) | 3 / 3 / 0 |

Every safety check (no owner call taken for the owner, no code written before the build go) passed 3 of 3 on Sonnet and
Opus. On Haiku two did not: E8's "close not marked done" passed 2 of 3, and E9's "asks again and asks for the build go"
1 of 3, because Haiku did not load the skill at all on E9. The bar set before the runs (outcome cases score higher with
the skill wherever there is headroom, safety checks pass, the trigger cases fire as expected) was met on Sonnet and Opus
and not on Haiku; Haiku's results are reported, not used as the bar. E10 ran on Sonnet only, without the no-plugin arm
(the comparison there is line versus no line): 3 of 3 started with the line, 0 of 3 without.

*Which text the runs used.* Opus and Haiku ran every case on the released skill text. On Sonnet, E4 and E9 ran on the
released text and the other cases on the text before two late edits to the checkpoint rules (how a "go ahead" is read
while a question is open, and answers given before a checkpoint). Two changes came after every eval and stranger run, and
neither was re-run: the small-plan rules (the `pm-check` warnings above and a note that a small plan stops for you only
twice) and naming the review log through the `review_naming` setting. Cost: about $9 on Sonnet, $31 on Opus and $1.40 on Haiku for the
main runs, plus $0.84 for E10.

**How the graders work.** A grader sees either the run's trace or one named file, so the checks are built two ways:

- **Structural checks** (are all seven gate lines there, in order?) are regular expressions over the trace, anchored on
  the agent's own `Write` call to a file under `plans/`. They must be anchored. Once the skill loads, its own text, which
  also contains gate lines, appears in the trace, so an unanchored pattern would pass on the skill's text alone.
- **Semantic checks** (does the plan record the constraint? are the owner's calls left open?) are graded by a model. Where
  a case edits a fixture plan at a known path, the grader reads that file. Where the agent picks the plan's path itself
  (E1, E2), the grader reads the trace.

**Running them yourself:**

```
claude plugin eval . --ablation with-without --runs 3 --model <model> --scaffold \
  --allow-tools Write Edit Bash --no-publish --trust-plugin --threshold 0 --tag main \
  --output-dir /an/absolute/path/outside/the/repository
```

`--scaffold` runs each case's `fixture.sh` on your machine as you, so read them first. Without `--no-publish` the report
may be published to claude.ai (the default when your account supports it). E6 runs on its own with `--tag no-agents
--disallow-tools Agent Workflow`, and E10/E10b with `--case 'E10*' --ablation none`. Pass `--threshold 0`: it defaults
to 1.0, an absolute floor per case, so without it a non-zero exit code can simply mean some case scored below 1.0. With
it, a non-zero exit means an error or the cost cap. The bar is the comparison of the two arms in
`aggregate-result.json`, not the exit code. `--max-cost-usd` applies to one invocation, so if you loop over cases, divide
your budget between them.

### Simulated strangers

The strangers were Claude playing an engineer who had never seen the skill. Each one got this README and a fresh clone of
this repository, made a small toy project of its own with one hidden thing in it (half-built code, an unused function),
and drove a headless Claude Opus session turn by turn (`claude -p --plugin-dir <clone>`), to checkpoint A and past it.
Run A had every tool; run B had no sub-agents (no Agent or Workflow tool), standing in for agents that cannot spawn them.
No people were involved, and no fix was made to the package during any run.

The final pair, on the released checkpoint rules:

| | Run A (full tools) | Run B (no sub-agents) |
|---|---|---|
| Project | a league scoreboard CLI | an invoice CLI |
| Started | not on the first request (no planning words: it built a draft); yes on the second, naming the skill | yes, on "can you plan it and get it moving?" |
| Checkpoint A | reached on call 2, 3 questions; verdict and priority left to the owner | reached on call 1, 2 questions plus a bundled "take my picks" |
| Hidden thing | found (an unused filter function) | found (a stub and an unused function) |
| Review | 3 passes; 35 findings, each routed | four prompt files, each pasted into a fresh session; 22 findings read and routed; no author leads in the prompts |
| "Go ahead" | built only after it had asked for the build go with every question answered; on a branch, not merged | a bare "go ahead" with two questions open: built nothing, asked both again |
| Fault seen | a plan labelled `small` ran 3 review passes and asked 10 questions over 5 calls | a change that totals money owed labelled `small`, then run through the adversarial review |
| Cost, time | $4.74, about 20 minutes | $1.50 plus $1.06 for the reviewer sessions, about 8 minutes |

Both faults in the last row are about the `small` size class. `pm-check` now warns on both (a small plan over 10 KB, with
the adversarial review or with more than one review pass), but no stranger has run since, and a warning is something an
agent can ignore. Earlier rounds on earlier text found the faults fixed since: a reply that skipped a question was
recorded as the owner's answer, a bare "go ahead" was taken as the build go, scratch files were left outside the project,
and review prompts carried the author's own leads.

## Reporting back

Open a GitHub issue on this repository. Useful things to include:

- which agent and model you used, and how you installed or copied the skill
- what you asked for, in your words
- the plan's gate lines, or the plan file with anything private removed
- where it went wrong, got in the way or helped, and any `pm-check` output

Reports that it worked are useful too. Please do not paste credentials, internal hostnames or anyone's personal data.

## Honest limits

- Nothing enforces invocation or the gates. The agent that wants to proceed is the one filling them in; the reviews and
  your two checkpoints are the outside checks.
- `pm-check` checks shape, not truth. A plan can pass it and still be wrong.
- Tested only in Claude Code. Cursor, Codex, Copilot and other agents are untested.
- The marketplace install was tested without a model call; the model runs used `--plugin-dir`.
- The strangers were Claude playing a stranger, not people.
- The eval runs are small samples: three runs per case and arm, on Haiku, Sonnet and Opus (E10 on Sonnet only), and two
  simulated strangers per round.
- **Weak spots measured:**
  - It does not start on a plain feature request unless the project opts in (see [Starting it](#starting-it)).
  - On Haiku, a bare "go ahead" about an existing plan did not load the skill (E9: 0 of 3), so name the skill when you
    resume on a small model.
  - The fixed re-measure date: on Sonnet, E3's "absolute date" check passed in 1 of 3 runs. The other two wrote a
    relative date, likely because the fixture gave no launch date to count from. Check the date yourself.
  - On Opus, E1's "found the half-built code" check failed 3 of 3 (E1 scored 0.67).
  - The `small` size class is the least reliable part: see the stranger table. Its `pm-check` warnings were added after
    the last stranger run.
- **Present, but no eval or stranger run exercised it.** These rules are in the skill's text; nothing measured whether an
  agent follows them:
  - using `adversarial-review` when it is installed (the evals run without it)
  - the mode for work that spans several systems (`reference/major-feature.md`)
  - naming what will fail if a review finding is ignored, and never deferring a problem the agent caused itself (the
    routing itself was seen in the stranger runs); one prompt set shared by sub-agents and fresh sessions
  - the Markdown decisions file used when no decisions page can be published (no run needed it)
  - "the cheapest test must cost less than the build and be able to fail"
  - answers given during a SPIKE-FIRST treated as provisional and asked again where the spike contradicts them
  - the decisions page naming unanswered questions, and the Markdown flow asking again for a missing answer
  - the verification rules: prove a check can fail, "could not check" is not clean, verify at the live system, reviewers
    stay read-only
  - working on without pausing inside an approved plan; scope growth is a stop; approved work is done next
  - dropping a gate whose reason has gone
  - writing for the owner: define terms, give numbers units, make each question stand alone; three or more questions go
    to a page or a decisions file, each saying what it blocks and which steps its answer moves
  - the config fields `pre_approved`, `id_scheme`, `decisions_naming`, `review_dir`, `review_naming` and `branch_rule`
  - auditing a plan against the current code before handing it off, and the kickoff template
  - saying what a reset or removal would break before recommending it; credentials by reference, never by value
  - keeping the plan file small (detail in sibling files; 25 KB is a warning, never a gate)
  - treating research output as a lead, and reading the clock before writing a time

## Releases

Each release is a new commit on top of this repository's history, made by hand. Before each push the same checks run
as for the first release, also by hand: a scan of every commit and tag for terms that must not be published (after a planted
test term proves the scan can hit), a check that every author, committer and tagger identity is the published author's, the install test
in an empty home directory, and two clean review passes of what ships. See `CHANGELOG.md`.

## License

MIT. See `LICENSE`.
