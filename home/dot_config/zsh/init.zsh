# Zsh entrypoint for the managed dotfiles environment.

setopt no_beep
setopt auto_cd
setopt interactive_comments
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt share_history

ZSH_CONFIG_DIR="${${(%):-%N}:A:h}"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$ZSH_CACHE_DIR"

zmodload zsh/complist
setopt auto_list
setopt auto_menu
setopt complete_in_word
unsetopt menu_complete

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:descriptions' format ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

autoload -Uz compinit
compinit -d "$ZSH_CACHE_DIR/zcompdump"

[ -r "$ZSH_CONFIG_DIR/env.zsh" ] && source "$ZSH_CONFIG_DIR/env.zsh"

_antidote_source=""
for _candidate in \
  "${ANTIDOTE_HOME:-}/antidote.zsh" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/antidote/antidote.zsh" \
  "$HOME/.antidote/antidote.zsh" \
  "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" \
  "/opt/homebrew/share/antidote/antidote.zsh" \
  "/usr/local/opt/antidote/share/antidote/antidote.zsh" \
  "/usr/local/share/antidote/antidote.zsh"; do
  if [ -r "$_candidate" ]; then
    _antidote_source="$_candidate"
    break
  fi
done

if [ -n "$_antidote_source" ]; then
  source "$_antidote_source"
fi

[ -r "$ZSH_CONFIG_DIR/aliases.zsh" ] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[ -r "$ZSH_CONFIG_DIR/functions.zsh" ] && source "$ZSH_CONFIG_DIR/functions.zsh"
[ -r "$ZSH_CONFIG_DIR/keybinds.zsh" ] && source "$ZSH_CONFIG_DIR/keybinds.zsh"

case "$(uname -s)" in
  Darwin)
    [ -r "$ZSH_CONFIG_DIR/os/macos.zsh" ] && source "$ZSH_CONFIG_DIR/os/macos.zsh"
    ;;
  Linux)
    if [ -r /proc/version ] && grep -qi microsoft /proc/version; then
      [ -r "$ZSH_CONFIG_DIR/os/wsl.zsh" ] && source "$ZSH_CONFIG_DIR/os/wsl.zsh"
    else
      [ -r "$ZSH_CONFIG_DIR/os/linux.zsh" ] && source "$ZSH_CONFIG_DIR/os/linux.zsh"
    fi
    ;;
esac

if [ -n "${DOTFILES_PROFILE:-}" ] && [ -r "$ZSH_CONFIG_DIR/profiles/$DOTFILES_PROFILE.zsh" ]; then
  source "$ZSH_CONFIG_DIR/profiles/$DOTFILES_PROFILE.zsh"
fi

HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf unknown)"
HOST_MATCH=""
for f in "$ZSH_CONFIG_DIR"/host/*.zsh(N); do
  [ -f "$f" ] || continue
  base="${f:t:r}"
  if [[ "$HOSTNAME_SHORT" == *"$base"* ]]; then
    if [ -z "$HOST_MATCH" ] || [ ${#base} -gt ${#HOST_MATCH:t:r} ]; then
      HOST_MATCH="$f"
    fi
  fi
done
[ -n "$HOST_MATCH" ] && source "$HOST_MATCH"
unset HOSTNAME_SHORT HOST_MATCH base f

if [ -r "$HOME/.config/dotfiles/local.zsh" ]; then
  source "$HOME/.config/dotfiles/local.zsh"
fi

# clash-for-linux-install exposes its commands as shell functions instead of
# standalone executables. Load them after local.zsh so custom install paths can
# override the default ~/clashctl location.
if [ "$(uname -s)" = Linux ]; then
  _clashctl_home="${CLASHCTL_HOME:-$HOME/clashctl}"
  _clashctl_init="$_clashctl_home/scripts/cmd/clashctl.sh"
  if [ -r "$_clashctl_init" ]; then
    export CLASHCTL_HOME="$_clashctl_home"
    source "$_clashctl_init"
  fi
  unset _clashctl_home _clashctl_init
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# zsh-syntax-highlighting must be loaded after every widget and prompt setup.
# Also rebuild Antidote's static loader when a cache cleanup removed a bundle.
if (( $+functions[antidote] )); then
  _bundle_file="$ZSH_CONFIG_DIR/plugins.txt"
  _static_file="$ZSH_CACHE_DIR/antidote.zsh"
  _antidote_rebuild=0

  if [ ! -s "$_static_file" ] || [ "$_bundle_file" -nt "$_static_file" ]; then
    _antidote_rebuild=1
  else
    while IFS=$' \t' read -r _bundle _; do
      case "$_bundle" in
        ''|'#'*|using:*) continue ;;
      esac
      if ! antidote path "$_bundle" >/dev/null 2>&1; then
        _antidote_rebuild=1
        break
      fi
    done < "$_bundle_file"
  fi

  if (( _antidote_rebuild )); then
    antidote bundle < "$_bundle_file" >| "$_static_file"
  fi
  source "$_static_file"
fi
unset _antidote_source _candidate _bundle_file _static_file _antidote_rebuild _bundle
