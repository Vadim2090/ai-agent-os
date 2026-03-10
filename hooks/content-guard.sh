#!/bin/bash

# Content Guard Hook — PostToolUse (Write, Edit)
# Scans files written/edited by Claude for banned words or phrases.
# Customize BANNED_PATTERNS for your domain.
#
# Installation:
#   1. Copy to ~/.claude/hooks/
#   2. chmod +x ~/.claude/hooks/content-guard.sh
#   3. Wire in settings.json for Write and Edit matchers
#
# Example use cases:
#   - Legal compliance (banned legal terms)
#   - Brand guidelines (off-brand language)
#   - Security (sensitive data patterns)
#   - Style guide enforcement

# === CUSTOMIZE THESE ===
# Add your domain-specific banned words/phrases (case-insensitive match)
BANNED_PATTERNS=(
  # "banned-word-1"
  # "banned-phrase-2"
  # "another-term"
)
# === END CUSTOMIZATION ===

# Exit early if no patterns configured
if [ ${#BANNED_PATTERNS[@]} -eq 0 ]; then
  exit 0
fi

# Read the tool result from stdin (contains file path info)
INPUT=$(cat)

# Extract file path from the tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    fp = data.get('tool_input', {}).get('file_path', '')
    print(fp)
except:
    print('')
" 2>/dev/null)

# Skip if no file path or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only scan relevant file types
case "$FILE_PATH" in
  *.md|*.txt|*.js|*.py|*.html|*.json|*.ts|*.jsx|*.tsx) ;;
  *) exit 0 ;;
esac

VIOLATIONS=""
for pattern in "${BANNED_PATTERNS[@]}"; do
  MATCHES=$(grep -in "$pattern" "$FILE_PATH" 2>/dev/null | grep -v "^#" | grep -v "BANNED" | head -3)
  if [ -n "$MATCHES" ]; then
    VIOLATIONS="${VIOLATIONS}\n  ⚠  \"${pattern}\" found:\n${MATCHES}\n"
  fi
done

if [ -n "$VIOLATIONS" ]; then
  echo ""
  echo "━━━ CONTENT GUARD ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Banned words detected in: $(basename "$FILE_PATH")"
  echo -e "$VIOLATIONS"
  echo "Replace with safe alternatives (see MEMORY.md)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0
