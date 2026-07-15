# Minimal PATH setup shared by .zshenv and the interactive zsh environment.

if [ -z "${_DOTFILES_PATH_INITIALIZED:-}" ]; then
  typeset -g _DOTFILES_PATH_INITIALIZED=1
  typeset -gU path PATH

  _dotfiles_profile="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/profile.env"
  if [ -r "$_dotfiles_profile" ]; then
    source "$_dotfiles_profile"
  fi
  unset _dotfiles_profile

  DOTFILES_USER_ENV="${DOTFILES_USER_ENV:-${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/env}"
  path=("$HOME/.local/bin" $path)
  if [ "${DOTFILES_PACKAGE_BACKEND:-}" = micromamba ] && [ -d "$DOTFILES_USER_ENV/bin" ]; then
    path=("$DOTFILES_USER_ENV/bin" $path)
  fi
  export DOTFILES_USER_ENV PATH
fi
