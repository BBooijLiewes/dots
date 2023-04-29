set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set number
set showcmd 
set ignorecase
set autoindent 
set hlsearch
set incsearch
set scrolloff=10
set nowrap
set hidden
set smartcase
set autoread
set clipboard+=unnamedplus

set spell
set spelllang=en,nl

" tabbing
set softtabstop=0
set shiftwidth=4
set tabstop=4
set expandtab
set cindent
set smarttab

set termguicolors

filetype plugin on
syntax on
set pyxversion=3

" enable scroll
set mouse=a
set cmdheight=0

call plug#begin()
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'romgrk/barbar.nvim'
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'rktjmp/lush.nvim'
	Plug 'psliwka/vim-smoothie'
	Plug 'mbbill/undotree'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'honza/vim-snippets'
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-fugitive'
    Plug 'b3nj5m1n/kommentary'
    Plug 'airblade/vim-gitgutter'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    Plug 'nvim-telescope/telescope-file-browser.nvim'
    Plug 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    Plug 'weilbith/nvim-code-action-menu',
    Plug 'antoinemadec/FixCursorHold.nvim',
    Plug 'kosayoda/nvim-lightbulb',
    Plug 'f-person/git-blame.nvim',
    Plug 'sindrets/diffview.nvim',
    Plug 'nvim-lua/plenary.nvim',
    Plug 'SmiteshP/nvim-navic',
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    " LSP Support
    Plug 'neovim/nvim-lspconfig'                           " Required
    Plug 'williamboman/mason.nvim', {'do': ':MasonUpdate'} " Optional
    Plug 'williamboman/mason-lspconfig.nvim'               " Optional

    " Autocompletion
    Plug 'hrsh7th/nvim-cmp'     " Required
    Plug 'hrsh7th/cmp-nvim-lsp' " Required
    Plug 'L3MON4D3/LuaSnip'     " Required
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'

    Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}
call plug#end()

""autocmd vimenter * ++nested 
colorscheme tokyonight-night

" remap nerdcomment
nnoremap <C-_> :call NERDComment(0, "toggle")<CR>
vnoremap <C-_> :call NERDComment(0, "toggle")<CR>

" buffers jump to existing window
let g:fzf_buffers_jump = 1
" set fzf layout
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.6, 'border': 'rounded' } }

" copy to clipboard
vnoremap Y "+y

" paste from yank register
nnoremap p "0p
vnoremap p "0p

" in millisecond, used for both CursorHold and CursorHoldI,
" use updatetime instead if not defined
let g:cursorhold_updatetime = 100


lua << EOF
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    find_files = {
      theme = "dropdown",
      hidden = true,
    },
    live_grep = {
      theme = "dropdown",
      hidden = true,
    },
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
    file_browser = {
        theme='dropdown',
        hidden = true,
    },
  }
}
require('telescope').load_extension('fzf')
require("telescope").load_extension "file_browser"
vim.api.nvim_set_keymap('n', '<C-f>', '<cmd>lua require "telescope".extensions.file_browser.file_browser({ path = vim.fn.expand("%:p:h") })<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-b>', '<cmd>lua require "telescope".extensions.file_browser.file_browser()<cr>', { noremap = true })
EOF

" map Telescope
map <C-p> :Telescope find_files<CR>
map <C-j> :Telescope live_grep<CR>

" double esc to disable hlsearch
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>

" nvim code actions menu
map <C-h> :CodeActionMenu<CR>

" Easy file history
nnoremap <silent> <expr> <C-x> ':DiffviewFileHistory %<CR>'

" Easily link to gitlab commit
nnoremap <silent> <expr> <C-l> ':GitBlameOpenCommitURL<CR>'


lua << EOF

navic = require 'nvim-navic'
navic.setup({
    separator = "  ",
    highlight = true
})


require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'tokyonight',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_diagnostic'}}},
    lualine_c = {{'filename', path=1},{
            navic.get_location,
            cond=navic.is_available,
            padding={left=1, right=0},
    }},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {'chadtree', 'fugitive', 'fzf'}
}
EOF

" Move to previous/next
nnoremap <silent>    <A-,> :BufferPrevious<CR>
nnoremap <silent>    <A-.> :BufferNext<CR>
" Re-order to previous/next
nnoremap <silent>    <A-<> :BufferMovePrevious<CR>
nnoremap <silent>    <A->> :BufferMoveNext<CR>
" Goto buffer in position...
nnoremap <silent>    <A-1> :BufferGoto 1<CR>
nnoremap <silent>    <A-2> :BufferGoto 2<CR>
nnoremap <silent>    <A-3> :BufferGoto 3<CR>
nnoremap <silent>    <A-4> :BufferGoto 4<CR>
nnoremap <silent>    <A-5> :BufferGoto 5<CR>
nnoremap <silent>    <A-6> :BufferGoto 6<CR>
nnoremap <silent>    <A-7> :BufferGoto 7<CR>
nnoremap <silent>    <A-8> :BufferGoto 8<CR>
nnoremap <silent>    <A-9> :BufferLast<CR>
" Pin/unpin buffer
nnoremap <silent>    <A-p> :BufferPin<CR>
" Close buffer
nnoremap <silent>    <A-c> :BufferClose<CR>
" New buffer
nnoremap <silent>    <A-n> :enew<CR>
" Wipeout buffer
"                          :BufferWipeout<CR>
" Close commands
"                          :BufferCloseAllButCurrent<CR>
"                          :BufferCloseAllButPinned<CR>
"                          :BufferCloseBuffersLeft<CR>
"                          :BufferCloseBuffersRight<CR>
" Magic buffer-picking mode
nnoremap <silent> <C-s>    :BufferPick<CR>
" Sort automatically by...
nnoremap <silent> <Space>bb :BufferOrderByBufferNumber<CR>
nnoremap <silent> <Space>bd :BufferOrderByDirectory<CR>
nnoremap <silent> <Space>bl :BufferOrderByLanguage<CR>
nnoremap <silent> <Space>bw :BufferOrderByWindowNumber<CR>


" Shift + J/K moves selected lines down/up in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" LSP config (the mappings used in the default file don't quite work right)
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>

" auto-format
" autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
" autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting_sync(nil, 100)
" autocmd BufWritePre *.py lua vim.lsp.buf.formatting_sync(nil, 100)
"
"
lua require'nvim-treesitter.configs'.setup{highlight={enable=true}}

lua <<EOF


local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  mapping = {
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    ['<CR>'] = cmp.mapping.confirm({select = false}),
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
  }
})

EOF
