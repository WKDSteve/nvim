-- Feature sheet: `:MyPlugins sync <dir> --only=<name>` fetches the checkout, finds it behind but blocked by a local
-- change and lists it for triage; `t` in the triage list opens a terminal in the repo (lua/bindings/usrcmds/
-- plugin_repos/sync.lua, ops.lua, sync_dash.lua), typed in the installed config. Never the real checkouts or the
-- network: `<dir>` is a temp folder with a fixture checkout named like the first plugin of the list, whose `origin` is
-- a bare repository next to it, one commit ahead. git and the terminal's shell run for real; the terminal is closed at
-- the end (its job ends with it). The result of the sync is saved below the child's own stdpath("state"). On CI and
-- without an installed config: a skip.
return {
  id = "nvim-config.myplugins-sync",
  feature = "nvim-config.myplugins-sync",
  title = "nvim-config: :MyPlugins sync lists a blocked fixture checkout for triage, t opens a terminal in it",
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
        _G.REPO = H.repo(BASE .. "/" .. NAME, { ["NEW.md"] = "local, not committed\n" })
        H.git(REPO, { "rm", "-q", "--cached", "NEW.md" })
        H.git(REPO, { "commit", "-q", "-m", "drop NEW.md from the index" })
        H.remote_ahead(REPO)
        -- `NEW.md` is untracked here and comes with the remote's commit: the pull is blocked.
        _G.TERM = function()
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[b].buftype == "terminal" and vim.api.nvim_buf_is_loaded(b) then
              return b
            end
          end
        end
        -- The triage list is a snacks.nvim picker (sync_dash.lua); its first row is the fixture repo.
        _G.TRIAGE = function()
          local ok, pickers = pcall(function()
            return Snacks.picker.get()
          end)
          local p = ok and pickers and pickers[1]
          return p ~= nil and #p:items() > 0
        end
      ]],
      note = "a fixture checkout behind its local origin, with an untracked file the pull would overwrite",
    },
    {
      lua = [[vim.api.nvim_input((":MyPlugins sync %s --only=%s<CR>"):format(BASE, NAME))]],
    },
    {
      wait = "TRIAGE()",
      timeout = 60000,
      note = "the fetch ran, the pull is blocked, the triage list is open",
    },
    { input = "<M-t>", note = "t (Alt-t in the list's search field): a terminal in the repo" },
    { wait = "TERM() ~= nil", timeout = 20000, note = "a terminal buffer is open" },
    {
      expect = [[vim.fs.normalize(vim.fn.getcwd(vim.fn.bufwinid(TERM()))):lower():find(NAME:lower(), 1, true) ~= nil
        or vim.api.nvim_buf_get_name(TERM()):lower():find(NAME:lower(), 1, true) ~= nil]],
      note = "it is in the repo's folder",
    },
    {
      lua = "vim.api.nvim_buf_delete(TERM(), { force = true })",
      note = "close the terminal (its shell ends)",
    },
    { wait = "TERM() == nil", timeout = 10000 },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  judge = {
    "The triage list says why the repo was not pulled and what to do about it",
  },
  manual = {
    "Once in a real session: :MyPlugins sync over $REPOS_DIR; a repo with local changes lands in the triage list, t and lazygit work",
  },
}
