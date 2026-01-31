#!/usr/bin/env bash
# File: tmux.sh - Install oh-my-tmux.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/i18n.sh"
dotfiles_lang_init

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_tmux() {
  if have_cmd tmux; then
    local tmux_path
    tmux_path="$(command -v tmux)"
    if [[ "$tmux_path" == *"/micromamba/"* || "$tmux_path" == *"/mamba/"* || "$tmux_path" == *"/conda/"* ]]; then
      if have_cmd apt-get; then
        if have_cmd sudo; then
          log_msg install_via_apt "tmux"
          sudo apt-get update
          sudo apt-get install -y tmux
          return
        fi
        if [ "$(id -u)" = "0" ]; then
          log_msg install_via_apt "tmux"
          apt-get update
          apt-get install -y tmux
          return
        fi
      fi
    fi

    log_msg already_installed "tmux"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "tmux"
    brew install tmux
    return
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "tmux"
    nix-env -iA nixpkgs.tmux
    return
  fi

  if have_cmd apt-get; then
    if have_cmd sudo; then
      log_msg install_via_apt "tmux"
      sudo apt-get update
      sudo apt-get install -y tmux
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log_msg install_via_apt "tmux"
      apt-get update
      apt-get install -y tmux
      return
    fi
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "tmux"
    micromamba install -y -c conda-forge tmux
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "tmux"
    conda install -y -c conda-forge tmux
    return
  fi

  warn_msg install_manual "tmux"
}

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
  install_tmux
  install_oh_my_tmux
}

main "$@"
