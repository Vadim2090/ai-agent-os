---
name: meeting-debrief
description: |
  Analyze a single meeting and outline the user's next steps. Use when:
  (1) user shares a Granola/Otter/Fireflies link and asks to "analyze this meeting"
      or "outline my next steps",
  (2) user references a specific meeting by date/topic and wants actions extracted,
  (3) user wants a post-meeting synthesis filtered to their own action items.
  Pulls summary + transcript via the meeting tool's MCP, synthesizes into
  analysis + filtered next steps, optionally creates tasks in your task tracker.
  Do NOT trigger for: general multi-meeting sync (use /meetings instead) or sharing
  a meeting link without explicit analysis intent.
author: Claude Code
version: 1.0.0
---

# /meeting-debrief — Meeting Analysis & Next Steps

## Trigger
User shares a meeting URL (Granola/Otter/Fireflies/Read.ai) AND says one of:
- "analyze this meeting"
- "debrief this meeting"
- "what are my next steps"
- "outline my next steps from this meeting"
- "/meeting-debrief"

**Do NOT trigger** if:
- User only wants the raw transcript → use the transcript-fetch tool directly
- User wants multi-meeting sync → use `/meetings`

## Procedure

### Step 0: Load the radar
Before fetching the meeting, load context:
- `memory/focus.md` — active strategic streams
- Top entry of `memory/sessions-history.md` (use the awk slice from START.md) — last session's next steps + decisions
- `memory/inbox.md` — captured items that may be affected

Hold this as the baseline for Step 5's reconciliation. Don't include it in the visible output unless an item is affected by this meeting.

### Step 1: Extract Meeting ID
- Granola URL format: `https://notes.granola.ai/t/<meeting-id>-<variant-suffix>` → ID is the UUIDv4
- Otter / Fireflies: extract per the tool's URL format
- If no URL is provided, ask, or search by date/topic via the meeting tool's MCP

### Step 2: Fetch Meeting Data
Call in parallel (depending on which meeting tool is in use):
- Summary endpoint — for quick context
- Transcript endpoint — for nuance and exact quotes

### Step 3: Synthesize Meeting Analysis
Structure:

```
## Meeting Analysis — <Title> (<Date>)

**Key updates:**
- 3-7 bullets of decisions, announcements, strategic context
- Group by theme if long (e.g., Sales / Product / Ops)

**Red flags / new risks:**
- Anything flagged as concerning (missed targets, blockers, downturns)
```

Filter for signal — drop casual chat, retellings, and already-known context.

### Step 4: Outline User's Next Steps
**Filter strictly to items the user is responsible for** — not what others should do, unless the user is on the hook to follow up.

Structure:

```
## Your Next Steps

**Critical unblockers** (blocking other work or time-sensitive)
1. <Item> — why now, what success looks like

**<Theme 1>**
2. <Item> — concrete action

**<Theme 2>**
3. <Item>

**Ops / Housekeeping**
N. <Item>
```

For each item include: who they need input from, deadline if mentioned, dependencies.

### Step 5: Action Reconciliation + Task Proposal

Output **two tables in this order**:

**Table 1: Reconciliation against existing items**
For each baseline item (focus.md streams + sessions-history.md next-steps + inbox.md) that this meeting **affects**, classify:
- **DONE** — meeting confirms it's complete
- **REVERSED** — meeting reverses the prior decision
- **UPDATED** — tag/deadline/owner/blocker change only
- **SUBSUMED** — broader new task replaces this

Skip "unchanged" items (noise reduction).

| # | Existing item | Source | Status | Proposed change |
|---|---|---|---|---|
| O1 | [item] | focus.md | DONE | Update focus.md: ... |

**Table 2: New Tasks Proposal**
For action items surfaced by this meeting not already covered by Table 1.

| # | Task title | Tags | Priority | Status | Assigned To | ✅/❌ |
|---|---|---|---|---|---|---|
| T1 | [task] | [tag] | P1 | Not started | [User] | ☐ |

### Step 5b: Approval prompt
Always close Step 5 with this exact line:
> **Approve like: `create T1-T5, kill T2, reassign T3 to <name>, T4 P3 not P2`.
> For Table 1: `O1 confirm, O2 skip`. Or `all approve`.**

Parse the reply for: `create T<n>` / `kill T<n>` / `O<n> confirm` / `O<n> skip` / `all approve`.

Then:
- Table 1 confirmed → surgical Edit to focus.md / inbox.md, or via task-tracker MCP
- Table 2 created → batch-create in task tracker (via Notion / Linear / Jira MCP)
- Confirm with bullet list of created task URLs

### Step 6: Save nothing automatically
Do NOT write to `memory/` by default. The debrief is transient — artifacts are: (a) conversation output, (b) any tasks created.

If the meeting is a recurring sync that warrants a permanent memory file, ask the user first.

## Role context
When filtering "user's next steps":
- Adapt to the user's role (read CLAUDE.md "Who I am" section)
- Filter out items owned by others unless the user is following up
- Don't fabricate ownership — if unclear, ask

## Output quality checks
Before returning:
- [ ] Memory baseline (Step 0) was loaded before reconciliation
- [ ] Table 1 only lists affected items (no "unchanged" noise)
- [ ] Table 2 has user-approval prompt with parseable syntax
- [ ] All next steps are the user's own (not someone else's)
- [ ] Each item has enough context to act without re-reading the transcript
- [ ] Critical blockers called out separately from routine tasks

## Adapt to your stack
- Replace "Granola" with your meeting tool (Otter / Fireflies / Read.ai)
- Replace task-tracker references with your tool (Notion / Linear / Jira / Asana)
- Tags / priorities / statuses should match your schema (read from CLAUDE.md or ask)
