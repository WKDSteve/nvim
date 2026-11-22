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
        -- The calls run at the same time, and the Windows stand-in loses log records of simultaneous calls
        -- (testing.nvim task fake-programs-gleichzeitige-aufrufe-unter-windows-verlieren: 0 to 4 of 11 were left).
        -- So the calls are counted where the config starts them (the list stand_ins returns), not in the stand-in's
        -- log.
        _G.STARTED = H.runtime("stand_ins", vim.env.TESTING_FAKES, { "gh" })
        _G.REPOS = require("bindings.usrcmds.plugin_repos.runner").REPOS
        -- Only the `gh api .../actions/runners` calls: the same stand-in also catches other plugins of the config that
        -- start gh (github_stats.nvim's clone of its data repository), which keeps them off the network too.
        _G.API = function()
          return vim.tbl_filter(function(c)
            return c.program == "gh" and c.argv[1] == "api" and tostring(c.argv[2]):find("/actions/runners$") ~= nil
          end, STARTED)
        end
        -- Each repo of REPOS asked exactly once, for its own runners, and no other runner query.
        _G.EACH_ASKED_ONCE = function()
          local api = API()
          if #api ~= #REPOS then
            return false
          end
          for _, name in ipairs(REPOS) do
            local want = "^repos/[^/]+/" .. vim.pesc(name) .. "/actions/runners$"
            local n = 0
            for _, c in ipairs(api) do
              n = n + ((#c.argv == 2 and tostring(c.argv[2]):find(want)) and 1 or 0)
            end
            if n ~= 1 then
              return false
            end
          end
          return true
        end
        -- The stand-in answers nothing, so a message naming every repo as not registered shows that each call ran
        -- through the stand-in and its answer reached the report.
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
      expect = "EACH_ASKED_ONCE()",
      note = "gh api repos/<owner>/<repo>/actions/runners, once for each repo",
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
