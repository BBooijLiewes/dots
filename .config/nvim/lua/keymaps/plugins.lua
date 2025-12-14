-- lua/keymaps/plugins.lua

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Telescope mappings
map('n', '<C-p>', ':Telescope find_files<CR>', opts)
map('n', '<C-j>', ':Telescope live_grep<CR>', opts)
map('n', '<C-f>', '<cmd>lua require("telescope").extensions.file_browser.file_browser({ path = vim.fn.expand("%:p:h") })<cr>', opts)
map('n', '<C-b>', '<cmd>lua require("telescope").extensions.file_browser.file_browser()<cr>', opts)

-- Precognition toggle
map('n', '<C-h>', ':lua require("precognition").toggle()<CR>', opts)
