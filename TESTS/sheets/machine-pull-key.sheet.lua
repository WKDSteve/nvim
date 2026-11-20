-- Feature sheet: `<CR>` on a repo line of `:MyPlugins machine` fast-forwards that repo (lua/bindings/usrcmds/
-- plugin_repos/machine.lua), in the installed config. The report is real (the module's own render and keys); only
-- what it shows is made up, as in machine-build-key.sheet.lua: the check's argv (`build_cmd`) is a headless nvim that
-- prints one line of the script's `-Json` shape, a repo that is behind and pullable. The repo is a fixture checkout
-- whose `origin` is a bare repository next to it, one commit ahead; `git pull --ff-only` runs for real. The re-check
-- after the pull is counted, not run, so the real `sync-machine.ps1` never starts. On CI and without an installed
-- config: a skip.
return {
  id = "nvim-config.machine-pull-key",
  feature = "nvim-config.myplugins-machine",
  title = "nvim-config: <CR> in :MyPlugins machine pulls the repo under the cursor, then checks again",
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
        local machine = require("bindings.usrcmds.plugin_repos.machine")
        local root = H.tmpdir()
        _G.REPO = H.repo(root .. "/sheet-pull")
        H.remote_ahead(REPO)
        local items = {
          {
            Repo = "sheet-pull", Path = REPO, State = "behind", Note = "", Behind = 1, Ahead = 0, Dirty = 0,
            Pullable = true, Build = "ok", Hint = "", Command = vim.NIL,
          },
        }
        local json = root .. "/report.json"
        vim.fn.writefile({ vim.json.encode(items) }, json)
        local printer = root .. "/print.lua"
        vim.fn.writefile({ ("io.stdout:write(io.open(%q):read('*a'))"):format(json) }, printer)
        _G.REAL = { build_cmd = machine.build_cmd, run = machine.run }
        machine.build_cmd = function()
          return { vim.v.progpath, "--clean", "--headless", "-l", printer }
        end
        _G.LINE = function(repo)
          for i, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
            if l:find(repo, 1, true) then
              return i
            end
          end
        end
      ]],
      note = "a made-up report: one fixture repo, behind its local origin by one commit",
    },
    { lua = "require('bindings.usrcmds.plugin_repos.machine').run({})" },
    {
      wait = "vim.bo.filetype == 'myplugins-machine' and LINE('sheet-pull') ~= nil",
      timeout = 30000,
      note = "the report shows the repo",
    },
    {
      lua = [[
        -- From here on a re-check is counted, not run: the real script must never start.
        _G.RECHECKS = 0
        require("bindings.usrcmds.plugin_repos.machine").run = function()
          _G.RECHECKS = _G.RECHECKS + 1
        end
        vim.api.nvim_win_set_cursor(0, { LINE("sheet-pull"), 0 })
      ]],
    },
    { keys = "<CR>" },
    { wait = "H.heard('Pulled 1 repo(s).')", timeout = 30000, note = "the pull is reported" },
    {
      expect = "vim.fn.filereadable(REPO .. '/NEW.md') == 1",
      note = "git pull --ff-only took the remote's commit",
    },
    { wait = "RECHECKS == 1", timeout = 5000, note = "and the report checks again, once" },
    {
      lua = [[
        local machine = require("bindings.usrcmds.plugin_repos.machine")
        machine.build_cmd, machine.run = REAL.build_cmd, REAL.run
      ]],
    },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  manual = {
    "Once in a real session after pushing from another machine: <CR> on a behind line pulls it and the line turns current",
  },
}
