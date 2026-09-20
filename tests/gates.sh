#!/bin/bash
# Publish gates for the public repo: secret patterns, employer identifiers, chat-language leaks.
set -u
cd "$(dirname "$0")/.."
FAIL=0
SCOPE=(template README.md ONBOARD.md hooks skills settings.json.template setup.sh tests evals .claude-plugin)
if grep -rnE '(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----)' "${SCOPE[@]}" --exclude-dir=results --exclude-dir=fixtures 2>/dev/null | grep -v 'tests/gates.sh' | grep -v 'hooks/done-gate.sh' | grep -v 'test-done-gate.sh'; then echo "  secret pattern above"; FAIL=1; fi
if grep -rniE '\b(kevin|dreem|immcore|omw)\b' "${SCOPE[@]}" --exclude-dir=results 2>/dev/null | grep -v 'tests/gates.sh'; then echo "  employer identifier above"; FAIL=1; fi
FILES=$(find "${SCOPE[@]}" -type f \( -name '*.md' -o -name '*.sh' -o -name '*.json' -o -name '*.py' -o -name '*.yaml' \) -not -path '*/results/*' -not -path '*/fixtures/*' -not -path '*/.tmp/*' -not -path '*/.scratch/*' 2>/dev/null)
if ! python3 tests/cyrillic.py $FILES >/dev/null; then python3 tests/cyrillic.py $FILES; echo "  Cyrillic above"; FAIL=1; fi
exit $FAIL
