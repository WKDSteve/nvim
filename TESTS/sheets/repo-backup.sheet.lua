-- Feature sheet: the weekly backup of the repos without a remote (lua/config/repo_backup.lua), which init.lua starts in
-- its UIReady phase `repo_backup`: `git bundle create` into a temp file, `git bundle verify`, then the rename over the
-- last backup. The sheet calls what that phase calls, on a fixture: the child's $REPOS_DIR is a temp folder with a
-- fixture repo named like the one on the list (WKDBook-Tricentis), $REPO_BACKUP_DIR another temp folder. Never the
-- real repo or the real backup folder (the sheet stops before the run when either is not the fixture). git runs for
-- real. On CI and without an installed config: a skip.
return {
  id = "nvim-config.repo-backup",
  feature = "nvim-config.repo-backup",
  title = "nvim-config: the weekly backup bundles a fixture repo, verifies the bundle and keeps it",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  sizes = { { rows = 24, cols = 110 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        _G.BACKUP = require("config.repo_backup")
        local root = H.tmpdir()
        _G.BASE = root .. "/repos"
        for _, name in ipairs(BACKUP.REPOS) do
          H.repo(BASE .. "/" .. name)
        end
        _G.OUT = root .. "/backup"
        vim.env.REPOS_DIR = BASE
        vim.env.REPO_BACKUP_DIR = OUT
        _G.BUNDLE = OUT .. "/" .. BACKUP.REPOS[1] .. ".bundle"
      ]],
      note = "$REPOS_DIR has a fixture repo per listed name, $REPO_BACKUP_DIR is empty",
    },
    {
      expect = [[vim.fs.normalize(vim.env.REPOS_DIR) == BASE and vim.fs.normalize(BACKUP.dir()) == OUT
        and vim.fn.filereadable(BUNDLE) == 0]],
      note = "only the fixture is touched, and there is no backup yet",
    },
    { lua = "_G.STARTED = BACKUP.run()", note = "what the UIReady phase repo_backup runs" },
    { expect = "STARTED == #BACKUP.REPOS", note = "one backup per listed repo is due and started" },
    {
      wait = "H.heard('weekly backup written')",
      timeout = 60000,
      note = "bundle created, verified and renamed",
    },
    {
      expect = "vim.fn.filereadable(BUNDLE) == 1 and #vim.fn.glob(OUT .. '/*.tmp-*', true, true) == 0",
      note = "the bundle is there, no temp file is left",
    },
    { lua = "_G.AGAIN = BACKUP.run()" },
    { expect = "AGAIN == 0", note = "a second start in the same week starts nothing" },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  manual = {
    "Once a week on STEVESPC: the first start says `WKDBook-Tricentis: weekly backup written` and the bundle restores with git clone",
  },
}
