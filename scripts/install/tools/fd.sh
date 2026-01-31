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

  if have_cmd nix-env; then
    log_msg install_via_nix "fd"
    nix-env -iA nixpkgs.fd
    return
  fi

  if have_cmd apt-get; then
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

  install_with_cargo fd-find || warn_msg install_manual "fd"
}
