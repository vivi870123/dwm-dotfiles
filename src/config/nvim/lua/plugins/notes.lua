local fmt, fn, ui = string.format, vim.fn, vim.ui
local border = mines.ui.current.border
local function sync(path) return fmt('%s/notes/%s', fn.expand '$SYNC_DIR', path) end

return {
  { 'itchyny/calendar.vim', cmd = 'Calendar' },
  { 'dhruvasagar/vim-table-mode', ft = { 'markdown', 'org', 'norg' } },
  {
    'lukas-reineke/headlines.nvim',
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    config = function()
      require('headlines').setup {
        org = { headline_highlights = false },
      }
    end,
  },
  {
    'vhyrro/neorg',
    ft = 'norg',
    build = ':Neorg sync-parsers',
    dependencies = { 'vhyrro/neorg-telescope' },
    opts = {
      configure_parsers = true,
      load = {
        ['core.defaults'] = {},
        ['core.integrations.telescope'] = {},
        ['core.keybinds'] = {
          config = {
            default_keybinds = true,
            neorg_leader = '<localleader>',
            hook = function(keybinds)
              keybinds.unmap('norg', 'n', '<C-s>')
              keybinds.map_event('norg', 'n', '<C-x>', 'core.integrations.telescope.find_linkable')
            end,
          },
        },
        ['core.completion'] = { config = { engine = 'nvim-cmp' } },
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = sync 'neorg/notes/',
              dotfiles = fn.expand '$DOTFILES/neorg/',
            },
          },
        },
      },
    },
  },
  {
    'nvim-orgmode/orgmode',
    keys = { '<leader>oa', '<leader>oc' },
    dependencies = {
      {
        'akinsho/org-bullets.nvim',
        opts = {
          symbols = {
            checkboxes = { todo = { '⛌', 'OrgTODO' } },
          },
        },
      },
    },
    opts = {
      ui = {
        menu = {
          handler = function(data)
            local items = vim.tbl_filter(function(i) return i.key and i.label:lower() ~= 'quit' end, data.items)
            ui.select(items, {
              prompt = data.prompt,
              kind = 'orgmode',
              format_item = function(item) return fmt('%s → %s', item.key, item.label) end,
            }, function(choice)
              if not choice then return end
              if choice.action then choice.action() end
            end)
          end,
        },
      },
      org_agenda_files = { sync 'org/**/*' },
      org_default_notes_file = sync 'org/refile.org',
      org_todo_keywords = { 'TODO(t)', 'WAITING', 'IN-PROGRESS', '|', 'DONE(d)', 'CANCELLED' },
      org_todo_keyword_faces = {
        ['IN-PROGRESS'] = ':foreground royalblue :weight bold',
        ['CANCELLED'] = ':foreground darkred :weight bold',
      },
      org_hide_leading_stars = true,
      org_agenda_skip_scheduled_if_done = true,
      org_agenda_skip_deadline_if_done = true,
      org_agenda_templates = {
        t = { description = 'Task', template = '* TODO %?\n %u' },
        l = { description = 'Link', template = '* %?\n%a' },
        n = { description = 'Note', template = '* %?\n', target = sync 'org/notes.org' },
        p = {
          description = 'Project Todo',
          template = '* TODO %? \nSCHEDULED: %t',
          target = sync 'org/projects.org',
        },
      },
      win_border = border,
      mappings = { org = { org_global_cycle = '<leader><S-TAB>' } },
      notifications = {
        enabled = true,
        repeater_reminder_time = false,
        deadline_warning_reminder_time = true,
        reminder_time = 10,
        deadline_reminder = true,
        scheduled_reminder = true,
      },
    },
  },
}

