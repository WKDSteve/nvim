-- Feature sheet: `:MyPlugins clone <dir> --only=<name>` clones a listed plugin that is missing in `<dir>`
-- (lua/bindings/usrcmds/plugin_repos/init.lua, `ops.clone_one`: `git clone https://github.com/<owner>/<repo>.git`),
-- typed in the installed config. Never the network: the child's git gets `url.<fixture>.insteadOf =
-- https://github.com/` through `GIT_CONFIG_COUNT`/`GIT_CONFIG_KEY_0`/`GIT_CONFIG_VALUE_0`, so the clone reads a bare
-- fixture repository in a temp folder; `<dir>` is another temp folder. git runs for real. On CI and without an
-- installed config: a skip.
return {
  id = "nvim-config.myplugins-clone",
  feature = "nvim-config.myplugins-clone",
  title = "nvim-config: :MyPlugins clone fetches a missing listed plugin (from a local stand-in for GitHub)",
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
        local entry = assert(require("plugins.personal.core.list").read())[1]
        _G.NAME = entry.name
        local root = H.tmpdir()
        local hub = root .. "/github"
        local src = H.repo(root .. "/src", { ["README.md"] = "the fixture of " .. entry.repo .. "\n" })
        vim.fn.mkdir(vim.fs.dirname(hub .. "/" .. entry.repo), "p")
        H.git(root, { "clone", "-q", "--bare", src, hub .. "/" .. entry.repo .. ".git" })
        _G.BASE = H.tmpdir() .. "/repos"
        vim.fn.mkdir(BASE, "p")
        vim.env.GIT_CONFIG_COUNT = "1"
        vim.env.GIT_CONFIG_KEY_0 = "url.file:///" .. hub:gsub("^/", "") .. "/.insteadOf"
        vim.env.GIT_CONFIG_VALUE_0 = "https://github.com/"
      ]],
      note = "GitHub is a bare fixture repo in a temp folder (git's insteadOf), the target folder is empty",
    },
    {
      expect = "vim.fn.isdirectory(BASE .. '/' .. NAME) == 0",
      note = "the plugin is missing in the target folder",
    },
    {
      lua = [[vim.api.nvim_input((":MyPlugins clone %s --only=%s<CR>"):format(BASE, NAME))]],
    },
    { wait = "H.heard('Cloned 1')", timeout = 60000, note = "the clone is reported" },
    {
      expect = "vim.fn.readfile(BASE .. '/' .. NAME .. '/README.md')[1]:find('the fixture of', 1, true) ~= nil",
      note = "the checkout is the fixture's (no network was asked)",
    },
    {
      lua = [[vim.api.nvim_input((":MyPlugins clone %s --only=%s<CR>"):format(BASE, NAME))]],
    },
    {
      wait = "H.heard('skipped 1 already present')",
      timeout = 30000,
      note = "a second clone leaves the present checkout alone",
    },
    {
      lua = "vim.env.GIT_CONFIG_COUNT = nil; vim.env.GIT_CONFIG_KEY_0 = nil; vim.env.GIT_CONFIG_VALUE_0 = nil",
    },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  manual = {
    "Once on a fresh machine: :MyPlugins clone fills $REPOS_DIR from GitHub; a second run skips every present checkout",
  },
}
