local function commit_summary(init)
  local notes = {
    f = 'feat',
    x = 'fix',
    fi = 'fix',
    r = 'refactor',
    ref = 'refactor',
    p = 'performance',
    perf = 'performance',
    c = 'chore',
  }

  init = init:lower()
  init = notes[init] or init
  if vim.g.gitsigns_head then
    vim.g.branch = vim.g.gitsigns_head
  end

  local feat_pattern = { '^([fF][eE][rR][-/]%d+)[-/]' }

  if vim.g.branch then
    for _, pattern in ipairs(feat_pattern) do
      local feature = vim.g.branch:match(pattern)
      if feature then
        init = init .. ('(%s)'):format(feature)
        break
      end
    end
  end

  return init .. ': '
end

-- stylua: ignore
return {
    snippet('f',  { p(commit_summary, 'feat'),     i(1), t{'', '', ''}, i(2) }),
    snippet('x',  { p(commit_summary, 'fix'),      i(1), t{'', '', ''}, i(2) }),
    snippet('r',  { p(commit_summary, 'refactor'), i(1), t{'', '', ''}, i(2) }),
    snippet('c',  { p(commit_summary, 'chore'),    i(1), t{'', '', ''}, i(2) }),
    snippet('d',  { p(commit_summary, 'docs'),     i(1), t{'', '', ''}, i(2) }),
    snippet('p',  { p(commit_summary, 'perf'),     i(1), t{'', '', ''}, i(2) }),
    snippet('t',  { p(commit_summary, 'test'),     i(1), t{'', '', ''}, i(2) }),
    snippet('ci', { p(commit_summary, 'ci'),       i(1), t{'', '', ''}, i(2) }),
    snippet('link', { t{'['}, i(1, 'description'), t{'](https://'}, i(2, {'url'}), t{')'}, }),
    snippet('url', { t{'['}, i(1, 'description'), t{'](https://'}, i(2, {'url'}), t{')'}, }),
}
