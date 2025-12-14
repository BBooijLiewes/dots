-- lua/lazy_setup.lua

-- Ensure lazy.nvim is loaded
local ensure_lazy = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/lazy/start/lazy.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/folke/lazy.nvim.git", install_path })
		vim.cmd([[packadd lazy.nvim]])
		return true
	end
	return false
end

local lazy_bootstrap = ensure_lazy()

require("lazy").setup({
	-- Plugin list
	"kyazdani42/nvim-web-devicons",
	"romgrk/barbar.nvim",
	"folke/tokyonight.nvim",
	"Apeiros-46B/qalc.nvim",
	"rktjmp/lush.nvim",
	"psliwka/vim-smoothie",
	"mbbill/undotree",
	"nvim-lualine/lualine.nvim",
	"honza/vim-snippets",
	"sheerun/vim-polyglot",
	"b3nj5m1n/kommentary",
	"nvim-telescope/telescope.nvim",
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	"nvim-telescope/telescope-file-browser.nvim",
	"weilbith/nvim-code-action-menu",
	"antoinemadec/FixCursorHold.nvim",
	"kosayoda/nvim-lightbulb",
	"sindrets/diffview.nvim",
	"nvim-lua/plenary.nvim",
	"SmiteshP/nvim-navic",
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	-- LSP Support
	"neovim/nvim-lspconfig",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",

	-- Autocompletion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",

	{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },

	-- colours
	"brenoprata10/nvim-highlight-colors",

	-- git
	"lewis6991/gitsigns.nvim",

	-- Habits
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {},
	},
	"tris203/precognition.nvim",
}, {
	install = { missing = true, colorscheme = { "tokyonight-night" } },
})

if lazy_bootstrap then
	require("lazy").sync()
end
