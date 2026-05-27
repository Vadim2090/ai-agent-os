---
name: sprint-planning
description: |
  Build the next sprint's planning agenda. Reviews the last sprint's results,
  carries forward unfinished work, and pulls new candidates from focus.md,
  meetings.md, and your inbox.
  Use when: (1) user says /sprint-planning, "sprint planning", "plan next sprint",
  (2) at the start of a planning meeting (typically Monday morning),
  (3) you want a Notion-ready or Slack-ready agenda.
author: Claude Code
version: 1.0.0
---

# /sprint-planning — Sprint Agenda Builder

## Trigger
User says: `/sprint-planning`, "sprint planning", "plan the next sprint", "build sprint agenda"

## Procedure

### Step 1: Load the radar
Read in parallel:
- `memory/focus.md` — active strategic streams (the portfolio view)
- `memory/sessions-history.md` (top entry via awk slice from START.md) — last session's "Next steps emerging" + decisions
- `memory/meetings.md` — recent meeting commitments (last 2-3 entries)
- `memory/inbox.md` — captured ideas that need a decision

### Step 2: Find the last sprint's data
Search your task tracker (Notion / Linear / Jira / etc.) for the last sprint's page or backlog:
- What was committed?
- What got delivered?
- What's carrying over?

Ask the user to provide the link/ID if the page isn't easily findable.

### Step 3: Synthesize candidates for the next sprint
Build a candidate list from 4 sources:

1. **Carry-forward** — unfinished from last sprint
2. **New from streams** — items implied by active `focus.md` streams
3. **New from commitments** — action items from recent meetings (`meetings.md`)
4. **Inbox promotions** — captured ideas the user wants to elevate to a sprint task

For each candidate: title, source, why-now, success criteria, estimated effort.

### Step 4: Surface decisions
Flag candidates that need a yes/no call from the user before committing:
- Items with no clear owner
- Items competing for the same scarce resource
- Items dependent on someone else's deliverable
- Items where timing isn't obvious

### Step 5: Output

Produce a sprint agenda doc in this structure:

```
# Sprint N planning — [DATE]

## Carry-forward from Sprint N-1
- [Item] — status, why still relevant

## New: from active streams
- [Item] — stream, why now

## New: from meetings
- [Item] — meeting source, commitment quote

## Inbox promotions (need your call)
- [Item] — captured DATE, why elevating now

## Decisions needed before kickoff
- [Question] — who needs to weigh in
```

**Format-aware**: ask the user whether the agenda is for Notion (markdown with embeds OK), Slack (plain text), or live discussion (bullet list).

## Adapt to your stack
- "Task tracker" can be Notion / Linear / Jira / Asana / Monday — replace references accordingly
- If you don't use sprints (e.g., continuous flow), this skill still works as a weekly planning ritual — substitute "Sprint N" with "Week N"
- For solo work: skip Step 4 (no team to weigh in)

## Outputs
- A markdown agenda document
- Optional: pushed to your task tracker via the relevant MCP
- Do NOT auto-create or modify pages without explicit approval
