# Orchestration Rules

## 1. Orchestrated runs do not load folder instructions

An orchestrator starts each agent in its own workdir, so `CLAUDE.md` and `AGENTS.md` in the AI OS folder never load. When a rule here should bind those agents, update the orchestrator's workspace context or the agent instructions in the same sitting.
Why: otherwise the local and orchestrated agents silently follow different rules.

## 2. Track-level `AGENTS.md` is a pointer, not a copy

For file-reading agents launched in a track folder, use a few lines that tell them to read the root file and then the track file. A symlink to the track file alone drops the root rules, while a copy drifts.
Why: a pointer preserves both instruction layers without creating another source of truth.

## 3. Choose an issue or a local session deliberately

Use a task-board issue when work needs an executor, a repository, several steps, a durable record, or execution while the laptop sleeps. Use a local session when the human is involved turn by turn or the work changes the machine itself, such as agent configuration, the keychain, or launch agents.
Why: the execution surface should match the work's durability and where its state lives.

## 4. Use a predictable roster

Use one router that plans and assigns without executing, one executor per model family, a backup executor only when the primary reaches its quota, and a reviewer from a different model family than the author. Switch to the backup with a deterministic watcher that reads a machine-readable failure reason. Never place confidential material in issues handled by an external provider that has not been cleared for it.
Why: explicit roles, deterministic failover, and provider boundaries make behavior auditable.

## 5. A laptop runtime sleeps

Runs assigned to a laptop queue, and scheduled runs are skipped while it is offline. Put work that must run on time, such as intake bots, backups, and collectors, on an always-on host.
Why: a schedule is not a delivery guarantee when its runtime can disappear.

## 6. Every agent mention is a paid run

Do not use agent mentions for courtesy, thanks, or FYI messages; assign work by stable ID, never by fuzzy name.
Why: every mention consumes resources and ambiguous names can dispatch the wrong executor.

## 7. Check connector identity before writing

A connector acting as a person may expose that person's entire workspace, including an employer's. Probe which account it is bound to before writing, and remember that deny rules for one tool namespace may miss the same connector exposed under another name.
Why: connector identity and aliases determine the real confidentiality boundary.

## 8. Keep secrets outside the tree

Store secrets in 600-permission files outside the tree, never in a `.md`. A human copies remote-host keys into per-application environment files there; the laptop's own key folder never leaves the laptop.
Why: separating secrets from content prevents accidental publication and cross-host leakage.

## 9. Use the owning system's time zone

State a time window in the time zone of the system that defines it, such as a sender schedule or rate-limit reset.
Why: converting it to local time fails during weeks when the two zones change daylight-saving time on different dates.
