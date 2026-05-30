# `vc-operator` Contract

This document is the binding contract behind the readable operator flow.

## Layer Contract

```yaml
interactive_skill:
  name: vc-operator
  kind: orchestration_posture
  activates_when:
    - user names "$vc-operator"
    - user asks to conduct a plan or fleet
    - user asks for multi-wave dispatch
  does_not_automatically:
    - launch "vibecrafted operator"
    - create a run_id
    - create transcript/meta artifacts
    - fire workers

runtime_workflow:
  name: vibecrafted operator
  kind: runtime_workflow
  activates_when:
    - operator launches "vibecrafted operator <agent>"
    - framework dispatches an operator run explicitly
  creates:
    - run_id
    - operator/tracker.md
    - operator/journal.md
    - briefs
    - close_out_reports
    - transcript.log
    - meta.json
```

## Posture Contract

```yaml
vc-operator:
  owns:
    - plan_intake
    - wave_atlas
    - agent_selection
    - dispatch_briefs
    - await_and_recovery
    - tracker
    - journal
    - wave_close_outs
    - stop_point_handoff
  may_launch_runtime:
    - vc-scaffold
    - vc-implement
    - vc-workflow
    - vc-marbles
    - vc-audit
    - vc-review
    - vc-followup
    - vc-release
    - vc-ownership
    - vc-partner
  must_not:
    - silently become a worker
    - dispatch without vc-init evidence
    - dispatch without a wave atlas
    - use native subagents for fleet dispatch
    - blind-restart stalled workers
    - push_merge_deploy_or_publish_without_operator_button
```

## Binding Artifacts

```yaml
operator_run:
  plan_name: ""
  artifact_root: ""
  framing_shift: ""
  init_evidence: ""
wave_atlas:
  waves: []
  dependencies: []
  parallel_groups: []
dispatches:
  briefs: []
  run_ids: []
  agents: []
verification:
  reports: []
  gates: []
  branches: []
  shas: []
recovery:
  stalls: []
  recovery_dispatches: []
close_out:
  tracker: ""
  journal: ""
  stop_point_handoff: ""
```

## Stop Button Policy

Operator mode stops before:

- push
- force-push
- merge
- deploy
- public message
- paid action
- irreversible state change
- trust-boundary action

The final handoff should make the remaining button obvious.

## Recovery Policy

Stall does not mean restart.

Allowed recovery requires:

1. read the stalled worker's report/transcript/meta if present
2. classify the failure
3. issue a focused recovery dispatch or escalate to marbles/ownership
4. append the recovery decision to `journal.md`

Blind re-fire is a process failure.
