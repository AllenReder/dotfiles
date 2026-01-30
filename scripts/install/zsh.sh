#!/usr/bin/env bash
# File: zsh.sh - Install zsh, oh-my-zsh, powerlevel10k, and related plugins.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/i18n.sh"
dotfiles_lang_init

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_zsh_user() {
  if have_cmd brew; then
    log_msg install_via_brew "zsh"
    brew install zsh
    return
  fi

  if have_cmd nix-env; then
    log_msg install_via_nix "zsh"
    nix-env -iA nixpkgs.zsh
    return
  fi

  if have_cmd micromamba; then
    log_msg install_via_mm "zsh"
    micromamba install -y -c conda-forge zsh
    return
  fi

  if have_cmd conda; then
    log_msg install_via_conda "zsh"
    conda install -y -c conda-forge zsh
    return
  fi

  if [ "${DOTFILES_ZSH_BUILD:-}" != "1" ]; then
    warn_msg install_manual "zsh (set DOTFILES_ZSH_BUILD=1 to build from source)"
    return
  fi

  local version="${ZSH_VERSION:-5.9}"
  local url="https://sourceforge.net/projects/zsh/files/zsh/${version}/zsh-${version}.tar.xz/download"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if have_cmd curl; then
    log_msg install_manual "zsh (download via curl)"
    curl -fsSL "$url" -o "$tmp_dir/zsh.tar.xz"
  elif have_cmd wget; then
    log_msg install_manual "zsh (download via wget)"
    wget -qO "$tmp_dir/zsh.tar.xz" "$url"
  else
    warn_msg install_manual "zsh (need curl or wget to download source)"
    return
  fi

  if ! have_cmd tar; then
    warn_msg install_manual "zsh (need tar to extract source)"
    return
  fi

  if ! have_cmd make || ! have_cmd cc; then
    warn_msg install_manual "zsh (need build tools: make, cc)"
    return
  fi

  log_msg install_manual "zsh (building from source)"
  tar -xf "$tmp_dir/zsh.tar.xz" -C "$tmp_dir"
  (cd "$tmp_dir/zsh-${version}" && ./configure --prefix="$HOME/.local" && make && make install)
  log_msg install_manual "zsh installed to ~/.local/bin (ensure PATH)"
}

install_zsh() {
  if have_cmd zsh; then
    log_msg zsh_installed
    return
  fi

  case "$(uname -s)" in
    Darwin)
      if have_cmd brew; then
        log_msg zsh_install_brew
        brew install zsh
      else
        warn_msg zsh_brew_missing
      fi
      ;;
    Linux)
      if have_cmd apt-get; then
        if have_cmd sudo; then
          log_msg zsh_install_apt_sudo
          sudo apt-get update
          sudo apt-get install -y zsh
        else
          if [ "$(id -u)" = "0" ]; then
            log_msg zsh_install_apt_root
            apt-get update
            apt-get install -y zsh
          else
            warn_msg zsh_no_sudo_user
            install_zsh_user
          fi
        fi
      else
        warn_msg zsh_no_sudo_user
        install_zsh_user
      fi
      ;;
    *)
      warn_msg zsh_unknown_os
      ;;
  esac
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log_msg omz_installed
    return
  fi

  if have_cmd curl; then
    log_msg omz_install_curl
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  elif have_cmd wget; then
    log_msg omz_install_wget
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    warn_msg omz_need_curl_wget
  fi
}

install_oh_my_zsh_plugins() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if ! have_cmd git; then
    warn_msg plugin_need_git
    return
  fi

  local autosug_dir="$custom_dir/plugins/zsh-autosuggestions"
  if [ -d "$autosug_dir" ]; then
    log_msg autosug_installed
  else
    log_msg autosug_install
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$autosug_dir"
  fi

  local syntax_dir="$custom_dir/plugins/zsh-syntax-highlighting"
  if [ -d "$syntax_dir" ]; then
    log_msg syntax_installed
  else
    log_msg syntax_install
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_dir"
  fi
}

install_powerlevel10k() {
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ -d "$dest" ]; then
    log_msg p10k_installed
    return
  fi
  if ! have_cmd git; then
    warn_msg p10k_need_git
    return
  fi
  log_msg p10k_install
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest"
}

set_default_shell() {
  if [ -z "${SHELL:-}" ]; then
    return
  fi

  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    warn_msg set_shell_missing
    return
  fi

  if [ "$SHELL" = "$zsh_path" ]; then
    log_msg set_shell_already
    return
  fi

  if ! have_cmd chsh; then
    warn_msg set_shell_no_chsh
    return
  fi

  local user="${SUDO_USER:-$USER}"
  if [ "$(id -u)" = "0" ] && [ -n "$user" ]; then
    log_msg set_shell_user "$user" "$zsh_path"
    chsh -s "$zsh_path" "$user" || warn "Failed to change shell for $user"
  else
    log_msg set_shell "$zsh_path"
    chsh -s "$zsh_path" || warn "Failed to change shell"
  fi
}

main() {
  install_zsh
  install_oh_my_zsh
  install_oh_my_zsh_plugins
  install_powerlevel10k
  set_default_shell
}

main "$@"
