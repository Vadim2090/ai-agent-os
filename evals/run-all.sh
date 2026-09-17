#!/bin/bash
# Everything the weekly routine runs: Tier 0 (static), Tier 1 (headless golden prompts), Tier 2 (skill evals
# with a no-plugin baseline). Writes evals/LAST_RUN.md and commits it. Push only with EVAL_PUSH=1.
set -u
cd "$(dirname "$0")/.."
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"
mkdir -p evals/results
STAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ); VERSION=$(claude --version 2>/dev/null | head -1)
T0=$(bash tests/run.sh 2>&1); T0_RC=$?
T1=$(python3 evals/headless/run.py 2>&1); T1_RC=$?
T2_JSON="evals/results/skills-$(date -u +%Y%m%dT%H%M%SZ).json"
T2=$(claude plugin eval . --json "$T2_JSON" --runs "${EVAL_RUNS:-3}" --threshold 0.8 --trust-plugin --scaffold --allow-tools Bash,Write,Edit --model "${EVAL_MODEL:-claude-sonnet-5}" --max-cost-usd 10 2>&1); T2_RC=$?
T2_SUMMARY=$(python3 - "$T2_JSON" <<'PY' 2>/dev/null
import json, sys
try:
    d = json.load(open(sys.argv[1])); a = d.get("aggregates", {})
    md = a.get("meanDelta"); md = f"{md:+.2f}" if isinstance(md, (int, float)) else "n/a"
    print(f"{a.get('casesPassed','?')}/{a.get('casesTotal','?')} cases at threshold, mean delta vs no plugin {md}, ${d.get('costUsd',0):.2f}" + (" (partial)" if d.get("partial") else ""))
except Exception as e:
    print(f"no result document ({e})")
PY
)
status() { [ "$1" -eq 0 ] && echo "pass" || echo "FAIL (exit $1)"; }
{
  echo "# Last eval run"
  echo
  echo "| | Result |"
  echo "|---|---|"
  echo "| Run | $STAMP |"
  echo "| Claude Code | $VERSION |"
  echo "| Tier 0 static + hook tests | $(status $T0_RC) |"
  echo "| Tier 1 headless golden prompts | $(status $T1_RC): $(grep -E '^[0-9]+/[0-9]+ passed' <<< "$T1" | head -1) |"
  echo "| Tier 2 skill evals | $(status $T2_RC): $T2_SUMMARY |"
  echo
  echo "<details><summary>Tier 0 output</summary>"; echo; echo '```'; echo "$T0"; echo '```'; echo "</details>"
  echo "<details><summary>Tier 1 output</summary>"; echo; echo '```'; echo "$T1" | tail -n 20; echo '```'; echo "</details>"
  echo "<details><summary>Tier 2 output</summary>"; echo; echo '```'; echo "$T2" | tail -n 30; echo '```'; echo "</details>"
} > evals/LAST_RUN.md
git add evals/LAST_RUN.md >/dev/null 2>&1
if ! git diff --cached --quiet; then
  git commit -q -m "evals: run $STAMP" -m "Tier 0 $(status $T0_RC), Tier 1 $(status $T1_RC), Tier 2 $(status $T2_RC). Claude Code $VERSION." && echo "committed evals/LAST_RUN.md"
  [ "${EVAL_PUSH:-0}" = "1" ] && git push -q origin main && echo "pushed"
fi
cat evals/LAST_RUN.md | head -12
if [ $T0_RC -ne 0 ] || [ $T1_RC -ne 0 ] || [ $T2_RC -ne 0 ]; then
  # Alert on failure only: a Tier 3 job that is quiet when green.
  command -v osascript >/dev/null && osascript -e "display notification \"Tier 0 $(status $T0_RC), Tier 1 $(status $T1_RC), Tier 2 $(status $T2_RC)\" with title \"AI Agent OS evals failed\"" >/dev/null 2>&1
  exit 1
fi
exit 0
