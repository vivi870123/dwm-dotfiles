local executable = mines.executable

return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local null_ls = require 'null-ls'

      local sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.luacheck,

        null_ls.builtins.code_actions.proselint.with {
          filetypes = { 'markdown', 'tex', 'txt' },
          condition = function() return executable 'proselint' end,
        },

        null_ls.builtins.code_actions.refactoring.with {
          filetypes = { 'php', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
        },

        null_ls.builtins.diagnostics.zsh,

        null_ls.builtins.formatting.jq,

        null_ls.builtins.formatting.shfmt.with {
          filetypes = { 'sh', 'zsh' },
          args = { '-i', '2', '-filename', '$FILENAME' },
        },

        null_ls.builtins.formatting.prettier.with {
          filetypes = { 'html', 'json', 'yaml', 'graphql', 'markdown', 'jsx', 'javascriptreact' },
          condition = function() return executable 'prettier' end,
        },

        null_ls.builtins.diagnostics.phpstan.with {
          to_temp_file = false,
          filetypes = { 'phhp' },
          method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
          cond = function() return executable 'phpstan' end,
        },
      }

      -- -- PHP
      -- local composer_ok, composer = pcall(require, 'composer')
      -- if composer_ok and composer.query { 'require', 'laravel/framework' } ~= nil then
      --   local php_actions = require 'php-code-actions'
      --   local laravel_actions = require 'laravel.code-actions'
      --
      --   table.insert(sources, null_ls.builtins.formatting.pint)
      --   table.insert(sources, laravel_actions.relationships)
      --   table.insert(sources, php_actions.getter_setter)
      --   table.insert(sources, php_actions.file_creator)
      -- end

      null_ls.setup {
        debounce = 150,
        sources = sources,
      }
    end,
  }, -- null-ls.nvim
  {
    'jay-babu/mason-null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'williamboman/mason.nvim' },
      'jose-elias-alvarez/null-ls.nvim',
    },
    config = function()
      local null_ls = require 'null-ls'
      null_ls.setup()

      require('mason-null-ls').setup {
        automatic_setup = true,
        automatic_installation = true,
        ensure_installed = {
          'php-debug-adapter',
          'black',
          'luacheck',
          'eslint_d',
          'shellcheck',
          'stylua',
          'shfmt',
        },
      }
    end,
  }, -- mason-null-ls.nvim
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    event = 'VeryLazy',
    opts = {
      automatic_installation = true,
      ensure_installed = {
        'bashls',
        'cssls',
        'emmet_ls',
        'html',
        'intelephense',
        'jsonls',
        'lua_ls',
        'phpactor',
        'sqlls',
        'tailwindcss',
        'tsserver',
        'yamlls',

        'eslint_d',
        'luacheck',
        'phpstan',
        'proselint',
        'shellcheck',

        'black',
        'jq',
        'pint',
        'prettier',
        -- 'prettierd',
        'shfmt',
        'stylua',
      },
    },
  }, -- mason-tool-installer.nvim
  {
    'jackMort/ChatGPT.nvim',
    cmd = { 'ChatGPT', 'ChatGPTActAs', 'ChatGPTEditWithInstructions' },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local border = { style = mines.ui.border.rectangle, highlight = 'PickerBorder' }
      require('chatgpt').setup {
        popup_window = { border = border },
        popup_input = { border = border, submit = '<C-s>' },
        settings_window = { border = border },
        chat = {
          keymaps = {
            close = {
              '<C-c>',--[[ , '<Esc>' ]]
            },
          },
        },
      }
    end,
  }, -- ChatGPT.nvim
}

