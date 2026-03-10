#!/bin/bash
set -e

# AI OS — Setup Script
# Installs the AI OS template into your home directory and wires up Claude Code hooks/skills.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_AI_OS_PATH="$HOME/AI OS"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  AI OS — Personal AI Operating System"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Choose install path
read -p "Install AI OS to [$DEFAULT_AI_OS_PATH]: " AI_OS_PATH
AI_OS_PATH="${AI_OS_PATH:-$DEFAULT_AI_OS_PATH}"

echo ""
echo "Installing to: $AI_OS_PATH"
echo ""

# Step 2: Create folder structure from template
echo "[1/5] Creating folder structure..."
if [ -d "$AI_OS_PATH" ]; then
  echo "  ⚠  $AI_OS_PATH already exists. Skipping template copy to avoid overwriting."
  echo "     (If this is a fresh install, remove the folder first.)"
else
  cp -r "$SCRIPT_DIR/template" "$AI_OS_PATH"
  mkdir -p "$AI_OS_PATH/projects"
  echo "  ✓ Created $AI_OS_PATH"
fi

# Step 3: Install hooks
echo "[2/5] Installing hooks..."
HOOKS_DIR="$HOME/.claude/hooks"
mkdir -p "$HOOKS_DIR"

for hook in "$SCRIPT_DIR/hooks/"*.sh; do
  HOOK_NAME=$(basename "$hook")
  if [ -f "$HOOKS_DIR/$HOOK_NAME" ]; then
    echo "  ⚠  $HOOK_NAME already exists — skipping (won't overwrite)"
  else
    cp "$hook" "$HOOKS_DIR/$HOOK_NAME"
    chmod +x "$HOOKS_DIR/$HOOK_NAME"
    echo "  ✓ Installed $HOOK_NAME"
  fi
done

# Step 4: Install skills
echo "[3/5] Installing skills..."
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

for skill_dir in "$SCRIPT_DIR/skills/"*/; do
  SKILL_NAME=$(basename "$skill_dir")
  TARGET="$SKILLS_DIR/$SKILL_NAME"
  if [ -d "$TARGET" ]; then
    echo "  ⚠  $SKILL_NAME already exists — skipping"
  else
    cp -r "$skill_dir" "$TARGET"
    echo "  ✓ Installed skill: $SKILL_NAME"
  fi
done

# Step 5: Settings
echo "[4/5] Configuring settings..."
SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
  echo "  ⚠  ~/.claude/settings.json already exists."
  echo "     Template saved to: ~/.claude/settings.json.ai-os-template"
  echo "     Merge hooks manually from the template."
  cp "$SCRIPT_DIR/settings.json.template" "$HOME/.claude/settings.json.ai-os-template"
else
  cp "$SCRIPT_DIR/settings.json.template" "$SETTINGS_FILE"
  echo "  ✓ Created settings.json with hooks"
fi

# Step 6: Update session-guard path
echo "[5/5] Configuring paths..."
GUARD_FILE="$HOOKS_DIR/session-guard.sh"
if [ -f "$GUARD_FILE" ]; then
  # Replace the default path with actual install path
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s|\${AI_OS_PATH:-\$HOME/AI OS}|$AI_OS_PATH|g" "$GUARD_FILE"
  else
    sed -i "s|\${AI_OS_PATH:-\$HOME/AI OS}|$AI_OS_PATH|g" "$GUARD_FILE"
  fi
  echo "  ✓ Configured session-guard path"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Edit $AI_OS_PATH/CLAUDE.md — fill in your identity and domain"
echo "  2. Edit $AI_OS_PATH/MEMORY.md — add your active projects"
echo "  3. (Optional) Edit ~/.claude/hooks/content-guard.sh — add banned words"
echo "  4. Open Claude Code in $AI_OS_PATH and say /start"
echo ""
echo "Docs: See README.md for full system documentation."
