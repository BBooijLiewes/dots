-- lua/keymaps/buffers.lua

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Navigate buffers
map('n', '<A-,>', ':BufferPrevious<CR>', opts)
map('n', '<A-.>', ':BufferNext<CR>', opts)

-- Re-order buffers
map('n', '<A-<>', ':BufferMovePrevious<CR>', opts)
map('n', '<A->>', ':BufferMoveNext<CR>', opts)

-- Goto buffer in position
for i = 1, 9 do
    map('n', '<A-' .. i .. '>', ':BufferGoto ' .. i .. '<CR>', opts)
end
map('n', '<A-9>', ':BufferLast<CR>', opts)

-- Pin/unpin buffer
map('n', '<A-p>', ':BufferPin<CR>', opts)

-- Close buffer
map('n', '<A-c>', ':BufferClose<CR>', opts)

-- New buffer
map('n', '<A-n>', ':enew<CR>', opts)

-- Buffer picker
map('n', '<C-s>', ':BufferPick<CR>', opts)

-- Sort buffers
map('n', '<Space>bb', ':BufferOrderByBufferNumber<CR>', opts)
map('n', '<Space>bd', ':BufferOrderByDirectory<CR>', opts)
map('n', '<Space>bl', ':BufferOrderByLanguage<CR>', opts)
map('n', '<Space>bw', ':BufferOrderByWindowNumber<CR>', opts)
