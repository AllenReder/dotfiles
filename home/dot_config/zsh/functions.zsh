# Shell functions and CLI integrations.

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

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
