# Closing — finishing, re-measuring, parking and abandoning

Loaded at Phase 6, and whenever a plan is parked or abandoned.

## Close on success
1. **Re-read Origin and the intake readback** — the owner's words, not your summary — and check each ask against what
   shipped before calling anything handled.
2. **Definition of Done:** tick each item with its observation and evidence rung. An item only the owner can observe gets
   a due date and a fallback instead of a tick. An item not delivered loses its box and is struck:
   `- ~~item~~ - not delivered (why)`. Never leave an open box under a closed gate, and never tick what was not observed.
3. **Protections:** never bulk-remove monitors, alerts, backups or checks on an assumption that they are redundant; prove
   each one, and default to keeping it. A rebuild restores the whole original spec, not
   just the data path; list any gap before saying done.
4. **Corrected facts:** when a fact was corrected during the work, find every place it was restated (plan, docs, backlog,
   tickets) and fix each one.
5. **Status in one change:** the plan's close gate, any roadmap row and any queue line are updated in the same commit;
   rows are labels, not essays.
6. **Run the checker** and report its exit code (captured without a pipe).
7. **Reconcile ideas:** list every idea, request and gotcha raised during the work → shipped (where) or a backlog line.
8. **Book the re-measure** (below), and offer the project's save step if it has one.
9. `Gate (close): DONE - <date>`.

## Partial close
When some slices shipped and others did not: `Gate (close): partial - <which slices, what remains>`. The plan stays in the
building phase; the shipped slices' DoD items are ticked, the rest stay open with their reason.

## The re-measure
- At GO, the Value table's re-measure date is an absolute `YYYY-MM-DD` (relative dates like "a month after launch" lapse
  silently). Book a dated backlog line for it at close, naming what is measured and where the evidence will come from.
- On the date, measure and fill the Value table's **Re-measured result** row: date — value vs the success metric —
  keep / revisit / kill. That row is the only home for the result.
- **Fallback:** not measured by the date ⇒ write "not measured - <why>" in that row and re-ask the owner for a new date or a
  decision. Never leave it blank.
- Value kill triggers fire here too: their pre-agreed action is taken, or the owner waives it with a decision id.

## Parked
A plan paused on purpose: set the gate where it stopped to
`PARKED — re-entry: <the trigger that resumes it>; exposed: <what stays unprotected meanwhile>`.
Record the decision id that parked it. On resume, re-check the exposure first.

## Abandon (NO-GO, a kill trigger, or the owner stops it)
- Fill the remaining gates, close included, with `ABANDONED - <reason, decision id>`.
- Return unshipped ideas to intake or the backlog with the reason.
- Update the roadmap row, or never create one.
- Undelivered checklist items lose their box and are struck (`- ~~item~~ - not delivered (ABANDONED)`): never ticked, never
  left open under a closed status. A finished record, not a half-open one.

## Many plans at once
To sweep a folder of plans, loop the checker over them (`for p in plans/*.md; do python3 <skill folder>/scripts/pm-check
"$p"; echo "$p rc:$?"; done`) and read each non-zero. Plans written before v3 (no `<!-- pm-template: v3 -->` first line) get
INFO lines only.
