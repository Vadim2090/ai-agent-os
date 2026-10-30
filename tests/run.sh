#!/bin/bash
# Tier 0: static checks and hook unit tests. Seconds, no model calls. Exit 1 on any failure.
set -u
cd "$(dirname "$0")/.." || exit 1
FAIL=0
run() { local name="$1"; shift; if "$@"; then echo "PASS  $name"; else echo "FAIL  $name"; FAIL=1; fi; }
# `claude plugin validate` needs the claude CLI. CI has none and sets TIER0_SKIP_CLAUDE=1; everything else
# here runs offline with bash, git and python3 only.
validate() { if [ "${TIER0_SKIP_CLAUDE:-}" = 1 ]; then echo "SKIP  $1 (TIER0_SKIP_CLAUDE=1, no claude CLI)"; else run "$@"; fi; }
validate "plugin manifest, skills, hooks validate (--strict)" bash -c 'claude plugin validate . --strict >/dev/null 2>&1'
validate "template agents validate (--strict)"                 bash -c 'claude plugin validate template/.claude/agents --strict >/dev/null 2>&1'
run "settings.json.template structure"               python3 tests/settings-check.py settings.json.template
run "hooks/hooks.json is valid JSON"                  python3 -c 'import json,sys; json.load(open("hooks/hooks.json"))'
run "CLAUDE.md lint (budget, language, links, placeholders)" bash tests/lint-claude-md.sh
run "publish gates (secrets, identifiers, language)"  bash tests/gates.sh
run "secretscan: shapes caught, prose not"            python3 tests/test-secretscan.py
run "hook: done-gate"                                 bash tests/hooks/test-done-gate.sh
run "hook: publish-guard"                             bash tests/hooks/test-publish-guard.sh
run "hook: content-guard"                             bash tests/hooks/test-content-guard.sh
run "hook: finish-staleness-check"                    bash tests/hooks/test-staleness.sh
run "tests: fixtures never write to the real repo"    bash tests/hooks/test-fixture-isolation.sh
exit $FAIL
