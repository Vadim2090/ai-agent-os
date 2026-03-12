# AI OS — Personal AI Operating System for Claude Code

A complete, opinionated system for running Claude Code as a persistent AI agent with session memory, self-learning, automated guardrails, and structured workflows.

## What This Is

AI OS turns Claude Code from a stateless assistant into a **persistent operating system** with:

- **Session continuity** — `/start` loads previous context, `/finish` saves a handoff for next time
- **Persistent memory** — decisions, patterns, and project state survive across sessions
- **Self-learning** — corrections are captured automatically and applied to instructions via `/reflect`
- **Skill extraction** — non-obvious discoveries become reusable skills via `/claudeception`
- **Automated guardrails** — hooks enforce rules mechanically (banned words, session hygiene, etc.)
- **Multi-tool portability** — works across Claude Code, Cursor, and any CLAUDE.md-compatible agent

## System Architecture

```
AI OS/                              ← Your single source of truth
├── CLAUDE.md                       ← Agent instructions (identity, tools, domain, workflow)
├── START.md                        ← Session kickstart procedure
├── MEMORY.md                       ← Active projects, key decisions, patterns
├── IDEAS.md                        ← Idea backlog (not actionable yet)
├── knowledge-base/                 ← Reference material
│   └── ai-agent-principles.md     ← 5 principles + 3 pillars
├── memory/                         ← Session handoffs + meeting log
│   ├── handoff.md                 ← Last session summary + next steps
│   ├── handoff-history.md         ← Timeline of all sessions
│   └── meetings.md               ← Distilled meeting decisions/actions
└── projects/                       ← Your project folders
    └── {project-name}/
        ├── .claude/settings.local.json  ← Per-project permissions
        └── CLAUDE.md                    ← Project-specific instructions

~/.claude/                          ← Claude Code configuration
├── settings.json                   ← Permissions + hooks
├── hooks/                          ← Automated enforcement scripts
│   ├── learning-activator.sh      ← Triggers skill extraction evaluation
│   ├── content-guard.sh           ← Scans for banned words/phrases
│   └── session-guard.sh           ← Warns if previous session not closed
└── skills/                         ← Installed skills
    ├── start/                     ← Session kickstart
    ├── finish/                    ← Session wrap-up
    ├── meetings/                  ← Meeting sync (Granola, Otter, etc.)
    ├── claudeception/             ← Skill extraction from discoveries
    ├── claude-reflect/            ← Self-learning from corrections
    └── skill-creator/             ← Guide for creating new skills
```

## Core Concepts

### 1. Session Lifecycle

Every work session follows a strict open/close protocol:

```
/start → loads context → work → /finish → saves handoff
```

This ensures no context is lost between sessions, regardless of which tool you use.

### 2. Memory Hierarchy

| Layer | File | Purpose | Update frequency |
|-------|------|---------|-----------------|
| Instructions | `CLAUDE.md` | Who you are, how to work, domain rules | Rarely (via /reflect) |
| Active state | `MEMORY.md` | Current projects, decisions, metrics | When state changes |
| Session bridge | `memory/handoff.md` | Last session → next session | Every /finish |
| History | `memory/handoff-history.md` | Scannable timeline | Every /finish |
| Meetings | `memory/meetings.md` | Distilled meeting decisions/actions | On-demand via /meetings |
| Ideas | `IDEAS.md` | Unscoped ideas | Ad hoc |

### 3. Self-Learning Loop

```
User corrects Claude → hook captures correction → queued
User runs /reflect → Claude proposes CLAUDE.md update → user approves
```

This creates a feedback loop where the agent gets better over time without manual instruction editing.

### 4. Skill Extraction

```
Claude solves non-obvious problem → /claudeception evaluates
→ if reusable: creates new skill in ~/.claude/skills/
```

Skills are modular packages of knowledge that trigger automatically based on context.

### 5. Meeting Integration

```
Meeting tool (Granola, Otter, etc.) ← source of truth for raw data
    ↓ /meetings (on-demand sync)
memory/meetings.md ← distilled decisions, actions, commitments only
```

Meetings are **not** auto-synced into session lifecycle. Run `/meetings` when you want to pull in recent meeting context. This keeps `/start` and `/finish` fast while ensuring meeting decisions are always accessible.

### 6. Automated Guardrails (Hooks)

Hooks run automatically on Claude Code events:

| Hook | Event | Purpose |
|------|-------|---------|
| `learning-activator.sh` | Every prompt | Reminds Claude to evaluate for extractable knowledge |
| `content-guard.sh` | After Write/Edit | Scans output for banned words/phrases |
| `session-guard.sh` | Session start | Warns if handoff.md is stale (previous session not closed) |

### 7. The 5 Principles

1. **Make everything visible to the agent** — all context in files, not in your head
2. **Diagnose the environment, not the model** — fix tooling/docs, not the AI
3. **Mechanically enforce structure** — hooks > written rules
4. **Give the agent sensory access** — let it see results of its work
5. **Provide a map, not a manual** — brief architecture > exhaustive docs

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- macOS or Linux (Windows WSL should work)

### Installation

```bash
# Clone the repo
git clone https://github.com/Vadim2090/ai-agent-os.git

# Run the setup script
cd ai-agent-os
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Create the `AI OS/` folder structure in your home directory (or a path you choose)
2. Install hooks to `~/.claude/hooks/`
3. Install core skills to `~/.claude/skills/`
4. Create a template `~/.claude/settings.json` (or merge with existing)
5. Generate a starter `CLAUDE.md` with placeholder sections

### Post-Setup

1. **Edit `AI OS/CLAUDE.md`** — fill in your identity, tools, domain knowledge
2. **Edit `AI OS/MEMORY.md`** — add your active projects
3. **Configure `content-guard.sh`** — add your domain-specific banned words (or remove if not needed)
4. **Start a session**: open Claude Code in `AI OS/` and say `/start`

## Customization

### Adding Domain-Specific Guardrails

Edit `~/.claude/hooks/content-guard.sh` to add your own banned words:

```bash
BANNED_PATTERNS=(
  "your-banned-word"
  "another-phrase"
)
```

### Adding Project-Specific Permissions

Create `.claude/settings.local.json` in any project folder:

```json
{
  "permissions": {
    "allow": [
      "WebFetch(domain:your-api.example.com)"
    ]
  }
}
```

### Creating New Skills

Use the built-in skill creator:
```
/skill-creator
```

Or manually create `~/.claude/skills/{name}/SKILL.md` with:
```yaml
---
name: my-skill
description: What it does and when to trigger it.
---
# Instructions here
```

## Design Philosophy

This system is built on three pillars:

1. **Context Engineering** — The repo is the single source of truth. If it's not in agent-visible files, it doesn't exist.
2. **Architectural Constraints** — Rules are enforced by hooks and scripts, not just documentation.
3. **Entropy Management** — Session protocol and memory hierarchy prevent context drift over time.

## File Reference

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main agent instructions — identity, workflow, domain, guardrails |
| `START.md` | Session kickstart procedure (read by /start skill) |
| `MEMORY.md` | Active project state, decisions, metrics |
| `IDEAS.md` | Idea backlog |
| `knowledge-base/ai-agent-principles.md` | The 5 principles + 3 pillars |
| `memory/handoff.md` | Last session summary and next steps |
| `memory/handoff-history.md` | Condensed timeline of all sessions |
| `memory/meetings.md` | Meeting decisions/actions log (synced via /meetings) |
| `settings.json.template` | Claude Code settings with hooks pre-wired |

## Contributing

PRs welcome. The goal is to keep this minimal and opinionated — complexity should be opt-in via skills, not baked into the core.

## License

MIT
