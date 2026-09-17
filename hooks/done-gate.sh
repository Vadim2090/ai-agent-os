#!/bin/bash
# Done Gate — Stop hook
# Re-runs the file checks on what this session touched:
#   1. language leak  — the chat language's script inside files the agent authors (default: Cyrillic).
#                       Text inside quotes, backticks and parentheses is ignored, so quoted source
#                       material passes.
#   2. secret pattern — API keys, tokens, private keys.
# Files judged: every file the Write/Edit tools touched (from the transcript) plus every text file
# modified since session start under the session's working directory, under <AI OS>/memory, and at the
# top level of <AI OS>. Sibling tracks are not scanned.
# On failure it blocks the stop ONCE (exit 2) and lists file:line, so the agent has to look.
# The second stop passes (stop_hook_active), so a legitimate exception never loops.
#
# Installation:
#   1. Copy to ~/.claude/hooks/
#   2. Wire in settings.json:
#      "Stop": [{"hooks": [{"type": "command", "command": "bash ~/.claude/hooks/done-gate.sh", "timeout": 30}]}]
#
# === CUSTOMIZE THESE ===
AI_OS_ROOT="${AI_OS_PATH:-$HOME/AI OS}"
LANGUAGE_LEAK_REGEX='[\U00000400-\U000004FF]'       # Python regex for the chat language's script; empty = disabled
TEXT_EXTENSIONS='md txt json yaml yml toml csv sh py js ts sql html css'
MAX_FILE_BYTES=2000000
# === END CUSTOMIZATION ===

HOOK_INPUT="$(cat)"
export HOOK_INPUT AI_OS_ROOT LANGUAGE_LEAK_REGEX TEXT_EXTENSIONS MAX_FILE_BYTES
python3 - <<'PY'
import json, os, re, sys
from datetime import datetime

inp = json.loads(os.environ.get("HOOK_INPUT") or "{}")
if inp.get("stop_hook_active"):
    sys.exit(0)  # this stop was already blocked once; let it through

ai_root = os.path.realpath(os.path.expanduser(os.environ["AI_OS_ROOT"]))
cwd = os.path.realpath(inp.get("cwd") or os.getcwd())
transcript = os.path.expanduser(inp.get("transcript_path", ""))
exts = set(os.environ["TEXT_EXTENSIONS"].split())
max_bytes = int(os.environ["MAX_FILE_BYTES"])
skip_dirs = {".git", "node_modules", ".venv", "venv", "__pycache__", "archive", "worktrees"}

def is_text(path):
    ext = path.rsplit(".", 1)[-1].lower() if "." in os.path.basename(path) else ""
    return ext in exts

# 1. Session start and the files the Write/Edit tools touched, both from the transcript.
start, touched = None, set()
try:
    with open(transcript, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            try:
                entry = json.loads(line)
            except Exception:
                continue
            if start is None and entry.get("timestamp"):
                start = datetime.fromisoformat(entry["timestamp"].replace("Z", "+00:00")).timestamp()
            stack = [entry]
            while stack:
                node = stack.pop()
                if isinstance(node, dict):
                    if node.get("type") == "tool_use" and node.get("name") in ("Write", "Edit", "MultiEdit", "NotebookEdit"):
                        p = (node.get("input") or {}).get("file_path") or (node.get("input") or {}).get("notebook_path")
                        if p:
                            touched.add(os.path.realpath(os.path.expanduser(p)))
                    stack.extend(node.values())
                elif isinstance(node, list):
                    stack.extend(node)
except OSError:
    pass
if start is None:
    try:
        start = os.path.getmtime(transcript)
    except OSError:
        sys.exit(0)

# 2. Text files modified since session start: the working directory tree, <AI OS>/memory, <AI OS> top level.
candidates = set(touched)
def walk(top):
    for dirpath, dirnames, filenames in os.walk(top):
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for fn in filenames:
            candidates.add(os.path.realpath(os.path.join(dirpath, fn)))
walk(cwd)
walk(os.path.join(ai_root, "memory"))
try:
    for fn in os.listdir(ai_root):
        p = os.path.join(ai_root, fn)
        if os.path.isfile(p):
            candidates.add(os.path.realpath(p))
except OSError:
    pass

leak = os.environ.get("LANGUAGE_LEAK_REGEX", "")
leak_re = re.compile(leak) if leak else None
quoted_re = re.compile(r'"[^"\n]*"|«[^»\n]*»|`[^`\n]*`|\([^()\n]*\)')
secret_re = re.compile(
    r"(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}"
    r"|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----)"
)

violations = {}
for path in sorted(candidates):
    if not is_text(path):
        continue
    try:
        st = os.stat(path)
    except OSError:
        continue
    if st.st_size > max_bytes or (path not in touched and st.st_mtime < start):
        continue
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for n, line in enumerate(f, 1):
                if secret_re.search(line):
                    violations.setdefault((path, "secret pattern"), []).append(n)
                elif leak_re and leak_re.search(quoted_re.sub("", line)):
                    violations.setdefault((path, "language leak"), []).append(n)
    except OSError:
        continue

if not violations:
    sys.exit(0)
print("DONE GATE: files touched this session fail the file checks. Fix them, or say in one line why the "
      "content is legitimate (quoted source material), then finish.", file=sys.stderr)
for (path, kind), lines in sorted(violations.items()):
    shown = ", ".join(str(x) for x in lines[:8]) + (" ..." if len(lines) > 8 else "")
    rel = os.path.relpath(path, ai_root)
    print(f"  {kind}: {path if rel.startswith('..') else rel} lines {shown}", file=sys.stderr)
sys.exit(2)
PY
