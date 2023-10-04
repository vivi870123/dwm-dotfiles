local conditions = require 'heirline.conditions'
local icons = mines.ui.icons.misc

local lsp_colors = {
  sumneko_lua = '#5EBCF6',
  vimls = '#43BF6C',
  ansiblels = '#ffffff',
}

-- Flexible components priorities
local priority = {
  CurrentPath = 60,
  Git = 40,
  Lsp = 10,
}

local Space = { provider = ' ' }

local LspIndicator = {
  provider = icons.circle_small .. ' ',
  hl = 'StLspIndicator',
}

local LspServer = {
  Space,
  {
    provider = function(self)
      local names = self.lsp_names
      if #names == 1 then
        names = names[1]
      else
        names = table.concat(names, ', ')
      end
      return names
    end,
  },
  hl = 'StLspServer',
}

return {
  condition = conditions.lsp_attached,
  update = { 'LspAttach', 'LspDetach', 'BufWinEnter' },
  init = function(self)
    local names = {}
    for _, server in pairs(vim.lsp.buf_get_clients(0)) do
      table.insert(names, server.name)
    end
    self.lsp_names = names
  end,
  on_click = {
    callback = function()
      vim.defer_fn(function() vim.cmd 'LspInfo' end, 100)
    end,
    name = 'heirline_LSP',
  },
  hl = function(self)
    local color
    for _, name in ipairs(self.lsp_names) do
      if lsp_colors[name] then
        color = lsp_colors[name]
        break
      end
    end
    if color then
      return { fg = color, bold = true, force = true }
    else
      return
    end
  end,
  flexible = priority.Lsp,

  LspServer,
  LspIndicator,
}
