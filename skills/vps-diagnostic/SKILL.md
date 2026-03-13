---
name: vps-diagnostic
description: >
  Deep diagnostic of a VPS that checks system resources, service health,
  cron jobs, logs, env vars, and known failure patterns — then produces a prioritized P0-P2
  report with specific fix commands. Use when: (1) user says /diagnostic or "check the VPS",
  (2) debugging a silent failure or degraded service, (3) before/after deploying changes to VPS,
  (4) weekly health audit. Collects all data in a single SSH session, then analyzes against
  a catalog of known failure patterns.
---

# VPS Diagnostic

Deep diagnostic for a remote VPS.
Produces a prioritized P0→P2 report with specific fix commands.

## Customization

Before using, update `scripts/vps-diagnostic.sh` with your:
- VPS hostname/IP (replace `YOUR_VPS_HOST`)
- Service names and paths
- Cron job locations
- Env var names and file paths

Update `references/known-issues.md` with failure patterns specific to your stack.

## Procedure

### Step 1: Collect Data

Run the diagnostic script on VPS in a single SSH session:

```bash
ssh root@YOUR_VPS_HOST 'bash -s' < ~/.claude/skills/vps-diagnostic/scripts/vps-diagnostic.sh
```

Timeout: 60s. If SSH fails, report "VPS UNREACHABLE" as P0 and stop.

### Step 2: Analyze Against Known Issues

Read `references/known-issues.md` for the full pattern catalog.

For each section of diagnostic output, match against known issue signatures:

| Section | Key Checks |
|---------|-----------|
| MEMORY | swap_total = 0 → P0. ram_available < 1GB → P1 |
| DISK | disk_pct > 80% → P2 |
| SERVICES | service_status != active → P0. version != latest → P2. memory > threshold → P1 |
| CRON_HEALTH | Log older than expected schedule → P1. NO_LOG_FILE → P2 |
| ENV_VARS | Any MISSING or PLACEHOLDER → P0 (if critical) or P1 |
| RECENT_ERRORS | OOM in 7d → P0 (if no swap). sigterm > 5/24h → P1. timeout > 3/24h → P1 |
| NETWORK | dns or outbound FAIL → P1 |

### Step 3: Generate Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VPS DIAGNOSTIC — [date] [time]
Host: [hostname] | Uptime: [since]
RAM: [used]/[total] | Swap: [used]/[total] | Disk: [pct]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

P0 — FIX NOW
  [issue] — [one-line description]
    Fix: [specific command or action]

P1 — THIS WEEK
  [issue] — [one-line description]
    Fix: [specific command or action]

P2 — NEXT SPRINT
  [issue] — [one-line description]
    Fix: [specific command or action]

CRON STATUS
  [cron name]  [schedule]  [last run]  [status]

ALL CLEAR (if no issues)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Rules:
- Each issue gets a severity (P0/P1/P2), one-line description, and a concrete fix command
- If an issue matches a known pattern from `references/known-issues.md`, cite it
- If a new pattern is found (not in known-issues.md), flag it as "NEW" and suggest adding it
- Never expose API keys or secrets — only report "set" / "MISSING" / "PLACEHOLDER"
- Group related issues (e.g., multiple related failures = one entry)
- If everything is healthy, say "ALL CLEAR" with the summary line

### Step 4: Offer Next Actions

After the report, ask:
> Want me to fix any of these? (list P0 items as defaults)

Do NOT auto-fix. The user decides what to fix.

## Guardrails

- Read-only diagnostic. Never modify VPS state during collection.
- SSH timeout: 60s. Mark section as TIMEOUT if exceeded.
- Never print env var values. Only report existence.
- If the diagnostic script is missing or fails, fall back to running equivalent commands inline.
