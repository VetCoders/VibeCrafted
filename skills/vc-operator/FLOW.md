# `vc-operator` Flow

`vc-operator` is the autonomous orchestration posture for a planned
multi-wave dispatch chain.

It conducts. It does not become the worker.

## Core Loop

```mermaid
flowchart TD
    A[Operator intent or master plan] --> B[Declare operator posture]
    B --> C[Run or consume vc-init]
    C --> D[Read plan and cited files]
    D --> E{Dispatchable?}
    E -->|no| F[Reshape with vc-scaffold]
    F --> G[Build wave atlas]
    E -->|yes| G

    G --> H[Verify cuts with Loctree]
    H --> I[Pick agents via why-matrix]
    I --> J[Render worker briefs]
    J --> K[Fire Wave N through vibecrafted launcher]
    K --> L[Await durable artifacts]
    L --> M{Wave green?}
    M -->|stalled| N[Recovery dispatch, not restart]
    N --> L
    M -->|failed truth drift| O[Escalate slice to vc-marbles]
    O --> L
    M -->|green| P[Verify reports, gates, branch, SHA]
    P --> Q[Append tracker and journal]
    Q --> R[Synthesize wave close-out]
    R --> S{More waves?}
    S -->|yes| K
    S -->|no| T[Stop at operator button]
    T --> U[Return push/merge/deploy handoff]
```

## Phase Contract

| Phase            | Question                                              | Required output                |
| ---------------- | ----------------------------------------------------- | ------------------------------ |
| Posture          | Did we explicitly enter operator mode?                | one-line framing shift         |
| Orientation      | Do we have current repo/runtime/intention truth?      | `vc-init` evidence             |
| Plan intake      | Is the full plan and every cited file read?           | input coverage note            |
| Dispatchability  | Can the plan be run as waves?                         | wave atlas or scaffold handoff |
| Cut verification | Does each cut match repo structure?                   | Loctree annotations            |
| Agent choice     | Who should run each slice?                            | why-matrix rationale           |
| Briefing         | Can a worker execute without guessing?                | rendered dispatch brief        |
| Dispatch         | Did every spawn go through framework telemetry?       | run IDs and launch cards       |
| Await            | Did each worker finish, stall, or fail with evidence? | report/transcript/meta state   |
| Recovery         | Is the next action focused, not a blind retry?        | recovery brief or escalation   |
| Close-out        | What landed and where?                                | wave report, SHAs, gates       |
| Stop             | What remains operator-owned?                          | push/merge/deploy handoff      |

## Operator Journal

Operator mode keeps two living artifacts:

- `tracker.md` - wave status, checkbox state, run IDs, branches, SHAs, gates.
- `journal.md` - append-only mission diary for decisions, stalls, recoveries,
  framing shifts, and stop points.

The tracker lets the operator audit what landed without reading every report.
The journal explains why the wave moved the way it did.

## Routes

| Entry                          | Args                   | Produces                                              | Exit        |
| ------------------------------ | ---------------------- | ----------------------------------------------------- | ----------- |
| `vibecrafted operator <agent>` | `--prompt` or `--file` | tracker, journal, wave close-outs, stop-point handoff | `0` on stop |
| `vc-operator <agent>`          | same                   | same                                                  | `0` on stop |
| `vc-conductor <agent>`         | same                   | same                                                  | `0` on stop |

### Escalation edges

- Need a plan first -> `vibecrafted scaffold <agent>`
- Need shared strategy before dispatch -> `vibecrafted partner <agent>`
- A slice needs solo A to Z delivery -> `vibecrafted ownership <agent>`
- Wave failed on truth drift -> `vibecrafted marbles <agent>`
- Completed chain needs release surface -> `vibecrafted release <agent>`

### Session artifacts

- Artifact root: `$VIBECRAFTED_HOME/artifacts/<org>/<repo>/<YYYY_MMDD>/operator/`
- Tracker: `<artifact-root>/tracker.md`
- Journal: `<artifact-root>/journal.md`
- Briefs: `<artifact-root>/briefs/*.md`
- Per-wave close-outs: `<artifact-root>/reports/<ts>_wave-<n>-close-out_operator.md`
- Final stop-point handoff: `<artifact-root>/reports/<ts>_stop-point_operator.md`
- Lock: `$VIBECRAFTED_HOME/locks/<org>/<repo>/<run_id>.lock`

## Anti-Patterns

- Acting like the implementer instead of the conductor.
- Re-firing a stalled wave without reading the failed worker report.
- Compressing wave status into "green" without SHAs and gate evidence.
- Treating native subagents as external fleet dispatches.
- Authoring worker achievements as operator achievements.
- Continuing past the operator button.
