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
  log "Done."
}

main "$@"
