#!/usr/bin/env bash
# File: nvitop.sh - Install nvitop.
set -euo pipefail

install_nvitop() {
  if have_cmd nvitop; then
    log_msg already_installed "nvitop"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "nvitop"
    brew install nvitop
    return
  fi

  if have_cmd apt-get; then
    if apt_has_pkg nvitop; then
      if have_cmd sudo; then
        log_msg install_via_apt "nvitop"
        sudo apt-get update
        sudo apt-get install -y nvitop
        return
      fi
      if [ "$(id -u)" = "0" ]; then
        log_msg install_via_apt "nvitop"
        apt-get update
        apt-get install -y nvitop
        return
      fi
    fi
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "nvitop"
    nix-env -iA nixpkgs.nvitop
    return
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "nvitop"
    micromamba install -y -c conda-forge nvitop
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "nvitop"
    conda install -y -c conda-forge nvitop
    return
  fi

  warn_msg install_manual "nvitop"
}
