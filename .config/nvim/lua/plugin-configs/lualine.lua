-- lua/plugin-configs/lualine.lua

local navic = require 'nvim-navic'

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
    lualine_b = {'branch', 'diff', {'diagnostics', sources={'nvim_diagnostic'}}},
    lualine_c = {{'filename', path=1}, {
        navic.get_location,
        cond = navic.is_available,
        padding = {left = 1, right = 0},
    }},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location', {
        function()
          -- This function will return hardtime hints
          local hints = vim.g.hardtime_hints or ''
          return hints
        end,
        color = { fg = '#ff9e64', gui = 'bold' },
    }},
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
  extensions = {'fzf'}
}

navic.setup({
    separator = "  ",
    highlight = true
})
