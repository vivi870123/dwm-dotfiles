local util = require 'plugins.snippets.utils'
local saved_text = util.saved_text
local else_clause = util.else_clause

-- stylua: ignore
return {
  snippet(
      { trig = 'if(e?)', regTrig = true },
      fmt([=[
      if [[ {} ]]; then
      {}
      {}fi
      ]=], {
          i(1, 'condition'),
          d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
          d(3, else_clause, {}, {}),
      })
  ),
  snippet('fun', fmt([[
  function {}() {{
  {}
  }}
  ]], {
      i(1, 'name'),
      d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
  })),
  snippet('for', fmt([[
  for {} in {}; do
  {}
  done
  ]], {
      i(1, 'i'),
      i(2, 'Iterator'),
      d(3, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
  })),
  snippet('fori', fmt([[
  for (({} = {}; {} < {}; {}++)); do
  {}
  done
  ]], {
      i(1, 'i'),
      i(2, '0'),
      r(1),
      i(3, '10'),
      r(1),
      d(4, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
  })),
  snippet('wh', fmt([=[
  while [[ {} ]]; do
  {}
  done
  ]=], {
      i(1, 'condition'),
      d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
  })),
  snippet('l', fmt([[local {}={}]],{
      i(1, 'varname'),
      i(2, '1'),
  })),
  snippet('ex', fmt([[export {}={}]],{
      i(1, 'varname'),
      i(2, '1'),
  })),
  snippet('ha', fmt([[hash {} 2>/dev/null ]],{
      i(1, 'cmd'),
  })),
  snippet('case', fmt([[
  case ${} in
      {})
          {}
          ;;
  esac
  ]],{
      i(1, 'VAR'),
      i(2, 'CONDITION'),
      i(3, ':'),
  })),
}
