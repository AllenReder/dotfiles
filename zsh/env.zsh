# File: env.zsh - Environment variables shared across shells.
# Environment defaults.
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export LANG="zh_CN.UTF-8"

# Nix (single-user) environment, if present.
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# fzf completion trigger.
export FZF_COMPLETION_TRIGGER=';;'

# Bark push (fill in your own values).
export BARK_SERVER=""
export BARK_DEVICE_KEYS=""
