local conditions = require 'heirline.conditions'

local GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self) self.git_status = vim.b.gitsigns_status_dict end,
  provider = function(self) return table.concat { ' ', self.git_status.head } end,
  hl = 'StGitBranch',
}

local GitChanges = {
  condition = function(self)
    if conditions.is_git_repo() then
      self.git_status = vim.b.gitsigns_status_dict
      local has_changes = self.git_status.added ~= 0 or self.git_status.removed ~= 0 or self.git_status.changed ~= 0
      return has_changes
    end
  end,
  provider = '  ',
  hl = 'StGitDirty',
}

return {
  GitBranch,
  GitChanges,
}
