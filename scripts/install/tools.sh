#!/usr/bin/env bash
# File: tools.sh - Install common CLI tools (zoxide, eza, fdfind).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/i18n.sh"
dotfiles_lang_init

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_with_cargo() {
  if ! have_cmd cargo; then
    warn_msg cargo_missing "$1"
    return 1
  fi
  log_msg install_via_cargo "$1"
  cargo install "$1"
}

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

  install_with_cargo eza || warn_msg install_manual "eza"
}

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

  install_with_cargo fzf || warn_msg install_manual "fzf"
}

main() {
  install_zoxide
  install_eza
  install_fdfind
  install_fzf
}

main "$@"
