---
run_id: root-contract-fix-codex-20260519
agent: codex
skill: vc-agents
project: vibecrafted
status: pending
operator_policy: parent operator does not code; implementation belongs to vc-agents
coordination_mode: solo implementation on this stage
---

# Task: Root Contract Test Fix

Goal:

- Fix the two currently failing root contract tests without touching unrelated runtime code.
- Preserve the command-deck wording contract in docs.
- Restore the canonical orientation gate contract for `vc-operator`.

Scope:

- In scope:
  - `docs/WORKFLOWS.md`
  - `skills/vc-operator/SKILL.md`
  - the two failing tests only if the implementation proves the test wording is stale
- Out of scope:
  - no changes to Task 23 runtime observe code
  - no Husky template edits
  - no broad documentation rewrite
  - no push, PR, merge, tag, deploy, or publish

Constraints:

- You are working on a living tree. Concurrent changes are expected. Adapt proactively.
- The parent operator must not write implementation code. You, the fleet worker, own any patch.
- Loctree first before structural edits. If Loctree cannot surface a needed area, append a hook to `$HOME/.vibecrafted/loctree/loctree-fail.md` and use shell fallback.
- Do not create a worktree or change branches.
- Do not call `vc-agents` again. You are execution, not orchestration authority.
- Keep the fix small and contract-driven.

Acceptance:

- [ ] `tests/tui/test_docs_links.py::test_skill_docs_pin_command_deck_semantics` passes.
- [ ] `tests/tui/test_skill_contracts.py::test_vc_skills_preserve_init_and_loctree_orientation_contract` passes.
- [ ] `python -m pytest tests/tui/test_docs_links.py::test_skill_docs_pin_command_deck_semantics tests/tui/test_skill_contracts.py::test_vc_skills_preserve_init_and_loctree_orientation_contract -q` passes.
- [ ] Root `python -m pytest tests -q` is run or the exact blocker is reported.
- [ ] Patch is locally committed if hooks pass; no push.

Context:

- Current failures:
  - `docs/WORKFLOWS.md` does not include the expected string `` `vibecrafted implement` is the canonical autonomous delivery ``.
  - `skills/vc-operator/SKILL.md` is missing the canonical orientation gate, `Loctree:loctree`, and `Code-Derived Application Map` contract expected across `vc-*` skills.
- Current branch includes Task 23 commit `e95b8c8` and Husky template commit `2293900`; do not revert either.

Living tree note:

- Re-read files immediately before editing.
- If another agent changes the same files, adapt and report the substrate collision.
- Commit only your scoped files if the repo helper/hook path is clear. Do not push.
