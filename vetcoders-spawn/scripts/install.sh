#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF_USAGE'
Usage: install.sh [--source <repo-root>] [--tool <codex|claude|gemini>]... [--dry-run] [--mirror] [--list]

Install the canonical skill directories from this repo into local tool homes:
  ~/.codex/skills
  ~/.claude/skills
  ~/.gemini/skills

Examples:
  bash vetcoders-spawn/scripts/install.sh
  bash vetcoders-spawn/scripts/install.sh --tool codex --tool claude
  bash vetcoders-spawn/scripts/install.sh --dry-run
  bash vetcoders-spawn/scripts/install.sh --mirror
EOF_USAGE
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

foundation_preflight() {
  local missing=0

  printf 'Foundation preflight:\n'

  if command -v aicx >/dev/null 2>&1; then
    printf '  [ok] aicx -> %s\n' "$(command -v aicx)"
  else
    printf '  [missing] aicx\n'
    printf '    fix: cargo install aicx\n'
    missing=1
  fi

  if command -v loctree-mcp >/dev/null 2>&1; then
    printf '  [ok] loctree-mcp -> %s\n' "$(command -v loctree-mcp)"
  else
    printf '  [missing] loctree-mcp\n'
    printf '    fix: cargo install loctree-mcp\n'
    missing=1
  fi

  if (( missing )); then
    printf '\nProceeding with install, but ai-contexters / loctree-backed flows will stay degraded until the missing foundations are installed.\n\n'
  else
    printf '\n'
  fi
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
dry_run=0
mirror=0
list_only=0
declare -a tools=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      shift
      [[ $# -gt 0 ]] || die "Missing value for --source"
      repo_root="$1"
      ;;
    --tool)
      shift
      [[ $# -gt 0 ]] || die "Missing value for --tool"
      case "$1" in
        codex|claude|gemini) tools+=("$1") ;;
        *) die "Unknown tool: $1" ;;
      esac
      ;;
    --dry-run|-n)
      dry_run=1
      ;;
    --mirror)
      mirror=1
      ;;
    --list)
      list_only=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
  shift
done

[[ -d "$repo_root" ]] || die "Repo root not found: $repo_root"

foundation_preflight

skills=()
while IFS= read -r skill; do
  [[ -n "$skill" ]] || continue
  skills+=("$skill")
done < <(
  find "$repo_root" -mindepth 1 -maxdepth 1 -type d \
    ! -name '.git' \
    ! -name '.loctree' \
    ! -name 'docs' \
    ! -name '.github' \
    -exec test -f '{}/SKILL.md' ';' -print | sort
)

[[ ${#skills[@]} -gt 0 ]] || die "No top-level skill directories found under $repo_root"

if (( list_only )); then
  printf 'Repo root: %s\n' "$repo_root"
  printf 'Skills to install:\n'
  for skill in "${skills[@]}"; do
    printf '  - %s\n' "$(basename "$skill")"
  done
  exit 0
fi

if [[ ${#tools[@]} -eq 0 ]]; then
  tools=(codex claude gemini)
fi

rsync_args=(-az --exclude '.DS_Store' --exclude '.loctree' -e ssh)
if (( mirror )); then
  rsync_args+=(--delete)
fi
if (( dry_run )); then
  rsync_args+=(--dry-run --itemize-changes)
fi

printf 'Installing skills from %s\n' "$repo_root"
for tool in "${tools[@]}"; do
  target="$HOME/.${tool}/skills"
  mkdir -p "$target"
  printf -- '-- %s -> %s\n' "$tool" "$target"
  for skill in "${skills[@]}"; do
    name="$(basename "$skill")"
    mkdir -p "$target/$name"
    rsync "${rsync_args[@]}" "$skill/" "$target/$name/"
  done
  printf '\n'
done

printf 'Install complete.\n'
