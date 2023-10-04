return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  lazy = false,
  config = function()
    local border = mines.ui.current.border

    mines.highlight.plugin('whichkey', {
      theme = {
        ['*'] = { { WhichkeyFloat = { link = 'NormalFloat' } } },
      },
    })

    local wk = require 'which-key'
    wk.setup {
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true },
        presets = {
          operators = false,
          motions = true,
          text_objects = true,
          nav = false,
          z = true,
          g = false,
          windows = false,
        },
      },
      icons = { breadcrumb = '»', separator = '➜', group = '+' },
      window = { winblend = 3, border = border },
      show_help = false,
    }

    wk.register {
      [']'] = { name = '+Next' },
      ['['] = { name = '+Prev' },
      g = {
        c = { name = '+Comment' },
        l = { name = '+Align' },
        s = { name = '+Grep' },
      },
      ['<leader>'] = {
        a = { name = '+Projectionist' },
        c = { name = '+Color' },
        d = { name = '+Debug/Database', h = 'Dap Hydra' },
        f = { name = '+Telescope' },
        p = { name = '+Package' },
        q = { name = '+Quit' },
        l = { name = '+List' },
        e = { name = '+Edit' },
        r = { name = '+Lsp-Refactor' },
        o = { name = '+Only / Org' },
        t = { name = '+Tab' },
        s = { name = '+Source/Swap' },
        z = 'Window Scroll Hydra',
      },
      ['<localleader>'] = {
        d = { name = '+Dap' },
        g = { name = '+Git' },
        G = 'Git hydra',
        n = { name = '+Neogen' },
        o = { name = '+Neorg' },
        t = { name = '+Neotest' },
        w = { name = '+Window' },
      },
    }
  end,
}
