# Onboarding — paste this whole file into a fresh Claude Code chat

> **Claude: onboard me the way a great product would.** Clear, one step at a time, explaining
> *why* before each step, marking progress, and building to the moment my first real workflow
> runs — that's the payoff, treat it as the goal. I already use Claude Code a little, so skip
> what I already have. Don't dump the whole plan at once. Don't lecture. Make it feel easy and
> a little exciting.

## First, tell me where we're going

Open with something like:
> *"In about 45 minutes you'll walk away with four things: a CLAUDE.md that knows who you are,
> your tools connected, a set of reusable skills, and — the whole point — **one real task from
> your week running end-to-end in here**. We'll go one step at a time, and I'll skip anything
> you've already set up. Ready?"*

Then wait for me to say go. Don't proceed until I do.

## How to run this (your rules, Claude)

1. **One line of "why" before each step**, then do it. People follow steps they understand.
2. **One step at a time. Verify before advancing.** Never paste the whole runbook at once.
3. **Mark progress** — "✅ that's 1 of 5 done" — so it feels like motion.
4. **Skip what I already have** (you'll learn that in Step 0).
5. **The aha-moment is Step 5** (my first workflow). Everything before it is setup — keep it light and quick.
6. **If something breaks, debug it with me.** When it works, say so.

---

## Step 0 — Get to know me (2 min)

**Why** (say it): *"So I tailor the rest to you and don't waste your time on things you've already got."*

Ask me three questions, ONE AT A TIME:
1. What do you already use Claude Code for today?
2. Which tools do you want me to reach directly (e.g. Notion, Slack, your CRM, Google Sheets, email, a meeting-notes tool) — and which are already connected as MCPs?
3. **What's one task you do every week that you wish ran itself?** ← this is the one that matters; we build it in Step 5.

Then tell me the plan you picked from my answers (one short paragraph): which tools we'll connect, which workflow we'll build, what we'll skip.

---

## Step 1 — Your CLAUDE.md: teach me once, never repeat yourself (10 min)

**Why**: *"This file is the first thing I read every session. Spend 10 minutes here and you'll never
re-explain who you are, how you like things, or what to never say — ever again."*

1. If I haven't yet, have me run `./setup.sh` from this repo to create the `AI OS/` folder + install hooks and skills.
2. Open the generated `CLAUDE.md` and **interview me**, one question at a time:
   - Name, role, what I'm driving (2-3 streams)
   - How I like outputs (tables? exec-summary-first? forwardable-as-is?)
   - Anything you must never say
   - Key teammates + what they own
3. Write it in. Show me the result. Confirm it reads back right.

✅ **Win 1**: *"Now I know who you are on every future session — you'll never type this again."*

---

## Step 2 — Your keys, stored once and safely (5 min)

**Why** — explain this properly, don't rush it:
> *"To do real work I act on your actual tools — your CRM, your email tool, your sheets. I do that
> with API keys: basically passwords that let me log in as you. You don't want to paste those into
> every chat — slow and risky. So we store them once, in a single locked file on your machine. Set
> it up now and you never think about it again. And they stay safe: the file never leaves your
> laptop, never goes into a chat, never into git."*

Walk me through it:
1. Create one secrets file — e.g. `~/.env.local` (or `~/.env.<company>`). Keys go in as `NAME=value`, one per line.
2. Lock it: `chmod 600 ~/.env.local` — only my user can read it.
3. Keep it out of git: add `.env*` to my global gitignore (`git config --global core.excludesfile ~/.gitignore_global`, then add `.env*`).
4. **The rule to burn in**: never paste a key into a chat or a `.md` file. If I ever do, tell me to rotate it.
5. **The one gotcha**: MCP configs (`.mcp.json` / `~/.claude.json`) can't read this file — for those, paste the token value *inline*, and keep that config out of git too. If a tool offers a narrow MCP-scoped key, use the narrow one there.

We'll drop actual keys in as we connect each tool in Step 3 — for now just create the empty, locked file.

✅ **Win 2**: *"Keys live in one safe place. From here on, connecting any tool is a 2-minute job."*

---

## Step 3 — Connect your tools (10 min)

**Why**: *"This is what makes me more than a chatbot — now I can read your CRM, post to chat,
pull your sheets, instead of you copy-pasting between tabs."*

Connect the 1-2 MCPs closest to my Step-0 #3 task. ONE AT A TIME. For each:
1. One sentence on what it unlocks.
2. The exact install / connector step, and where the key goes (into the secrets file, or inline for an MCP config).
3. Wait for me to confirm it's connected.
4. **Verify with a tiny real read** ("list my last 3 pages", "read the last 5 messages in a channel"). Advance only when it works.

Common gotchas to flag so I don't trip:
- **Google Sheets** = service account + share the sheet with its email (a programmatic identity, not a person).
- **Personal email (Gmail etc.)** = OAuth user-flow, not a service account; sensitive scopes can expire after 7 days in "Testing" mode.
- **Chat tools (Slack etc.)**: a *bot token* posts as a bot (survives you leaving an org); a *user token* posts as you.
- **Remote OAuth MCPs** usually need a Claude Code **restart** before their tools appear.
- **CRM built-in reports** often fold in bulk-cleanup + test records — pull raw and compute yourself for real analysis.

✅ **Win 3**: *"Your tools are wired in. I can act on your real data now."*

---

## Step 4 — Install the skills (5 min)

**Why**: *"Skills are reusable workflows you run with `/name`. Build once, run forever. This is
where the leverage lives — not in clever one-off prompts."*

1. `setup.sh` copied this repo's `skills/` into `~/.claude/skills/`. Have me type `/` and confirm `/start`, `/finish`, `/sprint-planning`, `/meeting-debrief` show up.
2. Point out the 1-2 most relevant to my Step-0 task. Don't list them all.

✅ **Win 4**: *"You've got a starter toolbox. Now we make one of these do your real work."*

---

## Step 5 — The moment: run your first real workflow (15 min)

> **This is the point of everything above.** Say so: *"Okay — this is the part that makes it click.
> That weekly task you mentioned in Step 0? Let's do it together, right now, on your real data."*

Run it like this:
1. **Plan first** — show me the steps, let me adjust. Don't execute yet.
2. **Execute step by step** on my real data, confirming as you go.
3. **Produce a real, forwardable output** — a message, a doc, a filled sheet.
4. **Then turn it into a skill**: *"Want next time to be one command? Let me save this as `/yourthing`."* Do it with me.

🎉 **The aha**: *"You just did [the task] in [N] minutes — and next time it's literally one command:
`/yourthing`. That's the whole idea: teach me a workflow once, and it's free every time after."*

---

## Where to go next (1 min)

- Read `README.md` for the memory model + the three-tier agent architecture.
- Suggest the next single tool to connect, based on what I reached for in Step 5.
- Remind me of the rule that keeps this compounding: **anything I do 3+ times → ask you to make it a skill.**
- Give me ONE highest-leverage next step for my situation — not a list of ten.

---

## Rules to hold throughout (re-read if you drift)

- Why-then-do. One step at a time. Verify before advancing. Skip what I already have.
- Get me to Step 5 — the first real workflow is the win that matters; everything before is setup.
- Read official docs first when you hit an API you're unsure about.
- **Prompts aren't the point — workflows and skills are.** Don't hand me prompt lists; build me things that run.
