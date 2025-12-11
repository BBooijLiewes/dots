-- lua/diag_hover.lua
-- Minimal, production-grade diagnostic hover on CursorHold/CursorHoldI.

local M = {}

local defaults = {
  updatetime   = 250,                 -- ms before CursorHold fires
  scope        = "cursor",            -- "cursor" | "line"
  border       = "rounded",
  focus        = false,
  focusable    = false,
  close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
  severity_min = nil,                 -- e.g. vim.diagnostic.severity.WARN
  filetypes    = nil,                 -- e.g. { "lua", "python", "typescript", ... } (nil = all)
}

local augroup

--- Shallow check for diagnostics at current line (filtered by severity)
local function line_diags(bufnr, line, severity_min)
  return vim.diagnostic.get(bufnr, {
    lnum = line,
    severity = severity_min and { min = severity_min } or nil,
  })
end

function M.setup(opts)
  opts = vim.tbl_extend("force", {}, defaults, opts or {})

  -- Make CursorHold feel responsive (opt-in; skip if user manages this elsewhere)
  if type(opts.updatetime) == "number" and opts.updatetime > 0 then
    vim.o.updatetime = opts.updatetime
  end

  if augroup then pcall(vim.api.nvim_del_augroup_by_id, augroup) end
  augroup = vim.api.nvim_create_augroup("DiagHover", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = augroup,
    desc = "Show LSP diagnostics in a floating window on hover",
    callback = function()
      -- Quiet in special buffers
      if vim.bo.buftype ~= "" or vim.fn.mode() == "c" then return end
      if opts.filetypes and not vim.tbl_contains(opts.filetypes, vim.bo.filetype) then return end

      local bufnr = 0
      local pos = vim.api.nvim_win_get_cursor(0)
      local line = pos[1] - 1

      -- No diagnostics on this line? bail early.
      local diags = line_diags(bufnr, line, opts.severity_min)
      if #diags == 0 then return end

      -- Avoid flicker: don’t reopen at the same position
      local key = ("%d:%d"):format(line, pos[2])
      if vim.b._diag_hover_last == key then return end

      vim.diagnostic.open_float(bufnr, {
        focus = opts.focus,
        focusable = opts.focusable,
        scope = opts.scope,            -- "cursor" is the tightest; use "line" to be more permissive
        border = opts.border,
        source = "if_many",
        close_events = opts.close_events,
      })

      vim.b._diag_hover_last = key
    end,
  })

  -- Reset cache when moving far or switching buffers
  vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "InsertEnter" }, {
    group = augroup,
    callback = function() vim.b._diag_hover_last = nil end,
  })
end

function M.disable()
  if augroup then pcall(vim.api.nvim_del_augroup_by_id, augroup) end
  augroup = nil
end

return M

