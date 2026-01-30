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

# uv mirrors.
export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
export UV_EXTRA_INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"

# Micromamba base env PATH (no shell init).
if command -v micromamba >/dev/null 2>&1; then
  if [ -z "${MAMBA_ROOT_PREFIX:-}" ]; then
    if [ -d "$HOME/micromamba" ]; then
      export MAMBA_ROOT_PREFIX="$HOME/micromamba"
    elif [ -d "$HOME/.micromamba" ]; then
      export MAMBA_ROOT_PREFIX="$HOME/.micromamba"
    fi
  fi
  if [ -n "${MAMBA_ROOT_PREFIX:-}" ] && [ -d "$MAMBA_ROOT_PREFIX/bin" ]; then
    export PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"
  fi
fi
