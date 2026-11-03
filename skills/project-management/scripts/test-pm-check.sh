#!/usr/bin/env bash
# test-pm-check.sh: the pm-check test suite.
#
#   bash test-pm-check.sh                     # tests ./pm-check
#   PM_CHECK=/path/to/copy bash test-pm-check.sh   # tests another copy (e.g. one with a rule disabled)
#
# One line per case: PASS or FAIL, the case name, and why. Exit 0 only if every case got its expected
# exit code and named its rule, and the number of cases run is the number written below.
# Needs bash, python3 and git. Writes only under one `mktemp -d` directory, removed on exit.
set -u

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PMC=${PM_CHECK:-$DIR/pm-check}
[ -f "$PMC" ] || { echo "FAIL setup: no pm-check at $PMC"; exit 2; }
PMC=$(cd "$(dirname "$PMC")" && pwd)/$(basename "$PMC")   # absolute: the git cases run from another dir
PY=${PYTHON:-python3}
FX=$DIR/fixtures
CFG=$FX/config-garden.md
CLEAN=$FX/v3-clean.md
EXPECTED_CASES=85   # one per expect / vcase / ccase call below; a skipped case turns the suite red

TMP=$(mktemp -d "${TMPDIR:-/tmp}/pm-check-test.XXXXXX") || { echo "FAIL setup: mktemp -d failed"; exit 2; }
trap 'rm -rf -- "$TMP"' EXIT
pass=0
fail=0

record() {  # record PASS|FAIL NAME DETAIL [OUTPUT]
  if [ "$1" = PASS ]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi
  printf '%s %-34s %s\n' "$1" "$2" "$3"
  if [ "$1" = FAIL ] && [ -n "${4:-}" ]; then
    printf '%s\n' "$4" | head -n 6 | sed 's/^/      | /'
  fi
}

# expect NAME WANT_RC RULE MODE PATTERN -- COMMAND...
#   PATTERN  an extended regex that at least one output line must match ("-" = none)
#   MODE     only  : every ERROR/WARN line names RULE
#            one   : exactly one ERROR/WARN line
#            noerr : no ERROR/WARN line at all
#            any   : no condition on the other lines
expect() {
  local name=$1 want=$2 rule=$3 mode=$4 pat=$5
  shift 6
  local out rc why="" line hit=0 n_err=0 other=""
  out=$("$@" 2>&1)
  rc=$?
  [ "$rc" = "$want" ] || why="rc $rc, want $want"
  while IFS= read -r line; do
    if [ "$pat" != "-" ] && [[ $line =~ $pat ]]; then hit=1; fi
    case $line in
      "ERROR "* | "WARN "*)
        n_err=$((n_err + 1))
        case $line in
          "ERROR $rule L"* | "WARN $rule L"*) ;;
          *) [ -n "$other" ] || other=$line ;;
        esac
        ;;
    esac
  done <<<"$out"
  if [ -z "$why" ] && [ "$pat" != "-" ] && [ "$hit" != 1 ]; then why="no output line matches /$pat/"; fi
  if [ -z "$why" ]; then
    case $mode in
      only) [ -z "$other" ] || why="another rule fired: $other" ;;
      one) [ "$n_err" = 1 ] || why="$n_err ERROR/WARN lines, want exactly 1" ;;
      noerr) [ "$n_err" = 0 ] || why="$n_err ERROR/WARN lines, want none" ;;
      any) ;;
      *) why="test bug: unknown mode $mode" ;;
    esac
  fi
  if [ -z "$why" ]; then
    record PASS "$name" "rc $rc${pat:+, /$pat/}"
  else
    record FAIL "$name" "$why" "$out"
  fi
}

# plant SRC DEST OLD NEW [OLD NEW ...]: copy SRC to DEST with each OLD (which must occur exactly once)
# replaced by NEW. A planted defect is then the ONLY difference from the clean fixture.
plant() {
  "$PY" - "$@" <<'PY'
import sys
src, dst, pairs = sys.argv[1], sys.argv[2], sys.argv[3:]
t = open(src, encoding="utf-8").read()
for old, new in zip(pairs[0::2], pairs[1::2]):
    n = t.count(old)
    if n != 1:
        sys.exit("plant: %r occurs %d times in %s (need exactly 1)" % (old, n, src))
    t = t.replace(old, new)
open(dst, "w", encoding="utf-8").write(t)
PY
}

# vcase NAME RULE MODE PATTERN OLD NEW [...]: one planted defect in the clean v3 fixture => rc 1
vcase() {
  local name=$1 rule=$2 mode=$3 pat=$4 msg
  shift 4
  if msg=$(plant "$CLEAN" "$TMP/$name.md" "$@" 2>&1); then
    expect "$name" 1 "$rule" "$mode" "$pat" -- "$PY" "$PMC" "$TMP/$name.md" --config "$CFG"
  else
    record FAIL "$name" "could not plant the defect: $msg"
  fi
}

# ccase NAME LINE OLD NEW: one unparseable line planted in the clean config => rc 2 naming that line
ccase() {
  local name=$1 ln=$2 msg
  shift 2
  if msg=$(plant "$CFG" "$TMP/$name.config.md" "$@" 2>&1); then
    expect "$name" 2 config only "^ERROR config L$ln: " -- "$PY" "$PMC" "$CLEAN" --config "$TMP/$name.config.md"
  else
    record FAIL "$name" "could not plant the config line: $msg"
  fi
}

echo "pm-check suite: $PMC"

# ── clean v3 plans: rc 0 ─────────────────────────────────────────────────────────────────
expect clean-v3 0 - noerr '^INFO P0 L0: embedded control passed' -- "$PY" "$PMC" "$CLEAN" --config "$CFG"
expect clean-v3-owner-step-is-info 0 - noerr '^INFO P11 L[0-9]+: an open owner step' -- "$PY" "$PMC" "$CLEAN" --config "$CFG"
expect clean-v3-flow-config 0 - noerr '^INFO config L0: config: .*config-flow.md' -- "$PY" "$PMC" "$CLEAN" --config "$FX/config-flow.md"
expect clean-v3-parked 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$FX/v3-parked.md" --config "$CFG"
expect clean-v3-today-accepted 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$CLEAN" --config "$CFG" --today 2031-05-01
expect config-found-walking-up 1 P4 only "maps to 'harvested'" -- "$PY" "$PMC" "$FX/walkup/plan.md"

# ── one planted defect per rule: rc 1, and only that rule fires ──────────────────
vcase p2-state-not-in-vocabulary P2 only '^ERROR P2 L[0-9]+: Gate \(build\): .* is not a state' \
  'Gate (build): built + verified — 2031-04-16, streams merged 2/2' 'Gate (build): finished on 2031-04-16'
vcase p2-parked-without-trigger P2 only '^ERROR P2 L[0-9]+: Gate \(build\)' \
  'Gate (build): built + verified — 2031-04-16, streams merged 2/2' 'Gate (build): PARKED — waiting for spring'
vcase p2-missing-gate P2 only "^ERROR P2 L0: missing the 'Gate \(spec\):' line" \
  'Gate (spec): drafted — open decisions: none' ''
vcase p2-gate-twice P2 only '^ERROR P2 L[0-9]+: Gate \(review\) appears again' \
  'Gate (review): 1 pass, 1 finding, 0 open — declared general, delivered general' \
  $'Gate (review): 1 pass, 1 finding, 0 open — declared general, delivered general\nGate (review): 2 passes'
vcase p2-out-of-order P2 only '^ERROR P2 L[0-9]+: Gate \(intake\) comes after Gate \(value\)' \
  'Gate (intake): captured — readback items 1–2 above' '' \
  'Gate (value): GO — D1' $'Gate (value): GO — D1\n\nGate (intake): captured — moved'
vcase p2-unknown-gate P2 only "^ERROR P2 L[0-9]+: unknown gate 'Gate \(deploy\)'" \
  'Gate (close): DONE — 2031-04-18, D1..D4' $'Gate (close): DONE — 2031-04-18, D1..D4\nGate (deploy): done'
vcase p4-status-disagrees P4 only "^ERROR P4 L4: \*\*Status:\*\* says 'building'" \
  '**Status:** done' '**Status:** building'
vcase p4-status-line-missing P4 only '^ERROR P4 L0: the config has a status_map but the plan has no' \
  '**Status:** done · ' ''
vcase p5-flag-cites-no-id P5 only '^ERROR P5 L[0-9]+: a ⚑ recommendation cites no decision id' \
  '- ⚑ Show the card at 18:00 local time. Accepted with the threshold, D2.' '- ⚑ Show the card at 18:00 local time.'
vcase p10-dod-not-observed P10 only "^ERROR P10 L[0-9]+: a Definition of Done item has no 'observed by:'" \
  ' — **observed by:** a test with a planted forecast of 1 °C' ''
vcase p11-struck-item-keeps-box P11 only '^ERROR P11 L[0-9]+: Gate \(close\) is DONE but this DoD box is open' \
  '- ~~A push notification~~' '- [ ] ~~A push notification~~'
vcase p11-indented-box-counts P11 one '^ERROR P11 L[0-9]+: Gate \(close\) is DONE but this DoD box is open' \
  '  — **observed by:** the same test with that bed opted out' \
  $'  — **observed by:** the same test with that bed opted out\n  - [ ] the opt-out survives a restart'
vcase p11-open-dod-box-abandoned P11 only '^ERROR P11 L[0-9]+: Gate \(close\) is ABANDONED' \
  '- [x] A bed with the opt-out shows no warning.' '- [ ] A bed with the opt-out shows no warning.' \
  'Gate (close): DONE — 2031-04-18, D1..D4' 'Gate (close): ABANDONED — 2031-04-18, D1..D4' \
  '**Status:** done' '**Status:** dropped'
vcase p11-open-claude-step P11 only '^WARN P11 L[0-9]+: an open step under Gate \(close\) DONE' \
  '- [x] **[C]** Render the alert card.' '- [ ] **[C]** Render the alert card.'
vcase p12-id-defined-twice P12 only '^ERROR P12 L[0-9]+: decision D2 is defined twice' \
  '- D4 — Push notifications become their own plan.' $'- D4 — Push notifications become their own plan.\n- D2 — A second meaning.'
vcase p12-range-cites-undefined P12 only '^ERROR P12 L[0-9]+: Gate \(close\) cites D5,' \
  'Gate (close): DONE — 2031-04-18, D1..D4' 'Gate (close): DONE — 2031-04-18, D1..D5'
if plant "$CLEAN" "$TMP/struck-def.md" '- D4 — Push notifications become their own plan.' \
  $'- D4 — Push notifications become their own plan.\n- ~~**D5** — Use a paid forecast.~~ Withdrawn for D4.' \
  'Gate (close): DONE — 2031-04-18, D1..D4' 'Gate (close): DONE — 2031-04-18, D1..D5' >/dev/null 2>&1; then
  expect p12-struck-definition-counts 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$TMP/struck-def.md" --config "$CFG"
else
  record FAIL p12-struck-definition-counts "could not plant the struck decision"
fi
# P12 group headers: a Decisions line that OPENS with a range is a header. It defines only its first id (as any
# line does); an indented sub-item under it may define that id once more without a duplicate. Nothing else loosens.
if plant "$CLEAN" "$TMP/p12-group.md" '- D1 — Build it; appetite 3 sessions.' \
  $'- **D1…D2 — answered together at checkpoint A:**\n  - D1 — Build it; appetite 3 sessions.' \
  '- **D2** — The alert threshold is 2 °C.' '  - **D2** — The alert threshold is 2 °C.' >/dev/null 2>&1; then
  expect p12-group-header-with-items-is-clean 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$TMP/p12-group.md" --config "$CFG"
else
  record FAIL p12-group-header-with-items-is-clean "could not plant"
fi
if plant "$CLEAN" "$TMP/p12-group-alone.md" '- D4 — Push notifications become their own plan.' \
  $'- D4 — Push notifications become their own plan.\n- D5..D6 — both deferred to the next plan.' \
  'Gate (close): DONE — 2031-04-18, D1..D4' 'Gate (close): DONE — 2031-04-18, D1..D6' >/dev/null 2>&1; then
  expect p12-group-header-alone-defines-first-only 1 P12 only '^ERROR P12 L[0-9]+: Gate \(close\) cites D6' -- "$PY" "$PMC" "$TMP/p12-group-alone.md" --config "$CFG"
else
  record FAIL p12-group-header-alone-defines-first-only "could not plant"
fi
vcase p12-dup-before-group-header P12 only '^ERROR P12 L[0-9]+: decision D1 is defined twice' \
  '- **D2** — The alert threshold is 2 °C.' $'- D1…D2 — answered together:\n- **D2** — The alert threshold is 2 °C.'
vcase p12-two-group-headers P12 only '^ERROR P12 L[0-9]+: decision D1 is defined twice' \
  '- D1 — Build it; appetite 3 sessions.' $'- D1…D2 — answered together:\n- D1..D3 — again:\n  - D1 — Build it; appetite 3 sessions.'
vcase p12-prose-range-defines-nothing-extra P12 only '^ERROR P12 L[0-9]+: Gate \(close\) cites D9' \
  '- D1 — Build it; appetite 3 sessions.' '- D1 … 9 beds is too many; appetite 3 sessions.' \
  'Gate (close): DONE — 2031-04-18, D1..D4' 'Gate (close): DONE — 2031-04-18, D1..D4, D9'
vcase p12-redef-under-other-item P12 only '^ERROR P12 L[0-9]+: decision D1 is defined twice' \
  '- D1 — Build it; appetite 3 sessions.' $'- D1…D2 — answered together:\n- `D3` — Other item.\n  - D1 — Nested under the other item.'
vcase p12-redef-under-other-header P12 only '^ERROR P12 L[0-9]+: decision D1 is defined twice' \
  '- D1 — Build it; appetite 3 sessions.' $'- D1…D2 — answered together:\n- D5..D6 — another group:\n  - D1 — Under the other header.'
vcase p12-redef-after-paragraph P12 only '^ERROR P12 L[0-9]+: decision D1 is defined twice' \
  '- D1 — Build it; appetite 3 sessions.' $'- D1…D2 — answered together:\n\nA paragraph that closes the group.\n\n    - D1 — Much later.'
vcase p12-prose-range-is-not-a-header P12 only '^ERROR P12 L[0-9]+: decision D1 is defined twice' \
  '- D1 — Build it; appetite 3 sessions.' $'- D1 … 9 beds is too many.\n  - D1 — Build it; appetite 3 sessions.'
vcase p12-group-ends-at-section P12 only '^ERROR P12 L[0-9]+: decision D5 is defined twice' \
  '- D4 — Push notifications become their own plan.' $'- D4 — Push notifications become their own plan.\n- D5…D6 — grouped:\n\n## Notes\nx\n\n## Decisions (more)\n  - D5 — In a later section.'
vcase p12-group-ends-at-code-fence P12 only '^ERROR P12 L[0-9]+: decision D5 is defined twice' \
  '- D4 — Push notifications become their own plan.' $'- D4 — Push notifications become their own plan.\n- D5…D6 — grouped:\n\n```\ncode\n```\n\n  - D5 — After the fence.'
vcase p12-bare-range-is-not-a-header P12 only '^ERROR P12 L[0-9]+: decision D5 is defined twice' \
  '- D4 — Push notifications become their own plan.' $'- D4 — Push notifications become their own plan.\n- D5…D6\n  - D5 — Under a bare range.'
for sep in en:'–' hyphen:'-'; do
  n=${sep%%:*}; c=${sep#*:}; c=${c//\'/}
  if plant "$CLEAN" "$TMP/p12-sep-$n.md" '- D1 — Build it; appetite 3 sessions.' \
    "- D1…D2 $c answered together"$'\n  - D1 — Build it; appetite 3 sessions.' >/dev/null 2>&1; then
    expect p12-group-header-sep-$n 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$TMP/p12-sep-$n.md" --config "$CFG"
  else
    record FAIL p12-group-header-sep-$n "could not plant"
  fi
done
if plant "$FX/legacy.md" "$TMP/p12-dated-prefix.md" '- D-2031-03-01-02 — Build it.' \
  $'- D-2031-03-01-02…D-2031-04-01-09 — grouped:\n  - D-2031-03-01-02 — Build it.' >/dev/null 2>&1; then
  expect p12-dated-range-prefix-mismatch-is-not-a-header 0 - noerr 'decision D-2031-03-01-02 is defined twice' \
    -- "$PY" "$PMC" "$TMP/p12-dated-prefix.md" --config "$FX/config-legacy.md"
else
  record FAIL p12-dated-range-prefix-mismatch-is-not-a-header "could not plant"
fi
big=$(printf '9%.0s' $(seq 5000))
vcase p12-huge-id-range-no-crash P12 only '^ERROR P12 L[0-9]+: decision D1 is defined twice' \
  '- D1 — Build it; appetite 3 sessions.' "- D1 — Build it."$'\n'"- D${big}…D9${big} — grouped:"$'\n'"- D1 — Again."
vcase p12-dup-under-group-header P12 only '^ERROR P12 L[0-9]+: decision D2 is defined twice' \
  '- D1 — Build it; appetite 3 sessions.' $'- **D1…D2 — answered together:**\n  - D1 — Build it; appetite 3 sessions.' \
  '- **D2** — The alert threshold is 2 °C.' $'  - **D2** — The alert threshold is 2 °C.\n  - D2 — A second meaning.'
vcase p13-placeholder-left P13 only '^ERROR P13 L[0-9]+: placeholder \{\{one-sentence goal\}\}' \
  'A gardener sees a frost warning on the evening before a forecast frost.' '{{one-sentence goal}}'
vcase p15-build-without-go P15 only '^ERROR P15 L[0-9]+: Gate \(build\) is .* while Gate \(plan\)' \
  'Gate (plan): go — D1, D2' 'Gate (plan): pending go-ahead'

# P16: a plan that says **Size:** small must stay within 10 KB (a WARN). Padding is a comment line, so no other rule moves.
pad16=$("$PY" -c 'print("<!-- " + "x" * 6000 + " -->")')
vcase p16-small-over-bound P16 only '^WARN P16 L[0-9]+: \*\*Size:\*\* small, but the plan is [0-9]+ bytes' \
  '**Depth:** general' "**Size:** small · **Depth:** general" \
  '## Origin' $'## Origin\n'"$pad16"
if plant "$CLEAN" "$TMP/p16-standard.md" '**Depth:** general' '**Size:** standard · **Depth:** general' \
  '## Origin' $'## Origin\n'"$pad16" >/dev/null 2>&1; then
  expect p16-standard-over-bound-is-clean 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$TMP/p16-standard.md" --config "$CFG"
else
  record FAIL p16-standard-over-bound-is-clean "could not plant"
fi
if plant "$CLEAN" "$TMP/p16-small-ok.md" '**Depth:** general' '**Size:** small · **Depth:** general' >/dev/null 2>&1; then
  expect p16-small-within-bound-is-clean 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$TMP/p16-small-ok.md" --config "$CFG"
else
  record FAIL p16-small-within-bound-is-clean "could not plant"
fi

vcase p16-small-but-adversarial P16 only '^WARN P16 L[0-9]+: \*\*Size:\*\* small, but the depth is general\+adversarial' \
  '**Depth:** general' "**Size:** small · **Depth:** general+adversarial"
vcase p16-small-but-many-passes P16 only '^WARN P16 L[0-9]+: \*\*Size:\*\* small, but Gate \(review\) records 2 passes' \
  '**Depth:** general' "**Size:** small · **Depth:** general" \
  'Gate (review): 1 pass' 'Gate (review): 2 passes'
# P16 reads Size and Depth from the HEADER only: a body line quoting them (a log, a note) is not the plan's class.
if plant "$CLEAN" "$TMP/p16-quoted-in-body.md" '**Depth:** general' '**Size:** standard · **Depth:** general' \
  '## Origin' $'## Origin\nA note: `**Size:** small` plans with `**Depth:** general+adversarial` draw P16.\n'"$pad16" \
  >/dev/null 2>&1; then
  expect p16-quoted-in-body-is-clean 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$TMP/p16-quoted-in-body.md" --config "$CFG"
else
  record FAIL p16-quoted-in-body-is-clean "could not plant"
fi

# P4's config finding: a status_map without the phase the plan is in (a WARN, not a plan error)
if plant "$CFG" "$TMP/no-closed.config.md" '  closed: done' '' >/dev/null 2>&1; then
  expect p4-status-map-lacks-phase 1 P4 only "^WARN P4 L4: the config's status_map has no 'closed' key" \
    -- "$PY" "$PMC" "$CLEAN" --config "$TMP/no-closed.config.md"
else
  record FAIL p4-status-map-lacks-phase "could not plant the config"
fi

# SPIKE-FIRST is not pending for the implied phase: the phase is `value`, not `intake`. The config
# maps the two phases to different words, so reading SPIKE-FIRST as pending would fail both cases.
cat >"$TMP/spike.config.md" <<'EOF'
```yaml
status_map: {intake: new, value: researching, spec: designing, review: designing, planned: building, building: building, parked: on-hold, closed: done, abandoned: dropped}
```
EOF
spike_plan() {  # spike_plan STATUS > file
  printf '%s\n' '<!-- pm-template: v3 -->' '# SEED-30 — Rain barrel gauge' '' "**Status:** $1" '' \
    '## Decisions (owner)' '- D1 — Measure the barrel for a week before building.' '' \
    'Gate (intake): captured' 'Gate (value): SPIKE-FIRST — D1' 'Gate (spec): pending' 'Gate (review): pending' \
    'Gate (plan): pending go-ahead' 'Gate (build): pending' 'Gate (close): pending'
}
spike_plan researching >"$TMP/spike-ok.md"
spike_plan new >"$TMP/spike-bad.md"
expect spike-first-implies-value 0 - noerr '^INFO P0 L0' -- "$PY" "$PMC" "$TMP/spike-ok.md" --config "$TMP/spike.config.md"
expect spike-first-not-intake 1 P4 only "^ERROR P4 L4: .*imply phase value, which status_map maps to 'researching'" -- "$PY" "$PMC" "$TMP/spike-bad.md" --config "$TMP/spike.config.md"

# ── legacy plans (no v3 marker): rc 0, INFO only, each rule still named ──────────────────
LEG=( "$PY" "$PMC" "$FX/legacy.md" --config "$FX/config-legacy.md" )
expect legacy-is-info-only 0 - noerr '^INFO legacy L0: ' -- "${LEG[@]}"
expect legacy-not-started-parked 0 - noerr '^INFO P2 L[0-9]+: \[legacy; ERROR in a v3 plan\] Gate \(build\)' -- "${LEG[@]}"
expect legacy-dod-not-observed 0 - noerr '^INFO P10 L[0-9]+: \[legacy; ERROR in a v3 plan\]' -- "${LEG[@]}"
expect legacy-id-range 0 - noerr '^INFO P12 L[0-9]+: .*cites D-2031-03-01-05,' -- "${LEG[@]}"
if plant "$FX/legacy.md" "$TMP/legacy-marked.md" '# Compost log — plan' $'<!-- pm-template: v3 -->\n# Compost log — plan' >/dev/null 2>&1; then
  expect legacy-with-v3-marker-errors 1 - any '^ERROR P10 L[0-9]+: ' -- "$PY" "$PMC" "$TMP/legacy-marked.md" --config "$FX/config-legacy.md"
else
  record FAIL legacy-with-v3-marker-errors "could not plant the marker"
fi

# ── config: the subset parses; anything outside it is rc 2 naming the line ───────────────
expect config-unparseable-line 2 config only '^ERROR config L10: .*config-unparseable.md' -- "$PY" "$PMC" "$CLEAN" --config "$FX/config-unparseable.md"
ccase config-block-scalar 16 'max_parallel: 2' 'notes: |'
ccase config-two-levels 13 '  parked: on-hold' $'  parked:\n    on-hold'
ccase config-unterminated-quote 4 'owner: Gardener' 'owner: "Gardener'
ccase config-tab-indent 7 '  intake: idea' $'\tintake: idea'
ccase config-top-level-list 16 'max_parallel: 2' '- loose item'
ccase config-duplicate-key 16 'max_parallel: 2' 'owner: twice'
ccase config-bad-id-regex 16 'max_parallel: 2' "id_scheme: 'D(\\d+'"
ccase config-no-yaml-block 0 '```yaml' '```text'
expect config-file-missing 2 config only '^ERROR config L0: ' -- "$PY" "$PMC" "$CLEAN" --config "$TMP/no-such-config.md"

# ── broken input: rc 2 ───────────────────────────────────────────────────────────────────
printf 'Gate (intake): captured \xe9\xff\n' >"$TMP/latin1.md"
printf 'plan\0with a NUL\n' >"$TMP/nul.md"
expect input-missing 2 input only '^ERROR input L0: ' -- "$PY" "$PMC" "$TMP/no-such-plan.md" --config "$CFG"
expect input-not-utf8 2 input only '^ERROR input L0: .*not UTF-8' -- "$PY" "$PMC" "$TMP/latin1.md" --config "$CFG"
expect input-binary 2 input only '^ERROR input L0: .*NUL byte' -- "$PY" "$PMC" "$TMP/nul.md" --config "$CFG"
expect input-is-a-directory 2 input only '^ERROR input L0: ' -- "$PY" "$PMC" "$TMP" --config "$CFG"
expect input-bad-today 2 input only '^ERROR input L0: --today' -- "$PY" "$PMC" "$CLEAN" --config "$CFG" --today 2031-13-45
expect input-no-arguments 2 - any 'usage: pm-check' -- "$PY" "$PMC"

# ── the embedded control, sabotaged: rc 2 ────────────────────────────────────────────────
# sabotage SRC DEST REGEX REPLACEMENT: a copy of pm-check with exactly one control expectation edited
sabotage() {
  "$PY" - "$@" <<'PY'
import re, sys
src, dst, rx, rep = sys.argv[1:5]
t = open(src, encoding="utf-8").read()
new, n = re.subn(rx, rep, t)
if n != 1 or new == t:
    sys.exit("sabotage: %r matched %d times (need exactly 1)" % (rx, n))
open(dst, "w", encoding="utf-8").write(new)
PY
}
mkdir -p "$TMP/sab1" "$TMP/sab2"
if msg=$(sabotage "$PMC" "$TMP/sab1/pm-check" '\("ERROR", "P5", (\d+)\)' '("ERROR", "P5", 1\1)' 2>&1); then
  expect control-sabotaged 2 P0 only '^ERROR P0 L0: CONTROL FAILED' -- "$PY" "$TMP/sab1/pm-check" "$CLEAN" --config "$CFG"
else
  record FAIL control-sabotaged "$msg"
fi

# ── overlap: a throwaway git repo ────────────────────────────────────────────────────────
G=$TMP/repo
mkdir -p "$G" "$TMP/norepo"
gitq() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 git -C "$G" -c user.name=pm-check-test \
    -c user.email=pm-check-test@example.invalid -c commit.gpgsign=false -c init.defaultBranch=main "$@"
}
in_repo() { (cd "$G" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$@"); }
mkbranch() {  # mkbranch NAME FILE...: a branch off BASE that changes each FILE
  local b=$1 f
  shift
  gitq checkout -q -b "$b" "$BASE" || return 1
  for f in "$@"; do
    mkdir -p "$G/$(dirname "$f")" && printf '%s\n' "$b" >>"$G/$f" || return 1
  done
  gitq add -A && gitq commit -q -m "$b"
}
setup_ok=0
if gitq init -q &&
  mkdir -p "$G/app/timer" "$G/app/cards" "$G/docs" &&
  printf 'base\n' >"$G/app/timer/run.py" && printf 'base\n' >"$G/app/settings.py" &&
  printf 'base\n' >"$G/CHANGELOG.md" && printf 'base\n' >"$G/docs/help.md" &&
  gitq add -A && gitq commit -q -m base && BASE=$(gitq rev-parse HEAD) &&
  mkbranch water-timer app/timer/run.py tests/timer/test_run.py &&
  mkbranch water-card app/cards/next.py &&
  mkbranch water-docs docs/help.md CHANGELOG.md &&
  mkbranch water-stray app/rain/sensor.py app/timer/run.py &&
  mkbranch water-split app/split/a1.py &&
  mkbranch water-nowhere app/elsewhere.py; then
  setup_ok=1
fi
OVL=$FX/overlap-plan.md
if [ "$setup_ok" = 1 ]; then
  expect overlap-disjoint 0 - noerr '^INFO overlap L[0-9]+: water-timer: 2 file' -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-timer water-card --plan "$OVL"
  expect overlap-disjoint-no-plan 0 - noerr '^INFO overlap L0: water-card: 1 file' -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-timer water-card
  expect overlap-same-file 1 overlap one '^ERROR overlap L0: app/timer/run.py is changed by water-timer and water-stray' -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-timer water-stray
  expect overlap-out-of-glob 1 overlap one '^ERROR overlap L[0-9]+: water-stray changed app/timer/run.py, outside its owned globs' -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-stray --plan "$OVL"
  expect overlap-hotspot 1 overlap one '^ERROR overlap L[0-9]+: water-docs changed CHANGELOG.md, a hotspot' -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-docs --plan "$OVL"
  expect overlap-ambiguous-branch 2 overlap only "^ERROR overlap L[0-9]+: branch 'water-split' matches 2 Workstreams rows" -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-split --plan "$OVL"
  expect overlap-branch-in-no-row 2 overlap only "^ERROR overlap L0: branch 'water-nowhere' matches 0 Workstreams rows" -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-nowhere --plan "$OVL"
  expect overlap-plan-without-table 2 overlap only '^ERROR overlap L0: .*no table' -- in_repo "$PY" "$PMC" overlap --base "$BASE" water-timer --plan "$FX/v3-parked.md"
  expect overlap-bad-base 2 overlap only '^ERROR overlap L0: git rev-parse' -- in_repo "$PY" "$PMC" overlap --base 0123456789abcdef0123456789abcdef01234567 water-timer
  expect overlap-unknown-branch 2 overlap only '^ERROR overlap L0: git rev-parse' -- in_repo "$PY" "$PMC" overlap --base "$BASE" no-such-branch
  expect overlap-not-a-repo 2 overlap only '^ERROR overlap L0: ' -- env GIT_CEILING_DIRECTORIES="$TMP" sh -c 'cd "$1" && shift && exec "$@"' sh "$TMP/norepo" "$PY" "$PMC" overlap --base "$BASE" water-timer
  if msg=$(sabotage "$PMC" "$TMP/sab2/pm-check" '\(9, "hotspot", "shared/hot\.md"\)' '(9, "hotspot", "shared/cold.md")' 2>&1); then
    expect overlap-control-sabotaged 2 P0 only '^ERROR P0 L0: CONTROL FAILED' -- in_repo "$PY" "$TMP/sab2/pm-check" overlap --base "$BASE" water-timer water-card --plan "$OVL"
  else
    record FAIL overlap-control-sabotaged "$msg"
  fi
else
  record FAIL overlap-setup "could not build the throwaway git repo under $G"
fi

total=$((pass + fail))
if [ "$total" != "$EXPECTED_CASES" ]; then
  record FAIL case-count "ran $total cases, the suite defines $EXPECTED_CASES"
fi
echo "pm-check suite: $pass passed, $fail failed"
[ "$fail" = 0 ] && [ "$pass" -gt 0 ]
