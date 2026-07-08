# Shell aliases.

if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons -h --group-directories-first"
  alias ll="eza --icons -lh --group-directories-first"
  alias lla="eza --icons -lha --group-directories-first"
fi

if command -v fdfind >/dev/null 2>&1; then
  alias fd="fdfind"
fi

if command -v batcat >/dev/null 2>&1; then
  alias bat="batcat"
fi

if command -v nvitop >/dev/null 2>&1; then
  alias ntop="nvitop"
fi
