# AI Agent OS — Personal AI Operating System

A complete, opinionated system for running **Claude Code** as a **persistent operating system** — with session memory, self-learning, automated guardrails, and a three-tier agent architecture. Core context files are plain markdown, portable to any agent.

## Why This Exists

AI coding agents are stateless by default. Every session starts from zero. This system fixes that:

- **Session continuity** — `/start` loads previous context, `/finish` saves a handoff for next time
- **Persistent memory** — decisions, patterns, and project state survive across sessions
- **Self-learning** — corrections are captured and applied to instructions via `/reflect`
- **Skill extraction** — non-obvious discoveries become reusable skills via `/claudeception`
- **Automated guardrails** — hooks enforce rules mechanically, not just documentation
- **Credential registry** — agent knows what APIs/tools it can access without asking
- **Freshness enforcement** — drift detection on session start/end prevents stale context
- **Agent tiers** — graduate workflows from interactive to fully autonomous

## System Architecture

```
AI OS/                              ← Single source of truth
├── CLAUDE.md                       ← Agent instructions (identity, tools, rules, guardrails)
├── START.md                        ← Session kickstart procedure
├── IDEAS.md                        ← Idea backlog (not actionable yet)
├── data/                           ← Structured data (SQLite, exports)
├── knowledge-base/                 ← Reference material
│   └── ai-agent-principles.md     ← 5 principles + 3 pillars
├── memory/                         ← Session handoffs + meeting log
│   ├── handoff.md                 ← Last session summary + next steps
│   ├── handoff-history.md         ← Timeline of all sessions
│   └── meetings.md               ← Distilled meeting decisions/actions
└── projects/                       ← Your project folders (each with README.md)
    └── {project-name}/

~/.claude/                          ← Claude Code configuration
├── settings.json                   ← Permissions + hooks
├── hooks/                          ← Automated enforcement scripts
│   ├── learning-activator.sh      ← Triggers skill extraction evaluation
│   ├── content-guard.sh           ← Scans for banned words/phrases
│   └── session-guard.sh           ← Warns if previous session not closed
└── skills/                         ← Installed skills
    ├── start/                     ← Session kickstart
    ├── finish/                    ← Session wrap-up
    ├── checkpoint/                ← Save mid-session state
    ├── meetings/                  ← Meeting sync (Granola, Otter, etc.)
    ├── system-health/             ← Service health checker
    ├── claudeception/             ← Skill extraction from discoveries
    └── claude-reflect/            ← Self-learning from corrections
```

## Core Concepts

### 1. Session Lifecycle

Every work session follows a strict open/close protocol:

```
/start → loads context → work → /checkpoint (optional) → /finish → saves handoff
```

This ensures no context is lost between sessions, regardless of which tool you use. The `/checkpoint` command saves mid-session state for parallel sessions.

### 2. Memory Architecture

Two separate memory systems serve different purposes:

**System memory** (`.claude/projects/.../memory/`) — what the agent knows:

| Layer | Loaded | Purpose |
|-------|--------|---------|
| `MEMORY.md` (index) | Every turn | Pure pointers to topic files — no inline data |
| Topic files (`*.md`) | On demand | Detailed project state, API patterns, references |

**Session memory** (`AI OS/memory/`) — continuity between sessions:

| Layer | Loaded | Purpose |
|-------|--------|---------|
| `handoff.md` | On /start | Last session summary + next steps |
| `handoff-history.md` | Never auto | Append-only timeline of all sessions |
| `wip.md` | On /start | Mid-session state (created by /checkpoint) |
| `meetings.md` | On demand | Distilled meeting decisions/actions |

**Key design rule:** MEMORY.md index must be a pure pointer index — no inline data. Every line costs tokens on every turn. Data lives in topic files, loaded only when relevant.

### 3. Three-Tier Agent Architecture

Not everything needs a human in the loop. As workflows prove reliable, promote them to higher autonomy:

```
Tier 1: Interactive                    You + AI agent, real-time
  │     (Claude Code sessions)         Every action visible and approved
  │
  ▼  promote when validated
Tier 2: Supervised Autonomous          Agent runs alone, pauses at checkpoints
  │     (cron + Slack/Telegram gates)  Human approves at defined gates
  │
  ▼  promote when reliable
Tier 3: Fully Autonomous               Scheduled scripts, no human needed
        (cron jobs, webhooks)           Alert on failure only
```

**Design rules:**
- Start every workflow at Tier 1. Validate manually before promoting.
- Every Tier 3 job needs a watchdog — no silent crons.
- Skills are portable across tiers — same SKILL.md logic works interactively and autonomously.
- Any Tier 2/3 workflow can be demoted back if quality degrades.

**Example promotion path:**
```
Week 1: You manually run /system-health in Claude Code          → Tier 1
Week 2: Cron runs it daily, posts to Slack, you review          → Tier 2
Week 3: Cron runs silently, alerts only on failures             → Tier 3
```

### 4. Self-Learning Loop

```
User corrects Claude → hook captures correction → queued
User runs /reflect → Claude proposes CLAUDE.md update → user approves
```

The agent gets better over time without manual instruction editing.

### 5. Skill Extraction

```
Claude solves non-obvious problem → /claudeception evaluates
→ if reusable: creates new skill in ~/.claude/skills/
```

Skills are modular packages of knowledge that trigger automatically based on context. Build your own library of domain-specific skills over time.

### 6. Meeting Integration

```
Meeting tool (Granola, Otter, etc.) ← source of truth for raw data
    ↓ /meetings (on-demand sync)
memory/meetings.md ← distilled decisions, actions, commitments only
```

### 7. Automated Guardrails (Hooks)

Hooks run automatically on Claude Code events:

| Hook | Event | Purpose |
|------|-------|---------|
| `learning-activator.sh` | Every prompt | Reminds agent to evaluate for extractable knowledge |
| `content-guard.sh` | After Write/Edit | Scans output for banned words/phrases |
| `session-guard.sh` | Session start | Warns if handoff.md is stale (previous session not closed) |

### 8. The 5 Principles

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
git clone https://github.com/Vadim2090/ai-agent-os.git
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

1. **Edit `AI OS/CLAUDE.md`** — fill in your identity, tools, domain knowledge, operational rules
2. **Configure `content-guard.sh`** — add your domain-specific banned words (or remove if not needed)
3. **Start a session**: open Claude Code in `AI OS/` and say `/start`
4. **Build memory over time** — topic files accumulate naturally as you work on projects

## Design Philosophy

Three pillars:

1. **Context Engineering** — The repo is the single source of truth. If it's not in agent-visible files, it doesn't exist.
2. **Architectural Constraints** — Rules are enforced by hooks and scripts, not just documentation.
3. **Entropy Management** — Session protocol, memory hierarchy, and watchdog agents prevent drift over time.

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

Use the built-in skill creator, or manually create `~/.claude/skills/{name}/SKILL.md`:

```yaml
---
name: my-skill
description: What it does and when to trigger it.
---
# Instructions here
```

### Building Tier 2/3 Agents

To promote a skill to autonomous execution:

1. Extract the core logic into a standalone script (Python/Node)
2. Add checkpoint logic (Slack/Telegram notification + approval gate)
3. Deploy to your server with a cron schedule
4. Add a watchdog that alerts on failure
5. Monitor for quality — demote back to Tier 1 if needed

## File Reference

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main agent instructions — identity, workflow, domain, guardrails |
| `START.md` | Session kickstart procedure (read by /start skill) |
| `data/` | Structured data layer (SQLite, exports) |
| `IDEAS.md` | Idea backlog |
| `knowledge-base/ai-agent-principles.md` | The 5 principles + 3 pillars |
| `memory/handoff.md` | Last session summary and next steps |
| `memory/handoff-history.md` | Condensed timeline of all sessions |
| `memory/wip.md` | Work-in-progress state (created by /checkpoint) |
| `memory/meetings.md` | Meeting decisions/actions log (synced via /meetings) |
| `settings.json.template` | Claude Code settings with hooks pre-wired |

## Skills Included

| Skill | Purpose |
|-------|---------|
| `/start` | Load context, show pending items, begin session |
| `/finish` | Save handoff, update history, close session |
| `/checkpoint` | Save mid-session state for parallel contexts |
| `/meetings` | Sync meeting notes from recording tools |
| `/system-health` | Check all configured services in one shot |
| `/reflect` | Review corrections, propose CLAUDE.md updates |
| `/claudeception` | Extract reusable skills from session discoveries |

## Contributing

PRs welcome. The goal is to keep this minimal and opinionated — complexity should be opt-in via skills, not baked into the core.

## License

MIT
