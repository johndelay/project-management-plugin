# pm.config.md — project settings for project-management

Put this at a project root; the skill uses the nearest one walking up from the working directory. Every field is optional;
an absent field uses the skill's Defaults (restated in the comments). Only the first fenced `yaml` block is read.

```yaml
owner: null                        # who decides priorities and owner calls; default: the person asking
env: {}                            # variables to export before allocator/claim commands
repos: []                          # git repos the work touches (each is fetched first); default: the current repo
plans_dir: null                    # default: the existing plan convention, else plans/ at the git top level, else plans/ under cwd
plan_naming: "<slug>.md"
draft_naming: null                 # e.g. "_draft-<slug>.md" if a checker rejects a plan with no roadmap row yet
companion_naming: null             # e.g. "<plan>-<part>.md" for a plan in parts
plan_numbering: null               # how a plan number is chosen, if plans are numbered
spikes_dir: null
spike_naming: "SPIKE-<slug>.md"
decisions_naming: "<plan-slug>-decisions.md"   # the decisions file when no page tool exists
review_dir: null                   # default: <plans dir>/review/
review_naming: "<plan-slug>-<kind>.md"         # kind = requirements, prompt-<lens>, reply-<lens>, review-log
intake: []                         # e.g. [ideas/INBOX.md]
backlog: null                      # default: an existing backlog file near the plans, else <plans dir>/BACKLOG.md
roadmap: null
queue: null                        # the single "what's next" list, if any
id_scheme: null                    # a regex for decision ids; default plan-scoped D1, D2, ...
id_allocator: null                 # a command that hands out ids, if several sessions share the project
claim: null                        # a command to claim a shared file before editing
release: null                      # its release command
checker: null                      # the project's own plan checker, if any; the skill's pm-check runs regardless
step_tags: {owner: "[O]", claude: "[C]"}
status_map: null                   # lifecycle phase -> the project's status word; only then is a Status: line written
pre_approved: []                   # standing grants from the owner, e.g. "push to feature branches"; default none: ask
branch_rule: null                  # default: confirm the branch before the first commit; never merge to the default branch on "commit and push"
adversarial_triggers: []           # ADD to when general+adversarial review is required; never subtract
deploy_gates: []                   # named deploys and what each ships
hotspots: []                       # globs never owned by two parallel streams
must_read: {}                      # area -> docs; default: the nearest status file and agent instructions, else the README
max_parallel: 3
save_command: null                 # the project's save/log step, if any
```

## Notes
Project-specific verification habits, suites that must run alone, anything a stream must know.
