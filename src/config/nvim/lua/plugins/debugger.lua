local fn = vim.fn
local ui = mines.ui
local icon, border = ui.icons, ui.current.border

return {
  {
    'mfussenegger/nvim-dap',
    init = function() end,
    -- stylua: ignore
    keys = {
      {'<localleader>dL', function() require('dap').set_breakpoint(nil, nil, fn.input 'Log point message: ') end, desc = 'dap: log breakpoint',},
      {'<localleader>db', function() require('dap').toggle_breakpoint() end, desc = 'dap: toggle breakpoint',},
      {'<localleader>dB', function() require('dap').set_breakpoint(fn.input 'Breakpoint condition: ') end, desc = 'dap: set conditional breakpoint',},
      {'<localleader>dc', function() require('dap').continue() end, desc = 'dap: continue or start debugging',},
      {'<localleader>de', function() require('dap').step_out() end, desc = 'dap: step out',},
      {'<localleader>di', function() require('dap').step_into() end, desc = 'dap: step into',},
      { '<localleader>do', function() require('dap').step_over() end, desc = 'dap: step over' },
      { '<localleader>dl', function() require('dap').run_last() end, desc = 'dap REPL: run last' },
    },
    config = function()
      local dap = require 'dap' -- Dap must be loaded before the signs can be tweaked

      vim.fn.sign_define {
        { name = 'DapBreakpoint', text = icon.bug, texthl = 'DapBreakpoint', linehl = '', numhl = '' },
        { name = 'DapStopped', text = icon.bookmark, texthl = 'DapStopped', linehl = '', numhl = '' },
      }

      -- DON'T automatically stop at exceptions
      -- dap.defaults.fallback.exception_breakpoints = {}
      dap.adapters.php = { type = 'executable', command = 'php-debug-adapter' }
      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Laravel',
          port = 9003,
          pathMappings = { ['/var/www/html'] = '${workspaceFolder}' },
        },
        {
          type = 'php',
          request = 'launch',
          name = 'Symfony',
          port = 9003,
          pathMappings = { ['/app'] = '${workspaceFolder}' },
        },
      }

      require('dap-vscode-js').setup {
        debugger_cmd = { 'js-debug-adapter' },
        adapters = { 'pwa-node', 'pwa-chrome', 'node-terminal' },
      }

      for _, language in ipairs { 'typescript', 'javascript' } do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end

      for _, language in ipairs { 'typescriptreact', 'javascriptreact' } do
        require('dap').configurations[language] = {
          {
            type = 'pwa-chrome',
            name = 'Attach - Remote Debugging',
            request = 'attach',
            program = '${file}',
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            protocol = 'inspector',
            port = 9222,
            webRoot = '${workspaceFolder}',
          },
          {
            type = 'pwa-chrome',
            name = 'Launch Chrome',
            request = 'launch',
            url = 'http://localhost:3000',
          },
        }
      end
    end,
    dependencies = {
      {
        'microsoft/vscode-js-debug',
        build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
      }, -- vscode-js-debug
      {
        'mxsdev/nvim-dap-vscode-js',
        ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        dependencies = { 'mfussenegger/nvim-dap' },
        opts = {
          adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'node-terminal', 'pwa-extensionHost' },
          node_path = 'node',
          debugger_cmd = { 'js-debug-adapter' },
        },
      }, -- nvim-dap-vscode-js
      {
        'rcarriga/nvim-dap-ui',
        keys = {
          {
            '<localleader>duc',
            function() require('dapui').close(mines.debug.layout.ft[vim.bo.ft]) end,
            desc = 'dap ui: close',
          },
          {
            '<localleader>dut',
            function() require('dapui').toggle(mines.debug.layout.ft[vim.bo.ft]) end,
            desc = 'dap ui: toggle',
          },
        },
        config = function()
          require('dapui').setup {
            windows = { indent = 2 },
            floating = { border = border },
            icons = { expanded = '▾', collapsed = '▸' },
            layouts = {
              {
                elements = {
                  { id = 'scopes', size = 0.25 },
                  { id = 'breakpoints', size = 0.25 },
                  { id = 'stacks', size = 0.25 },
                  { id = 'watches', size = 0.25 },
                },
                position = 'left',
                size = 20,
              },
              {
                elements = { 'repl', 'console' },
                size = 10,
                position = 'bottom',
              },
            },
          }

          local dap = require 'dap'

          dap.listeners.after.event_initialized['dapui_config'] = function()
            require('dapui').open()
            vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
          end

          dap.listeners.before.event_terminated['dapui_config'] = function() require('dapui').close() end
          dap.listeners.before.event_exited['dapui_config'] = function() require('dapui').close() end
        end,
      }, -- nvim-dap-ui
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = { all_frames = true },
      }, -- nvim-dap-virtual-text
    },
  }, -- nvim-dap
  {
    'andrewferrier/debugprint.nvim',
    event = 'VeryLazy',
    opts = { create_keymaps = false },
    keys = {
      {
        '<leader>dp',
        function() return require('debugprint').debugprint { variable = true } end,
        { desc = 'debugprint: cursor', expr = true },
      },
      {
        '<leader>do',
        function() return require('debugprint').debugprint { motion = true } end,
        { desc = 'debugprint: operator', expr = true },
      },
      {
        '<leader>C',
        '<Cmd>DelteDebugPrints<CR>',
        { desc = 'debugprint: clear all' },
      },
    },
  }, -- debugprint.nvim
}

