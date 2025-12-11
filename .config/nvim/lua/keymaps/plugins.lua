-- lua/keymaps/plugins.lua

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Telescope mappings
map('n', '<C-p>', ':Telescope find_files<CR>', opts)
map('n', '<C-j>', ':Telescope live_grep<CR>', opts)
map('n', '<C-f>', '<cmd>lua require("telescope").extensions.file_browser.file_browser({ path = vim.fn.expand("%:p:h") })<cr>', opts)
map('n', '<C-b>', '<cmd>lua require("telescope").extensions.file_browser.file_browser()<cr>', opts)

-- Code action menu
map('n', '<C-h>', ':lua require("precognition").toggle()<CR>', opts)

-- CodeCompanion key mappings using Shift+Q as the prefix.

-- Normal mode mappings
vim.keymap.set("n", "QA", "<cmd>CodeCompanion<CR>", { desc = "Open CodeCompanion Assistant" })
vim.keymap.set("n", "QG", "<cmd>CodeCompanionGenerate<CR>", { desc = "Generate code with CodeCompanion" })
vim.keymap.set("n", "QS", "<cmd>CodeCompanionStatus<CR>", { desc = "Show CodeCompanion Status" })
vim.keymap.set("n", "QC", "<cmd>CodeCompanionChat<CR>", { desc = "Chat with CodeCompanion" })
vim.keymap.set("n", "QX", "<cmd>CodeCompanionExplain<CR>", { desc = "Explain code using CodeCompanion" })
vim.keymap.set("n", "QF", "<cmd>CodeCompanionFix<CR>", { desc = "Fix code using CodeCompanion" })
vim.keymap.set("n", "QT", "<cmd>CodeCompanionToggleContext<CR>", { desc = "Toggle CodeCompanion context view" })

-- Visual mode mapping: use selected text as input
vim.keymap.set("v", "QV", ":<C-u>CodeCompanionVisual<CR>", { desc = "Query CodeCompanion on selection" })

-- Insert mode mapping: trigger inline autocomplete (if supported by your setup)
vim.keymap.set("i", "QI", function()
  require("codecompanion").autocomplete()
end, { desc = "Trigger CodeCompanion Autocomplete" })
