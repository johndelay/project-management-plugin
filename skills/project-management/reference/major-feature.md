# Major feature — work that spans more than one system

Loaded when the size class is **major**: more than one system or repo, or the owner asks. ⚠️ **Untested:** this mode has not
been through the release evals; treat each step as a recommendation and tell the owner when one does not fit.

## Phase 0 additions
- **Estimate the context cost first.** Count the systems, repos and documents the plan must read; if one session cannot hold
  them, plan the discovery as several sessions or sub-agents from the start and say so.
- **Glossary and people sweep.** List the terms each system uses for the same thing, and the people or roles who own each
  system. Mismatched names are where cross-system plans break.
- **Decision sweep.** Collect decisions already made about these systems (in docs, tickets, earlier plans) so the plan does
  not re-ask or silently reverse them. Each one cited with its source.

## Discovery
- **Fan out by system:** one read-only sub-agent (or session) per system answers the same questions: what exists, current
  state measured and dated, interfaces, owners, risks. Ask for short answers; verify one load-bearing claim from each before
  relying on it.
- **Already exists?** asked per system, then across systems.

## Structure
- **An umbrella plan** holds the gates, decisions, Definition of Done and steps for the whole effort, and nothing else that
  can live elsewhere.
- **One file per system** (named per config `companion_naming` if set), each linked from the umbrella and linking back; each
  carries that system's current state, design and steps.
- **A decision point file** when the owner must choose between system-level options: the options, what each costs, what each
  drops, a recommendation; answered like any decisions file.

## Through the build
- Streams usually follow system boundaries; a change that crosses systems is its own slice with both owners named.
- **Keep a process record:** one dated section per session — what was asked, what was found, what was decided, what changed
  the plan. Long efforts lose their reasons fastest; the record keeps them for the close and for anyone who reviews it later.
