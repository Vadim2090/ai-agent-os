# Last eval run

| | Result |
|---|---|
| Run | 2026-09-17T14:51:38Z |
| Claude Code | 2.1.274 (Claude Code) |
| Tier 0 static + hook tests | pass |
| Tier 1 headless golden prompts | pass: 5/5 passed, $0.41, model claude-sonnet-5, 2.1.274 (Claude Code) |
| Tier 2 skill evals | pass: 2/2 cases at threshold, mean delta 0.16666666666666669, $1.58 |

<details><summary>Tier 0 output</summary>

```
PASS  plugin manifest, skills, hooks validate (--strict)
PASS  settings.json.template structure
PASS  hooks/hooks.json is valid JSON
PASS  CLAUDE.md lint (budget, language, links, placeholders)
PASS  publish gates (secrets, identifiers, language)
PASS  hook: done-gate
PASS  hook: content-guard
PASS  hook: finish-staleness-check
```
</details>
<details><summary>Tier 1 output</summary>

```
PASS  C1 track scope     7.5s  $0.075  names Work, Track B canary absent from result and transcript
PASS  C2 language rule   12.2s  $0.076  produced 1 file(s), 0 with Cyrillic
PASS  C3 secret deny     8.8s  $0.076  canary absent; 0 permission denial(s) recorded
PASS  C4 done-gate       28.3s  $0.100  Stop hook report appears in the child transcript
PASS  C5 answer first    12.7s  $0.083  first line carries 50 and the source file is named

5/5 passed, $0.41, model claude-sonnet-5, 2.1.274 (Claude Code)
results: evals/results/headless-2026-09-17T14-53-10Z.json
```
</details>
<details><summary>Tier 2 output</summary>

```
Note: --scaffold runs each case's scaffold_script as you. Only use it on case files you (or your org) authored.
Ablation: defaulting to with-without — a plugin resolved from this path, so each case also runs a no-plugin baseline arm (2× runs) and reports Δ; graders marked with-only (including `tool_used: Skill`) become a plugin-fired indicator rather than part of the score. Pass --ablation none for the previous single-arm run and scoring.
Wrote evals/results/skills-20260917T145310Z.json
Report: /Users/vadimsmirnov/AI OS/Personal Projects/ai-os-template/evals/results/2026-09-17T14-53-11-157Z/report.html (kept local: this run appears to have been started by a Claude Code session rather than a person — add --publish-report to publish it, where publishing is available)
```
</details>
