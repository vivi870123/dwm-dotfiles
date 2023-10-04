if vim.g.vscode then return end -- if someone has forced me to use vscode don't load my config

local g, fn, opt, loop, env, cmd = vim.g, vim.fn, vim.opt, vim.loop, vim.env, vim.cmd
local data = fn.stdpath 'data'

if vim.loader then vim.loader.enable() end

g.os = loop.os_uname().sysname
g.open_command = 'xdg-open'
g.dotfiles = env.DOTFILES or fn.expand '~/.dotfiles'
g.vim_dir = g.dotfiles .. '/.config/nvim'
g.projects_dir = env.PROJECTS_DIR or fn.expand '~/projects'
g.data_dir = data
g.cache_dir = fn.stdpath 'cache'
g.vim_runtime = '~/.asdf/installs/neovim/nightly/share/nvim/runtime'
g.db_root = function()
  local root = data .. '/databases'
  if vim.fn.isdirectory(root) ~= 1 then vim.fn.mkdir(root, 'p') end
  return root
end

g.tmp_dir = function(filename) return '/tmp/' .. filename end

----------------------------------------------------------------------------------------------------
-- Leader bindings
----------------------------------------------------------------------------------------------------
g.mapleader = ' '      -- leader key
g.maplocalleader = ';' -- local leader

----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------

local namespace = {
  ui = {
    winbar = { enable = false },
    statuscolumn = { enable = true },
    statusline = { enable = true },
  },

  -- this table is place to store lua functions to be called in those mappings
  mappings = { enable = true },
}

_G.mines = mines or namespace
_G.map = vim.keymap.set
_G.P = vim.print

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
-- Order matters here as globals needs to be instantiated first etc.
require 'globals'
require 'highlights'
require 'ui'

------------------------------------------------------------------------------------------------------
-- Plugins
------------------------------------------------------------------------------------------------------
local lazypath = data .. '/lazy/lazy.nvim'
if not loop.fs_stat(lazypath) then
  fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  vim.notify 'Installed lazy.nvim'
end
opt.runtimepath:prepend(lazypath)

----------------------------------------------------------------------------------------------------
--  $NVIM
----------------------------------------------------------------------------------------------------
-- NOTE: this must happen after the lazy path is setup

-- If opening from inside neovim terminal then do not load other plugins
if env.NVIM then return require('lazy').setup { { 'willothy/flatten.nvim', config = true } } end
------------------------------------------------------------------------------------------------------

require('lazy').setup('plugins', {
  ui = { border = mines.ui.current.border },
  defaults = { lazy = true },
  change_detection = { notify = false },
  checker = {
    enabled = true,
    concurrency = 30,
    notify = false,
    frequency = 3600, -- check for updates every hour
  },
  performance = {
    rtp = {
      paths = { data .. '/site' },
      disabled_plugins = { 'netrw', 'netrwPlugin' },
    },
  },
})

map('n', '<leader>pm', '<Cmd>Lazy<CR>', { desc = 'manage' })

------------------------------------------------------------------------------------------------------
-- Builtin Packages
------------------------------------------------------------------------------------------------------
-- cfilter plugin allows filtering down an existing quickfix list
cmd.packadd 'cfilter'
