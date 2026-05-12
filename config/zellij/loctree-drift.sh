#!/usr/bin/env bash
# loctree-drift.sh — loctree snapshot age indicator for zellij status bars.
#
# Plan 12 (META_22) — Wave 4 agent-native runtime cut.
#
# Walks a set of known repo roots, picks up `<repo>/.loctree/snapshot.json`,
# and reports the *oldest* snapshot age. The status line uses ANSI color
# hints so an operator can spot drift without reading numbers:
#
#   green   — all snapshots <5 min  -> "loctree: fresh"
#   yellow  — oldest <1h           -> "loctree: drift <repo> (<age>)"
#   red     — oldest >=1h or stale -> "loctree: stale <repo> (<age>)"
#
# Known roots default to the operator's workspace neighbourhood
# (~/vc-workspace) plus the current working tree. Override via
# LOCTREE_DRIFT_ROOTS (colon-separated paths). Each root is searched up to
# LOCTREE_DRIFT_DEPTH levels deep for `.loctree/snapshot.json`.
#
# Environment:
#   LOCTREE_DRIFT_ROOTS    colon-separated roots (default: $PWD:$HOME/vc-workspace)
#   LOCTREE_DRIFT_DEPTH    find -maxdepth (default 4)
#   LOCTREE_DRIFT_REFRESH  refresh interval in seconds (default 30)
#   LOCTREE_DRIFT_ONESHOT  emit one line and exit (used by smoke tests)
#
# Vibecrafted with AI Agents (c)2024-2026 LibraxisAI

set -euo pipefail

LOCTREE_DRIFT_DEPTH="${LOCTREE_DRIFT_DEPTH:-4}"
LOCTREE_DRIFT_REFRESH="${LOCTREE_DRIFT_REFRESH:-30}"

# Default search roots. The operator's PWD comes first so an active worktree
# is the primary signal; the workspace neighbourhood is the fallback.
default_roots() {
    local roots=("$PWD")
    if [[ -d "${HOME}/vc-workspace" ]]; then
        roots+=("${HOME}/vc-workspace")
    fi
    if [[ -d "${HOME}/Libraxis" ]]; then
        roots+=("${HOME}/Libraxis")
    fi
    printf '%s\n' "${roots[@]}"
}

# ANSI colors — same palette as aicx-status.sh.
if [[ -t 1 ]]; then
    C_DIM=$'\033[2m'
    C_AMBER=$'\033[38;5;214m'
    C_GREEN=$'\033[38;5;108m'
    C_RED=$'\033[38;5;167m'
    C_RESET=$'\033[0m'
else
    C_DIM=""
    C_AMBER=""
    C_GREEN=""
    C_RED=""
    C_RESET=""
fi

format_age() {
    local seconds=$1
    if [[ "$seconds" -lt 60 ]]; then
        printf '%ds' "$seconds"
    elif [[ "$seconds" -lt 3600 ]]; then
        printf '%dm' $((seconds / 60))
    elif [[ "$seconds" -lt 86400 ]]; then
        printf '%dh' $((seconds / 3600))
    else
        printf '%dd' $((seconds / 86400))
    fi
}

emit_status() {
    # Split colon-separated LOCTREE_DRIFT_ROOTS without mutating IFS
    # (semgrep ifs-tampering rule rejects local IFS even when scoped).
    # Manual split via `tr` keeps the helper side-effect-free.
    local roots=()
    if [[ -n "${LOCTREE_DRIFT_ROOTS:-}" ]]; then
        while IFS= read -r r; do
            [[ -n "$r" ]] && roots+=("$r")
        done < <(printf '%s\n' "$LOCTREE_DRIFT_ROOTS" | tr ':' '\n')
    else
        while IFS= read -r r; do
            roots+=("$r")
        done < <(default_roots)
    fi

    local snapshots=()
    local r
    for r in "${roots[@]}"; do
        [[ -d "$r" ]] || continue
        while IFS= read -r s; do
            [[ -n "$s" ]] && snapshots+=("$s")
        done < <(find "$r" -maxdepth "$LOCTREE_DRIFT_DEPTH" \
            -type f -path "*/.loctree/snapshot.json" 2>/dev/null)
    done

    if [[ "${#snapshots[@]}" -eq 0 ]]; then
        printf '%sloctree: no snapshots%s\n' "$C_DIM" "$C_RESET"
        return 0
    fi

    local now
    now=$(date +%s)

    local oldest_age=0
    local oldest_name="?"
    local s mtime age repo_dir base
    for s in "${snapshots[@]}"; do
        mtime=$(stat -f %m "$s" 2>/dev/null || stat -c %Y "$s" 2>/dev/null || echo 0)
        age=$((now - mtime))
        if [[ "$age" -gt "$oldest_age" ]]; then
            oldest_age=$age
            repo_dir=$(dirname "$(dirname "$s")")
            base=$(basename "$repo_dir")
            oldest_name="$base"
        fi
    done

    local color label
    if [[ "$oldest_age" -lt 300 ]]; then
        color="$C_GREEN"
        label="fresh"
    elif [[ "$oldest_age" -lt 3600 ]]; then
        color="$C_AMBER"
        label="drift"
    else
        color="$C_RED"
        label="stale"
    fi

    if [[ "$label" == "fresh" ]]; then
        printf '%sloctree: fresh (%d snapshots)%s\n' \
            "$color" "${#snapshots[@]}" "$C_RESET"
    else
        printf '%sloctree: %s %s (%s)%s\n' \
            "$color" "$label" "$oldest_name" "$(format_age "$oldest_age")" "$C_RESET"
    fi
}

main() {
    if [[ -n "${LOCTREE_DRIFT_ONESHOT:-}" ]]; then
        emit_status
        return 0
    fi

    while true; do
        printf '\033[2K\r'
        emit_status
        sleep "$LOCTREE_DRIFT_REFRESH"
    done
}

main "$@"
