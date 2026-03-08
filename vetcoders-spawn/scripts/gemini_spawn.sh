#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF_USAGE
Usage: gemini_spawn.sh [--mode <mode>] [--model <model>] <plan.md>

Portable Gemini spawn wrapper built around zsh -ic.
EOF_USAGE
}

mode="implement"
model="${GEMINI_MODEL:-gemini-3.1-pro-preview}"
plan_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      shift
      [[ $# -gt 0 ]] || spawn_die "Missing value for --mode"
      mode="$1"
      ;;
    --model)
      shift
      [[ $# -gt 0 ]] || spawn_die "Missing value for --model"
      model="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      [[ -z "$plan_file" ]] || spawn_die "Unexpected argument: $1"
      plan_file="$1"
      ;;
  esac
  shift
done

[[ -n "$plan_file" ]] || {
  usage
  exit 1
}
spawn_require_file "$plan_file"
spawn_prepare_paths gemini "$plan_file"
runtime_input="$SPAWN_TMP_DIR/${SPAWN_TS}_${SPAWN_SLUG}_gemini_prompt.md"
spawn_build_runtime_prompt "$SPAWN_PLAN" "$runtime_input" "$SPAWN_REPORT"
spawn_write_meta "$SPAWN_META" "launching" "gemini" "$mode" "$SPAWN_ROOT" "$SPAWN_PLAN" "$SPAWN_REPORT" "$SPAWN_TRANSCRIPT" "$SPAWN_LAUNCHER" "$model"

qroot="$(printf '%q' "$SPAWN_ROOT")"
qruntime="$(printf '%q' "$runtime_input")"
qreport="$(printf '%q' "$SPAWN_REPORT")"
qtranscript="$(printf '%q' "$SPAWN_TRANSCRIPT")"
qmeta="$(printf '%q' "$SPAWN_META")"
qmodel="$(printf '%q' "$model")"

cat > "$SPAWN_LAUNCHER" <<EOF_LAUNCH
#!/usr/bin/env bash
set -euo pipefail
meta=$qmeta
report=$qreport
transcript=$qtranscript
rm -f "\$transcript" "\$report"
cmd="set -o pipefail && cd $qroot && prompt=\$(cat $qruntime) && gemini -p \"\$prompt\" -y --model $qmodel -o text 2>&1 | tee -a $qtranscript"
if zsh -ic "\$cmd"; then
  if [[ ! -s "\$report" && -s "\$transcript" ]]; then
    cp "\$transcript" "\$report"
  fi
  python3 - "\$meta" "completed" "0" <<'PY'
import datetime as dt
import json
import sys
meta_path, status, exit_code = sys.argv[1:4]
with open(meta_path, 'r', encoding='utf-8') as fh:
    payload = json.load(fh)
payload['updated_at'] = dt.datetime.now(dt.timezone.utc).isoformat()
payload['status'] = status
payload['exit_code'] = int(exit_code)
with open(meta_path, 'w', encoding='utf-8') as fh:
    json.dump(payload, fh, indent=2, ensure_ascii=False)
    fh.write('\n')
PY
else
  exit_code=\$?
  if [[ ! -s "\$report" && -s "\$transcript" ]]; then
    cp "\$transcript" "\$report"
  fi
  python3 - "\$meta" "failed" "\$exit_code" <<'PY'
import datetime as dt
import json
import sys
meta_path, status, exit_code = sys.argv[1:4]
with open(meta_path, 'r', encoding='utf-8') as fh:
    payload = json.load(fh)
payload['updated_at'] = dt.datetime.now(dt.timezone.utc).isoformat()
payload['status'] = status
payload['exit_code'] = int(exit_code)
with open(meta_path, 'w', encoding='utf-8') as fh:
    json.dump(payload, fh, indent=2, ensure_ascii=False)
    fh.write('\n')
PY
  exit "\$exit_code"
fi
EOF_LAUNCH

chmod +x "$SPAWN_LAUNCHER"
spawn_print_launch gemini "$mode"
printf '  model:  %s\n' "$model"
spawn_open_terminal "$SPAWN_LAUNCHER"
printf 'Agent launched. Report will land at: %s\n' "$SPAWN_REPORT"
