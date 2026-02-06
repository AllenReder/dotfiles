#!/usr/bin/env bash
# File: link.sh - Symlink dotfiles into $HOME with backups.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "[dotfiles] %s\n" "$*"; }

link_file() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "Already linked: $dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    log "Backed up $dest to $backup"
  fi

  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

main() {
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.config"
  link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/zsh/p10k.zsh" "$HOME/.p10k.zsh"
  link_file "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf.local"
  link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  link_file "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"
  link_file "$DOTFILES_DIR/ironbar" "$HOME/.config/ironbar"
  link_file "$DOTFILES_DIR/hypr" "$HOME/.config/hypr"
  link_file "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
  link_file "$DOTFILES_DIR/mako" "$HOME/.config/mako"
  link_file "$DOTFILES_DIR/swayosd" "$HOME/.config/swayosd"
  link_file "$DOTFILES_DIR/omarchy" "$HOME/.config/omarchy"
  link_file "$DOTFILES_DIR/walker" "$HOME/.config/walker"
  link_file "$DOTFILES_DIR/elephant" "$HOME/.config/elephant"

  for f in "$DOTFILES_DIR"/bin/*; do
    [ -f "$f" ] || continue
    link_file "$f" "$HOME/.local/bin/$(basename "$f")"
  done
}

main "$@"
