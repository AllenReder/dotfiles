#!/usr/bin/env bash
# File: tmux.sh - Install oh-my-tmux.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/i18n.sh"
dotfiles_lang_init

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_oh_my_tmux() {
  if [ -d "$HOME/.tmux" ]; then
    log_msg tmux_installed
  else
    if ! have_cmd git; then
      warn_msg tmux_need_git
      return
    fi
    log_msg tmux_install
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  fi

  if [ -e "$HOME/.tmux/.tmux.conf" ]; then
    if [ ! -e "$HOME/.tmux.conf" ]; then
      ln -s "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
      log_msg tmux_linked
    else
      warn_msg tmux_conf_exists
    fi
  fi
}

main() {
  install_oh_my_tmux
}

main "$@"
