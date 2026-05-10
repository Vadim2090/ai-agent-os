# /start — Universal Session Kickstart

**For AI agents:** Follow these instructions when the user says
"/start", "new session", "let's begin", or "kick off".

---

## Session Start Procedure

### Step 1: Load Context

Read these files:

| File | What to extract |
|------|-----------------|
| `memory/focus.md` | Active strategic streams (the portfolio view) |
| `memory/sessions-history.md` (TOP ENTRY ONLY — see slice below) | Last session's narrative |
| `memory/wip.md` (if exists) | What's currently in flight in a parallel session |

**Slice for sessions-history.md** — read only the most recent session entry, not the whole file:

```bash
awk '
  /^## / {
    if (in_first) exit
    in_first = 1
  }
  in_first { print }
' "$HOME/AI OS/memory/sessions-history.md"
```

This prints from the first `## ` heading through to (but not including) the second — i.e., the latest session's full entry.

**Already loaded automatically:** CLAUDE.md, MEMORY.md (via auto-memory system — do not re-read).

**Do NOT load by default:**
- `memory/inbox.md` — GTD capture buffer; only loaded when user says "show inbox" or "process inbox". Cheap counter only at /start.
- `memory/references.md` — stable IDs/URLs; only loaded when needed.
- `IDEAS.md` — not actionable.
- Any project-specific files — not yet scoped.

### Health checks

**Inbox counter** (one bash op, no content load):
```bash
INBOX="$HOME/AI OS/memory/inbox.md"
COUNT=$(grep -c "^- " "$INBOX" 2>/dev/null || echo 0)
echo "Inbox: $COUNT items"
```

**focus.md staleness** — if "Last refreshed" line is > 7 days old, suggest a refresh.

**sessions-history.md staleness** — if last `## [YYYY-MM-DD HH:MM]` line is > 24h ago, soft warning that context may be stale.

**MEMORY.md line count**: count lines in auto-memory MEMORY.md. If over 200 lines, surface a warning.

### Display format:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION CONTEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Active Focus** (from focus.md):
[Streams grouped by section]

**Last session** (from top of sessions-history.md):
[name]
[1-2 sentence summary]

**Inbox**: [N items]

In flight (if wip.md exists):
🔄 [session name from wip.md]

[Health-check warnings if any]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Step 2: Ask About Goals

Ask ONE open question:

> **What do you want to accomplish this session?**

Wait for the user's response before proceeding.

---

## Notes on the 4-file memory system

```
memory/
├── focus.md              ← Active strategic streams (loaded at /start)
├── inbox.md              ← GTD capture buffer (NOT loaded at /start)
├── references.md         ← Stable IDs/URLs (NOT loaded at /start)
└── sessions-history.md   ← Append-only timeline; top entry = "last session"
```

- Tasks live in your **real task tracker** (Notion, Linear, etc.), not in any of these files.
- The system avoids duplication: each file has one purpose, one consumer, one cadence.
