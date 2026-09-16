# /start — Session Kickstart

**For AI agents:** follow these instructions when the user says "/start", "new session",
"let's begin", or "kick off".

---

## Step 0 — Determine the track

The track is **the folder the session was launched in**. Do not ask; detect it.

```bash
case "$PWD" in
  *"AI OS/{{Track A}}"*) TRACK={{track-a}} ;;
  *"AI OS/{{Track B}}"*) TRACK={{track-b}} ;;
  *)                     TRACK=system ;;
esac
echo "Track: $TRACK"
```

| Track | Focus file | Tasks live in |
|---|---|---|
| `{{track-a}}` | `memory/focus-{{track-a}}.md` | {{tracker A}} |
| `{{track-b}}` | `memory/focus-{{track-b}}.md` | {{tracker B}} |
| `system` | *(none — say so)* | — |

If `TRACK=system`, skip the focus load. Say the session is unscoped, name the two tracks and the
folder to relaunch in, and go to Step 2.

**Never load both focus files.** If the user's goal turns out to belong to the other track, say so
and tell them to relaunch there — do not silently load the other file.

---

## Step 1 — Load context

| File | What to extract |
|---|---|
| The track's focus file | Active strategic streams (and the dated table, if the file opens with one) |
| `memory/sessions-history.md` (**top entry only**) | Last session's narrative |

**Slice for `sessions-history.md`** — read only the most recent entry, never the whole file:

```bash
awk '/^## / { if (in_first) exit; in_first = 1 } in_first { print }' "$HOME/AI OS/memory/sessions-history.md"
```

**Already loaded automatically — do not re-read:** the root `CLAUDE.md`, the track's `CLAUDE.md`,
and the auto-memory `MEMORY.md` index.

**Do NOT load by default:** `memory/archive/**` · any project-specific file — not yet scoped.

### Health checks

Run them in one batch, not one command per check.

```bash
grep -m1 '^## \[' "$HOME/AI OS/memory/sessions-history.md"
wc -l < "$HOME/.claude/projects/<project-slug>/memory/MEMORY.md"
grep -m1 -o 'last_reviewed: [0-9-]*' "$HOME/AI OS/CLAUDE.md"
```

Surface a warning only when one actually trips:

- **sessions-history staleness** — top entry > 24h old ⇒ soft warning that context may be stale.
- **cross-track continuity** — top entry stamped with the *other* track ⇒ it is not continuity for this session; say so.
- **MEMORY.md over 200 lines** ⇒ content past the limit is silently dropped at load. Move detail into topic files.
- **CLAUDE.md freshness** — `last_reviewed` > 30 days ⇒ flag a freshness pass before `/finish`.
- **The clock.** If the focus file opens with a dated table, overdue / today / tomorrow always surface.

---

## Step 2 — Display

Order is fixed. **When the focus file has a dated table, the clock comes first** — dates outrank
streams, because a stream carrying no date never loses to one that does.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION CONTEXT · [track]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[If the focus file has a dated table] **⏰ The clock — today is [Day DD Mon]**
[table: Date | What lands | State]

**Active Focus**
[table: Stream | State]

**Last session**
[name] — [1–2 sentences: what was accomplished + the key decision]

[Health: one line when clean. A warning block only when a check trips]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[One-line read: where you would start and why. Then the Step 3 question.]
```

### Rendering rules

**The clock.** Three columns — `Date | What lands | State`. Everything overdue, plus today and
tomorrow — always. Then the next 2–3 forward milestones with their distance (`**Fri 12 Sep** (+12d)`).
Not the whole table. **State is yours to write, not copied from the focus file** — say whether the
thing has actually started, and flag a contradiction when you see one.

**Active Focus.** Two columns — `Stream | State` — in the focus file's own priority order. Compress to
what changes a decision: what is blocked, what is the bottleneck, what is banked. Not the goal.

**Last session.** If the top entry belongs to the *other* track, say so and do not present it as
continuity. Name the most recent entry that does belong to this track, or state that the focus file is
the only state there is.

**The closing read.** One-line recommendation of where you would start and why. Pick one, name the
trade-off if there is one, then ask.

## Step 3 — Ask about goals

One open question:

> **What do you want to accomplish this session?**

Wait for the answer before proceeding.

---

## The memory model, in one place

```
memory/
├── focus-{{track-a}}.md  ← streams, track A   (loaded at /start when TRACK={{track-a}})
├── focus-{{track-b}}.md  ← streams, track B   (loaded at /start when TRACK={{track-b}})
├── sessions-history.md   ← append-only; top entry = last session, stamped with its track
└── archive/              ← superseded files (never loaded)
```

- Focus files hold **streams** — multi-week initiatives. Not tasks.
- Tasks live where the track's `CLAUDE.md` says they live.
- `/finish` writes one file: it prepends to `sessions-history.md`. A focus file is edited only when
  streams actually changed.
- The agent's own auto memory (`~/.claude/projects/<project>/memory/`) is a **separate** system for
  what the agent learns. Do not mirror AI OS content into it.
