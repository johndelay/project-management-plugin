# Owner communication — questions, checkpoints and handoffs

Loaded at Checkpoint A, Checkpoint B, and any time the owner must decide something.

## What belongs to the owner
The verdict (GO / NO-GO / SPIKE-FIRST), priority and roadmap position, appetite, the build go, anything outward (accounts,
DNS, credentials, deploys, messages, publishing), anything users will notice, and the plan's statement of purpose. Draft
these as recommendations if you like, but mark them ⚑ and ask. A ⚑ is resolved only when the line cites the decision id
that answered it. Never record an owner call as decided because it seemed obvious.

## Asking
- **Verify each question's premise first.** A question built on a stale fact wastes the owner's answer. Questions also
  go stale while they wait: before applying an answer, re-check its question against what shipped or changed since, and
  re-ask one that events overtook.
- **Each question stands alone:** what it is in plain words, what it blocks, **which plan steps its answer moves** (an answer
  that reorders the steps says so), why it is the owner's call, the options with their consequences, your recommendation
  first and labelled.
- **Numbering is locked** to the plan: question 3 on the page is question 3 in the plan and in the answer ids.
- **One plain list, grouped by who can answer.** Never make the owner track internal ids or cross-references between files.
- **1–2 questions:** inline in your reply. **3 or more:** a decisions page or a decisions file, plus the questions inline.
- **When scope is a cut-list choice,** give a short options brief: each option, what it costs, what it drops.

## The decisions page (when you can publish a page)
Start from `templates/decisions-page.html`. Keep the reply bar: it builds a one-line reply like `1a 2b 3a` that the owner pastes
back, and it names any question left unanswered (`Q4 unanswered`) so a skipped question cannot pass silently.

## The decisions file (when you cannot)
Copy `templates/decisions.md` into the project, named per config `decisions_naming` (default `<plan-slug>-decisions.md`
beside the plan). Fill one block per question; the owner writes the answer under each `Answer:` or replies `1a 2b …`. Put
the questions inline in your reply as well, and say where the file is. Never leave it in a temporary or scratch folder the
owner cannot find.

## After the answers
- Record each answer as a decision with an id in the plan's Decisions section, quoting the owner where the words matter.
- **Answers given before the checkpoint count** when the owner gave them in their own words (in the request, or during a
  spike): record each as a decision with the quote and do not ask again, unless research has since contradicted it. An
  inferred or implied answer is not one, and none of them is the build go.
- **An open question is never yours to declare non-blocking.** Offering "it's safe to build without it" is fine; a bare
  "go ahead" after that still leaves the question open. Ask whether to build without it, and wait for that answer.
- **Silence is not an answer.** A partial answer: restate exactly what is still open before going on. A missing number is
  re-asked, never assumed, and never filled with your own recommendation, even if the reply says so ("I took your go ahead
  as accepting my picks" is that failure, disclosed in a sentence the owner can miss).
- A bare "go", "ok" or "go ahead" that could answer more than one thing: ask which. At Checkpoint B in particular, an earlier
  "go ahead" never covers the build, and a go given while any owner question is still open is not the build go: list the
  open questions, ask for each answer, then for the build go.
- **A small plan has two owner stops, A and B.** Questions a review raises between them wait for B, bundled; a reply
  that ends on new questions every turn has stopped being small: re-class it as standard and say so.
- **Many small choices** (a small plan has a cap of 2 questions per checkpoint): ask one bundled question, "take my picks on
  X, Y and Z, or name the ones to change", so the owner's yes is explicit. More than that ⇒ the plan is not small; re-class.
- At Checkpoint A, re-check appetite as soon as the answers land; they often change it.
- An approval is a commitment: the approved work is done next, not after a self-chosen detour.

## Checkpoint B — what to show
What the review changed (and any owner decision the review now contradicts, re-asked), the open findings, the steps and
streams, every owner step, and which steps each answer moves. Then ask for the build go explicitly.

## Writing for the owner
- Define every term on first use ("the checker" = which script); no unexplained labels.
- Every number has a unit and, if measured, a date.
- Lead with the answer; be specific and short.
- When asked "what's next" or "what's waiting on me", list **every** item waiting on the owner, each with its age.
- Credentials by reference (a vault path, an environment variable name), never by value; if a step will make the owner
  approve a prompt that touches a secret, say so before it appears.

## Handoffs (every stop)
The first line says what is **not** done yet (a reader who sees only that line must not think the work is finished). Then:
the state (gate lines), what was decided (ids), what is open, the next three actions, who does each (owner / agent), a
paste-ready prompt for the next session, and the date. "DONE" and "queued next" never appear in the same handoff for the
same item. Write the handoff before context runs low, and split a session whose steps ran over into the next one.
