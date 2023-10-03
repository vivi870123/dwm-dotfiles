local api, fn, k = vim.api, vim.fn, vim.keycode
local ui, highlight = mines.ui, mines.highlight
local ellipsis, border = ui.icons.misc.ellipsis, ui.current.border

return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'L3MON4D3/LuaSnip', event = 'InsertEnter' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-buffer' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'lukas-reineke/cmp-rg' },
      { 'petertriho/cmp-git', opts = { filetypes = { 'gitcommit', 'NeogitCommitMessage' } } },
      { 'roobert/tailwindcss-colorizer-cmp.nvim', ft = { 'css', 'scss', 'jsx', 'tsx' } },
    },
    config = function()
      local cmp = require 'cmp'
      local MIN_MENU_WIDTH, MAX_MENU_WIDTH = 25, math.min(50, math.floor(vim.o.columns * 0.5))
      local MAX_INDEX_FILE_SIZE = 4000

      highlight.plugin('Cmp', {
        { CmpItemKindVariable = { link = 'Variable' } },
        { CmpItemAbbrMatchFuzzy = { inherit = 'CmpItemAbbrMatch', italic = true } },
        { CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' } },
        { CmpItemMenu = { inherit = 'Comment', italic = true } },
      })

      -------------------------------------------------------------------------------------------------
      -- Helpers
      -------------------------------------------------------------------------------------------------
      -- local luasnip = require 'luasnip'
      -- local neogen = require 'neogen'

      local neogen = vim.F.npcall(require, 'neogen')
      local luasnip = vim.F.npcall(require, 'luasnip')

      local has_words_before = function()
        local line, col = unpack(api.nvim_win_get_cursor(0))
        return col ~= 0 and api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end

      local codeium = function() api.nvim_feedkeys(fn['codeium#Accept'](k '<Tab>'), 'n', true) end

      local tab = function(fallback)
        if luasnip then luasnip.unlink_current_if_deleted() end

        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip and luasnip.locally_jumpable(1) then
          luasnip.jump(1)
        elseif neogen and neogen.jumpable() then
          fn.feedkeys(k "<cmd>lua require('neogen').jump_next()<CR>", '')
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end

      local shift_tab = function(fallback)
        if not cmp.visible() then return fallback() end
        if cmp.visible() then cmp.select_prev_item() end
        if luasnip then luasnip.unlink_current_if_deleted() end
        if luasnip.jumpable(-1) then luasnip.jump(-1) end
        if neogen.jumpable(-1) then fn.feedkeys(k "<cmd>lua require('neogen').jump_prev()<CR>", '') end
      end

      local enter_item = function(fallback)
        if luasnip and luasnip.expandable() then
          luasnip.expand()
        elseif cmp.visible() then
          if not cmp.get_selected_entry() then
            cmp.close()
          else
            cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
          end
        else
          fallback()
        end
      end

      local close = function()
        if cmp.visible() then
          cmp.abort()
          cmp.close()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<End>', true, true, true), 'i', true)
        end
      end

      cmp.setup {
        window = {
          completion = cmp.config.window.bordered({
            scrollbar = false,
            border = 'shadow',
            winhighlight = 'NormalFloat:Pmenu,CursorLine:PmenuSel,FloatBorder:FloatBorder',
          }),
          documentation = cmp.config.window.bordered({
            border = border,
            winhighlight = 'FloatBorder:FloatBorder',
          }),
        },
        completion = {
          autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
          completeopt = 'menu,menuone,noselect',
        },
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = {
          ['<c-]>'] = cmp.mapping(codeium),
          ['<a-]>'] = cmp.mapping(codeium),

          ['<c-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i' }),
          ['<a-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i' }),

          ['<c-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i' }),
          ['<a-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i' }),

          ['<c-e>'] = cmp.mapping(close, { 'i', 's' }),
          ['<a-e>'] = cmp.mapping(close, { 'i', 's' }),

          ['<c-space>'] = cmp.mapping.complete(),
          ['<a-space>'] = cmp.mapping.complete(),

          ['<CR>'] = cmp.mapping(enter_item, { 'i', 's' }),
          ['<tab>'] = cmp.mapping(tab, { 'i', 's' }),
          ['<s-tab>'] = cmp.mapping(shift_tab, { 'i', 's' }),

          ['<c-j>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ['<c-k>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ['<a-j>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ['<a-k>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        },

        formatting = {
          -- fields = { 'abbr', 'kind', 'menu' },
          format = require('lspkind').cmp_format {
            mode = 'symbol',
            maxwidth = MAX_MENU_WIDTH,
            ellipsis_char = ellipsis,
            before = function(_, vim_item)
              local label, length = vim_item.abbr, api.nvim_strwidth(vim_item.abbr)
              if length < MIN_MENU_WIDTH then vim_item.abbr = label .. string.rep(' ', MIN_MENU_WIDTH - length) end
              return vim_item
            end,
            menu = {
              nvim_lsp = '[LSP]',
              nvim_lua = '[Lua]',
              emoji = '[EMOJI]',
              path = '[Path]',
              neorg = '[N]',
              luasnip = '[SN]',
              dictionary = '[D]',
              buffer = '[B]',
              spell = '[SP]',
              orgmode = '[Org]',
              norg = '[Norg]',
              rg = '[Rg]',
              git = '[Git]',
            },
          },
        },
        sources = cmp.config.sources {
          { name = 'codeium' },
          { name = 'nvim_lsp', max_item_count = 30, group_index = 1 },
          { name = 'luasnip', group_index = 1, option = { use_show_condition = false } },
          { name = 'path', group_index = 1, max_item_count = 10 },
          {
            name = 'rg',
            group_index = 1,
            keyword_length = 4,
            max_item_count = 10,
            option = { additional_arguments = '--max-depth 8' },
          },
          {
            name = 'buffer',
            group_index = 2,
            keyword_length = 3,
            options = {
              get_bufnrs = function()
                local bufs = {}
                for _, bufnr in ipairs(api.nvim_list_bufs()) do
                  -- Don't index giant files
                  if api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_line_count(bufnr) < MAX_INDEX_FILE_SIZE then
                    table.insert(bufs, bufnr)
                  end
                end
                return bufs
              end,
            },
          },
          { name = 'spell', keyword_length = 4, group_index = 2 },
          --  { name = 'zsh' },
          --  { name = 'vim-dadbod-completion' },
        },
      }
    end,
  }, -- nvim-cmp
  {
    'danymat/neogen',
    opts = {
      enabled = true,
      snippet_engine = 'luasnip',
      input_after_comment = true,
      languages = {
        lua = { template = { annotation_convention = 'emmylua' } },
        python = { template = { annotation_convention = 'numpydoc' } },
      },
    },
  }, -- neogen
  {
    'Exafunction/codeium.vim',
    dependencies = { 'nvim-cmp' },
    init = function() vim.g.codeium_no_map_tab = true end,
    event = 'InsertEnter',
    config = function()
      local opts = { remap = true, expr = true, silent = true, script = true, nowait = true }

      map('i', '<Plug>(mines-copilot-accept)', "codeium#Accept('<Tab>')", opts)
      map('i', '<c-g>', function() return vim.fn['codeium#Accept']() end, opts)
      map('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
      map('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
      map('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
      map('i', '<m-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
      map('i', '<m-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })

      vim.g.codeium_filetypes = {
        ['*'] = true,
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      }
    end,
  }, -- codeium.vim
}
