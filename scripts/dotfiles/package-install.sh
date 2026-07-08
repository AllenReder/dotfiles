#!/usr/bin/env bash
# Install baseline packages from simple per-manager manifests.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

log() { printf '[dotfiles] %s\n' "$*"; }
warn() { printf '[dotfiles] WARN: %s\n' "$*" >&2; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }

profile_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/profile.env"
if [ -r "$profile_file" ]; then
  # shellcheck disable=SC1090
  . "$profile_file"
fi

DOTFILES_PROFILE="${DOTFILES_PROFILE:-server}"
DOTFILES_FEATURES="${DOTFILES_FEATURES:-}"
DOTFILES_DRY_RUN="${DOTFILES_DRY_RUN:-0}"

is_yes() {
  case "${1:-}" in
    1|y|Y|yes|YES|true|TRUE) return 0 ;;
    *) return 1 ;;
  esac
}

run_as_root() {
  if is_yes "$DOTFILES_DRY_RUN"; then
    log "DRY RUN: $*"
    return 0
  fi
  if [ "$(id -u)" = "0" ]; then
    "$@"
  elif have_cmd sudo; then
    sudo "$@"
  else
    return 1
  fi
}

manager() {
  case "$(uname -s)" in
    Darwin) have_cmd brew && printf 'brew\n' ;;
    Linux)
      if have_cmd apt-get; then
        printf 'apt\n'
      elif have_cmd pacman; then
        printf 'pacman\n'
      fi
      ;;
  esac
}

read_manifest() {
  local mgr="$1" file line
  local files=(
    "$REPO_DIR/packages/$mgr/base.txt"
    "$REPO_DIR/packages/$mgr/profile-$DOTFILES_PROFILE.txt"
  )
  local feature
  for feature in $DOTFILES_FEATURES; do
    files+=("$REPO_DIR/packages/$mgr/feature-$feature.txt")
  done

  for file in "${files[@]}"; do
    [ -r "$file" ] || continue
    while IFS= read -r line || [ -n "$line" ]; do
      line="${line%%#*}"
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      [ -n "$line" ] || continue
      printf '%s\n' "$line"
    done < "$file"
  done | awk '!seen[$0]++'
}

install_brew() {
  have_cmd brew || return 0
  local formulas=() casks=() item
  while IFS= read -r item; do
    case "$item" in
      cask:*) casks+=("${item#cask:}") ;;
      *) formulas+=("$item") ;;
    esac
  done < <(read_manifest brew)

  if [ "${#formulas[@]}" -gt 0 ]; then
    log "Installing Homebrew formulae: ${formulas[*]}"
    if is_yes "$DOTFILES_DRY_RUN"; then
      log "DRY RUN: brew install ${formulas[*]}"
    else
      brew install "${formulas[@]}"
    fi
  fi
  if [ "${#casks[@]}" -gt 0 ]; then
    log "Installing Homebrew casks: ${casks[*]}"
    if is_yes "$DOTFILES_DRY_RUN"; then
      log "DRY RUN: brew install --cask ${casks[*]}"
    else
      brew install --cask "${casks[@]}"
    fi
  fi
}

apt_available() {
  apt-cache show "$1" >/dev/null 2>&1
}

install_apt() {
  have_cmd apt-get || return 0
  local pkgs=() skipped=() item
  while IFS= read -r item; do
    if apt_available "$item"; then
      pkgs+=("$item")
    else
      skipped+=("$item")
    fi
  done < <(read_manifest apt)

  if [ "${#skipped[@]}" -gt 0 ]; then
    warn "apt packages unavailable, skipped: ${skipped[*]}"
  fi
  [ "${#pkgs[@]}" -gt 0 ] || return 0
  log "Installing apt packages: ${pkgs[*]}"
  run_as_root apt-get update
  run_as_root apt-get install -y "${pkgs[@]}"
}

install_pacman() {
  have_cmd pacman || return 0
  local pkgs=() item
  while IFS= read -r item; do
    pkgs+=("$item")
  done < <(read_manifest pacman)
  [ "${#pkgs[@]}" -gt 0 ] || return 0
  log "Installing pacman packages: ${pkgs[*]}"
  run_as_root pacman -Sy --needed --noconfirm "${pkgs[@]}"
}

install_paru() {
  local pkgs=() item
  while IFS= read -r item; do
    pkgs+=("$item")
  done < <(read_manifest paru)
  [ "${#pkgs[@]}" -gt 0 ] || return 0
  have_cmd paru || {
    warn "paru not found; skipped AUR packages: ${pkgs[*]}"
    return 0
  }
  log "Installing AUR packages via paru: ${pkgs[*]}"
  if is_yes "$DOTFILES_DRY_RUN"; then
    log "DRY RUN: paru -S --needed --noconfirm ${pkgs[*]}"
  else
    paru -S --needed --noconfirm "${pkgs[@]}"
  fi
}

find_antidote() {
  local paths=(
    "${ANTIDOTE_HOME:-}"
    "${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
    "$HOME/.antidote"
    "/opt/homebrew/opt/antidote/share/antidote"
    "/opt/homebrew/share/antidote"
    "/usr/local/opt/antidote/share/antidote"
    "/usr/local/share/antidote"
  )
  local dir
  for dir in "${paths[@]}"; do
    [ -n "$dir" ] || continue
    [ -r "$dir/antidote.zsh" ] && return 0
  done
  return 1
}

install_antidote() {
  find_antidote && return 0
  have_cmd git || {
    warn "git not found; cannot install Antidote"
    return 0
  }
  local dest="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
  log "Installing Antidote to $dest"
  if is_yes "$DOTFILES_DRY_RUN"; then
    log "DRY RUN: git clone --depth=1 https://github.com/mattmc3/antidote.git $dest"
  else
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$dest"
  fi
}

install_starship_fallback() {
  have_cmd starship && return 0
  have_cmd curl || {
    warn "curl not found; cannot install Starship fallback"
    return 0
  }
  mkdir -p "$HOME/.local/bin"
  log "Installing Starship to ~/.local/bin"
  if is_yes "$DOTFILES_DRY_RUN"; then
    log "DRY RUN: curl -sS https://starship.rs/install.sh | sh -s -- -b $HOME/.local/bin -y"
  else
    curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y
  fi
}

install_oh_my_tmux() {
  have_cmd git || return 0
  if [ ! -d "$HOME/.tmux/.git" ]; then
    if [ -e "$HOME/.tmux" ]; then
      warn "$HOME/.tmux exists but is not a git checkout; skipped oh-my-tmux"
      return 0
    fi
    log "Installing oh-my-tmux"
    if is_yes "$DOTFILES_DRY_RUN"; then
      log "DRY RUN: git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux"
    else
      git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    fi
  else
    log "Updating oh-my-tmux"
    if is_yes "$DOTFILES_DRY_RUN"; then
      log "DRY RUN: git -C $HOME/.tmux pull --ff-only"
    else
      git -C "$HOME/.tmux" pull --ff-only || warn "oh-my-tmux update failed"
    fi
  fi

  if [ ! -e "$HOME/.tmux.conf" ] && [ -e "$HOME/.tmux/.tmux.conf" ]; then
    if is_yes "$DOTFILES_DRY_RUN"; then
      log "DRY RUN: ln -s $HOME/.tmux/.tmux.conf $HOME/.tmux.conf"
    else
      ln -s "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
    fi
  fi
}

main() {
  local mgr
  mgr="$(manager || true)"
  case "$mgr" in
    brew) install_brew ;;
    apt) install_apt ;;
    pacman) install_pacman; install_paru ;;
    *) warn "No supported package manager detected; skipped package manifests" ;;
  esac

  install_starship_fallback
  install_antidote
  install_oh_my_tmux
}

main "$@"
