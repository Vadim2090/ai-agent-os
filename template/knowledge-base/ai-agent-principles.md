# AI Agent Operating Principles

Reference framework for how I build and maintain my AI operating system. Every skill, hook and
workflow in this repo should be traceable to one of the three.

> *An AI agent without context and feedback loops is like a pilot flying blind. You can still move fast,
> but you can't trust the direction.*

---

## The 3 Principles

| # | Principle | In plain English | In practice |
|---|-----------|------------------|-------------|
| 1 | **Make the work visible to the agent** | Give the agent the same context you would give a human teammate: decisions, plans, metrics, outputs | Structured sessions (`/start` loads prior context, `/finish` saves it — nothing is lost between sessions) and MCP integrations, so the agent reads the real systems and can verify its own results |
| 2 | **Fix the system, not the AI** | When the agent fails, check tooling, documentation and context quality before rewriting prompts or switching models | An agent acting on outdated information (people who had left, tools marked "evaluation" that were live) was fixed with automated freshness checks and drift detection, not a new prompt |
| 3 | **Enforce structure mechanically** | Critical rules are checks and constraints that prevent violations by default | Hooks scan every file write; a SessionStart hook runs the health checks; the launch folder decides the track. Written rules get forgotten, automated checks don't |

## Three pillars underneath

1. **Context engineering** — the repo is the single source of truth. If it is not in agent-visible files, it does not exist.
2. **Architectural constraints** — rules enforced by hooks and scripts that physically prevent violations.
3. **Entropy management** — session protocol and memory hierarchy prevent context drift over time.

---

## How to apply this

When evaluating any change to the system, ask:

- **P1**: Can the agent see everything it needs without asking me? Can it verify its own output?
- **P2**: When something broke, did I fix the environment or just re-prompt?
- **P3**: Is this rule enforced by a hook or script, or only written down?
