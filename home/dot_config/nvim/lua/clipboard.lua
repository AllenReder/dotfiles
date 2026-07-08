-- 禁用默认剪贴板提供者
vim.g.clipboard = false
-- 启用 unnamedplus，让 y 默认使用系统剪贴板
vim.opt.clipboard:append("unnamedplus")
-- 配置 OSC 52
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
