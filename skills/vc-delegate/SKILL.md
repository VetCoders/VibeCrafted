---
name: vc-delegate
version: 2.0.0
description: >
  Native operator-side delegation doctrine for small bounded native cuts.
  Use this when the operator agent must decide whether work should stay
  in-process through native subagents or be escalated upward into vc-agents.
  Trigger phrases: "implement with agents", "delegate to subagents", "zaimplementuj",
  "run agents", "parallel tasks", "delegate safely", "native agents",
  "Task tool agents", "implement plan", "uruchom agentów", "subagenty natywne",
  "bezpieczne agenty", "implement without externals", "no osascript".
compatibility:
  tools: []
---

# vc-delegate

## Operator Entry

Operator enters the framework session through:

```bash
vibecrafted start
# or
vc-start
# same default board as: vc-start vibecrafted
```

Do not launch `vc-delegate` directly. Its operator-facing replacement is:

```bash
vibecrafted <workflow> <agent> --file '/path/to/plan.md'
```

```bash
vc-<workflow> <agent> --prompt '<prompt>'
```

This skill is not the external fleet itself. It is the operator doctrine for
native delegation: when to keep a cut local, when to stop pretending a native
cut is still bounded, and when the operator should escalate into `vc-agents`.

### Concrete dispatch examples

```bash
vibecrafted partner codex --prompt 'Split this into one small native cut'
vibecrafted justdo claude --file /path/to/plan.md
vibecrafted workflow gemini --prompt 'Keep this local unless it clearly wants the external fleet'
```

## Native Delegation Policy

When using native subagents, default to the same frontier as the parent agent.

Why:

- same-named native delegation preserves the closest reasoning style to the parent
- it maximizes context locality and cache reuse opportunities
- on the same repo and task family, this is usually the best cost-to-quality default

Default:

- Codex parent -> Codex native subagent
- Claude parent -> Claude native subagent
- Gemini parent -> Gemini native subagent

Exceptions:

- Codex: you may delegate to `gpt-5.3-codex-spark` with `xhigh` when the task benefits from extreme speed. Treat Spark as a fast execution tier; the parent agent remains responsible for final quality.
- Claude: for extensive long-running tasks prefer `opus[1m]`; for easier or lighter tasks prefer `sonnet[1m]`.
- Gemini: if `gemini-3.1-pro-preview` is unavailable or unstable during peak demand, fallback native delegation to `auto-gemini-3`.

Rule:

- default to same-named native agents first
- use cross-model exceptions intentionally, never casually
- if you trade down for speed or availability, recover quality in the parent orchestration pass

## Escalation Direction

`vc-delegate` is a bounded native delegation tool for the operator agent.

Its role is to help the operator go deeper locally, or to admit when a task has
outgrown native delegation.

If a native delegated task becomes too extensive, too cross-cutting, or too
dependent on model-specific orchestration, it should not fake completion.

Instead it must:

- report that the task has exceeded native delegation scope
- return to the parent operator
- let the parent operator decide whether to escalate into `vc-agents`

Only the operator agent may escalate work into `vc-agents`.

Reason:

- `vc-agents` is not a generic recursion mechanism
- it is a deliberate operator decision based on the `vc-why-matrix`
- once a fleet agent has been chosen, that choice must remain stable unless the operator explicitly changes it

## Scope Boundary

This doctrine is for the operator layer.

It is not forwarded as an execution policy to the tiny native subagents
themselves. Native subagents are execution helpers, not orchestration actors.

Read `skills/vc-agents/SKILL.md` alongside this file when the operator needs the
full external fleet and the `vc-why-matrix`.
