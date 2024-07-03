-- lua/settings.lua

-- General settings
vim.opt.encoding = 'utf-8'        -- Set default encoding to UTF-8
vim.opt.fileencoding = 'utf-8'    -- Set file encoding to UTF-8
vim.opt.number = true             -- Show line numbers
vim.opt.showcmd = true            -- Show command in the last line of the screen
vim.opt.ignorecase = true         -- Ignore case when searching
vim.opt.smartcase = true          -- Override 'ignorecase' if search contains uppercase
vim.opt.autoindent = true         -- Auto indent new lines
vim.opt.hlsearch = true           -- Highlight search results
vim.opt.incsearch = true          -- Show search matches as you type
vim.opt.scrolloff = 10            -- Keep 10 lines visible above/below cursor
vim.opt.hidden = true             -- Allow unsaved buffers in the background
vim.opt.autoread = true           -- Auto read file changes
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.termguicolors = true      -- Enable 24-bit RGB colors
vim.opt.mouse = 'a'               -- Enable mouse support
vim.opt.cmdheight = 0             -- Set command line height to 0 (requires UI support)
vim.opt.spell = true              -- Enable spell check
vim.opt.spelllang = { 'en', 'nl' }-- Set spell check languages

-- Tabbing settings
vim.opt.softtabstop = 0           -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 4            -- Number of spaces to use for auto-indent
vim.opt.tabstop = 4               -- Number of spaces a <Tab> counts for
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.cindent = true            -- Enable C-style indentation
vim.opt.smarttab = true           -- Make tabbing smarter

-- Enable syntax highlighting and filetype plugins
vim.cmd 'filetype plugin on'
vim.cmd 'syntax on'

-- Python version for Neovim
vim.g.pyxversion = 3

-- Hardline settings
vim.opt.showmode = false

-- set both full and relative line numbers
vim.opt.nu = true
vim.opt.relativenumber = true
vim.o.statuscolumn = "%s %l %r "
