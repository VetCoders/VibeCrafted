#!/usr/bin/env bash
set -euo pipefail

spawn_die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

spawn_require_file() {
  local path="${1:-}"
  [[ -n "$path" ]] || spawn_die "Missing required file path."
  [[ -f "$path" ]] || spawn_die "File not found: $path"
}

spawn_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

spawn_abspath() {
  local path="$1"
  if [[ "$path" == /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$(cd "$(dirname "$path")" && pwd)" "$(basename "$path")"
  fi
}

spawn_slug_from_path() {
  local raw
  raw="$(basename "${1%.*}")"
  raw="$(printf '%s' "$raw" | tr ' ' '-' | tr -cs '[:alnum:]._-' '-')"
  raw="${raw#-}"
  raw="${raw%-}"
  [[ -n "$raw" ]] || raw="agent-task"
  printf '%s\n' "$raw"
}

spawn_timestamp() {
  date +%Y%m%d_%H%M
}

spawn_write_meta() {
  local meta_path="$1"
  local status="$2"
  local agent="$3"
  local mode="$4"
  local root="$5"
  local input_ref="$6"
  local report="$7"
  local transcript="$8"
  local launcher="$9"
  local model="${10:-__NONE__}"

  python3 - "$meta_path" "$status" "$agent" "$mode" "$root" "$input_ref" "$report" "$transcript" "$launcher" "$model" <<'PY'
import datetime as dt
import json
import sys

meta_path, status, agent, mode, root, input_ref, report, transcript, launcher, model = sys.argv[1:11]
payload = {
    "updated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
    "status": status,
    "agent": agent,
    "mode": mode,
    "root": root,
    "input": input_ref,
    "report": report,
    "transcript": transcript,
    "launcher": launcher,
}
if model != "__NONE__":
    payload["model"] = model
with open(meta_path, "w", encoding="utf-8") as fh:
    json.dump(payload, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY
}

spawn_finish_meta() {
  local meta_path="$1"
  local status="$2"
  local exit_code="${3:-0}"

  python3 - "$meta_path" "$status" "$exit_code" <<'PY'
import datetime as dt
import json
import sys

meta_path, status, exit_code = sys.argv[1:4]
with open(meta_path, "r", encoding="utf-8") as fh:
    payload = json.load(fh)
payload["updated_at"] = dt.datetime.now(dt.timezone.utc).isoformat()
payload["status"] = status
payload["exit_code"] = int(exit_code)
with open(meta_path, "w", encoding="utf-8") as fh:
    json.dump(payload, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY
}

spawn_prepare_paths() {
  local agent="$1"
  local prompt_file="$2"

  SPAWN_ROOT="$(spawn_repo_root)"
  SPAWN_PLAN="$(spawn_abspath "$prompt_file")"
  SPAWN_SLUG="$(spawn_slug_from_path "$prompt_file")"
  SPAWN_TS="$(spawn_timestamp)"
  SPAWN_REPORT_DIR="$SPAWN_ROOT/.ai-agents/reports"
  SPAWN_TMP_DIR="$SPAWN_ROOT/.ai-agents/tmp"
  SPAWN_BASE="$SPAWN_REPORT_DIR/${SPAWN_TS}_${SPAWN_SLUG}_${agent}"
  SPAWN_REPORT="${SPAWN_BASE}.md"
  SPAWN_TRANSCRIPT="${SPAWN_BASE}.transcript.log"
  SPAWN_META="${SPAWN_BASE}.meta.json"
  SPAWN_LAUNCHER="$SPAWN_TMP_DIR/${SPAWN_TS}_${SPAWN_SLUG}_${agent}_launch.sh"
  mkdir -p "$SPAWN_REPORT_DIR" "$SPAWN_TMP_DIR"
}

spawn_build_runtime_prompt() {
  local source_file="$1"
  local runtime_file="$2"
  local report_path="$3"

  cat "$source_file" > "$runtime_file"
  cat >> "$runtime_file" <<EOF_PROMPT

At the end of the task, write your final human-readable report to this exact path:
$report_path

Keep streaming useful progress to stdout while you work. If you cannot write the
report file directly, finish normally and let the transcript act as the fallback
artifact.
EOF_PROMPT
}

spawn_open_terminal() {
  local launcher="$1"
  command -v osascript >/dev/null 2>&1 || spawn_die "osascript is required for visible Terminal spawns."

  local command_json
  command_json="$(python3 - "$launcher" <<'PY'
import json
import shlex
import sys

launcher = sys.argv[1]
print(json.dumps("zsh " + shlex.quote(launcher)))
PY
)"

  osascript <<EOF_APPLE
 tell application "Terminal"
   activate
   do script $command_json
 end tell
EOF_APPLE
}

spawn_print_launch() {
  local agent="$1"
  local mode="$2"
  printf 'Spawning %s-%s in Terminal...\n' "$agent" "$mode"
  printf '  plan:   %s\n' "$SPAWN_PLAN"
  printf '  report: %s\n' "$SPAWN_REPORT"
  printf '  trace:  %s\n' "$SPAWN_TRANSCRIPT"
  printf '  meta:   %s\n' "$SPAWN_META"
  printf '  launch: %s\n' "$SPAWN_LAUNCHER"
}
