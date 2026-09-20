#!/bin/bash
# Done Gate — Stop hook
# Re-runs the file checks on what this session touched:
#   1. language leak  — the chat language's script inside files the agent authors (default: Cyrillic).
#                       Text inside quotes, backticks and parentheses is ignored, so quoted source
#                       material passes.
#   2. secret pattern — API keys, tokens, private keys.
#
# Revised 2026-09-17 after measuring it against the whole tree (580 .md files):
#   - the secret regex fired 13 times and every hit was false. `sk-` was unanchored, so any
#     word ending in "sk" before a hyphen matched: risk-, ask-, task-, desk-. Now \b-anchored.
#   - it also looked for none of the credential formats this system actually holds. Added
#     Notion ntn_, any Bearer token, api_key=/token=/access_token= with a real value, the Exa
#     apiKey UUID and the Make webhook id. Verified: 6/6 real formats caught, 0 false positives.
#   - the language check treated "…", «…», `…` and (…) as quoted but not [markdown link text],
#     which is exactly where Russian Notion task titles live. Adding [ … ] took the always-
#     scanned memory/ files from 13 violations to 5.
#   - test fixtures plant fake secrets on purpose, so tests/ and test-* files are skipped.
# Known residual: a few bare foreign-script terms in memory/*.md still trip the language check.
# Those files are the operator's, not agent-authored; the real fix is to block only transcript-touched
# files and merely report the rest.
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
skip_dirs = {".git", "node_modules", ".venv", "venv", "__pycache__", "archive", "worktrees",
             "tests", "test", "fixtures", "evals", ".tmp"}

def is_text(path):
    ext = path.rsplit(".", 1)[-1].lower() if "." in os.path.basename(path) else ""
    return ext in exts

def lang_exempt(path):
    # A file may waive the LANGUAGE check by saying so in its own first 4 KB.
    # Added 2026-09-20: a stop-word list and a marker regex in another language are
    # data the code matches against, not prose the agent wrote — the same standing as
    # quoted source material, but spread over lines that carry no quotes of their own.
    # Declared in the file, so a reader meets the reason where the Cyrillic is.
    # The SECRET check still runs: this waives one rule, not the gate.
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return "lang-check: data" in f.read(4000)
    except OSError:
        return False

def is_test_fixture(path):
    # A fixture plants fake credentials on purpose; flagging it teaches you to ignore the gate.
    base = os.path.basename(path).lower()
    return (base.startswith(("test-", "test_")) or base.rsplit(".", 1)[0].endswith(("_test", "-test"))
            or any(seg in ("tests", "test", "fixtures", "evals", ".tmp") for seg in path.split(os.sep)))

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
quoted_re = re.compile(r'"[^"\n]*"|«[^»\n]*»|`[^`\n]*`|\([^()\n]*\)|\[[^\]\n]*\]')
secret_re = re.compile(
    r"(\bsk-[A-Za-z0-9_-]{20,}"                      # OpenAI — \b or "risk-"/"task-" match
    r"|\bntn_[A-Za-z0-9]{40,}"                       # Notion integration
    r"|AKIA[0-9A-Z]{16}"                             # AWS
    r"|\bghp_[A-Za-z0-9]{36}|\bgithub_pat_[A-Za-z0-9_]{22,}"
    r"|\bxox[abprs]-[A-Za-z0-9-]{10,}"               # Slack
    r"|\bAIza[0-9A-Za-z_-]{35}"                      # Google
    r"|-----BEGIN [A-Z ]*PRIVATE KEY-----"
    r"|[Bb]earer\s+[A-Za-z0-9_\-\.]{20,}"            # any bearer token
    r"|(?:api[_-]?key|apikey|access[_-]?token|auth[_-]?token|[Tt]oken)=[A-Za-z0-9_\-]{20,}"
    r"|[Aa]pi[Kk]ey=[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"  # Exa
    r"|make\.com/mcp/server/[0-9a-f]{8}-[0-9a-f]{4}"                               # Make webhook
    r")"
)

violations = {}
for path in sorted(candidates):
    if not is_text(path) or is_test_fixture(path):
        continue
    try:
        st = os.stat(path)
    except OSError:
        continue
    if st.st_size > max_bytes or (path not in touched and st.st_mtime < start):
        continue
    check_lang = bool(leak_re) and not lang_exempt(path)
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for n, line in enumerate(f, 1):
                if secret_re.search(line):
                    violations.setdefault((path, "secret pattern"), []).append(n)
                elif check_lang and leak_re.search(quoted_re.sub("", line)):
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
