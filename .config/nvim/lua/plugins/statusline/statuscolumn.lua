local fn, v, api = vim.fn, vim.v, vim.api

return {
  static = {
    ---@return {name:string, text:string, texthl:string}[]
    get_signs = function()
      local buf = fn.expand '%'
      return vim.tbl_map(
        function(sign) return fn.sign_getdefined(sign.name)[1] end,
        fn.sign_getplaced(buf, { group = '*', lnum = v.lnum })[1].signs
      )
    end,

    resolve = function(self, name)
      for pat, cb in pairs(self.handlers) do
        if name:match(pat) then return cb end
      end
    end,

    handlers = {
      ['GitSigns.*'] = function(args) require('gitsigns').preview_hunk_inline() end,
      ['Dap.*'] = function(args) require('dap').toggle_breakpoint() end,
      ['Diagnostic.*'] = function(args) vim.diagnostic.open_float() end,
    },
  },
  {
    provider = '%s',
    on_click = {
      callback = function(self, ...)
        local mousepos = fn.getmousepos()
        api.nvim_win_set_cursor(0, { mousepos.line, mousepos.column })
        local sign_at_cursor = fn.screenstring(mousepos.screenrow, mousepos.screencol)
        if sign_at_cursor ~= '' then
          local args = {
            mousepos = mousepos,
          }
          local signs = fn.sign_getdefined()
          for _, sign in ipairs(signs) do
            local glyph = sign.text:gsub(' ', '')
            if sign_at_cursor == glyph then
              vim.defer_fn(function() self:resolve(sign.name)(args) end, 10)
              return
            end
          end
        end
      end,
      name = 'heirline_signcol_callback',
      update = true,
    },
  },
  { provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}" },
  { provider = "%{% &fdc ? '%C ' : '' %}" },
}
