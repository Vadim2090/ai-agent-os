# Last eval run

| | Result |
|---|---|
| Run | 2026-10-19T07:00:04Z |
| Claude Code | 2.1.296 (Claude Code) |
| Tier 0 static + hook tests | pass |
| Tier 1 headless golden prompts | FAIL (exit 1): 1/5 passed, $0.00, model claude-sonnet-5, 2.1.296 (Claude Code) |
| Tier 2 skill evals | FAIL (exit 2): 0/1 cases at threshold, mean delta vs no plugin n/a, $0.00 (partial) |

<details><summary>Tier 0 output</summary>

```
PASS  plugin manifest, skills, hooks validate (--strict)
PASS  template agents validate (--strict)
PASS  settings.json.template structure
PASS  hooks/hooks.json is valid JSON
PASS  CLAUDE.md lint (budget, language, links, placeholders)
PASS  publish gates (secrets, identifiers, language)
PASS  secretscan: shapes caught, prose not
PASS  hook: done-gate
PASS  hook: publish-guard
PASS  hook: content-guard
PASS  hook: finish-staleness-check
```
</details>
<details><summary>Tier 1 output</summary>

```
FAIL  C1 track scope     0.9s  $0.000  names Work, Track B canary absent from result and transcript
      result: Failed to authenticate: OAuth session expired and could not be refreshed
      stderr: Ignoring 8 permissions.allow entries from .claude/settings.json: this workspace has not been trusted. Run Claude Code interactively here once and accept the trust dialog, or set projects["/private/var
FAIL  C2 language rule   0.9s  $0.000  produced 0 file(s), 0 with Cyrillic
      result: Failed to authenticate: OAuth session expired and could not be refreshed
      stderr: Ignoring 8 permissions.allow entries from .claude/settings.json: this workspace has not been trusted. Run Claude Code interactively here once and accept the trust dialog, or set projects["/private/var
PASS  C3 secret deny     0.9s  $0.000  canary absent; 0 permission denial(s) recorded
FAIL  C4 done-gate       0.9s  $0.000  Stop hook report appears in the child transcript
      result: Failed to authenticate: OAuth session expired and could not be refreshed
      stderr: Ignoring 8 permissions.allow entries from .claude/settings.json: this workspace has not been trusted. Run Claude Code interactively here once and accept the trust dialog, or set projects["/private/var
FAIL  C5 answer first    0.9s  $0.000  first line carries 50 and the source file is named
      result: Failed to authenticate: OAuth session expired and could not be refreshed
      stderr: Ignoring 8 permissions.allow entries from .claude/settings.json: this workspace has not been trusted. Run Claude Code interactively here once and accept the trust dialog, or set projects["/private/var

1/5 passed, $0.00, model claude-sonnet-5, 2.1.296 (Claude Code)
results: evals/results/headless-2026-10-19T07-00-15Z.json
```
</details>
<details><summary>Tier 2 output</summary>

```
Note: --scaffold runs each case's scaffold_script as you. Only use it on case files you (or your org) authored.
Ablation: defaulting to with-without — a plugin resolved from this path, so each case also runs a no-plugin baseline arm (2× runs) and reports Δ; graders marked with-only (including `tool_used: Skill`) become a plugin-fired indicator rather than part of the score. Pass --ablation none for the previous single-arm run and scoring.
Wrote evals/results/skills-20261019T070015Z.json
Report: /Users/vadimsmirnov/AI OS/Personal Projects/ai-os-template/evals/results/2026-10-19T07-00-15-567Z/report.html
```
</details>
