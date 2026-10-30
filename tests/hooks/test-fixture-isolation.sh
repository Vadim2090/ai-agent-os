#!/bin/bash
# Fixture isolation: when the fixture repository cannot be created (git init fails), test-publish-guard.sh
# must exit non-zero and leave the repository it was started from untouched. Runs the test inside a
# throwaway copy of the layout, so a regression damages the copy, never this checkout.
set -u
cd "$(dirname "$0")/../.." || exit 1
REAL_GIT="$(command -v git)" || { echo "  git not found"; exit 1; }
S="$(mktemp -d "${TMPDIR:-/tmp}/aios-iso.XXXXXX")" || exit 1; trap 'rm -rf "$S" 2>/dev/null || true' EXIT
[ -n "$S" ] && [ -d "$S" ] || { echo "  mktemp failed"; exit 1; }
mkdir -p "$S/repo/tests/hooks" "$S/repo/hooks" "$S/bin" || exit 1
cp tests/hooks/test-publish-guard.sh "$S/repo/tests/hooks/" && cp hooks/publish-guard.sh hooks/secretscan.py "$S/repo/hooks/" || exit 1
printf 'original\n' > "$S/repo/README.md" || exit 1
( cd "$S/repo" && git init -q --template= && git config user.email t@example.com && git config user.name t \
  && git add -A && git commit -qm base ) || { echo "  could not build the stand-in repository"; exit 1; }
HEAD_BEFORE="$(git -C "$S/repo" rev-parse HEAD)"
# A git whose init always fails; every other subcommand goes to the real git.
printf '#!/bin/bash\n[ "${1:-}" = init ] && exit 1\nexec "%s" "$@"\n' "$REAL_GIT" > "$S/bin/git" && chmod +x "$S/bin/git" || exit 1
PATH="$S/bin:$PATH" bash "$S/repo/tests/hooks/test-publish-guard.sh" >/dev/null 2>&1 && { echo "  git init failed but the test passed"; exit 1; }
[ "$(cat "$S/repo/README.md")" = original ] || { echo "  README.md of the starting repository was overwritten"; exit 1; }
[ "$(git -C "$S/repo" rev-parse HEAD)" = "$HEAD_BEFORE" ] || { echo "  a commit landed in the starting repository"; exit 1; }
[ -z "$(git -C "$S/repo" status --porcelain)" ] || { echo "  files were written into the starting repository"; git -C "$S/repo" status --short; exit 1; }
exit 0
