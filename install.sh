#!/usr/bin/env bash
# File: install.sh - Orchestrate dotfiles installation.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/scripts/lib/i18n.sh"

prompt_install_brew_or_micromamba() {
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
      if command -v micromamba >/dev/null 2>&1; then
        return
      fi
      printf "[dotfiles] %s" "$(t prompt_mm)" >&2
      read -r reply || true
      case "$reply" in
        y|Y)
          if command -v curl >/dev/null 2>&1; then
            # Official installer puts micromamba in ~/.local/bin
            log_msg mm_tip
            bash -c "$(curl -fsSL https://micromamba.pfx.dev/install.sh)"
          else
            warn_msg curl_missing_mm
          fi
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
  prompt_install_brew_or_micromamba
  "$DOTFILES_DIR/scripts/install/zsh.sh"
  "$DOTFILES_DIR/scripts/install/tmux.sh"
  "$DOTFILES_DIR/scripts/install/tools.sh"
  log_msg linking_configs
  "$DOTFILES_DIR/link.sh"
  if [ -t 1 ] && [ "${DOTFILES_NO_EXEC_ZSH:-}" != "1" ] && [ -z "${ZSH_VERSION:-}" ]; then
    log_msg switching_zsh
    exec zsh
  fi
  log_msg done
}

main "$@"
