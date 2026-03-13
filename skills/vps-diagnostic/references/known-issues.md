# Known Issue Patterns

Catalog of common VPS failure patterns. Add your own as you discover them.
Each entry has a signature (what to grep for), trigger, fix, and check method.

## P0 — Service-Breaking

### OOM Kill
- **Signature**: `Out of memory: Killed process` in journal
- **Trigger**: Process memory spike when RAM is low and no swap configured
- **Fix**: Add swap (`fallocate -l 4G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile`), persist in `/etc/fstab`
- **Check**: `free -m` swap line = 0, or swap_used > 80%

### Service Down
- **Signature**: `systemctl is-active <service>` != "active"
- **Fix**: `systemctl restart <service>`, check logs with `journalctl -u <service> --since "1 hour ago"`
- **Check**: service status field in diagnostic output

### Env Var Placeholder Left in Production
- **Signature**: env var contains `YOUR_`, `changeme`, `PLACEHOLDER`, or is empty
- **Impact**: Silent failures — services start but don't function (no errors logged)
- **Fix**: Set correct value in `.env` file
- **Check**: ENV_VARS section for MISSING or PLACEHOLDER

## P1 — Degraded Performance

### API Timeout Loop
- **Signature**: Repeated timeout errors with retry attempts in logs
- **Trigger**: Single API key with no backoff, retry loops to same key
- **Impact**: Service unresponsive for hours, wasted API credits
- **Fix**: Add exponential backoff + max retries, add fallback API key
- **Check**: timeout_count > 3 in last 24h

### SIGTERM Cascade
- **Signature**: 5+ SIGTERM events in 1 hour
- **Trigger**: Long-running process exceeds timeout, gets killed, spawns retry that also exceeds timeout
- **Impact**: Wasted compute, possible OOM from accumulated processes
- **Fix**: Break long tasks into atomic units with self-termination timeouts
- **Check**: sigterm_count > 5 in last 24h

### Cron Job Silent Failure
- **Signature**: Cron exists in crontab but log file is stale or missing
- **Trigger**: Code changes not deployed, env vars not set, stderr not redirected to log
- **Impact**: Scheduled tasks silently stop running — no alerts, no visibility
- **Fix**: Check log freshness, verify code is synced, verify env vars
- **Check**: Compare last log timestamp to expected cron schedule

### Code Drift (Local vs VPS)
- **Signature**: `AttributeError`, `ModuleNotFoundError`, or missing function errors in logs
- **Trigger**: Partial deployment (some files synced, others not)
- **Impact**: Silent failures caught by try/except, partial data
- **Fix**: Use a deploy script that syncs all files atomically
- **Check**: Look for import/attribute errors in recent logs

## P2 — Monitoring Gaps

### High Memory Usage
- **Signature**: Service memory > 70% of total RAM
- **Fix**: Restart service to reclaim memory, investigate leaks
- **Check**: service_memory field vs ram_total

### Disk Usage > 80%
- **Signature**: disk_pct > 80%
- **Fix**: Clean temp files, old logs, stale caches
- **Check**: disk_pct field

### Missing Log Files
- **Signature**: Log path returns NO_LOG_FILE
- **Impact**: No visibility into cron job health
- **Fix**: Verify cron stderr redirect path exists, check permissions
- **Check**: Any NO_LOG_FILE in cron health section

### Network/DNS Intermittent Failures
- **Signature**: `fetch failed`, `ECONNREFUSED`, `EHOSTUNREACH` in logs
- **Fix**: Add retry logic for transient network errors, check DNS config
- **Check**: dns_resolve = FAIL or outbound_https = FAIL
