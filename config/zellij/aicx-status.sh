#!/usr/bin/env bash
# aicx-status.sh — live AICX session counter for zellij status bars.
#
# Plan 12 (META_22) — Wave 4 agent-native runtime cut.
#
# Reads ~/.aicx/store/<org>/<project>/<YYYY_MMDD>/conversations/<agent>/*.md
# for the *current* day and counts sessions touched recently (mtime within
# AICX_STATUS_WINDOW seconds). Output is a single status line:
#
#   aicx: <active>/<total> [agents]
#
# Examples:
#   aicx: 2/5 (claude+codex)
#   aicx: 0/0
#
# Designed to be sourced (`exec`) by a thin zellij status pane. Repeats every
# AICX_STATUS_REFRESH seconds (default 5). Falls back to a benign idle line
# when the store is missing — never breaks the layout.
#
# Environment:
#   AICX_STORE            override the store root  (default ~/.aicx/store)
#   AICX_STATUS_WINDOW    "active" window in seconds (default 600 = 10 min)
#   AICX_STATUS_REFRESH   refresh interval in seconds (default 5)
#   AICX_STATUS_ONESHOT   if set, emit one line and exit (used by smoke tests)
#
# Vibecrafted with AI Agents (c)2024-2026 LibraxisAI

set -euo pipefail

AICX_STORE="${AICX_STORE:-${HOME}/.aicx/store}"
AICX_STATUS_WINDOW="${AICX_STATUS_WINDOW:-600}"
AICX_STATUS_REFRESH="${AICX_STATUS_REFRESH:-5}"

# ANSI color helpers — graceful degradation when stdout is not a TTY.
if [[ -t 1 ]]; then
    C_DIM=$'\033[2m'
    C_AMBER=$'\033[38;5;214m'
    C_GREEN=$'\033[38;5;108m'
    C_RESET=$'\033[0m'
else
    C_DIM=""
    C_AMBER=""
    C_GREEN=""
    C_RESET=""
fi

today_dir() {
    date +%Y_%m%d
}

# emit_status — print one status line for the current moment.
emit_status() {
    local today
    today=$(today_dir)

    if [[ ! -d "$AICX_STORE" ]]; then
        printf '%saicx: store offline%s\n' "$C_DIM" "$C_RESET"
        return 0
    fi

    local total=0
    local active=0
    local agents=()
    local agent_seen=""

    # Globstar over today's conversations dirs. Pattern stops at conversations/<agent>.
    # Use find to stay portable (avoids bash 4+ globstar dependency).
    local found
    found=$(find "$AICX_STORE" \
        -mindepth 5 -maxdepth 5 \
        -type d \
        -path "*/${today}/conversations/*" \
        2>/dev/null || true)

    if [[ -z "$found" ]]; then
        printf '%saicx: 0/0 idle%s\n' "$C_DIM" "$C_RESET"
        return 0
    fi

    local now
    now=$(date +%s)

    # Iterate agent dirs. Each `.md` file = one conversation segment.
    while IFS= read -r agent_dir; do
        [[ -z "$agent_dir" ]] && continue
        local agent_name
        agent_name=$(basename "$agent_dir")

        # Count .md (or .jsonl) artifacts; tolerate empty dirs.
        local files=()
        while IFS= read -r f; do
            files+=("$f")
        done < <(find "$agent_dir" -maxdepth 1 -type f \( -name "*.md" -o -name "*.jsonl" \) 2>/dev/null)

        local agent_total=${#files[@]}
        [[ "$agent_total" -eq 0 ]] && continue
        total=$((total + agent_total))

        # Active = at least one file modified within the active window.
        local agent_active=0
        local f mtime delta
        for f in "${files[@]}"; do
            mtime=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
            delta=$((now - mtime))
            if [[ "$delta" -le "$AICX_STATUS_WINDOW" ]]; then
                agent_active=$((agent_active + 1))
            fi
        done

        if [[ "$agent_active" -gt 0 ]]; then
            active=$((active + agent_active))
            if [[ "$agent_seen" != *"|${agent_name}|"* ]]; then
                agents+=("$agent_name")
                agent_seen="${agent_seen}|${agent_name}|"
            fi
        fi
    done <<<"$found"

    # Join agents[] with '+' without touching IFS (semgrep ifs-tampering
    # rule rejects local IFS even when scoped). Manual join keeps the
    # function pure and side-effect-free.
    local agents_str=""
    if [[ "${#agents[@]}" -gt 0 ]]; then
        local sep="" a
        agents_str=" ("
        for a in "${agents[@]}"; do
            agents_str+="${sep}${a}"
            sep="+"
        done
        agents_str+=")"
    fi

    local color="$C_DIM"
    if [[ "$active" -gt 0 ]]; then
        color="$C_GREEN"
    elif [[ "$total" -gt 0 ]]; then
        color="$C_AMBER"
    fi

    printf '%saicx: %d/%d%s%s\n' "$color" "$active" "$total" "$agents_str" "$C_RESET"
}

main() {
    if [[ -n "${AICX_STATUS_ONESHOT:-}" ]]; then
        emit_status
        return 0
    fi

    # Continuous mode: clear the pane between updates, refresh every N seconds.
    while true; do
        printf '\033[2K\r'
        emit_status
        sleep "$AICX_STATUS_REFRESH"
    done
}

main "$@"
