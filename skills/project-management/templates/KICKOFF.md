# Kickoff — {{plan id}} · Stream {{S#}}: {{slice name}}

You are building ONE stream of a larger plan. Plan of record: `{{path to plan}}`. Read its Design, Definition of Done and
your stream's Workstreams row. Do not edit the plan; report back instead.

**Audit each remaining item against current code before acting.** The plan was written earlier; files may have moved since.
For each item you are about to build, open the code it touches and confirm the plan's premise still holds. If it doesn't,
stop and report the mismatch instead of building on it.

**Base:** your branch must contain `{{SHA taken after git fetch}}`. First command:
`git merge-base --is-ancestor {{SHA}} HEAD && echo BASE-OK`. If it does not print BASE-OK, stop and report.

**Read first:** {{must-read docs for this area}}

**You own these globs (repo-relative) — touch nothing else:**
- `{{glob}}`
If another file must change, stop and report; do not edit it. Never touch a hotspot: {{hotspots}}.

**Deliver (your Definition of Done items, each with how it is observed):**
- [ ] {{item}} — **observed by:** {{how}}

**Verify with:** `{{command}}`. Capture the exit code without a pipe (`out=$(cmd); rc=$?`) and report rc.
Run alone, never in parallel: {{suites, or "none"}}.

**Never:** deploy, send any communication, push, merge, switch the checkout of a tree someone else is reading, or
`git commit -a`. Commit your owned paths by name. Credentials by reference only, never by value.

**If you are a reviewer, not a builder:** you write nothing. Read-only: no edits, no commits, no checkout switches. Report
findings in your reply.

**Handoff — end your reply with exactly:**
```
STREAM {{S#}} HANDOFF
not done: <first line: what is NOT done yet, or "nothing">
branch: …
commits: <output of git log --oneline BASE..HEAD>
status: <output of git status --short, or "clean">
verify rc: …
DoD: <each item: done/not, how observed>
open questions: …
```
The orchestrator re-checks all of this with git itself; the handoff is a map, not evidence.
