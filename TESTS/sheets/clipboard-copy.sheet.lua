-- Feature sheet: `:Clipboard <target>` copies the path of a well-known folder of this config, `:Clipboard <snippet>`
-- a ready-made snippet (lua/bindings/usrcmds/clipboard/init.lua), typed in the installed config. The copy goes through
-- the config's own clipboard provider (my.nvim), whose program is a recording stand-in (fixtures/stand_ins.lua); the
-- + register reads back what was copied (fixtures/clipboard_memory.lua): the real clipboard is neither written nor
-- read. On CI and without an installed config: a skip.
return {
  id = "nvim-config.clipboard-copy",
  feature = "nvim-config.clipboard",
  title = "nvim-config: :Clipboard reports copies the folder's path, :Clipboard remove citeX the snippet",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  fakes = { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" },
  sizes = { { rows = 24, cols = 110 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':Clipboard') == 2", timeout = 30000, note = ":Clipboard is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        H.runtime("stand_ins", vim.env.TESTING_FAKES, { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" })
        _G.COPIED = H.runtime("clipboard_memory")
        _G.TOOL = vim.fn.has("win32") == 1 and "win32yank" or "wl-copy"
        _G.TEXT = function()
          return table.concat(COPIED("+") or {}, "\n")
        end
      ]],
      note = "the clipboard tool is a stand-in, the + register remembers the copy",
    },
    { keys = ":Clipboard reports<CR>" },
    { wait = "#H.calls(TOOL) >= 1", timeout = 10000, note = "the clipboard tool was started" },
    {
      expect = [[TEXT():gsub("\\", "/"):find("docs/ROADMAP/reports", 1, true) ~= nil]],
      note = "the + register holds the path of the reports folder",
    },
    { wait = "H.heard('copied reports')", timeout = 5000, note = "it says what it copied" },
    { keys = ":Clipboard remove citeX<CR>" },
    { wait = "#H.calls(TOOL) >= 2", timeout = 10000, note = "a second copy" },
    {
      expect = [[TEXT():find("[cite: ", 1, true) ~= nil]],
      note = "the + register holds the snippet's Ex command, backslashes as they are",
    },
    {
      wait = "H.heard('copied remove citeX')",
      timeout = 5000,
      note = "it says which snippet it copied",
    },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  judge = {
    "The messages say what was copied, shortened so that they fit on one line",
  },
  manual = {
    "Once in a real session: :Clipboard handovers and paste into the Explorer's address bar; the folder opens",
  },
}
