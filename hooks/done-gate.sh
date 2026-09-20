#!/bin/bash
# Done Gate — Stop hook (v3, 2026-09-20)
# Before the agent stops, re-checks what THIS session wrote:
#   1. language leak  — the chat language's script in prose the agent authored (default: Cyrillic).
#                       Quotes, backticks, parentheses and [link text] are ignored; a data file may waive
#                       the check with `lang-check: data` in its first 4 KB.
#   2. credentials    — by brand and by shape (see secretscan.py next to this file).
#
# What counts as "this session wrote": lines the Write and Edit tools produced (taken from the transcript,
# line by line) and files whose modification time falls inside one of this session's Bash commands
# (whole file, since a heredoc leaves no line map). A file another session changed is not reported.
#
# Memory: a finding blocks ONCE PER FINDING, not once per stop. On the block the agent has to look; when
# it continues (stop_hook_active) the findings still present are acknowledged in a journal with the
# agent's stated reason, keyed by path + a hash of the line. An acknowledged line never blocks again; a
# changed line is a new hash and blocks again; a line that disappears is pruned from the journal.
# The journal holds hashes and reasons, never the flagged text itself.
#
#   done-gate.sh --list          show acknowledged findings
#   done-gate.sh --forget PATH   drop the acknowledgements for one file
#   done-gate.sh --forget-all    empty the journal
#
# Revised 2026-09-17 after measuring it against the whole tree (580 .md files): unanchored `sk-` matched
# risk-/task-/desk-; the brand list missed every format this system actually holds; [link text] carried
# quoted titles; test fixtures plant fake secrets on purpose. Revised 2026-09-20: memory, line attribution,
# shape detection, after a session passed the gate three times with one phrase on a line it never wrote.
#
# Installation:
#   1. Copy done-gate.sh and secretscan.py to ~/.claude/hooks/
#   2. Wire in settings.json:
#      "Stop": [{"hooks": [{"type": "command", "command": "bash ~/.claude/hooks/done-gate.sh", "timeout": 30}]}]
#
# === CUSTOMIZE THESE ===
AI_OS_ROOT="${AI_OS_PATH:-$HOME/AI OS}"
LANGUAGE_LEAK_REGEX='[\U00000400-\U000004FF]'       # Python regex for the chat language's script; empty = disabled
TEXT_EXTENSIONS='md txt json yaml yml toml csv sh py js ts sql html css'
MAX_FILE_BYTES=2000000
DONE_GATE_STATE="${DONE_GATE_STATE:-$HOME/.claude/state/done-gate}"   # the journal lives here, outside the tree
# === END CUSTOMIZATION ===

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "${1:-}" in
  --list|--forget|--forget-all) MODE="$1"; ARG="${2:-}"; HOOK_INPUT="" ;;
  *) MODE="hook"; ARG=""; HOOK_INPUT="$(cat)" ;;
esac
export HOOK_INPUT AI_OS_ROOT LANGUAGE_LEAK_REGEX TEXT_EXTENSIONS MAX_FILE_BYTES DONE_GATE_STATE HOOK_DIR MODE ARG
python3 - <<'PY'
import hashlib, json, os, re, sys
from datetime import datetime, timezone

sys.path.insert(0, os.environ["HOOK_DIR"])
from secretscan import classify

mode, arg = os.environ["MODE"], os.environ["ARG"]
ai_root = os.path.realpath(os.path.expanduser(os.environ["AI_OS_ROOT"]))
state_dir = os.path.expanduser(os.environ["DONE_GATE_STATE"])
journal_path = os.path.join(state_dir, "acks.jsonl")

def load_journal():
    try:
        with open(journal_path, encoding="utf-8") as f:
            return [json.loads(l) for l in f if l.strip()]
    except (OSError, ValueError):
        return []

def save_journal(entries):
    os.makedirs(state_dir, exist_ok=True)
    tmp = journal_path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        for e in entries:
            f.write(json.dumps(e, ensure_ascii=False) + "\n")
    os.replace(tmp, journal_path)

def rel(path):
    r = os.path.relpath(path, ai_root)
    return path if r.startswith("..") else r

# ---------------------------------------------------------------- CLI modes
if mode == "--list":
    entries = load_journal()
    if not entries:
        print("done-gate: no acknowledged findings")
    for e in entries:
        print(f"{rel(e['path'])}  {e['kind']}  hash {e['line_hash']}  acked {e['acked_at'][:10]}  {e.get('reason', '')[:100]}")
    sys.exit(0)
if mode == "--forget-all":
    n = len(load_journal()); save_journal([]); print(f"done-gate: forgot {n} finding(s)"); sys.exit(0)
if mode == "--forget":
    target = os.path.realpath(os.path.expanduser(arg))
    entries = load_journal()
    keep = [e for e in entries if e["path"] != target and not e["path"].endswith("/" + arg)]
    save_journal(keep); print(f"done-gate: forgot {len(entries) - len(keep)} finding(s) for {arg}"); sys.exit(0)

# ---------------------------------------------------------------- hook mode
inp = json.loads(os.environ.get("HOOK_INPUT") or "{}")
cwd = os.path.realpath(inp.get("cwd") or os.getcwd())
transcript = os.path.expanduser(inp.get("transcript_path", ""))
session_id = inp.get("session_id", "")
exts = set(os.environ["TEXT_EXTENSIONS"].split())
max_bytes = int(os.environ["MAX_FILE_BYTES"])
skip_dirs = {".git", "node_modules", ".venv", "venv", "__pycache__", "archive", "worktrees",
             "tests", "test", "fixtures", "evals", ".tmp"}

def is_text(path):
    ext = path.rsplit(".", 1)[-1].lower() if "." in os.path.basename(path) else ""
    return ext in exts

def is_test_fixture(path):
    base = os.path.basename(path).lower()
    return (base.startswith(("test-", "test_")) or base.rsplit(".", 1)[0].endswith(("_test", "-test"))
            or any(seg in ("tests", "test", "fixtures", "evals", ".tmp") for seg in path.split(os.sep)))

def lang_exempt(path):
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return "lang-check: data" in f.read(4000)
    except OSError:
        return False

def ts(entry):
    t = entry.get("timestamp")
    if not t:
        return None
    try:
        return datetime.fromisoformat(t.replace("Z", "+00:00")).timestamp()
    except ValueError:
        return None

# 1. From the transcript: lines the Write/Edit tools produced, this session's Bash intervals, the last
#    assistant text (the stated reason when a block is acknowledged).
authored, bash_start, intervals, last_text = {}, {}, [], ""
try:
    with open(transcript, "r", encoding="utf-8", errors="ignore") as f:
        for raw in f:
            try:
                entry = json.loads(raw)
            except ValueError:
                continue
            when = ts(entry)
            content = (entry.get("message") or {}).get("content")
            if not isinstance(content, list):
                continue
            texts = []
            for block in content:
                if not isinstance(block, dict):
                    continue
                btype = block.get("type")
                if btype == "tool_use":
                    name, args = block.get("name"), block.get("input") or {}
                    if name in ("Write", "Edit", "MultiEdit") and args.get("file_path"):
                        path = os.path.realpath(os.path.expanduser(args["file_path"]))
                        lines = authored.setdefault(path, set())
                        body = args.get("content") if name == "Write" else args.get("new_string", "")
                        for edit in args.get("edits", []) or []:          # MultiEdit
                            body = (body or "") + "\n" + (edit.get("new_string") or "")
                        for l in (body or "").splitlines():
                            if l.strip():
                                lines.add(l.strip())
                    elif name == "NotebookEdit" and args.get("notebook_path"):
                        authored.setdefault(os.path.realpath(os.path.expanduser(args["notebook_path"])), set())
                    elif name == "Bash" and when is not None:
                        bash_start[block.get("id")] = when
                elif btype == "tool_result" and block.get("tool_use_id") in bash_start and when is not None:
                    intervals.append((bash_start.pop(block["tool_use_id"]) - 2, when + 5))
                elif btype == "text" and entry.get("type") == "assistant" and block.get("text"):
                    texts.append(block["text"])
            if texts:
                last_text = "\n".join(texts)
except OSError:
    pass
now = datetime.now(timezone.utc).timestamp()
for start in bash_start.values():                     # commands still running at this stop
    intervals.append((start - 2, now + 5))

def bash_written(path):
    try:
        m = os.stat(path).st_mtime
    except OSError:
        return False
    return any(a <= m <= b for a, b in intervals)

# 2. Candidates: files this session wrote through a tool (only their authored lines) and files a Bash
#    command of this session modified under the working directory, <AI OS>/memory and the top level.
candidates = {}                                        # path -> set of authored lines, or None = whole file
for path, lines in authored.items():
    candidates[path] = lines or None
def walk(top):
    for dirpath, dirnames, filenames in os.walk(top):
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for fn in filenames:
            p = os.path.realpath(os.path.join(dirpath, fn))
            if is_text(p) and bash_written(p):
                candidates[p] = None
walk(cwd)
walk(os.path.join(ai_root, "memory"))
try:
    for fn in os.listdir(ai_root):
        p = os.path.join(ai_root, fn)
        if os.path.isfile(p) and is_text(p) and bash_written(p):
            candidates[os.path.realpath(p)] = None
except OSError:
    pass

leak = os.environ.get("LANGUAGE_LEAK_REGEX", "")
leak_re = re.compile(leak) if leak else None
quoted_re = re.compile(r'"[^"\n]*"|«[^»\n]*»|`[^`\n]*`|\([^()\n]*\)|\[[^\]\n]*\]')

def line_hash(line):
    return hashlib.sha1(line.strip().encode("utf-8")).hexdigest()[:16]

findings = []                                          # (path, line_no, kind, hash)
scanned = set()
for path, only in sorted(candidates.items()):
    if not is_text(path) or is_test_fixture(path):
        continue
    try:
        if os.path.getsize(path) > max_bytes:
            continue
        check_lang = bool(leak_re) and not lang_exempt(path)
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            scanned.add(path)
            for n, line in enumerate(f, 1):
                if only is not None and line.strip() not in only:
                    continue
                kind = classify(line)
                if not kind and check_lang and leak_re.search(quoted_re.sub("", line)):
                    kind = "language leak"
                if kind:
                    findings.append((path, n, kind, line_hash(line)))
    except OSError:
        continue

# 3. Memory: drop acknowledged findings, prune acknowledgements whose line is gone.
journal = load_journal()
current = {(p, h) for p, _, _, h in findings}
journal = [e for e in journal if not (e["path"] in scanned and (e["path"], e["line_hash"]) not in current)]
acked = {(e["path"], e["line_hash"]) for e in journal}
new = [f for f in findings if (f[0], f[3]) not in acked]
if len(journal) != len(load_journal()):
    save_journal(journal)

if not new:
    sys.exit(0)

if inp.get("stop_hook_active"):
    # The agent looked and continued: acknowledge what is still there, with its stated reason.
    reason = " ".join(last_text.split())[:240]
    stamp = datetime.now(timezone.utc).isoformat(timespec="seconds")
    for p, n, kind, h in new:
        journal.append({"path": p, "line_hash": h, "kind": kind, "line_at_ack": n, "acked_at": stamp,
                        "session": session_id, "reason": reason})
    save_journal(journal)
    sys.exit(0)

print("DONE GATE: lines this session wrote fail the file checks. Fix them, or say in one line why the "
      "content is legitimate, then finish; what you leave in place is acknowledged and never blocks again "
      "unless the line changes.", file=sys.stderr)
by_file = {}
for p, n, kind, h in new:
    by_file.setdefault((p, kind), []).append(n)
for (p, kind), lines in sorted(by_file.items()):
    shown = ", ".join(str(x) for x in lines[:8]) + (" ..." if len(lines) > 8 else "")
    print(f"  {kind}: {rel(p)} lines {shown}", file=sys.stderr)
if acked:
    print(f"  ({len(acked)} acknowledged finding(s) not shown; done-gate.sh --list)", file=sys.stderr)
sys.exit(2)
PY
