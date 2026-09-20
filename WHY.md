# WHY.md — every mechanism traced to the incident that created it

A rule that lives only in prose gets forgotten, and so does the reason for it. This file keeps the reason.
One row per mechanism: what happened, when, what prevents it now. New rows are added when a correction
becomes a hook, a rule or a structural change; nothing here is hypothetical.

| Mechanism | Incident | When | What prevents it now |
|---|---|---|---|
| Two tracks by launch folder, one `CLAUDE.md` each | One CLAUDE.md past 200 lines served two jobs; every session paid for both, and material from one job could surface in the other | Sep 2026 | A track's rules load only when the session starts in its folder |
| `sessions-history.md` as the only "last session" file | A separate hand-off file duplicated the top entry; two files claiming "latest" gave torn writes when sessions ran in parallel | 2026 | One append-only timeline; the top entry is the last session |
| `/finish` prepends with a shell op | The model rewrote a 200 KB history file on every wrap-up: five minutes and a chance to mangle old entries | 2026 | The model writes only the new entry |
| Streams, not tasks, in focus files | Tasks were carried from session to session, one of them 21 times; a task carried that long is a museum piece | 2026 | Tasks live in the tracker; focus files hold multi-week streams |
| `finish-staleness-check.sh` at SessionStart | Sessions ended without `/finish`, and the next session trusted a stale top entry as current | 2026 | A warning whenever the history is more than 24 h old |
| Freshness checks at SessionStart | The agent acted on outdated context: people who had left, tools marked "evaluation" that were live | 2026 | Stale instructions are flagged, not followed |
| `content-guard.sh` after every write | In a regulated domain there is content the agent must never produce; a written rule was not enough | 2026 | Every write is scanned; a hit exits 2 and reaches the agent |
| Retired the inbox file and `/checkpoint` | A capture counter nobody acted on for three months, and a second "latest" file | Sep 2026 | Capture goes straight to the tracker; hand-off runs through one file |
| Least-privilege `settings.json` and the sandbox | The first template approved every shell command and denied nothing; a review found secret files readable by the file tools | 17 Sep 2026 | Secret files denied, destructive commands ask, OS-level isolation for Bash |
| `done-gate.sh` at Stop | Chat-language text kept leaking into English-only files; the only check was a manual grep the agent forgot | 17 Sep 2026 | Everything the session touched is re-checked before the agent stops; blocks once |
| Anchored secret patterns in `done-gate.sh` | The first regex flagged "risk-", "task-" and "desk-" as API keys: 13 hits, all false | 17 Sep 2026 | Word-anchored patterns; test fixtures skipped |
| Evals: `tests/`, `evals/`, a weekly routine | Claude Code went 2.1.270 → 2.1.274 in one afternoon and nothing would have shown a rule breaking | 17 Sep 2026 | Fixed prompts, a fresh agent, assertions on artifacts, run weekly |
| Eval fixtures built outside the tree | A fixture under the real AI OS inherited the real CLAUDE.md through ancestor loading and quoted the operator's rules back | 17 Sep 2026 | `tempfile.mkdtemp`, never inside the workspace |
| Quoted hook paths | `bash /Users/x/AI OS/hooks/a.sh` ran as `bash /Users/x/AI`; the transcript showed only a non-blocking hook error | 17 Sep 2026 | Every hook command quotes its path |
| Rules and agents installed to `~/.claude/` | Copies at the AI OS root never loaded in a track session; a probe rule proved it | 17 Sep 2026 | `setup.sh` installs to user scope; rule scopes stay under the launch folder |
| `lang-check: data` waiver in `done-gate.sh` | A stop-word list and a marker regex written in another script are data the code matches against, not prose the agent wrote; the gate blocked on them every stop | 20 Sep 2026 | A file declares the waiver in its own first 4 KB, where a reader meets the reason; the secret check still runs |
| `AGENTS.md` canonical, `CLAUDE.md` a symlink | "Portable to any agent that reads files" was a claim with no file behind it | 17 Sep 2026 | One instruction file under the open-standard name; Claude Code reads it through the symlink |
