-- Feature sheet: `:Cdx prompt <name> [sha]` copies a prompt template of docs/NOTES/CDX/templates/PROMPT to the system
-- clipboard (lua/bindings/usrcmds/cdx/init.lua), typed in the installed config. The copy goes through the config's
-- own clipboard provider (my.nvim: `win32yank.exe -i --crlf` on Windows, `wl-copy` on Wayland), whose program is a
-- recording stand-in (fixtures/stand_ins.lua), and the + register reads back what was copied
-- (fixtures/clipboard_memory.lua): the real clipboard is neither written nor read. On CI and without an installed
-- config: a skip.
return {
  id = "nvim-config.cdx-prompt",
  feature = "nvim-config.cdx-prompt",
  title = "nvim-config: :Cdx prompt copies a template to the clipboard, {SHA} replaced by the given SHA",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  fakes = { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" },
  sizes = { { rows = 24, cols = 110 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':Cdx') == 2", timeout = 30000, note = ":Cdx is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        H.runtime("stand_ins", vim.env.TESTING_FAKES, { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" })
        _G.COPIED = H.runtime("clipboard_memory")
        _G.TOOL = vim.fn.has("win32") == 1 and "win32yank" or "wl-copy"
      ]],
      note = "the clipboard tool is a stand-in, the + register remembers the copy",
    },
    { keys = ":Cdx prompt ultra_sha 1a2b3c4d<CR>" },
    { wait = "#H.calls(TOOL) >= 1", timeout = 10000, note = "the clipboard tool was started once" },
    {
      expect = [[(function()
        local lines = COPIED("+") or {}
        local text = table.concat(lines, "\n")
        return text:find("1a2b3c4d", 1, true) ~= nil and text:find("{SHA}", 1, true) == nil
      end)()]],
      note = "the + register holds the template with the SHA in place of {SHA}",
    },
    { wait = "H.heard('Copied')", timeout = 5000, note = "it says what it copied" },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  judge = {
    "The message after the copy names the template and the size of what was copied",
  },
  manual = {
    "Once in a real session: :Cdx prompt ultra_sha <sha> and paste into another program; the SHA is in the text",
  },
}
