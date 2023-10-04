local ui = mines.ui
local icons, border = ui.icons.separators, ui.current.border

return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = function()
      local goto_hunk_cmd = function(direction)
        local unfold_and_center =
          [[if MiniAnimate ~= nil then MiniAnimate.execute_after('scroll', 'normal! zvzz') else vim.cmd('normal! zvzz') end]]
        return string.format([[<Cmd>lua require("gitsigns").%s_hunk(); %s<CR>]], direction, unfold_and_center)
      end

      return {
        { '=f', '<cmd>Gitsigns preview_hunk<cr>', 'open status buffer' },
        { '=s', '<cmd>Gitsigns stage_buffer<cr>', 'git: stage buffer' },
        { '[h', goto_hunk_cmd 'prev', 'git: prev hunk' },
        { ']h', goto_hunk_cmd 'next', 'git: next hunk' },
        { 'ih', '<cmd>Gitsigns select_hunk<cr>', mode = { 'o', 'x' } },
      }
    end,
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = icons.right_block },
          change = { text = icons.right_block },
          delete = { text = icons.right_block },
          topdelete = { text = icons.right_block },
          changedelete = { text = icons.right_block },
          untracked = { text = icons.light_shade_block },
        },
        word_diff = false,
        numhl = false,
        preview_config = { border = border },
        watch_gitdir = { interval = 1000 },
      }
    end,
  }, -- gitsigns.nvim
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    keys = function()
      local function neogit() return require 'neogit' end
      return {
        { 'mg', function() neogit().open() end, 'open status buffer' },
        { '<localleader>gs', function() neogit().open() end, 'open status buffer' },
        { '<localleader>gc', function() neogit().open { 'commit' } end, 'open commit buffer' },
        { '<localleader>gL', function() neogit().popups.pull.create() end, 'open pull popup' },
        { '<localleader>gP', function() neogit().popups.push.create() end, 'open push popup' },
      }
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      disable_signs = false,
      disable_hint = true,
      disable_context_highlighting = false,
      disable_commit_confirmation = false,
      disable_builtin_notifications = true,
      disable_insert_on_commit = false,
      signs = {
        section = { '', '' }, -- "󰁙", "󰁊"
        item = { '▸', '▾' },
        hunk = { '󰐕', '󰍴' },
      },
      integrations = { diffview = true },

      _inline2 = true,
      _extmark_signs = true,
      _signs_staged_enable = false,
    },
  }, -- },-- neogit.nvim
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<localleader>gd', '<Cmd>DiffviewOpen<CR>', desc = 'diffview: open', mode = 'n' },
      { 'gh', [[:'<'>DiffviewFileHistory<CR>]], desc = 'diffview: file history', mode = 'v' },
      { '<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', desc = 'diffview: file history', mode = 'n' },
    },
    config = function()
      require('diffview').setup {
        default_args = { DiffviewFileHistory = { '%' } },
        hooks = {
          diff_buf_read = function()
            vim.wo.wrap = false
            vim.wo.list = false
            vim.wo.colorcolumn = ''
          end,
        },
        enhanced_diff_hl = true,
        keymaps = {
          view = { q = '<Cmd>DiffviewClose<CR>' },
          file_panel = { q = '<Cmd>DiffviewClose<CR>' },
          file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
        },
      }
    end,
  }, -- diffview.nvim
}
