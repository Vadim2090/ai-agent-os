#!/bin/bash

# Finish Staleness Check — SessionStart hook
# Single-source-of-truth model: only sessions-history.md exists.
# Reports if the last session was >24h ago (genuinely missed /finish).
#
# Installation:
#   1. Copy to ~/.claude/hooks/
#   2. chmod +x ~/.claude/hooks/finish-staleness-check.sh
#   3. Wire in settings.json SessionStart hooks

# === CUSTOMIZE THIS PATH ===
HISTORY_FILE="${AI_OS_PATH:-$HOME/AI OS}/memory/sessions-history.md"
# === END CUSTOMIZATION ===

if [ ! -f "$HISTORY_FILE" ]; then
  echo ""
  echo "⚠️  No sessions-history.md found — first session, or memory not initialized."
  exit 0
fi

# Get file modification time (epoch seconds)
if [[ "$(uname)" == "Darwin" ]]; then
  HISTORY_MOD=$(stat -f %m "$HISTORY_FILE" 2>/dev/null)
else
  HISTORY_MOD=$(stat -c %Y "$HISTORY_FILE" 2>/dev/null)
fi

NOW=$(date +%s)
AGE_HOURS=$(( (NOW - HISTORY_MOD) / 3600 ))

# Genuinely stale — last /finish was a long time ago
if [ "$AGE_HOURS" -gt 24 ]; then
  echo ""
  echo "━━━ SESSION HYGIENE ━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  sessions-history.md last updated ${AGE_HOURS}h ago."
  echo "   Previous session may not have been closed with /finish."
  echo "   Top entry context may be stale — verify before relying on it."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0
