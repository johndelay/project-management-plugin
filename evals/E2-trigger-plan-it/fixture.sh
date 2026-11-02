#!/usr/bin/env bash
# A tiny garden-watering tracker with a feature request waiting in REQUEST.md.
set -euo pipefail
mkdir -p tracker
cat > README.md <<'MD'
# garden-log
Records when each bed was watered. `python -m tracker water <bed>`, `python -m tracker status`.
MD
cat > REQUEST.md <<'MD'
# Request: reminders
Gardeners forget beds in hot weeks. Send a reminder when a bed has not been watered for 3 days.
Some volunteers only read email; others want a phone notification.
MD
cat > tracker/__init__.py <<'PY'
PY
cat > tracker/__main__.py <<'PY'
import json, sys, time, pathlib
LOG = pathlib.Path("water.json")
def main(argv):
    log = json.loads(LOG.read_text()) if LOG.exists() else {}
    if argv[:1] == ["water"] and len(argv) == 2:
        log[argv[1]] = time.time(); LOG.write_text(json.dumps(log))
    elif argv[:1] == ["status"]:
        for bed, t in sorted(log.items()):
            print(bed, f"{(time.time() - t) / 86400:.1f} days ago")
    else:
        sys.exit("usage: water <bed> | status")
main(sys.argv[1:])
PY
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "garden log"
