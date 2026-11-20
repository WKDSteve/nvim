-- Feature sheet: `:MyGit hooks repo <name>` installs the git hooks into one repo under $REPOS_DIR, `:MyGit hooks
-- status` shows the hooks of every repo there (lua/bindings/usrcmds/git_hooks/init.lua), typed in the installed config.
-- Never the real repos: the child's $REPOS_DIR is a temp folder with two fixture repos, `alpha` and `beta`, a linked
-- worktree of `alpha` (its `.git` is a file, so the status asks git for the common folder). The install runs the
-- config's scripts/git-hooks/install.sh through the real bash (Git for Windows on Windows); the sheet stops before it
-- when $REPOS_DIR is not the fixture. On CI and without an installed config: a skip.
return {
  id = "nvim-config.mygit-hooks",
  feature = "nvim-config.git-hooks",
  title = "nvim-config: :MyGit hooks repo installs the hooks into a fixture repo, :MyGit hooks status shows them",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':MyGit') == 2", timeout = 30000, note = ":MyGit is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        _G.BASE = H.tmpdir() .. "/repos"
        local alpha = H.repo(BASE .. "/alpha")
        H.git(alpha, { "worktree", "add", "-q", "-b", "beta", BASE .. "/beta" })
        vim.env.REPOS_DIR = BASE
        _G.HOOK = function(name)
          return vim.fn.filereadable(BASE .. "/alpha/.git/hooks/" .. name) == 1
        end
      ]],
      note = "$REPOS_DIR is a temp folder: alpha, and beta as a worktree of alpha",
    },
    {
      expect = "vim.fs.normalize(vim.env.REPOS_DIR) == BASE and not HOOK('commit-msg')",
      note = "only the fixture is touched, and it has no hook yet",
    },
    { keys = ":MyGit hooks repo alpha<CR>" },
    {
      wait = "H.heard('Git hooks: ')",
      timeout = 30000,
      note = "the install ran and reports how many hooks it installed",
    },
    {
      expect = "HOOK('pre-commit') and HOOK('commit-msg')",
      note = "alpha has the pre-commit and commit-msg hooks",
    },
    { keys = ":MyGit hooks status<CR>" },
    {
      wait = "H.heard('alpha') and H.heard('beta')",
      timeout = 20000,
      note = "the status names both repos",
    },
    {
      expect = "H.heard('[ok ] alpha') and H.heard('[ok ] beta')",
      note = "alpha is ok, and so is beta through its worktree's common folder",
    },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  judge = {
    "The status lines read well: state in brackets, the repo, what is missing",
  },
  manual = {
    "Once in a real session: :MyGit hooks status over the real $REPOS_DIR lists every repo without a long wait",
  },
}
