# Shell functions and CLI integrations.

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

_tmh_shell="${XDG_DATA_HOME:-$HOME/.local/share}/tmh/shell/tmh.zsh"
if [ -x "$HOME/.local/bin/tmh" ] && [ -r "$_tmh_shell" ]; then
  source "$_tmh_shell"
fi
unset _tmh_shell

if command -v yazi >/dev/null 2>&1; then
  y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return 1
    command yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" \
      && [ -n "$cwd" ] \
      && [ "$cwd" != "$PWD" ] \
      && [ -d "$cwd" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# Install Ghostty's terminfo entry on an SSH server.
ssh-terminfo() {
  if (( $# == 0 )); then
    print -u2 "usage: ssh-terminfo [ssh options] user@host"
    return 2
  fi

  if ! command -v infocmp >/dev/null 2>&1; then
    print -u2 "ssh-terminfo: infocmp is not installed"
    return 1
  fi

  if ! command infocmp -x xterm-ghostty >/dev/null 2>&1; then
    print -u2 "ssh-terminfo: xterm-ghostty is not available locally"
    return 1
  fi

  command infocmp -x xterm-ghostty | command ssh "$@" -- tic -x -
}
