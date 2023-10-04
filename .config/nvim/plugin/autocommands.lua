local fn, api, v, env, cmd, fmt = vim.fn, vim.api, vim.v, vim.env, vim.cmd, string.format
local augroup, falsy = mines.augroup, mines.falsy

----------------------------------------------------------------------------------------------------
-- SmartClose
----------------------------------------------------------------------------------------------------
local smart_close_filetypes = mines.p_table {
  ['qf'] = true,
  ['log'] = true,
  ['help'] = true,
  ['query'] = true,
  ['dbui'] = true,
  ['lspinfo'] = true,
  ['git.*'] = true,
  ['Neogit.*'] = true,
  ['neotest.*'] = true,
  ['tsplayground'] = true,
  ['startuptime'] = true,
}

local smart_close_buftypes = mines.p_table {
  ['nofile'] = true,
}

local function smart_close()
  if fn.winnr '$' ~= 1 then api.nvim_win_close(0, true) end
end

augroup(
  'SmartClose',
  -- Auto open grep quickfix window
  { event = 'QuickFixCmdPost', pattern = '*grep*', command = 'cwindow' },

  -- Close certain filetypes by pressing q.
  {
    event = 'FileType',
    command = function(args)
      local is_unmapped = fn.hasmapto('q', 'n') == 0
      local buf = vim.bo[args.buf]
      local is_eligible = is_unmapped
        or vim.wo.previewwindow
        or smart_close_filetypes[buf.ft]
        or smart_close_buftypes[buf.bt]
      if is_eligible then map('n', 'q', smart_close, { buffer = args.buf, nowait = true }) end
    end,
  },

  -- Close quick fix window if the file containing it was closed
  {
    event = 'BufEnter',
    command = function()
      if fn.winnr '$' == 1 and vim.bo.buftype == 'quickfix' then api.nvim_buf_delete(0, { force = true }) end
    end,
  },

  -- automatically close corresponding loclist when quitting a window
  {
    event = 'QuitPre',
    nested = true,
    command = function()
      if vim.bo.filetype ~= 'qf' then cmd.lclose { mods = { silent = true } } end
    end,
  }
)

augroup('ExternalCommands', {
  -- Open images in an image viewer (probably Preview)
  event = 'BufEnter',
  pattern = { '*.png', '*.jpg', '*.gif' },
  command = function() cmd(fmt('silent! "%s | :bw"', vim.g.open_command .. ' ' .. fn.expand '%')) end,
})

augroup('CheckOutsideTime', {
  -- automatically check for changed files outside vim
  event = { 'WinEnter', 'BufWinEnter', 'BufWinLeave', 'BufRead', 'BufEnter', 'FocusGained' },
  command = 'silent! checktime',
})

augroup('TextYankHighlight', {
  -- don't execute silently in case of errors
  event = 'TextYankPost',
  command = function() vim.highlight.on_yank { timeout = 300, on_visual = false, higroup = 'Visual' } end,
})

augroup('UpdateVim', { event = 'FocusLost', command = 'silent! wall' }, { event = 'VimResized', command = 'wincmd =' })

augroup(
  'WindowBehaviours',
  -- map q to close command window on quit
  { event = 'CmdwinEnter', command = 'nnoremap <silent><buffer><nowait> q <C-W>c' },
  {
    event = 'BufWinEnter',
    command = function(args)
      if vim.wo.diff then vim.diagnostic.disable(args.buf) end
    end,
  },
  {
    event = 'BufWinLeave',
    command = function(args)
      if vim.wo.diff then vim.diagnostic.enable(args.buf) end
    end,
  }
)

----------------------------------------------------------------------------------------------------
-- Cursorline
----------------------------------------------------------------------------------------------------
-- Show cursor line only in active window
local cursorline_exclude = { 'starter', 'toggleterm', 'neoterm' }

---@param buf number
---@return boolean
local function should_show_cursorline(buf)
  return vim.bo[buf].buftype ~= 'terminal'
    and not vim.wo.previewwindow
    and vim.wo.winhighlight == ''
    and vim.bo[buf].filetype ~= ''
    and not vim.tbl_contains(cursorline_exclude, vim.bo[buf].filetype)
end

augroup('Cursorline', {
  event = { 'InsertLeave', 'BufEnter' },
  command = function(args)
    if api.nvim_buf_get_option(0, 'buftype') == '' then vim.wo.cursorline = should_show_cursorline(args.buf) end
  end,
}, {
  event = { 'InsertEnter', 'BufLeave' },
  command = function()
    if api.nvim_buf_get_option(0, 'buftype') == '' then vim.wo.cursorline = false end
  end,
})

local save_excluded = {
  'neo-tree',
  'neo-tree-popup',
  'lua.luapad',
  'gitcommit',
  'NeogitCommitMessage',
}

local function can_save()
  return falsy(fn.win_gettype())
    and falsy(vim.bo.buftype)
    and not falsy(vim.bo.filetype)
    and vim.bo.modifiable
    and not vim.tbl_contains(save_excluded, vim.bo.filetype)
end

augroup(
  'Utilities',
  {
    ---@source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
    event = { 'BufReadCmd' },
    pattern = { 'file:///*' },
    nested = true,
    command = function(args)
      cmd.bdelete { bang = true }
      cmd.edit(vim.uri_to_fname(args.file))
    end,
  },
  {
    -- always add a guard clause when creating plugin files
    event = 'BufNewFile',
    pattern = { vim.g.vim_dir .. '/plugin/**.lua' },
    command = 'norm! iif not mines then return end',
  },
  {
    --- disable formatting in directories in third party repositories
    event = { 'BufEnter' },
    command = function(args)
      local paths = vim.split(vim.o.runtimepath, ',')
      local match = vim.iter(paths):find(function(dir)
        local path = api.nvim_buf_get_name(args.buf)
        if vim.startswith(path, env.PERSONAL_PROJECTS_DIR) then return false end
        if vim.startswith(path, env.VIMRUNTIME) then return true end
        return vim.startswith(path, dir)
      end)
      vim.b[args.buf].formatting_disabled = match ~= nil
    end,
  },
  {
    event = { 'BufLeave' },
    pattern = { '*' },
    command = function()
      if can_save() then cmd 'silent! write ++p' end
    end,
  },
  {
    event = { 'BufWritePost' },
    pattern = { '*' },
    nested = true,
    command = function()
      if falsy(vim.bo.filetype) or fn.exists 'b:ftdetect' == 1 then
        cmd [[
        unlet! b:ftdetect
        filetype detect
        call v:lua.vim.notify('Filetype set to ' . &ft, "info", {})
      ]]
      end
    end,
  },
  -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
  {
    event = 'FileType',
    desc = 'set typescript and friends filetype options',
    pattern = { 'typescript', 'typescriptreact' },
    command = function()
      vim.opt_local.textwidth = 100
      if pcall(require, 'typescript') then
        map('n', 'gd', 'TypescriptGoToSourceDefinition', {
          desc = 'typescript: go to source definition',
        })
      end
    end,
  }
)

augroup('DisableSwapUndoBackupInTemp', {
  event = { 'BufNewFile', 'BufReadPre' },
  pattern = {
    '/tmp/*',
    '$TMPDIR/*',
    '$TMP/*',
    '$TEMP/*',
    '*/shm/*',
    '/private/var/*',
    '.vault.vim',
  },
  command = function()
    vim.opt_local.undofile = false
    vim.opt_local.swapfile = false
    vim.opt_global.backup = false
    vim.opt_global.writebackup = false
  end,
})

augroup('TerminalAutocommands', {
  event = { 'TermClose' },
  command = function(args)
    --- automatically close a terminal if the job was successful
    if falsy(v.event.status) and falsy(vim.bo[args.buf].ft) then cmd.bdelete { args.buf, bang = true } end
  end,
})



