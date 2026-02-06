#!/usr/bin/env bash
# File: rg.sh - Install ripgrep.
set -euo pipefail

install_rg() {
  if have_cmd rg; then
    log_msg already_installed "ripgrep"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "ripgrep"
    brew install ripgrep
    return
  fi

  if have_cmd pacman; then
    if have_cmd sudo; then
      log_msg install_via_apt "ripgrep"
      sudo pacman -S --needed --noconfirm ripgrep
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log_msg install_via_apt "ripgrep"
      pacman -S --needed --noconfirm ripgrep
      return
    fi
  fi

  if have_cmd apt-get; then
    if apt_has_pkg ripgrep; then
      if have_cmd sudo; then
        log_msg install_via_apt "ripgrep"
        sudo apt-get update
        sudo apt-get install -y ripgrep
        return
      fi
      if [ "$(id -u)" = "0" ]; then
        log_msg install_via_apt "ripgrep"
        apt-get update
        apt-get install -y ripgrep
        return
      fi
    fi
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "ripgrep"
    nix-env -iA nixpkgs.ripgrep
    return
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "ripgrep"
    micromamba install -y -c conda-forge ripgrep
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "ripgrep"
    conda install -y -c conda-forge ripgrep
    return
  fi

  warn_msg install_manual "ripgrep"
}
