---@diagnostic disable: undefined-global

local util = require 'plugins.snippets.utils'
local return_value = util.return_value

local function notes(note)
  note = note:upper()
  if note:sub(#note, #note) ~= ':' then note = note .. ': ' end
  return require('plugins.snippets.utils').get_comment(note)
end

local general_snips = {
  snippet('ret', return_value(true)),
  snippet('#!', {
    p(function()
      local ft = vim.opt_local.filetype:get()
      local executables = { python = 'python3' }
      return '#!/usr/bin/env ' .. (executables[ft] or ft)
    end),
  }),
  snippet(
    { trig = 'hr', name = 'Header' },
    fmt(
      [[
          {1}
          {2} {3}
          {1}
          {4}
      ]],
      {
        f(function()
          local comment = string.format(vim.bo.commentstring:gsub(' ', '') or '#%s', '-')
          local col = vim.bo.textwidth or 80
          return comment .. string.rep('-', col - #comment)
        end),
        f(function() return vim.bo.commentstring:gsub('%%s', '') end),
        i(1, 'HEADER'),
        i(0),
      }
    )
  ),
}

local annotations = {
  'note',
  'todo',
  'fix',
  'fixme',
  'warn',
  'bug',
  'improve',
}

for _, annotation in ipairs(annotations) do
  table.insert(general_snips, snippet(annotation, p(notes, annotation)))
end

return general_snips
