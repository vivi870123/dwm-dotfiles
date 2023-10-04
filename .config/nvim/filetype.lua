if not vim.filetype then return end

vim.filetype.add {
  extension = {
    lock = 'yaml',
  },
  filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
    ['.gitignore'] = 'conf',
    ['.zimrc'] = 'dosini',
    ['launch.json'] = 'jsonc',
    Podfile = 'ruby',
    Brewfile = 'ruby',
  },
  pattern = {
    ['.*/%.vscode/.*%.json'] = 'json5', -- These json files frequently have comments
    ['.*%.conf'] = 'conf',
    ['.*%.theme'] = 'conf',
    ['.*%.gradle'] = 'groovy',
    ['^.env%..*'] = 'bash',
  },
}
