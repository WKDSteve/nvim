-- Live check of the :MyPlugins task commands of the bindings checklist (task
-- nvim-config/testblatt-myplugins-tasks-befehle-der-bindings-checkliste): the routes of tasks.nvim as this config
-- mounts them under :MyPlugins, typed in the installed config (`config = "user"`). The handlers are tasks.nvim's and
-- have its own sheet (tasks.nvim TESTS/sheets/vault-and-plan-commands.sheet.lua); this one checks the mounting.
-- Never the real vault: the child is set up on a fixture vault in a temp folder (tasks.nvim's TESTS/fixture.lua), and
-- the sheet stops before the first command when the vault in use is any other (a step that would write goes after
-- that check). The commands run with `ignore_errmsg`: a `silent!` inside sets v:errmsg (E31); an error that is
-- shown is caught by the last step (:messages). On CI and without an installed config the sheet is a skip.
return {
  id = "nvim-config.myplugins-task-commands",
  title = "nvim-config: the :MyPlugins task commands on a fixture vault",
  task = "nvim-config/testblatt-myplugins-tasks-befehle-der-bindings-checkliste",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      wait = "vim.fn.exists(':MyPlugins') == 2",
      timeout = 30000,
      note = ":MyPlugins is there",
    },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        -- tasks.nvim as this config loaded it; its fixture builds a vault in a temp folder
        local init = vim.api.nvim_get_runtime_file("lua/tasks_nvim/init.lua", false)[1]
        local plugin = init and vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(init))))
        local H = {
          tmpdir = function()
            local d = vim.fs.normalize(vim.fn.tempname())
            vim.fn.mkdir(d, "p")
            return d
          end,
          write = function(path, text)
            vim.fn.mkdir(vim.fs.dirname(path), "p")
            local f = assert(io.open(path, "wb"))
            f:write(text)
            f:close()
          end,
        }
        local F = dofile(plugin .. "/TESTS/fixture.lua")
        _G.fixture = vim.fs.normalize(F.vault(H))
        F.task(H, _G.fixture, "lib.nvim", "tiny-and-worth-it", F.meta("Tiny and worth it", "open", {
          { "effort", "XS" }, { "value", "5" },
        }))
        F.task(H, _G.fixture, "lib.nvim", "to-be-finished", F.meta("To be finished", "open", { { "effort", "S" } }))
        require("tasks_nvim").setup({ vault = _G.fixture })
        _G.same = function(a, b)
          local function real(p) return vim.fs.normalize(vim.uv.fs_realpath(p or "") or p or "") end
          return a ~= nil and b ~= nil and real(a) == real(b)
        end
        _G.buf_has = function(text)
          return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find(text, 1, true) ~= nil
        end
        -- what is said: through vim.notify (passed on as it is), lib.nvim's popup history, :messages
        _G.notes = {}
        local notify = vim.notify
        vim.notify = function(msg, ...)
          table.insert(_G.notes, tostring(msg))
          return notify(msg, ...)
        end
        _G.said = function(text)
          for _, n in ipairs(_G.notes) do
            if n:find(text, 1, true) then
              return true
            end
          end
          -- lib.nvim's popup mode keeps its messages in a history of its own
          local ok, popup = pcall(require, "lib.nvim.notify.popup")
          for _, e in ipairs(ok and popup.history() or {}) do
            if tostring(e.message):find(text, 1, true) then
              return true
            end
          end
          return vim.fn.execute("messages"):find(text, 1, true) ~= nil
        end
        -- back to a plain window before the next command: out of insert mode, every float closed
        _G.reset = function()
          vim.cmd("stopinsert")
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative ~= "" then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
          vim.cmd("enew")
        end
        -- a loaded buffer that shows `has` and not `lacks`
        _G.one_with = function(has, lacks)
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
              if text:find(has, 1, true) and not text:find(lacks, 1, true) then
                return true
              end
            end
          end
          return false
        end
        -- what any loaded buffer shows (a list may open in a picker or a buffer of its own, not the current one)
        _G.any_has = function(...)
          local want = { ... }
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
              local all = true
              for _, w in ipairs(want) do
                all = all and text:find(w, 1, true) ~= nil
              end
              if all then
                return true
              end
            end
          end
          return false
        end
      ]],
      note = "a fixture vault with two tasks of lib.nvim, tasks.nvim set up on it",
    },
    -- the guard: nothing below runs on any other vault
    {
      expect = [[_G.same(require("tasks_nvim.vault").root(), _G.fixture)]],
      note = "the vault in use is the fixture, never the real one",
    },

    { keys = ":MyPlugins tasks lib.nvim<CR>", ignore_errmsg = true },
    {
      wait = [[_G.any_has("Tiny and worth it", "To be finished")]],
      timeout = 15000,
      note = ":MyPlugins tasks lists the open tasks as a table",
    },
    { input = "<Esc>" },
    { lua = "_G.reset()", note = "back to a plain window" },
    { keys = ":MyPlugins task quickwins lib.nvim<CR>", ignore_errmsg = true },
    {
      wait = [[_G.any_has("## Quick wins (1)", "Tiny and worth it")]],
      timeout = 15000,
      note = ":MyPlugins task quickwins: one quick win, the small task without a value is named apart",
    },
    { input = "<Esc>" },
    { lua = "_G.reset()", note = "back to a plain window" },
    { keys = ":MyPlugins task plan lib.nvim<CR>", ignore_errmsg = true },
    {
      wait = [[_G.any_has("To be finished")]],
      timeout = 15000,
      note = ":MyPlugins task plan shows the plan",
    },
    { input = "<Esc>" },
    { lua = "_G.reset()", note = "back to a plain window" },
    { keys = ":MyPlugins task estimate lib.nvim<CR>", ignore_errmsg = true },
    {
      wait = [[_G.said("Quick wins: lib.nvim/tiny-and-worth-it")]],
      timeout = 15000,
      note = ":MyPlugins task estimate sums the efforts",
    },

    {
      expect = [[_G.same(require("tasks_nvim.vault").root(), _G.fixture)]],
      note = "still the fixture before writing",
    },
    { input = "<Esc>" },
    { lua = "_G.reset()", note = "back to a plain window" },
    { keys = ":MyPlugins task new lib.nvim Made from MyPlugins<CR>", ignore_errmsg = true },
    {
      wait = [[vim.fn.filereadable(_G.fixture .. "/lib.nvim/ROADMAP/tasks/made-from-myplugins.md") == 1]],
      timeout = 15000,
      note = ":MyPlugins task new makes the task file",
    },
    { input = "<Esc>" },
    { lua = "_G.reset()", note = "back to a plain window" },
    { keys = ":MyPlugins task planfile lib.nvim Ship it --phases=a,b<CR>", ignore_errmsg = true },
    {
      wait = [[vim.fn.filereadable(_G.fixture .. "/lib.nvim/ROADMAP/plans/ship-it.md") == 1]],
      timeout = 15000,
      note = ":MyPlugins task planfile makes the plan file",
    },
    { input = "<Esc>" },
    { lua = "_G.reset()", note = "back to a plain window" },
    { keys = ":MyPlugins tasks index lib.nvim<CR>", ignore_errmsg = true },
    {
      wait = [[vim.fn.filereadable(_G.fixture .. "/lib.nvim/ROADMAP/TASKS.md") == 1]],
      timeout = 15000,
      note = ":MyPlugins tasks index writes the index",
    },
    { input = "<Esc>" },
    { lua = "_G.reset()", note = "back to a plain window" },
    { keys = ":MyPlugins task done lib.nvim/to-be-finished --yes<CR>", ignore_errmsg = true },
    {
      wait = [[vim.fn.filereadable(_G.fixture .. "/lib.nvim/ROADMAP/tasks/to-be-finished.md") == 0
        and #vim.fn.glob(_G.fixture .. "/lib.nvim/Backlog/TASKS/*_to-be-finished.md", false, true) == 1]],
      timeout = 15000,
      note = ":MyPlugins task done moves the task to the Backlog",
    },

    {
      expect = "not vim.fn.execute('messages'):find('E%d+:')",
      note = "no error message",
    },
  },
  judge = {},
  manual = {
    ":MyPlugins open lib.nvim tasks opens the picker of pickers.nvim over the files of the folder",
    ":MyPlugins task lists offers the named lists and opens one as the dashboard",
    ":MyPlugins tasks --to=mdview shows the table in the browser",
  },
}
