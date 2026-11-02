# Verification — how "done" is proven

Loaded at Phase 5 and Phase 6. The rule behind all of it: **assume the check is broken before the system is.** A clean
result from a check that could not have failed proves nothing.

## The six evidence steps (a stream is done only on these)
1. `git log <base>..<branch>` shows the commits the stream says it made.
2. `git status` is clean in that stream's worktree.
3. `git merge-base --is-ancestor <base> <target>` — the stream started where the plan says.
4. On a merge conflict, read **both** sides' reasons before choosing; never take "ours" to make it go away.
5. Re-run the verification on the **merged** tree, not the branch. Timing-sensitive suites run alone.
6. Check each Definition of Done item **the way it says it is observed** — the screenshot, the live read, the measurement.

An agent's "committed as abc123, tests pass" is a map to these checks, not a substitute for them.

## Make the check able to fail
- **Prove it can fail first.** Plant one known defect (or point it at a known-bad input) and watch it go red before
  trusting its green. A suite nobody has seen fail may not be running at all.
- **"Could not check" is not clean.** A command that errored and printed nothing looks exactly like "0 problems". Capture
  exit codes without a pipe (`out=$(cmd); rc=$?`, or `set -o pipefail`), and treat a non-zero you did not expect as unknown.
- **Exact-match "not found" is not absence.** Search loosely too, or open the file.
- **Arguments that start with `-`** are read as flags; pass `--` or a `./` prefix before any dynamic value.
- **Compare like units:** characters vs bytes vs lines; local time vs UTC.

## Verify at the real surface
- **At the live system, not the config.** A deploy is verified by reading the running service, not the file that should have
  changed it. A service "active" in its manager can still be doing nothing; check its output.
- **Semantics, not arithmetic.** Re-deriving a number proves the arithmetic. Before a decision rests on it, check what the
  data source can and cannot see (a gap in coverage looks like a low count).
- **Automate the check you'd ask a person to do,** so it can be re-run; then run it yourself and report PASS/FAIL with the
  output.

## Reviewers and readers
- Reviewers and verifiers are read-only: they report proposed changes; the orchestrator applies them.
- Never switch, stash or check out branches in a tree another agent is reading; use `git show <sha>:<path>`, `git diff` or
  a separate worktree.

## Claims you inherit
- **Research output is a lead.** A sub-agent's (or your own earlier) specific claim — a flag, a version, a count, a quote —
  is checked against something executable or a primary source before it is relied on.
- **Re-read the source of an inherited rule** before applying it; a summary of a rule drifts from the rule.
- **Mark evidence** observed (you saw it) vs inferred (you reasoned it). Say whether a missing signal was absent or existed
  and was ignored, and say it before writing code on top of it.
- **A file on disk is not the remote:** `git fetch` before any claim about a repo, and report divergence first.
- **Read the clock** (`date`) before writing any time; never estimate one.
- **Pace fan-out** to the tools' limits: a cheap model for mechanical sweeps, a stronger one for review; ask before a fourth
  large fan-out in one session; ask sub-agents for short answers.

## Ticking a Definition of Done item
Each tick names its evidence rung, strongest first:
1. **re-run on the merged tree** (the check ran again, now, on what ships);
2. **live read** (you looked at the running system or the real output);
3. **recorded result** (a log, a report or an earlier run — say whose and when).
An item only the owner can observe (a person's reaction, a production metric weeks out) is not ticked: give it a due date
and a fallback, and leave it open with the reason.
