local api, fmt = vim.api, string.format
local l, uv = vim.log.levels, vim.loop
local g, fn, opt, loop, env, cmd = vim.g, vim.fn, vim.opt, vim.loop, vim.env, vim.cmd

----------------------------------------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------------------------------------

--- Convert a list or map of items into a value by iterating all it's fields and transforming
--- them with a callback
---@generic T : table
---@param callback fun(T, T, key: string | number): T
---@param list T[]
---@param accum T?
---@return T
function mines.fold(callback, list, accum)
  accum = accum or {}
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'The accumulator must be returned on each iteration')
  end
  return accum
end

---@generic T : table
---@param callback fun(item: T, key: string | number, list: T[]): T
---@param list T[]
---@return T[]
function mines.map(callback, list)
  return mines.fold(function(accum, v, k)
    accum[#accum + 1] = callback(v, k, accum)
    return accum
  end, list, {})
end

---@generic T : table
---@param callback fun(T, key: string | number)
---@param list T[]
function mines.foreach(callback, list)
  for k, v in pairs(list) do
    callback(v, k)
  end
end

--- Check if the target matches  any item in the list.
---@param target string
---@param list string[]
---@return boolean
function mines.any(target, list)
  for _, item in ipairs(list) do
    if target:match(item) then return true end
  end
  return false
end

---Find an item in a list
---@generic T
---@param matcher fun(arg: T):boolean
---@param haystack T[]
---@return T
function mines.find(matcher, haystack)
  local found
  for _, needle in ipairs(haystack) do
    if matcher(needle) then
      found = needle
      break
    end
  end
  return found
end

--- Autosize quickfix to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param min_height number
---@param max_height number
function mines.adjust_split_height(min_height, max_height)
  api.nvim_win_set_height(0, math.max(math.min(fn.line '$', max_height), min_height))
end

---------------------------------------------------------------------------------
-- Quickfix and Location List
---------------------------------------------------------------------------------
mines.list = { qf = {}, loc = {} }

---@param list_type "loclist" | "quickfix"
---@return boolean
local function is_list_open(list_type)
  return vim.iter(fn.getwininfo()):find(function(win) return not mines.falsy(win[list_type]) end) ~= nil
end

local silence = { mods = { silent = true, emsg_silent = true } }

---@param callback fun(...)
local function preserve_window(callback, ...)
  local win = api.nvim_get_current_win()
  callback(...)
  if win ~= api.nvim_get_current_win() then cmd.wincmd 'J' end
end

function mines.list.qf.toggle()
  if is_list_open 'quickfix' then
    cmd.cclose(silence)
  elseif #fn.getqflist() > 0 then
    preserve_window(cmd.copen, silence)
  end
end

function mines.list.loc.toggle()
  if is_list_open 'loclist' then
    cmd.lclose(silence)
  elseif #fn.getloclist(0) > 0 then
    preserve_window(cmd.lopen, silence)
  end
end

-- @see: https://vi.stackexchange.com/a/21255
-- using range-aware function
function mines.list.qf.delete(buf)
  buf = buf or api.nvim_get_current_buf()
  local list = fn.getqflist()
  local line = api.nvim_win_get_cursor(0)[1]
  local mode = api.nvim_get_mode().mode
  if mode:match '[vV]' then
    local first_line = fn.getpos("'<")[2]
    local last_line = fn.getpos("'>")[2]
    list = vim.iter(ipairs(list)):filter(function(i) return i < first_line or i > last_line end)
  else
    table.remove(list, line)
  end
  -- replace items in the current list, do not make a new copy of it; this also preserves the list title
  fn.setqflist({}, 'r', { items = list })
  fn.setpos('.', { buf, line, 1, 0 }) -- restore current line
end

---------------------------------------------------------------------------------

---@param str string
---@param max_len integer
---@return string
function mines.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. mines.ui.icons.misc.ellipsis or str
end

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function mines.falsy(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'boolean' then return not item end
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

---Require a module using `pcall` and report any errors
---@param module string
---@param opts {silent: boolean, message: string}?
---@return boolean, any
function mines.require(module, opts)
  opts = opts or { silent = false }
  local ok, result = pcall(require, module)
  if not ok and not opts.silent then
    if opts.message then result = opts.message .. '\n' .. result end
    vim.notify(result, l.ERROR, { title = fmt('Error requiring: %s', module) })
  end
  return ok, result
end

--- Call the given function and use `vim.notify` to notify of any errors
--- this function is a wrapper around `xpcall` which allows having a single
--- error handler for all errors
---@param msg string
---@param func function
---@param ... any
---@return boolean, any
---@overload fun(func: function, ...): boolean, any
function mines.pcall(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    local arg = func --[[@mines any]]
    args, func, msg = { arg, unpack(args) }, msg, nil
  end
  return xpcall(func, function(err)
    msg = debug.traceback(msg and fmt('%s:\n%s\n%s', msg, vim.inspect(args), err) or err)
    vim.schedule(function() vim.notify(msg, l.ERROR, { title = 'ERROR' }) end)
  end, unpack(args))
end

local LATEST_NIGHTLY_MINOR = 9
function mines.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

----------------------------------------------------------------------------------------------------
--  FILETYPE HELPERS
----------------------------------------------------------------------------------------------------
---@class FiletypeSettings
---@field g table<string, any>
---@field bo vim.bo
---@field wo vim.wo
---@field opt vim.opt
---@field plugins {[string]: fun(module: table)}

---@param args {[1]: string, [2]: string, [3]: string, [string]: boolean | integer}[]
---@param buf integer
local function apply_ft_mappings(args, buf)
  vim.iter(ipairs(args)):each(function(_, m)
    assert(m[1] and m[2] and m[3], 'map args must be a table with at least 3 items')
    local opts = vim.iter(pairs(m)):fold({ buffer = buf }, function(acc, item, key)
      if type(key) == 'string' then acc[key] = item end
      return acc
    end)
    map(m[1], m[2], m[3], opts)
  end)
end

--- A convenience wrapper that calls the ftplugin config for a plugin if it exists
--- and warns me if the plugin is not installed
---@param configs table<string, fun(module: table)>
function mines.ftplugin_conf(configs)
  if type(configs) ~= 'table' then return end
  for name, callback in pairs(configs) do
    local ok, plugin = mines.pcall(require, name)
    if ok then callback(plugin) end
  end
end

--- This function is an alternative API to using ftplugin files. It allows defining
--- filetype settings in a single place, then creating FileType autocommands from this definition
---
--- e.g.
--- ```lua
---   mines.filetype_settings({
---     lua = {
---      opt = {foldmethod = 'expr' },
---      bo = { shiftwidth = 2 }
---     },
---    [{'c', 'cpp'}] = {
---      bo = { shiftwidth = 2 }
---    }
---   })
--- ```
--- One future idea is to generate the ftplugin files from this function, so the settings are still
--- centralized but the curation of these files is automated. Although I'm not sure this actually
--- has value over autocommands, unless ftplugin files specifically have that value
---
---@param map {[string|string[]]: FiletypeSettings | {[integer]: fun(args: AutocmdArgs)}}
function mines.filetype_settings(map)
  local commands = vim.iter(map):map(function(ft, settings)
    local name = type(ft) == 'table' and table.concat(ft, ',') or ft
    return {
      pattern = ft,
      event = 'FileType',
      desc = ('ft settings for %s'):format(name),
      command = function(args)
        vim.iter(settings):each(function(value, scope)
          if scope == 'opt' then scope = 'opt_local' end
          if scope == 'mappings' then return apply_ft_mappings(value, args.buf) end
          if scope == 'plugins' then return mines.ftplugin_conf(value) end
          local v = type(value)
          if v == 'function' then return value(args) end
          if v == 'table' then vim.iter(value):each(function(setting, option) vim[scope][option] = setting end) end
        end)
      end,
    }
  end)
  mines.augroup('filetype-settings', unpack(commands:totable()))
end

---Check if a cmd is executable
---@param e string
---@return boolean
function mines.executable(e) return fn.executable(e) > 0 end

----------------------------------------------------------------------------------------------------
-- File helpers
----------------------------------------------------------------------------------------------------
function mines.normalize(path)
  vim.validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')
  if path == '%' then
    -- TODO: Replace this with a fast API
    return vim.fn.expand(path)
  end
  return (path:gsub('^~', vim.loop.os_homedir()):gsub('%$([%w_]+)', vim.loop.os_getenv):gsub('\\', '/'))
end
function mines.exists(filename)
  vim.validate { filename = { filename, 'string' } }
  if filename == '' then return false end
  local stat = uv.fs_stat(mines.normalize(filename))
  return stat and stat.type or false
end

function mines.is_dir(filename) return mines.exists(filename) == 'directory' end

function mines.is_file(filename) return mines.exists(filename) == 'file' end

function mines.executable(exec)
  vim.validate { exec = { exec, 'string' } }
  assert(exec ~= '', debug.traceback 'Empty executable string')
  return vim.fn.executable(exec) == 1
end

function mines.exepath(exec)
  vim.validate { exec = { exec, 'string' } }
  assert(exec ~= '', debug.traceback 'Empty executable string')
  local path = vim.fn.exepath(exec)
  return path ~= '' and path or false
end

function mines.is_absolute(path)
  vim.validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')
  if path:sub(1, 1) == '~' then path = path:gsub('~', uv.os_homedir()) end

  return path:sub(1, 1) == '/'
end

function mines.is_root(path)
  vim.validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')
  return path == '/'
end

function mines.realpath(path)
  vim.validate { path = { path, 'string' } }
  assert(mines.exists(path), debug.traceback(([[Path "%s" doesn't exists]]):format(path)))
  return uv.fs_realpath(mines.normalize(path)):gsub('\\', '/')
end

function mines.basename(file)
  vim.validate { file = { file, 'string', true } }
  if file == nil then return nil end
  vim.validate { file = { file, 's' } }
  return file:match '[/\\]$' and '' or (file:match('[^\\/]*$'):gsub('\\', '/'))
end

function mines.extension(path)
  vim.validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')
  local extension = ''
  path = mines.normalize(path)
  if not mines.is_dir(path) then
    local filename = mines.basename(path)
    extension = filename:match '^.+(%..+)$' or ''
  end
  return #extension >= 2 and extension:sub(2, #extension) or extension
end

function mines.filename(path)
  vim.validate { path = { path, 'string' } }
  local name = vim.fs.basename(path)
  local extension = mines.extension(name)
  return extension ~= '' and name:gsub('%.' .. extension .. '$', '') or name
end

---comment
---@return boolean
function mines.has_sqlite()
  local sqlite_clib_path = vim.g.sqlite_clib_path
  if vim.fn.filereadable(vim.loop.os_homedir() .. '/.local/lib/libsqlite.so') then
    sqlite_clib_path = vim.loop.os_homedir() .. '/.local/lib/libsqlite.so'
  end
  return vim.fn.executable 'sqlite3'
end

---@param name string
function mines.plugin_opts(name)
  local plugin = require('lazy.core.config').plugins[name]
  if not plugin then return {} end
  local Plugin = require 'lazy.core.plugin'
  return Plugin.values(plugin, 'opts', false)
end

----------------------------------------------------------------------------------------------------
-- API Wrappers
----------------------------------------------------------------------------------------------------
-- Thin wrappers over API functions to make their usage easier/terser

local autocmd_keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
--- Validate the keys passed to mines.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = mines.fold(function(accum, _, key)
    if not vim.tbl_contains(autocmd_keys, key) then table.insert(accum, key) end
    return accum
  end, command, {})

  if #incorrect > 0 then
    vim.schedule(function()
      local msg = 'Incorrect keys: ' .. table.concat(incorrect, ', ')
      vim.notify(msg, 'error', { title = fmt('Autocmd: %s', name) })
    end)
  end
end

---@class AutocmdArgs
---@field id number autocmd ID
---@field event string
---@field group string?
---@field buf number
---@field file string
---@field match string | number
---@field data any

---@class Autocommand
---@field desc string
---@field event  string | string[] list of autocommand events
---@field pattern string | string[] list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean
---@field once    boolean
---@field buffer  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
function mines.augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(#commands > 0, fmt('You must specify at least one autocommand for %s', name))
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean,

---Create an nvim command
---@param name string
---@param rhs string | fun(args: CommandArgs)
---@param opts table?
function mines.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return string
function mines.replace_termcodes(str) return api.nvim_replace_termcodes(str, true, true, true) end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function mines.has(feature) return fn.has(feature) > 0 end

---@generic T
---Given a table return a new table which if the key is not found will search
---all the table's keys for a match using `string.match`
---@param map T
---@return T
function mines.p_table(map)
  return setmetatable(map, {
    __index = function(tbl, key)
      if not key then return end
      for k, v in pairs(tbl) do
        if key:match(k) then return v end
      end
    end,
  })
end


function mines.abbr(abbr)
  vim.validate { abbrevation = { abbr, 'table' } }
  if not abbr.mode or not abbr.lhs then
    vim.notify('Missing arguments!! set_abbr need a mode and a lhs attribbutes', 'ERROR', { title = 'Nvim Abbrs' })
    return false
  end

  local command = {}
  local extras = {}
  local modes = { insert = 'i', command = 'c', }

  local lhs, rhs = abbr.lhs, abbr.rhs
  local args = type(abbr.args) == 'table' and abbr.args or { abbr.args }
  local mode = modes[abbr.mode] or abbr.mode

  if args.buffer ~= nil then table.insert(extras, '<buffer>') end

  if args.expr ~= nil and rhs ~= nil then table.insert(extras, '<expr>') end

  for _, v in pairs(extras) do table.insert(command, v) end

  if mode == 'i' or mode == 'insert' then
    if rhs == nil then
      table.insert(command, 1, 'iunabbrev')
      table.insert(command, lhs)
    else
      table.insert(command, 1, 'iabbrev')
      table.insert(command, lhs)
      table.insert(command, rhs)
    end
  elseif mode == 'c' or mode == 'command' then
    if rhs == nil then
      table.insert(command, 1, 'cunabbrev')
      table.insert(command, lhs)
    else
      table.insert(command, 1, 'cabbrev')
      table.insert(command, lhs)
      table.insert(command, rhs)
    end
  else
    vim.notify('Unsupported mode: ' .. vim.inspect(mode), 'ERROR', { title = 'Nvim Abbrs' })
    return false
  end

  if args.silent ~= nil then
    table.insert(command, 1, 'silent!')
  end

  api.nvim_command(table.concat(command, ' '))
end

------------------------------------------------------------------------------------------------------------------------
--  Lazy Requires
------------------------------------------------------------------------------------------------------------------------
--- source: https://github.com/tjdevries/lazy-require.nvim

--- Require on index.
---
--- Will only require the module after the first index of a module.
--- Only works for modules that export a table.
function mines.reqidx(require_path)
  return setmetatable({}, {
    __index = function(_, key) return require(require_path)[key] end,
    __newindex = function(_, key, value) require(require_path)[key] = value end,
  })
end

--- Require when an exported method is called.
---
--- Creates a new function. Cannot be used to compare functions,
--- set new values, etc. Only useful for waiting to do the require until you actually
--- call the code.
---
--- ```lua
--- -- This is not loaded yet
--- local lazy_mod = lazy.require_on_exported_call('my_module')
--- local lazy_func = lazy_mod.exported_func
---
--- -- ... some time later
--- lazy_func(42)  -- <- Only loads the module now
---
--- ```
---@param require_path string
---@return table<string, fun(...): any>
function mines.reqcall(require_path)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...) return require(require_path)[k](...) end
    end,
  })
end
