-- Live check (task fileops.nvim/no-name-buffer-schliessen-und-speichern): the installed config with its real fileops
-- and ui plugins. `<C-s>` on a [No Name] buffer asks for the file name and the folder instead of E32; `<leader>bc`
-- on the tab's last [No Name] keeps it, and its "Save as…" opens fileops' prompt typeable in Insert mode. The plugins'
-- own sheets (fileops.save, tabufline.close-no-name) cover each half alone; this one covers them together.
-- `config = "user"`: on CI and without an installed config the sheet is a skip. A key that leads into a typed prompt
-- goes in as `input`: `keys` feeds with `x`, which ends Insert mode again.

local PROMPTING = [[vim.api.nvim_win_get_config(0).relative ~= "" and vim.fn.mode() == "i"]]
local CHOOSER = [[require("lib.nvim.ui.kit.chooser").is_open()]]
local DIALOG = [[require("lib.nvim.ui.kit.confirm").is_open()]]

return {
  id = "nvim-config.no-name-save",
  title = "nvim-config: <C-s> and <leader>bc on a [No Name] buffer ask for a name and a folder",
  task = "fileops.nvim/no-name-buffer-schliessen-und-speichern",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    {
      lua = "_G.SheetErrors = dofile(vim.fn.getcwd() .. '/TESTS/sheets/fixtures/errors.lua')",
      note = "the no-error check, loaded while the cwd is the project root",
    },
    -- not `settle`: the config keeps timers running, the editor is never idle
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        local dir = vim.fn.tempname()
        vim.fn.mkdir(dir .. "/docs", "p")
        vim.api.nvim_set_current_dir(dir)
        _G.__root = dir
        _G.__has = function(rel, text)
          local f = io.open(dir .. "/" .. rel, "rb")
          if not f then return false end
          local s = f:read("*a")
          f:close()
          return vim.trim(s) == text
        end
        vim.cmd("tabnew")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "via ctrl-s" })]],
      note = "a throwaway cwd with docs/, a new tab holding only a [No Name] with text",
    },

    -- <C-s>: name, then the folder (the cwd row is preselected)
    { input = "<C-s>", note = "<C-s> on the [No Name]" },
    { wait = PROMPTING, timeout = 5000, note = "fileops' name prompt, in Insert mode (no E32)" },
    { input = "a.md<CR>" },
    { wait = CHOOSER, timeout = 5000, note = "the folder chooser" },
    -- `input`, not `keys`: a `silent! unmap` of a Markdown plugin sets v:errmsg (E31) on the save, which `keys`
    -- would report as an error although nothing is shown; the check on :messages below is the real one
    { input = "<CR>", note = "the preselected cwd row" },
    { wait = [[_G.__has("a.md", "via ctrl-s")]], timeout = 5000, note = "saved in the cwd" },
    {
      expect = [[vim.fs.basename(vim.api.nvim_buf_get_name(0)) == "a.md" and not vim.bo.modified]],
      note = "the buffer is the file now",
    },
    {
      expect = "SheetErrors.none()",
      note = "no error message (no E32)",
    },

    -- <leader>bc on the tab's last [No Name], with text: it stays, Save as… opens fileops' prompt
    {
      lua = [[vim.cmd("tabnew")
      _G.__noname = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "via close" })]],
      note = "another tab with only a [No Name] with text",
    },
    { keys = "<Space>bc", note = "close it" },
    { wait = DIALOG, timeout = 5000, note = "a dialog instead of a close" },
    { keys = "<Esc>" },
    { wait = "not " .. DIALOG },
    {
      expect = [[vim.api.nvim_get_current_buf() == _G.__noname and vim.bo.modified]],
      note = "the buffer and its text stay",
    },
    { keys = "<Space>bc" },
    { wait = DIALOG, timeout = 5000 },
    { input = "h<CR>", note = "Save as…" },
    { wait = PROMPTING, timeout = 5000, note = "fileops' name prompt, in Insert mode" },
    { input = "b.md<CR>" },
    { wait = CHOOSER, timeout = 5000 },
    { input = "j<CR>", note = "Enter path manually…" },
    { wait = PROMPTING, timeout = 5000, note = "the path prompt, in Insert mode" },
    { input = "<C-u>docs/b.md<CR>" },
    { wait = [[_G.__has("docs/b.md", "via close")]], timeout = 5000, note = "saved where typed" },
    {
      expect = [[vim.api.nvim_buf_is_valid(_G.__noname) and not vim.bo[_G.__noname].modified]],
      note = "the buffer stays open, saved (the last buffer is not closed)",
    },
    {
      expect = "SheetErrors.none()",
      note = "still no error message",
    },
  },
}
