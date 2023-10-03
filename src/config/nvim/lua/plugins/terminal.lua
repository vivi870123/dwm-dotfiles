local fn = vim.fn

return {
  'akinsho/toggleterm.nvim',
  event = 'VeryLazy',
  opts = {
    open_mapping = [[<c-\>]],
    shade_filetypes = {},
    direction = 'horizontal',
    autochdir = true,
    persist_mode = true,
    insert_mappings = false,
    start_in_insert = true,
    winbar = { enabled = mines.ui.winbar.enable },
    highlights = {
      FloatBorder = { link = 'FloatBorder' },
      NormalFloat = { link = 'NormalFloat' },
    },
    float_opts = {
      border = mines.ui.current.border,
      winblend = 3,
    },
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local float_handler = function(term)
      if not mines.falsy(fn.mapcheck('jk', 't')) then
        vim.keymap.del('t', 'jk', { buffer = term.bufnr })
        vim.keymap.del('t', '<esc>', { buffer = term.bufnr })
      end
    end

    local Terminal = require('toggleterm.terminal').Terminal

    local lazygit = Terminal:new {
      cmd = 'lazygit',
      dir = 'git_dir',
      hidden = true,
      direction = 'float',
      on_open = float_handler,
    }

    local btop = Terminal:new {
      cmd = 'btop',
      hidden = true,
      direction = 'float',
      on_open = float_handler,
    }

    map('n', '<leader>lg', function() lazygit:toggle() end, { desc = 'toggleterm: toggle lazygit' })
    mines.command('Btop', function() btop:toggle() end)
  end,
}
