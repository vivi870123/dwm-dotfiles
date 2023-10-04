local api, fn, bo = vim.api, vim.fn, vim.bo
local P, icons = mines.ui.palette, mines.ui.icons

local util = require 'heirline.utils'
local sep = icons.separators
local Space = { provider = ' ' }

local mode_names = setmetatable({
  n = 'normal',
  no = 'op',
  nov = 'op',
  noV = 'op',
  ['no'] = 'op',
  niI = 'normal',
  niR = 'normal',
  niV = 'normal',
  nt = 'normal',
  v = 'visual',
  V = 'visual_lines',
  [''] = 'visual_block',
  s = 'select',
  S = 'select',
  [''] = 'block',
  i = 'insert',
  ic = 'insert',
  ix = 'insert',
  R = 'replace',
  Rc = 'replace',
  Rv = 'v_replace',
  Rx = 'replace',
  c = 'command',
  cv = 'command',
  ce = 'command',
  r = 'enter',
  rm = 'more',
  ['r?'] = 'confirm',
  ['!'] = 'shell',
  t = 'terminal',
  ['null'] = 'none',
}, {
  __call = function(self, raw_mode) return self[raw_mode] end,
})

-- Mode colors
local vim_mode = {
  normal = { color = P.light_gray, label = 'NORMAL' },
  op = { color = P.dark_blue, label = 'OP' },
  insert = { color = P.blue, label = 'INSERT' },
  visual = { color = P.magenta, label = 'VISUAL' },
  visual_lines = { color = P.magenta, label = 'VISUAL LINES' },
  visual_block = { color = P.magenta, label = 'VISUAL BLOCK' },
  replace = { color = P.dark_red, label = 'REPLACE' },
  v_replace = { color = P.dark_red, label = 'V-REPLACE' },
  enter = { color = P.aqua, label = 'ENTER' },
  more = { color = P.aqua, label = 'MORE' },
  select = { color = P.teal, label = 'SELECT' },
  command = { color = P.light_yellow, label = 'COMMAND' },
  shell = { color = P.orange, label = 'SHELL' },
  term = { color = P.orange, label = 'TERMINAL' },
  none = { color = P.dark_red, label = 'NONE' },
  block = { color = P.dark_red, label = 'BLOCK' },
  confirm = { color = P.dark_red, label = 'CONFIRM' },
}

local Mode = setmetatable({ normal = { fg = vim_mode.normal.color } }, {
  __index = function(_, mode)
    return {
      fg = P.black,
      bg = vim_mode[mode].color,
      bold = true,
    }
  end,
})

local ReadOnly = {
  condition = function() return not bo.modifiable or bo.readonly end,
  provider = icons.lock,
  hl = 'StError',
}

local Modified = {
  provider = function() return bo.modified and icons.misc.circle_plus or icons.misc.circle end,
  hl = function() return vim.bo.modified and 'StModified' or Mode.normal end,
}

local NormalModeIndicator = {
  Space,
  {
    fallthrough = false,
    ReadOnly,
    Modified,
  },
}

local ActiveModeIndicator = {
  condition = function(self) return self.mode ~= 'normal' end,
  util.surround({ sep.circle_left, sep.circle_right }, function(self)
    return Mode[self.mode].bg -- color
  end, {
    {
      fallthrough = false,
      ReadOnly,
      Modified,
    },
    Space,
    {
      provider = function(self) return vim_mode[self.mode].label end,
      hl = function(self) return Mode[self.mode] end,
    },
  }),
}

return {
  init = function(self) self.mode = mode_names[fn.mode(1)] end, -- :h mode()``
  condition = function() return bo.buftype == '' end,
  {
    fallthrough = false,
    ActiveModeIndicator,
    NormalModeIndicator,
  },
}
