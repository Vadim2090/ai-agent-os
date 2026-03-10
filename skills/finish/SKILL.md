---
name: finish
description: Session wrap-up. Create a handoff summary, update memory if needed, and close out the current working session.
---

# /finish — Session Wrap-Up

## Trigger
User says: /finish, /end, "wrap up", "done for now"

## Procedure

### Phase 1: Generate Session Name
Create a short, descriptive session name based on what was accomplished.
- Format: `[YYYY-MM-DD HH:MM] {project-or-area} — {what was done}`
- Example: `[2026-02-21 14:30] AI OS — Setup & Config`
- Use current date and time (24h format, user's timezone)
- Keep the descriptive part under 50 characters
- Use the primary project/area worked on + the main action

### Phase 2: Summary
Create/update `memory/handoff.md` with:
- Session name (from Phase 1)
- Session date
- What was accomplished (bullet points)
- Decisions made
- Next steps (numbered, prioritized)
- Carried-over items (flag if item appeared in previous handoff too)

Then **append** a condensed entry to `memory/handoff-history.md` (prepend after the `---` header line, so newest is first). Format:

```
## [session name]

**Accomplished:**
- [bullet points]

**Decisions:**
- [bullet points, or "None" if no decisions]

**Next steps at end of session:**
1. [numbered list]
```

Keep history entries concise — no carried-over items, no full detail. The goal is a scannable timeline.

### Phase 3: Memory & Structure Check
Review if anything from this session should update MEMORY.md:
- New project started? → add to Active Projects
- Key decision made? → add to Key Decisions
- Pattern discovered? → add to Patterns & Conventions

**Folder tree drift check:** If any project folders were created, renamed, or removed during this session, update the folder tree in CLAUDE.md to match the actual filesystem.

Only update if genuinely needed. Most sessions won't change MEMORY.md or the folder tree.

### Phase 4: Docs (conditional)
Only if significant work was done on a specific project:
- Update project-specific docs if they exist
- Create a dated session log in memory/ if the session was substantive

### Display format:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION [session name] WRAPPED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Accomplished: [count] items
Decisions: [count]
Next steps: [count] (see handoff.md)
Memory updated: [yes/no]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
