---
run_id: meta22-task23-observe-contract-codex-20260519
agent: codex
skill: vc-agents
project: vibecrafted
status: pending
operator_policy: parent operator does not code; implementation belongs to vc-agents
coordination_mode: solo implementation on this stage
---

# Task: Task 23 Runtime Observe Contract

Goal:

- Wire the smallest missing runtime observe contract across existing Python core and MCP surfaces.
- Preserve the current shell/vc-agents launcher as the launch authority.
- Make MCP able to launch, lookup, and await runs through existing core/control-plane truth without duplicating launcher semantics.

Scope:

- In scope:
  - `vibecrafted-core/vibecrafted_core/control_plane.py`
  - `vibecrafted-core/vibecrafted_core/workflow.py`
  - `vibecrafted-mcp/vibecrafted_mcp/server.py`
  - nearest existing tests under `vibecrafted-core/tests/` and `vibecrafted-mcp/tests/` or repo test conventions
  - docs/test updates only when needed to make the dispatch/observe contract clear
- Out of scope:
  - no bash engine port
  - no rewrite of `scripts/vibecrafted`
  - no new workflow semantics
  - no billing, release, deploy, or public-site changes
  - no push, PR, merge, tag, deploy, or publish

Constraints:

- You are working on a living tree. Concurrent changes are expected. Adapt proactively.
- The parent operator must not write implementation code. You, the fleet worker, own any code patch in this run.
- Loctree first before structural edits. If Loctree cannot surface a needed area, append a hook to `$HOME/.vibecrafted/loctree/loctree-fail.md` and use shell fallback.
- Do not create a worktree or change branches.
- Do not call `vc-agents` again. You are execution, not orchestration authority.
- Keep launcher semantics where they already live: `scripts/vibecrafted` + `skills/vc-agents`.

Acceptance:

- [ ] `RunStatus` or the equivalent control-plane projection preserves enough meta fields for await/status consumers: at minimum `exit_code`, `liveness`, `launcher_pid`, `completed_at`, and `session_id` when present.
- [ ] MCP exposes a thin launch tool that calls existing `normalize_launch_spec()` / `launch_workflow()` and does not mint launchers itself.
- [ ] MCP exposes run status lookup by `run_id` using `sync_state()` / control-plane truth.
- [ ] MCP exposes a bounded await by `run_id` that loops on metadata/control-plane state and does not parse transcript text.
- [ ] Existing MCP tools/resources still work.
- [ ] Tests cover launch/status/await behavior with fake or temporary meta/control-plane data.
- [ ] The final report names any remaining manual/live-run gap honestly.

Test gate:

- `python -m pytest vibecrafted-core/tests vibecrafted-mcp/tests tests -q`
- If that full gate is too broad or environment-blocked, run the narrowest relevant pytest targets and report the exact blocker.

Context:

- Meta-22 audit found that framework Plans 02-04 and 06-12 have landed or mostly landed, while 01, 05, 20, 21, and 22 remain blocked.
- Halley recon verdict: meta JSON owns facts; `control_plane.sync_state()` owns board projection; `await.sh` is authoritative await adapter; MCP should be a remote button + board reader.
- Current runtime surfaces to inspect before editing: `skills/vc-agents/scripts/lib/meta.sh`, `skills/vc-agents/scripts/lib/session.sh`, `skills/vc-agents/scripts/await.sh`, `skills/vc-agents/scripts/observe.sh`, `vibecrafted-core/vibecrafted_core/control_plane.py`, `vibecrafted-core/vibecrafted_core/workflow.py`, and `vibecrafted-mcp/vibecrafted_mcp/server.py`.

Living tree note:

- You work on a living tree with Vibecraftsmanship methodology, so concurrent changes are expected.
- Re-read files immediately before editing.
- Run required checks.
- If a wider runtime migration appears necessary, stop at the smallest honest patch and report the boundary.
- Commit locally only if this repo's active workflow expects it and the helper contract is clear; otherwise leave the patch staged/unstaged with a precise report. Do not push.
