# /checkpoint — Save Work-In-Progress State

## Trigger
User says: /checkpoint, "save state", "I'm switching contexts"

## What This Does
Saves current session state to `memory/wip.md` so parallel sessions (or the same user in a different tool) can see what's in flight. Does NOT end the session.

## Instructions

### Step 1: Summarize Current State
Write to `memory/wip.md`:

```markdown
# Work In Progress

## Session: [auto-generated session name]
## Started: [timestamp]
## Last checkpoint: [timestamp]

## What's in flight
- [What you're currently working on]
- [What's partially done]
- [What's blocked and why]

## Key decisions made (this session)
- [Decision 1]
- [Decision 2]

## Files modified
- [file1.md] — [what changed]
- [file2.py] — [what changed]
```

### Step 2: Confirm
Tell the user: "State saved to wip.md. You can switch contexts safely — any new session will see what's in flight."

### Notes
- `wip.md` is read by `/start` (if it exists) to show parallel session context
- `/finish` deletes `wip.md` when the session ends
- This is for mid-session saves, not session endings
