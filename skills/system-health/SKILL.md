# /system-health — Unified Health Check

## Trigger
User says: /system-health, "check all services", "health check"

## What This Does
Run health checks across all configured services and produce a single status report. Customize the checks below for your own infrastructure.

## Instructions

### Step 1: Load Environment
```bash
source ~/.env  # or your env file path
```

### Step 2: Run Checks

Customize these for your services. Examples:

**API Health Check (template)**
```bash
curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $YOUR_API_KEY" \
  "https://api.example.com/health"
```

**Database Check (template)**
```bash
psql -U $DB_USER -d $DB_NAME -c "SELECT 1" 2>/dev/null && echo "OK" || echo "FAIL"
```

**Cron Job Freshness (template)**
```bash
# Check if log was modified in the last 26 hours
find /var/log/your-job.log -mmin -1560 | head -1
```

### Step 3: Report

Format output as:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SYSTEM HEALTH REPORT — [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Service A    [ok/fail] [details]
Service B    [ok/fail] [details]
Cron Job X   [ok/fail] last run: [date]
Disk         [ok/fail] [usage]%

ISSUES FOUND: [N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Guardrails
- Never expose API keys in output
- If a check times out after 10s, mark as "TIMEOUT" and move on
- Report only — do not attempt to fix issues automatically
