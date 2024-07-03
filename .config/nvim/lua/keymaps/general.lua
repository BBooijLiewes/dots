-- lua/keymaps/general.lua

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Toggle comments
map('n', '<C-_>', ':call NERDComment(0, "toggle")<CR>', opts)
map('v', '<C-_>', ':call NERDComment(0, "toggle")<CR>', opts)

-- Copy to clipboard
map('v', 'Y', '"+y', opts)

-- Paste from yank register
map('n', 'p', '"0p', opts)
map('v', 'p', '"0p', opts)

-- Double escape to disable search highlight
map('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR><Esc>', opts)

-- Move selected lines
map('v', 'J', ':m \'>+1<CR>gv=gv', opts)
map('v', 'K', ':m \'<-2<CR>gv=gv', opts)
