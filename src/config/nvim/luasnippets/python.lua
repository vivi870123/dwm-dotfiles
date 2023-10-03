local util = require 'plugins.snippets.utils'
local saved_text = util.saved_text

local function python_class_init(args, snip, old_state, placeholder)
  local nodes = {}

  if snip.captures[1] == 'd' then
    table.insert(
      nodes,
      c(1, {
        t { '' },
        sn(nil, { t { '\t' }, i(1, 'attr') }),
      })
    )
  else
    table.insert(nodes, t { '', '\tdef __init__(self' })
    table.insert(
      nodes,
      c(1, {
        t { '' },
        sn(nil, { t { ', ' }, i(1, 'arg') }),
      })
    )
    table.insert(nodes, t { '):', '\t\t' })
    table.insert(nodes, i(2, 'pass'))
  end

  local snip_node = sn(nil, nodes)
  snip_node.old_state = old_state
  return snip_node
end

local function python_dataclass(args, snip, old_state, placeholder)
  local nodes = {}

  table.insert(nodes, snip.captures[1] == 'd' and t { '@dataclass', '' } or t { '' })

  local snip_node = sn(nil, nodes)
  snip_node.old_state = old_state
  return snip_node
end

-- stylua: ignore
return {
  snippet('for', fmt([[
  for {} in {}:
  {}
  ]], {
      i(1, 'i'),
      i(2, 'iterator'),
      d(3, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
  })),
  snippet('pr', fmt([[print({})]],{
      i(1, 'msg'),
  })),
  snippet('ran', fmt([[range({}, {})]],{
      i(1, '0'),
      i(2, '10'),
  })),
  snippet('imp', fmt([[import {}]],{
      i(1, 'sys'),
  })),
  snippet(
      { trig = 'fro(m?)', regTrig = true },
      fmt([[from {} import {}]],
      {
          i(1, 'sys'),
          i(2, 'path'),
      }
  )),
  snippet(
      { trig = 'if(e?)', regTrig = true },
      fmt([[
  if {}:
  {}{}
  ]], {
      i(1, 'condition'),
      d(2, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
      d(3, else_clause, {}, {}),
  })),
  snippet('def', fmt([[
  def {}({}{}):
  {}
  ]], {
      i(1, 'name'),
      p(function()
          -- stylua: ignore
          local get_current_class = require('utils.treesitter').get_current_class
          -- stylua: ignore
          local has_ts = require('utils.treesitter').has_ts()
          -- stylua: ignore
          if has_ts and get_current_class() then
              -- stylua: ignore
              return 'self, '
          end
          -- stylua: ignore
          return ''
      end),
      i(2, 'args'),
      d(3, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
  })),
  snippet('try', fmt([[
  try:
  {}
  except {}:
      {}
  ]], {
      d(1, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
      c(2, {
          t{'Exception as e'},
          t{'KeyboardInterrupt as e'},
          sn(nil, { i(1, 'Exception') }),
      }),
      i(3, 'pass'),
  })),
  snippet('ifmain', fmt([[
  if __name__ == "__main__":
      {}
  else:
      {}
  ]], {
      c(1, {
          sn(nil, { t{'exit('}, i(1, 'main()'), t{')'} }),
          t{'pass'},
      }),
      i(2, 'pass'),
  })),
  snippet('with', fmt([[
  with open('{}', {}) as {}:
  {}
  ]], {
      i(1, 'filename'),
      c(2, {
          i(1, '"r"'),
          i(1, '"a"'),
          i(1, '"w"'),
      }),
      i(3, 'data'),
      d(4, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
  })),
  snippet('w', fmt([[
  while {}:
  {}
  ]], {
      i(1, 'condition'),
      d(2, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
  })),
  snippet(
      { trig = "(d?)cl", regTrig = true },
      fmt([[
      {}class {}({}):
          {}
      ]],
      {
          d(1, python_dataclass, {}, {}),
          i(2, 'Class'),
          c(3, {
              t{''},
              i(1, 'object'),
          }),
          -- dl(4, l._1 .. ': docstring', { 2 }),
          d(4, python_class_init, {}, {}),
      }
  )),
  snippet('raise', fmt([[raise {}({})]],{
      c(1, {
          i(1, 'Exception'),
          i(1, 'KeyboardInterrupt'),
          i(1, 'IOException'),
      }),
      i(2, 'message'),
  })),
  snippet('clist', fmt('[{} for {} in {}{}]',{
      r(1),
      i(1, 'i'),
      i(2, 'Iterator'),
      c(3, {
          t{''},
          sn(nil, {t' if ', i(1, 'condition') }),
      }),
  })),
  snippet('cdict', fmt('{{ {}:{} for ({},{}) in {}{}}}',{
      r(1),
      r(2),
      i(1, 'k'),
      i(2, 'v'),
      i(3, 'Iterator'),
      c(4, {
          t{''},
          sn(nil, {t' if ', i(1, 'condition') }),
      }),
  })),
}
