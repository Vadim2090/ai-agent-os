#!/bin/bash
# done-gate v3: only lines this session wrote count (Write/Edit lines from the transcript, whole files a
# Bash command of this session modified); a finding blocks once, the continuation acknowledges it in the
# journal with the agent's reason, a changed line blocks again, --list / --forget-all work.
set -u
cd "$(dirname "$0")/../.."
export TZ=UTC
# Fixtures live in .scratch/, not tests/ or .tmp/: the gate skips those on purpose.
mkdir -p .scratch; T="$(mktemp -d "$PWD/.scratch/case.XXXXXX")"; trap 'rm -rf "$T"' EXIT
export DONE_GATE_STATE="$T/state"
R="$T/root"; mkdir -p "$R/work/sub" "$R/memory" "$R/other"
# notes.md: the Write tool produced lines 1-2; line 3 was already there and is not this session's
printf 'Clean line\n\xd1\x83\xd1\x82\xd0\xb5\xd1\x87\xd0\xba\xd0\xb0 authored\n\xd1\x81\xd1\x82\xd0\xb0\xd1\x80\xd0\xb0\xd1\x8f not authored\n' > "$R/work/notes.md"
# secret.md: modified inside this session's Bash interval (00:10:00-00:10:30) -> whole file counts
printf 'k = AKIAABCDEFGHIJKLMNOP\n' > "$R/memory/secret.md"; touch -t 202001010010.15 "$R/memory/secret.md"
# old.md: a leak modified long before any Bash command of this session -> not this session's
printf '\xd1\x81\xd1\x82\xd0\xb0\xd1\x80\xd0\xbe\xd0\xb5\n' > "$R/work/old.md"; touch -t 201912310000 "$R/work/old.md"
# sibling track: never scanned even inside the interval
printf '\xd1\x81\xd0\xbe\xd1\x81\xd0\xb5\xd0\xb4\n' > "$R/other/sibling.md"; touch -t 202001010010.20 "$R/other/sibling.md"
{
  printf '{"type":"user","timestamp":"2020-01-01T00:00:00Z","message":{"role":"user","content":[{"type":"text","text":"start"}]}}\n'
  printf '{"type":"assistant","timestamp":"2020-01-01T00:05:00Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"w1","name":"Write","input":{"file_path":"%s/work/notes.md","content":"Clean line\\n\xd1\x83\xd1\x82\xd0\xb5\xd1\x87\xd0\xba\xd0\xb0 authored\\n"}}]}}\n' "$R"
  printf '{"type":"assistant","timestamp":"2020-01-01T00:10:00Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"b1","name":"Bash","input":{"command":"echo"}}]}}\n'
  printf '{"type":"user","timestamp":"2020-01-01T00:10:30Z","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"b1","content":"ok"}]}}\n'
  printf '{"type":"assistant","timestamp":"2020-01-01T00:20:00Z","message":{"role":"assistant","content":[{"type":"text","text":"Legitimate: quoted source material in a data file."}]}}\n'
} > "$T/t.jsonl"
J="{\"transcript_path\":\"$T/t.jsonl\",\"cwd\":\"$R/work\",\"session_id\":\"s1\"}"
# 1. first stop: blocks on the authored leak and the Bash-written secret only
OUT=$(printf '%s' "$J" | AI_OS_PATH="$R" bash hooks/done-gate.sh 2>&1); RC=$?
[ "$RC" -eq 2 ] || { echo "  run 1: expected exit 2, got $RC"; echo "$OUT"; exit 1; }
grep -q 'work/notes.md lines 2$' <<< "$OUT" || { echo "  run 1: notes.md line 2 (authored) missing or extra lines listed"; echo "$OUT"; exit 1; }
grep -q 'memory/secret.md lines 1' <<< "$OUT" || { echo "  run 1: Bash-written secret.md missing"; echo "$OUT"; exit 1; }
grep -q -E 'old.md|sibling.md' <<< "$OUT" && { echo "  run 1: reported a file this session did not write"; echo "$OUT"; exit 1; }
# 2. the continuation acknowledges what is still there, with the agent's stated reason
printf '%s' "${J%\}},\"stop_hook_active\":true}" | AI_OS_PATH="$R" bash hooks/done-gate.sh >/dev/null 2>&1 || { echo "  run 2: continuation should pass"; exit 1; }
[ "$(wc -l < "$T/state/acks.jsonl" | tr -d ' ')" -eq 2 ] || { echo "  run 2: expected 2 journal entries"; cat "$T/state/acks.jsonl"; exit 1; }
grep -q 'Legitimate: quoted' "$T/state/acks.jsonl" || { echo "  run 2: reason not captured"; exit 1; }
grep -q 'AKIA' "$T/state/acks.jsonl" && { echo "  run 2: the journal must not store the flagged text"; exit 1; }
# 3. a fresh stop with the same findings passes silently
printf '%s' "$J" | AI_OS_PATH="$R" bash hooks/done-gate.sh >/dev/null 2>&1 || { echo "  run 3: acknowledged findings should not block"; exit 1; }
# 4. the acknowledged line changes -> new hash -> blocks again; the untouched acknowledgement is kept
printf 'Clean line\n\xd1\x83\xd1\x82\xd0\xb5\xd1\x87\xd0\xba\xd0\xb0 authored and changed\n' > "$R/work/notes.md"
printf '{"type":"assistant","timestamp":"2020-01-01T00:30:00Z","message":{"role":"assistant","content":[{"type":"tool_use","id":"e1","name":"Edit","input":{"file_path":"%s/work/notes.md","old_string":"authored","new_string":"\xd1\x83\xd1\x82\xd0\xb5\xd1\x87\xd0\xba\xd0\xb0 authored and changed"}}]}}\n' "$R" >> "$T/t.jsonl"
OUT=$(printf '%s' "$J" | AI_OS_PATH="$R" bash hooks/done-gate.sh 2>&1); RC=$?
[ "$RC" -eq 2 ] || { echo "  run 4: changed line should block again, got $RC"; echo "$OUT"; exit 1; }
grep -q 'notes.md lines 2' <<< "$OUT" || { echo "  run 4: changed line not reported"; echo "$OUT"; exit 1; }
grep -q 'secret.md' <<< "$OUT" && { echo "  run 4: acknowledged secret.md must not be re-reported"; echo "$OUT"; exit 1; }
grep -q '1 acknowledged' <<< "$OUT" || { echo "  run 4: acknowledged count missing"; echo "$OUT"; exit 1; }
# 5. CLI
bash hooks/done-gate.sh --list | grep -q 'secret.md' || { echo "  --list should show the acknowledged file"; exit 1; }
bash hooks/done-gate.sh --forget-all | grep -q 'forgot' || { echo "  --forget-all failed"; exit 1; }
exit 0
