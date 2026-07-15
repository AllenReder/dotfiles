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

首次运行会把选择写入 `~/.config/dotfiles/profile.env`。之后可以通过环境变量覆盖：

```bash
DOTFILES_PROFILE=server DOTFILES_FEATURES="" ./bootstrap.sh
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
- Debian/Ubuntu：优先 apt；不可用包会跳过并提示。
- Arch：优先 pacman；AUR 只在已安装 `paru` 时使用。
- 关键工具缺失时会用轻量 fallback，例如 Starship/tmh 官方安装脚本、Antidote git clone。

## 验证

```bash
bash -n bootstrap.sh scripts/dotfiles/package-install.sh extras/clash.sh home/dot_local/bin/executable_bark
zsh -n home/dot_zshrc home/dot_config/zsh/*.zsh home/dot_config/zsh/os/*.zsh home/dot_config/zsh/profiles/*.zsh home/dot_config/zsh/host/*.zsh
chezmoi --source "$PWD" apply --dry-run --force
```
