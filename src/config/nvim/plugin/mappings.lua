local fn, api, uv, cmd, fmt = vim.fn, vim.api, vim.loop, vim.cmd, string.format
local augroup, command = mines.augroup, mines.command
local map = vim.keymap.set

local recursive_map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.remap = true
  map(mode, lhs, rhs, opts)
end

local nmap = function(...) recursive_map('n', ...) end
local imap = function(...) recursive_map('i', ...) end
local nnoremap = function(...) map('n', ...) end
local xnoremap = function(...) map('x', ...) end
local vnoremap = function(...) map('v', ...) end
local inoremap = function(...) map('i', ...) end
local onoremap = function(...) map('o', ...) end
local cnoremap = function(...) map('c', ...) end
local tnoremap = function(...) map('t', ...) end

-----------------------------------------------------------------------------
-- Arrows
-----------------------------------------------------------------------------
nnoremap('<down>', '<nop>')
nnoremap('<up>', '<nop>')
nnoremap('<left>', '<nop>')
nnoremap('<right>', '<nop>')
inoremap('<up>', '<nop>')
inoremap('<down>', '<nop>')
inoremap('<left>', '<nop>')
inoremap('<right>', '<nop>')

-- Repeat last substitute with flags
nnoremap('&', '<cmd>&&<CR>')

-----------------------------------------------------------------------------
-- Terminal
------------------------------------------------------------------------------
augroup('AddTerminalMappings', {
  event = { 'TermOpen' },
  pattern = { 'term://*' },
  command = function()
    if vim.bo.filetype == '' or vim.bo.filetype == 'toggleterm' then
      local opts = { silent = false, buffer = 0 }
      -- tnoremap('<esc>', [[<C-\><C-n>]], opts)
      tnoremap('<C-h>', '<Cmd>wincmd h<CR>', opts)
      tnoremap('<C-j>', '<Cmd>wincmd j<CR>', opts)
      tnoremap('<C-k>', '<Cmd>wincmd k<CR>', opts)
      tnoremap('<C-l>', '<Cmd>wincmd l<CR>', opts)
      tnoremap(']t', '<Cmd>tablast<CR>')
      tnoremap('[t', '<Cmd>tabnext<CR>')
      tnoremap('<S-Tab>', '<Cmd>bprev<CR>')
      tnoremap('<leader><Tab>', '<Cmd>close \\| :bnext<cr>')
    end
  end,
})

-----------------------------------------------------------------------------
-- MACROS
-----------------------------------------------------------------------------
-- Absolutely fantastic function from stoeffel/.dotfiles which allows you to
-- repeat macros across a visual range
------------------------------------------------------------------------------
-- TODO: converting this to lua does not work for some obscure reason.
vim.cmd [[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]]

xnoremap('@', ':<C-u>call ExecuteMacroOverVisualRange()<CR>', { silent = false })
vnoremap('.', ':norm.<cr>') -- make . work with visually selected lines

-- Enter key should repeat the last macro recorded or just act as enter
nnoremap('<leader><CR>', [[empty(&buftype) ? '@@' : '<CR>']], { expr = true })

-- TODO: check if mini.bracket subbots il
------------------------------------------------------------------------------
-- Credit: JGunn Choi ?il | inner line
------------------------------------------------------------------------------
-- includes newline
xnoremap('al', '$o0')
onoremap('al', '<cmd>normal val<CR>')
--No Spaces or CR
xnoremap('il', [[<Esc>^vg_]])
onoremap('il', [[<cmd>normal! ^vg_<CR>]])

-- Paste in visual mode multiple times
xnoremap('p', 'pgvy')
-- search visual selection
vnoremap('//', [[y/<C-R>"<CR>]])

-----------------------------------------------------------------------------
-- Folds Related
-----------------------------------------------------------------------------
-- Evaluates whether there is a fold on the current line if so unfold it else return a normal space
nnoremap('<space><space>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]])
nnoremap('<cr>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]])
-- Refocus folds
nnoremap('<localleader><space>', [[zMzvzz]])
-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap('zO', [[zCzO]])

------------------------------------------------------------------------------
-- Buffers
------------------------------------------------------------------------------
nnoremap('<leader>on', [[<cmd>w <bar> %bd <bar> e#<CR>]], { desc = 'close all other buffers' })
nnoremap('<localleader><tab>', [[:b <Tab>]], { silent = false, desc = 'open buffer list' })
nnoremap('<leader><leader>', [[<c-^>]], { desc = 'switch to last buffer' })

----------------------------------------------------------------------------------
-- Windows
----------------------------------------------------------------------------------
nnoremap('<localleader>wh', '<C-W>t <C-W>K', { desc = 'change two horizontally split windows to vertical splits' })
nnoremap('<localleader>wv', '<C-W>t <C-W>H', { desc = 'change two vertically split windows to horizontal splits' })
-- equivalent to gf but opens the window in a vertical split
-- vim doesn't have a native mapping for this as <C-w>f normally
-- opens a horizontal split
nnoremap('<C-w>f', '<C-w>vgf', { desc = 'open file in vertical split' })

-- Start an external command with a single bang
map('n', '!', ':!', { nowait = true })

----------------------------------------------------------------------------------
-- Quick find/replace
----------------------------------------------------------------------------------
nnoremap('<leader>[', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], {
  silent = false,
  desc = 'replace word under the cursor(file)',
})
nnoremap('<leader>]', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], {
  silent = false,
  desc = 'replace word under the cursor (line)',
})
vnoremap('<leader>[', [["zy:%s/<C-r><C-o>"/]], {
  silent = false,
  desc = 'replace word under the cursor (visual)',
})

-- Visual shifting (does not exit Visual mode)
vnoremap('<', '<gv')
vnoremap('>', '>gv')

--Remap back tick for jumping to marks more quickly back
nnoremap("'", '`')

----------------------------------------------------------------------------------
-- Commandline mappings
----------------------------------------------------------------------------------
-- https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
-- c-a / c-e everywhere - RSI.vim provides these
cnoremap('<m-n>', '<Down>')
cnoremap('<m-p>', '<Up>')

-- <C-A> allows you to insert all matches on the command line e.g. bd *.js <c-a>
-- will insert all matching files e.g. :bd a.js b.js c.js
cnoremap('<c-x><c-a>', '<c-a>')
cnoremap('<C-f>', '<Right>')
cnoremap('<C-b>', '<Left>')
cnoremap('<C-d>', '<Del>')
-- see :h cmdline-editing
cnoremap('<Esc>b', [[<S-Left>]])
cnoremap('<Esc>f', [[<S-Right>]])

cmd.cabbrev('options', 'vert options')

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
local function search(direction_key, default)
  local c_type = fn.getcmdtype()
  return (c_type == '/' or c_type == '?') and fmt('<CR>%s<C-r>/', direction_key) or default
end
cnoremap('<Tab>', function() return search('/', '<Tab>') end, { expr = true })
cnoremap('<S-Tab>', function() return search('?', '<S-Tab>') end, { expr = true })
-- insert path of current file into a command
cnoremap('%%', "<C-r>=fnameescape(expand('%'))<cr>")
cnoremap('::', "<C-r>=fnameescape(expand('%:p:h'))<cr>/")

----------------------------------------------------------------------------------
-- Save
----------------------------------------------------------------------------------
-- NOTE: this uses write specifically because we need to trigger a filesystem event
-- even if the file isn't changed so that things like hot reload work
-- nnoremap('<c-s>', '<Cmd>silent! write ++p<CR>')
inoremap('<c-s>', '<Cmd>silent! write ++p<CR><ESC>')
-- Write and quit all files, ZZ is NOT equivalent to this
nnoremap('qa', '<cmd>qa<CR>')

----------------------------------------------------------------------------------
-- Quickfix
----------------------------------------------------------------------------------
nnoremap(']q', '<cmd>cnext<CR>zz')
nnoremap('[q', '<cmd>cprev<CR>zz')
nnoremap(']l', '<cmd>lnext<cr>zz')
nnoremap('[l', '<cmd>lprev<cr>zz')

----------------------------------------------------------------------------------
-- Operators
----------------------------------------------------------------------------------
-- Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap('Y', 'y$')

----------------------------------------------------------------------------------
-- Core navigation
----------------------------------------------------------------------------------
-- Store relative line number jumps in the jumplist.
nnoremap('j', [[(v:count > 1 ? 'm`' . v:count : '') . 'gj']], { expr = true, silent = true })
nnoremap('k', [[(v:count > 1 ? 'm`' . v:count : '') . 'gk']], { expr = true, silent = true })
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap('0', "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })
-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap('$', 'g_')
-- jk is escape, THEN move to the right to preserve the cursor position, unless
-- at the first column.  <esc> will continue to work the default way.
-- NOTE: this is a recursive mapping so anything bound (by a plugin) to <esc> still works
imap('jk', [[col('.') == 1 ? '<esc>' : '<esc>l']], { expr = true })
-- Toggle top/center/bottom
nmap('zz', [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']], { expr = true })

----------------------------------------------------------------------------------
-- Open Common files
----------------------------------------------------------------------------------
nnoremap('<leader>ev', [[<Cmd>edit $MYVIMRC<CR>]], { desc = 'open $VIMRC' })
nnoremap('<leader>ez', '<Cmd>edit $ZDOTDIR/.zshrc<CR>', { desc = 'open zshrc' })
nnoremap('<leader>et', '<Cmd>edit $XDG_CONFIG_HOME/tmux/tmux.conf<CR>', { desc = 'open tmux.conf' })
nnoremap('<leader>ep', fmt('<Cmd>edit %s/lua/plugins/init.lua<CR>', fn.stdpath 'config'), {
  desc = 'open plugins file',
})

----------------------------------------------------------------------------------
-- Quotes
----------------------------------------------------------------------------------
nnoremap([[<leader>"]], [[ciw"<c-r>""<esc>]], { desc = 'surround with double quotes' })
nnoremap('<leader>`', [[ciw`<c-r>"`<esc>]], { desc = 'surround with backticks' })
nnoremap("<leader>'", [[ciw'<c-r>"'<esc>]], { desc = 'surround with single quotes' })
nnoremap('<leader>)', [[ciw(<c-r>")<esc>]], { desc = 'surround with parentheses' })
nnoremap('<leader>}', [[ciw{<c-r>"}<esc>]], { desc = 'surround with curly braces' })

----------------------------------------------------------------------------------
-- Grep Operator
----------------------------------------------------------------------------------
-- http://travisjeffery.com/b/2011/10/m-x-occur-for-vim/

---@param type string
---@return nil
function mines.mappings.grep_operator(type)
  local saved_unnamed_register = fn.getreg '@@'
  if type:match 'v' then
    vim.cmd [[normal! `<v`>y]]
  elseif type:match 'char' then
    vim.cmd [[normal! `[v`]y']]
  else
    return
  end
  -- Store the current window so if it changes we can restore it
  local win = api.nvim_get_current_win()
  vim.cmd.grep { fn.shellescape(fn.getreg '@@') .. ' .', bang = true, mods = { silent = true } }
  fn.setreg('@@', saved_unnamed_register)
  if api.nvim_get_current_win() ~= win then vim.cmd.wincmd 'J' end
end

nnoremap('gs', function()
  vim.o.operatorfunc = 'v:lua.mines.mappings.grep_operator'
  return 'g@'
end, { expr = true, desc = 'grep operator' })
xnoremap('gs', ':call v:lua.mines.mappings.grep_operator(visualmode())<CR>')

-------------------------------------- GX ----------------------------------------
-- replicate netrw functionality
----------------------------------------------------------------------------------
local function open(path)
  vim.fn.jobstart({ vim.g.open_comand, path }, { detach = true })
  vim.notify(string.format('Opening %s', path))
end

nnoremap('gx', function()
  local file = fn.expand '<cfile>'
  if not file or fn.isdirectory(file) > 0 then return vim.cmd.edit(file) end

  if file:match 'http[s]?://' then return open(file) end

  -- consider anything that looks like string/string a github link
  local link = file:match '[%a%d%-%.%_]*%/[%a%d%-%.%_]*'
  if link then return open(fmt('https://www.github.com/%s', link)) end
end)

nnoremap('gf', '<Cmd>e <cfile><CR>', { desc = 'goto file' })

----------------------------------------------------------------------------------
nnoremap('<leader>ls', mines.list.qf.toggle, { desc = 'toggle quickfix list' })
nnoremap('<leader>ll', mines.list.loc.toggle, { desc = 'toggle location list' })
nnoremap('=q', mines.list.qf.toggle, { desc = 'toggle quickfix list' })
nnoremap('=l', mines.list.loc.toggle, { desc = 'toggle location list' })

-----------------------------------------------------------------------------//
-- Completion
-----------------------------------------------------------------------------//
-- cycle the completion menu with <TAB>
inoremap('<tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
inoremap('<s-tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

-- ----------------------------------------------------------------------------------
-- -- Delimiters
-- ----------------------------------------------------------------------------------
-- -- TLDR: Conditionally modify character at end of line
--
-- -- Description:
-- -- This function takes a delimiter character and:
-- --   * removes that character from the end of the line if the character at the end
-- --     of the line is that character
-- --   * removes the character at the end of the line if that character is a
-- --     delimiter that is not the input character and appends that character to
-- --     the end of the line
-- --   * adds that character to the end of the line if the line does not end with
-- --     a delimiter
-- -- Delimiters:
-- -- - ","
-- -- - ";"
-- ---@param character string
-- ---@return function
-- local function modify_line_end_delimiter(character)
--   local delimiters = { ',', ';' }
--   return function()
--     local line = api.nvim_get_current_line()
--     local last_char = line:sub(-1)
--     if last_char == character then
--       api.nvim_set_current_line(line:sub(1, #line - 1))
--     elseif vim.tbl_contains(delimiters, last_char) then
--       api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
--     else
--       api.nvim_set_current_line(line .. character)
--     end
--   end
-- end
--
-- nnoremap('<localleader>,', modify_line_end_delimiter ',', { desc = "add ',' to end of line" })
-- nnoremap('<localleader>;', modify_line_end_delimiter ';', { desc = "add ';' to end of line" })

-- command('TodoDots', ('TodoQuickFix cwd=%s keywords=TODO,FIXME'):format(vim.g.vim_dir))
