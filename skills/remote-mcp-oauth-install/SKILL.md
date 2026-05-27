---
name: remote-mcp-oauth-install
description: |
  Install OAuth-gated remote MCP servers in Claude Code (CLI) and unblock the
  "where are my tools?" gotcha. Use when: (1) just ran `claude mcp add --transport http`
  for a remote MCP and only `mcp__<name>__authenticate` + `mcp__<name>__complete_authentication`
  appear in the deferred tool list, (2) `/mcp` reports "Authentication successful"
  but ToolSearch still finds zero functional tools (sender profiles, inbox, search,
  etc.) for that server, (3) installing GetSales, Tavily, Zapier, Brevo, Pipedrive,
  or other OAuth-based MCPs. Covers the install command, the OAuth handshake, the
  session-restart requirement, and the verification check.
author: Claude Code
version: 1.0.0
date: 2026-05-08
---

# Remote MCP OAuth install (Claude Code CLI)

## Problem

Claude Code's deferred-tool list is captured at session start and does NOT refresh when
a remote MCP server completes OAuth mid-session. Result: after a successful auth flow
the user sees "Authentication successful. Reconnected to <name>" but the server's real
functional tools (sender profiles, inbox, reports, CRM, etc.) remain invisible to the
agent. Only the bootstrap helpers `mcp__<name>__authenticate` and
`mcp__<name>__complete_authentication` are exposed.

This is not in the MCP vendor docs. The GetSales help center ("Once authenticated,
the tools become available automatically") is technically correct but omits the part
about needing a Claude Code session restart to surface them.

## Trigger conditions

ALL of these together:

- `claude mcp add --transport http ...` succeeded (or equivalent for SSE)
- User completed OAuth in browser (clicked through GetSales/Tavily/Zapier login)
- Terminal `/mcp` shows: `Authentication successful. Reconnected to <name>.`
- `ToolSearch` with `select:mcp__<name>__authenticate,mcp__<name>__complete_authentication`
  returns those 2 tools — and nothing else for that namespace
- Searching for expected functional tools (e.g. `getsales sender inbox`) returns no
  matches under the `mcp__<name>__*` namespace

## Solution

Step-by-step:

1. **Install** (user-scope keeps it across all projects):
   ```
   claude mcp add --transport http --scope user <name> <url>
   ```
   This writes to `~/.claude.json`. No restart needed yet — the server is registered.

2. **Authenticate** via the slash command:
   ```
   /mcp
   ```
   Pick the server → triggers OAuth → browser opens → sign in. Terminal confirms
   "Authentication successful. Reconnected to <name>."

3. **Save in-flight state** before exiting (CRITICAL — Claude's working context dies on restart):
   - Write a short note to `memory/wip.md` describing what's open and what to test post-restart
   - Or use the `checkpoint` skill if available
   - Skipping this step loses audit work, partial plans, etc.

4. **Restart Claude Code**:
   ```
   /exit
   ```
   Re-launch from your normal entry (terminal, IDE integration, etc.). On startup the
   MCP host re-handshakes with `<url>`, this time with the stored OAuth token, and
   the full tool list propagates into the deferred-tool registry.

5. **Verify with `/start`** — it'll surface `wip.md` so you continue cleanly.

6. **Confirm tools loaded**:
   ```
   ToolSearch query="<server> <expected-capability>" max_results=10
   ```
   Should now return functional tools (e.g. `mcp__getsales__list_senders`,
   `mcp__getsales__inbox_read`). If it still only returns the 2 auth tools, see
   "Edge cases" below.

## Verification

Post-restart, this command should return >2 tools for the server's namespace:
```
ToolSearch query="select:mcp__<name>__authenticate" max_results=20
```

If you get tools you didn't ask for in the response (because the registry now contains
many `mcp__<name>__*` tools and the search returns related neighbors), that's the success
signal — pre-restart it returned exactly the 2 you named.

A direct functional call (e.g. "list my GetSales sender profiles") should succeed.

## Example: GetSales install (2026-05-08, verified)

```
$ claude mcp add --transport http --scope user getsales https://mcp.getsales.io
Added HTTP MCP server getsales with URL: https://mcp.getsales.io to user config
File modified: ~/.claude.json

# In Claude Code:
> /mcp
[picked getsales → browser OAuth → ]
Authentication successful. Reconnected to getsales.

# But:
> ToolSearch query="getsales sender inbox" max_results=15
# returns only mcp__getsales__authenticate + mcp__getsales__complete_authentication

# Fix:
> /exit
$ # relaunch claude code
> /start
[wip.md surfaces previous session]
> ToolSearch query="getsales" max_results=20
[functional tools now present]
```

## Edge cases

- **Tools still missing after restart**: server may genuinely expose only the 2 auth
  helpers (vendor doc overstates the surface). Test by reading the server's actual
  manifest via `claude mcp list` or by calling `mcp__<name>__authenticate` directly
  to see if it returns a capability list. If confirmed, the MCP is not yet usable —
  fall back to direct API.

- **Project-scope (`.mcp.json`) MCPs**: untested whether they have the same restart
  requirement. Likely yes — same host caching mechanism.

- **stdio-transport MCPs (local)**: do NOT have this problem — the tool list comes
  from the local process, no OAuth handshake involved.

- **Re-auth after token expiry**: when an OAuth token expires, expect to repeat the
  same restart cycle. Symptom: tools that worked yesterday return 401-style errors
  today. Fix: `/mcp` re-auth → `/exit` → relaunch.

- **Multiple OAuth MCPs at once**: each restart picks up ALL pending tool lists, so
  you can batch installs (add 3 servers, OAuth all 3 via `/mcp`, restart once).

## MCPs known to use this pattern

Confirmed on `~/.claude.json` 2026-05-08:
- `getsales` (mcp.getsales.io) — verified
- `tavily` — has `mcp__tavily__authenticate` + `complete_authentication`
- `zapier` — has `mcp__zapier__authenticate` + `complete_authentication`

Other likely candidates that use this same pattern:
- `brevo` (email marketing)
- `pipedrive` (CRM, via a community Pipedrive MCP fork)
- Any "Add custom connector" entry with HTTP transport

## Notes

- Don't confuse this with **Claude Desktop's** "Add custom connector" UI — that
  appears to refresh tools without restart, but Claude Code CLI behaves differently
  due to its session lifecycle.
- The `--scope user` flag matters. `--scope project` writes to `.mcp.json` in the
  current directory (good for shared team setups but requires teammates to OAuth
  individually).
- Claude Code stores OAuth tokens locally (path varies by OS); they survive restart
  so re-auth is one-time per token TTL.
- If you suspect cache corruption rather than just stale tool list, removing and
  re-adding the server (`claude mcp remove <name>` → `claude mcp add ...`) forces
  a clean handshake.

## See also

- `memory/wip.md` pattern — for preserving in-session context across forced restarts
- `getsales-api-patterns` skill — fallback when MCP can't deliver (bulk ops, complex
  Elasticsearch queries)
