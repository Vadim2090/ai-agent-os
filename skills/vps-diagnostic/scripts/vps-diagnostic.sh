#!/bin/bash
# VPS Diagnostic — collects all health data in one SSH session
# Usage: ssh root@YOUR_VPS_HOST 'bash -s' < scripts/vps-diagnostic.sh
# Output: structured text blocks, parsed by the skill's analysis step
#
# CUSTOMIZE: Replace paths, service names, env var names, and cron jobs
# with your own. This is a template — adapt it to your stack.

set -o pipefail

echo "===SECTION:SYSTEM==="
echo "hostname=$(hostname)"
echo "uptime=$(uptime -s 2>/dev/null || uptime)"
echo "load=$(cat /proc/loadavg)"
echo "kernel=$(uname -r)"

echo ""
echo "===SECTION:MEMORY==="
free -b | awk '/^Mem:/{printf "ram_total=%d\nram_used=%d\nram_available=%d\n",$2,$3,$7}'
free -b | awk '/^Swap:/{printf "swap_total=%d\nswap_used=%d\nswap_free=%d\n",$2,$3,$4}'
echo "swap_file=$(ls -lh /swapfile 2>/dev/null | awk '{print $5}' || echo 'NONE')"
echo "swap_persistent=$(grep -c 'swapfile' /etc/fstab 2>/dev/null && echo yes || echo no)"

echo ""
echo "===SECTION:DISK==="
df -h / | tail -1 | awk '{printf "disk_size=%s\ndisk_used=%s\ndisk_avail=%s\ndisk_pct=%s\n",$2,$3,$4,$5}'
echo "tmp_size=$(du -sh /tmp/ 2>/dev/null | awk '{print $1}' || echo '0')"

echo ""
echo "===SECTION:SERVICES==="
# CUSTOMIZE: Add your systemd services here
# Example for a Node.js app:
# echo "myapp_status=$(systemctl is-active myapp 2>/dev/null || echo 'unknown')"
# echo "myapp_memory=$(systemctl show myapp --property=MemoryCurrent 2>/dev/null | sed 's/MemoryCurrent=//')"
for svc in $(systemctl list-units --type=service --state=active --no-legend 2>/dev/null | awk '{print $1}' | grep -v "^systemd\|^ssh\|^cron\|^snap\|^user@\|^dbus\|^polkit\|^unattended"); do
  status=$(systemctl is-active "$svc" 2>/dev/null)
  mem=$(systemctl show "$svc" --property=MemoryCurrent 2>/dev/null | sed 's/MemoryCurrent=//')
  echo "service:${svc}:status=${status}:memory=${mem}"
done

echo ""
echo "===SECTION:CRON_JOBS==="
echo "---crontab---"
crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" || echo "NO_CRONTAB"

echo ""
echo "===SECTION:CRON_HEALTH==="
# CUSTOMIZE: Add your cron job log paths here
# For each cron job, check log freshness and last lines
# Example:
# echo "---my_cron_job---"
# echo "last_log_lines:"
# tail -5 /var/log/my-cron-job.log 2>/dev/null || echo "NO_LOG_FILE"

echo ""
echo "===SECTION:ENV_VARS==="
# CUSTOMIZE: Check for critical env vars in your .env files
# Never print values — only check existence
# Example:
# if [ -f /opt/myapp/.env ]; then
#   echo "env_file_myapp=exists"
#   for var in DATABASE_URL API_KEY SECRET_TOKEN; do
#     if grep -q "^${var}=" /opt/myapp/.env 2>/dev/null; then
#       val=$(grep "^${var}=" /opt/myapp/.env | head -1 | sed "s/^${var}=//")
#       if [ -z "$val" ] || echo "$val" | grep -qi "PLACEHOLDER\|your_.*_here\|changeme"; then
#         echo "${var}=PLACEHOLDER"
#       else
#         echo "${var}=set"
#       fi
#     else
#       echo "${var}=MISSING"
#     fi
#   done
# else
#   echo "env_file_myapp=MISSING"
# fi

echo ""
echo "===SECTION:RECENT_ERRORS==="
# Journal errors (last 24h) — searches all services
echo "---journal_errors_24h---"
journalctl --since "24 hours ago" --no-pager -p err 2>/dev/null | tail -20 || echo "NO_ERRORS"

# OOM events (last 7 days)
echo "---oom_events_7d---"
journalctl --since "7 days ago" --no-pager | grep -i "oom\|out of memory\|killed process" | grep -v "sshd" | tail -10 || echo "NONE"

# SIGTERM/SIGKILL (last 24h)
echo "---signals_24h---"
journalctl --since "24 hours ago" --no-pager | grep -c "SIGTERM" | xargs -I{} echo "sigterm_count={}"
journalctl --since "24 hours ago" --no-pager | grep -c "SIGKILL" | xargs -I{} echo "sigkill_count={}"

# Timeout events (last 24h)
echo "---timeouts_24h---"
journalctl --since "24 hours ago" --no-pager | grep -c "timed out\|timeout" | xargs -I{} echo "timeout_count={}"

echo ""
echo "===SECTION:PROCESSES==="
echo "---top_memory---"
ps aux --sort=-%mem | head -6
echo "---node_processes---"
ps aux | grep "[n]ode" | awk '{printf "pid=%s mem_pct=%s rss_kb=%s cmd=%s\n", $2, $4, $6, $11}' || echo "NONE"

echo ""
echo "===SECTION:NETWORK==="
echo "dns_resolve=$(dig +short google.com | head -1 2>/dev/null || echo 'FAIL')"
echo "outbound_https=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 https://google.com 2>/dev/null || echo 'FAIL')"

echo ""
echo "===END_DIAGNOSTIC==="
