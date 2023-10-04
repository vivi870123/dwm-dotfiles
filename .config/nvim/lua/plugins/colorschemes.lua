return {
  {
    'rafi/theme-loader.nvim',
    lazy = false,
    priority = 99,
    opts = { initial_colorscheme = 'catppuccin' },
  },
  {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    opts = {
      integrations = {
        alpha = true,
        cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
          },
        },
        navic = { enabled = true },
        neotest = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    'marko-cerovac/material.nvim',
    lazy = false,
    config = function() vim.g.material_style = 'deep ocean' end,
  }, -- material.nvim
  {
    'akinsho/horizon.nvim',
    lazy = false,
    priority = 1000,
  }, -- horizon.nvim
  {
    'igorgue/danger',
    lazy = false,
  }, -- danger
  {
    'NTBBloodbath/doom-one.nvim',
    lazy = false,
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  }, -- doom-one.nvim
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
  }, -- nordic.nvim
  {
    'folke/tokyonight.nvim',
    opts = { style = 'night' },
    lazy = false,
  }, -- tokyonight.nvim
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    config = function()
      require('kanagawa').setup {
        background = {
          light = 'dragon',
          dark = 'lotus',
        },
      }
    end,
  }, -- kanagawa.nvim
  {
    'olimorris/onedarkpro.nvim',
    lazy = false,
  }, -- onedarkpro.nvim
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
  }, -- nightfox.nvim
  {
    'nyoom-engineering/oxocarbon.nvim',
    lazy = false,
  }, -- oxocarbon.nvim
}
