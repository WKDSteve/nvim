-- Live check: the installed config starts as a person's editor does (`config = "user"` of testing.nvim: the real
-- config and its installed plugins, read only; state, cache and the rest of data in a sandbox). On CI and without
-- an installed config the sheet is a skip.
return {
  id = "nvim-config.smoke",
  title = "nvim-config: the installed config starts with its plugins and without an error",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    {
      lua = "_G.SheetErrors = dofile(vim.fn.getcwd() .. '/TESTS/sheets/fixtures/errors.lua')",
      note = "the no-error check, loaded while the cwd is the project root",
    },
    -- not `settle`: the config keeps timers running, the editor is never idle
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "lazy.nvim is loaded" },
    { expect = "#require('lazy').plugins() > 10", note = "with the installed plugins" },
    { expect = "vim.g.mapleader ~= nil", note = "the leader key of the config" },
    -- not `v:errmsg`: a `silent!` sets it too (neo-tree's `silent! autocmd! FileExplorer *` when it takes over netrw);
    -- fixtures/errors.lua reads `:messages`, noice's history and lib.nvim's popups (no-errors-probe.sheet.lua)
    {
      expect = "SheetErrors.none()",
      note = "no error message at the start",
    },
  },
}
