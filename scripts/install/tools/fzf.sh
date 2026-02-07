#!/usr/bin/env bash
# File: fzf.sh - Install fzf.
set -euo pipefail

install_fzf_from_git() {
  local fzf_dir="${HOME}/.fzf"

  if ! have_cmd git; then
    return 1
  fi

  if [ -d "${fzf_dir}/.git" ]; then
    printf "[dotfiles] Updating fzf via git\n"
    git -C "${fzf_dir}" pull --ff-only
  elif [ -d "${fzf_dir}" ]; then
    printf "[dotfiles] WARN: %s exists but is not a git repo; skip git install\n" "${fzf_dir}" >&2
    return 1
  else
    printf "[dotfiles] Installing fzf via git\n"
    git clone --depth 1 https://github.com/junegunn/fzf.git "${fzf_dir}"
  fi

  if [ -x "${fzf_dir}/install" ]; then
    "${fzf_dir}/install" --bin --no-update-rc
  fi

  [ -x "${fzf_dir}/bin/fzf" ]
}

install_fzf() {
  if install_fzf_from_git; then
    log_msg already_installed "fzf"
    return
  fi

  if have_cmd brew; then
    log_msg install_via_brew "fzf"
    brew install fzf
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

  if have_cmd nix-env; then
    log_msg install_via_nix "fzf"
    nix-env -iA nixpkgs.fzf
    return
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
