#!/usr/bin/env bash
# File: install.sh - Orchestrate dotfiles installation.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "[dotfiles] %s\n" "$*"; }

prompt_install_nix() {
  if command -v nix-env >/dev/null 2>&1; then
    return
  fi
  printf "[dotfiles] Nix not found. Install Nix (single-user)? [y/N] " >&2
  read -r reply || true
  case "$reply" in
    y|Y)
      if command -v curl >/dev/null 2>&1; then
        sh -c "curl -L https://nixos.org/nix/install | sh"
      else
        printf "[dotfiles] WARN: curl not found; cannot install Nix\n" >&2
      fi
      ;;
    *)
      ;;
  esac
}

main() {
  log "Using dotfiles at $DOTFILES_DIR"
  prompt_install_nix
  "$DOTFILES_DIR/scripts/install/zsh.sh"
  "$DOTFILES_DIR/scripts/install/tmux.sh"
  "$DOTFILES_DIR/scripts/install/tools.sh"
  log "Linking configs"
  "$DOTFILES_DIR/link.sh"
  if [ -t 1 ] && [ "${DOTFILES_NO_EXEC_ZSH:-}" != "1" ] && [ -z "${ZSH_VERSION:-}" ]; then
    log "Switching to zsh"
    exec zsh
  fi
  log "Done."
}

main "$@"
