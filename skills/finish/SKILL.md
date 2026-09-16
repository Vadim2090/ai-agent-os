---
name: finish
description: Session wrap-up. Prepend the session entry to sessions-history.md (stamped with the track) and refresh the track's focus file only if streams changedd.
---

# /finish — Session Wrap-Up

## Trigger
User says: /finish, /end, "wrap up", "done for now"

## Procedure

### Phase 1: Generate Session Name
Create a short, descriptive session name based on what was accomplished.
- Format: `[YYYY-MM-DD HH:MM] {project-or-area} — {what was done}`
- Example: `[2026-02-21 14:30] AI OS — Setup & Config`
- Use current date and time (24h format)
- Keep the descriptive part under 50 characters
- Use the primary project/area worked on + the main action

### Phase 2: Append session entry to sessions-history.md (only file write)

The 4-file memory model removed `handoff.md`. The "last session" is just the top entry of `sessions-history.md`. /finish only writes that one file.

1. Compose the session entry and Write it to a fresh temp file:

   ```
   /tmp/new_history_entry.md
   ```

   Format:

   ```
   ## [session name]

   **Accomplished:**
   - [bullet points]

   **Decisions:**
   - [bullet points, or "None" if no decisions]

   **Next steps emerging from this session:**
   1. [numbered list — high-signal only; routine tasks should already be in your task tracker, not here]
   ```

   Keep entries concise — a scannable timeline of what was done and decided. Tasks belong in your task tracker, not here.

2. Run this Bash command (single shell op, atomic, no full-file regeneration by the model):

   ```bash
   HIST="$HOME/AI OS/memory/sessions-history.md"
   ENTRY="/tmp/new_history_entry.md"
   SPLIT=$(grep -n "^## " "$HIST" | head -1 | cut -d: -f1)
   if [ -z "$SPLIT" ]; then SPLIT=$(($(wc -l < "$HIST") + 1)); fi
   {
     head -n $((SPLIT - 1)) "$HIST"
     cat "$ENTRY"
     echo ""
     tail -n +"$SPLIT" "$HIST"
   } > "$HIST.tmp" && mv "$HIST.tmp" "$HIST" && rm "$ENTRY"
   ```

   This finds the first `## ` heading line, keeps the file header above it intact, inserts the new entry before it, and atomically renames. The model never streams the whole file.

3. **Size guard**: After the prepend, warn if file size > 200 KB:

   ```bash
   SIZE=$(stat -f%z "$HIST" 2>/dev/null || stat -c%s "$HIST")
   if [ "$SIZE" -gt 204800 ]; then
     echo "⚠️  sessions-history.md is $((SIZE / 1024)) KB. Quarterly rotation recommended: split oldest quarter into sessions-history-YYYY-QN.md."
   fi
   ```

   Do not auto-rotate. Surface to user; they decide when.

   **Rotation pattern** (when user approves): identify the line of the first entry of the oldest quarter (entries are newest-first), split into `sessions-history-YYYY-QN.md` with a small archive header, keep current quarter in active file. Update active file's header to list archived quarters.

### Phase 3: Optional updates (only if relevant)

These are NOT mandatory every /finish — only touch them when something genuinely changed:

**focus-<track>.md** (the launch track's file) — only edit if a stream was started/paused/retired this session:
- Use Edit tool for surgical changes (add/remove a single bullet under a section, or move between sections)
- Do not full-rewrite. Most sessions don't change the focus file.



**MEMORY.md (auto-memory)** — review if anything from this session should update it:
- New project started? → add to Active Projects list
- Key decision made? → add or update topic file pointer
- Most sessions: no change needed.

**Folder tree drift** — if any project folders were created/renamed/removed, update CLAUDE.md `## FOLDER STRUCTURE` section.

**CLAUDE.md freshness** — read the `<!-- last_reviewed: YYYY-MM-DD -->` comment. If older than 30 days, run a quick check (tools table, folder tree, people) and update the date.

**MEMORY.md size** — count lines. If > 200, trim before close (move details to topic files, replace with pointers).

**Stamp the entry** with `<!-- track: <track> -->` right under its heading, so /start can tell a foreign entry from continuity.

### Display format:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION [session name] WRAPPED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Logged to: sessions-history.md (top entry)
focus file updated: [yes/no]
Memory updated: [yes/no]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
