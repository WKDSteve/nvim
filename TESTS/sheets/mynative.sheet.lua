-- Feature sheet: `:MyNative list`, `:MyNative build <name>` and `:MyNative deps <name>` (lua/bindings/usrcmds/
-- native_repos/), typed in the installed config, on a fixture: the child's $REPOS_DIR is a temp folder with one
-- checkout `tasks-desktop` (a git repo with its `crates/` and a `scripts/build-install.ps1` that writes a file
-- instead of building). What runs for real: git for the list's state, the tool probes (vswhere, cargo, ...: they only
-- ask), PowerShell running the fixture's build script in the checkout. The one install `deps` starts goes to a
-- recording `winget` stand-in (fixtures/stand_ins.lua): the sheet makes the tool `rust` read as missing, so the install
-- path runs without installing anything. Never the real repos (the sheet stops before the first command when $REPOS_DIR
-- is not the fixture). Windows only (the native apps build there); on CI and without an installed config: a skip.
return {
  id = "nvim-config.mynative",
  feature = "nvim-config.native-repos",
  title = "nvim-config: :MyNative list shows a fixture checkout, build runs its build script, deps installs a tool",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  requires = {
    { lua = "vim.fn.has('win32') == 1", reason = "the native apps build on Windows only" },
  },
  fakes = { "winget" },
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':MyNative') == 2", timeout = 30000, note = ":MyNative is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        H.runtime("stand_ins", vim.env.TESTING_FAKES, { "winget" })
        _G.BASE = H.tmpdir() .. "/repos"
        _G.APP = H.repo(BASE .. "/tasks-desktop", {
          ["crates/hub/src/main.rs"] = "fn main() {}\n",
          ["Cargo.lock"] = "# fixture\n",
          ["scripts/build-install.ps1"] = "param([switch]$BuildOnly)\n"
            .. "Set-Content -Path built.txt -Value $BuildOnly.IsPresent\n"
            .. "Write-Output 'fixture build ran'\n",
        })
        vim.env.REPOS_DIR = BASE
        _G.QF = function()
          return table.concat(vim.tbl_map(function(i) return i.text end, vim.fn.getqflist()), "\n")
        end
      ]],
      note = "$REPOS_DIR is a temp folder with a fixture checkout of tasks-desktop",
    },
    {
      expect = "vim.fs.normalize(vim.env.REPOS_DIR) == BASE",
      note = "only the fixture is touched",
    },
    { keys = ":MyNative list<CR>" },
    {
      wait = "H.heard('tasks-desktop')",
      timeout = 20000,
      note = "the list names the cloned app, its git state and that its build is missing",
    },
    { expect = "H.heard('missing')", note = "no artifact yet: the build is missing" },
    { keys = ":MyNative build tasks-desktop<CR>" },
    {
      wait = "H.heard('Build done: tasks-desktop') or H.heard('Build FAILED')",
      timeout = 60000,
      note = "the build ran (after the tool check)",
    },
    {
      expect = "vim.fn.filereadable(APP .. '/built.txt') == 1 and QF():find('fixture build ran', 1, true) ~= nil",
      note = "the fixture's build script ran in the checkout, its output is in the quickfix list",
    },
    {
      lua = [[
        local toolchain = require("bindings.usrcmds.native_repos.toolchain")
        _G.RUST = toolchain.get("rust")
        _G.RUST_CHECK = RUST.check
        RUST.check = function() return false end
      ]],
      note = "from here on the tool rust reads as missing",
    },
    { keys = ":MyNative deps tasks-desktop<CR>" },
    {
      wait = "#H.calls('winget') >= 1",
      timeout = 60000,
      note = "deps started the install of rustup",
    },
    {
      expect = "vim.tbl_contains(H.calls('winget')[1].argv, 'Rustlang.Rustup')",
      note = "winget install ... Rustlang.Rustup --scope user",
    },
    {
      wait = "H.heard('rust') and H.heard('MISSING')",
      timeout = 60000,
      note = "rust is still missing after the stand-in's install, and the summary says so",
    },
    { lua = "RUST.check = RUST_CHECK" },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  judge = {
    "The list and the summaries say per app and per tool what is the matter, in a few lines",
  },
  manual = {
    "Once on STEVESPC: :MyNative build on a real checkout with a stale build (tasks-desktop) builds it, the quickfix list has the cargo output",
  },
}
