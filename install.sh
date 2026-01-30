#!/usr/bin/env bash
# File: install.sh - Orchestrate dotfiles installation.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "[dotfiles] %s\n" "$*"; }

prompt_install_micromamba() {
  if command -v micromamba >/dev/null 2>&1; then
    return
  fi
  printf "[dotfiles] Micromamba not found. Install micromamba (user-level)? [y/N] " >&2
  read -r reply || true
  case "$reply" in
    y|Y)
      if command -v curl >/dev/null 2>&1; then
        # Official installer puts micromamba in ~/.local/bin
        bash -c "$(curl -fsSL https://micromamba.pfx.dev/install.sh)"
      else
        printf "[dotfiles] WARN: curl not found; cannot install micromamba\n" >&2
      fi
      ;;
    *)
      ;;
  esac
}

main() {
  log "Using dotfiles at $DOTFILES_DIR"
  prompt_install_micromamba
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
