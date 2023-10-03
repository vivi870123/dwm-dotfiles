local env, opt, api, fn, cmd, fmt = vim.env, vim.opt, vim.api, vim.fn, vim.cmd, string.format
local ui, highlight = mines.ui, mines.highlight
local icons, border = ui.icons, ui.current.border

return {
  {
    'willothy/flatten.nvim',
    lazy = false,
    priority = 1001,
    config = {
      window = { open = 'alternate' },
      callbacks = {
        block_end = function() require('toggleterm').toggle() end,
        post_open = function(_, winnr, _, is_blocking)
          if is_blocking then
            require('toggleterm').toggle()
          else
            api.nvim_set_current_win(winnr)
          end
        end,
      },
    },
  },
  {
    'lmburns/lf.nvim',
    lazy = false,
    keys = {
      { '<localleader>e', '<cmd>Lf<CR>', desc = 'Lf: toggle' },
      { '<localleader>a', '<cmd>Lf<CR>', desc = 'Lf: toggle' },
    },
    config = function()
      require('lf').setup {
        default_actions = { -- default action keybindings
          ['st'] = 'tabedit',
          ['sg'] = 'vsplit',
          ['sv'] = 'split',
          ['e'] = '',
          ['w'] = '',
          ['W'] = '',
        },
        winblend = 10, -- psuedotransparency level
        dir = '', -- directory where `lf` starts ('gwd' is git-working-directory, ""/nil is CWD)
        direction = 'float', -- window type: float horizontal vertical
        border = mines.ui.current.border, -- border kind: single double shadow curved
        width = fn.float2nr(fn.round(0.95 * vim.o.columns)),
        mappings = true, -- whether terminal buffer mapping is enabled
        height = fn.float2nr(fn.round(0.95 * vim.o.lines)),
        -- height = 0.80, -- height of the *floating* window
        -- width = 0.85, -- width of the *floating* window
        escape_quit = true, -- map escape to the quit command (so it doesn't go into a meta normal mode)
        focus_on_open = false, -- focus the current file when opening Lf (experimental)
        -- Layout configurations
        layout_mapping = '<A-u>',
        views = {
          { width = 0.600, height = 0.600 },
          { width = 0.950, height = 0.950 },
        },
        highlights = {
          FloatBorder = { guibg = 'Black', guifg = 'DarkGray' },
          NormalFloat = { guibg = 'Black' },
        },
      }
    end,
    init = function() vim.g.f_netrw = true end,
  },
  {
    'folke/lazy.nvim',
    version = '*',
  }, -- lazy.nvim,
  {
    'nvim-lua/plenary.nvim',
    version = '*',
  }, -- plenary.nvim
  {
    'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
    dependencies = { 'DaikyXendo/nvim-material-icon' },
    config = function()
      require('nvim-web-devicons').setup {
        override = require('nvim-material-icon').get_icons(),
      }
    end,
  }, -- nvim-web-devicons
  {
    'olimorris/persisted.nvim',
    event = 'VimEnter',
    priority = 1000,
    init = function()
      mines.augroup('PersistedEvents', {
        event = 'User',
        pattern = 'PersistedSavePre',
        -- Arguments are always persisted in a session and can't be removed using 'sessionoptions'
        -- so remove them when saving a session
        command = function() cmd '%argdelete' end,
      })
    end,
    opts = {
      autoload = true,
      use_git_branch = true,
      allowed_dirs = { vim.g.dotfiles, vim.g.work_dir, vim.g.projects_dir .. '/personal' },
      ignored_dirs = { vim.g.data_dir },
    },
  }, -- persisted.nvim

  --   -----------------------------------------------------------------------------
  --   -- LSP
  --   -----------------------------------------------------------------------------

  'onsails/lspkind.nvim',
  'b0o/schemastore.nvim',
  {
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = false },
      float = { text = icons.misc.lightbulb, enabled = true, win_opts = { border = 'none' } },
    },
  },
  {
    {
      'williamboman/mason.nvim',
      cmd = 'Mason',
      build = ':MasonUpdate',
      opts = { ui = { border = border, height = 0.8 } },
    },
    {
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        'mason.nvim',
        {
          'neovim/nvim-lspconfig',
          dependencies = {
            {
              'folke/neodev.nvim',
              ft = 'lua',
              opts = { library = { plugins = { 'nvim-dap-ui' } } },
            },
            {
              'folke/neoconf.nvim',
              cmd = { 'Neoconf' },
              opts = { local_settings = '.nvim.json', global_settings = 'nvim.json' },
            },
          },
          config = function()
            highlight.plugin('lspconfig', { { LspInfoBorder = { link = 'FloatBorder' } } })
            require('lspconfig.ui.windows').default_options.border = border
          end,
        },
      },
      opts = {
        automatic_installation = true,
        handlers = {
          function(name)
            local config = require 'servers'(name)
            if config then require('lspconfig')[name].setup(config) end
          end,
        },
      },
    },
  },
  {
    'DNLHC/glance.nvim',
    event = 'VeryLazy',
    keys = { 'gd', 'gr', 'gy', 'gi' },
    opts = {
      before_open = function(results, open, jump, method)
        local uri = vim.uri_from_bufnr(0)
        if #results == 1 then
          local target_uri = results[1].uri or results[1].targetUri

          if target_uri == uri then
            jump(results[1])
          else
            open(results)
          end
        else
          open(results)
        end
      end,
      preview_win_opts = {
        relativenumber = false,
        wrap = false,
      },
      theme = { enable = true },
    },
  }, -- glance.nvim
  {
    'smjonas/inc-rename.nvim',
    opts = { hl_group = 'Visual', preview_empty_name = true },
    keys = {
      {
        '<leader>rn',
        function() return fmt(':IncRename %s', fn.expand '<cword>') end,
        expr = true,
        silent = false,
      },
      desc = 'lsp: incremental rename',
    },
  }, -- inc-rename.nvim
  {
    'lvimuser/lsp-inlayhints.nvim',
    init = function()
      mines.augroup('InlayHintsSetup', {
        event = 'LspAttach',
        command = function(args)
          local id = vim.tbl_get(args, 'data', 'client_id') --[[@as lsp.Client]]
          if not id then return end
          local client = vim.lsp.get_client_by_id(id)
          require('lsp-inlayhints').on_attach(client, args.buf)
        end,
      })
    end,
    opts = {
      inlay_hints = {
        highlight = 'Comment',
        labels_separator = ' ⏐ ',
        parameter_hints = { prefix = '󰊕' },
        type_hints = { prefix = '=> ', remove_colon_start = true },
      },
    },
  }, -- lsp-inlayhints.nvim
  {
    'SmiteshP/nvim-navic',
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = function()
      require('nvim-navic').setup {
        highlight = false,
        icons = require('lspkind').symbol_map,
        depth_limit_indicator = ui.icons.misc.ellipsis,
        lsp = { auto_attach = true },
      }
    end,
  }, -- nvim-navic

  -----------------------------------------------------------------------------//
  -- Utilities
  -----------------------------------------------------------------------------//
  {
    'rainbowhxch/beacon.nvim',
    event = 'VeryLazy',
    opts = {
      minimal_jump = 20,
      ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
      ignore_filetypes = {
        'qf',
        'dap_watches',
        'dap_scopes',
        'neo-tree',
        'NeogitCommitMessage',
        'NeogitPopup',
        'NeogitStatus',
      },
    },
  }, -- beacon.nvim
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require 'nvim-autopairs'
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      autopairs.setup {
        close_triple_quotes = true,
        check_ts = true,
        fast_wrap = { map = '<m-e>' },
        ts_config = {
          lua = { 'string' },
          dart = { 'string' },
          javascript = { 'template_string' },
        },
      }
    end,
  }, -- nvim-autopairs
  {
    'mg979/vim-visual-multi',
    keys = {
      { '<c-n>', '<Plug>(VM-Find-Under)' },
      { '<n-n>', '<Plug>(VM-Find-Under)' },
      { '<c-n>', '<Plug>(VM-Find-Subword-Under)', mode = 'x' },
      { '<M-A>', '<Plug>(VM-Select-All)', desc = 'visual multi: select all' },
      { '<M-A>', '<Plug>(VM-Visual-All)', mode = 'x', desc = 'visual multi: visual all' },
      { 'g/', '<cmd>VMSearch<cr>', desc = 'visual multi: search' },
    },
    init = function()
      vim.g.VM_Extend_hl = 'VM_Extend_hi'
      vim.g.VM_Cursor_hl = 'VM_Cursor_hi'
      vim.g.VM_Mono_hl = 'VM_Mono_hi'
      vim.g.VM_Insert_hl = 'VM_Insert_hi'
      vim.g.VM_highlight_matches = ''
      vim.g.VM_show_warnings = 0
      vim.g.VM_silent_exit = 1
      vim.g.VM_default_mappings = 1
    end,
  }, -- vim-visual-multi
  {
    'folke/flash.nvim',
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end },
      -- { 'S', mode = { 'o', 'x' }, function() require('flash').treesitter() end },
      {
        'r',
        function() require('flash').remote() end,
        mode = 'o',
        desc = 'Remote Flash',
      },
      {
        '<c-s>',
        function() require('flash').toggle() end,
        mode = { 'c' },
        desc = 'Toggle Flash Search',
      },
      {
        'R',
        function() require('flash').treesitter_search() end,
        mode = { 'o', 'x' },
        desc = 'Flash Treesitter Search',
      },
    },
    init = function()
      mines.highlight.plugin('flash', {
        { FlashLabel = { fg = { from = 'Keyword' }, bold = true, italic = true } },
        { FlashCurrent = { fg = { from = 'Function' }, italic = false, underline = true } },
        { FlashMatch = { fg = { from = 'Function' }, italic = false } },
        { FlashBackdrop = { fg = { from = 'Comment' } } },
      })
    end,
    opts = {
      modes = {
        char = {
          keys = { 'f', 'F', 't', 'T', ';' }, -- remove "," from keys
        },
      },
    },
  },
  {
    'jghauser/fold-cycle.nvim',
    config = true,
    keys = { { '<BS>', function() require('fold-cycle').open() end, desc = 'fold-cycle: toggle' } },
  }, -- fold-cycle.nvim
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = { { '<leader>u', '<Cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' } },
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  }, -- undotree
  {
    'kylechui/nvim-surround',
    version = '*',
    keys = { { 's', mode = 'v' }, '<C-g>s', '<C-g>S', 'ys', 'yss', 'yS', 'cs', 'ds' },
    opts = { move_cursor = true, keymaps = { visual = 's' } },
  }, -- nvim-surround
  {
    'monaqa/dial.nvim',
    keys = {
      { '<c-a>', '<Plug>(dial-increment)', mode = 'n', 'v' },
      { '<c-x>', '<Plug>(dial-decrement)', mode = 'n', 'v' },
      { 'g<c-a>', 'g<Plug>(dial-increment)', mode = 'v' },
      { 'g<c-x>', 'g<Plug>(dial-decrement)', mode = 'v' },

      { '<m-a>', '<Plug>(dial-increment)', mode = 'n', 'v' },
      { '<m-x>', '<Plug>(dial-decrement)', mode = 'n', 'v' },
      { 'g<m-a>', 'g<Plug>(dial-increment)', mode = 'v' },
      { 'g<m-x>', 'g<Plug>(dial-decrement)', mode = 'v' },
    },
    config = function()
      local augend = require 'dial.augend'
      local config = require 'dial.config'

      local operators = augend.constant.new {
        elements = { '&&', '||' },
        word = false,
        cyclic = true,
      }

      local casing = augend.case.new {
        types = {
          'camelCase',
          'snake_case',
          'PascalCase',
          'SCREAMING_SNAKE_CASE',
        },
        cyclic = true,
      }

      config.augends:register_group {
        -- default augends used when no group name is specified
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias['%Y/%m/%d'],
          -- augend.date.alias['%m/%d/%y'],
          augend.constant.alias.bool,
        },
        casing,
        dep_files = { augend.semver.alias.semver },
      }

      config.augends:on_filetype {
        typescript = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.constant.alias.bool,
          augend.constant.new { elements = { 'let', 'const' } },
          operators,
          casing,
        },
        markdown = { augend.integer.alias.decimal, augend.misc.alias.markdown_header },
        yeaml = { augend.integer.alias.decimal, augend.semver.alias.semver },
        toml = { augend.integer.alias.decimal, augend.semver.alias.semver },
      }
    end,
  }, -- dial.nvim
  {
    'mrjones2014/smart-splits.nvim',
    config = true,
    build = './kitty/install-kittens.bash',
    keys = {
      { '<a-H>', function() require('smart-splits').resize_left() end },
      { '<a-L>', function() require('smart-splits').resize_right() end },
      { '<a-J>', function() require('smart-splits').resize_down() end },
      { '<a-K>', function() require('smart-splits').resize_up() end },
      -- moving between splits
      { '<a-h>', function() require('smart-splits').move_cursor_left() end },
      { '<a-j>', function() require('smart-splits').move_cursor_down() end },
      { '<a-k>', function() require('smart-splits').move_cursor_up() end },
      { '<a-l>', function() require('smart-splits').move_cursor_right() end },
    },
  }, -- smart-splits.nvim
  {
    'anuvyklack/vim-smartword',
    event = 'VeryLazy',
  }, -- vim-smartword
  {
    'chaoren/vim-wordmotion',
    event = 'VeryLazy',
    init = function() vim.g.wordmotion_spaces = { '-', '_', '\\/', '\\.' } end,
  }, -- vim-wordmotion
  { 'nacro90/numb.nvim', event = 'CmdlineEnter', config = true },
  {
    'linty-org/readline.nvim',
    keys = {
      { '<M-f>', function() require('readline').forward_word() end, mode = '!' },
      { '<M-b>', function() require('readline').backward_word() end, mode = '!' },
      { '<C-a>', function() require('readline').beginning_of_line() end, mode = '!' },
      { '<C-e>', function() require('readline').end_of_line() end, mode = '!' },
      { '<C-w>', function() require('readline').unix_word_rubout() end, mode = '!' },
      { '<C-k>', function() require('readline').kill_line() end, mode = '!' },
      { '<C-u>', function() require('readline').backward_kill_line() end, mode = '!' },
      { '<M-d>', function() require('readline').kill_word() end, mode = '!' },
      { '<M-BS>', function() require('readline').backward_kill_word() end, mode = '!' },
    },
  },
  --{
  --  'HiPhish/rainbow-delimiters.nvim',
  --  event = 'VeryLazy',
  --  config = function()
  --    local rainbow_delimiters = require 'rainbow-delimiters'

  --    vim.g.rainbow_delimiters = {
  --      strategy = {
  --        [''] = rainbow_delimiters.strategy['global'],
  --      },
  --      query = {
  --        [''] = 'rainbow-delimiters',
  --      },
  --    }
  --  end,
  --},

  -----------------------------------------------------------------------------//
  -- Quickfix
  -----------------------------------------------------------------------------//
  {
    url = 'https://gitlab.com/yorickpeterse/nvim-pqf',
    event = 'VeryLazy',
    config = true,
  }, -- nvim-pqf
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
  }, -- nvim-bqf

  ---------------------------------------------------------------------------------------------
  -- Terminal
  ---------------------------------------------------------------------------------------------
  {
    'kassio/neoterm',
    lazy = false,
    config = function()
      vim.g.neoterm_bracketed_paste = 1
      vim.g.neoterm_repl_python = 'ipython'
      vim.g.neoterm_direct_open_repl = 1
      vim.g.neoterm_default_mod = 'vertical'
      vim.g.neoterm_autoinsert = 1
      vim.g.neoterm_autoscroll = 1

      -- Change default shell to zsh (if it is installed)
      if vim.fn.executable 'zsh' == 1 then vim.g.neoterm_shell = 'zsh' end
    end,
  }, -- neoterm
  {
    'metakirby5/codi.vim',
    event = 'VeryLazy',
  }, -- codi

  ---------------------------------------------------------------------------------------------
  -- FileType Plugins
  ---------------------------------------------------------------------------------------------
  {
    'NTBBloodbath/rest.nvim',
    ft = 'http',
    config = function()
      local rest_nvim = require 'rest-nvim'

      rest_nvim.setup {
        result_split_horizontal = false,
        skip_ssl_verification = false,
        encode_url = false,
        highlight = {
          enabled = true,
          timeout = 150,
        },
        result = {
          show_url = true,
          show_http_info = true,
          show_headers = true,
        },
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
      }

      mines.augroup('RestAutocommand', {
        event = 'FileType',
        pattern = 'http',
        command = function()
          local bufnr = tonumber(vim.fn.expand '<abuf>', 10)
          map('n', '<leader>hn', rest_nvim.run, { desc = 'rest: run request', buffer = bufnr })
          map('n', '<leader>hl', rest_nvim.last, { desc = 'rest: last request', buffer = bufnr })
          map(
            'n',
            '<leader>hp',
            function() rest_nvim.run(true) end,
            { desc = 'rest: run req with preview', buffer = bufnr }
          )
        end,
      })
    end,
  }, -- rest.nvim

  -- typescript / javascript
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-treesitter/nvim-treesitter' },
    },
    keys = {
      {
        '<leader>rr',
        function() require('telescope').extensions.refactoring.refactors() end,
        mode = { 'n', 'v' },
        desc = 'Refactoring menu',
      },
    },
    config = function()
      require('refactoring').setup {}
      require('telescope').load_extension 'refactoring'
    end,
  },



  { 'dmmulroy/tsc.nvim', cmd = 'TSC', opts = {}, ft = { 'typescript', 'typescriptreact' } },
  {
    'pmizio/typescript-tools.nvim',
    ft = { 'typescript', 'typescriptreact' },
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      tsserver_file_preferences = {
        includeInlayParameterNameHints = 'literal',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  { 'fladson/vim-kitty', lazy = false },
  { 'mtdl9/vim-log-highlighting', lazy = false },

  { 'lifepillar/pgsql.vim', lazy = false },
  {
    'vuki656/package-info.nvim',
    event = 'BufRead package.json',
    dependencies = 'MunifTanjim/nui.nvim',
    config = true,
  }, -- package-info.nvim

  -- php
  {
    'adalessa/phpactor.nvim',
    cmd = { 'PhpActor' },
    keys = {
      { '<leader>pa', ':PhpActor context_menu<cr>', desc = 'PhpActor context menu' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      install = { bin = vim.g.data_dir .. '/mason/bin/phpactor' },
      lspconfig = { enabled = false },
    },
  },
  { 'jwalton512/vim-blade' },
  {
    'adalessa/laravel.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>la', ':Laravel artisan<cr>', desc = 'Laravel Application Commands' },
      { '<leader>lr', ':Laravel routes<cr>', desc = 'Laravel Application Routes' },
      {
        '<leader>lt',
        function() require('laravel').app.sendToTinker() end,
        mode = 'v',
        desc = 'Laravel App Routes',
      },
    },
    dependencies = {
      { 'adalessa/php-code-actions.nvim' },
      { 'adalessa/composer.nvim' },
      -- {
      --   'adalessa/telescope-projectionist.nvim',
      --   ft = 'php',
      --   dependencies = { 'tpope/vim-projectionist' },
      --   event = 'VeryLazy',
      --   config = function() require('telescope').load_extension 'projectionist' end,
      -- },
    },
    config = function()
      vim.g.laravel_log_level = 'debug'
      require('laravel').setup()
      require('telescope').load_extension 'laravel'
    end,
  },
  {
    'mboughaba/i3config.vim',
  },
}
