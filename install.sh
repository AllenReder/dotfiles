#!/usr/bin/env bash
# File: install.sh - Orchestrate dotfiles installation.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/scripts/lib/i18n.sh"

log_plain() { printf "[dotfiles] %s\n" "$*"; }
warn_plain() { printf "[dotfiles] %s\n" "$*" >&2; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }

ensure_basic_tools() {
  case "$(uname -s)" in
    Linux)
      local missing=()
      for cmd in curl wget git tar; do
        if ! have_cmd "$cmd"; then
          missing+=("$cmd")
        fi
      done
      if [ "${#missing[@]}" -eq 0 ]; then
        return
      fi

      if have_cmd apt-get; then
        log_plain "缺少基础工具: ${missing[*]}"
        printf "[dotfiles] 是否通过 apt-get 安装这些工具？[y/N] " >&2
        read -r reply || true
        case "$reply" in
          y|Y)
            if have_cmd sudo; then
              sudo apt-get update && sudo apt-get install -y "${missing[@]}" || warn_plain "安装基础工具失败"
            elif [ "$(id -u)" = "0" ]; then
              apt-get update && apt-get install -y "${missing[@]}" || warn_plain "安装基础工具失败"
            else
              warn_plain "缺少 sudo 且不是 root，无法自动安装基础工具"
            fi
            ;;
          *)
            ;;
        esac
      else
        warn_plain "缺少基础工具: ${missing[*]}（未找到 apt-get，无法自动安装）"
      fi
      ;;
    *)
      ;;
  esac
}

prompt_install_pkg_manager() {
  case "$(uname -s)" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        return
      fi
      printf "[dotfiles] %s" "$(t prompt_brew)" >&2
      read -r reply || true
      case "$reply" in
        y|Y)
          if command -v curl >/dev/null 2>&1; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          else
            warn_msg curl_missing_brew
          fi
          ;;
        *)
          ;;
      esac
      ;;
    Linux)
      if command -v micromamba >/dev/null 2>&1 || command -v cargo >/dev/null 2>&1 || command -v nix-env >/dev/null 2>&1; then
        return
      fi
      printf "[dotfiles] %s" "$(t prompt_pm)" >&2
      read -r reply || true
      case "$reply" in
        ""|1|m|M)
          if command -v curl >/dev/null 2>&1; then
            # Official installer puts micromamba in ~/.local/bin
            log_msg mm_tip
            bash -c "$(curl -fsSL https://micromamba.pfx.dev/install.sh)"
            if [ -d "$HOME/.local/bin" ]; then
              PATH="$HOME/.local/bin:$PATH"
              export PATH
            fi
          else
            warn_msg curl_missing_mm
          fi
          ;;
        2|c|C)
          if command -v curl >/dev/null 2>&1; then
            log_msg install_via_rustup
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            if [ -d "$HOME/.cargo/bin" ]; then
              PATH="$HOME/.cargo/bin:$PATH"
              export PATH
            fi
          else
            warn_msg curl_missing_rustup
          fi
          ;;
        3|n|N)
          if command -v curl >/dev/null 2>&1; then
            log_msg install_via_nix
            sh <(curl -fsSL https://nixos.org/nix/install) --no-daemon
            if [ -d "$HOME/.nix-profile/bin" ]; then
              PATH="$HOME/.nix-profile/bin:$PATH"
              export PATH
            fi
          else
            warn_msg curl_missing_nix
          fi
          ;;
        4|none|None|NONE)
          ;;
        *)
          ;;
      esac
      ;;
    *)
      ;;
  esac
}

main() {
  dotfiles_lang_init
  log_msg using_dotfiles "$DOTFILES_DIR"
  ensure_basic_tools
  prompt_install_pkg_manager
  "$DOTFILES_DIR/scripts/install/zsh.sh"
  "$DOTFILES_DIR/scripts/install/tmux.sh"
  "$DOTFILES_DIR/scripts/install/tools.sh"
  bash "$DOTFILES_DIR/scripts/install/nvim.sh"
  log_msg linking_configs
  "$DOTFILES_DIR/link.sh"
  if [ -t 1 ] && [ "${DOTFILES_NO_EXEC_ZSH:-}" != "1" ] && [ -z "${ZSH_VERSION:-}" ]; then
    log_msg switching_zsh
    exec zsh
  fi
  log_msg done
}

main "$@"
