-- Feature sheet: `:MyPlugins fetch|pull|update <dir> --only=<name>` (lua/bindings/usrcmds/plugin_repos/init.lua and
-- ops.lua, through lib.nvim.git), typed in the installed config. Never the real checkouts or the network: `<dir>` is a
-- temp folder with a fixture checkout named like the first plugin of the list, whose `origin` is a bare repository
-- next to it, one commit ahead. git runs for real. On CI and without an installed config: a skip.
return {
  id = "nvim-config.myplugins-git",
  feature = "nvim-config.myplugins-git",
  title = "nvim-config: :MyPlugins fetch, pull and update bring a fixture checkout level with its local origin",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':MyPlugins') == 2", timeout = 30000, note = ":MyPlugins is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        _G.NAME = assert(require("plugins.personal.core.list").read())[1].name
        _G.BASE = H.tmpdir() .. "/repos"
        _G.REPO = H.repo(BASE .. "/" .. NAME)
        _G.BARE = H.remote_ahead(REPO)
        _G.TYPE = function(verb)
          vim.api.nvim_input((":MyPlugins %s %s --only=%s<CR>"):format(verb, BASE, NAME))
        end
        _G.BEHIND = function()
          return vim.trim(H.git(REPO, { "rev-list", "--count", "HEAD..origin/main" }))
        end
      ]],
      note = "a fixture checkout of the first listed plugin; its local origin has one commit more",
    },
    { lua = "TYPE('fetch')" },
    { wait = "H.heard('fetched')", timeout = 30000, note = "fetch reports the repository" },
    { expect = "BEHIND() == '1'", note = "the fetch brought origin/main one commit ahead" },
    { lua = "TYPE('pull')" },
    { wait = "H.heard('pulled')", timeout = 30000, note = "pull reports the repository" },
    {
      expect = "vim.fn.filereadable(REPO .. '/NEW.md') == 1 and BEHIND() == '0'",
      note = "the pull fast-forwarded: the remote's file is there",
    },
    {
      lua = [[
        local other = REPO .. ".other"
        H.write(other .. "/NEWER.md", "again\n")
        H.git(other, { "add", "NEWER.md" })
        H.git(other, { "commit", "-q", "-m", "second remote commit" })
        H.git(other, { "push", "-q", "origin", "main" })
      ]],
      note = "the origin gets one more commit",
    },
    { lua = "TYPE('update')" },
    { wait = "H.heard('updated')", timeout = 30000, note = "update reports the repository" },
    {
      expect = "vim.fn.filereadable(REPO .. '/NEWER.md') == 1",
      note = "update = fetch + fast-forward: the newer file is there",
    },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  judge = {
    "The summaries say how many repositories moved and how many were already up to date",
  },
  manual = {
    "Once on a second machine: :MyPlugins update brings the checkouts level with commits pushed from the first",
  },
}
