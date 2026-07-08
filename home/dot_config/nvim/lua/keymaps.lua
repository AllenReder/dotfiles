-- ~/.config/nvim/lua/keymaps.lua

-- 先定义一个方便的映射函数
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 在普通模式下，将 J 映射为 Ctrl+D （向下翻半页）
map('n', 'J', '<C-d>', opts)

-- 在普通模式下，将 K 映射为 Ctrl+U （向上翻半页）
map('n', 'K', '<C-u>', opts)

-- 在可视模式下，将 J/K 映射为 Ctrl+D/Ctrl+U（上下翻半页）
map('v', 'J', '<C-d>', opts)
map('v', 'K', '<C-u>', opts)
