local fn, highlight, ui = vim.fn, mines.highlight, mines.ui
local icons, P = ui.icons, ui.palette

local M = {}
-- A helper function to limit the size of a telescope window to fit the maximum available
-- space on the screen. This is useful for dropdowns e.g. the cursor or dropdown theme
local function fit_to_available_height(self, _, max_lines)
  local results, PADDING = #self.finder.results, 4 -- this represents the size of the telescope window
  local LIMIT = math.floor(max_lines / 2)
  return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
end

---@param opts table
---@return table
local function cursor(opts)
  return require('telescope.themes').get_cursor(vim.tbl_extend('keep', opts or {}, {
    layout_config = {
      width = 0.4,
      height = fit_to_available_height,
    },
  }))
end

---@param opts table
---@return table
local function dropdown(opts)
  return require('telescope.themes').get_dropdown(vim.tbl_extend('keep', opts or {}, {
    borderchars = {
      { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
  }))
end

local function adaptive_dropdown(_) return dropdown { height = fit_to_available_height } end
local function extensions(name) return require('telescope').extensions[name] end

local root_patterns = { '.git', '.hg', '.bzr', '.svn' }

-- Credits: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
local function get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= '' and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws) return vim.uri_to_fname(ws.uri) end, workspace)
        or client.config.root_dir and { client.config.root_dir }
        or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then roots[#roots + 1] = r end
      end
    end
  end
  table.sort(roots, function(a, b) return #a > #b end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

-- Credits: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
-- this will return a function that calls telescope.
-- cwd will default to get_root
-- for `files`, git_files or find_files will be chosen depending on .git
local function telescope(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend('force', { cwd = get_root() }, opts or {})
    if builtin == 'files' then
      if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. '/.git') then
        opts.show_untracked = true
        builtin = 'git_files'
      else
        builtin = 'find_files'
      end
    end
    require('telescope.builtin')[builtin](opts)
  end
end

local function luasnips() extensions('luasnip').luasnip(dropdown()) end
local function notifications() extensions('notify').notify(dropdown()) end
local function pickers() require('telescope.builtin').builtin { include_extensions = true } end

mines.telescope = {
  cursor = cursor,
  dropdown = dropdown,
  adaptive_dropdown = adaptive_dropdown,
}

return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  keys = {
    { '<leader>fn', notifications, desc = 'notifications' },
    { '<leader>.', telescope 'find_files', desc = 'find files' },
    { '<leader>ff', telescope 'git_files', desc = 'find files' },
    { '<leader>fA', pickers, desc = 'builtins' },
    { '<leader>fL', luasnips, desc = 'luasnip: available snippets' },
    { '<leader>fvh', telescope 'autocommands', desc = 'autocommands' },
    { '<leader>fvh', telescope 'highlights', desc = 'highlights' },
    { '<leader>fvk', telescope 'keymaps', desc = 'autocommands' },
    { '<leader>fvo', telescope 'vim_options', desc = 'options' },
    { '<leader>fr', telescope 'resume', desc = 'resume last picker' },
    { '<leader>ff', telescope 'find_files', desc = 'find files' },
    { '<leader>f?', telescope 'help_tags', desc = 'help' },
    { '<leader>fgb', telescope 'git_branches', desc = 'branches' },
    { '<leader>,', telescope 'buffers', desc = 'buffers' },
    { '<leader>fo', telescope 'buffers', desc = 'buffers' },
    { 'z=', telescope 'spell_suggest', desc = 'spell suggestions' },
    { '<leader>;', telescope 'current_buffer_fuzzy_find', desc = 'search buffer' },
    { '<leader>fg', telescope 'live_grep', desc = 'live grep' },
    { '<leader>fd', dotfiles, desc = 'dotfiles' },
    { '<localleader>f', telescope 'files', desc = 'find files' },
  },
  dependencies = {
    { 'nvim-telescope/telescope-dap.nvim' },
    { 'benfowler/telescope-luasnip.nvim' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    { 'nvim-telescope/telescope-smart-history.nvim', dependencies = { 'kkharji/sqlite.lua' } },
  },
  config = function()
    local actions = require 'telescope.actions'
    local themes = require 'telescope.themes'
    local layout_actions = require 'telescope.actions.layout'
    local lga_actions = require 'telescope-live-grep-args.actions'

    mines.augroup('TelescopePreviews', {
      event = 'User',
      pattern = 'TelescopePreviewerLoaded',
      command = function(args)
        --- TODO: Contribute upstream change to telescope to pass preview buffer data in autocommand
        local bufname = vim.tbl_get(args, 'data', 'bufname')
        local ft = bufname and require('plenary.filetype').detect(bufname) or nil
        vim.opt_local.number = not ft or ui.decorations.get(ft, 'number', 'ft') ~= false
      end,
    })

    highlight.plugin('telescope', {
      theme = {
        ['*'] = {
          { TelescopeBorder = { link = 'PickerBorder' } },
          { TelescopePromptPrefix = { link = 'Statement' } },
          { TelescopeTitle = { inherit = 'Normal', bold = true } },
          { TelescopePromptTitle = { fg = { from = 'Normal' }, bold = true } },
          { TelescopeResultsTitle = { fg = { from = 'Normal' }, bold = true } },
          { TelescopePreviewTitle = { fg = { from = 'Normal' }, bold = true } },
        },
        ['doom-one'] = { { TelescopeMatching = { link = 'Title' } } },
      },
    })

    require('telescope').setup {
      defaults = {
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        dynamic_preview_title = true,
        prompt_prefix = ' ' .. icons.misc.telescope .. ' ',
        prompt_title = '',
        results_title = '',
        selection_caret = icons.misc.chevron_right .. ' ',
        cycle_layout_list = { 'flex', 'horizontal', 'vertical', 'bottom_pane', 'center' },

        layout_config = {
          width = 0.95,
          height = 0.85,
          prompt_position = 'bottom',
          bottom_pane = {
            width = 10,
            height = 15,
            preview_height = 0.5,
            preview_cutoff = 120,
          },
          vertical = { width = 0.9, height = 0.95, preview_height = 0.5 },
          flex = { horizontal = { preview_width = 0.9 } },
          horizontal = { preview_width = 0.55 },
        },
        mappings = {
          i = {
            ['<C-x>'] = false,
            ['jk'] = { '<Esc>', type = 'command' },
            ['<Tab>'] = actions.move_selection_next,
            ['<S-Tab>'] = actions.move_selection_previous,
            ['<m-j>'] = actions.move_selection_next,
            ['<m-k>'] = actions.move_selection_previous,
            ['<c-j>'] = actions.move_selection_next,
            ['<c-k>'] = actions.move_selection_previous,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<esc>'] = actions.close,
            ['<C-w>'] = actions.send_selected_to_qflist,
            ['<c-c>'] = function() vim.cmd 'stopinsert!' end,
            ['<c-v>'] = actions.select_horizontal,
            ['<c-g>'] = actions.select_vertical,
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,
            ['<C-b>'] = actions.preview_scrolling_up,
            ['<C-f>'] = actions.preview_scrolling_down,
            ['<c-l>'] = layout_actions.cycle_layout_next,
          },
          n = {
            ['<C-x>'] = false,
            ['q'] = actions.close,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<Esc>'] = actions.close,
            ['<Tab>'] = actions.move_selection_next,
            ['<S-Tab>'] = actions.move_selection_previous,
            ['<C-b>'] = actions.preview_scrolling_up,
            ['<C-f>'] = actions.preview_scrolling_down,
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,
            ['*'] = actions.toggle_all,
            ['u'] = actions.drop_all,
            ['J'] = actions.toggle_selection + actions.move_selection_next,
            ['K'] = actions.toggle_selection + actions.move_selection_previous,
            ['<Space>'] = {
              actions.toggle_selection,
              type = 'action',
              keymap_opts = { nowait = true },
            },
            ['gg'] = actions.move_to_top,
            ['G'] = actions.move_to_bottom,
            ['<c-v>'] = actions.select_horizontal,
            ['<c-g>'] = actions.select_vertical,
            ['<c-t>'] = actions.select_tab,
            ['!'] = actions.edit_command_line,
          },
        },
        history = { path = vim.g.data_dir .. '/telescope_history.sqlite3' },
        -- stylua: ignore
        file_ignore_patterns = {
          '%.jpg', '%.jpeg', '%.png', '%.otf', '%.ttf', '%.DS_Store',
          '^.git/', 'node%_modules/.*', '^site-packages/', '%.yarn/.*',
        },
        path_display = { 'truncate' },
        winblend = 5,
        layout_strategy = 'flex',
      },
      extensions = {
        persisted = mines.telescope.dropdown(),
        live_grep_args = {
          mappings = { -- extend mappings
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
            },
          },
        },
        -- ['zf-native'] = {
        -- generic = { enable = true, match_filename = true },
        --M.extensions },
      },
      pickers = {
        buffers = {
          layout_strategy = 'bottom_pane',
          ignore_current_buffer = true,
          previewer = false,
          mappings = {
            i = { ['<c-x>'] = actions.delete_buffer },
            n = { ['<c-x>'] = actions.delete_buffer },
          },
        },
        git_files = { layout_strategy = 'bottom_pane', previewer = false },
        find_files = {
          layout_strategy = 'bottom_pane',
          previewer = false,
          hidden = true,
          find_command = { 'rg', '--smart-case', '--hidden', '--no-ignore-vcs', '--glob', '!.git', '--files' },
        },
        oldfiles = {
          layout_strategy = 'bottom_pane',
          previewer = false,
        },
        live_grep = themes.get_ivy {
          file_ignore_patterns = { '.git/', '%.svg', '%.lock' },
          max_results = 2000,
        },
        current_buffer_fuzzy_find = {
          layout_strategy = 'bottom_pane',
          previewer = false,
          shorten_path = false,
        },
        quickfix = { layout_strategy = 'bottom_pane' },
        colorscheme = {
          enable_preview = false,
          layout_config = { width = 0.45, height = 0.8 },
        },
        search_history = { layout_strategy = 'bottom_pane' },
        reloader = mines.telescope.dropdown(),
        spell_suggest = {
          theme = 'cursor',
          layout_config = { width = 0.27, height = 0.45 },
        },
      },
    }

    require('telescope').load_extension 'smart_history'
    require('telescope').load_extension 'luasnip'
    require('telescope').load_extension 'live_grep_args'

    if pcall(require, 'dap') then require('telescope').load_extension 'dap' end
    if pcall(require, 'persisted') then require('telescope').load_extension 'persisted' end
  end,
}
