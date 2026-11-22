-- Live check: `B` in `:MyPlugins machine` (lua/bindings/usrcmds/plugin_repos/machine.lua) in the installed config,
-- without a real build. The report is real (the module's own render, keys and terminal.nvim float); only what it shows
-- is made up: the check's argv (`build_cmd`) is a headless nvim that prints two lines of the script's `-Json` shape, a
-- repo whose `Command` writes a file in its own (temp) folder after a short wait, and one without a command (a desktop
-- app: "run its setup.exe"). The re-check after the float is closed is counted, not run, so the real
-- `sync-machine.ps1` never starts. On CI and without an installed config: a skip; on the workstation `B` is refused
-- by machine_guard and the sheet does not run there (workstation rule of testing.nvim).
return {
  id = "nvim-config.machine-build-key",
  feature = "nvim-config.myplugins-machine",
  title = "nvim-config: B in :MyPlugins machine builds in a float in the repo's folder, re-checks after q",
  task = "nvim-config/live-check-structure-jump-and-bindings-check",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    {
      lua = "_G.SheetErrors = dofile(vim.fn.getcwd() .. '/TESTS/sheets/fixtures/errors.lua')",
      note = "the no-error check, loaded while the cwd is the project root",
    },
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':MyPlugins') == 2", timeout = 30000, note = ":MyPlugins is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        local machine = require("bindings.usrcmds.plugin_repos.machine")
        local root = vim.fs.normalize(vim.fn.tempname())
        _G.__repo = root .. "/sheet-build"
        vim.fn.mkdir(_G.__repo, "p")
        vim.fn.mkdir(root .. "/sheet-setup", "p")
        local items = {
          {
            Repo = "sheet-build", Path = _G.__repo, State = "ok", Note = "", Behind = 0, Ahead = 0, Dirty = 0,
            Pullable = false, Build = "stale", Hint = "build it",
            Command = "Start-Sleep -Milliseconds 2500; Set-Content -Path built.txt -Value ok; "
              .. "Write-Output 'sheet build ran'",
          },
          {
            Repo = "sheet-setup", Path = root .. "/sheet-setup", State = "ok", Note = "", Behind = 0, Ahead = 0,
            Dirty = 0, Pullable = false, Build = "missing", Hint = "run its setup.exe", Command = vim.NIL,
          },
        }
        local json = root .. "/report.json"
        vim.fn.writefile({ vim.json.encode(items) }, json)
        local printer = root .. "/print.lua"
        vim.fn.writefile({ ("io.stdout:write(io.open(%q):read('*a'))"):format(json) }, printer)
        _G.__real = { build_cmd = machine.build_cmd, run = machine.run }
        -- Did the module say `text`? This config shows lib.nvim's messages as popups (not in :messages); their
        -- history has them, and vim.notify's when popups are off.
        _G.__heard = function(text)
          local said = {}
          local ok, popup = pcall(require, "lib.nvim.notify.popup")
          for _, e in ipairs(ok and popup.history() or {}) do
            said[#said + 1] = tostring(e.message)
          end
          said[#said + 1] = vim.fn.execute("messages")
          return table.concat(said, " "):gsub("%s+", " "):find(text, 1, true) ~= nil
        end
        machine.build_cmd = function()
          return { vim.v.progpath, "--clean", "--headless", "-l", printer }
        end
        -- Report the lines of the report buffer, and the float terminal of a build with its text.
        _G.__report_line = function(repo)
          for i, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
            if l:find(repo, 1, true) then
              return i
            end
          end
        end
        _G.__build_float = function()
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            local b = vim.api.nvim_win_get_buf(w)
            if vim.api.nvim_win_get_config(w).relative ~= "" and vim.bo[b].buftype == "terminal" then
              return w, table.concat(vim.api.nvim_buf_get_lines(b, 0, -1, false), "\n")
            end
          end
        end
        _G.__float_text = function()
          local _, text = _G.__build_float()
          return text or ""
        end
        _G.__builds = function()
          local n = 0
          for _, name in ipairs(require("terminal").names(true)) do
            n = n + (name == "build:sheet-build" and 1 or 0)
          end
          return n
        end
      ]],
      note = "a made-up report: one repo with a build command, one without",
    },
    { lua = "require('bindings.usrcmds.plugin_repos.machine').run({})" },
    {
      wait = "vim.bo.filetype == 'myplugins-machine' and _G.__report_line('sheet-build') ~= nil",
      timeout = 30000,
      note = "the report shows both repos",
    },
    {
      lua = [[
        -- From here on a re-check is counted, not run: the real script must never start.
        _G.__rechecks = 0
        require("bindings.usrcmds.plugin_repos.machine").run = function()
          _G.__rechecks = _G.__rechecks + 1
        end
        vim.api.nvim_win_set_cursor(0, { _G.__report_line("sheet-setup"), 0 })
      ]],
    },
    -- A desktop app has no build command: B says what to do instead and starts nothing.
    { keys = "B" },
    {
      expect = "_G.__build_float() == nil and _G.__heard('no build command - run its setup.exe')",
      note = "B on a line without a command: the hint, no float",
    },
    { lua = "vim.api.nvim_win_set_cursor(0, { _G.__report_line('sheet-build'), 0 })" },
    { keys = "B" },
    { wait = "_G.__build_float() ~= nil", timeout = 15000, note = "B opens a float terminal" },
    {
      expect = "_G.__builds() == 1",
      note = ":Terminal list has build:sheet-build (terminal.nvim's registry)",
    },
    -- A second B while the build runs starts nothing (the report window is the previous one).
    { lua = "vim.cmd.wincmd('p')" },
    { wait = "vim.bo.filetype == 'myplugins-machine'", timeout = 5000 },
    { keys = "B" },
    {
      expect = "_G.__builds() == 1 and _G.__heard('a build is already running here')",
      note = "a second B during the build: refused, still one terminal",
    },
    {
      wait = "_G.__float_text():find('sheet build ran', 1, true) ~= nil",
      timeout = 30000,
      note = "the build ran and its output stays in the float",
    },
    {
      wait = "vim.fn.filereadable(_G.__repo .. '/built.txt') == 1",
      timeout = 5000,
      note = "it ran in the repo's folder (cwd), where it wrote built.txt",
    },
    {
      wait = "_G.__heard('build done - close the window to re-check')",
      timeout = 15000,
      note = "the end of the build is reported",
    },
    {
      expect = "_G.__build_float() ~= nil and _G.__rechecks == 0",
      note = "the float stays open, no re-check yet",
    },
    -- q closes the float in normal mode (after <C-\><C-n> out of terminal mode).
    { lua = "vim.api.nvim_set_current_win((_G.__build_float()))" },
    { input = "<C-\\><C-n>" },
    {
      wait = "vim.api.nvim_get_mode().mode:sub(1, 1) == 'n'",
      timeout = 5000,
      note = "normal mode (nt)",
    },
    { keys = "q" },
    { wait = "_G.__build_float() == nil", timeout = 5000, note = "q closes the float" },
    {
      wait = "_G.__rechecks == 1",
      timeout = 5000,
      note = "only now the report checks again, once",
    },
    {
      lua = [[
        local machine = require("bindings.usrcmds.plugin_repos.machine")
        machine.build_cmd, machine.run = _G.__real.build_cmd, _G.__real.run

      ]],
    },
    {
      expect = "SheetErrors.none()",
      note = "no error message on the way",
    },
  },
  judge = {
    "The float's title and output make clear which repo is building and that the build has ended",
  },
  manual = {
    "Once, on a real line with build stale/missing (mdview.nvim or ai-desktop): B builds for real, q closes the float, the report checks again and the line is current",
  },
}
