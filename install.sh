#!/usr/bin/env bash
# File: install.sh - Installer for external tools (oh-my-zsh, powerlevel10k, oh-my-tmux).
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "[dotfiles] %s\n" "$*"; }
warn() { printf "[dotfiles] WARN: %s\n" "$*" >&2; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_zsh_user() {
  if have_cmd brew; then
    log "Installing zsh via Homebrew (user-level)"
    brew install zsh
    return
  fi

  if have_cmd nix-env; then
    log "Installing zsh via nix-env (user-level)"
    nix-env -iA nixpkgs.zsh
    return
  fi

  if have_cmd micromamba; then
    log "Installing zsh via micromamba (user-level)"
    micromamba install -y -c conda-forge zsh
    return
  fi

  if have_cmd conda; then
    log "Installing zsh via conda (user-level)"
    conda install -y -c conda-forge zsh
    return
  fi

  if [ "${DOTFILES_ZSH_BUILD:-}" != "1" ]; then
    warn "No user-level package manager found. Set DOTFILES_ZSH_BUILD=1 to build zsh from source under ~/.local"
    return
  fi

  local version="${ZSH_VERSION:-5.9}"
  local url="https://sourceforge.net/projects/zsh/files/zsh/${version}/zsh-${version}.tar.xz/download"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if have_cmd curl; then
    log "Downloading zsh ${version} via curl"
    curl -fsSL "$url" -o "$tmp_dir/zsh.tar.xz"
  elif have_cmd wget; then
    log "Downloading zsh ${version} via wget"
    wget -qO "$tmp_dir/zsh.tar.xz" "$url"
  else
    warn "curl or wget required to download zsh source"
    return
  fi

  if ! have_cmd tar; then
    warn "tar required to extract zsh source"
    return
  fi

  if ! have_cmd make || ! have_cmd cc; then
    warn "build tools required (make, cc). Install them or use a user-level package manager"
    return
  fi

  log "Building zsh ${version} from source"
  tar -xf "$tmp_dir/zsh.tar.xz" -C "$tmp_dir"
  (cd "$tmp_dir/zsh-${version}" && ./configure --prefix="$HOME/.local" && make && make install)
  log "Installed zsh to $HOME/.local/bin/zsh (ensure ~/.local/bin is on PATH)"
}

install_zsh() {
  if have_cmd zsh; then
    log "zsh already installed"
    return
  fi

  case "$(uname -s)" in
    Darwin)
      if have_cmd brew; then
        log "Installing zsh via Homebrew"
        brew install zsh
      else
        warn "Homebrew not found; install zsh manually (brew install zsh)"
      fi
      ;;
    Linux)
      if have_cmd apt-get; then
        if have_cmd sudo; then
          log "Installing zsh via apt-get (sudo)"
          sudo apt-get update
          sudo apt-get install -y zsh
        else
          warn "sudo not available; attempting user-level install"
          install_zsh_user
        fi
      else
        warn "apt-get not found; attempting user-level install"
        install_zsh_user
      fi
      ;;
    *)
      warn "Unknown OS; install zsh manually"
      ;;
  esac
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "oh-my-zsh already installed"
    return
  fi

  if have_cmd curl; then
    log "Installing oh-my-zsh via official script (curl)"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  elif have_cmd wget; then
    log "Installing oh-my-zsh via official script (wget)"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    warn "curl or wget required to install oh-my-zsh"
  fi
}

install_powerlevel10k() {
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ -d "$dest" ]; then
    log "powerlevel10k already installed"
    return
  fi
  if ! have_cmd git; then
    warn "git required to install powerlevel10k"
    return
  fi
  log "Installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest"
}

install_oh_my_tmux() {
  if [ -d "$HOME/.tmux" ]; then
    log "oh-my-tmux already installed"
  else
    if ! have_cmd git; then
      warn "git required to install oh-my-tmux"
      return
    fi
    log "Installing oh-my-tmux"
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  fi

  if [ -e "$HOME/.tmux/.tmux.conf" ]; then
    if [ ! -e "$HOME/.tmux.conf" ]; then
      ln -s "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
      log "Linked ~/.tmux.conf -> ~/.tmux/.tmux.conf"
    else
      warn "~/.tmux.conf exists; not overwriting"
    fi
  fi
}

main() {
  log "Using dotfiles at $DOTFILES_DIR"
  install_zsh
  install_oh_my_zsh
  install_powerlevel10k
  install_oh_my_tmux
  log "Done. Run ./link.sh to link your configs."
}

main "$@"
