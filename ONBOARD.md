# Onboarding — paste this whole file into a fresh Claude Code chat

> **Claude: onboard me the way a great product would.** Clear, one step at a time, explaining
> *why* before each step, marking progress, and building to the moment I have real skills running
> on my own data. I already use Claude Code a little, so skip what I already have. Don't dump the
> whole plan at once. Don't lecture. Make it feel easy and a little exciting.

## First, tell me where we're going

Open with something like:
> *"In about 45 minutes you'll walk away with: your AI OS set up on this machine (a tidy home base
> that makes me useful), your tools connected, and — the point — a **working skill built on your
> real data** for a task you do regularly, plus the know-how to turn anything you repeat into a
> one-command skill. We go one step at a time, and I'll skip whatever you've already set up. Ready?"*

Then wait for me to say go. Don't proceed until I do.

## How to run this (your rules, Claude)

1. **One line of "why" before each step**, then do it. People follow steps they understand.
2. **One step at a time. Verify before advancing.** Never paste the whole runbook at once.
3. **Mark progress** — "✅ that's 1 of 5 done" — so it feels like motion.
4. **Skip what I already have** (you'll learn that in Step 0).
5. **The payoff is Steps 4-5** — building real skills on my data. Everything before is setup; keep it light and quick.
6. **If something breaks, debug it with me.** When it works, say so.

---

## Step 0 — Get to know me (2 min)

**Why** (say it): *"So I tailor the rest to you and don't waste time on things you've already got."*

Ask me three questions, ONE AT A TIME:
1. What do you already use Claude Code for today?
2. Which tools do you want me to reach directly (CRM, chat, sheets, email, meeting notes…) — and which are already connected as MCPs?
3. **What's a task you repeat regularly and wish ran itself?** ← we'll build a version of this as your first skill.

Then tell me the plan you picked from my answers (one short paragraph): what we'll set up, connect, and build; what we'll skip.

---

## Step 1 — Set up your AI OS on this machine (10 min)

**Why**: *"I work best with a tidy home base — one folder that holds who you are, your memory, and
your skills. Let's create it properly so everything after just works."*

1. If I haven't yet, have me run `./setup.sh` from this repo.
2. **Verify the structure** — show me the tree and confirm each piece exists, explaining each in one line:
   - `~/AI OS/` → `CLAUDE.md`, `memory/` (focus.md, inbox.md, references.md, sessions-history.md, meetings.md), `knowledge-base/`, `projects/`
   - `~/.claude/skills/` (bundled skills), `~/.claude/hooks/` (guardrails), `~/.claude/settings.json` (hooks wired)
   If anything's missing, fix it with me before moving on — the rest assumes this layout.
3. **Write my CLAUDE.md** — interview me one question at a time: name, role, what I'm driving (2-3 streams), how I like outputs, anything you must never say, key teammates + what they own. Write it in, show me, confirm it reads back right.

✅ **Win 1**: *"Your AI OS is set up and I know who you are. This folder is your home base now."*

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

✅ **Win 2**: *"Keys live in one safe place. From here, connecting any tool is a 2-minute job."*

---

## Step 3 — Connect the tools your first skill needs (10 min)

**Why**: *"Your first skill (next step) is the recurring task from Step 0 — so let's wire the tools it
needs: wherever its data lives (your CRM, analytics, sheets) and wherever its output goes (chat, docs)."*

Connect them ONE AT A TIME. For each: one line on what it unlocks → the install/connector step + where the key goes → wait for me to confirm → **verify with a tiny real read** before advancing.

Common gotchas to flag so I don't trip:
- **Google Sheets** = service account + share the sheet with its email (a programmatic identity, not a person).
- **Personal email (Gmail etc.)** = OAuth user-flow, not a service account; sensitive scopes can expire after 7 days in "Testing" mode.
- **Chat tools (Slack etc.)**: a *bot token* posts as a bot (survives you leaving an org); a *user token* posts as you.
- **Remote OAuth MCPs** usually need a Claude Code **restart** before their tools appear.
- **CRM built-in reports** often fold in bulk-cleanup + test records — pull raw and compute yourself for real analysis.

✅ **Win 3**: *"Tools wired and verified. Now we build something real."*

---

## Step 4 — Configure your first skill: a report you run regularly (15 min)

> **The first real payoff.** We'll take the recurring task you named in Step 0 and turn it into a
> skill you run with one command. I'll lead this one so you see exactly how a skill gets built — then
> in Step 5 you drive.

**Why**: *"Turn the task into a `/command` once, and from then on it's one keystroke on live data —
no more manual pulling and pasting."*

**Plan it WITH me first** (don't run yet — show me the steps + which data/fields you'll use, let me adjust):
1. **Pull** the inputs from the connected tools (your CRM / analytics / sheets).
2. **Compute** the thing you actually care about — the trend, the funnel, the conversion rates, the summary.
3. **Render** a forwardable output (a chat message, a doc, a filled sheet).

**Then build it:**
- Run it on my **real data**. Sanity-check one number by hand (LLMs confabulate — verify before trusting).
- Show me the actual output; let me adjust.
- **Save it as a skill**: write the SKILL.md to `~/.claude/skills/<name>/`. Confirm `/<name>` shows up when I type `/`.

✅ **Win 4 — first aha**: *"You just built `/<name>`. Next time it's one command on live data. You didn't
write code — you described the job and it became a tool."*

---

## Step 5 — Now build YOUR own (15 min)

> **Your turn to drive.** Step 4 I led; this one you steer — that's the real unlock.

**Why**: *"The point was never that one report. It's that anything you repeat can become a `/command`.
Let's prove it on a task you pick."*

1. **Ask me**: *"What's another task you do on a schedule and wish ran itself?"*
2. **Scope it with me**: what data, what output, how often. Plan before building.
3. **Build + run it** on my real data, one step at a time.
4. **Save it as a skill**, confirm it appears.
5. If it's worth running unattended later, mention it can graduate to a scheduled job (cron) — but only after it's proven by hand a few times.

🎉 **The aha**: *"That's two skills you built today. The pattern is the whole game: do a thing once with
me → save it → it's free forever. Anything you repeat 3+ times is a candidate."*

---

## Where to go next (1 min)

- Read `README.md` for the memory model + the three-tier agent architecture.
- Suggest the next single tool to connect, based on what we reached for in Steps 4-5.
- The rule that keeps this compounding: **anything I do 3+ times → ask you to make it a skill.**
- Give me ONE highest-leverage next step for my situation — not a list of ten.

---

## Rules to hold throughout (re-read if you drift)

- Why-then-do. One step at a time. Verify before advancing. Skip what I already have.
- The payoff is Steps 4-5 — real skills on my data. Everything before is setup.
- Read official docs first when you hit an API you're unsure about.
- **Prompts aren't the point — workflows and skills are.** Don't hand me prompt lists; build me things that run.
