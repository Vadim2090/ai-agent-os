#!/bin/bash
# Context footprint of what a session loads before the first prompt, estimated at 4 bytes per token.
# Path-scoped rules and skill bodies load on demand, so only their descriptions count here.
set -u
cd "$(dirname "$0")/.."
est() { local b; b=$(cat "$@" 2>/dev/null | wc -c | tr -d ' '); printf "%5.1fK" "$(python3 -c "print($b/4/1000)")"; }
printf "%-52s %s\n" "Always loaded" "tokens (est.)"
printf "%-52s %s\n" "template/CLAUDE.md (= AGENTS.md)" "$(est template/AGENTS.md)"
printf "%-52s %s\n" "template/MEMORY.md (auto-memory index, as shipped)" "$(est template/MEMORY.md)"
printf "%-52s %s\n" "skill descriptions ($(ls skills | wc -l | tr -d ' ') skills)" "$(grep -h '^description:' skills/*/SKILL.md | est /dev/stdin)"
printf "%-52s %s\n" "agent descriptions (2 agents)" "$(grep -h '^description:' template/.claude/agents/*.md | est /dev/stdin)"
printf "%-52s %s\n" "On demand" ""
printf "%-52s %s\n" "template/START.md (only when /start runs)" "$(est template/START.md)"
printf "%-52s %s\n" "rules/repos.md (inside repo-* folders)" "$(est template/.claude/rules/repos.md)"
printf "%-52s %s\n" "rules/research.md (inside research/ folders)" "$(est template/.claude/rules/research.md)"
