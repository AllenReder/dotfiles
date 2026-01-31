#!/usr/bin/env bash
# File: i18n.sh - Simple i18n helpers for dotfiles scripts.
set -euo pipefail

_dotfiles_lang_default() {
  echo "zh"
}

_dotfiles_lang_prompt() {
  local def
  def="$(_dotfiles_lang_default)"
  if [ -t 0 ]; then
    printf "[dotfiles] Select language (en/zh) [default: %s]: " "$def" >&2
    read -r reply || true
    case "$reply" in
      zh|ZH) echo "zh" ;;
      en|EN) echo "en" ;;
      *) echo "$def" ;;
    esac
  else
    echo "$def"
  fi
}

dotfiles_lang_init() {
  if [ -n "${DOTFILES_LANG:-}" ]; then
    return
  fi
  export DOTFILES_LANG="$(_dotfiles_lang_prompt)"
}

_t_fmt() {
  case "$1" in
    using_dotfiles_en) echo "Using dotfiles at %s" ;;
    using_dotfiles_zh) echo "使用 dotfiles 目录：%s" ;;
    prompt_pm_en) echo "No package manager found. Install: 1) micromamba 2) cargo [default: 1]: " ;;
    prompt_pm_zh) echo "未检测到包管理工具。请选择安装：1) micromamba 2) cargo [默认: 1]: " ;;
    prompt_brew_en) echo "Homebrew not found. Install Homebrew? [y/N] " ;;
    prompt_brew_zh) echo "未检测到 Homebrew。是否安装 Homebrew？[y/N] " ;;
    curl_missing_brew_en) echo "WARN: curl not found; cannot install Homebrew" ;;
    curl_missing_brew_zh) echo "WARN: 未找到 curl，无法安装 Homebrew" ;;
    mm_tip_en) echo "Micromamba installer tips: press Enter for '~/.local/bin', answer 'n' for 'Init shell (bash)?', press Enter for 'Configure conda-forge?'" ;;
    mm_tip_zh) echo "Micromamba 安装提示：二进制目录直接回车(~/.local/bin)；Init shell (bash) 选 n；Configure conda-forge 直接回车" ;;
    curl_missing_mm_en) echo "WARN: curl not found; cannot install micromamba" ;;
    curl_missing_mm_zh) echo "WARN: 未找到 curl，无法安装 micromamba" ;;
    curl_missing_rustup_en) echo "WARN: curl not found; cannot install rustup/cargo" ;;
    curl_missing_rustup_zh) echo "WARN: 未找到 curl，无法安装 rustup/cargo" ;;
    linking_configs_en) echo "Linking configs" ;;
    linking_configs_zh) echo "正在链接配置" ;;
    switching_zsh_en) echo "Switching to zsh" ;;
    switching_zsh_zh) echo "切换到 zsh" ;;
    done_en) echo "Done." ;;
    done_zh) echo "完成。" ;;

    zsh_installed_en) echo "zsh already installed" ;;
    zsh_installed_zh) echo "zsh 已安装" ;;
    zsh_install_brew_en) echo "Installing zsh via Homebrew" ;;
    zsh_install_brew_zh) echo "通过 Homebrew 安装 zsh" ;;
    zsh_install_apt_sudo_en) echo "Installing zsh via apt-get (sudo)" ;;
    zsh_install_apt_sudo_zh) echo "通过 apt-get 安装 zsh（sudo）" ;;
    zsh_install_apt_root_en) echo "Installing zsh via apt-get (root)" ;;
    zsh_install_apt_root_zh) echo "通过 apt-get 安装 zsh（root）" ;;
    zsh_brew_missing_en) echo "Homebrew not found; install zsh manually (brew install zsh)" ;;
    zsh_brew_missing_zh) echo "未找到 Homebrew，请手动安装 zsh（brew install zsh）" ;;
    zsh_no_sudo_user_en) echo "sudo not available; attempting user-level install" ;;
    zsh_no_sudo_user_zh) echo "没有 sudo，尝试用户级安装" ;;
    zsh_unknown_os_en) echo "Unknown OS; install zsh manually" ;;
    zsh_unknown_os_zh) echo "未知系统，请手动安装 zsh" ;;

    omz_installed_en) echo "oh-my-zsh already installed" ;;
    omz_installed_zh) echo "oh-my-zsh 已安装" ;;
    omz_install_curl_en) echo "Installing oh-my-zsh via official script (curl)" ;;
    omz_install_curl_zh) echo "通过官方脚本安装 oh-my-zsh（curl）" ;;
    omz_install_wget_en) echo "Installing oh-my-zsh via official script (wget)" ;;
    omz_install_wget_zh) echo "通过官方脚本安装 oh-my-zsh（wget）" ;;
    omz_need_curl_wget_en) echo "curl or wget required to install oh-my-zsh" ;;
    omz_need_curl_wget_zh) echo "安装 oh-my-zsh 需要 curl 或 wget" ;;

    p10k_installed_en) echo "powerlevel10k already installed" ;;
    p10k_installed_zh) echo "powerlevel10k 已安装" ;;
    p10k_install_en) echo "Installing powerlevel10k" ;;
    p10k_install_zh) echo "安装 powerlevel10k" ;;
    p10k_need_git_en) echo "git required to install powerlevel10k" ;;
    p10k_need_git_zh) echo "安装 powerlevel10k 需要 git" ;;

    plugin_need_git_en) echo "git required to install oh-my-zsh plugins" ;;
    plugin_need_git_zh) echo "安装 oh-my-zsh 插件需要 git" ;;
    autosug_installed_en) echo "zsh-autosuggestions already installed" ;;
    autosug_installed_zh) echo "zsh-autosuggestions 已安装" ;;
    autosug_install_en) echo "Installing zsh-autosuggestions" ;;
    autosug_install_zh) echo "安装 zsh-autosuggestions" ;;
    syntax_installed_en) echo "zsh-syntax-highlighting already installed" ;;
    syntax_installed_zh) echo "zsh-syntax-highlighting 已安装" ;;
    syntax_install_en) echo "Installing zsh-syntax-highlighting" ;;
    syntax_install_zh) echo "安装 zsh-syntax-highlighting" ;;

    set_shell_already_en) echo "Default shell already set to zsh" ;;
    set_shell_already_zh) echo "默认 shell 已是 zsh" ;;
    set_shell_missing_en) echo "zsh not found; cannot set default shell" ;;
    set_shell_missing_zh) echo "未找到 zsh，无法设置默认 shell" ;;
    set_shell_no_chsh_en) echo "chsh not available; set default shell manually" ;;
    set_shell_no_chsh_zh) echo "未找到 chsh，请手动设置默认 shell" ;;
    set_shell_user_en) echo "Setting default shell for %s to %s" ;;
    set_shell_user_zh) echo "为用户 %s 设置默认 shell 为 %s" ;;
    set_shell_en) echo "Setting default shell to %s" ;;
    set_shell_zh) echo "设置默认 shell 为 %s" ;;

    tmux_installed_en) echo "oh-my-tmux already installed" ;;
    tmux_installed_zh) echo "oh-my-tmux 已安装" ;;
    tmux_install_en) echo "Installing oh-my-tmux" ;;
    tmux_install_zh) echo "安装 oh-my-tmux" ;;
    tmux_need_git_en) echo "git required to install oh-my-tmux" ;;
    tmux_need_git_zh) echo "安装 oh-my-tmux 需要 git" ;;
    tmux_linked_en) echo "Linked ~/.tmux.conf -> ~/.tmux/.tmux.conf" ;;
    tmux_linked_zh) echo "已链接 ~/.tmux.conf -> ~/.tmux/.tmux.conf" ;;
    tmux_conf_exists_en) echo "~/.tmux.conf exists; not overwriting" ;;
    tmux_conf_exists_zh) echo "~/.tmux.conf 已存在，未覆盖" ;;

    already_installed_en) echo "%s already installed" ;;
    already_installed_zh) echo "%s 已安装" ;;
    install_via_brew_en) echo "Installing %s via Homebrew" ;;
    install_via_brew_zh) echo "通过 Homebrew 安装 %s" ;;
    install_via_nix_en) echo "Installing %s via nix-env" ;;
    install_via_nix_zh) echo "通过 nix-env 安装 %s" ;;
    install_via_mm_en) echo "Installing %s via micromamba" ;;
    install_via_mm_zh) echo "通过 micromamba 安装 %s" ;;
    install_via_rustup_en) echo "Installing cargo via rustup" ;;
    install_via_rustup_zh) echo "通过 rustup 安装 cargo" ;;
    install_via_conda_en) echo "Installing %s via conda" ;;
    install_via_conda_zh) echo "通过 conda 安装 %s" ;;
    install_via_pipx_en) echo "Installing %s via pipx" ;;
    install_via_pipx_zh) echo "通过 pipx 安装 %s" ;;
    install_via_pip_en) echo "Installing %s via pip" ;;
    install_via_pip_zh) echo "通过 pip 安装 %s" ;;
    install_via_cargo_en) echo "Installing %s via cargo" ;;
    install_via_cargo_zh) echo "通过 cargo 安装 %s" ;;
    cargo_missing_en) echo "cargo not found; cannot install %s via cargo" ;;
    cargo_missing_zh) echo "未找到 cargo，无法通过 cargo 安装 %s" ;;
    install_manual_en) echo "Install %s manually" ;;
    install_manual_zh) echo "请手动安装 %s" ;;

    *) echo "$1" ;;
  esac
}

t() {
  local key
  key="$1"
  shift || true
  local lang
  lang="${DOTFILES_LANG:-en}"
  local fmt
  fmt="$(_t_fmt "${key}_${lang}")"
  printf "$fmt" "$@"
}

log_msg() {
  printf "[dotfiles] %s\n" "$(t "$@")"
}

warn_msg() {
  printf "[dotfiles] WARN: %s\n" "$(t "$@")" >&2
}
