# `vc-operator` Runtime

`vc-operator` as an interactive skill does not automatically launch runtime.

Runtime begins only when the framework launches:

```bash
vibecrafted operator <agent> --file /path/to/master-dispatch.md
vibecrafted operator <agent> --prompt '<dispatch mandate>'
vc-operator <agent> --file /path/to/master-dispatch.md
```

## Runtime Responsibilities

The operator runtime creates durable state for fleet orchestration:

- run metadata
- transcript
- wave tracker
- append-only journal
- worker briefs
- launch cards and run IDs
- per-wave close-outs
- final stop-point handoff
- plan mutation and security guardrail entries in the operator journal

## Artifact Layout

```text
$VIBECRAFTED_HOME/artifacts/<org>/<repo>/<YYYY_MMDD>/operator/
  tracker.md
  journal.md
  briefs/
    <wave>-<position>_<slug>.md
  reports/
    <timestamp>_wave-<n>-close-out_operator.md
    <timestamp>_stop-point_operator.md
    <timestamp>_<slug>_operator.transcript.log
    <timestamp>_<slug>_operator.meta.json
```

## Runtime Lanes

| Need                        | Runtime lane                    |
| --------------------------- | ------------------------------- |
| Plan is fuzzy               | `vibecrafted scaffold <agent>`  |
| One worker slice            | `vibecrafted implement <agent>` |
| Strict ERi slice            | `vibecrafted workflow <agent>`  |
| Truth-drift convergence     | `vibecrafted marbles <agent>`   |
| A to Z polish for one slice | `vibecrafted ownership <agent>` |
| Shared strategy pause       | `vibecrafted partner <agent>`   |
| Independent verification    | `vibecrafted audit <agent>`     |
| Outward ship                | `vibecrafted release <agent>`   |

## Terminal States

```yaml
terminal_state:
  stopped_at_operator_button:
    requires:
      - wave tracker updated
      - journal updated
      - reports and SHAs named
      - remaining unpermitted human action named
  completed_with_plan_permission:
    requires:
      - permission source named
      - tracker updated
      - journal updated
      - reports and SHAs named
  blocked_with_evidence:
    requires:
      - blocker classification
      - attempted recovery
      - nearest safe next action
  escalated:
    requires:
      - target skill
      - reason
      - handoff state
```

## Non-Goals

- Do not use runtime to hide decisions from the operator.
- Do not run unwatchable dispatch.
- Do not bypass launch telemetry.
- Do not turn stop-point handoff into push/merge/deploy unless the written
  plan or current session explicitly permitted that action.
