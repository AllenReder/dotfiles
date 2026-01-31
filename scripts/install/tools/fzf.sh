#!/usr/bin/env bash
# File: fzf.sh - Install fzf.
set -euo pipefail

install_fzf() {
  if have_cmd fzf; then
    log_msg already_installed "fzf"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "fzf"
    brew install fzf
    return
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "fzf"
    nix-env -iA nixpkgs.fzf
    return
  fi

  if have_cmd apt-get; then
    if have_cmd sudo; then
      log_msg install_via_apt "fzf"
      sudo apt-get update
      sudo apt-get install -y fzf
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log_msg install_via_apt "fzf"
      apt-get update
      apt-get install -y fzf
      return
    fi
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "fzf"
    micromamba install -y -c conda-forge fzf
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "fzf"
    conda install -y -c conda-forge fzf
    return
  fi
  warn_msg install_manual "fzf"
}
