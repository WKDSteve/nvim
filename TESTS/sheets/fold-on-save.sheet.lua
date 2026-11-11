-- Live check: a closed Markdown fold (the table of contents) stays closed when the buffer is saved, with `:w` and with
-- `<C-s>`, with a second window on the buffer and in a second tab (`preserve_folds` in `lua/bindings/autocmds/text/`).
-- The file is a copy of `TESTS/fixtures/fold-reset/toc.md` in a temporary folder, with trailing blanks added so that
-- the trim on save really changes the buffer. Each save also compares `foldexpr` before and after: a change there is
-- the competing FileType handler the task suspects.
return {
  id = "nvim-config.fold-on-save",
  title = "nvim-config: a closed Markdown fold stays closed on save (:w, <C-s>, two windows, second tab)",
  task = "nvim-config/fold-reset-on-save-root-cause",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        local dir = vim.fn.tempname()
        vim.fn.mkdir(dir, "p")
        local file = dir .. "/toc.md"
        vim.fn.writefile(vim.fn.readfile("TESTS/fixtures/fold-reset/toc.md"), file)
        vim.cmd.edit(vim.fn.fnameescape(file))
        _G.__toc = 3
        -- Trailing blanks in the section under the fold and below it: the save trims them, the buffer changes.
        _G.__dirty = function()
          vim.api.nvim_buf_set_lines(0, 4, 5, false, { vim.api.nvim_buf_get_lines(0, 4, 5, false)[1] .. "   " })
          vim.api.nvim_buf_set_lines(0, 10, 11, false, { vim.api.nvim_buf_get_lines(0, 10, 11, false)[1] .. "  " })
        end
        -- Whether the table of contents is closed in every window on this buffer.
        _G.__closed_everywhere = function()
          local buf = vim.api.nvim_get_current_buf()
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(w) == buf then
              local closed = vim.api.nvim_win_call(w, function()
                return vim.fn.foldclosed(_G.__toc)
              end)
              if closed == -1 then
                return false
              end
            end
          end
          return true
        end
      ]],
    },
    {
      wait = "vim.wo.foldmethod == 'expr' and vim.fn.foldlevel(_G.__toc) > 0",
      timeout = 10000,
      note = "the Markdown buffer folds by expression",
    },
    {
      lua = "vim.api.nvim_win_set_cursor(0, { _G.__toc, 0 }); vim.cmd('normal! zMzv'); vim.cmd('normal! zc')",
    },
    { expect = "vim.fn.foldclosed(_G.__toc) ~= -1", note = "the table of contents is closed" },
    { lua = "_G.__foldexpr = vim.wo.foldexpr; _G.__dirty()" },
    { input = ":w<CR>" },
    { wait = "not vim.bo.modified", timeout = 5000, note = ":w writes the file" },
    {
      expect = "not vim.fn.getline(5):find('%s$') and not vim.fn.getline(11):find('%s$')",
      note = "the trim on save ran",
    },
    {
      expect = "_G.__closed_everywhere()",
      note = "after :w the table of contents is still closed",
    },
    {
      expect = "vim.wo.foldexpr == _G.__foldexpr",
      note = "foldexpr is the same before and after the save",
    },
    { lua = "_G.__dirty()" },
    { input = "<C-s>" },
    { wait = "not vim.bo.modified", timeout = 5000, note = "<C-s> writes the file" },
    { expect = "_G.__closed_everywhere()", note = "after <C-s> it is still closed" },
    -- A second window on the same buffer, the fold closed in both.
    {
      lua = "vim.cmd('vsplit'); vim.cmd('normal! zMzv'); vim.api.nvim_win_set_cursor(0, { _G.__toc, 0 }); vim.cmd('normal! zc')",
    },
    { expect = "_G.__closed_everywhere()", note = "closed in both windows" },
    { lua = "_G.__dirty()" },
    { input = ":w<CR>" },
    { wait = "not vim.bo.modified", timeout = 5000 },
    {
      expect = "_G.__closed_everywhere()",
      note = "with two windows the fold stays closed in both",
    },
    -- A second tab on the same buffer.
    {
      lua = "vim.cmd('tab split'); vim.cmd('normal! zMzv'); vim.api.nvim_win_set_cursor(0, { _G.__toc, 0 }); vim.cmd('normal! zc')",
    },
    { lua = "_G.__dirty()" },
    { input = ":w<CR>" },
    { wait = "not vim.bo.modified", timeout = 5000 },
    {
      expect = "_G.__closed_everywhere()",
      note = "in a second tab the fold stays closed in every window",
    },
    { expect = "vim.wo.foldexpr == _G.__foldexpr", note = "foldexpr is still the same" },
    {
      expect = "not vim.fn.execute('messages'):find('E%d+:')",
      note = "no error message on the way",
    },
  },
  manual = {
    "In daily work: watch whether a closed fold ever opens again on save; if it does, note the file and what else was open",
  },
}
