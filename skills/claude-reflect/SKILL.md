---
name: claude-reflect
description: Self-learning system that captures corrections during sessions and reminds users to run /reflect to update CLAUDE.md. Use when discussing learnings, corrections, or when the user mentions remembering something for future sessions.
---

# Claude Reflect — Self-Learning System

A two-stage system that helps Claude Code learn from user corrections.

## How It Works

**Stage 1: Capture (Automatic)**
Hooks detect correction patterns ("no, use X", "actually...", "use X not Y") and queue them to `~/.claude/learnings-queue.json`.

**Stage 2: Process (Manual)**
User runs `/reflect` to review and apply queued learnings to CLAUDE.md files.

## Available Commands

| Command | Purpose |
|---------|---------|
| `/reflect` | Process queued learnings with human review |
| `/reflect --dry-run` | Preview changes without applying |
| `/skip-reflect` | Discard all queued learnings |
| `/view-queue` | View pending learnings without processing |

## When to Remind Users

Remind users about `/reflect` when:
- They complete a feature or meaningful work unit
- They make corrections you should remember for future sessions
- They explicitly say "remember this" or similar
- Context is about to compact and queue has items

## Correction Detection Patterns

High-confidence corrections:
- Tool rejections (user stops an action with guidance)
- "no, use X" / "don't use Y"
- "actually..." / "I meant..."
- "use X not Y" / "X instead of Y"
- "remember:" (explicit marker)

## Learning Destinations

- `~/.claude/CLAUDE.md` — Global learnings (model names, general patterns)
- `./CLAUDE.md` — Project-specific learnings (conventions, tools, structure)
- `./CLAUDE.local.md` — Personal learnings (machine-specific, gitignored)
- `./.claude/rules/*.md` — Modular rules with optional path-scoping

## /reflect Procedure

When user runs `/reflect`:

1. Read `~/.claude/learnings-queue.json`
2. For each learning:
   a. Display the correction and proposed change
   b. Suggest which file it belongs in (global vs project CLAUDE.md)
   c. Ask user to approve/reject/modify
3. Apply approved changes to the target file
4. Clear processed items from queue
5. Summarize what was applied

## Example Interaction

```
User: no, use gpt-5.1 not gpt-5 for reasoning tasks
Claude: Got it, I'll use gpt-5.1 for reasoning tasks.

[Hook captures this correction to queue]

User: /reflect
Claude: Found 1 learning queued. "Use gpt-5.1 for reasoning tasks"
        Scope: global
        Apply to ~/.claude/CLAUDE.md? [y/n]
```

## Capture Script

The capture hook (`scripts/capture_learning.py`) should:

1. Read the user's latest message from stdin
2. Pattern-match for correction indicators
3. If found, append to `~/.claude/learnings-queue.json`:
   ```json
   {
     "timestamp": "ISO-8601",
     "raw_message": "the user's correction",
     "confidence": "high|medium",
     "suggested_scope": "global|project"
   }
   ```
4. Exit silently (no output to user)
