#!/usr/bin/env bash
# File: fd.sh - Install fd.
set -euo pipefail

install_fdfind() {
  if have_cmd fd || have_cmd fdfind; then
    log_msg already_installed "fd"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "fd"
    brew install fd
    return
  fi

  if have_cmd pacman; then
    if have_cmd sudo; then
      log_msg install_via_apt "fd"
      sudo pacman -S --needed --noconfirm fd
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log_msg install_via_apt "fd"
      pacman -S --needed --noconfirm fd
      return
    fi
  fi

  if have_cmd apt-get; then
    if apt_has_pkg fd-find; then
      if have_cmd sudo; then
        log_msg install_via_apt "fd"
        sudo apt-get update
        sudo apt-get install -y fd-find
        return
      fi
      if [ "$(id -u)" = "0" ]; then
        log_msg install_via_apt "fd"
        apt-get update
        apt-get install -y fd-find
        return
      fi
    fi
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "fd"
    nix-env -iA nixpkgs.fd
    return
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "fd"
    micromamba install -y -c conda-forge fd-find
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "fd"
    conda install -y -c conda-forge fd-find
    return
  fi

  warn_msg install_manual "fd"
}
