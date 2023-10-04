local api, fn, fmt = vim.api, vim.fn, string.format
local sep = package.config:sub(1, 1)

local identifiers = {
  buftypes = {
    terminal = ' ',
    quickfix = '',
  },
  filetypes = {
    ['org'] = '',
    ['orgagenda'] = '',
    ['himalaya-msg-list'] = '',
    ['mail'] = '',
    ['dbui'] = '',
    ['DiffviewFiles'] = 'פּ',
    ['tsplayground'] = '侮',
    ['Trouble'] = '',
    ['NeogitStatus'] = '', -- '',
    ['norg'] = 'ﴬ',
    ['help'] = '',
    ['undotree'] = 'פּ',
    ['NvimTree'] = 'פּ',
    ['neo-tree'] = 'פּ',
    ['toggleterm'] = ' ',
    ['minimap'] = '',
    ['octo'] = '',
    ['dap-repl'] = '',
  },
  names = {
    ['orgagenda'] = 'Org',
    ['himalaya-msg-list'] = 'Inbox',
    ['mail'] = 'Mail',
    ['minimap'] = '',
    ['dbui'] = 'Dadbod UI',
    ['tsplayground'] = 'Treesitter',
    ['NeogitStatus'] = 'Neogit Status',
    ['Trouble'] = 'Lsp Trouble',
    ['gitcommit'] = 'Git commit',
    ['help'] = 'help',
    ['undotree'] = 'UndoTree',
    ['octo'] = 'Octo',
    ['NvimTree'] = 'Nvim Tree',
    ['dap-repl'] = 'Debugger REPL',
    ['DiffviewFiles'] = 'Diff view',

    ['neo-tree'] = function(fname, _)
      local parts = vim.split(fname, ' ')
      return fmt('Neo Tree(%s)', parts[2])
    end,

    ['toggleterm'] = function(_, buf)
      local shell = vim.fn.fnamemodify(vim.env.SHELL, ':t')
      return fmt('Terminal(%s)[%s]', shell, vim.api.nvim_buf_get_var(buf, 'toggle_number'))
    end,
  },
}

--- This function allow me to specify titles for special case buffers
--- like the preview window or a quickfix window
--- CREDIT: https://vi.stackexchange.com/a/18090
--- @param ctx StatuslineContext
local function special_buffers(ctx)
  local location_list = fn.getloclist(0, { filewinid = 0 })
  local is_loc_list = location_list.filewinid > 0
  local normal_term = ctx.buftype == 'terminal' and ctx.filetype == ''

  if is_loc_list then return 'Location List' end
  if ctx.buftype == 'quickfix' then return 'Quickfix List' end
  if normal_term then return 'Terminal(' .. fn.fnamemodify(vim.env.SHELL, ':t') .. ')' end
  if ctx.preview then return 'preview' end

  return nil
end

---Only append the path separator if the path is not empty
---@param path string
---@return string
local function path_sep(path) return not mines.falsy(path) and path .. sep or path end

--- Replace the directory path with an identifier if it matches a commonly visited
--- directory of mine such as my projects directory or my work directory
--- since almost all my project directories are nested underneath one of these paths
--- this should match often and reduce the unnecessary boilerplate in my path as
--- I know where these directories are generally
---@param directory string
---@return string directory
---@return string custom_dir
local function dir_env(directory)
  if not directory then return '', '' end
  local paths = {
    [vim.g.dotfiles] = '$DOTFILES',
    [vim.g.projects_dir] = '$PROJECTS',
  }
  local result, env, prev_match = directory, '', ''
  for dir, alias in pairs(paths) do
    local match, count = fn.expand(directory):gsub(vim.pesc(path_sep(dir)), '')
    if count == 1 and #dir > #prev_match then
      result, env, prev_match = match, path_sep(alias), dir
    end
  end
  return result, env
end

--- @param ctx StatuslineContext
--- @return {env: string, dir: string, parent: string, fname: string}
local function filename(ctx)
  local buf, ft = ctx.bufnum, ctx.filetype
  local special_buf = special_buffers(ctx)
  if special_buf then return { fname = special_buf } end

  local path = api.nvim_buf_get_name(buf)
  if mines.falsy(path) then return { fname = 'No Name' } end
  --- add ":." to the expansion i.e. to make the directory path relative to the current vim directory
  local parts = vim.split(fn.fnamemodify(path, ':~'), sep)
  local fname = table.remove(parts)

  local name = identifiers.names[ft]
  if name then return { fname = vim.is_callable(name) and name(fname, buf) or name } end

  local parent = table.remove(parts)
  fname = fn.isdirectory(fname) == 1 and fname .. sep or fname
  if mines.falsy(parent) then return { fname = fname } end

  local dir = path_sep(table.concat(parts, sep))
  if api.nvim_strwidth(dir) > math.floor(vim.o.columns / 3) then dir = fn.pathshorten(dir) end

  local new_dir, env = dir_env(dir)
  return { env = env, dir = new_dir, parent = path_sep(parent), fname = fname }
end

---@alias FilenamePart {item: string, hl: string, opts: ComponentOpts}
---Create the various segments of the current filename
---@param ctx StatuslineContext
---@param minimal boolean
---@return {file: FilenamePart, parent: FilenamePart, dir: FilenamePart, env: FilenamePart}
local function stl_file(ctx, minimal)
  -- highlight the filename components separately
  local filename_hl = 'StFilename'
  local directory_hl = 'StDirectory'
  local parent_hl = 'StParentDirectory'
  local env_hl = 'StEnv'

  local file_opts = { before = '', after = ' ', priority = 0 }
  local parent_opts = { before = '', after = '', priority = 2 }
  local dir_opts = { before = '', after = '', priority = 3 }
  local env_opts = { before = '', after = '', priority = 4 }

  local p = filename(ctx)

  return {
    env = { item = p.env, hl = env_hl, opts = env_opts },
    file = { item = p.fname, hl = filename_hl, opts = file_opts },
    dir = { item = p.dir, hl = directory_hl, opts = dir_opts },
    parent = { item = p.parent, hl = parent_hl, opts = parent_opts },
  }
end

local EnvComponent = {
  provider = function(self) return self.env.item end,
  hl = function(self) return self.env.hl end,
}
local DirComponent = {
  provider = function(self) return self.dir.item end,
  hl = function(self) return self.dir.hl end,
}
local ParentComponent = {
  provider = function(self) return self.parent.item end,
  hl = function(self) return self.parent.hl end,
}
local FileComponent = {
  provider = function(self) return self.file.item end,
  hl = function(self) return self.file.hl end,
}

return {
  init = function(self)
    local segments = stl_file(self.ctx, false)
    self.env = segments.env
    self.dir = segments.dir
    self.parent = segments.parent
    self.file = segments.file
  end,
  {
    EnvComponent,
    DirComponent,
    ParentComponent,
    FileComponent,
  },
  { provider = '%<' },
}
