local api = vim.api
local icon = mines.ui.icons.misc
local conditions = require 'heirline.conditions'
local Space = { provider = ' ' }

local LineNumber = { provider = function(self) return icon.line .. self.lnum end }
local LineCount = { provider = function(self) return '/' .. self.line_count end }
local Col = { provider = function(self) return ' ' .. self.col end }

local ScrollPercentage = {
  condition = function() return conditions.width_percent_below(4, 0.035) end,
  provider = '%3(%P%)',
}

local function init(self)
  local lnum, col = unpack(api.nvim_win_get_cursor(self.ctx.win))
  local line_count = api.nvim_buf_line_count(self.ctx.bufnum)

  self.lnum = lnum
  self.col = col
  self.line_count = line_count
end

return {
  init = init,
  Space,
  LineNumber,
  LineCount,
  Col,
  Space,
  ScrollPercentage,
  Space,
  hl = 'StMetadataPerfix',
}
