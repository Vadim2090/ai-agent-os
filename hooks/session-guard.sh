#!/bin/bash

# Session Guard Hook — SessionStart
# Warns if handoff.md hasn't been updated in >24 hours,
# suggesting the previous session wasn't properly closed with /finish.
#
# Installation:
#   1. Copy to ~/.claude/hooks/
#   2. chmod +x ~/.claude/hooks/session-guard.sh
#   3. Wire in settings.json SessionStart hooks

# === CUSTOMIZE THIS PATH ===
HANDOFF_FILE="${AI_OS_PATH:-$HOME/AI OS}/memory/handoff.md"
# === END CUSTOMIZATION ===

if [ ! -f "$HANDOFF_FILE" ]; then
  echo ""
  echo "⚠  No handoff.md found — run /finish at end of each session."
  exit 0
fi

# Get file modification time vs now (in seconds)
if [[ "$(uname)" == "Darwin" ]]; then
  FILE_MOD=$(stat -f %m "$HANDOFF_FILE" 2>/dev/null)
else
  FILE_MOD=$(stat -c %Y "$HANDOFF_FILE" 2>/dev/null)
fi

NOW=$(date +%s)
AGE_HOURS=$(( (NOW - FILE_MOD) / 3600 ))

if [ "$AGE_HOURS" -gt 24 ]; then
  echo ""
  echo "━━━ SESSION HYGIENE ━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠  handoff.md is ${AGE_HOURS}h old."
  echo "   Previous session may not have been closed with /finish."
  echo "   Context may be stale — verify before relying on it."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0
