---
title: Integrate agy and junie into vc-operator
description: Plan for replacing gemini with agy (antigravity-cli) and adding junie to the operator-side orchestration and dispatch systems
type: implementation_plan
project: VetCoders/vibecrafted
created: 2026-05-23
parent_branch: release/v2.0.0
---

# Plan: `vc-operator` — `agy` & `junie` Agent Integration

This plan details the steps required to replace the legacy `gemini-cli` with `antigravity-cli` (`agy`) and introduce JetBrains `junie` as a first-class dispatchable agent inside the operator orchestration workspace.

---

## 1) Goal and Rationale

The modern Vibecrafted runtime is transitioning away from the legacy `gemini-cli` wrapper to **`antigravity-cli`** (command: `agy`) for all Gemini-based prompt-interactive sessions, and introducing **`junie`** to orchestrate code-centric IDE/terminal tasks. We must update the orchestration commands, symlinks, status checks, TUI layouts, and agent selection tables to reflect this reality.

---

## 2) Target Architecture / Swarm Mapping

```text
                     [ vibecrafted command / TUI ]
                                   │
         ┌───────────────────┬─────┴─────────────┬──────────────────┐
         ▼                   ▼                   ▼                  ▼
   [ claude-code ]     [ codex-cli ]       [ agy (Gemini) ]      [ junie ]
```

- **`agy` (Gemini CLI)**: Invoked non-interactively via `agy -p '<prompt>'` or interactively via `agy -i --add-dir <path>`. Emits stream-json outputs for fast filtering.
- **`junie` (Junie CLI)**: Invoked via `junie --task '<prompt>' --project <path>` with `--skip-update-check` enabled to bypass latency.

---

## 3) Detailed Changes

### Component: `skills/vc-operator/`

#### [MODIFY] [WHY_MATRIX_TABLE.md](file:///Users/polyversai/Libraxis/vc-runtime/vibecrafted/skills/vc-operator/WHY_MATRIX_TABLE.md)

Update the task-to-agent performance matrix table:

- Replace `gemini` with `agy` in the rankings.
- Add `junie` as a high-tier ranked agent for standard code refactoring, test execution, and Rust/Kotlin type fixes.
- Rank `junie` alongside `claude` and `codex` with specific model-strength weighting.

#### [MODIFY] [SKILL.md](file:///Users/polyversai/Libraxis/vc-runtime/vibecrafted/skills/vc-operator/SKILL.md)

- Update launcher usage examples to replace `gemini` calls with `agy` and `junie`.
- Update the valid agent runtime pairs list:
  ```text
  | skill     | accepts                       |
  | --------- | ----------------------------- |
  | implement | claude, codex, agy, junie     |
  ```

---

### Component: `skills/vc-agents/`

#### [NEW] [agy_spawn.sh](file:///Users/polyversai/Libraxis/vc-runtime/vibecrafted/skills/vc-agents/scripts/agy_spawn.sh)

Create the spawn wrapper for `agy`:

- Consume and format plan prompts to stdin of `agy -p '' --dangerously-skip-permissions --add-dir "$SPAWN_ROOT"`.
- Support stream-filtering matching `agy` JSON output patterns.
- Save transcripts to `$SPAWN_TRANSCRIPT` and build completion reports.

#### [NEW] [junie_spawn.sh](file:///Users/polyversai/Libraxis/vc-runtime/vibecrafted/skills/vc-agents/scripts/junie_spawn.sh)

Create the spawn wrapper for `junie`:

- Invoke `junie --task "$task" --project "$SPAWN_ROOT" --skip-update-check --use-local-cache`.
- Capture output logs and formats to telemetry files.

#### [DELETE] [gemini_spawn.sh](file:///Users/polyversai/Libraxis/vc-runtime/vibecrafted/skills/vc-agents/scripts/gemini_spawn.sh)

Remove the legacy `gemini_spawn.sh` script.

---

### Component: Framework Shell Interfaces

#### [MODIFY] [shell/vetcoders.sh](file:///Users/polyversai/Libraxis/vc-runtime/vibecrafted/skills/vc-agents/shell/vetcoders.sh)

- Update CLI commands matching `vibecrafted <agent>`:
  - Map `agy` to `antigravity` calls.
  - Map `junie` to Junie CLI calls.
- Define agent convenience functions:
  - `agy-implement()`, `agy-review()`, `agy-research()`, `agy-marbles()`, etc.
  - `junie-implement()`, `junie-review()`, `junie-research()`, `junie-marbles()`, etc.
- Replace `gemini` references inside the triple-agent swarm launcher (`vc-research` / `_vetcoders_research`) with `agy` to leverage antigravity-cli's sandbox/permission skipping.
- Update `_vetcoders_operator_command_text`:
  ```bash
  agy)
    printf 'agy --dangerously-skip-permissions -p %s' "$quoted_prompt"
    ;;
  junie)
    printf 'junie --task %s --skip-update-check' "$quoted_prompt"
    ;;
  ```

---

## 4) Verification Plan

- Run TUI launcher integration tests:
  ```bash
  pytest tests/tui/test_launcher_surface.py
  ```
- Run mock spawner parity validations:
  ```bash
  pytest tests/spawn_parity_test.sh
  ```
