-- Live check: the own `<C-n>` flow (`lua/multicursor`, replaces vim-visual-multi) in the installed config, pressed
-- like a person would: mark the word and the next occurrences, take one back (`<C-p>`), skip one (`<C-x>`), then
-- `c`/`i`/`a`/`d` on every marked place at once, `u` as one undo step (a `c` included: deletion and typing), `<Esc>` clears and `x` is plain again. `foofoo` is no whole word
-- and must never be marked. The buffer is a scratch buffer; nothing is written.
return {
  id = "nvim-config.multicursor",
  title = "nvim-config: <C-n> marks word and next matches, c/i/a/d change them all, <C-x>/<C-p>/<Esc> work",
  task = "nvim-config/vim-visual-multi-reste-doku-lazy-clean-multicursor-handcheck",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        vim.cmd("enew")
        vim.bo.buftype = "nofile"
        _G.__reset = function()
          require("multicursor").clear()
          vim.api.nvim_buf_set_lines(0, 0, -1, false, { "foo bar foo", "foo baz foofoo", "end foo" })
          vim.api.nvim_win_set_cursor(0, { 1, 0 })
          -- an undo break, so the `u` below takes back the change and not the reset
          vim.o.undolevels = vim.o.undolevels
        end
        _G.__lines = function()
          return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "|")
        end
        _G.__reset()
      ]],
    },
    {
      expect = "vim.fn.maparg('<C-n>', 'n') ~= ''",
      note = "<C-n> is mapped (no vim-visual-multi any more)",
    },
    {
      expect = "not package.loaded['lazy.core.config'].plugins['vim-visual-multi']",
      note = "vim-visual-multi is not in the spec",
    },

    -- mark, next, take back, mark again, change all
    { input = "<C-n>" },
    {
      wait = "require('multicursor').count() == 1",
      timeout = 3000,
      note = "<C-n> marks the word under the cursor",
    },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 2", timeout = 3000 },
    { input = "<C-n>" },
    {
      wait = "require('multicursor').count() == 3",
      timeout = 3000,
      note = "<C-n> again marks the next occurrences",
    },
    { input = "<C-p>" },
    {
      wait = "require('multicursor').count() == 2",
      timeout = 3000,
      note = "<C-p> takes back the last mark",
    },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 3", timeout = 3000 },
    { input = "<C-n>" },
    {
      wait = "require('multicursor').count() == 4",
      timeout = 3000,
      note = "foofoo is skipped: four whole-word foo",
    },
    { input = "cqux<Esc>" },
    {
      wait = "_G.__lines() == 'qux bar qux|qux baz foofoo|end qux'",
      timeout = 3000,
      note = "c changes every marked place",
    },
    {
      wait = "not require('multicursor').active()",
      timeout = 3000,
      note = "the marks are gone after the change",
    },
    { input = "u" },
    {
      wait = "_G.__lines() == 'foo bar foo|foo baz foofoo|end foo'",
      timeout = 3000,
      note = "one u undoes the whole change",
    },

    -- skip
    { lua = "_G.__reset()" },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 1", timeout = 3000 },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 2", timeout = 3000 },
    { input = "<C-x>" },
    {
      wait = "require('multicursor').count() == 2",
      timeout = 3000,
      note = "<C-x> skips the current occurrence",
    },
    { input = "d" },
    {
      wait = "_G.__lines() == ' bar foo| baz foofoo|end foo'",
      timeout = 3000,
      note = "d deletes the marked places (first and third foo), not the skipped one",
    },

    -- insert before, append after
    { lua = "_G.__reset()" },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 1", timeout = 3000 },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 2", timeout = 3000 },
    { input = "iX<Esc>" },
    {
      wait = "_G.__lines() == 'Xfoo bar Xfoo|foo baz foofoo|end foo'",
      timeout = 3000,
      note = "i inserts before every mark",
    },
    { lua = "_G.__reset()" },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 1", timeout = 3000 },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 2", timeout = 3000 },
    { input = "aY<Esc>" },
    {
      wait = "_G.__lines() == 'fooY bar fooY|foo baz foofoo|end foo'",
      timeout = 3000,
      note = "a appends after every mark",
    },

    -- Esc clears, the operators come back
    { lua = "_G.__reset()" },
    { input = "<C-n>" },
    { wait = "require('multicursor').count() == 1", timeout = 3000 },
    { input = "<C-n>" },
    {
      wait = "require('multicursor').active()",
      timeout = 3000,
      note = "marks are active",
    },
    { input = "<Esc>" },
    {
      wait = "not require('multicursor').active()",
      timeout = 3000,
      note = "<Esc> clears the marks",
    },
    {
      expect = "vim.tbl_isempty(vim.tbl_filter(function(m) return m.lhs:match('^[csiadx]$') ~= nil end, vim.api.nvim_buf_get_keymap(0, 'n')))",
      note = "after <Esc> the operator keys are no longer taken by the marks",
    },
    -- `x`, not `dw`: the installed config maps the word motions, the check is only that the key is plain again
    {
      lua = [[
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()
        _G.__after_x = line:sub(1, col) .. line:sub(col + 2)
        _G.__x_row = row
      ]],
    },
    { input = "x" },
    {
      wait = "vim.api.nvim_buf_get_lines(0, _G.__x_row - 1, _G.__x_row, false)[1] == _G.__after_x",
      timeout = 3000,
      note = "x deletes one character again, as without marks",
    },
    { expect = "not vim.fn.execute('messages'):find('E%d+:')", note = "no error message" },
  },
  judge = {
    "The marks are easy to see while <C-n> is active, and the typed text shows at the first place while changing",
  },
}
