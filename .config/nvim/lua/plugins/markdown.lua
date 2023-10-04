return {
  {
    'iamcco/markdown-preview.nvim',
    build = function() vim.fn['mkdp#util#install']() end,
    ft = { 'markdown' },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 0
    end,
  },

  {
    'ellisonleao/glow.nvim',
    event = 'VeryLazy',
    ft = 'markdown',
    cmd = 'Glow',
    init = function()
      mines.augroup('GlowAutocomands', {
        event = 'FileType',
        pattern = 'markdown',
        command = function() map('i', '<leader>lp', '<cmd>Glow<cr>', { desc = 'Preview', buffer = true }) end,
      })
    end,
    config = function()
      require('glow').setup {
        install_path = '~/.local/bin', -- default path for installing glow binary
      }
    end,
  },
  {
    'AckslD/nvim-FeMaco.lua',
    cmd = 'FeMaco',
    ft = 'markdown',
    init = function()
      mines.augroup('FamacoAutocommands', {
        event = 'FileType',
        pattern = 'markdown',
        command = function()
          map('n', '<leader>ec', '<cmd>FeMaco<cr>', { desc = 'Edit codeblock', buffer = true })
          map('i', '<c-l>', '<cmd>FeMaco<cr>', { desc = 'Edit codeblock', buffer = true })
        end,
      })
    end,
    opts = {
      post_open_float = function(_)
        vim.wo.signcolumn = 'no'
        map('n', '<esc>', '<cmd>q<cr>', { buffer = true })
      end,
    },
  },
  -- {
  --   'toppair/peek.nvim',
  --   build = { 'deno task --quiet build:fast' },
  --   event = 'VeryLazy',
  --   init = function()
  --     augroup('PeekAutocommands', {
  --       event = 'FileType',
  --       pattern = 'markdown',
  --       command = function()
  --         map('n', '<Leader>eP', function()
  --           local peek = require 'peek'
  --           if peek.is_open() then
  --             peek.close()
  --           else
  --             peek.open()
  --           end
  --         end, { desc = 'Live preview', buffer = true })
  --       end,
  --     })
  --   end,
  --   config = function() require('peek').setup { app = 'browser' } end,
  -- },
}

