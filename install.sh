#!/usr/bin/env bash
# File: install.sh - Installer for external tools (oh-my-zsh, powerlevel10k, oh-my-tmux).
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "[dotfiles] %s\n" "$*"; }
warn() { printf "[dotfiles] WARN: %s\n" "$*" >&2; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "oh-my-zsh already installed"
    return
  fi

  if have_cmd curl; then
    log "Installing oh-my-zsh via official script (curl)"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  elif have_cmd wget; then
    log "Installing oh-my-zsh via official script (wget)"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    warn "curl or wget required to install oh-my-zsh"
  fi
}

install_powerlevel10k() {
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ -d "$dest" ]; then
    log "powerlevel10k already installed"
    return
  fi
  if ! have_cmd git; then
    warn "git required to install powerlevel10k"
    return
  fi
  log "Installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest"
}

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
  log "Using dotfiles at $DOTFILES_DIR"
  install_oh_my_zsh
  install_powerlevel10k
  install_oh_my_tmux
  log "Done. Run ./link.sh to link your configs."
}

main "$@"
