#!/bin/bash
# finish-staleness-check: warns when sessions-history.md is older than 24 h, silent when fresh, silent when absent.
set -u
cd "$(dirname "$0")/../.."
# Fixtures live in .scratch/, not tests/ or .tmp/: the gate skips those on purpose.
mkdir -p .scratch; T="$(mktemp -d "$PWD/.scratch/case.XXXXXX")"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/memory"
printf '# history\n' > "$T/memory/sessions-history.md"
if [[ "$(uname)" == "Darwin" ]]; then touch -t "$(date -v-30H +%Y%m%d%H%M)" "$T/memory/sessions-history.md"; else touch -d '30 hours ago' "$T/memory/sessions-history.md"; fi
OUT=$(AI_OS_PATH="$T" bash hooks/finish-staleness-check.sh 2>&1)
grep -q "30h ago" <<< "$OUT" || { echo "  expected a 30h warning, got: $OUT"; exit 1; }
touch "$T/memory/sessions-history.md"
OUT=$(AI_OS_PATH="$T" bash hooks/finish-staleness-check.sh 2>&1)
grep -q "ago" <<< "$OUT" && { echo "  fresh file should be silent: $OUT"; exit 1; }
rm "$T/memory/sessions-history.md"
AI_OS_PATH="$T" bash hooks/finish-staleness-check.sh >/dev/null 2>&1 || { echo "  missing file should exit 0"; exit 1; }
exit 0
