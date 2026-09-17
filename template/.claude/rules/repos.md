---
paths:
  - "**/repo-*/**"
---
# Code repositories (`repo-*` folders)

Loaded when a file inside a `repo-*` folder is read.

- The `repo-` prefix promises a git checkout. Run `git rev-parse --is-inside-work-tree` before any git
  operation; if it fails, say so and stop.
- Read the repo's own `README` and `CLAUDE.md` before editing. Inside the repo its conventions win over this file.
- Never stage a secret: `.env*`, keys, tokens, service-account files. Check `git diff --cached` before every commit.
- Commit only when asked. Message in English: imperative subject under 72 characters, body says why.
- Run the repo's tests before reporting a change as done. If there are none, say so in the first line.
- A server copy may be ahead of the checkout. Before deploying or overwriting it, diff in both directions.
