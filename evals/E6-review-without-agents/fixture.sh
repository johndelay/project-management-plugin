#!/usr/bin/env bash
# Same repo and plan as E5 (spec drafted, review pending); E6 runs it with no sub-agent tools.
set -euo pipefail
bash "$(dirname "$0")/../E5-resume-at-gate/fixture.sh"
