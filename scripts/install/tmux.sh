#!/usr/bin/env bash
# File: tmux.sh - Install oh-my-tmux.
set -euo pipefail

log() { printf "[dotfiles] %s\n" "$*"; }
warn() { printf "[dotfiles] WARN: %s\n" "$*" >&2; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_oh_my_tmux() {
  if [ -d "$HOME/.tmux" ]; then
    log "oh-my-tmux already installed"
  else
    if ! have_cmd git; then
      warn "git required to install oh-my-tmux"
      return
    fi
    log "Installing oh-my-tmux"
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  fi

  if [ -e "$HOME/.tmux/.tmux.conf" ]; then
    if [ ! -e "$HOME/.tmux.conf" ]; then
      ln -s "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
      log "Linked ~/.tmux.conf -> ~/.tmux/.tmux.conf"
    else
      warn "~/.tmux.conf exists; not overwriting"
    fi
  fi
}

main() {
  install_oh_my_tmux
}

main "$@"
