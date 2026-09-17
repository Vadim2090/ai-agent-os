#!/bin/bash
# Installs the weekly eval routine as a launchd agent (macOS): Mondays 09:00 local, runs evals/run-all.sh.
# Uninstall: launchctl bootout gui/$(id -u)/com.ai-agent-os.evals && rm ~/Library/LaunchAgents/com.ai-agent-os.evals.plist
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
PLIST="$HOME/Library/LaunchAgents/com.ai-agent-os.evals.plist"
mkdir -p "$HOME/Library/LaunchAgents" "$REPO/evals/results"
sed "s|__REPO__|$REPO|g" "$REPO/evals/routine/com.ai-agent-os.evals.plist" > "$PLIST"
launchctl bootout "gui/$(id -u)/com.ai-agent-os.evals" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "installed: $PLIST"; launchctl print "gui/$(id -u)/com.ai-agent-os.evals" | grep -E 'state|program|last exit' || true
echo "run now:   launchctl kickstart -k gui/$(id -u)/com.ai-agent-os.evals"
