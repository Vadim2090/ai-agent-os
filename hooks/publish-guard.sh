#!/bin/bash
# Publish Guard — PreToolUse hook on Bash (2026-09-20)
# A Stop hook cannot guard a `git push` that happens in the middle of a turn; only a PreToolUse hook
# runs before the command does. Before any command that publishes a repository (git push,
# gh repo create --push, gh release create/upload, npm publish, git remote add) this scans the
# repository's tracked files for credentials by brand and by shape (secretscan.py next to this file)
# and for tracked .env files, and blocks the command (exit 2) with file:line. On a clean scan it tells
# the agent how many files it checked, so "clean" is a result, not an assumption.
# Non-publishing commands pass untouched. Born the day a parallel session created a public repo with
# `gh repo create --push` and nothing had checked its contents.
#
# Installation:
#   1. Copy publish-guard.sh and secretscan.py to ~/.claude/hooks/
#   2. Wire in settings.json:
#      "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/publish-guard.sh", "timeout": 60}]}]

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_INPUT="$(cat)"
export HOOK_INPUT HOOK_DIR
python3 - <<'PY'
import json, os, re, subprocess, sys

sys.path.insert(0, os.environ["HOOK_DIR"])
from secretscan import scan_file

inp = json.loads(os.environ.get("HOOK_INPUT") or "{}")
if inp.get("tool_name") != "Bash":
    sys.exit(0)
cmd = (inp.get("tool_input") or {}).get("command", "") or ""
PUBLISH = re.compile(r"(?:^|[;&|]\s*)(?:git\s+push\b|gh\s+repo\s+create\b[^;&|]*--push|gh\s+release\s+(?:create|upload)\b"
                     r"|npm\s+publish\b|git\s+remote\s+add\b)")
if not PUBLISH.search(cmd):
    sys.exit(0)

# The repository: a leading `cd <dir> &&` wins, otherwise the command's working directory.
repo = inp.get("cwd") or os.getcwd()
m = re.match(r"""\s*cd\s+("[^"]+"|'[^']+'|\S+)\s*(?:&&|;)""", cmd)
if m:
    repo = os.path.expanduser(os.path.expandvars(m.group(1).strip("\"'")))
try:
    top = subprocess.run(["git", "-C", repo, "rev-parse", "--show-toplevel"], capture_output=True, text=True, check=True).stdout.strip()
    tracked = [l for l in subprocess.run(["git", "-C", top, "ls-files", "--cached"], capture_output=True, text=True, check=True).stdout.split("\n") if l]
except Exception:
    sys.exit(0)  # not a repository: nothing to guard here

hits, env_files, scanned = [], [], 0
for relpath in tracked:
    base = os.path.basename(relpath)
    if re.match(r"\.env(\..+)?$", base) and not base.endswith(".example"):
        env_files.append(relpath)
    path = os.path.join(top, relpath)
    if not os.path.isfile(path):
        continue
    scanned += 1
    for n, kind in scan_file(path):
        hits.append((relpath, n, kind))

if hits or env_files:
    print(f"PUBLISH GUARD: blocked `{cmd.strip()[:80]}`. The repository at {top} would publish:", file=sys.stderr)
    for relpath, n, kind in hits[:30]:
        print(f"  {kind}: {relpath}:{n}", file=sys.stderr)
    for relpath in env_files:
        print(f"  tracked env file: {relpath}", file=sys.stderr)
    print("Remove or replace the values, rewrite history if they were committed, then retry.", file=sys.stderr)
    sys.exit(2)

print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
      "additionalContext": f"publish-guard: {scanned} tracked file(s) in {os.path.basename(top)} scanned for credentials before publishing, clean."}}))
sys.exit(0)
PY
