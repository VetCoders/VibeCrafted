#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF_USAGE
Usage: codex_spawn.sh [--mode <mode>] <plan.md>

Modes are labels for the artifact metadata, e.g. implement, review, or plan.
The runtime path is always: zsh -ic "... codex exec ..."
EOF_USAGE
}

mode="implement"
plan_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      shift
      [[ $# -gt 0 ]] || spawn_die "Missing value for --mode"
      mode="$1"
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
spawn_prepare_paths codex "$plan_file"
spawn_write_meta "$SPAWN_META" "launching" "codex" "$mode" "$SPAWN_ROOT" "$SPAWN_PLAN" "$SPAWN_REPORT" "$SPAWN_TRANSCRIPT" "$SPAWN_LAUNCHER"

qroot="$(printf '%q' "$SPAWN_ROOT")"
qplan="$(printf '%q' "$SPAWN_PLAN")"
qreport="$(printf '%q' "$SPAWN_REPORT")"
qtranscript="$(printf '%q' "$SPAWN_TRANSCRIPT")"
qmeta="$(printf '%q' "$SPAWN_META")"

cat > "$SPAWN_LAUNCHER" <<EOF_LAUNCH
#!/usr/bin/env bash
set -euo pipefail
meta=$qmeta
report=$qreport
transcript=$qtranscript
rm -f "\$transcript" "\$report"
cmd="set -o pipefail && cd $qroot && codex exec -C $qroot --dangerously-bypass-approvals-and-sandbox --output-last-message $qreport - < $qplan 2>&1 | tee -a $qtranscript"
if zsh -ic "\$cmd"; then
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
spawn_print_launch codex "$mode"
spawn_open_terminal "$SPAWN_LAUNCHER"
printf 'Agent launched. Report will land at: %s\n' "$SPAWN_REPORT"
