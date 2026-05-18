#!/usr/bin/env bash
# vibecrafted-husky-template :: install.sh
#
# Installs the husky template into the current repo. Idempotent — re-running
# refreshes lib/, scripts/, and the hook entry points while preserving the
# repo's .husky/config.env and .husky/local/ extension hooks.
#
# Usage:
#   bash /path/to/vibecrafted/templates/husky/install.sh
#   bash "$VIBECRAFTED_ROOT/templates/husky/install.sh"  --force
#
# Options:
#   --force         Overwrite .husky/config.env even if present (use with care)
#   --no-gitignore  Skip .gitignore patching
#   --dry-run       Show what would happen without writing anything
#
# Vibecrafted with AI Agents by VetCoders (c)2024-2026 LibraxisAI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LIB="$SCRIPT_DIR/lib"
SOURCE_HOOKS="$SCRIPT_DIR/hooks"
SOURCE_SCRIPTS="$SCRIPT_DIR/scripts"
SOURCE_CONFIG="$SCRIPT_DIR/config/template.husky.env"

FORCE=0
NO_GITIGNORE=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --force)        FORCE=1 ;;
    --no-gitignore) NO_GITIGNORE=1 ;;
    --dry-run)      DRY_RUN=1 ;;
    -h|--help)
      sed -n '1,/^# Vibecrafted/p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TARGET_HUSKY="$REPO_ROOT/.husky"
TARGET_LIB="$TARGET_HUSKY/lib"
TARGET_HOOKS_DIR="$TARGET_HUSKY"
TARGET_SCRIPTS="$TARGET_HUSKY/scripts"
TARGET_CONFIG="$TARGET_HUSKY/config.env"
TARGET_LOCAL_DIR="$TARGET_HUSKY/local"
TARGET_WARNS_DIR="$TARGET_HUSKY/warns"

say() { printf '[husky-install] %s\n' "$*"; }
do_cp() {
  local src="$1"
  local dst="$2"
  if [ "$DRY_RUN" = "1" ]; then
    say "DRY: cp $src → $dst"
  else
    install -m "${3:-0644}" "$src" "$dst"
  fi
}
do_mkdir() {
  if [ "$DRY_RUN" = "1" ]; then
    say "DRY: mkdir -p $1"
  else
    mkdir -p "$1"
  fi
}

say "Installing vibecrafted-husky-template into: $REPO_ROOT"

# --- husky check --------------------------------------------------------------
if [ ! -f "$REPO_ROOT/package.json" ] || ! grep -q '"husky"' "$REPO_ROOT/package.json" 2>/dev/null; then
  say "Warning: 'husky' is not listed in package.json devDependencies."
  say "  Hooks will still install, but you may want to add husky for"
  say "  automated activation: pnpm add -D husky && pnpm exec husky"
fi

# --- target dirs --------------------------------------------------------------
do_mkdir "$TARGET_HUSKY"
do_mkdir "$TARGET_LIB"
do_mkdir "$TARGET_SCRIPTS"
do_mkdir "$TARGET_LOCAL_DIR"
do_mkdir "$TARGET_WARNS_DIR"

# --- copy lib + scripts (always refresh) --------------------------------------
say "Refreshing lib/*"
for f in "$SOURCE_LIB"/*.sh; do
  do_cp "$f" "$TARGET_LIB/$(basename "$f")" 0644
done

say "Refreshing scripts/*"
for f in "$SOURCE_SCRIPTS"/*; do
  [ -f "$f" ] || continue
  do_cp "$f" "$TARGET_SCRIPTS/$(basename "$f")" 0755
done

# --- hook entries -------------------------------------------------------------
HOOKS=(pre-commit pre-push pre-merge-commit prepare-commit-msg post-commit commit-msg)
for hook in "${HOOKS[@]}"; do
  src="$SOURCE_HOOKS/$hook"
  [ -f "$src" ] || { say "Skipping missing $hook"; continue; }
  dst="$TARGET_HOOKS_DIR/$hook"
  say "Refreshing $hook"
  do_cp "$src" "$dst" 0755
done

# --- config.env (preserve unless --force) -------------------------------------
if [ -f "$TARGET_CONFIG" ] && [ "$FORCE" = "0" ]; then
  say "Keeping existing .husky/config.env (use --force to overwrite)"
else
  say "Writing default .husky/config.env"
  do_cp "$SOURCE_CONFIG" "$TARGET_CONFIG" 0644
fi

# --- .gitignore ---------------------------------------------------------------
if [ "$NO_GITIGNORE" = "0" ]; then
  GITIGNORE="$REPO_ROOT/.gitignore"
  if [ ! -f "$GITIGNORE" ]; then
    if [ "$DRY_RUN" = "1" ]; then
      say "DRY: would create .gitignore with .husky/warns/"
    else
      printf '.husky/warns/\n' > "$GITIGNORE"
    fi
  else
    if ! grep -qx '.husky/warns/' "$GITIGNORE" 2>/dev/null; then
      if [ "$DRY_RUN" = "1" ]; then
        say "DRY: would append .husky/warns/ to .gitignore"
      else
        printf '\n# vibecrafted-husky-template warns retention\n.husky/warns/\n' >> "$GITIGNORE"
      fi
    fi
  fi
fi

# --- README pointer -----------------------------------------------------------
README_NOTICE="$TARGET_HUSKY/README.md"
if [ ! -f "$README_NOTICE" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    say "DRY: would drop README pointer at .husky/README.md"
  else
    cat > "$README_NOTICE" <<'EOF'
# .husky/ (managed by vibecrafted-husky-template)

Hooks here are installed from `vibecrafted/templates/husky/`.

- Tweak behavior in `config.env` (opt-in flags).
- Drop repo-specific extensions in `local/<hook>.d/*.sh` (auto-discovered).
- Failed warn logs land in `warns/` (gitignored, rolling retention).

Re-run the installer to refresh:
```
bash /path/to/vibecrafted/templates/husky/install.sh
```
EOF
  fi
fi

say "Done."
if [ "$DRY_RUN" = "1" ]; then
  say "(dry-run — no files were modified)"
fi
say ""
say "Next steps:"
say "  1. Edit .husky/config.env to enable the gates your repo needs."
say "  2. Add repo-specific extensions in .husky/local/<hook>.d/*.sh if needed."
say "  3. Smoke test: git commit --allow-empty -m \"chore(husky): smoke\""
