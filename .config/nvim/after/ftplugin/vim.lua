local opt, fn = vim.opt_local, vim.fn
opt.spell = true

map('n', '<leader>so', function()
  vim.cmd.source '%'
  vim.notify('Sourced ' .. fn.expand '%')
end)
