return {
  'L3MON4D3/LuaSnip',
  lazy = false,
  build = 'make install_jsregexp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  config = function()
    local ls = require 'luasnip'
    local types = require 'luasnip.util.types'
    local extras = require 'luasnip.extras'
    local fmt = require('luasnip.extras.fmt').fmt

    ls.config.set_config {
      updateevents = 'TextChanged,TextChangedI',
      --region_check_events = 'CursorMoved,CursorHold,InsertEnter',
      delete_check_events = 'InsertLeave',
      ext_opts = {
        [types.choiceNode] = { active = { hl_mode = 'combine', virt_text = { { '●', 'Operator' } } } },
        [types.insertNode] = { active = { hl_mode = 'combine', virt_text = { { '●', 'Type' } } } },
      },
      enable_autosnippets = true,
      snip_env = {
        fmt = fmt,
        m = extras.match,
        t = ls.text_node,
        f = ls.function_node,
        c = ls.choice_node,
        d = ls.dynamic_node,
        i = ls.insert_node,
        l = extras.lamda,
        sn = ls.snippet_node,
        rep = extras.rep,
        snippet = ls.snippet,
      },
    }

    -- TODO: Add file watcher to auto reload snippets on changes
    local function load_snippets(ft)
      local runtimepaths = {
        ['lua/snippets/'] = { default_priority = 1000 },
        ['luasnippets/'] = { default_priority = 2000 },
      }

      local ok
      local snip_msg = ''
      ft = ft or vim.opt_local.filetype:get()

      for runtimepath, opts in pairs(runtimepaths) do
        for _, snips in ipairs(vim.api.nvim_get_runtime_file(runtimepath .. 'all.lua', true)) do
          ok, snip_msg = pcall(dofile, snips)
          if not ok then goto fail end
          opts.key = snips
          ls.add_snippets('all', snip_msg, opts)
        end

        for _, snips in ipairs(vim.api.nvim_get_runtime_file(runtimepath .. ft .. '.lua', true)) do
          ok, snip_msg = pcall(dofile, snips)
          if not ok then goto fail end
          opts.key = snips
          ls.add_snippets(ft, snip_msg, opts)
        end
      end

      ::fail::

      return ok, snip_msg
    end

    mines.command(
      'SnippetEdit',
      function(opts) require('luasnip.loaders').edit_snippet_files() end,
      { nargs = '?', complete = 'filetype' }
    )

    mines.command('SnippetUnlink', function() vim.cmd.LuaSnipUnlinkCurrent() end)

    map({ 's', 'i' }, '<m-j>', function()
      if not ls.expand_or_jumpable() then return '<Tab>' end
      ls.expand_or_jump()
    end, { expr = true })

    -- <C-K> is easier to hit but swallows the digraph key
    map({ 's', 'i' }, '<m-k>', function()
      if not ls.jumpable(-1) then return '<S-Tab>' end
      ls.jump(-1)
    end, { expr = true })

    -- <c-l> is selecting within a list of options.
    map({ 's', 'i' }, '<m-l>', function()
      if ls.choice_active() then ls.change_choice(1) end
    end)

    -- if #ls.get_snippets 'all' == 0 then ls.add_snippets('all', require 'snippets.all') end

    require('luasnip.loaders.from_lua').lazy_load()

    -- NOTE: the loader is called twice so it picks up the defaults first then my custom textmate snippets.
    -- see: https://github.com/L3MON4D3/LuaSnip/issues/364
    require('luasnip.loaders.from_vscode').lazy_load()
    -- require('luasnip.loaders.from_vscode').lazy_load({ paths = './snippets/textmate' })

    ls.filetype_extend('typescriptreact', { 'javascript', 'typescript' })
    ls.filetype_extend('dart', { 'flutter' })
    ls.filetype_extend('NeogitCommitMessage', { 'gitcommit' })

    mines.augroup('SnippetsAutoCommands', {
      event = 'Filetype',
      command = function() load_snippets() end,
    }, {
      event = 'ModeChanged',
      pattern = '[is]:n',
      command = function()
        if ls.in_snippet() then return vim.diagnostic.enable() end
      end,
    }, {
      event = 'ModeChanged',
      pattern = '*:s',
      command = function()
        if ls.in_snippet() then return vim.diagnostic.disable() end
      end,
    })
  end,
}
