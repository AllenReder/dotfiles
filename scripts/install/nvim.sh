#!/usr/bin/env bash
# File: nvim.sh - Install Neovim for macOS/Linux without sudo.
set -euo pipefail

log() { printf "[dotfiles] %s\n" "$*"; }
warn() { printf "[dotfiles] %s\n" "$*" >&2; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_nvim_macos() {
  if have_cmd brew; then
    log "Installing Neovim via Homebrew"
    brew install neovim
  else
    warn "Homebrew not found; please install Homebrew first"
  fi
}

install_nvim_linux() {
  if have_cmd nvim; then
    log "Neovim already installed"
    return
  fi

  if have_cmd pacman; then
    if have_cmd sudo; then
      log "Installing Neovim via pacman"
      sudo pacman -S --needed --noconfirm neovim
      return
    fi
    if [ "$(id -u)" = "0" ]; then
      log "Installing Neovim via pacman"
      pacman -S --needed --noconfirm neovim
      return
    fi
  fi

  local version="${NVIM_VERSION:-0.11.5}"
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)
      arch="x86_64"
      ;;
    aarch64|arm64)
      arch="arm64"
      ;;
    *)
      warn "Unsupported arch for auto-install: $arch"
      warn "Please install Neovim manually"
      return
      ;;
  esac

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local tarball="nvim-linux-${arch}.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/v${version}/${tarball}"

  if have_cmd curl; then
    log "Downloading Neovim ${version} via curl"
    curl -fsSL "$url" -o "$tmp_dir/$tarball"
  elif have_cmd wget; then
    log "Downloading Neovim ${version} via wget"
    wget -qO "$tmp_dir/$tarball" "$url"
  else
    warn "Need curl or wget to download Neovim"
    return
  fi

  if ! have_cmd tar; then
    warn "Need tar to extract Neovim"
    return
  fi

  tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir"

  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  rm -rf "$HOME/.local/opt/nvim"
  mv "$tmp_dir/nvim-linux-${arch}" "$HOME/.local/opt/nvim"
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"

  log "Neovim installed to ~/.local/opt/nvim"
}

main() {
  case "$(uname -s)" in
    Darwin)
      install_nvim_macos
      ;;
    Linux)
      install_nvim_linux
      ;;
    *)
      warn "Unsupported OS"
      ;;
  esac
}

main "$@"
