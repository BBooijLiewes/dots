-- lua/plugin-configs/silicon.lua

local silicon = require('silicon')
local silicon_utils = require('silicon.utils')

silicon.setup({
  output = string.format(
    "~/Pictures/SILICON_%s-%s-%s_%s-%s.png",
    os.date("%Y"),
    os.date("%m"),
    os.date("%d"),
    os.date("%H"),
    os.date("%M")
  ),
})

vim.keymap.set('v', '<Leader>s', function() silicon.visualise_api({to_clip = false}) end )
vim.keymap.set('v', '<Leader>bs', function() silicon.visualise_api({to_clip = true}) end )

vim.api.nvim_create_augroup('SiliconRefresh', { clear = true })
vim.api.nvim_create_autocmd({ 'ColorScheme' },
  {
    group = 'SiliconRefresh',
    callback = function()
      silicon_utils.build_tmTheme()
      silicon_utils.reload_silicon_cache({async = true})
    end,
    desc = 'Reload silicon themes cache on colorscheme switch',
  }
)
