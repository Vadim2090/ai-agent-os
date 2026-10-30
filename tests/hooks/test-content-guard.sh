#!/bin/bash
# content-guard: a banned term in a written .md exits 2 with the term on stderr; a clean file exits 0;
# a non-text extension is skipped.
set -u
cd "$(dirname "$0")/../.." || exit 1
# Fixtures live in .scratch/, not tests/ or .tmp/: the gate skips those on purpose.
mkdir -p .scratch || exit 1; T="$(mktemp -d "$PWD/.scratch/case.XXXXXX")" || exit 1; trap 'rm -rf "$T"' EXIT
# Every fixture path below starts with $T; an empty or missing $T would write outside the temp dir.
[ -n "$T" ] && [ -d "$T" ] || { echo "  mktemp failed"; exit 1; }
printf 'This mentions forbidden-term in passing.\n' > "$T/bad.md"
printf 'Nothing to see.\n' > "$T/ok.md"
printf 'forbidden-term\n' > "$T/skip.png"
ERR=$(printf '{"tool_input":{"file_path":"%s/bad.md"}}' "$T" | CONTENT_GUARD_PATTERNS="forbidden-term|other-term" bash hooks/content-guard.sh 2>&1 >/dev/null); RC=$?
[ "$RC" -eq 2 ] || { echo "  expected exit 2 on banned term, got $RC"; exit 1; }
grep -q "forbidden-term" <<< "$ERR" || { echo "  stderr lacks the term"; exit 1; }
printf '{"tool_input":{"file_path":"%s/ok.md"}}' "$T" | CONTENT_GUARD_PATTERNS="forbidden-term" bash hooks/content-guard.sh >/dev/null 2>&1 || { echo "  clean file should exit 0"; exit 1; }
printf '{"tool_input":{"file_path":"%s/skip.png"}}' "$T" | CONTENT_GUARD_PATTERNS="forbidden-term" bash hooks/content-guard.sh >/dev/null 2>&1 || { echo "  non-text file should be skipped"; exit 1; }
exit 0
