local api, fn, wo, bo = vim.api, vim.fn, vim.wo, vim.bo

local icons = mines.ui.icons
local seprator = icons.separators
local heirline_util = require 'heirline.utils'
local Space = { provider = ' ' }

local M = {}

M.ReadOnly = {
  condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
  provider = icons.misc.padlock,
  hl = 'StError',
}

M.filename = require 'plugins.statusline.components.filename'
M.vim_mode = require 'plugins.statusline.components.vim_mode'
M.line_properties = require 'plugins.statusline.components.line_properties'
M.git = require 'plugins.statusline.components.git'
M.lsp = require 'plugins.statusline.components.lsp'
M.diagnostics = require 'plugins.statusline.components.diagnostics'

M.saving = {
  condition = function() return vim.g.is_saving end,
  provider = function() return 'Saving...' end,
}

M.macro = {
  condition = function() return fn.reg_recording() ~= '' and vim.o.cmdheight == 0 end,
  heirline_util.surround(
    { seprator.circle_left, seprator.circle_right },
    require('heirline.utils').get_highlight('StMacroRecording').fg,
    {
      provider = function() return ' Recording @' .. fn.reg_recording() end,
      hl = {
        bg = require('heirline.utils').get_highlight('StMacroRecording').fg,
        bg = require('heirline.utils').get_highlight('StMacroRecording').bg,
      },
    }
  ),
  Space,
}

M.dap = {
  -- display the dap messages only on the debugged file
  condition = function()
    local session = require('dap').session()
    if session then
      local file_name = api.nvim_buf_get_name(0)
      if session.config then
        local progname = session.config.program
        return file_name == progname
      end
    end
    return false
  end,
  provider = function() return icons.misc.bug .. require('dap').status() .. ' ' end,
  hl = 'StDapMessages',
}

return M
