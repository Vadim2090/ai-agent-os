# AI OS — root agent instructions

> `AI OS/` is the single source of truth. This file holds only what is true in **every** session.
> Track-specific context lives one level down and loads on its own.

<!-- last_reviewed: {{YYYY-MM-DD}} — the /start health check flags this when it is >30 days old -->

---

## 1 · SCOPE — the track is set by the launch folder

Claude Code loads `CLAUDE.md` from the working directory **and every parent**. Files in
subdirectories load lazily, the first time a file there is read. So where the session starts
decides which context is live:

| Launch in | Loads | Use for |
|---|---|---|
| `~/AI OS/{{Track A}}` | this file + `{{Track A}}/CLAUDE.md` | {{e.g. the day job: one employer, one client}} |
| `~/AI OS/{{Track B}}` | this file + `{{Track B}}/CLAUDE.md` | {{e.g. personal projects, side venture, career}} |
| `~/AI OS` (root) | this file only | System work, cross-track questions |

**Do not restate a track's rules here to "make sure they load."** If a rule from one track matters in
a session, that session should have started in that track's folder — say so instead of duplicating.

**One track per session.** To switch, end the session and relaunch in the other folder.
A track's confidential material never appears in the other track's files, chat, or shared surfaces.

---

## 2 · FOLDERS

| Path | Purpose |
|---|---|
| `CLAUDE.md` | This file — shared context only |
| `START.md` | Session kickstart procedure (`/start`) |
| `knowledge-base/` | Reference material — glossary, operating principles, reviews |
| `memory/` | Session state. See §5 |
| `{{Track A}}/` | Track folder. Own `CLAUDE.md`, own task tracker |
| `{{Track B}}/` | Track folder. Own `CLAUDE.md`, own task tracker |

```
AI OS/
├── CLAUDE.md                     ← this file: what is true in every session
├── START.md                      ← /start procedure
├── knowledge-base/               ← reference material (principles, glossary, reviews)
├── memory/
│   ├── focus-{{track-a}}.md      ← streams, track A (loaded at /start when launched there)
│   ├── focus-{{track-b}}.md      ← streams, track B
│   ├── sessions-history.md       ← append-only; top entry = last session, stamped with its track
│   └── archive/                  ← superseded, never loaded
├── {{Track A}}/
│   ├── CLAUDE.md                 ← track rules and context; loads only when launched here
│   ├── .claude/skills/           ← skills scoped to this track
│   └── <org>-<workstream>/ · repo-<owner>-<tool>/ · archive/
└── {{Track B}}/
    ├── CLAUDE.md
    └── <project>/ · repo-<tool>/ · archive/
```

### Naming

Folders are kebab-case. **The prefix states what kind of thing it is** — read it before assuming
where something lives:

| Prefix | Means | Contains |
|---|---|---|
| `repo-*` | **A code repository** — a git checkout, usually with a remote | Source code. The second segment names the owner or the tool |
| `{{org}}-*` | A workstream of that organisation | Docs, analysis, specs — not code |
| *(no prefix)* | A one-off or cross-cutting piece of work | |
| `archive/` | Retired. Never loaded, kept for recovery | Superseded projects and files |

⚠️ If a folder carries `repo-` without being a git repository, the name promises a checkout that is
not there — verify before running any git operation against it.

---

## 3 · CONTEXT — who I am

- **{{Name}}**, {{city}}. Timezone {{tz}}. Languages: {{languages}}.
- {{One line of career shape: years, domains, what you do now.}}
- **The through-line in my experience**: {{the one sentence that makes five roles read as range,
  not drift — e.g. "building the system that produces the result, and the instrumentation that proves it did."}}

### How I work

- **Automation-first.** Scalable workflows, minimal manual ops, strong API capability.
- **Data-first.** Data lives cleanly in the system of record and syncs to the analytics stack.
- **High-signal execution**: crisp definitions, structured outputs, iterative delivery (v0 → v1 → v2)
  with obvious deltas.
- **Practical simplicity beats elegance.** When I ask for "the simplest way", do not propose a system.

### Self-described weaknesses — treat as operating instructions

<!-- One line per weakness, each followed by the agent's counter-move. -->
1. **{{e.g. Loses focus in long sessions; leaves things unfinished.}}** → Close deliverables. Name the one
   next action. Do not open a fifth thread while three are half-done.
2. **{{e.g. Buries the conclusion.}}** → Lead with the answer, then the reasoning. Never make me read to
   the end to find out what happened.
3. **{{e.g. Under-claims.}}** → When my own verified numbers are strong, say so plainly.

---

## 4 · RULES

### Communicating

- Direct. Skip pleasantries. Executive summary first.
- Metrics questions get **numbers, not narratives**.
- Structured outputs by default: tables, schemas, checklists.
- If I can forward it to someone as-is, that is a good output.
- **Answer from the data you have — don't route the question back to me.** "We should ask X" is not an
  answer when the data already supports an estimate. Produce the number, label the assumption, flag
  what would change it. Escalate only when the answer genuinely cannot be derived.
- **Analysis docs read general → specific, primary → secondary.** Headline conclusion first.

### Written artifacts

- **One deliverable = one `.md` file.** Never split an analysis into a file per finding.
- **One language in files — no exceptions.** Every `.md`, page, memory file, code comment, commit
  message is written in {{English}}. Chat follows my language; **the chat language must never leak into
  the file.** Verify before saving, e.g. for Cyrillic: `grep -nP '[\x{0400}-\x{04FF}]' <file>` must return nothing.
  Quoted source material may stay in the original inside quotes; everything the agent authors is {{English}}.
- A message in another language that has to *ship* (a chat note, a founder-to-founder message) is
  drafted **in the chat**, not saved as a file, unless I ask otherwise.

### Claims and numbers

- **Claim discipline on every number.** *Built and ran* what you built and ran; *operated and optimised*
  — never *personally sourced* — what the whole team produced. And **always state the denominator**:
  a rate without its base can describe two completely different results.

---

## 5 · RUNTIME

**Primary agent: Claude Code** (Desktop + CLI), built around its native features — skills, hooks,
auto memory, path-scoped rules (`.claude/rules/`), MCP. Core context files are plain markdown,
portable to any agent that reads files.

**Principles**
1. **Make the work visible to the agent.** Decisions, plans, metrics and outputs live in files here or in
   systems reachable via MCP. Read them before asking. This folder is the single source of truth.
2. **Fix the system, not the AI.** On a failure, check tooling, documentation and context freshness
   before rewriting a prompt or switching models.
3. **Enforce structure mechanically.** Hooks and scripts prevent violations; prose is documentation, not
   the guard. One track per session, decided by the launch folder.

### Session state — `memory/`

| File | Role | Loaded |
|---|---|---|
| `focus-{{track-a}}.md` · `focus-{{track-b}}.md` | Active strategic streams, one file per track | At `/start`, by track |
| `sessions-history.md` | Append-only timeline; top entry = last session, stamped `<!-- track: X -->` | Top entry only, at `/start` |
| `archive/` | Superseded files. Kept for recovery | Never |

Tasks do **not** live here. They live in the tracker named by the active track's `CLAUDE.md`.
Focus files hold **streams** — multi-week initiatives — not tasks.


**These files are maintained by me.** Claude Code's own auto memory
(`~/.claude/projects/<project>/memory/`) is a separate store for what the agent learns — corrections,
preferences. **Do not mirror `memory/` content into it.**

**Session flow**: `/start` to begin, `/finish` to wrap up.

**`/start` loads state; it is worth its ~5K tokens only when the session needs state** — continuing
prior work, a dated milestone on the horizon, or the first session in several days. A self-contained
technical task does not need it. Everything mechanical — track detection, staleness, cross-track
continuity, `CLAUDE.md` freshness, `MEMORY.md` size — runs in the SessionStart hook regardless.

**Skills** load by scope: `~/.claude/skills/` (everywhere), `{{Track A}}/.claude/skills/` (that track
only). Put a new skill where its scope is, not in the shared folder by default.

**Subagents — choose by context need, not by task type.** One question decides it: *does the agent
need what this session already knows?*
- **Yes** → Agent tool **without** `subagent_type`. A fork inherits the parent's context and shares its
  prompt cache. Never set `model` on a fork — a different model cannot reuse the cache.
- **No** → a named `subagent_type`. It starts cold, and that is the point: a wide file sweep or a
  research fan-out should hand back a conclusion, not drag its reading into this window.

**Web tools — built-in by default, a semantic search tool when the query is about meaning.**
Known public URL → built-in fetch. Keyword-shaped question → built-in search. Meaning-shaped
question ("companies like X", "who has written about Y") → semantic search. Bulk URL enrichment →
the provider's REST API directly, not the MCP.

**Secrets** live in an environment file outside this folder — never in a `.md` file.
