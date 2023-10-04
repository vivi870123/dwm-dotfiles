return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    config = function()
      -- @see: https://github.com/nvim-orgmode/orgmode/issues/481
      local ok, orgmode = pcall(require, 'orgmode')
      if ok then orgmode.setup_ts_grammar() end

      -- stylua: ignore
      local install_list = {
        'bash', 'css', 'diff', 'dockerfile', 'gitcommit', 'gitignore', 'graphql', 'html', 'http',
        'json', 'json5', 'jsonc', 'lua', 'luadoc', 'make', 'markdown', 'markdown_inline',
        'php', 'phpdoc', 'python', 'query', 'regex', 'rust', 'sql', 'toml', 'todotxt', 'vim', 'yaml',
        -- "comment", -- comments are slowing down TS bigtime, so disable for now
      }

      require('nvim-treesitter.configs').setup {
        ensure_installed = install_list,

        indent = {
          enable = true,
          disable = function(lang, bufnr)
            if lang == 'lua' or lang == 'html' or lang == 'vue' or 'yaml' then -- or lang == "python" then
              return true
            else
              return false
            end
          end,
        },

        context_commentstring = {
          enable = true,
          enable_autocmd = false, -- we will use nvim-ts-context-commentstring
          config = {
            lua = '--  %s',
            css = '// %s',
            javascriptreact = { style_element = '{/*%s*/}' },
          },
        },

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'org', 'php' },
        },

        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[a'] = '@parameter.inner',
            },
            goto_next_start = {
              [']m'] = '@function.outer',
              [']a'] = '@parameter.inner',
            },
          },
        },

        playground = { persist_queries = true },
      }
    end,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
    },
  },
  { 'JoosepAlviste/nvim-ts-context-commentstring' },
}
