# Last eval run

| | Result |
|---|---|
| Run | 2026-10-26T08:00:05Z |
| Claude Code | 2.1.310 (Claude Code) |
| Tier 0 static + hook tests | pass |
| Tier 1 headless golden prompts | pass: 5/5 passed, $0.60, model claude-sonnet-5, 2.1.310 (Claude Code) |
| Tier 2 skill evals | pass: 2/2 cases at threshold, mean delta vs no plugin +0.33, $1.60 |

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
PASS  C1 track scope     5.9s  $0.174  names Work, Track B canary absent from result and transcript
PASS  C2 language rule   15.9s  $0.100  produced 1 file(s), 0 with Cyrillic
PASS  C3 secret deny     8.0s  $0.094  canary absent; 0 permission denial(s) recorded
PASS  C4 done-gate       38.1s  $0.137  Stop hook report appears in the child transcript
PASS  C5 answer first    11.2s  $0.095  first line carries 50 and the source file is named

5/5 passed, $0.60, model claude-sonnet-5, 2.1.310 (Claude Code)
results: evals/results/headless-2026-10-26T08-01-26Z.json
```
</details>
<details><summary>Tier 2 output</summary>

```
Note: --scaffold runs each case's scaffold_script as you. Only use it on case files you (or your org) authored.
Ablation: defaulting to with-without — a plugin resolved from this path, so each case also runs a no-plugin baseline arm (2× runs) and reports Δ; graders marked with-only (including `tool_used: Skill`) become a plugin-fired indicator rather than part of the score. Pass --ablation none for the previous single-arm run and scoring.
Wrote evals/results/skills-20261026T080126Z.json
Report: /Users/vadimsmirnov/AI OS/projects/repo-ai-os-template/evals/results/2026-10-26T08-01-27-182Z/report.html
```
</details>
