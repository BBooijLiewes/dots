-- lua/plugin-configs/nvim-treesitter.lua

local configs = require('nvim-treesitter.configs')

-- Disable heavyweight TS features on very large files
local function ts_disable_large(_, buf)
  local max_filesize = 256 * 1024 -- 256 KB
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  if ok and stats and stats.size > max_filesize then
    return true
  end
  if vim.api.nvim_buf_line_count(buf) > 20000 then
    return true
  end
  return false
end

configs.setup {
  -- Installs missing parsers once; won’t “reinstall every time”
  ensure_installed = {
    'markdown', 'markdown_inline',
    'javascript', 'typescript', 'tsx',
    'python', 'bash', 'dockerfile',
    'json', 'jsonc', 'yaml', 'toml', 'regex',
    'lua', 'vim', 'vimdoc',
    'gitcommit', 'gitignore', 'git_rebase',
  },
  sync_install = false,
  auto_install = false, -- don’t auto-fetch when opening new filetypes

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false, -- avoid double-highlighting
    disable = ts_disable_large,                -- big-file guard
  },

  -- Treesitter indent can be flaky for some langs; disable where it’s noisy
  indent = {
    enable = true,
    disable = { 'python', 'yaml' },
  },

  -- Super handy for structural selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = 'gnn',
      node_incremental  = 'grn',
      scope_incremental = 'grc',
      node_decremental  = 'grm',
    },
  },

  -- Harmless if you don’t have andymass/vim-matchup; enables smart % jumps
  matchup = { enable = true },
}

-- Optional: Treesitter-powered folding (keeps files snappy & tidy)
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr   = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel  = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
