#!/usr/bin/env bash
# File: yazi.sh - Install yazi.
set -euo pipefail

install_yazi() {
  if have_cmd yazi; then
    log_msg already_installed "yazi"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "yazi"
    brew install yazi
    return
  fi

  if have_cmd pacman; then
    if have_cmd sudo; then
      log_msg install_via_apt "yazi"
      sudo pacman -S --needed --noconfirm yazi
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log_msg install_via_apt "yazi"
      pacman -S --needed --noconfirm yazi
      return
    fi
  fi

  if have_cmd apt-get; then
    if apt_has_pkg yazi; then
      if have_cmd sudo; then
        log_msg install_via_apt "yazi"
        sudo apt-get update
        sudo apt-get install -y yazi
        return
      fi
      if [ "$(id -u)" = "0" ]; then
        log_msg install_via_apt "yazi"
        apt-get update
        apt-get install -y yazi
        return
      fi
    fi
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "yazi"
    nix-env -iA nixpkgs.yazi
    return
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "yazi"
    micromamba install -y -c conda-forge yazi
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "yazi"
    conda install -y -c conda-forge yazi
    return
  fi

  if have_cmd cargo; then
    log_msg install_via_cargo "yazi"
    cargo install yazi-fm yazi-cli
    return
  fi

  warn_msg install_manual "yazi"
}
