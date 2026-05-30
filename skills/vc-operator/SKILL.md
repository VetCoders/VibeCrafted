---
name: vc-operator
version: 3.0.0-dev
description: >
  Autonomous orchestration posture for conducting a fleet through a planned
  multi-wave dispatch chain. Use when the agent is not building one slice but
  reading a plan, building a wave atlas, dispatching peer agents, awaiting
  durable artifacts, verifying reports and gates, issuing recovery dispatches
  on stalls, and stopping at the operator button. Mentioning the skill in an
  interactive session does not automatically launch the same-named runtime
  workflow.
  Trigger phrases: "operator mode", "vc-operator", "Agent-Operator",
  "tryb operatora", "prowadz fleet", "konduktorze", "orkiestracja",
  "dispatch the plan", "fire the wave", "dirygentura",
  "multi-dispatch", "orchestrate this plan", "stop at the button".
default: vc-operator
aliases:
  - vc-conductor
compatibility:
  tools:
    - exec_command
    - apply_patch
    - update_plan
    - multi_tool_use.parallel
    - web.run
    - js_repl
requires:
  - vc-init
  - vc-ownership
---

# vc-operator

> Autonomous orchestration posture. Wave discipline. Recovery over retries.
> Stop at the operator button.

## Taxonomy

```yaml
vc-operator:
  kind: orchestration_posture
  scope: interactive_session
  meaning: dispatch, await, synthesize, recover, close waves
  autonomy: orchestration
```

`vc-operator` is not an implementation skill. It is the conductor posture for
a planned chain of work.

- `vc-partner` preserves and co-steers the original shape before or during
  strategy work.
- `vc-ownership` drives one product slice end-to-end.
- `vc-operator` conducts a fleet through a plan and stops at the operator
  button.
- `vc-init` opens the session with repo/runtime/intention truth; it is not a
  posture.

Skill invocation is not runtime invocation. If the operator says
`$vc-operator` inside the current conversation, the current agent adopts this
orchestration posture. A separate runtime run exists only when the operator or
framework launches `vibecrafted operator <agent> ...`.

See [CONTRACT.md](CONTRACT.md) for the binding posture/runtime split.

## Mandatory Entrypoint

Read [RUNNER.md](RUNNER.md) first.

`SKILL.md` defines the posture. `RUNNER.md` is the deterministic runbook. The
other documents are supporting surfaces:

- [FLOW.md](FLOW.md) - orchestration loop and artifacts.
- [TAXONOMY.md](TAXONOMY.md) - operator posture vs runtime taxonomy.
- [FRAME.md](FRAME.md) - Worker / Owner / Operator role boundaries.
- [GUIDE.md](GUIDE.md) - wave atlas structure.
- [DISPATCH.md](DISPATCH.md) and [DISPATCH_TEMPLATE.md](DISPATCH_TEMPLATE.md) -
  worker brief contract.
- [AWAIT.md](AWAIT.md) - await/recovery discipline.
- [AUTONOMY.md](AUTONOMY.md) - the operator button.
- [JOURNAL.md](JOURNAL.md) - append-only operator journal.
- [RUNTIME.md](RUNTIME.md) - runtime launch and artifact contract.
- [WHY_MATRIX_TABLE.md](WHY_MATRIX_TABLE.md) - agent routing.

## Framing Shift

Before first dispatch, declare the posture in one line:

```text
Operator mode active - <plan-name>
```

If the session was previously in Worker, Partner, or Ownership mode, name the
shift before firing anything. Silent role drift is an operator failure.

## Prime Directive

Conduct the plan. Do not become the worker.

The operator agent owns:

- plan intake
- wave atlas
- agent selection
- dispatch bodies
- await/recovery
- report/gate verification
- tracker and journal
- close-out synthesis
- stop-point handoff

Workers own their slices. Authorship, reports, commits, and findings stay
attached to the workers who produced them.

## Stop Point

Stop at the operator button: the line where the next action is push, merge,
deploy, public communication, paid action, irreversible state change, or any
trust-boundary move that belongs to the human operator.

Operator mode may make the work push-ready. It does not push, merge, deploy, or
publish unless the operator explicitly presses the button.

## Operating Loop

1. Run or consume fresh `vc-init` evidence.
2. Read the plan and all cited files in full.
3. Reshape through `vc-scaffold` if the plan is not dispatchable.
4. Build the wave atlas.
5. Verify each cut against Loctree.
6. Pick agents through `WHY_MATRIX_TABLE.md`.
7. Render worker briefs from `DISPATCH_TEMPLATE.md`.
8. Fire one wave at a time through `vibecrafted <skill> <agent>`.
9. Await durable artifacts.
10. Verify reports, gates, branch, and SHA.
11. Use recovery dispatch on stalls; never blind restart.
12. Append tracker and journal.
13. Synthesize wave close-out.
14. Continue or stop at the operator button.

## Dispatch Law

Every external worker dispatch goes through the framework launcher:

```bash
vibecrafted <skill> <agent> --file <brief>
```

No native subagents for fleet dispatch in operator mode. Native delegation is
for local bounded work; operator waves need telemetry, launch cards, reports,
transcripts, meta, and awaitable state.

## Journal And Tracker

Operator mode keeps two living artifacts:

- `tracker.md` - wave status table, checkboxes, run IDs, SHAs, gate state.
- `journal.md` - append-only mission diary for decisions, stalls, recoveries,
  role shifts, and stop points.

Both are operator-internal artifacts. They do not carry worker closing rails.

See [JOURNAL.md](JOURNAL.md).

## Adjacent Skills

- `vc-init` - required orientation gate.
- `vc-scaffold` - plan authoring or reshaping before dispatch.
- `vc-ownership` - each worker may operate with ownership inside its slice; the
  operator owns the chain.
- `vc-partner` - shared strategy before a plan is dispatchable.
- `vc-marbles` - convergence when a slice fails on truth drift.
- `vc-audit` / `vc-review` / `vc-followup` - verification surfaces after waves.
- `vc-release` - outward ship once the operator button has been pressed.

## Anti-Patterns

- Acting like a solo implementer after the operator asked for orchestration.
- Dispatching before the plan is readable as a wave atlas.
- Re-firing a stalled wave instead of reading artifacts and issuing recovery.
- Spawning native subagents for operator fleet work.
- Silently downgrading model tier or violating agent fairness.
- Claiming wave green without report, gate, branch, and SHA evidence.
- Authoring worker commits or close-outs as if the operator did their work.
- Running headless or unwatchable dispatches.
- Pushing, merging, deploying, or publishing before the operator button.

## Output Shape

For progress:

1. Current state - wave, prompt, agent, run ID, branch/SHA if landed.
2. Evidence - report/gate/artifact status.
3. Decision - continue, recover, pause, or stop.
4. Next move - exactly one.

For final handoff:

1. Plan and wave coverage.
2. Worker outputs and SHAs.
3. Gates and unresolved risks.
4. Recovery actions taken.
5. Stop-point handoff: what button remains for the operator.
