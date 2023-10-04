local api, fn = vim.api, vim.fn
local strwidth = api.nvim_strwidth
local ui, p_table, falsy = mines.ui, mines.p_table, mines.falsy
local icons, border, rect = ui.icons.lsp, ui.current.border, ui.border.rectangle

return {
  {
    'kevinhwang91/nvim-ufo',
    event = 'VeryLazy',
    dependencies = { 'kevinhwang91/promise-async' },
    keys = {
      { 'zR', function() require('ufo').openAllFolds() end, 'open all folds' },
      { 'zM', function() require('ufo').closeAllFolds() end, 'close all folds' },
      { 'zP', function() require('ufo').peekFoldedLinesUnderCursor() end, 'preview fold' },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      require('ufo').setup {
        open_fold_hl_timeout = 0,
        enable_get_fold_virt_text = true,
        close_fold_kinds = { 'imports', 'comment' },
        provider_selector = function(_, ft) return ft_map[ft] or { 'treesitter', 'indent' } end,
        fold_virt_text_handler = function(virt_text, _, end_lnum, width, truncate, ctx)
          local result, cur_width, padding = {}, 0, ''
          local suffix_width = strwidth(ctx.text)
          local target_width = width - suffix_width

          for _, chunk in ipairs(virt_text) do
            local chunk_text = chunk[1]
            local chunk_width = strwidth(chunk_text)
            if target_width > cur_width + chunk_width then
              table.insert(result, chunk)
            else
              chunk_text = truncate(chunk_text, target_width - cur_width)
              local hl_group = chunk[2]
              table.insert(result, { chunk_text, hl_group })
              chunk_width = strwidth(chunk_text)
              if cur_width + chunk_width < target_width then
                padding = padding .. (' '):rep(target_width - cur_width - chunk_width)
              end
              break
            end
            cur_width = cur_width + chunk_width
          end

          if ft_map[vim.bo[ctx.bufnr].ft] == 'lsp' then
            table.insert(result, { ' ⋯ ', 'UfoFoldedEllipsis' })
            return result
          end

          local end_text = ctx.get_fold_virt_text(end_lnum)
          if end_text[1] and end_text[1][1] then end_text[1][1] = end_text[1][1]:gsub('[%s\t]+', '') end

          vim.list_extend(result, { { ' ⋯ ', 'UfoFoldedEllipsis' }, unpack(end_text) })
          table.insert(result, { padding, '' })
          return result
        end,
      }
    end,
  }, -- nvim-ufo
  {
    'kevinhwang91/nvim-hlslens',
    keys = function()
      -- if Neovim is 0.8.0 before, remap yourself.
      local function nN(char)
        local ok, winid = require('hlslens').nNPeekWithUFO(char)
        if ok and winid then
          -- Safe to override buffer scope keymaps remapped by ufo,
          -- ufo will restore previous buffer keymaps before closing preview window
          -- Type <CR> will switch to preview window and fire `trace` action
          vim.keymap.set('n', '<CR>', function()
            local keyCodes = api.nvim_replace_termcodes('<Tab><CR>', true, false, true)
            api.nvim_feedkeys(keyCodes, 'im', false)
          end, { buffer = true })
        end
      end

      return {
        { 'n', function() nN 'n' end, mode = { 'n', 'x' } },
        { 'N', function() nN 'N' end, mode = { 'n', 'x' } },
        { '*', [[*<cmd>lua require('hlslens').start()<cr>]] },
        { '#', [[#<cmd>lua require('hlslens').start()<CR>nzv]] },
        { 'g*', [[g*<cmd>lua require('hlslens').start()<CR>nzv]] },
        { 'g#', [[g#<cmd>lua require('hlslens').start()<CR>nzv]] },
      }
    end,
    lazy = false,
    config = function()
      local hlslens = require 'hlslens'
      hlslens.setup { nearest_only = true, calm_down = true }

      local config, lensBak
      local overrideLens = function(render, posList, nearest, idx, relIdx)
        local _ = relIdx
        local lnum, col = unpack(posList[idx])

        local text, chunks
        if nearest then
          text = ('[%d/%d]'):format(idx, #posList)
          chunks = { { ' ', 'Ignore' }, { text, 'VM_Extend' } }
        else
          text = ('[%d]'):format(idx)
          chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
        end
        render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
      end

      local function start()
        if hlslens then
          config = require 'hlslens.config'
          lensBak = config.override_lens
          config.override_lens = overrideLens
          hlslens.start()
        end
      end

      local function exit()
        if hlslens then
          config.override_lens = lensBak
          hlslens.start()
        end
      end

      mines.augroup('LensAutocommands', {
        event = 'User ',
        pattern = 'visual_multi_start',
        -- command = function() vmlens_start() end,
        command = function() start() end,
      }, {
        event = 'User ',
        pattern = 'visual_multi_exit',
        command = function() exit() end,
      })
    end,
  }, -- nvim-hlslens
  {
    'uga-rosa/ccc.nvim',
    event = { 'BufRead', 'BufNewFile' },
    keys = {
      { '<leader>cp', '<cmd>CccPick<cr>', desc = 'Pick' },
      { '<leader>cc', '<cmd>CccConvert<cr>', desc = 'Convert' },
      { '<leader>ch', '<cmd>CccHighlighterToggle<cr>', desc = 'Toggle Highlighter' },
    },
    config = function()
      local ccc = require 'ccc'
      local p = ccc.picker
      p.hex.pattern = {
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)>]=],
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)(\x\x)>]=],
      }
      ccc.setup {
        win_opts = { border = border },
        pickers = {
          p.hex,
          p.css_rgb,
          p.css_hsl,
          p.css_hwb,
          p.css_lab,
          p.css_lch,
          p.css_oklab,
          p.css_oklch,
        },
        highlighter = {
          inputs = { ccc.input.hsl, ccc.input.rgb },
          auto_enable = true,
          filetypes = {
            'conf',
            'lua',
            'css',
            'javascript',
            'sass',
            'typescript',
            'javascriptreact',
            'typescriptreact',
          },
          excludes = {
            'lazy',
            'orgagenda',
            'org',
            'NeogitStatus',
            'toggleterm',
          },
        },
        recognize = { input = true, output = true },
        mappings = {
          ['?'] = function()
            print 'i - Toggle input mode'
            print 'o - Toggle output mode'
            print 'a - Toggle alpha slider'
            print 'g - Toggle palette'
            print 'w - Go to next color in palette'
            print 'b - Go to prev color in palette'
            print 'l/d/, - Increase slider'
            print 'h/s/m - Decrease slider'
            print '1-9 - Set slider value'
          end,
        },
      }
    end,
  }, -- ccc.nvim
  {
    'stevearc/dressing.nvim',
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.input(...)
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.select(...)
      end
    end,
    opts = {
      input = {
        enable = true,
        border = border,
        insert_only = true,
        win_options = { winblend = 2 },
      },
      select = {
        get_config = function(opts)
          if opts.kind == 'read_url' then
            return {
              relative = 'win',
              prefer_width = 60,
            }
          end

          if opts.kind == 'codeaction' then
            return {
              backend = 'telescope',
              telescope = mines.telescope.cursor(),
            }
          end

          if opts.kind == 'orgmode' then
            return {
              backend = 'nui',
              nui = {
                position = '97%',
                border = { style = rect },
                min_width = vim.o.columns - 2,
              },
            }
          end
        end,
        telescope = mines.telescope.dropdown(),
        nui = {
          min_height = 10,
        },
      },
    },
  }, -- dressing.nvim
  {
    'levouh/tint.nvim',
    event = 'UIEnter',
    opts = {
      tint = -15,
      highlight_ignore_patterns = {
        'WinSeparator',
        'Comment',
        'Panel.*',
        'Telescope.*',
        'IndentBlankline.*',
        'Bqf.*',
        'VirtColumn',
        'Headline.*',
        'NeoTree.*',
        'LineNr',
        'NvimTree_*.*',
        'Telescope.*',
        'VisibleTab',
      },
      window_ignore_function = function(win_id)
        local win, buf = vim.wo[win_id], vim.bo[vim.api.nvim_win_get_buf(win_id)]
        if win.diff or not falsy(fn.win_gettype(win_id)) then return true end
        local ignore_bt = p_table { terminal = true, prompt = true, nofile = false }
        local ignore_ft = p_table { ['Telescope.*'] = true, ['Neogit.*'] = true, ['qf'] = true }
        return ignore_bt[buf.buftype] or ignore_ft[buf.filetype]
      end,
    },
  },

  -------------------
  -- Distraction Free
  -------------------
  {
    'folke/zen-mode.nvim',
    keys = { { '<leader>Z', '<cmd>ZenMode<cr>', desc = 'ZenMode' } },
    cmd = { 'ZenMode' },
    opts = {
      window = {
        backdrop = 0.98,
        width = 82,
        height = 1,
        options = { signcolumn = 'no', number = false, relativenumber = false },
      },
      plugins = {
        tmux = { enabled = true },
        twilight = { enabled = true },
        gitsigns = { enabled = false },
      },
    },
  }, -- zen-mode.nvim
  {
    'folke/twilight.nvim',
    cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' },
    opts = {
      dimming = { alpha = 0.25, inactive = false },
      context = 10,
      treesitter = true,
      expand = { 'function', 'method', 'table', 'if_statement' },
      exclude = {},
    },
  }, -- twilight.nvim
}
