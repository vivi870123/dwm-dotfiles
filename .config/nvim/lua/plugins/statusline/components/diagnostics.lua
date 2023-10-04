local conditions = require 'heirline.conditions'

return {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = mines.ui.icons.lsp.error .. ' ',
    warn_icon = mines.ui.icons.lsp.warn .. ' ',
    info_icon = mines.ui.icons.lsp.info .. ' ',
    hint_icon = mines.ui.icons.lsp.hint .. ' ',
  },
  update = { 'DiagnosticChanged', 'BufEnter' },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  {
    provider = function(self)
      if self.errors > 0 then return table.concat { self.error_icon, self.errors, '  ' } end
    end,
    hl = 'StHint',
  },
  {
    provider = function(self)
      if self.warnings > 0 then return table.concat { self.warn_icon, self.warnings, '  ' } end
    end,
    hl = 'StWarn',
  },
  {
    provider = function(self)
      if self.info > 0 then return table.concat { self.info_icon, self.info, '  ' } end
    end,
    hl = 'StInfo',
  },
  {
    provider = function(self)
      if self.hints > 0 then return table.concat { self.hint_icon, self.hints, '  ' } end
    end,
    hl = 'StHint',
  },
  on_click = {
    callback = function() vim.diagnostic.setloclist() end,
    name = 'heirline_diagnostics',
  },
}
