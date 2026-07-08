# AGENTS.md

## 仓库约束

- 这是公开 dotfiles 仓库，禁止提交真实密钥、token、设备 key、私有服务器地址或机器私有绝对路径。
- chezmoi 源目录是 `home/`，由根目录 `.chezmoiroot` 指定；不要把目标 `$HOME` 路径直接硬编码成仓库外文件。
- 真实本机变量只放在 `~/.config/dotfiles/local.zsh`，仓库只维护 `home/dot_config/dotfiles/local.zsh.example`。
- 基础包通过 `packages/` 下的简单文本清单维护；除 fallback 逻辑外，不要重新引入每个工具一个 installer 的旧结构。
- zsh 方案是 Starship + Antidote；不要重新加入 oh-my-zsh、powerlevel10k 或 `.p10k.zsh`。
- Ghostty 应用本体不由 bootstrap 安装，仓库只管理配置。
