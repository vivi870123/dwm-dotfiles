local fn, api = vim.fn, vim.api

local util = require 'plugins.snippets.utils'
local saved_text = util.saved_text
local get_comment = util.get_comment
local surround_with_func = util.surround_with_func

local function import_suffix(import_name)
  local parts = vim.split(import_name[1][1], '.', true)
  return parts[#parts] or ''
end

local function rec_val()
  return sn(nil, {
    c(1, {
      t { '' },
      sn(nil, {
        t { '', '\t' },
        i(1, 'arg'),
        t { ' = { ' },
        r(1),
        t { ', ' },
        c(2, {
          i(1, "'string'"),
          i(1, "'table'"),
          i(1, "'function'"),
          i(1, "'number'"),
          i(1, "'boolean'"),
        }),
        c(3, {
          t { '' },
          t { ', true' },
        }),
        t { ' },' },
        d(4, rec_val, {}),
      }),
    }),
  })
end

-- stylua: ignore
---@diagnostic disable: undefined-global
return {
  snippet(
    {
      trig = 'cfg',
      name = 'config key',
      dscr = 'package manager config key',
    },
    fmt(
      [[
    , config = function()
      require("{}").setup()
    end
    ]],
      { i(1) }
    )
  ),
  snippet(
    {
      trig = 'vs',
      name = 'vim schedule',
      dscr = 'Schedule a function on the vim event loop',
    },
    fmt(
      [[
        vim.schedule(function()
          {}
        end)
      ]],
      { i(1) }
    )
  ),
  snippet(
    {
      trig = 'req',
      name = 'require module',
      dscr = 'Require a module and set the import to the last word',
    },
    fmt([[local {} = require("{}")]], {
      f(import_suffix, { 1 }),
      i(1),
    })
  ),
  snippet(
    {
      trig = 'reql',
      name = 'local require module',
      dscr = 'Require a module and set the import to the last word',
    },
    fmt([[local {} = require("{}")]], {
      f(import_suffix, { 1 }),
      i(1),
    })
  ),
  snippet(
    {
      trig = 'lreq',
      name = 'lazy require module',
      dscr = 'Lazy require a module and set the import to the last word',
    },
    fmt(
      [[
    local {1} = lazy.require("{2}") ---@module "{3}"
    ]],
      {
        f(import_suffix, { 1 }),
        i(1),
        rep(1),
      }
    )
  ),
  snippet(
    {
      trig = 'plg',
      name = 'plugin spec',
      dscr = {
        'plugin spec block',
        'e.g.',
        "{'author/plugin'}",
      },
    },
    fmt([[{{"{}"{}}}]], {
      d(1, function()
        -- Get the author and URL in the clipboard and auto populate the author and project
        local default = snippet('', { i(1, 'author'), t '/', i(2, 'plugin') })
        local clip = fn.getreg '*'
        if not vim.startswith(clip, 'https://github.com/') then return default end
        local parts = vim.split(clip, '/')
        if #parts < 2 then return default end
        local author, project = parts[#parts - 1], parts[#parts]
        return snippet('', { t(author .. '/' .. project) })
      end),
      c(2, {
        fmt(
          [[
              , config = function()
                require("{}").setup()
              end
          ]],
          { i(1, 'module') }
        ),
        t '',
      }),
    })
  ),
  snippet('ign', { t { '-- stylua: ignore' } }),
  snippet('sty', { t { '-- stylua: ignore' } }),
  snippet(
    {
      trig = 'map',
      name = 'vim.keymap.set',
      dscr = 'map a binding',
    },
    fmt("map('{}', '{}', {}, {})", {
      i(1, 'n'),
      i(2, 'lhs'),
      i(3, 'rhs'),
      i(4, 'opts'),
    })
  ),
  snippet("val", {
    t({"vim.validate {"}),
    t{'', "\t"}, i(1, 'arg'), t{" = { "}, rep(1), t{", "},
    c(2, {
      i(1, "'string'"),
      i(1, "'table'"),
      i(1, "'function'"),
      i(1, "'number'"),
      i(1, "'boolean'"),
    }),
    c(3, {
      t{""},
      t{", true"},
    }),
    t({" }"}),
    d(4, rec_val, {}),
    t({'', "}"}),
  }),
  snippet('com', fmt([[ mines.command({}, {}, {}) ]], { i(1, 'name'), i(2, 'cmd'), i(3, 'opts'), })),
  snippet('au', fmt([[
  mines.augroup({}, {{
    event = '{}',
    pattern = '{}',
    command = {}
  }})
  ]], {
    i(1, 'AuGroup'),
    i(2, 'event'),
    i(3, 'pattern'),
    i(0),
  })),
  snippet('lext', fmt([[vim.list_extend({}, {})]],{
    d(1, surround_with_func, {}, {user_args = {{text = 'tbl'}}}),
    i(2, "'node'"),
  })),
  snippet('text', fmt([[vim.tbl_extend('{}', {}, {})]],{
    c(1, { t{'force'}, t{'keep'}, t{'error'}, }),
    d(2, surround_with_func, {}, {user_args = {{text = 'tbl'}}}),
    i(3, "'node'"),
  })),
  snippet('not', fmt([[vim.notify("{}", "{}"{})]],{
    d(1, surround_with_func, {}, {user_args = {{text = 'msg'}}}),
    c(2, { t{'INFO'}, t{'WARN'}, t{'ERROR'}, t{'DEBUG'} }),
    c(3, { t{''}, sn(nil, { t{', { title = '}, i(1, "'title'"), t{' }'} }), }),
  })),
  snippet('cfg', fmt( [[ config = function() require("{}").setup() end ]], { i(1) })),
}
-- {
--   s(
--     {
--       trig = 'if',
--       condition = function()
--         local ignored_nodes = { 'string', 'comment' }
--         local pos = api.nvim_win_get_cursor(0)
--         local row, col = pos[1] - 1, pos[2] - 1
--         local node_type = vim.treesitter.get_node({ pos = { row, col } }):type()
--         return not vim.tbl_contains(ignored_nodes, node_type)
--       end,
--     },
--     fmt(
--       [[
--         if {} then
--           {}
--         end
--       ]],
--       { i(1), i(2) }
--     )
--   ),
-- }
