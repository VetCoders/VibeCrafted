---
run_id: watch-await-contract-codex-20260519
agent: codex
skill: vc-agents
project: vibecrafted
status: pending
operator_policy: parent operator does not code; implementation belongs to vc-agents
coordination_mode: solo implementation on this stage
---

# Task: Watch / Await Runtime Contract

Goal:

- Make `await` / `observe` effective for long or stalled fleet runs.
- Detect false-launched runs where the launch card exists but meta remains `pid_pending` with no live process.
- Add operator-visible heartbeat output while waiting so the operator is not blind during long runs.

Scope:

- In scope:
  - `skills/vc-agents/scripts/await.sh`
  - `skills/vc-agents/scripts/observe.sh`
  - nearest tests under `tests/` or `tests/tui/`
  - docs/help text only if needed to describe the recovery command
- Out of scope:
  - no changes to Task 23 MCP/core implementation unless tests prove a direct contract conflict
  - no changes to Husky/hooks templates
  - no rewrite of the launcher engine
  - no push, PR, merge, tag, deploy, or publish

Constraints:

- You are working on a living tree. Concurrent changes are expected. Adapt proactively.
- The parent operator must not write implementation code. You, the fleet worker, own any patch.
- Loctree first before structural edits. If Loctree cannot surface a needed area, append a hook to `$HOME/.vibecrafted/loctree/loctree-fail.md` and use shell fallback.
- Do not create a worktree or change branches.
- Do not call `vc-agents` again. You are execution, not orchestration authority.
- Keep this as watch/observe glue, not a launcher rewrite.

Observed failure to reproduce / account for:

- Run `just-024350-12530` produced a launch card and valid meta/launcher paths, but meta stayed:
  - `status=launching`
  - `exit_code=null`
  - `liveness=pid_pending`
  - `launcher_pid=null`
  - empty transcript
- Manual recovery by executing the generated `vc-spawn-cmd...` script started the worker successfully.
- Earlier `vibecrafted codex await --run-id just-013426-17501` blocked silently for minutes, so the operator had no heartbeat while the worker was alive.

Acceptance:

- [ ] `vibecrafted <agent> await --run-id <id>` prints periodic heartbeat lines containing at least run id, status, liveness, updated_at, and report/transcript paths.
- [ ] Await detects `pid_pending` / no `launcher_pid` / empty transcript beyond a bounded startup grace and exits nonzero with the exact recovery command or launcher path.
- [ ] Await still exits 0 for completed runs and nonzero for failed runs.
- [ ] `observe` can resolve a run by `--run-id <id>` or gives a precise documented reason if that is intentionally left to `await`.
- [ ] Tests cover completed meta, running/pid_alive meta, and false-launched pid_pending meta.
- [ ] Existing root contract tests remain green.

Test gate:

- Narrow tests for await/observe behavior.
- `python -m pytest tests -q`
- If full root tests are too slow or blocked, report exact blocker and run the closest safe targeted gate.

Context:

- Current branch is `feat/husky-template`, ahead of `origin/release/v1.7.1`.
- Existing local commits include:
  - `e95b8c8 Wire runtime observe contract into MCP`
  - `5a7d37a fix root skill contract tests`
- Do not revert or rewrite those commits.
- Leave untracked `plans/` alone unless you need to read this brief.

Living tree note:

- Re-read files immediately before editing.
- If another agent changes the same files, adapt and report the substrate collision.
- Commit only your scoped files if hooks pass. Do not push.
