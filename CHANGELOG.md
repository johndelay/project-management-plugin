# Changelog

Versions are bumped by hand in `.claude-plugin/plugin.json` for each release. Each later release is a new commit on top
of the public history, made by hand, and gets the same checks before it is pushed, also run by hand: the scan of
every commit and tag for terms that must not be published (after a planted term proves it can hit), the identity check, the install test in an empty
home directory, and two clean review passes of what ships.

## README revision after 3.0.0 (docs only; the `project-management--v3.0.0` tag predates it)

- The `CLAUDE.md` opt-in line for plain feature requests is narrower: new features, new projects and builds that span
  sessions, not routine ops, config changes, fixes or investigations. The broad first version started the skill on a
  three-file ops move (2 of 3 runs) and the agent then edited without a plan; the narrower one did not start the skill
  there (0 of 3). Measured on one ops task and one small config edit; fixes and investigations were not tested. Numbers in the README (E11, E12).
  No skill or checker change.

## 3.0.0

The first public release.

### Added
- The `project-management` skill as one self-contained folder: `SKILL.md`, six reference files loaded per phase
  (review, verification, parallel work, owner communication, closing, and a mode for work across several systems), and
  templates for the plan, a stream kickoff, the project config, a decisions page and a Markdown decisions file.
- Seven gate lines (intake, value, spec, review, plan, build, close) as the plan's only status, with a fixed set of
  states for each, including `PARKED` with a re-entry trigger. Plans written from this version carry a
  `<!-- pm-template: v3 -->` marker.
- A capabilities line and a fixed defaults block at the start of every invocation, so a run states which companions and
  settings it found and which fallbacks it used.
- Size classes: small, standard and major.
- Review without sub-agents: prompt files for fresh sessions, with the replies read, logged and routed.
- Finding routing (fix now, defer to the backlog, or ask the owner); a problem the plan itself caused is never deferred.
- `pm-check`, a read-only plan checker that proves itself on every run with an embedded control (exit 2 if the control
  fails), and its `overlap` subcommand, a build-time guard over the real branch diffs. Plans without the marker get INFO
  lines only.
- `test-pm-check.sh`, the checker's test suite.
- Eval cases for `claude plugin eval` (E1–E9, each scored with the plugin and without it; E10/E10b, the `CLAUDE.md`
  opt-in line with and without).
- A build go is explicit: a "go ahead" while an owner question is open builds nothing, and the agent asks again.
- `pm-check` warns when a plan labelled `small` is over 10 KB, runs the adversarial review, or runs more than one review
  pass.
- Every review file, the review log included, is named by the `review_naming` setting, so a project's own checker can
  find them.
