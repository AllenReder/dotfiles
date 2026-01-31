#!/usr/bin/env bash
# File: eza.sh - Install eza.
set -euo pipefail

install_eza() {
  if have_cmd eza; then
    log_msg already_installed "eza"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "eza"
    brew install eza
    return
  fi

  if have_cmd apt-get; then
    if apt_has_pkg eza; then
      if have_cmd sudo; then
        log_msg install_via_apt "eza"
        sudo apt-get update
        sudo apt-get install -y eza
        return
      fi
      if [ "$(id -u)" = "0" ]; then
        log_msg install_via_apt "eza"
        apt-get update
        apt-get install -y eza
        return
      fi
    fi
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "eza"
    nix-env -iA nixpkgs.eza
    return
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "eza"
    micromamba install -y -c conda-forge eza
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "eza"
    conda install -y -c conda-forge eza
    return
  fi

  warn_msg install_manual "eza"
}
