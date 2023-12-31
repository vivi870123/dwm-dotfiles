local fn = vim.fn
local border, L = mines.ui.current.border, vim.log.levels

return {
  'folke/noice.nvim',
  version = '*',
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim' },
  keys = { { '<M-CR>', function() require('noice').redirect(fn.getcmdline()) end, mode = 'c' } },
  opts = {
    messages = {
      enabled = false,
      view = 'notify',
      view_error = 'notify',
      view_warn = 'notify',
      view_history = 'split',
      view_search = false,
    },
    cmdline = {
      view = 'cmdline',
      opts = { buf_options = { filetype = 'vim' } },
      format = {
        IncRename = { title = 'Rename' },
        substitute = { pattern = '^:%%?s/', icon = ' ', ft = 'regex', title = '' },
      },
    },
    popupmenu = { backend = 'nui' },
    lsp = {
      documentation = {
        opts = {
          border = { style = border },
          position = { row = 2 },
        },
      },
      signature = {
        enabled = true,
        opts = { position = { row = 2 } },
      },
      hover = { enabled = true },
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    views = {
      vsplit = { size = { width = 'auto' } },
      popup = { border = { style = border, padding = { 0, 1 } } },
      cmdline_popup = {
        -- position = { row = 5, col = '50%' },
        size = { width = 'auto', height = 'auto' },
        border = { style = border, padding = { 0, 1 } },
      },
      confirm = {
        border = { style = border, padding = { 0, 1 } },
      },
      popupmenu = {
        size = { width = 60, height = 10 },
        border = { style = border, padding = { 0, 1 } },
      },
      -- notify = {
      --   backend = 'notify',
      --   replace = true,
      --   format = 'notify',
      -- },
    },
    redirect = { view = 'popup', filter = { event = 'msg_show' } },
    routes = {
      {
        opts = { skip = true },
        filter = {
          any = {
            { event = 'msg_show', find = 'written' },
            { event = 'msg_show', find = '%d+ lines, %d+ bytes' },
            { event = 'msg_show', kind = 'search_count' },
            { event = 'msg_show', find = '%d+L, %d+B' },
            { event = 'msg_show', find = '^Hunk %d+ of %d' },
            { event = 'msg_show', find = '%d+ change' },
            { event = 'msg_show', find = '%d+ line' },
            { event = 'msg_show', find = '%d+ more line' },
            -- TODO: investigate the source of this LSP message and disable it happens in typescript files
            { event = 'notify', find = 'No information available' },
          },
        },
      },
      {
        view = 'vsplit',
        filter = { event = 'msg_show', min_height = 20 },
      },
      {
        view = 'notify',
        filter = {
          any = {
            { event = 'msg_show', min_height = 10 },
            { event = 'msg_show', find = 'Treesitter' },
          },
        },
        opts = { timeout = 10000 },
      },
      {
        view = 'notify',
        filter = { event = 'notify', find = 'Type%-checking' },
        opts = { replace = true, merge = true, title = 'TSC' },
        stop = true,
      },
      {
        view = 'mini',
        filter = {
          any = {
            { event = 'msg_show', find = '^E486:' },
            { event = 'notify', max_height = 1 },
          },
        }, -- minimise pattern not found messages
      },
      {
        view = 'notify',
        filter = {
          any = {
            { warning = true },
            { event = 'msg_show', find = '^Warn' },
            { event = 'msg_show', find = '^W%d+:' },
            { event = 'msg_show', find = '^No hunks$' },
          },
        },
        opts = { title = 'Warning', level = L.WARN, merge = false, replace = false },
      },
      {
        view = 'notify',
        opts = { title = 'Error', level = L.ERROR, merge = true, replace = false },
        filter = {
          any = {
            { error = true },
            { event = 'msg_show', find = '^Error' },
            { event = 'msg_show', find = '^E%d+:' },
          },
        },
      },
      {
        view = 'notify',
        opts = { title = '' },
        filter = { kind = { 'emsg', 'echo', 'echomsg' } },
      },

      {
        view = 'notify',
        filter = {
          event = 'noice',
          kind = { 'stats', 'debug' },
        },
        opts = { buf_options = { filetype = 'lua' }, replace = true },
      },
    },
    commands = {
      history = {
        view = 'vsplit',
        opts = { enter = true, format = 'details' },
      },
    },
    presets = {
      inc_rename = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
}
