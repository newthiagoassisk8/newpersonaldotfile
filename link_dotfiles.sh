#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="false"
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="true"
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?}"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"

log() {
  printf '%s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

link_item() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]]; then
    local target
    target="$(readlink "$dest")"
    if [[ "$target" == "$src" ]]; then
      log "ok: $dest already links to $src"
      return 0
    fi
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    run mv "$dest" "${dest}${BACKUP_SUFFIX}"
    log "backup: $dest -> ${dest}${BACKUP_SUFFIX}"
  fi

  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  log "link: $src -> $dest"
}

declare -A FILE_MAP=(
  ["git/.gitconfig"]="$HOME_DIR/.gitconfig"
  ["tmux/.tmux.conf"]="$HOME_DIR/.tmux.conf"
  ["zsh/.zshrc"]="$HOME_DIR/.zshrc"
  ["zsh/.aliases.sh"]="$HOME_DIR/.aliases.sh"
  ["zsh/.adbScripts.sh"]="$HOME_DIR/.adbScripts.sh"
)

# Directory mapping
link_item "$REPO_DIR/nvim" "$HOME_DIR/.config/nvim"

for rel_path in "${!FILE_MAP[@]}"; do
  link_item "$REPO_DIR/$rel_path" "${FILE_MAP[$rel_path]}"
done
