# AI Agent OS — Personal AI Operating System

A second-brain operating system for **Claude Code**. Persistent memory across sessions, a library of skills, MCP integrations to your real tools, automated guardrails, and a three-tier execution architecture. Core context files are plain markdown — portable to any agent.

## Why This Exists

AI coding agents are stateless by default. Every session starts from zero. This system fixes that:

- **Session continuity** — `/start` loads previous context, `/finish` appends to a single audit trail
- **Strategic memory** — one `focus-<track>.md` per track holds active streams (the portfolio view), not a duplicate of your task tracker
- **Tracks by launch folder** — the folder you open Claude Code in decides which context loads; work and personal never mix
- **Self-learning** — corrections are captured and applied to instructions via `/reflect`
- **Skill extraction** — non-obvious discoveries become reusable skills via `/claudeception`
- **Automated guardrails** — hooks enforce rules mechanically, not just documentation
- **Credential registry** — agent knows what APIs/tools it can access without asking
- **Freshness enforcement** — drift detection on session start/end prevents stale context
- **Hybrid markdown + SQLite** — narrative in markdown, operational data (campaigns, funnels, metrics) in SQL the agent can query
- **Agent tiers** — graduate workflows from interactive to fully autonomous

## System Architecture

```
AI OS/                              ← Single source of truth
├── AGENTS.md                       ← Agent instructions, canonical (open-standard name)
├── CLAUDE.md → AGENTS.md           ← symlink, so Claude Code reads the same file
├── START.md                        ← Session kickstart procedure
├── IDEAS.md                        ← Idea backlog (not actionable yet)
├── profile.md                      ← Who I am, professionally; read on demand, never every session
├── data/                           ← SQLite: schema.sql, sync_csv.py, README (section 3)
├── knowledge-base/                 ← Reference material
│   └── ai-agent-principles.md     ← 3 principles + 3 pillars
├── memory/                         ← session state, one focus file per track
│   ├── focus-<track-a>.md         ← Active strategic streams, track A (loaded at /start when launched there)
│   ├── focus-<track-b>.md         ← Active strategic streams, track B
│   ├── sessions-history.md        ← Append-only timeline; top entry = "last session", stamped with its track
│   ├── meetings.md                ← Distilled meeting decisions/actions
│   └── archive/                   ← Superseded files, never loaded
├── <track-a>/                      ← e.g. your employer's work: own CLAUDE.md, own task tracker
└── <track-b>/                      ← e.g. personal projects: own CLAUDE.md, own task tracker

~/.claude/                          ← Claude Code configuration
├── settings.json                   ← Least-privilege permissions, sandbox, hooks
├── hooks/                          ← Automated enforcement scripts
│   ├── learning-activator.sh      ← Triggers skill extraction evaluation
│   ├── content-guard.sh           ← Scans for banned words/phrases; a hit exits 2
│   ├── finish-staleness-check.sh  ← Warns if last session was >24h ago
│   └── done-gate.sh               ← Stop gate: language leak + secret patterns on files touched this session
├── rules/                          ← Path-scoped rules: repos.md (repo-*), research.md (research/)
├── agents/                         ← Subagents: researcher (cold web research), fact-checker (numbers vs sources)
└── skills/                         ← Installed skills
    ├── start/                     ← Session kickstart
    ├── finish/                    ← Session wrap-up (single-file shell-prepend)
    ├── meetings/                  ← Meeting sync (Granola, Otter, etc.)
    ├── meeting-debrief/           ← Single-meeting analysis → next steps
    ├── system-health/             ← Service health checker
    ├── claudeception/             ← Skill extraction from discoveries (adapted, MIT)
    ├── claude-reflect/            ← Self-learning from corrections (adapted, MIT)
    ├── sprint-planning/           ← Build next sprint's agenda
    ├── sprint-status/             ← Mid-sprint status update
    └── remote-mcp-oauth-install/  ← OAuth MCP install troubleshooting

ai-agent-os/ (this repo)            ← also loads as a plugin: claude --plugin-dir .
├── .claude-plugin/plugin.json      ← manifest; hooks/hooks.json wires the hooks
├── template/ · hooks/ · skills/    ← what setup.sh installs
├── tests/                          ← Tier 0: static checks + hook unit tests (make test)
├── evals/                          ← Tier 1 headless cases, Tier 2 skill evals, weekly routine, LAST_RUN.md
└── Makefile                        ← test · eval · eval-skills · eval-all
```

## Core Concepts

### 1. Session Lifecycle

Every work session follows a strict open/close protocol:

```
/start → loads the track's context → work → /finish → prepends the session entry to history
```

This ensures no context is lost between sessions, regardless of which tool you use. Hand-off between sessions runs through `/finish` and the top entry of `sessions-history.md` — there is no second "latest" file.

### 2. The Memory Model

The system separates **streams** (what you're operating on, per track) from **history** (what happened). Each file has one purpose. No duplication. Tasks live in your task tracker; stable IDs live in the agent's auto-memory.

**Session memory** (`AI OS/memory/`):

| File | Loaded at /start | Purpose |
|------|------------------|---------|
| `focus-<track>.md` | yes — the launch track's file only | Active strategic streams for that track. The portfolio view. May open with a dated table ("the clock") that /start renders first. |
| `sessions-history.md` | yes (top entry only via shell slice) | Append-only timeline. The most recent entry serves "last session" context; each entry is stamped with its track, so a foreign entry is never presented as continuity. |
| `meetings.md` | no | Distilled meeting decisions/actions. On-demand. |
| `archive/` | never | Superseded files, kept for recovery. |

**Tasks do not live in memory.** They live in your real task tracker (Notion, Linear, Asana, etc.). Memory holds the strategic portfolio — what streams you're operating on this sprint. Tasks ≠ focus. Different cadence, different consumer, different tool.

**Agent's auto-memory** (`.claude/projects/.../memory/`):

| Layer | Loaded | Purpose |
|-------|--------|---------|
| `MEMORY.md` (index) | Every turn | Pure pointers to topic files — no inline data |
| Topic files (`*.md`) | On demand | Detailed project state, API patterns, references |

**Key design rule:** MEMORY.md must be a pure pointer index — no inline data. Every line costs tokens on every turn. Data lives in topic files, loaded only when relevant.

### 3. Hybrid Markdown + SQLite

Markdown is great for narrative. SQL is great for structured data. The system uses both:

- **Markdown** — principles, lessons, session log, meeting notes, focus streams
- **SQLite** — campaigns, funnel metrics, lead journeys, experiments, anything you'd put in a spreadsheet

The agent reads markdown for context and queries SQLite for facts. Operational data is synced via cron jobs from your real systems (CRM, analytics, ad platforms) into a local DB the agent can query.

> If you'd put it in a spreadsheet, it belongs in the DB.
> If you'd write it as a paragraph, it stays in markdown.

Shipped in `template/data/`: `schema.sql` (campaigns, daily funnel counts, experiments, and a monthly view with cost per
qualified lead), `sync_csv.py` (a CSV export upserted into a table, safe to re-run, standard library only) and a README
with the cron line. The database file is data; the schema is code.

### 4. Three-Tier Agent Architecture

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

Shipped instance of Tier 3: `evals/run-all.sh` under launchd (`evals/routine/`), weekly, no person involved, a
macOS notification only when a tier fails, results committed to `evals/LAST_RUN.md`.

### 5. Self-Learning Loop

```
User corrects Claude → hook captures correction → queued
User runs /reflect → Claude proposes CLAUDE.md update → user approves
```

The agent gets better over time without manual instruction editing.

### 6. Skill Extraction

```
Claude solves non-obvious problem → /claudeception evaluates
→ if reusable: creates new skill in ~/.claude/skills/
```

Skills are modular packages of knowledge that trigger automatically based on context. Build your own library of domain-specific skills over time.

### 7. Meeting Integration

```
Meeting tool (Granola, Otter, etc.) ← source of truth for raw data
    ↓ /meetings (on-demand sync)
memory/meetings.md ← distilled decisions, actions, commitments only
```

### 8. Guardrails: hooks, permissions, sandbox

Three layers, because a rule written in `CLAUDE.md` is a request, not a guarantee.

**Hooks** run automatically on Claude Code events:

| Hook | Event | Purpose |
|------|-------|---------|
| `learning-activator.sh` | Every prompt | Reminds agent to evaluate for extractable knowledge |
| `content-guard.sh` | After Write/Edit | Scans the written file for banned terms; a hit exits 2 so the report reaches the agent |
| `finish-staleness-check.sh` | Session start | Warns if last session was >24h ago |
| `done-gate.sh` | Stop | Language leak outside quotes and secret patterns on everything the session touched; blocks once, lets a stated exception through |
| `done-gate.sh` | Stop | Re-runs the file checks (language leak outside quotes, secret patterns) on everything the session touched; blocks once, then lets a stated exception through |

**Permissions** (`settings.json.template`) follow least privilege. There is no bare `Bash` allow: read-only
commands run without prompting on their own, everything else runs inside the sandbox or asks. Secret files
are denied to the agent's file tools, so a `.env`, a key or `~/.claude.json` never lands in the context
window, and pushing, recursive deletes and `sudo` always prompt:

```json
"ask":  ["Bash(git push *)", "Bash(rm -rf *)", "Bash(rm -r *)", "Bash(sudo *)"],
"deny": ["Read(//**/.env)", "Read(//**/.env.*)", "Read(//**/*.pem)", "Read(~/.ssh/**)",
         "Read(~/.aws/**)", "Read(~/.config/gh/**)", "Read(~/.claude.json)"]
```

**Sandbox** is the layer that holds when a prompt injection gets past the model: OS-level filesystem and
network isolation for every Bash command and its children (macOS Seatbelt, Linux bubblewrap). Writes are
limited to the working directory, the session temp directory and `~/AI OS`; no network host is allowed
until you approve it once; `~/.ssh` and `~/.aws/credentials` are unreadable inside it. `osascript` and
`open` are excluded because the macOS sandbox blocks Apple Events, and lifting that restriction globally
would remove code-execution isolation. Bash deny rules alone are not a security boundary; the sandbox is.

### 9. The 3 Principles

> *An AI agent without context and feedback loops is like a pilot flying blind. You can still move fast, but you can't trust the direction.*

1. **Make the work visible to the agent** — the same context you would give a human teammate: decisions, plans, metrics, outputs. Structured sessions plus MCP integrations, so it decides on real data and verifies its own results.
2. **Fix the system, not the AI** — when the agent fails, check tooling, documentation and context quality before rewriting prompts or switching models.
3. **Enforce structure mechanically** — critical rules are checks and constraints that prevent violations by default. Written rules get forgotten; automated checks don't.

Full framework, with the three pillars underneath: `knowledge-base/ai-agent-principles.md`.

### 10. Evals: instructions tested like code

A `CLAUDE.md`, a hook or a skill is a rule for a system that keeps changing: you edit the file, Claude Code
ships a release (this repo saw 2.1.270 → 2.1.274 in one afternoon), the model changes. Without tests the
first sign of a broken rule is a broken session days later. So the rules are tested the way code is: fixed
prompts, a fresh agent, assertions on what it produced.

| Tier | What | Cost | When |
|---|---|---|---|
| 0 | `make test`: plugin and skill validation, settings structure, CLAUDE.md lint (200-line budget, language, dead links), a unit test for every hook on planted fixtures | free, seconds | every commit |
| 1 | `make eval`: five golden prompts through `claude -p` against a throwaway AI OS built from `template/` (track scope, file language, secret deny, Stop gate, answer first); assertions on produced files, permission denials and the child transcript, never on prose | ~$0.50 | on change, weekly |
| 2 | `make eval-skills`: `claude plugin eval` for `start` and `finish` against a no-plugin baseline, regex and tool-use graders, scaffolded fixtures | ~$0.20 per case-run | weekly |

`make eval-all` runs everything and writes [`evals/LAST_RUN.md`](evals/LAST_RUN.md) with the Claude Code
version and the scores; `evals/routine/install.sh` schedules it weekly as a launchd agent, so the evidence
stays current without a person at the keyboard or an API key. `make footprint` estimates what a session loads
before the first prompt: CLAUDE.md ~2.6K tokens, the memory index plus every skill and agent description ~0.6K
together; START.md (~1.4K) and the two rules load on demand. Fixtures are built outside the repo on
purpose: Claude Code loads `CLAUDE.md` from every ancestor of the working directory, so a fixture inside
the real tree inherits the real rules and tests nothing.

### 11. Rules and subagents

Two path-scoped rules and two subagents ship with the template and install into `~/.claude/`:

| File | Loads when | Does |
|---|---|---|
| `rules/repos.md` | a file inside any `repo-*` folder is read | git etiquette: verify the checkout, no secrets staged, tests before "done", diff both ways before deploying |
| `rules/research.md` | a file inside any `research/` folder is read | every claim sourced and dated, UNVERIFIED marked, denominators kept |
| `agents/researcher.md` | called by name or delegated | cold, read-only web research; a sourced conclusion under 400 words |
| `agents/fact-checker.md` | called by name or delegated | every number in a draft against its source; a verdict per claim |

Why user scope: Claude Code loads `.claude/rules/` and `.claude/agents/` from the working directory and from
`~/.claude/`, not from a parent folder, and a path-scoped rule fires only for files under the working
directory. Copies at the AI OS root never load in a track session (verified with a probe rule, 17 Sep 2026),
and a rule for the sibling `memory/` folder cannot fire from a track at all; that procedure lives in the
`/start` and `/finish` skills instead.

### 12. Provenance: WHY.md

Every hook, rule and structural decision traces to the incident that created it, with the date and what prevents
it now: [`WHY.md`](WHY.md). A rule without a row there is a rule without a reason.

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

Or load it as a plugin for one session, nothing installed: `claude --plugin-dir .` from the clone.

The setup script will:
1. Create the `AI OS/` folder structure in your home directory (or a path you choose)
2. Install hooks to `~/.claude/hooks/`
3. Install core skills to `~/.claude/skills/`
4. Create a template `~/.claude/settings.json` (or merge with existing)
5. Generate a starter `CLAUDE.md` with placeholder sections

### Guided setup (recommended)

Don't want to configure by hand? After cloning, **paste `ONBOARD.md` into a fresh Claude Code chat.** Claude will walk you through the whole setup interactively — filling in your `CLAUDE.md`, connecting your first MCP, installing skills, and running one real task end-to-end — one step at a time, verifying as it goes.

### Post-Setup

1. **Edit `AI OS/CLAUDE.md`** — fill in your identity, tools, domain knowledge, operational rules
2. **Configure `content-guard.sh`** — add your domain-specific banned words (or remove if not needed)
3. **Curate `focus-<track>.md`** — list 3-7 active strategic streams you're operating on this sprint, one file per track
4. **Connect a task tracker** — Notion, Linear, etc. Tasks live there, not in memory
5. **Start a session**: open Claude Code in `AI OS/` and say `/start`
6. **Build memory over time** — topic files accumulate naturally as you work on projects

## Design Philosophy

Three pillars:

1. **Context Engineering** — The repo is the single source of truth. If it's not in agent-visible files, it doesn't exist.
2. **Architectural Constraints** — Rules are enforced by hooks and scripts, not just documentation.
3. **Entropy Management** — Session protocol, memory hierarchy, and watchdog agents prevent drift over time.

Plus one operational rule earned from three months of iteration:

4. **One source of truth per concept.** If two files claim to be "the latest", one is wrong. If tasks live in your task tracker AND in memory, you're paying for both and reconciling neither.

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

Create `.claude/settings.local.json` in any project folder. Deny always wins over allow, so widening
is additive and never re-opens a denied secret. To let a tool write somewhere else, add the path to
`sandbox.filesystem.allowWrite`; to pre-approve a host, add it to `sandbox.network.allowedDomains`:

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
| `knowledge-base/ai-agent-principles.md` | The 3 principles + 3 pillars |
| `memory/focus-<track>.md` | Active strategic streams, one file per track (the portfolio view) |
| `memory/sessions-history.md` | Append-only timeline; top entry = last session, stamped with its track |
| `memory/meetings.md` | Meeting decisions/actions log (synced via /meetings) |
| `memory/archive/` | Superseded files, never loaded |
| `settings.json.template` | Claude Code settings: least-privilege permissions, sandbox, hooks pre-wired |
| `.claude-plugin/plugin.json` · `hooks/hooks.json` | Plugin manifest and hook wiring for `--plugin-dir` and `claude plugin eval` |
| `tests/` · `Makefile` | Tier 0: static checks and hook unit tests (`make test`) |
| `template/profile.md` | Career, positioning, track record; opened only when the task is about the operator |
| `template/AGENTS.md` → `template/CLAUDE.md` | The instruction file, canonical under the open-standard name; CLAUDE.md is a symlink to it |
| `WHY.md` | Every mechanism traced to the incident that created it |
| `template/data/` | SQLite schema, CSV upsert script and the sync README |
| `tests/footprint.sh` | Estimated tokens a session loads before the first prompt (`make footprint`) |
| `template/.claude/rules/` · `template/.claude/agents/` | Path-scoped rules and subagents; `setup.sh` installs them into `~/.claude/` |
| `evals/` | Tier 1 headless cases (`headless/run.py`), Tier 2 skill evals (`start/`, `finish/`), `run-all.sh`, the launchd routine, `LAST_RUN.md` |

## Skills Included

| Skill | Purpose |
|-------|---------|
| `/start` | Detect the track from the launch folder, load its focus file + the top entry of sessions-history.md, run health checks |
| `/finish` | Prepend the session entry to sessions-history.md (shell-prepend, single file), stamped with the track |
| `/meetings` | Sync meeting notes from recording tools |
| `/system-health` | Check all configured services in one shot |
| `/reflect` | Review corrections, propose CLAUDE.md updates |
| `/claudeception` | Extract reusable skills from session discoveries |
| `/sprint-planning` | Build the next sprint's agenda from focus + meetings + tasks |
| `/sprint-status` | Mid-sprint status update (shipped / in-flight / blocked / unplanned) |
| `/meeting-debrief` | Analyze one meeting → filtered next steps + task proposal |
| `/remote-mcp-oauth-install` | Fix OAuth-gated remote MCP installs ("where are my tools?" gotcha) |

## Lessons From a Year In

This system went through several rewrites. The biggest changes:

- **Evals caught the harness before they caught a rule (Sep 2026).** First run: a fixture built under the real AI OS inherited the real `CLAUDE.md` through parent-directory loading, and a hook path with a space in it failed silently. Neither is visible without a fresh agent running fixed prompts. 5/5 and 2/2 after the fixes, $0.79 for the whole run.
- **Dropped the bare `Bash` allow (Sep 2026).** The first template approved every shell command and denied nothing. Now secrets are denied to the file tools, destructive commands ask, and the sandbox contains everything else. Prompts went down, not up: read-only commands never asked, and sandboxed commands are auto-approved.
- **Split into tracks by launch folder (Sep 2026).** One `CLAUDE.md` had grown past 200 lines serving two jobs, and every session paid for both. Now the root file holds only what is true everywhere; each track folder carries its own `CLAUDE.md`, focus file and task tracker, and Claude Code's parent-directory loading does the routing. Confidential material from one track cannot leak into the other because it is never loaded there.
- **Retired `inbox.md` and `/checkpoint`.** The inbox was a counter nobody acted on for three months — capture now goes straight to the relevant TODO. `wip.md` was a second "latest" file; hand-off runs through `/finish` and `sessions-history.md` alone.
- **`/start` became optional.** It costs ~5K tokens and is worth it only when the session needs state; the mechanical checks (track, staleness, cross-track continuity, freshness) moved into a SessionStart hook that runs for free every time.

- **Killed `handoff.md`.** It duplicated the top entry of `sessions-history.md`. Two files claiming to be "the latest" = torn-write race conditions when sessions ran in parallel.
- **Moved tasks out of memory.** Tasks accumulated in handoff.md with carry counters going up to "carried x21". Items at x14+ aren't tasks — they're a museum of work never killed. The real task tracker (Notion) was always the answer.
- **Switched to streams as the /start anchor.** At session start, you don't need a to-do list. You need to know what initiatives you're operating on this week. Tasks ≠ focus.
- **Moved operational data to SQLite.** Markdown can't answer "show me leads who replied but never booked." SQL can. Memory is for narrative; structured data lives in a DB the agent queries.
- **Refactored /finish to shell-prepend.** When the model is rewriting a 200 KB file every wrap, /finish takes 5+ minutes. When the model writes only the new entry and a shell op prepends, /finish takes ~1.5 min.

## Contributing

PRs welcome. The goal is to keep this minimal and opinionated — complexity should be opt-in via skills, not baked into the core.

## Credits

Two shipped skills are **adaptations of existing open-source projects**, not original work:

| Skill | Upstream | Author |
|---|---|---|
| `skills/claudeception/` | [blader/Claudeception](https://github.com/blader/Claudeception) | blader |
| `skills/claude-reflect/` | [BayramAnnakov/claude-reflect](https://github.com/BayramAnnakov/claude-reflect) | Bayram Annakov |

Both are MIT-licensed and both upstreams do more than the condensed copies here — install them
from source if you want the full versions. Copyright notices: [CREDITS.md](CREDITS.md).

Everything else — the memory model, session lifecycle, hooks, remaining skills and template —
is original.

## License

MIT — see [LICENSE](LICENSE).
