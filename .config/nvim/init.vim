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
set clipboard=unnamedplus

set spelllang=en_gb,nl

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

call plug#begin()
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'romgrk/barbar.nvim'
    Plug 'rktjmp/lush.nvim'
    Plug 'ellisonleao/gruvbox.nvim'
	Plug 'psliwka/vim-smoothie'
	Plug 'mbbill/undotree'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'honza/vim-snippets'
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-fugitive'
    Plug 'b3nj5m1n/kommentary'
    Plug 'airblade/vim-gitgutter'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    Plug 'nvim-telescope/telescope-file-browser.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'saadparwaiz1/cmp_luasnip',
    Plug 'L3MON4D3/LuaSnip'
    Plug 'ray-x/cmp-treesitter',
    Plug 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    Plug 'weilbith/nvim-code-action-menu',
    Plug 'antoinemadec/FixCursorHold.nvim',
    Plug 'kosayoda/nvim-lightbulb',
    Plug 'f-person/git-blame.nvim',
    Plug 'sindrets/diffview.nvim'
call plug#end()

""autocmd vimenter * ++nested 

set background=dark    " Setting dark mode
colorscheme gruvbox

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
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_diagnostic'}}},
    lualine_c = {{'filename', path=1}},
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

" function s:chadOpen()
" lua << EOF
"    require'bufferline.state'.set_offset(41, "FileTree")
" EOF
"   CHADopen --nofocus
"   if argc() > 0  || exists("s:std_in")
"     wincmd p
"   endif
" endfunction

" autocmd VimEnter * call s:chadOpen()

" autocmd bufenter * if (winnr("$") == 1 && &buftype == "nofile" && &filetype == "CHADTree") | quit | endif

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

lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = "all",

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  }
}

EOF
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
autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting_sync(nil, 100)
autocmd BufWritePre *.py lua vim.lsp.buf.formatting_sync(nil, 100)

" nvim-cmp
set completeopt=menu,menuone,noselect

lua <<EOF

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  -- Setup nvim-cmp.
  local cmp = require'cmp'
  local luasnip = require("luasnip")

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
  mapping = {
    ['<C-Space>'] = cmp.mapping.confirm({ select = true }),
    -- ... Your other mappings ...

    ["<Tab>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      -- elseif vim.fn.pumvisible() == 1 then
      --   feedkey("<C-n>")
      elseif cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    -- ... Your other mappings ...
  },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
      { name = 'buffer' },
      { name = 'path'},
      { name = 'treesitter'}}
    )
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig').pyright.setup {
    capabilities = capabilities
  }
  require('lspconfig').bashls.setup {
    capabilities = capabilities
  }
  require('lspconfig').dockerls.setup {
    capabilities = capabilities
  }
  require('lspconfig').tsserver.setup {
    capabilities = capabilities
  }
  require'lspconfig'.jsonls.setup {
    capabilities = capabilities,
  }
  require'lspconfig'.dartls.setup {
    capabilities = capabilities,
  }
  require'lspconfig'.intelephense.setup{
    capabilities = capabilities,
  }
  require("lsp_lines").setup()
  vim.diagnostic.config({
      virtual_text = false,
  })
  require('nvim-lightbulb').setup({autocmd = {enabled = true}})
EOF
