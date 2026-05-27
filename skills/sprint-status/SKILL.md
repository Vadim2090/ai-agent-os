---
name: sprint-status
description: |
  Generate a mid-sprint status update — what shipped, what's in flight, what's
  blocked, what's unplanned. Pulls planned items from the current sprint and
  cross-checks against actual progress.
  Use when: (1) user says /sprint-status, "sprint status", "where are we on the sprint",
  (2) preparing for a mid-sprint sync,
  (3) you want a Slack-ready or Notion-ready status update.
author: Claude Code
version: 1.0.0
---

# /sprint-status — Mid-Sprint Status Update

## Trigger
User says: `/sprint-status`, "sprint status", "where are we on the sprint", "mid-sprint check"

## Procedure

### Step 1: Pull the current sprint's planned items
Find the current sprint's page in your task tracker (Notion / Linear / Jira / etc.). Extract the committed item list.

If multiple sprints are open, ask the user which one (or default to the most recent by start date).

### Step 2: Cross-check actual progress
For each planned item, determine its current status. Signals to use:
- Task-tracker status (done / in-progress / blocked / not-started)
- Recent git activity on related branches
- Recent `meetings.md` entries mentioning the item
- `focus.md` mentions of the parent stream

Classify each into:
- **Shipped** — done and delivered
- **In-flight** — actively being worked
- **Blocked** — waiting on something (note what)
- **Not-started** — committed but no progress
- **Dropped** — explicitly killed (note why)

### Step 3: Identify unplanned work
What did the user do this sprint that wasn't in the original plan? Check:
- Recent `sessions-history.md` entries
- `focus.md` changes since sprint start

Categorize: **emergency** / **opportunity** / **scope-creep**.

### Step 4: Surface blockers
Items stuck waiting on:
- A specific person (name them)
- An external dependency (name it)
- The user's own decision-making (flag it)

### Step 5: Output

Slack-ready format (10-15 lines):

```
## Sprint N status — [DATE]

✅ Shipped:
- [Item] — [outcome]

🚧 In-flight:
- [Item] — [next step]

🟡 Blocked:
- [Item] — waiting on [person/thing]

🆕 Unplanned:
- [Item] — [why it came up]

🔴 Bottlenecks for second half:
- [Item] — [what we need]
```

**Format-aware**: ask whether the output is for Slack (plain text), Notion (tables), or live sync (bullet list).

## Adapt to your stack
- Replace "task tracker" with your tool (Notion / Linear / Jira / etc.)
- For continuous flow (no sprints), use this skill as a weekly status ritual

## Notes
- Focus on the user's own work — don't claim teammates' progress unless they're direct reports
- Honest blockers > optimistic spin
- A bottleneck named is half-resolved; an unnamed one stays
