# AI Agent Instructions

## WHO I AM

### Identity
- Name: {{YOUR_NAME}}
- Role: {{YOUR_ROLE}} at {{YOUR_COMPANY}}
- Default timezone: {{YOUR_TIMEZONE}}
- Default language: English

### Company context
- Company: {{YOUR_COMPANY}}
- Domain: {{YOUR_DOMAIN_DESCRIPTION}}
- Operating model: {{HOW_YOUR_COMPANY_WORKS}}

### What I'm driving
<!-- List 2-5 parallel workstreams you're actively managing -->
- Stream 1: {{DESCRIPTION}}
- Stream 2: {{DESCRIPTION}}
- Stream 3: {{DESCRIPTION}}

### How I work (operating style)
<!-- Keep the ones that apply, remove or replace the rest -->
- Automation-first. I optimize for scalable workflows, minimal manual ops, and strong API capability.
- High-signal execution. I prefer:
  - crisp definitions (stages, tags, KPIs)
  - structured outputs (tables, schemas, checklists)
  - iterative delivery (v0 → v1 → v2), with obvious deltas
- Practical simplicity beats elegance.

### People & collaboration context
<!-- List key collaborators and their roles -->
- {{NAME}} — {{ROLE}}, {{WHAT_THEY_DO}}
- {{NAME}} — {{ROLE}}, {{WHAT_THEY_DO}}

## HOW TO COMMUNICATE
- Be direct — skip pleasantries, get to the point
- Prioritize accuracy over comfort
- Executive summary first — for long responses, lead with key points
- Structured outputs by default: tables, schemas, checklists
- If I can forward it to a teammate as-is, that's a good output

## FOLDER STRUCTURE
This folder (`AI OS/`) is my single source of truth.

```
AI OS/
├── CLAUDE.md              # This file (agent instructions)
├── START.md               # Session kickstart procedure
├── MEMORY.md              # Active projects, key decisions
├── IDEAS.md               # Ideas not yet promoted to projects
├── knowledge-base/        # Reference material
│   └── ai-agent-principles.md
├── memory/                # Session logs and handoffs
│   ├── handoff.md
│   └── handoff-history.md
└── projects/              # All project folders
    └── {{project-name}}/
```

### Naming convention
- Format: `org-shortname` in kebab-case (e.g., `acme-crm`, `acme-marketing`)
- Each project gets its own folder inside `projects/`

### Keeping this in sync
- When creating or renaming a project folder → update this tree AND `MEMORY.md`
- When removing a project → remove from both
- The `/finish` skill checks for drift automatically

## TOOL-AGNOSTIC WORKFLOW
Work must continue seamlessly across tools (Claude Code, Cursor, Claude.ai, etc.).

**Principles:**
1. No tool lock-in — this folder works with any AI agent
2. Single source of truth — all context lives here, not in tool-specific locations
3. Graceful handoffs — any AI picks up where another left off
4. One project per session — don't mix contexts

## CURRENT TOOLS & INTEGRATIONS

<!-- Fill in the tools you actually use -->
| Tool | Purpose | Integration |
|------|---------|-------------|
| {{TOOL}} | {{PURPOSE}} | {{HOW_IT_CONNECTS}} |

> **API keys & secrets** are stored in environment files — never in .md files.

## DOMAIN KNOWLEDGE

<!-- Add domain-specific knowledge the agent needs -->
### Key concepts
- {{CONCEPT}}: {{DEFINITION}}

### Agent guardrails
<!-- Domain-specific rules the agent must follow -->
- {{GUARDRAIL_1}}
- {{GUARDRAIL_2}}

## FOR AI AGENTS
Read this if you're an AI starting a session.

### What to read on session start
See START.md for the full procedure.

### Session discipline
- Every session starts with /start
- Every session ends with /finish
- Never mix multiple projects in one session
- If switching projects, end current session first
