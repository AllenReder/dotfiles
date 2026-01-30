# File: functions.zsh - Shell functions.
# Functions.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
