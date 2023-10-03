local api, fn, diagnostic = vim.api, vim.fn, vim.diagnostic
local border = mines.ui.current.border

local function neotest() return require 'neotest' end

return {
  { 'vim-test/vim-test' },
  {
    'nvim-neotest/neotest',
    ft = { 'php', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'lua' },
    keys = {
      { '<localleader>ts', function() neotest().summary.toggle() end, desc = 'neotest: toggle summary' },
      {
        '<localleader>to',
        function() neotest().output.open { enter = true, short = false } end,
        desc = 'neotest: output',
      },
      { '<localleader>tn', function() neotest().run.run() end, desc = 'neotest: run' },
      { '<localleader>tf', function() neotest().run.run(fn.expand '%') end, desc = 'neotest: run file' },
      {
        '<localleader>tF',
        function() neotest().run.run { fn.expand '%', concurrent = false } end,
        desc = 'neotest: run file synchronously',
      },
      {
        '<localleader>tc',
        function() neotest().run.stop { interactive = true } end,
        desc = 'neotest: cancel',
      },
      { '[n', function() neotest().jump.prev { status = 'failed' } end, desc = 'jump to next failed test' },
      {
        ']n',
        function() neotest().jump.next { status = 'failed' } end,
        desc = 'jump to previous failed test',
      },
    },
    dependencies = {
      { 'nvim-neotest/neotest-vim-test' },
      { 'haydenmeade/neotest-jest' },
      { 'adalessa/neotest-phpunit' },
      { 'rcarriga/neotest-plenary', dependencies = { 'nvim-lua/plenary.nvim' } },
      { 'marilari88/neotest-vitest' },
      { 'thenbe/neotest-playwright' },
    },
    config = function()
      local namespace = api.nvim_create_namespace 'neotest'
      diagnostic.config({
        virtual_text = {
          format = function(d) return d.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '') end,
        },
      }, namespace)

      local adapters = {
        require 'neotest-plenary',
        require 'neotest-vim-test' { ignore_file_types = { 'go', 'lua', 'rust', 'php' } },
        require 'neotest-jest' {
          jestCommand = 'npm test --',
          jestConfigFile = 'jest.config.js',
        },
        require 'neotest-vitest',
        require('neotest-playwright').adapter {
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
          },
        },
      }

      -- local composer_ok, composer = pcall(require, 'composer')
      -- if composer_ok and composer.query { 'require', 'laravel/sail' } ~= nil then
      --   table.insert(adapters, [[ require 'laravel.neotest']])
      -- else
      --   return
      -- end

      require('neotest').setup {
        discovery = { enabled = true },
        diagnostic = { enabled = true },
        quickfix = { enabled = false, open = true },
        floating = { border = border },
        adapters = adapters,
      }
    end,
  },
}

