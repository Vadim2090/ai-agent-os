# AI Agent Operating Principles

Reference framework for how we build and maintain our AI operating system.
All AI OS decisions, skills, and workflows should align with these principles.

---

## The 5 Principles

| # | Principle | In Plain English |
|---|-----------|-----------------|
| 1 | **Make everything visible to the agent** | All decisions, plans, and context must live in the project files — not in Slack, not in someone's head |
| 2 | **Diagnose the environment, not the model** | When the agent fails, don't blame the AI — fix what's missing in the tooling/docs |
| 3 | **Mechanically enforce structure** | Don't just write rules — build automated checks that physically prevent violations |
| 4 | **Give the agent sensory access** | Let agents see the results of their work (logs, screenshots, metrics) so they can self-correct |
| 5 | **Provide a map, not a manual** | Brief architecture overview + boundaries > exhaustive documentation |

## Three Pillars

1. **Context Engineering** — The repo is the single source of truth. If it's not in agent-visible files, it doesn't exist.
2. **Architectural Constraints** — Rules enforced by hooks and scripts that physically prevent violations.
3. **Entropy Management** — Session protocol and memory hierarchy prevent context drift over time.

---

## How to Apply This

When evaluating any AI OS change, ask:

- **P1**: Can the agent see everything it needs without asking me?
- **P2**: When something broke, did I fix the environment or just re-prompt?
- **P3**: Is this rule enforced by a hook/script, or just written down?
- **P4**: Can the agent verify its own output (logs, API responses, screenshots)?
- **P5**: Am I adding a concise map or another wall of text?
