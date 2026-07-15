#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2030,SC2031,SC2034,SC2329
# Tests intentionally source scripts dynamically, isolate state in subshells,
# and replace selected functions with fakes.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'package-mode test: %s\n' "$*" >&2
  exit 1
}

assert_eq() {
  [ "$1" = "$2" ] || fail "expected '$2', got '$1'"
}

test_backend_resolution() {
  (
    export DOTFILES_BOOTSTRAP_NO_MAIN=1
    # shellcheck source=../bootstrap.sh
    source "$REPO_DIR/bootstrap.sh"
    detect_os() { printf 'linux\n'; }
    system_package_manager() { printf 'apt\n'; }
    can_use_system_packages() { return 0; }
    DOTFILES_PACKAGE_MODE=auto
    resolve_package_backend >/dev/null
    assert_eq "$DOTFILES_PACKAGE_BACKEND" system
  )

  (
    export DOTFILES_BOOTSTRAP_NO_MAIN=1
    # shellcheck source=../bootstrap.sh
    source "$REPO_DIR/bootstrap.sh"
    detect_os() { printf 'linux\n'; }
    system_package_manager() { printf 'apt\n'; }
    can_use_system_packages() { return 1; }
    DOTFILES_PACKAGE_MODE=auto
    resolve_package_backend >/dev/null
    assert_eq "$DOTFILES_PACKAGE_BACKEND" micromamba
  )

  if (
    export DOTFILES_BOOTSTRAP_NO_MAIN=1
    # shellcheck source=../bootstrap.sh
    source "$REPO_DIR/bootstrap.sh"
    detect_os() { printf 'linux\n'; }
    system_package_manager() { printf 'apt\n'; }
    can_use_system_packages() { return 1; }
    DOTFILES_PACKAGE_MODE=system
    resolve_package_backend >/dev/null
  ); then
    fail "system mode unexpectedly succeeded without privileges"
  fi

  (
    export DOTFILES_BOOTSTRAP_NO_MAIN=1 DOTFILES_SKIP_PACKAGES=1
    # shellcheck source=../bootstrap.sh
    source "$REPO_DIR/bootstrap.sh"
    detect_os() { printf 'linux\n'; }
    can_use_system_packages() { fail "sudo probe ran while packages were skipped"; }
    DOTFILES_PACKAGE_MODE=auto
    DOTFILES_PACKAGE_BACKEND=micromamba
    resolve_package_backend >/dev/null
    assert_eq "$DOTFILES_PACKAGE_BACKEND" micromamba
  )
}

test_profile_persistence() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  (
    export HOME="$tmp_dir/home" XDG_CONFIG_HOME="$tmp_dir/config" DOTFILES_BOOTSTRAP_NO_MAIN=1
    # shellcheck source=../bootstrap.sh
    source "$REPO_DIR/bootstrap.sh"
    DOTFILES_PROFILE=server
    DOTFILES_FEATURES=gpu
    DOTFILES_PACKAGE_MODE=user
    DOTFILES_PACKAGE_BACKEND=micromamba
    DOTFILES_USER_ENV="$tmp_dir/user env"
    write_profile_env >/dev/null
    unset DOTFILES_PROFILE DOTFILES_FEATURES DOTFILES_PACKAGE_MODE DOTFILES_PACKAGE_BACKEND DOTFILES_USER_ENV
    # shellcheck disable=SC1090
    source "$(profile_file)"
    assert_eq "$DOTFILES_PACKAGE_MODE" user
    assert_eq "$DOTFILES_PACKAGE_BACKEND" micromamba
    assert_eq "$DOTFILES_USER_ENV" "$tmp_dir/user env"
  )
  rm -rf "$tmp_dir"
}

test_micromamba_assets_and_manifest() {
  (
    export DOTFILES_PACKAGE_INSTALL_NO_MAIN=1 XDG_CONFIG_HOME=/nonexistent
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    uname() {
      case "$1" in
        -m) printf 'x86_64\n' ;;
        *) command uname "$@" ;;
      esac
    }
    assert_eq "$(micromamba_asset)" linux-64
  )

  (
    export DOTFILES_PACKAGE_INSTALL_NO_MAIN=1 XDG_CONFIG_HOME=/nonexistent
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    uname() {
      case "$1" in
        -m) printf 'aarch64\n' ;;
        *) command uname "$@" ;;
      esac
    }
    assert_eq "$(micromamba_asset)" linux-aarch64
  )

  if (
    export DOTFILES_PACKAGE_INSTALL_NO_MAIN=1 XDG_CONFIG_HOME=/nonexistent
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    uname() {
      case "$1" in
        -m) printf 'riscv64\n' ;;
        *) command uname "$@" ;;
      esac
    }
    micromamba_asset >/dev/null
  ); then
    fail "unsupported micromamba architecture unexpectedly succeeded"
  fi

  (
    export DOTFILES_PACKAGE_INSTALL_NO_MAIN=1 DOTFILES_FEATURES=gpu XDG_CONFIG_HOME=/nonexistent
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    packages="$(read_manifest micromamba)"
    printf '%s\n' "$packages" | grep -qx zsh
    printf '%s\n' "$packages" | grep -qx yazi
    printf '%s\n' "$packages" | grep -qx nvitop
  )
}

test_micromamba_download_failures() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if (
    export HOME="$tmp_dir/download" XDG_CONFIG_HOME="$tmp_dir/download-config" DOTFILES_PACKAGE_INSTALL_NO_MAIN=1
    mkdir -p "$HOME"
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    uname() {
      case "$1" in
        -m) printf 'x86_64\n' ;;
        *) command uname "$@" ;;
      esac
    }
    download_file() { return 1; }
    install_micromamba >/dev/null 2>&1
  ); then
    fail "micromamba download failure unexpectedly succeeded"
  fi

  if (
    export HOME="$tmp_dir/checksum" XDG_CONFIG_HOME="$tmp_dir/checksum-config" DOTFILES_PACKAGE_INSTALL_NO_MAIN=1
    mkdir -p "$HOME"
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    uname() {
      case "$1" in
        -m) printf 'x86_64\n' ;;
        *) command uname "$@" ;;
      esac
    }
    download_file() {
      case "$2" in
        *.sha256) printf '0000000000000000000000000000000000000000000000000000000000000000\n' > "$2" ;;
        *) printf 'not-a-real-binary\n' > "$2" ;;
      esac
    }
    install_micromamba >/dev/null 2>&1
  ); then
    fail "micromamba checksum mismatch unexpectedly succeeded"
  fi
  rm -rf "$tmp_dir"
}

test_micromamba_binary_idempotence() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  mkdir -p "$tmp_dir/home/.local/bin"
  cat > "$tmp_dir/home/.local/bin/micromamba" <<'EOF'
#!/bin/sh
if [ "${1:-}" = --version ]; then
  printf '2.8.1\n'
fi
EOF
  chmod +x "$tmp_dir/home/.local/bin/micromamba"

  (
    export HOME="$tmp_dir/home" XDG_CONFIG_HOME="$tmp_dir/config" DOTFILES_PACKAGE_INSTALL_NO_MAIN=1
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    download_file() { fail "existing pinned micromamba was downloaded again"; }
    install_micromamba
  )
  rm -rf "$tmp_dir"
}

test_micromamba_environment_idempotence() {
  local tmp_dir fake_bin log_file user_env
  tmp_dir="$(mktemp -d)"
  fake_bin="$tmp_dir/bin"
  log_file="$tmp_dir/micromamba.log"
  user_env="$tmp_dir/user-env"
  mkdir -p "$fake_bin"

  cat > "$fake_bin/micromamba" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$TEST_MICROMAMBA_LOG"
command_name=$1
shift
prefix=
while [ "$#" -gt 0 ]; do
  if [ "$1" = -p ]; then
    prefix=$2
    break
  fi
  shift
done
if [ "$command_name" = create ]; then
  mkdir -p "$prefix/conda-meta" "$prefix/bin"
fi
if [ "${TEST_MICROMAMBA_FAIL:-0}" = 1 ]; then
  exit 1
fi
EOF
  chmod +x "$fake_bin/micromamba"

  (
    export PATH="$fake_bin:/usr/bin:/bin"
    export TEST_MICROMAMBA_LOG="$log_file"
    export DOTFILES_PACKAGE_INSTALL_NO_MAIN=1 DOTFILES_FEATURES=gpu
    export XDG_CONFIG_HOME="$tmp_dir/config"
    export DOTFILES_USER_ENV="$user_env" MAMBA_ROOT_PREFIX="$tmp_dir/mamba"
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    install_micromamba_packages >/dev/null
    install_micromamba_packages >/dev/null
  )

  [ "$(wc -l < "$log_file" | tr -d ' ')" = 2 ] || fail "expected two micromamba package operations"
  sed -n '1p' "$log_file" | grep -q '^create '
  sed -n '1p' "$log_file" | grep -q 'nvitop'
  sed -n '2p' "$log_file" | grep -q '^install '

  mkdir -p "$tmp_dir/not-an-environment"
  if (
    export PATH="$fake_bin:/usr/bin:/bin"
    export TEST_MICROMAMBA_LOG="$log_file"
    export DOTFILES_PACKAGE_INSTALL_NO_MAIN=1 XDG_CONFIG_HOME="$tmp_dir/config"
    export DOTFILES_USER_ENV="$tmp_dir/not-an-environment" MAMBA_ROOT_PREFIX="$tmp_dir/mamba"
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    install_micromamba_packages >/dev/null 2>&1
  ); then
    fail "non-micromamba environment unexpectedly succeeded"
  fi

  rm -rf "$user_env"
  if output="$({
    export PATH="$fake_bin:/usr/bin:/bin"
    export TEST_MICROMAMBA_LOG="$log_file" TEST_MICROMAMBA_FAIL=1
    export DOTFILES_PACKAGE_INSTALL_NO_MAIN=1 XDG_CONFIG_HOME="$tmp_dir/config"
    export DOTFILES_USER_ENV="$user_env" MAMBA_ROOT_PREFIX="$tmp_dir/mamba"
    # shellcheck source=../scripts/dotfiles/package-install.sh
    source "$REPO_DIR/scripts/dotfiles/package-install.sh"
    install_micromamba_packages
  } 2>&1)"; then
    fail "micromamba package failure unexpectedly succeeded"
  fi
  printf '%s\n' "$output" | grep -q "failed to create the user package environment" || \
    fail "micromamba package failure did not produce an actionable error"
  rm -rf "$tmp_dir"
}

test_zsh_user_environment_path() {
  local tmp_dir user_env data_home
  tmp_dir="$(mktemp -d)"
  user_env="$tmp_dir/user-env"
  data_home="$tmp_dir/data"
  mkdir -p "$tmp_dir/home/.config/dotfiles" "$tmp_dir/home/.local/bin" "$user_env/bin" "$data_home/mamba/bin"
  touch "$tmp_dir/home/.local/bin/micromamba"
  chmod +x "$tmp_dir/home/.local/bin/micromamba"
  touch "$user_env/bin/nvitop"
  chmod +x "$user_env/bin/nvitop"
  {
    printf 'DOTFILES_PACKAGE_BACKEND=micromamba\n'
    printf 'DOTFILES_USER_ENV=%q\n' "$user_env"
  } > "$tmp_dir/home/.config/dotfiles/profile.env"

  HOME="$tmp_dir/home" XDG_CONFIG_HOME="$tmp_dir/home/.config" XDG_DATA_HOME="$data_home" \
    DOTFILES_TEST_REPO_DIR="$REPO_DIR" \
    zsh -dfc '
      source "$DOTFILES_TEST_REPO_DIR/home/dot_config/zsh/env.zsh"
      source "$DOTFILES_TEST_REPO_DIR/home/dot_config/zsh/aliases.zsh"
      [[ $path[1] == '"$user_env"'/bin ]]
      [[ $MAMBA_ROOT_PREFIX == '"$data_home"'/mamba ]]
      [[ "$(alias ntop)" == "ntop=nvitop" ]]
    '
  rm -rf "$tmp_dir"
}

test_backend_resolution
test_profile_persistence
test_micromamba_assets_and_manifest
test_micromamba_download_failures
test_micromamba_binary_idempotence
test_micromamba_environment_idempotence
test_zsh_user_environment_path

printf 'Package mode tests passed.\n'
