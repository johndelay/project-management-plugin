# Review — Phase 3 in detail

Loaded at Phase 3. The spine says *when* to review; this file says *how*.

## Inputs (write these before any reviewer starts)
- **A requirements file** in the review folder (config `review_dir`, default `<plans dir>/review/`; named per `review_naming`,
  default `<plan-slug>-requirements.md`). Copy, don't summarize: the owner's words from Origin verbatim, the decisions with
  ids, the Value table, Constraints, and the Definition of Done. A reviewer can only find an omission against a list of
  what was required, and summarizing is where items vanish.
- **The artifact:** the plan file (and any sibling spec).
- **Primary sources:** the code, the running system, the docs the plan makes claims about.
- **A tool-access statement:** what the reviewer can and cannot run. Reviewers are read-only: no edits, no commits, no
  checkout switches in a tree someone else is reading. Experiments go in a throwaway directory.
- **No author leads.** Never tell a reviewer what you suspect, what you already fixed, or why you chose something, and add
  no "look in particular for…" list of edge cases or weak spots: that list is your leads. A reviewer given your leads finds
  your leads.

## The general review ("improve it")
Prompt, filled in and given to one fresh reviewer:
> Review the plan at [path] against the requirements at [path]. Sources: [paths]. You are read-only. Report: (1) prior art —
> does something already do all or part of this; (2) a simpler alternative that meets the same requirements; (3) options the
> plan never considered; (4) conflicts with how this project actually works (read the code and docs, not the plan's account
> of them); (5) a pre-mortem — it is the re-measure date and this failed: why? For each finding: what, the evidence (quote
> the plan and the source), and whether it is structural (scope, design, a wrong premise) or polish. Report only findings.

Pre-mortem results seed the plan's Risks table.

## The adversarial review ("break it") — three lenses
If the `adversarial-review` skill is installed, use it (tier high) with the requirements file, the plan and the sources.
Otherwise spawn three fresh reviewers, one per lens, never merged into one; each prompt is the template below, filled.
<!-- lens-text: begin — copied word for word from the public adversarial-review skill; each release checks this block still matches -->
**Prompt template (fill the bracketed lens-specific parts):**
> You are an adversarial [OMISSION / CORRECTNESS / CONSISTENCY] auditor. A colleague produced the artifact below and believes it is complete and correct. You are biased toward agreeing -- RESIST that. Assume at least one [missing deliverable / confidently-wrong claim / internal contradiction] exists, and find it. Start by hunting for the worst defect, not by validating the good parts. Do NOT praise the artifact and do NOT report what it did well -- report only defects. If after genuine effort you find nothing in your lens, say so plainly rather than inventing a nitpick -- but you must genuinely try first.
> [Artifact path. Frozen requirement set. Primary sources. Tool-access statement.]
> [Lens method, below.]
> Return findings most-severe-first. For each: defect | evidence (quote the artifact AND the ground-truth source) | severity (REAL / minor / defensible) | your evidence tier. Your final message IS the result -- no preamble.

**Lens A -- OMISSION / COVERAGE.** Build a coverage matrix: one row per required deliverable, extracted *verbatim from the frozen requirement set and source artifacts*, NOT from the artifact's own summary (summarizing is where deliverables vanish). Per row: FULLY / PARTIALLY / NOT addressed + what's absent. A row with no producing step is a gap that lights up mechanically. Also hunt: collapsed sub-bullets; **an adjacent problem solved via a new mechanism while the original ask is silently treated as done**; in-scope artifacts never reviewed; any required section with far less depth.

**Lens B -- CORRECTNESS.** Assume >=1 confidently-wrong claim and >=1 bad load-bearing assumption exist; find them. Verify each factual claim against its PRIMARY source (read the diff; read the closing comment; state the field's granularity; fetch the citation). Name the single assumption the main conclusion rests on and argue the strongest case it's wrong. On any visible mismatch, generate the alternative hypothesis ("this is a different fix entirely") before rationalizing past it. Flag stale claims (a state that has since changed) and fabricated/misattributed citations.

**Lens C -- CONSISTENCY / EDIT-REGRESSION.** Check the artifact against itself -- especially valuable after multi-spot edits. Every "we no longer think X": does any residual sentence still assert X? Every "see section N": does N still say that? Every count ("four gaps," "27 items"): consistent everywhere, and does the enumeration actually contain it? BLUF <-> body <-> summary drift.
<!-- lens-text: end -->

## Without sub-agents
Write each filled prompt to a file in the review folder (`<plan-slug>-prompt-<lens>.md`), as the template reads, with
nothing of yours added. Ask the owner to paste each into a
**fresh** session (a new chat, not this one) and save the full reply beside it as `<plan-slug>-reply-<lens>.md`. Then read
each reply, log and route every finding as below. Say plainly which reviews ran and which did not. Reviewing in the same
session ("switch hats") is a last resort: label it "same-session, weaker" in the log and the gate, because the context that
wrote the plan is blind to its own gaps.

## Logging and routing
Append every finding to the review log, a sibling file in the review folder (`review_naming` with kind `review-log`;
default `<plan-slug>-review-log.md`); the plan's
Review section links it and keeps the gate line. Never edit a past row; supersede it by reference.
Columns: `# · pass · lens · finding · confirmed|relayed · verdict · route · refuses if ignored`.
- **Confirmed** = you re-checked the source yourself; **relayed** = taken at the reviewer's word. Re-check the sharpest
  findings before acting on them; reviewers err in both directions.
- **Verdict:** REAL / partially fair / false alarm / not a finding. Record the discards too.
- **Route:** **fix now** · **defer** (with a backlog id) · **owner** (asked at the next checkpoint). A problem the plan
  itself caused is never deferred.
- **Refuses if ignored:** name the check, test, gate or step that will fail if this finding is not acted on. A finding bound
  to nothing is advice; an advisory check is not a control.
- **Blast radius:** when a fact is corrected, find every place it was restated or relied on and fix each one.

## Counting passes
A pass = one review of one revision by fresh reviewers. A consistency re-check after localized fixes is not a pass. Run
another pass only if the last one had a REAL structural finding (scope, design, a wrong premise); polish needs none. More
than three passes needs an owner decision id. A structural finding means rewriting the affected sections from the recorded
decisions and findings, never a correction banner over text that still argues the old case.

## The gate line
`Gate (review): <N> passes, <M> findings, <K> open - declared <depth>, delivered <what ran>`. Declared depth and delivered
review are both stated; a waiver, a fast lane or an owner-directed shortcut names its decision id, its scope and what was
skipped. Never write "complete".
