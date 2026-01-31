#!/usr/bin/env bash
# File: zoxide.sh - Install zoxide.
set -euo pipefail

install_zoxide() {
  if have_cmd zoxide; then
    log_msg already_installed "zoxide"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "zoxide"
    brew install zoxide
    return
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "zoxide"
    nix-env -iA nixpkgs.zoxide
    return
  fi

  if have_cmd apt-get; then
    if have_cmd sudo; then
      log_msg install_via_apt "zoxide"
      sudo apt-get update
      sudo apt-get install -y zoxide
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log_msg install_via_apt "zoxide"
      apt-get update
      apt-get install -y zoxide
      return
    fi
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "zoxide"
    micromamba install -y -c conda-forge zoxide
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "zoxide"
    conda install -y -c conda-forge zoxide
    return
  fi

  install_with_cargo zoxide || warn_msg install_manual "zoxide"
}
