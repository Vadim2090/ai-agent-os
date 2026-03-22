# /start — Universal Session Kickstart

**For AI agents:** Follow these instructions when the user says
"/start", "new session", "let's begin", or "kick off".

---

## Session Start Procedure

### Step 1: Load Context

Read these files:

| File | What to extract |
|------|-----------------|
| `memory/handoff.md` | Last session summary, next steps, carried-over items |
| `memory/wip.md` (if exists) | What's currently in flight in a parallel session |

**Already loaded automatically:** CLAUDE.md, MEMORY.md (via auto-memory system — do not re-read).
**Do NOT read:** IDEAS.md (not actionable), any project-specific files (not yet scoped).

### Display format:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION CONTEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Last session: [name from handoff.md]

In flight (if wip.md exists):
- [session name from wip.md] — [what's in progress]

Pending:
- [Next Steps from handoff.md]

Carried over (if any):
- [items flagged as repeatedly carried over]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Step 2: Ask About Goals

Ask ONE open question:

> **What do you want to accomplish this session?**

Wait for the user's response before proceeding.

### Step 3: Scope the Session

After the user states their goal:

1. Identify which project this maps to
2. If a project folder exists with `context/` or `docs/`, load relevant files
3. If it's a new idea not tied to a project, suggest capturing in IDEAS.md
4. If ambiguous, ask ONE clarifying question
