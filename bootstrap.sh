#!/usr/bin/env bash
# Bootstrap this dotfiles repository with chezmoi.
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/AllenReder/dotfiles.git}"
DOTFILES_YES="${DOTFILES_YES:-0}"
DOTFILES_SKIP_PACKAGES="${DOTFILES_SKIP_PACKAGES:-0}"
DOTFILES_SKIP_CHSH="${DOTFILES_SKIP_CHSH:-0}"
DOTFILES_FORCE_BACKUP="${DOTFILES_FORCE_BACKUP:-0}"
if [ "${DOTFILES_FEATURES+x}" = x ]; then
  DOTFILES_FEATURES_INPUT="$DOTFILES_FEATURES"
  DOTFILES_FEATURES_INPUT_SET=1
else
  DOTFILES_FEATURES_INPUT=""
  DOTFILES_FEATURES_INPUT_SET=0
fi
DOTFILES_PACKAGE_MODE_INPUT="${DOTFILES_PACKAGE_MODE:-}"
DOTFILES_USER_ENV_INPUT="${DOTFILES_USER_ENV:-}"
DOTFILES_PACKAGE_MODE="${DOTFILES_PACKAGE_MODE:-auto}"
DOTFILES_PACKAGE_BACKEND="${DOTFILES_PACKAGE_BACKEND:-}"
DOTFILES_USER_ENV="${DOTFILES_USER_ENV:-${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/env}"

log() { printf '[dotfiles] %s\n' "$*"; }
warn() { printf '[dotfiles] WARN: %s\n' "$*" >&2; }
die() { printf '[dotfiles] ERROR: %s\n' "$*" >&2; exit 1; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }

is_yes() {
  case "${1:-}" in
    1|y|Y|yes|YES|true|TRUE) return 0 ;;
    *) return 1 ;;
  esac
}

confirm() {
  local prompt="$1"
  if is_yes "$DOTFILES_YES"; then
    return 0
  fi
  if [ ! -t 0 ]; then
    return 1
  fi
  printf '[dotfiles] %s [y/N] ' "$prompt" >&2
  local reply
  read -r reply || true
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

detect_os() {
  case "$(uname -s)" in
    Darwin) printf 'darwin\n' ;;
    Linux)
      if [ -r /proc/version ] && grep -qi microsoft /proc/version; then
        printf 'wsl\n'
      else
        printf 'linux\n'
      fi
      ;;
    *) printf 'unknown\n' ;;
  esac
}

detect_profile() {
  case "$(detect_os)" in
    darwin) printf 'macos\n' ;;
    wsl) printf 'wsl\n' ;;
    linux)
      if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        printf 'linux-desktop\n'
      else
        printf 'server\n'
      fi
      ;;
    *) printf 'server\n' ;;
  esac
}

profile_file() {
  printf '%s/dotfiles/profile.env\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

load_existing_profile() {
  local file
  file="$(profile_file)"
  if [ -r "$file" ]; then
    # shellcheck disable=SC1090
    . "$file"
  fi
}

validate_profile() {
  case "$1" in
    macos|linux-desktop|wsl|server) return 0 ;;
    *) return 1 ;;
  esac
}

choose_profile() {
  load_existing_profile
  local detected profile
  detected="$(detect_profile)"
  profile="${DOTFILES_PROFILE:-${detected}}"

  if [ -t 0 ] && ! is_yes "$DOTFILES_YES" && [ -z "${DOTFILES_PROFILE:-}" ]; then
    printf '[dotfiles] Select profile [macos/linux-desktop/wsl/server] (%s): ' "$profile" >&2
    local reply
    read -r reply || true
    if [ -n "$reply" ]; then
      profile="$reply"
    fi
  fi

  validate_profile "$profile" || die "invalid DOTFILES_PROFILE: $profile"
  DOTFILES_PROFILE="$profile"
  export DOTFILES_PROFILE
}

choose_features() {
  local features
  if is_yes "$DOTFILES_FEATURES_INPUT_SET"; then
    features="$DOTFILES_FEATURES_INPUT"
  else
    features=""
  fi
  if [ -t 0 ] && ! is_yes "$DOTFILES_YES" && ! is_yes "$DOTFILES_FEATURES_INPUT_SET"; then
    printf '[dotfiles] Optional features, comma or space separated [gpu node] (empty): ' >&2
    local reply
    read -r reply || true
    features="$reply"
  fi
  features="${features//,/ }"
  DOTFILES_FEATURES="$features"
  export DOTFILES_FEATURES
}

validate_package_mode() {
  case "$1" in
    auto|system|user) return 0 ;;
    *) return 1 ;;
  esac
}

choose_package_mode() {
  local requested
  requested="${DOTFILES_PACKAGE_MODE_INPUT:-${DOTFILES_PACKAGE_MODE:-auto}}"
  validate_package_mode "$requested" || die "invalid DOTFILES_PACKAGE_MODE: $requested (expected auto, system, or user)"
  DOTFILES_PACKAGE_MODE="$requested"
  DOTFILES_USER_ENV="${DOTFILES_USER_ENV_INPUT:-${DOTFILES_USER_ENV:-${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/env}}"
  export DOTFILES_PACKAGE_MODE DOTFILES_USER_ENV
}

system_package_manager() {
  case "$(detect_os)" in
    darwin) have_cmd brew && printf 'brew\n' ;;
    linux|wsl)
      if have_cmd apt-get; then
        printf 'apt\n'
      elif have_cmd pacman; then
        printf 'pacman\n'
      fi
      ;;
  esac
}

can_use_system_packages() {
  [ "$(id -u)" = "0" ] && return 0
  have_cmd sudo || return 1
  sudo -n true >/dev/null 2>&1 && return 0
  if [ -t 0 ]; then
    log "Validating sudo access for system packages"
    sudo -v && return 0
  fi
  return 1
}

resolve_package_backend() {
  local os mgr
  os="$(detect_os)"

  if is_yes "$DOTFILES_SKIP_PACKAGES"; then
    case "$DOTFILES_PACKAGE_MODE" in
      user) DOTFILES_PACKAGE_BACKEND=micromamba ;;
      system) DOTFILES_PACKAGE_BACKEND=system ;;
      auto)
        case "$DOTFILES_PACKAGE_BACKEND" in
          system|micromamba) ;;
          *)
            if [ -d "$DOTFILES_USER_ENV/conda-meta" ]; then
              DOTFILES_PACKAGE_BACKEND=micromamba
            else
              DOTFILES_PACKAGE_BACKEND=system
            fi
            ;;
        esac
        ;;
    esac
    export DOTFILES_PACKAGE_BACKEND
    log "Package backend: $DOTFILES_PACKAGE_BACKEND (package installation skipped)"
    return 0
  fi

  mgr="$(system_package_manager || true)"

  case "$os:$DOTFILES_PACKAGE_MODE" in
    darwin:user)
      die "DOTFILES_PACKAGE_MODE=user is currently supported only on Linux and WSL"
      ;;
    darwin:*)
      DOTFILES_PACKAGE_BACKEND=system
      ;;
    linux:user|wsl:user)
      DOTFILES_PACKAGE_BACKEND=micromamba
      ;;
    linux:system|wsl:system)
      [ -n "$mgr" ] || die "no supported system package manager found"
      can_use_system_packages || die "DOTFILES_PACKAGE_MODE=system requires root or working sudo access"
      DOTFILES_PACKAGE_BACKEND=system
      ;;
    linux:auto|wsl:auto)
      if [ -n "$mgr" ] && can_use_system_packages; then
        DOTFILES_PACKAGE_BACKEND=system
      else
        DOTFILES_PACKAGE_BACKEND=micromamba
      fi
      ;;
    *)
      die "unsupported operating system for package installation: $os"
      ;;
  esac

  export DOTFILES_PACKAGE_BACKEND
  log "Package backend: $DOTFILES_PACKAGE_BACKEND (requested: $DOTFILES_PACKAGE_MODE)"
}

write_profile_env() {
  local file dir
  file="$(profile_file)"
  dir="$(dirname "$file")"
  mkdir -p "$dir"
  {
    printf 'DOTFILES_PROFILE=%q\n' "$DOTFILES_PROFILE"
    printf 'DOTFILES_FEATURES=%q\n' "$DOTFILES_FEATURES"
    printf 'DOTFILES_PACKAGE_MODE=%q\n' "$DOTFILES_PACKAGE_MODE"
    printf 'DOTFILES_PACKAGE_BACKEND=%q\n' "$DOTFILES_PACKAGE_BACKEND"
    printf 'DOTFILES_USER_ENV=%q\n' "$DOTFILES_USER_ENV"
  } > "$file"
  chmod 600 "$file"
  log "Profile saved: $file"
}

run_as_root() {
  if [ "$(id -u)" = "0" ]; then
    "$@"
  elif have_cmd sudo; then
    sudo "$@"
  else
    return 1
  fi
}

ensure_homebrew() {
  if [ "$(detect_os)" != "darwin" ] || have_cmd brew; then
    return 0
  fi
  if ! confirm "Homebrew is missing. Install Homebrew now?"; then
    warn "Homebrew not installed; macOS package installation will be limited."
    return 1
  fi
  have_cmd curl || die "curl is required to install Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_bootstrap_tools() {
  if [ "$DOTFILES_PACKAGE_BACKEND" = micromamba ]; then
    have_cmd git || die "user package mode requires git to already be installed"
    if ! have_cmd curl && ! have_cmd wget; then
      die "user package mode requires curl or wget to already be installed"
    fi
    if ! have_cmd sha256sum && ! have_cmd shasum; then
      die "user package mode requires sha256sum or shasum to verify micromamba"
    fi
    return 0
  fi

  local missing=()
  for cmd in git curl; do
    have_cmd "$cmd" || missing+=("$cmd")
  done
  [ "${#missing[@]}" -eq 0 ] && return 0

  case "$(detect_os)" in
    darwin)
      ensure_homebrew || return 0
      log "Installing bootstrap tools via Homebrew: ${missing[*]}"
      brew install "${missing[@]}"
      ;;
    linux|wsl)
      if have_cmd apt-get; then
        log "Installing bootstrap tools via apt: ${missing[*]}"
        run_as_root apt-get update
        run_as_root apt-get install -y git curl ca-certificates
      elif have_cmd pacman; then
        log "Installing bootstrap tools via pacman: ${missing[*]}"
        run_as_root pacman -Sy --needed --noconfirm git curl ca-certificates
      else
        warn "Missing bootstrap tools: ${missing[*]}"
      fi
      ;;
  esac
}

install_chezmoi() {
  if have_cmd chezmoi; then
    return 0
  fi

  case "$(detect_os)" in
    darwin)
      ensure_homebrew || true
      if have_cmd brew; then
        log "Installing chezmoi via Homebrew"
        brew install chezmoi
        return 0
      fi
      ;;
    linux|wsl)
      if [ "$DOTFILES_PACKAGE_BACKEND" = system ] && have_cmd pacman; then
        log "Installing chezmoi via pacman"
        run_as_root pacman -Sy --needed --noconfirm chezmoi && return 0
      fi
      ;;
  esac

  have_cmd curl || die "curl is required to install chezmoi"
  log "Installing chezmoi to ~/.local/bin"
  mkdir -p "$HOME/.local/bin"
  sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
  have_cmd chezmoi || die "chezmoi installation failed"
}

local_source_dir() {
  local script_dir
  if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$script_dir/.chezmoiroot" ]; then
      printf '%s\n' "$script_dir"
      return 0
    fi
  fi
  return 1
}

prepare_source_dir() {
  if [ -n "${DOTFILES_SOURCE_DIR:-}" ]; then
    [ -f "$DOTFILES_SOURCE_DIR/.chezmoiroot" ] || die "DOTFILES_SOURCE_DIR is not a dotfiles v2 source: $DOTFILES_SOURCE_DIR"
    printf '%s\n' "$DOTFILES_SOURCE_DIR"
    return 0
  fi

  if local_source_dir >/dev/null 2>&1; then
    local_source_dir
    return 0
  fi

  local data_home source_dir
  data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  source_dir="$data_home/chezmoi"
  if [ -d "$source_dir/.git" ]; then
    log "Updating dotfiles source: $source_dir"
    git -C "$source_dir" pull --ff-only
  else
    log "Cloning dotfiles source: $DOTFILES_REPO"
    mkdir -p "$(dirname "$source_dir")"
    git clone "$DOTFILES_REPO" "$source_dir"
  fi
  printf '%s\n' "$source_dir"
}

backup_conflicts() {
  local marker state_dir backup_dir source_dir
  source_dir="$1"
  state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
  marker="$state_dir/initial-backup.done"

  if [ -e "$marker" ] && ! is_yes "$DOTFILES_FORCE_BACKUP"; then
    return 0
  fi

  local paths=(
    "$HOME/.zshrc"
    "$HOME/.config/zsh"
    "$HOME/.config/starship.toml"
    "$HOME/.config/ghostty/config.ghostty"
    "$HOME/.config/nvim"
    "$HOME/.tmux.conf.local"
    "$HOME/.local/bin/sshx"
    "$HOME/.local/bin/bark"
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
  )

  backup_dir="$state_dir/backups/$(date +%Y%m%d%H%M%S)"
  local did_backup=0 path rel dest
  for path in "${paths[@]}"; do
    [ -e "$path" ] || [ -L "$path" ] || continue
    rel="${path#"$HOME"/}"
    dest="$backup_dir/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$path" "$dest"
    log "Backed up $path -> $dest"
    did_backup=1
  done

  mkdir -p "$state_dir"
  {
    printf 'source=%s\n' "$source_dir"
    printf 'timestamp=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'did_backup=%s\n' "$did_backup"
  } > "$marker"
}

install_packages() {
  local source_dir="$1"
  if is_yes "$DOTFILES_SKIP_PACKAGES"; then
    log "Skipping package installation"
    return 0
  fi
  "$source_dir/scripts/dotfiles/package-install.sh"
}

activate_user_environment() {
  if [ "$DOTFILES_PACKAGE_BACKEND" = micromamba ] && [ -d "$DOTFILES_USER_ENV/bin" ]; then
    export PATH="$DOTFILES_USER_ENV/bin:$PATH"
  fi
}

maybe_change_shell() {
  if [ "$DOTFILES_PACKAGE_BACKEND" = micromamba ]; then
    if [ -x "$DOTFILES_USER_ENV/bin/zsh" ]; then
      log "User-level zsh installed. Start it with: exec \"$DOTFILES_USER_ENV/bin/zsh\" -l"
    else
      warn "user package environment does not contain zsh: $DOTFILES_USER_ENV/bin/zsh"
    fi
    return 0
  fi
  if is_yes "$DOTFILES_SKIP_CHSH"; then
    return 0
  fi
  have_cmd zsh || return 0
  local zsh_path current_shell
  zsh_path="$(command -v zsh)"
  current_shell="${SHELL:-}"
  [ "$current_shell" = "$zsh_path" ] && return 0
  if ! confirm "Change login shell to $zsh_path?"; then
    return 0
  fi
  if ! have_cmd chsh; then
    warn "chsh not found; set your login shell manually: $zsh_path"
    return 0
  fi
  chsh -s "$zsh_path" || warn "chsh failed; ensure $zsh_path is listed in /etc/shells"
}

main() {
  export PATH="$HOME/.local/bin:$PATH"
  choose_profile
  choose_features
  choose_package_mode
  resolve_package_backend
  write_profile_env
  ensure_bootstrap_tools

  local source_dir
  source_dir="$(prepare_source_dir)"
  export DOTFILES_SOURCE_DIR="$source_dir"

  install_packages "$source_dir"
  activate_user_environment
  install_chezmoi
  backup_conflicts "$source_dir"

  log "Applying chezmoi source: $source_dir"
  chezmoi --source "$source_dir" apply --force
  maybe_change_shell
  log "Done"
}

if [ "${DOTFILES_BOOTSTRAP_NO_MAIN:-0}" != "1" ]; then
  main "$@"
fi
