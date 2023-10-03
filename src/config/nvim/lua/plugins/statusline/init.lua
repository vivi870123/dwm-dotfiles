local ui, highlight, lsp, falsy = mines.ui, mines.highlight
local P, icons, decorations = ui.palette, ui.icons, ui.decorations
local api, fn, fs, fmt, strwidth = vim.api, vim.fn, vim.fs, string.format, vim.api.nvim_strwidth

local hls = {
  statusline = 'StatusLine',
  statusline_nc = 'StatusLineNC',
  metadata = 'StMetadata',
  metadata_prefix = 'StMetadataPrefix',
  indicator = 'StIndicator',
  modified = 'StModified',
  git_branch = 'StGitBranch',
  git_added = 'StGitAdded',
  git_changed = 'StGitChanged',
  git_removed = 'StGitRemoved',
  git_dirty = 'StGitDirty',
  green = 'StGreen',
  blue = 'StBlue',
  number = 'StNumber',
  count = 'StCount',
  client = 'StClient',
  env = 'StEnv',
  directory = 'StDirectory',
  directory_inactive = 'StDirectoryInactive',
  parent_directory = 'StParentDirectory',
  title = 'StTitle',
  comment = 'StComment',
  info = 'StInfo',
  warn = 'StWarn',
  error = 'StError',
  hint = 'StHint',
  filename = 'StFilename',
  filename_inactive = 'StFilenameInactive',
  mode_normal = 'StModeNormal',
  mode_op = 'StModeOp',
  mode_insert = 'StModeInsert',
  mode_visual = 'StModeVisual',
  mode_visual_lines = 'StModeVisualLines',
  mode_visual_block = 'StModeVisualBlock',
  mode_replace = 'StModeReplace',
  mode_v_replace = 'StModeVReplace',
  mode_enter = 'StModeEnter',
  mode_more = 'StModeMore',
  mode_select = 'StModeSelect',
  mode_command = 'StModeCommand',
  mode_shell = 'StModeShell',
  mode_term = 'StModeTerm',
  mode_none = 'StModeNone',
  mode_block = 'StModeBlock',
  mode_confirm = 'StModeConfirm',
  search_result = 'StSearchResult',
  macro_recording = 'StMacroRecording',
  file_properties = 'StFileProperties',
  dap_messages = 'StDapMessages',
  lsp_indicator = 'StLspIndicator',
  lsp_server = 'StLspServer',
  code_context = 'StCodeContext',
  code_context_text = 'StCodeContextText',
}

local function colors()
  --- NOTE: Unicode characters including vim devicons should NOT be highlighted
  --- as italic or bold, this is because the underlying bold font is not necessarily
  --- patched with the nerd font characters
  --- terminal emulators like kitty handle this by fetching nerd fonts elsewhere
  --- but this is not universal across terminals so should be avoided

  local indicator_color = P.bright_blue
  local warning_fg = mines.ui.lsp.colors.warn
  local error_color = mines.ui.lsp.colors.error
  local info_color = mines.ui.lsp.colors.info
  local hint_color = mines.ui.lsp.colors.hint
  local normal_fg = highlight.get('Normal', 'fg')
  local string_fg = highlight.get('String', 'fg')
  local number_fg = highlight.get('Number', 'fg')
  local normal_bg = highlight.get('Normal', 'bg')
  local bg_color = highlight.tint(normal_bg, -0.25)
  local darker_gray = highlight.tint(P.light_gray, 20)

  -- stylua: ignore
  highlight.all({
    { [hls.metadata] = { bg = bg_color, inherit = 'Comment' } },
    { [hls.metadata_prefix] = { bg = bg_color, fg = { from = 'Comment' } } },
    { [hls.indicator] = { bg = bg_color, fg = indicator_color } },
    { [hls.modified] = { fg = string_fg } },
    { [hls.git_branch] = { fg = P.light_gray, bg = bg_color } },
    { [hls.git_added] = { fg = P.light_gray, bg = bg_color } },
    { [hls.git_changed] = { fg = P.light_gray, bg = bg_color } },
    { [hls.git_removed] = { fg = P.light_gray, bg = bg_color } },
    { [hls.git_dirty] = { fg = P.light_gray, bg = bg_color } },
    { [hls.green] = { fg = string_fg, bg = bg_color } },
    { [hls.blue] = { fg = P.dark_blue, bg = bg_color, bold = true } },
    { [hls.number] = { fg = number_fg, bg = bg_color } },
    { [hls.count] = { fg = 'bg', bg = indicator_color, bold = true } },
    { [hls.client] = { bg = bg_color, fg = normal_fg, bold = true } },
    { [hls.env] = { bg = bg_color, fg = error_color, italic = true, bold = true } },
    { [hls.directory] = { bg = bg_color, fg = 'Gray', italic = true } },
    { [hls.directory_inactive] = { bg = bg_color, italic = true, fg = { from = 'Normal', alter = 0.4 } } },
    { [hls.parent_directory] = { bg = bg_color, fg = string_fg, bold = true } },
    { [hls.title] = { bg = bg_color, fg = 'LightGray', bold = true } },
    { [hls.comment] = { bg = bg_color, inherit = 'Comment' } },
    { [hls.statusline] = { bg = bg_color } },
    { [hls.statusline_nc] = { link = 'VertSplit' } },
    { [hls.info] = { fg = info_color, bg = bg_color, bold = true } },
    { [hls.warn] = { fg = warning_fg, bg = bg_color } },
    { [hls.error] = { fg = error_color, bg = bg_color } },
    { [hls.hint] = { fg = hint_color, bg = bg_color } },
    { [hls.filename] = {fg = 'LightGray', bold = true } },
    { [hls.filename_inactive] = { inherit = 'Comment', bold = true } },
    { [hls.mode_normal] = { bg = bg_color, fg = P.light_gray, bold = true } },
    { [hls.mode_op] = { bg = bg_color, fg = P.dark_blue, bold = true } },
    { [hls.mode_insert] = { bg = bg_color, fg = P.blue, bold = true } },
    { [hls.mode_visual] = { bg = bg_color, fg = P.magenta, bold = true } },
    { [hls.mode_visual_lines] = { bg = bg_color, fg = P.magenta, bold = true } },
    { [hls.mode_visual_block] = { bg = bg_color, fg = P.magenta, bold = true } },
    { [hls.mode_replace] = { bg = bg_color, fg = P.dark_red, bold = true } },
    { [hls.mode_v_replace] = { bg = bg_color, fg = P.dark_red, bold = true } },
    { [hls.mode_enter] = { bg = bg_color, fg = P.aqua, bold = true } },
    { [hls.mode_more] = { bg = bg_color, fg = P.aqua, bold = true } },
    { [hls.mode_select] = { bg = bg_color, fg = P.teal, bold = true } },
    { [hls.mode_command] = { bg = bg_color, fg = P.light_yellow, bold = true } },
    { [hls.mode_shell] = { bg = bg_color, fg = P.orange, bold = true } },
    { [hls.mode_term] = { bg = bg_color, fg = P.orange, bold = true } },
    { [hls.mode_none] = { bg = bg_color, fg = P.dark_red, bold = true } },
    { [hls.mode_block] = { bg = bg_color, fg = P.dark_red, bold = true } },
    { [hls.mode_confirm] = { bg = bg_color, fg = P.dark_red, bold = true } },
    { [hls.search_result] = { bg = bg_color, fg = P.yellow, bold = true } },
    { [hls.macro_recording] = { fg = P.orange } },
    -- { [hls.file_properties] = nil,
    -- { [hls.dap_messages] = { bg = bg_color, fg = P.orange, bold = true } },
    { [hls.dap_messages] = { fg = { from = 'Debug' } } },
    { [hls.lsp_indicator] = { bg = bg_color, fg = P.blue } },
    { [hls.lsp_server] = { bg = bg_color, fg = P.dark_blue, bold = true } },
    { [hls.code_context] = { bg = bg_color, fg = darker_gray} },
    { [hls.code_context_text] = { bg = bg_color, fg = P.whitesmoke } },
  })
end

mines.augroup('Customline', { event = 'ColorScheme', command = function() colors() end })

return {
  'rebelot/heirline.nvim',
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
  },
  config = function()
    vim.api.nvim_create_augroup('Heirline', { clear = true })

    require('heirline').setup {
      statusline = require 'plugins.statusline.statusline',
      statuscolumn = require 'plugins.statusline.statuscolumn',
    }

    vim.o.statuscolumn = require('heirline').eval_statuscolumn()
  end,
}
