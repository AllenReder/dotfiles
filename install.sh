#!/usr/bin/env bash
# File: install.sh - Orchestrate dotfiles installation.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "[dotfiles] %s\n" "$*"; }

main() {
  log "Using dotfiles at $DOTFILES_DIR"
  "$DOTFILES_DIR/scripts/install/zsh.sh"
  "$DOTFILES_DIR/scripts/install/tmux.sh"
  log "Linking configs"
  "$DOTFILES_DIR/link.sh"
  if [ -t 1 ] && [ "${DOTFILES_NO_EXEC_ZSH:-}" != "1" ] && [ -z "${ZSH_VERSION:-}" ]; then
    log "Switching to zsh"
    exec zsh
  fi
  log "Done."
}

main "$@"
