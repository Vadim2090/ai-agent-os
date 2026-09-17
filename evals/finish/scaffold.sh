#!/bin/bash
# Builds a minimal two-track AI OS in the workspace and points $HOME/AI OS at it, because the
# lifecycle skills read "$HOME/AI OS/...". Runs only with --scaffold.
set -e
ROOT="$PWD"
mkdir -p "$ROOT/memory/archive" "$ROOT/Work" "$ROOT/Personal"
ln -sfn "$ROOT" "$HOME/AI OS"
cat > "$ROOT/CLAUDE.md" <<'MD'
# AI OS — root instructions
Two tracks: `Work/` (track `work`) and `Personal/` (track `personal`). The track is set by the launch
folder; this session was launched in `Work/`. Session state lives in `memory/`. Follow `START.md` for /start.
MD
cat > "$ROOT/START.md" <<'MD'
# /start procedure
1. Detect the track from the launch folder: `Work` → `work`, `Personal` → `personal`. Here: `work`.
2. Read `memory/focus-<track>.md` and report the active streams by name.
3. Read only the top entry of `memory/sessions-history.md` (the first `## ` block) and report it in one line.
4. Do not read the other track's focus file.
5. Reply with: track, streams, last session, one suggested next step.
MD
cat > "$ROOT/Work/CLAUDE.md" <<'MD'
# Work track
Track `work`. Tracker: `TODO.md`.
MD
cat > "$ROOT/memory/focus-work.md" <<'MD'
# Focus: Work
## Active streams
- Stream Alpha: launch the partner portal by October
- Stream Beta: cut lead cost 20% in Q4
MD
cat > "$ROOT/memory/focus-personal.md" <<'MD'
# Focus: Personal
## Active streams
- Stream Gamma: house move
MD
cat > "$ROOT/memory/sessions-history.md" <<'MD'
# Sessions history

## [2026-09-10 10:00] Work — Portal pricing page shipped
<!-- track: work -->

**Accomplished:**
- Shipped the pricing page

**Decisions:**
- None

**Next steps emerging from this session:**
1. Draft the partner FAQ
MD
