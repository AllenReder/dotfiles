# dotfiles

个人 dotfiles v2。这个仓库用 [chezmoi](https://www.chezmoi.io/) 管理 `$HOME` 配置，用一个薄的 `bootstrap.sh` 负责首次安装、profile 选择、基础工具安装和安全备份。

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/AllenReder/dotfiles/main/bootstrap.sh | bash
```

无人值守示例：

```bash
DOTFILES_PROFILE=macos DOTFILES_FEATURES="" DOTFILES_YES=1 \
  bash <(curl -fsSL https://raw.githubusercontent.com/AllenReder/dotfiles/main/bootstrap.sh)
```

本地开发验证：

```bash
DOTFILES_SOURCE_DIR="$PWD" DOTFILES_SKIP_PACKAGES=1 DOTFILES_SKIP_CHSH=1 ./bootstrap.sh
```

## Profile 和 features

v1 profile：

- `macos`：macOS 桌面机。
- `linux-desktop`：Linux 桌面机；Hyprland 暂不纳入 v1。
- `wsl`：WSL 环境。
- `server`：Linux 服务器。

v1 features：

- `gpu`：安装 GPU 相关 CLI，例如 `nvitop`。
- `node`：统一通过 nvm 安装最新 Node.js LTS；npm 和 npx 随 Node.js 一起安装。

选择会写入 `~/.config/dotfiles/profile.env`，供已安装的 shell 环境读取；但每次交互运行 `bootstrap.sh` 都会重新询问 features，不会默认复用上一次选择。无人值守运行应显式传入 `DOTFILES_FEATURES`：

```bash
DOTFILES_PROFILE=server DOTFILES_FEATURES="gpu node" ./bootstrap.sh
```

Linux/WSL 默认自动选择包安装后端：有 root 或可用 sudo 时使用系统包管理器，否则使用用户级 micromamba 环境。也可以显式选择：

```bash
# 强制用户级安装
DOTFILES_PACKAGE_MODE=user ./bootstrap.sh

# 强制系统包安装；无权限时直接报错
DOTFILES_PACKAGE_MODE=system ./bootstrap.sh
```

## 目录结构

- `.chezmoiroot`：指向 `home/`，让仓库根目录保持干净。
- `home/`：chezmoi 源状态，对应最终的 `$HOME`。
- `packages/`：按包管理器拆分的简单文本包清单。
- `scripts/dotfiles/`：bootstrap 复用脚本。
- `extras/`：不进入默认安装的一次性或可选脚本。

## Shell 和终端

- zsh 不再使用 oh-my-zsh 和 powerlevel10k。
- 插件管理使用 Antidote，bundle 位于 `~/.config/zsh/plugins.txt`。
- prompt 使用 Starship，配置位于 `~/.config/starship.toml`。
- Ghostty 配置位于 `~/.config/ghostty/config.ghostty`；macOS 上用 symlink 转发，避免 Application Support 中的配置覆盖 XDG 配置。
- Ghostty 应用本体不由 bootstrap 安装，需要手动安装。
- 首次连接缺少 Ghostty terminfo 的服务器时，运行 `ssh-terminfo user@host`；SSH 端口等参数也可照常传入，例如 `ssh-terminfo -p 2222 user@host`。
- Linux/WSL 检测到 `~/clashctl/scripts/cmd/clashctl.sh` 时，会自动加载 `clashctl`、`clashon`、`clashoff`、`clashtun` 等命令；自定义安装路径可在 `local.zsh` 中设置 `CLASHCTL_HOME`。
- 缺少 `tmh` 时会通过项目官方安装脚本安装到 `~/.local/bin`；Zsh 集成由 dotfiles 加载，使生成的命令进入输入缓冲区等待确认。

真实私有变量放在：

```bash
~/.config/dotfiles/local.zsh
```

仓库只提供示例：

```bash
~/.config/dotfiles/local.zsh.example
```

## 包安装策略

- macOS：优先 Homebrew；缺 Homebrew 时先提示确认。
- Debian/Ubuntu：有 root/sudo 时使用 apt；不可用包会跳过并提示。
- Arch：有 root/sudo 时使用 pacman；AUR 只在已安装 `paru` 时使用。
- Linux/WSL 无法提权时：安装经过 SHA256 校验的固定版 micromamba，并在 `~/.local/share/dotfiles/env` 中安装 CLI；不安装桌面字体或 Ghostty 应用。
- 启用 `node` feature 时：所有平台统一安装固定版 nvm，再由 nvm 安装最新 Node.js LTS；即使有 root，也不直接安装发行版的 Node/npm。
- 关键工具缺失时会用轻量 fallback，例如 Starship/tmh 官方安装脚本、Antidote git clone。

安装或启用 Node/npm：

```bash
DOTFILES_FEATURES="node" ./bootstrap.sh

# 同时保留 GPU feature
DOTFILES_FEATURES="gpu node" ./bootstrap.sh
```

进入新的 zsh 后可以验证：

```bash
node --version
npm --version
npx --version
```

用户级模式不会修改 `.bashrc`，也不会尝试绕过系统的登录 Shell 策略。安装完成后按提示进入 zsh：

```bash
exec "$HOME/.local/share/dotfiles/env/bin/zsh" -l
```

用户级模式至少需要系统预装 Git、`curl`/`wget` 之一，以及 `sha256sum`/`shasum` 之一。

## 验证

```bash
bash -n bootstrap.sh scripts/dotfiles/package-install.sh extras/clash.sh home/dot_local/bin/executable_bark
tests/package-mode.test.sh
zsh -n home/dot_zshrc home/dot_config/zsh/*.zsh home/dot_config/zsh/os/*.zsh home/dot_config/zsh/profiles/*.zsh home/dot_config/zsh/host/*.zsh
chezmoi --source "$PWD" apply --dry-run --force
```
