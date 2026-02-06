#!/usr/bin/env bash
# File: tools.sh - Install common CLI tools.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/i18n.sh"
dotfiles_lang_init

have_cmd() { command -v "$1" >/dev/null 2>&1; }

apt_has_pkg() {
  if ! have_cmd apt-cache; then
    return 1
  fi
  apt-cache show "$1" >/dev/null 2>&1
}

source "$SCRIPT_DIR/tools/zoxide.sh"
source "$SCRIPT_DIR/tools/eza.sh"
source "$SCRIPT_DIR/tools/fd.sh"
source "$SCRIPT_DIR/tools/rg.sh"
source "$SCRIPT_DIR/tools/fzf.sh"
source "$SCRIPT_DIR/tools/bat.sh"
source "$SCRIPT_DIR/tools/nvitop.sh"

main() {
  install_zoxide
  install_eza
  install_fdfind
  install_rg
  install_fzf
  install_bat
  install_nvitop
}

main "$@"
