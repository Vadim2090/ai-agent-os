#!/bin/bash
# CLAUDE.md lint: budget, chat-language leak outside quotes, dead relative links, stray placeholders.
set -u
cd "$(dirname "$0")/.."
FAIL=0
for f in template/CLAUDE.md template/START.md; do
  lines=$(wc -l < "$f" | tr -d ' ')
  if [ "$f" = "template/CLAUDE.md" ] && [ "$lines" -gt 200 ]; then echo "  $f: $lines lines (budget 200)"; FAIL=1; fi
  if ! python3 tests/cyrillic.py "$f" >/dev/null; then echo "  $f: Cyrillic present"; FAIL=1; fi
done
# relative markdown links inside template/ must resolve (skip placeholders, urls and anchors)
if ! python3 - <<'PYLINK'
import os, re, sys
bad = 0
for dirpath, _, files in os.walk("template"):
    for fn in files:
        if not fn.endswith(".md"): continue
        path = os.path.join(dirpath, fn)
        for n, line in enumerate(open(path, encoding="utf-8", errors="ignore"), 1):
            for target in re.findall(r"\]\(([^)]+)\)", line):
                if target.startswith(("http", "#")) or "{{" in target: continue
                if not os.path.exists(os.path.join(dirpath, target.split("#")[0])):
                    print(f"  {path}:{n} dead link {target}"); bad += 1
sys.exit(1 if bad else 0)
PYLINK
then FAIL=1; fi
# placeholders belong only under template/
STRAY=$(grep -rln '{{' --include='*.md' --include='*.sh' --include='*.json' . --exclude-dir=template --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=evals --exclude-dir=tests --exclude-dir=.tmp | grep -v -e '^./README.md' -e '^./ONBOARD.md' -e 'hooks/hooks.json')
if [ -n "$STRAY" ]; then echo "  {{placeholder}} outside template/:"; sed 's/^/    /' <<< "$STRAY"; FAIL=1; fi
exit $FAIL
