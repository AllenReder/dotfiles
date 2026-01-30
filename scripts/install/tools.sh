#!/usr/bin/env bash
# File: tools.sh - Install common CLI tools (zoxide, eza, fdfind).
set -euo pipefail

log() { printf "[dotfiles] %s\n" "$*"; }
warn() { printf "[dotfiles] WARN: %s\n" "$*" >&2; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_with_cargo() {
  if ! have_cmd cargo; then
    warn "cargo not found; cannot install $1 via cargo"
    return 1
  fi
  log "Installing $1 via cargo"
  cargo install "$1"
}

install_zoxide() {
  if have_cmd zoxide; then
    log "zoxide already installed"
    return
  fi

  if have_cmd brew; then
    log "Installing zoxide via Homebrew"
    brew install zoxide
    return
  fi

  if have_cmd nix-env; then
    log "Installing zoxide via nix-env"
    nix-env -iA nixpkgs.zoxide
    return
  fi

  if have_cmd micromamba; then
    log "Installing zoxide via micromamba"
    micromamba install -y -c conda-forge zoxide
    return
  fi

  if have_cmd conda; then
    log "Installing zoxide via conda"
    conda install -y -c conda-forge zoxide
    return
  fi

  install_with_cargo zoxide || warn "Install zoxide manually"
}

install_eza() {
  if have_cmd eza; then
    log "eza already installed"
    return
  fi

  if have_cmd brew; then
    log "Installing eza via Homebrew"
    brew install eza
    return
  fi

  if have_cmd nix-env; then
    log "Installing eza via nix-env"
    nix-env -iA nixpkgs.eza
    return
  fi

  if have_cmd micromamba; then
    log "Installing eza via micromamba"
    micromamba install -y -c conda-forge eza
    return
  fi

  if have_cmd conda; then
    log "Installing eza via conda"
    conda install -y -c conda-forge eza
    return
  fi

  install_with_cargo eza || warn "Install eza manually"
}

install_fdfind() {
  if have_cmd fd || have_cmd fdfind; then
    log "fd/fdfind already installed"
    return
  fi

  if have_cmd brew; then
    log "Installing fd via Homebrew"
    brew install fd
    return
  fi

  if have_cmd nix-env; then
    log "Installing fd via nix-env"
    nix-env -iA nixpkgs.fd
    return
  fi

  if have_cmd micromamba; then
    log "Installing fd via micromamba"
    micromamba install -y -c conda-forge fd-find
    return
  fi

  if have_cmd conda; then
    log "Installing fd via conda"
    conda install -y -c conda-forge fd-find
    return
  fi

  install_with_cargo fd-find || warn "Install fd manually"
}

install_fzf() {
  if have_cmd fzf; then
    log "fzf already installed"
    return
  fi

  if have_cmd brew; then
    log "Installing fzf via Homebrew"
    brew install fzf
    return
  fi

  if have_cmd nix-env; then
    log "Installing fzf via nix-env"
    nix-env -iA nixpkgs.fzf
    return
  fi

  if have_cmd micromamba; then
    log "Installing fzf via micromamba"
    micromamba install -y -c conda-forge fzf
    return
  fi

  if have_cmd conda; then
    log "Installing fzf via conda"
    conda install -y -c conda-forge fzf
    return
  fi

  install_with_cargo fzf || warn "Install fzf manually"
}

main() {
  install_zoxide
  install_eza
  install_fdfind
  install_fzf
}

main "$@"
