-- Feature sheet: `:MyPlugins runner status` asks GitHub (`gh api repos/<owner>/<repo>/actions/runners`) whether the
-- self-hosted runner of each repo is online, `:MyPlugins runner autostart status` reads the logon task
-- (lua/bindings/usrcmds/plugin_repos/runner.lua), typed in the installed config. Never the network: `gh` is a
-- recording stand-in (fixtures/stand_ins.lua) that answers nothing, so every runner reads as not registered. The
-- autostart status runs PowerShell for real; it only reads the scheduled task (or says there is none). Starting and
-- stopping the real runners is a hand run (catalog: nvim-config.myplugins-runner-start). Windows only; on CI and
-- without an installed config: a skip.
return {
  id = "nvim-config.runner-status",
  feature = "nvim-config.myplugins-runner",
  title = "nvim-config: :MyPlugins runner status asks gh once per repo, runner autostart status reads the logon task",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  requires = {
    {
      lua = "vim.fn.has('win32') == 1",
      reason = "the runners and their logon task are Windows only",
    },
  },
  fakes = { "gh" },
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':MyPlugins') == 2", timeout = 30000, note = ":MyPlugins is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        H.runtime("stand_ins", vim.env.TESTING_FAKES, { "gh" })
        _G.REPOS = require("bindings.usrcmds.plugin_repos.runner").REPOS
        -- Only the `gh api` calls: the same stand-in also catches other plugins of the config that start gh
        -- (github_stats.nvim's clone of its data repository), which keeps them off the network too.
        _G.API = function()
          return vim.tbl_filter(function(c)
            return c.argv[1] == "api"
          end, H.calls("gh"))
        end
        -- The calls run at the same time, and the Windows stand-in loses log lines of simultaneous calls (testing.nvim
        -- task fake-programs-gleichzeitige-aufrufe-unter-windows-verlieren): the message that names every repo is the
        -- proof that each one was asked, the log only shows the shape of a call.
        _G.ALL_NAMED = function()
          for _, name in ipairs(REPOS) do
            if not H.heard(("%-14s no runner registered"):format(name):gsub("%s+", " ")) then
              return false
            end
          end
          return true
        end
      ]],
      note = "gh is a stand-in that answers nothing",
    },
    { keys = ":MyPlugins runner status<CR>" },
    {
      wait = "ALL_NAMED()",
      timeout = 60000,
      note = "one message names every repo with a runner (the stand-in registers none)",
    },
    {
      expect = [[#API() >= 1 and API()[1].argv[2]:find("/actions/runners$") ~= nil]],
      note = "gh api repos/<owner>/<repo>/actions/runners",
    },
    { keys = ":MyPlugins runner autostart status<CR>" },
    {
      wait = "H.heard('autostart status:') or H.heard('autostart: no scheduled task')",
      timeout = 30000,
      note = "the logon task was read (its triggers and state, or that there is none)",
    },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  manual = {
    "Once on STEVESPC: :MyPlugins runner status with the real gh lists every runner as online (after runners.ps1 ensure)",
  },
}
