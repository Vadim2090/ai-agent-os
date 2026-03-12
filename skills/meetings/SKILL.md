---
name: meetings
description: |
  Sync meeting notes from a meeting tool (e.g., Granola, Otter, Fireflies) into
  the AI OS meeting log. Use when: (1) user says /meetings, "sync meetings",
  "what meetings did I have", (2) user wants to review recent meeting decisions
  or action items, (3) user needs meeting context for a current task.
  Extracts decisions/actions, appends to memory/meetings.md.
  Never duplicates meetings already in the log.
---

# /meetings — Meeting Sync & Query

## Trigger
User says: /meetings, "sync meetings", "sync my meetings", "what meetings happened"

## Overview

This skill bridges your meeting tool (source of truth for raw meeting data) and
AI OS (source of truth for distilled decisions/actions). It queries the meeting
tool, extracts only decision-grade information, and appends to `memory/meetings.md`.

**Raw transcripts and full notes stay in the meeting tool. Only decisions, actions,
and commitments are extracted.**

## Configuration

This skill requires an MCP integration with your meeting tool. Supported:
- **Granola** — `mcp__claude_ai_Granola__*` tools
- **Other tools** — adapt the query/fetch steps below to your MCP integration

## Procedure

### Step 1: Determine Sync Window

Read `memory/meetings.md` to find the `Last synced:` date.
- If found: query meetings from that date to today
- If not found or file missing: query last 30 days

### Step 2: Fetch Meeting List

Query your meeting tool for meetings in the sync window.

If no new meetings since last sync → report "No new meetings" and stop.

### Step 3: Get Details for Each New Meeting

For each meeting NOT already in meetings.md (match by date + title):

1. Get the meeting summary, attendees, and notes
2. If the summary lacks enough detail, fetch the transcript as fallback

### Step 4: Extract Decision-Grade Information

For each meeting, extract ONLY:

- **Decisions** — anything agreed upon, approved, or changed
- **Action items** — tasks assigned to specific people with owner names
- **Commitments** — promises made (pricing, timelines, deliverables)
- **Key context** — one-line summary of what the meeting was about

**Do NOT extract:**
- General discussion or opinions
- Background context already in MEMORY.md
- Small talk or scheduling logistics

### Step 5: Append to meetings.md

Prepend new entries after the `---` separator (newest first). Format per meeting:

```markdown
## [YYYY-MM-DD] Meeting Title
**Attendees:** Name1, Name2
**Summary:** One-line context of what this meeting covered.
**Decisions:**
- Decision description
**Actions:**
- [ ] @Owner: task description
**Source:** [Meeting Tool](link-to-original)
```

Rules:
- If no decisions or actions were made → still log with summary only
- Use `- [x]` for actions already completed
- Preserve source links for traceability
- Update the `Last synced:` date at the top of the file

### Step 6: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MEETINGS SYNCED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
New meetings: [count]
Decisions extracted: [count]
Open actions: [count]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Query Mode

When the user asks about a specific meeting or topic (not syncing):

1. First check `memory/meetings.md` for already-extracted info
2. If not found or more detail needed → query the meeting tool directly
3. Answer from the combined context
4. If the query reveals unsynced meetings, offer to sync

## Deduplication

Before appending, check if a meeting with the same date and title already
exists in meetings.md. Skip duplicates. Safe to run multiple times.

## File Maintenance

When meetings.md exceeds ~200 entries:
- Archive older entries (>90 days) to `memory/meetings-archive.md`
- Keep only last 90 days in the main file
- Reference the archive at the top: `Older meetings: see meetings-archive.md`
