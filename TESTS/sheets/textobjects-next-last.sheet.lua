-- Live check: mini.ai's "next"/"last" textobjects sit on capitals (`aN`/`iN`, `aL`/`iL`, lua/plugins/textobjects.lua)
-- so Neovim 0.12's own `an`/`in` (incremental selection) stay free. Typed like a person would in the installed config:
-- `ciN)` from inside the first pair changes the next pair, `ciL)` from inside the last pair changes the one before,
-- `daN)` deletes the next pair with its brackets. The buffer is a scratch buffer; nothing is written. `c` and `d` go to
-- the + register ('clipboard' is unnamedplus): its program is a recording stand-in (fixtures/stand_ins.lua) and the +
-- register reads back what was copied (fixtures/clipboard_memory.lua), so the real clipboard is neither written nor read.
return {
  id = "nvim-config.textobjects-next-last",
  title = "nvim-config: mini.ai iN/aN/iL/aL reach the next/last pair, an/in stay Neovim's",
  task = "nvim-config/live-runde-umsetzungen-aus-chat-2-in-einer-echten-sitzung-pr",
  config = "user",
  fakes = { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" },
  sizes = { { rows = 24, cols = 100 } },
  steps = {
    {
      wait = "package.loaded['mini.ai'] ~= nil",
      timeout = 10000,
      note = "mini.ai is loaded (VeryLazy)",
    },
    {
      lua = [[
        local H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        H.runtime("stand_ins", vim.env.TESTING_FAKES, { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" })
        H.runtime("clipboard_memory")
      ]],
      note = "the clipboard tool is a stand-in, the + register remembers the copy",
    },
    {
      lua = [[
        vim.cmd("enew")
        vim.bo.buftype = "nofile"
        _G.__reset = function(col)
          vim.api.nvim_buf_set_lines(0, 0, -1, false, { "(aa) (bb) (cc)" })
          vim.api.nvim_win_set_cursor(0, { 1, col })
        end
        _G.__line = function()
          return vim.api.nvim_get_current_line()
        end
        _G.__reset(1)
      ]],
    },
    {
      expect = "vim.fn.maparg('iN', 'o') ~= '' and vim.fn.maparg('aL', 'x') ~= ''",
      note = "iN and aL are mapped",
    },
    {
      lua = [[
        _G.__desc = function(lhs, mode)
          return (vim.fn.maparg(lhs, mode, false, true).desc or ""):lower()
        end
      ]],
    },
    {
      expect = "_G.__desc('iN', 'o'):find('textobject') ~= nil",
      note = "iN carries mini.ai's textobject description (the check below can see mini.ai)",
    },
    {
      expect = "not _G.__desc('in', 'o'):find('textobject') and not _G.__desc('an', 'x'):find('textobject')",
      note = "an/in are not taken by mini.ai",
    },

    { input = "ciN)X<Esc>" },
    {
      wait = "_G.__line() == '(aa) (X) (cc)'",
      timeout = 3000,
      note = "ciN) from the first pair changes the next one",
    },

    { lua = "_G.__reset(11)" },
    { input = "ciL)Y<Esc>" },
    {
      wait = "_G.__line() == '(aa) (Y) (cc)'",
      timeout = 3000,
      note = "ciL) from the last pair changes the one before",
    },

    { lua = "_G.__reset(1)" },
    { input = "daN)" },
    {
      wait = "_G.__line() == '(aa)  (cc)'",
      timeout = 3000,
      note = "daN) deletes the next pair with its brackets",
    },

    { expect = "not vim.fn.execute('messages'):find('E%d+:')", note = "no error message" },
  },
}
