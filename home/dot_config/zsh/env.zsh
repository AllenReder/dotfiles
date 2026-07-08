# Environment shared across macOS, Linux, WSL, and servers.

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="${EDITOR:-nvim}"
export LANG="${LANG:-zh_CN.UTF-8}"

if [ -r "$HOME/.config/dotfiles/profile.env" ]; then
  source "$HOME/.config/dotfiles/profile.env"
fi

if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

if [ -d "$HOME/.fzf/bin" ]; then
  export PATH="$HOME/.fzf/bin:$PATH"
fi
export FZF_COMPLETION_TRIGGER="${FZF_COMPLETION_TRIGGER:-;;}"

export UV_INDEX_URL="${UV_INDEX_URL:-https://pypi.tuna.tsinghua.edu.cn/simple}"
export UV_EXTRA_INDEX_URL="${UV_EXTRA_INDEX_URL:-https://mirrors.aliyun.com/pypi/simple/}"

if command -v micromamba >/dev/null 2>&1; then
  if [ -z "${MAMBA_ROOT_PREFIX:-}" ]; then
    if [ -d "$HOME/.local/share/mamba" ]; then
      export MAMBA_ROOT_PREFIX="$HOME/.local/share/mamba"
    elif [ -d "$HOME/micromamba" ]; then
      export MAMBA_ROOT_PREFIX="$HOME/micromamba"
    elif [ -d "$HOME/.micromamba" ]; then
      export MAMBA_ROOT_PREFIX="$HOME/.micromamba"
    fi
  fi
  if [ -n "${MAMBA_ROOT_PREFIX:-}" ] && [ -d "$MAMBA_ROOT_PREFIX/bin" ]; then
    export PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"
  fi
fi
