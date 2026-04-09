#!/usr/bin/env bash
set -euo pipefail

_SPAWN_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$_SPAWN_LIB_DIR/zellij.sh"
source "$_SPAWN_LIB_DIR/launcher.sh"
source "$_SPAWN_LIB_DIR/session.sh"
source "$_SPAWN_LIB_DIR/prompt.sh"
source "$_SPAWN_LIB_DIR/lock.sh"
source "$_SPAWN_LIB_DIR/frontier.sh"
source "$_SPAWN_LIB_DIR/meta.sh"
source "$_SPAWN_LIB_DIR/paths.sh"
source "$_SPAWN_LIB_DIR/util.sh"

# Central artifact store: $HOME/.vibecrafted/artifacts/<org>/<repo>/<YYYY_MMDD>/
# Override with VIBECRAFTED_HOME env var for custom location
# Falls back to <repo>/.vibecrafted/ if git remote unavailable
VIBECRAFTED_HOME="${VIBECRAFTED_HOME:-$HOME/.vibecrafted}"

spawn_normalize_ambient_context

