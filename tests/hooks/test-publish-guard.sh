#!/bin/bash
# publish-guard: a push from a repository with a credential or a tracked .env is blocked (exit 2) with
# file:line; a clean repository passes with a "scanned, clean" context line; other commands pass at once.
set -u
cd "$(dirname "$0")/../.." || exit 1
HOOK="$PWD/hooks/publish-guard.sh"
# The fixture repository lives in the temp dir: inside the working tree the sandbox refuses to write .git/config.
T="$(mktemp -d "${TMPDIR:-/tmp}/aios-pg.XXXXXX")" || exit 1; trap 'rm -rf "$T" 2>/dev/null || true' EXIT
# Every step below writes and commits files in $PWD. If any setup step fails, stop: never fall through to the
# real repository (that is how a failed git init once replaced README.md with "hello" and committed it).
[ -n "$T" ] && [ -d "$T" ] || { echo "  mktemp failed"; exit 1; }
git init -q --template= "$T/repo" || { echo "  git init failed"; exit 1; }
cd "$T/repo" || exit 1
T="$(cd "$T" && pwd -P)"; case "$(pwd -P)" in "$T"/*) ;; *) echo "  not inside the temp dir: $PWD"; exit 1 ;; esac
git rev-parse --show-toplevel | grep -qxF "$(pwd -P)" || { echo "  fixture is not its own repository"; exit 1; }
git config user.email t@example.com || exit 1
git config user.name t || exit 1
printf 'PIPEDRIVE_API_TOKEN=0123456789abcdef0123456789abcdef01234567\n' > config.md
printf 'hello\n' > README.md; mkdir -p tests; printf 'AKIAABCDEFGHIJKLMNOP\n' > tests/fixture.md; git add -A; git commit -qm init
printf '{"tool_name":"Bash","tool_input":{"command":"ls -la"},"cwd":"%s"}' "$PWD" | bash "$HOOK" >/dev/null 2>&1 || { echo "  a non-publishing command must pass"; exit 1; }
OUT=$(printf '{"tool_name":"Bash","tool_input":{"command":"git push origin main"},"cwd":"%s"}' "$PWD" | bash "$HOOK" 2>&1); RC=$?
[ "$RC" -eq 2 ] || { echo "  push with a credential should exit 2, got $RC"; echo "$OUT"; exit 1; }
grep -q 'config.md:1' <<< "$OUT" || { echo "  file:line missing"; echo "$OUT"; exit 1; }
OUT=$(printf '{"tool_name":"Bash","tool_input":{"command":"cd \\"%s\\" && gh repo create demo --public --push"},"cwd":"/"}' "$PWD" | bash "$HOOK" 2>&1); RC=$?
[ "$RC" -eq 2 ] || { echo "  cd-prefixed gh repo create --push should be scanned, got $RC"; echo "$OUT"; exit 1; }
printf 'no secrets here\n' > config.md; git commit -qam fix
OUT=$(printf '{"tool_name":"Bash","tool_input":{"command":"git push origin main"},"cwd":"%s"}' "$PWD" | bash "$HOOK" 2>&1); RC=$?
[ "$RC" -eq 0 ] || { echo "  clean repository should pass, got $RC"; echo "$OUT"; exit 1; }
grep -q 'clean; 1 test fixture(s) skipped' <<< "$OUT" || { echo "  clean scan should report itself and the skipped fixture"; echo "$OUT"; exit 1; }
# A sandboxed session denies every .env file to Bash (the deny rules merge into the sandbox), so this
# last case runs only where the file can be staged; elsewhere it is skipped and says so.
if printf 'X=1\n' > .env 2>/dev/null && git add .env >/dev/null 2>&1; then
  git commit -qm env
  OUT=$(printf '{"tool_name":"Bash","tool_input":{"command":"git push"},"cwd":"%s"}' "$PWD" | bash "$HOOK" 2>&1); RC=$?
  [ "$RC" -eq 2 ] && grep -q 'tracked env file' <<< "$OUT" || { echo "  a tracked .env should block"; echo "$OUT"; exit 1; }
else
  echo "  (.env case skipped: this environment denies .env files to the shell)"
fi
exit 0
