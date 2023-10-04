--  Types
---@class StatuslineContext
---@field bufnum     number
---@field win        number
---@field bufname    string
---@field preview    boolean
---@field readonly   boolean
---@field filetype   string
---@field buftype    string
---@field modified   boolean
---@field fileformat string
---@field shiftwidth number
---@field expandtab  boolean

local api = vim.api

local Space = { provider = ' ' }
local Align = { provider = '%=' }

-------------
-- components
-------------
local mod = require 'plugins.statusline.components'
local vim_mode, saving, macro, filename = mod.vim_mode, mod.saving, mod.macro, mod.filename
local diagnostics, git, lsp, line_properties = mod.diagnostics, mod.git, mod.lsp, mod.line_properties

local statusline = {
  init = function(self)
    local curwin = api.nvim_get_current_win()
    local curbuf = api.nvim_win_get_buf(curwin)

    ---@type StatuslineContext
    self.ctx = {
      bufnum = curbuf,
      win = curwin,
      bufname = api.nvim_buf_get_name(curbuf),
      preview = vim.wo[curwin].previewwindow,
      readonly = vim.bo[curbuf].readonly,
      filetype = vim.bo[curbuf].ft,
      buftype = vim.bo[curbuf].bt,
      modified = vim.bo[curbuf].modified,
      fileformat = vim.bo[curbuf].fileformat,
      shiftwidth = vim.bo[curbuf].shiftwidth,
      expandtab = vim.bo[curbuf].expandtab,
    }
  end,
  {
    fallthrough = false,
    vim_mode,
  },
  Space,
  {
    fallthrough = false,
    saving,
    {
      macro,
      filename,
    },
  },
  Align,
  diagnostics,
  git,
  lsp,
  Space,
  line_properties,
  hl = 'StStatusLine',
}

mines.augroup('Heirline', {
  event = 'ColorScheme',
  command = function()
    if not vim.g.is_saving and vim.bo.modified then
      vim.g.is_saving = true
      vim.defer_fn(function() vim.g.is_saving = false end, 1000)
    end
  end,
})

return statusline
