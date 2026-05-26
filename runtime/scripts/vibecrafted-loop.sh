#!/usr/bin/env bash
set -euo pipefail

# Interactive operator loop controller.
#
# This is the canonical runtime surface for an Agent-Operator running from an
# interactive session. It keeps loop state in the repo, can tell the current
# agent whether to continue, and can run background await chains without
# teaching the front-door `vibecrafted` deck about every orchestration detail.

state_file="${VIBECRAFTED_LOOP_STATE_FILE:-}"
command_name="${1:-help}"
[[ $# -gt 0 ]] && shift || true

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
framework_root="$(cd "$script_dir/../.." && pwd)"
vibecrafted_cmd="${VIBECRAFTED_CMD:-}"
if [[ -z "$vibecrafted_cmd" ]]; then
  if [[ -x "$framework_root/scripts/vibecrafted" ]]; then
    vibecrafted_cmd="$framework_root/scripts/vibecrafted"
  else
    vibecrafted_cmd="$(command -v vibecrafted 2>/dev/null || true)"
  fi
fi

usage() {
  cat <<'EOF'
Usage:
  vibecrafted loop start [--prompt <text>|--file <path>] [options]
  vibecrafted loop next [--state-file <path>]
  vibecrafted loop complete --promise <text> [--state-file <path>]
  vibecrafted loop cancel [--state-file <path>]
  vibecrafted loop status [--state-file <path>]
  vibecrafted loop await-run --run-id <id> [--then-cmd <cmd>] [options]

Interactive operator loop:
  start        Create the current-session loop contract.
  next         Advance one iteration and print the fixed prompt to continue.
  complete     Stop only when the exact completion promise is true.
  cancel       Stop the loop unconditionally.
  status       Print active state.

Async orchestration:
  await-run    Start a background controller that awaits a worker run_id and
               optionally launches the next command when that run completes.

Options:
  --state-file <path>          Default: <repo-root>/.vibecrafted/operator-loop.local.md
  --prompt <text>              Inline loop prompt
  --file <path>                File to use as loop prompt
  --max-iterations <n>         0 = unlimited (default)
  --completion-promise <text>  Exact promise required by complete
  --run-id <id>                Worker run_id for await-run
  --agent <agent>              Await helper agent, default codex
  --then-cmd <cmd>             Operator-approved command to run after a
                               completed await via bash -lc. Do not use for
                               push/deploy/publish unless the plan says so.
  --foreground                 Run await-run in foreground
  --log <path>                 Background log path
EOF
}

die() {
  printf 'vibecrafted loop: %s\n' "$*" >&2
  exit 1
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

default_state_file() {
  printf '%s/.vibecrafted/operator-loop.local.md\n' "$(repo_root)"
}

ensure_state_file() {
  if [[ -z "$state_file" ]]; then
    state_file="$(default_state_file)"
  fi
}

timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

frontmatter() {
  ensure_state_file
  [[ -f "$state_file" ]] || return 1
  sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$state_file"
}

field() {
  local key="$1"
  frontmatter | awk -v k="$key" '
    index($0, k ":") == 1 {
      value=substr($0, length(k) + 2)
      sub(/^[ \t]+/, "", value)
      print value
      exit
    }
  ' | sed 's/^"\(.*\)"$/\1/'
}

prompt_body() {
  ensure_state_file
  awk '/^---$/{i++; next} i>=2' "$state_file"
}

json_quote() {
  python3 - "$1" <<'PY'
import json
import sys
print(json.dumps(sys.argv[1]))
PY
}

set_field() {
  ensure_state_file
  local key="$1"
  local value="$2"
  local tmp="${state_file}.tmp.$$"
  if grep -q "^${key}:" "$state_file"; then
    sed "s|^${key}:.*|${key}: ${value}|" "$state_file" > "$tmp"
  else
    awk -v key="$key" -v value="$value" '
      BEGIN { inserted=0; fence=0 }
      /^---$/ {
        fence++
        if (fence == 2 && !inserted) {
          print key ": " value
          inserted=1
        }
      }
      { print }
    ' "$state_file" > "$tmp"
  fi
  mv "$tmp" "$state_file"
}

parse_state_file_only() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --state-file)
        shift; [[ $# -gt 0 ]] || die "missing value for --state-file"
        state_file="$1"
        ;;
      -h|--help|help)
        usage
        exit 0
        ;;
      *)
        die "unknown argument: $1"
        ;;
    esac
    shift
  done
}

require_state() {
  ensure_state_file
  [[ -f "$state_file" ]] || die "no active operator loop state: $state_file"
}

validate_number() {
  local label="$1"
  local value="$2"
  [[ "$value" =~ ^[0-9]+$ ]] || die "invalid $label in $state_file: $value"
}

cmd_start() {
  local prompt="" prompt_file="" max_iterations=0 completion_promise="null"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --state-file)
        shift; [[ $# -gt 0 ]] || die "missing value for --state-file"
        state_file="$1"
        ;;
      --prompt|-p)
        shift; [[ $# -gt 0 ]] || die "missing value for --prompt"
        prompt="$1"
        ;;
      --file|-f)
        shift; [[ $# -gt 0 ]] || die "missing value for --file"
        prompt_file="$1"
        ;;
      --max-iterations)
        shift; [[ $# -gt 0 ]] || die "missing value for --max-iterations"
        max_iterations="$1"
        ;;
      --completion-promise)
        shift; [[ $# -gt 0 ]] || die "missing value for --completion-promise"
        completion_promise="$1"
        ;;
      -h|--help|help)
        usage
        exit 0
        ;;
      *)
        if [[ -z "$prompt" ]]; then
          prompt="$1"
        else
          prompt+=" $1"
        fi
        ;;
    esac
    shift
  done

  ensure_state_file
  validate_number "--max-iterations" "$max_iterations"
  if [[ -n "$prompt_file" ]]; then
    [[ -f "$prompt_file" ]] || die "prompt file not found: $prompt_file"
    prompt="$(cat "$prompt_file")"
  fi
  [[ -n "$prompt" ]] || die "provide --prompt or --file"

  mkdir -p "$(dirname "$state_file")"
  local completion_yaml session_id
  if [[ "$completion_promise" != "null" ]]; then
    completion_yaml="$(json_quote "$completion_promise")"
  else
    completion_yaml="null"
  fi
  session_id="${CODEX_SESSION_ID:-${CLAUDE_CODE_SESSION_ID:-${VIBECRAFTED_OPERATOR_SESSION_ID:-}}}"

  cat > "$state_file" <<EOF_STATE
---
active: true
runtime: operator-interactive
iteration: 1
session_id: "$session_id"
max_iterations: $max_iterations
completion_promise: $completion_yaml
started_at: "$(timestamp)"
updated_at: "$(timestamp)"
root: "$(repo_root)"
---

$prompt
EOF_STATE

  cat <<EOF
Operator loop activated.

State: $state_file
Iteration: 1
Max iterations: $(if (( max_iterations > 0 )); then echo "$max_iterations"; else echo "unlimited"; fi)
Completion promise: $(if [[ "$completion_promise" != "null" ]]; then echo "<promise>$completion_promise</promise>"; else echo "none"; fi)

Protocol for the active Agent-Operator:
1. Work normally in this same interactive session.
2. Before final answer, run: vibecrafted loop next
3. If it prints CONTINUE, continue with the printed prompt.
4. Stop only with: vibecrafted loop complete --promise "<text>"
EOF
}

cmd_status() {
  parse_state_file_only "$@"
  require_state
  frontmatter
}

cmd_cancel() {
  parse_state_file_only "$@"
  require_state
  set_field active false
  set_field stopped_at "\"$(timestamp)\""
  set_field stop_reason cancel
  printf 'Cancelled operator loop at iteration %s.\n' "$(field iteration)"
}

cmd_complete() {
  local promise=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --state-file)
        shift; [[ $# -gt 0 ]] || die "missing value for --state-file"
        state_file="$1"
        ;;
      --promise)
        shift; [[ $# -gt 0 ]] || die "missing value for --promise"
        promise="$1"
        ;;
      -h|--help|help)
        usage
        exit 0
        ;;
      *)
        die "unknown argument: $1"
        ;;
    esac
    shift
  done

  require_state
  local completion_promise
  completion_promise="$(field completion_promise || true)"
  if [[ "$completion_promise" != "null" && -n "$completion_promise" && "$promise" != "$completion_promise" ]]; then
    printf 'Promise mismatch. Expected: %s\n' "$completion_promise" >&2
    exit 3
  fi
  set_field active false
  set_field stopped_at "\"$(timestamp)\""
  set_field stop_reason promise
  printf 'Completed operator loop%s.\n' "$(if [[ -n "$completion_promise" && "$completion_promise" != "null" ]]; then printf ' with <promise>%s</promise>' "$completion_promise"; fi)"
}

cmd_next() {
  parse_state_file_only "$@"
  require_state

  local active iteration max_iterations completion_promise next_iteration
  active="$(field active || true)"
  iteration="$(field iteration || true)"
  max_iterations="$(field max_iterations || true)"
  completion_promise="$(field completion_promise || true)"
  validate_number "iteration" "$iteration"
  validate_number "max_iterations" "$max_iterations"

  if [[ "$active" != "true" ]]; then
    printf 'STOP: operator loop inactive.\n'
    exit 0
  fi
  if (( max_iterations > 0 && iteration >= max_iterations )); then
    set_field active false
    set_field stopped_at "\"$(timestamp)\""
    set_field stop_reason max_iterations
    printf 'STOP: max iterations reached (%s).\n' "$max_iterations"
    exit 0
  fi

  next_iteration=$((iteration + 1))
  set_field iteration "$next_iteration"
  set_field updated_at "\"$(timestamp)\""

  printf 'CONTINUE: operator loop iteration %s\n' "$next_iteration"
  if [[ "$completion_promise" != "null" && -n "$completion_promise" ]]; then
    printf 'Completion promise: <promise>%s</promise> only when completely true.\n' "$completion_promise"
  fi
  printf '\n--- PROMPT ---\n'
  prompt_body
}

await_foreground() {
  local agent="$1" run_id="$2" then_cmd="$3"
  [[ -n "$vibecrafted_cmd" ]] || die "could not resolve vibecrafted command for await-run"
  printf '[%s] awaiting %s via %s\n' "$(timestamp)" "$run_id" "$agent"
  "$vibecrafted_cmd" "$agent" await --run-id "$run_id"
  local rc=$?
  printf '[%s] await finished rc=%s for %s\n' "$(timestamp)" "$rc" "$run_id"
  if [[ "$rc" -eq 0 && -n "$then_cmd" ]]; then
    printf '[%s] running operator-approved next command via bash -lc: %s\n' "$(timestamp)" "$then_cmd"
    bash -lc "$then_cmd"
  fi
  return "$rc"
}

cmd_await_run() {
  local run_id="" agent="codex" then_cmd="" foreground=0 log_path=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --run-id)
        shift; [[ $# -gt 0 ]] || die "missing value for --run-id"
        run_id="$1"
        ;;
      --agent)
        shift; [[ $# -gt 0 ]] || die "missing value for --agent"
        agent="$1"
        ;;
      --then-cmd)
        shift; [[ $# -gt 0 ]] || die "missing value for --then-cmd"
        then_cmd="$1"
        ;;
      --foreground)
        foreground=1
        ;;
      --log)
        shift; [[ $# -gt 0 ]] || die "missing value for --log"
        log_path="$1"
        ;;
      -h|--help|help)
        usage
        exit 0
        ;;
      *)
        die "unknown argument: $1"
        ;;
    esac
    shift
  done

  [[ -n "$run_id" ]] || die "await-run requires --run-id"
  case "$agent" in claude|codex|gemini) ;; *) die "unknown agent: $agent" ;; esac

  if (( foreground )); then
    await_foreground "$agent" "$run_id" "$then_cmd"
    return
  fi

  if [[ -z "$log_path" ]]; then
    mkdir -p "$(repo_root)/.vibecrafted/reports"
    log_path="$(repo_root)/.vibecrafted/reports/operator-loop-await-${run_id}.log"
  else
    mkdir -p "$(dirname "$log_path")"
  fi

  (
    await_foreground "$agent" "$run_id" "$then_cmd"
  ) >> "$log_path" 2>&1 &

  printf 'Operator loop await armed.\n'
  printf '  run_id: %s\n' "$run_id"
  printf '  pid:    %s\n' "$!"
  printf '  log:    %s\n' "$log_path"
  if [[ -n "$then_cmd" ]]; then
    printf '  then:   %s\n' "$then_cmd"
  fi
}

case "$command_name" in
  help|-h|--help) usage ;;
  start) cmd_start "$@" ;;
  status) cmd_status "$@" ;;
  next) cmd_next "$@" ;;
  complete) cmd_complete "$@" ;;
  cancel) cmd_cancel "$@" ;;
  await-run) cmd_await_run "$@" ;;
  *)
    usage >&2
    exit 1
    ;;
esac
