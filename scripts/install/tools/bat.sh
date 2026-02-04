#!/usr/bin/env bash
# File: bat.sh - Install bat.
set -euo pipefail

install_bat() {
  if have_cmd bat || have_cmd batcat; then
    log_msg already_installed "bat"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "bat"
    brew install bat
    return
  fi

  if have_cmd pacman; then
    if have_cmd sudo; then
      log_msg install_via_apt "bat"
      sudo pacman -S --needed --noconfirm bat
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log_msg install_via_apt "bat"
      pacman -S --needed --noconfirm bat
      return
    fi
  fi

  if have_cmd apt-get; then
    if apt_has_pkg bat; then
      if have_cmd sudo; then
        log_msg install_via_apt "bat"
        sudo apt-get update
        sudo apt-get install -y bat
        return
      fi
      if [ "$(id -u)" = "0" ]; then
        log_msg install_via_apt "bat"
        apt-get update
        apt-get install -y bat
        return
      fi
    fi
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "bat"
    nix-env -iA nixpkgs.bat
    return
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "bat"
    micromamba install -y -c conda-forge bat
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "bat"
    conda install -y -c conda-forge bat
    return
  fi

  warn_msg install_manual "bat"
}
