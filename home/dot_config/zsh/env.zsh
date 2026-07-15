# Environment shared across macOS, Linux, WSL, and servers.

_dotfiles_path_config="${${(%):-%N}:A:h}/path.zsh"
if [ -r "$_dotfiles_path_config" ]; then
  source "$_dotfiles_path_config"
fi
unset _dotfiles_path_config

export EDITOR="${EDITOR:-nvim}"
export LANG="${LANG:-zh_CN.UTF-8}"

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
    if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/mamba" ]; then
      export MAMBA_ROOT_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/mamba"
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

export NVM_DIR="${NVM_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/nvm}"
if [ -r "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
fi
