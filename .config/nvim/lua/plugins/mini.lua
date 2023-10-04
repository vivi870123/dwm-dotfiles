local fn, api = vim.fn, vim.api

return {
  {
    'echasnovski/mini.move',
    event = 'VeryLazy',
    main = 'mini.move',
    keys = {
      { '<A-Up>', mode = { 'n', 'v' } },
      { '<A-Down>', mode = { 'n', 'v' } },
      { '<A-Left>', mode = { 'n', 'v' } },
      { '<A-Right>', mode = { 'n', 'v' } },
    },
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = '<A-left>',
        right = '<A-right>',
        down = '<A-down>',
        up = '<A-up>',
        -- Move current line in Normal mode
        line_left = '<A-left>',
        line_right = '<A-right>',
        line_down = '<A-down>',
        line_up = '<A-up>',
      },
    },
  }, -- mini.move
  {
    'echasnovski/mini.align',
    event = 'VeryLazy',
    main = 'mini.align',
    opts = { mappings = { start = 'gl', start_with_preview = 'gL' } },
  }, -- mini.align
  {
    'echasnovski/mini.splitjoin',
    keys = { { 'gS', mode = { 'o', 'x', 'n' } } },
    main = 'mini.splitjoin',
    config = true,
  }, -- mini.splitjoin
  {
    'echasnovski/mini.comment',
    lazy = false,
    -- event = 'VeryLazy',
    main = 'mini.comment',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    keys = {
      { '<c-/>', 'gcc', remap = true, silent = true, mode = 'n' },
      { '<c-/>', 'gc', remap = true, silent = true, mode = 'x' },
      { '<m-/>', 'gcc', remap = true, silent = true, mode = 'n' },
      { '<m-/>', 'gc', remap = true, silent = true, mode = 'x' },
    },
    opts = {
      hooks = { pre = function() require('ts_context_commentstring.internal').update_commentstring {} end },
    },
  }, -- mini.comment
  {
    'echasnovski/mini.cursorword',
    event = 'VeryLazy',
    main = 'mini.cursorword',
    config = true,
  }, -- mini.cursorword
  {
    'echasnovski/mini.bufremove',
    event = 'VeryLazy',
    min = 'mini.bufremove',
    keys = { { '<leader>qq', function() require('mini.bufremove').delete(0) end, desc = 'buffer delete' } },
    config = true,
  }, -- mini.bufremove
  {
    'echasnovski/mini.bracketed',
    event = 'VeryLazy',
    version = false,
    main = 'mini.bracketed',
    opts = {
      buffer = { suffix = 'b', options = {} },
      comment = { suffix = 'c', options = {} },
      indent = { suffix = 'i', options = {} },
      jump = { suffix = 'j', options = {} },
      location = { suffix = 'l', options = {} },
      oldfile = { suffix = 'o', options = {} },
      quickfix = { suffix = 'q', options = {} },
      treesitter = { suffix = 't', options = {} },
      undo = { suffix = 'u', options = {} },
      yank = { suffix = 'y', options = {} },
      conflict = { suffix = ' ', options = {} },
      diagnostic = { suffix = ' ', options = {} },
      file = { suffix = ' ', options = {} },
      window = { suffix = ' ', options = {} },
    },
  }, -- mini.bracketed
  {
    'echasnovski/mini.ai',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      local gen_spec = require('mini.ai').gen_spec

      local opts = {
        mappings = {
          around = 'a',
          inside = 'i',
          around_next = 'an',
          inside_next = 'in',
          around_last = 'al',
          inside_last = 'il',
          goto_left = 'g[',
          goto_right = 'g]',
        },

        n_lines = 500, -- Number of lines within which textobject is searched
        search_method = 'cover_or_next',
      }

      opts.custom_textobjects = {
        ['s'] = { { '%b()', '%b[]', '%b{}', '%b""', "%b''", '%b``' }, '^.().*().$' },
        m = gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        c = gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
        a = gen_spec.treesitter { a = '@parameter.outer', i = '@parameter.inner' },
        o = gen_spec.treesitter {
          a = { '@conditional.outer', '@loop.outer' },
          i = { '@conditional.inner', '@loop.inner' },
        },
        x = gen_spec.treesitter { a = '@comment.outer', i = '@comment.inner' },
        E = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = api.nvim_buf_line_count(0),
            col = math.max(fn.getline('$'):len(), 1),
          }
          return { from = from, to = to }
        end,
        u = { 'https?://[A-Za-z0-9][A-Za-z0-9_%-/.#?%%&=;@]+' },
      }

      require('mini.ai').setup(opts)
    end,
  }, -- mini.ai
  {
    'echasnovski/mini.indentscope',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local opts = {
        symbol = '│',
        draw = { delay = 100, animation = require('mini.indentscope').gen_animation.none() },
        options = {
          border = 'both',
          indent_at_cursor = true,
          try_as_border = true,
        },
      }

      mines.augroup('MiniIndentscopeAutoCommand', {
        event = 'FileType',
        pattern = { 'help', 'neo-tree', 'lazy', 'mason' },
        command = function() vim.b.miniindentscope_disable = true end,
      })

      require('mini.indentscope').setup(opts)
    end,
  }, -- mini.indentscope
  {
    'echasnovski/mini.animate',
    event = 'VeryLazy',
    config = function()
      local animate = require 'mini.animate'
      local timing = animate.gen_timing.linear { easing = 'in', duration = 100, unit = 'total' }

      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs { 'Up', 'Down' } do
        local key = '<ScrollWheel' .. scroll .. '>'
        map({ '', 'i' }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      animate.setup {
        cursor = { enable = true },
        scroll = {
          enable = true,
          timing = timing,
          subscroll = animate.gen_subscroll.equal {
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          },
        },
        resize = { enable = true, timing = timing },
        open = { enable = true, timing = timing },
        close = { enable = true, timing = timing },
      }
    end,
  }, -- mini.animate
  {
    'echasnovski/mini.basics',
    enabled = false,
    event = 'VeryLazy',
    config = function()
      require('mini.basics').setup {
        options = { basic = false, extra_ui = false },
        mappings = { basic = false, windows = true },
        autocommands = { relnum_in_visual_mode = false },
      }
    end,
  }, -- mini.basics
  {
    'echasnovski/mini.hipatterns',
    event = 'VeryLazy',
    config = function()
      require('mini.hipatterns').setup {
        highlighters = {
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
          todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
          note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
          hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
        },
      }
    end,
  }, -- mini.hipatterns
}

