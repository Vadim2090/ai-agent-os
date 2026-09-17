#!/bin/bash
# done-gate: 4 planted hits found (leak in cwd, leak in a tool-written file outside cwd, secret in memory/,
# leak at the root top level); sibling track, archive/ and worktrees/ untouched; stop_hook_active passes.
set -u
cd "$(dirname "$0")/../.."
mkdir -p .tmp; T="$(mktemp -d "$PWD/.tmp/case.XXXXXX")"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/root/work/sub" "$T/root/memory" "$T/root/other" "$T/root/work/archive" "$T/root/work/.claude/worktrees/x"
printf '{"timestamp":"2020-01-01T00:00:00Z"}\n{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Write","input":{"file_path":"%s/root/other/tool.md","content":"x"}}]}}\n' "$T" > "$T/t.jsonl"
printf 'Clean.\nQuoted "\xd1\x82\xd0\xb5\xd0\xba\xd1\x81\xd1\x82" ok.\n(\xd1\x81\xd0\xbb\xd0\xbe\xd0\xb2\xd0\xbe) ok.\n' > "$T/root/work/ok.md"
printf '\xd1\x83\xd1\x82\xd0\xb5\xd1\x87\xd0\xba\xd0\xb0\n' > "$T/root/work/sub/leak.md"
printf 'k = AKIAABCDEFGHIJKLMNOP\n' > "$T/root/memory/secret.md"
printf '\xd1\x81\xd0\xbe\xd1\x81\xd0\xb5\xd0\xb4\n' > "$T/root/other/sibling.md"
printf '\xd1\x82\xd1\x83\xd0\xbb\n' > "$T/root/other/tool.md"
printf '\xd0\xb0\xd1\x80\xd1\x85\xd0\xb8\xd0\xb2\n' > "$T/root/work/archive/a.md"
printf '\xd0\xb4\xd0\xb5\xd1\x80\xd0\xb5\xd0\xb2\xd0\xbe\n' > "$T/root/work/.claude/worktrees/x/w.md"
printf '\xd0\xba\xd0\xbe\xd1\x80\xd0\xb5\xd0\xbd\xd1\x8c\n' > "$T/root/ROOT.md"
OUT=$(printf '{"transcript_path":"%s/t.jsonl","cwd":"%s/root/work"}' "$T" "$T" | AI_OS_PATH="$T/root" bash hooks/done-gate.sh 2>&1); RC=$?
[ "$RC" -eq 2 ] || { echo "  expected exit 2, got $RC"; exit 1; }
for want in "work/sub/leak.md" "memory/secret.md" "other/tool.md" "ROOT.md"; do grep -q "$want" <<< "$OUT" || { echo "  missing hit: $want"; echo "$OUT"; exit 1; }; done
for nowant in "sibling.md" "archive/a.md" "worktrees"; do grep -q "$nowant" <<< "$OUT" && { echo "  false hit: $nowant"; exit 1; }; done
[ "$(grep -c 'lines' <<< "$OUT")" -eq 4 ] || { echo "  expected exactly 4 hits"; echo "$OUT"; exit 1; }
printf '{"transcript_path":"%s/t.jsonl","cwd":"%s/root/work","stop_hook_active":true}' "$T" "$T" | AI_OS_PATH="$T/root" bash hooks/done-gate.sh >/dev/null 2>&1 || { echo "  stop_hook_active should pass"; exit 1; }
exit 0
