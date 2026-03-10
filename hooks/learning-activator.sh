#!/bin/bash

# Learning Activator Hook — UserPromptSubmit
# Reminds Claude to evaluate every completed task for extractable knowledge.
# This drives the self-learning loop: work → evaluate → extract skill.
#
# Installation:
#   1. Copy to ~/.claude/hooks/
#   2. chmod +x ~/.claude/hooks/learning-activator.sh
#   3. Wire in settings.json (see settings.json.template)

cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SKILL EVALUATION REMINDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

After completing this request, evaluate whether it produced
extractable knowledge using the claudeception skill.

Ask yourself:
- Did this require non-obvious investigation or debugging?
- Would the solution help in future similar situations?
- Did I discover something not obvious from documentation?

If YES → use /claudeception to extract the knowledge.
If NO  → skip, no extraction needed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
