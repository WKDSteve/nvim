-- Positive test of the "no error on the way" check of the sheets (fixtures/errors.lua, `H.no_errors()`): under noice
-- in the installed config, every kind of error a config meets is raised on purpose, and the check must see each one
-- in the source that holds it. A check that says "no error" is worth nothing without this sheet (FALLEN-04).
-- What was measured (2026-11-22): `:messages` has the E-errors and Lua errors of callbacks (the latter without an
-- E-number), noice's history has `vim.notify` at ERROR too, and lib.nvim's popups are only in their own history.
-- The Lua error comes first: the check before (`E%d+:` in `:messages`) missed it, so `H.no_errors()` must turn red
-- on it alone.
return {
  id = "nvim-config.no-errors-probe",
  title = "nvim-config: the sheets' no-error check sees every kind of error under noice",
  task = "nvim-config/sheets-kein-fehler-pruefung-ueber-messages-unter-noice-ohne",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    {
      lua = [[
        _G.E = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/errors.lua")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
      ]],
      note = "the check of the sheets, and the helpers of the process sheets",
    },
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "package.loaded['noice'] ~= nil", timeout = 15000, note = "noice is loaded" },
    { expect = "E.none()", note = "the config starts without an error" },
    { lua = [[vim.schedule(function() error('sheet probe lua error') end)]] },
    {
      wait = "E.has(E.from_messages(), 'sheet probe lua error')",
      timeout = 5000,
      note = ":messages has a Lua error without an E-number",
    },
    { expect = "not E.none()", note = "the check turns red on a Lua error" },
    { expect = "not H.no_errors()", note = "H.no_errors() of the process sheets turns red too" },
    { keys = ":NoSuchCmdProbe<CR>", ignore_errmsg = true, note = "an E-error of a command (E492)" },
    { expect = "E.has(E.from_messages(), 'E492')", note = ":messages has the E-error" },
    { expect = "E.has(E.from_noice(), 'E492')", note = "noice's history has it too" },
    {
      lua = [[
        vim.api.nvim_create_autocmd('User', {
          pattern = 'SheetProbeError',
          callback = function() error('sheet probe autocmd error') end,
        })
        vim.schedule(function() vim.cmd('doautocmd User SheetProbeError') end)
      ]],
    },
    {
      wait = "E.has(E.from_messages(), 'sheet probe autocmd error')",
      timeout = 5000,
      note = ":messages has a Lua error of an autocmd",
    },
    { lua = [[vim.schedule(function() vim.cmd('echoerr "sheet probe echoerr"') end)]] },
    {
      wait = "E.has(E.from_messages(), 'sheet probe echoerr')",
      timeout = 5000,
      note = ":messages has an echoerr",
    },
    { lua = [[vim.notify('sheet probe notify error', vim.log.levels.ERROR)]] },
    {
      wait = "E.has(E.from_noice(), 'sheet probe notify error')",
      timeout = 5000,
      note = "noice's history has vim.notify at ERROR (not in :messages)",
    },
    {
      lua = [[require('lib.nvim.notify').create('[sheet-probe]', { popup = true })
        .notify('sheet probe popup error', vim.log.levels.ERROR)]],
    },
    {
      wait = "E.has(E.from_popups(), 'sheet probe popup error')",
      timeout = 5000,
      note = "lib.nvim's popup history has an ERROR popup",
    },
    {
      expect = [[E.none({ 'NoSuchCmdProbe', 'sheet probe lua error', 'sheet probe autocmd error',
        'sheet probe echoerr', 'sheet probe notify error', 'sheet probe popup error' })]],
      note = "without the errors raised on purpose, there is none",
    },
    {
      lua = "vim.cmd.cd(vim.fs.dirname(vim.fs.normalize(vim.fn.tempname())))",
      note = "away from the project root",
    },
    {
      expect = "vim.fn.filereadable('TESTS/sheets/fixtures/errors.lua') == 0",
      note = "the cwd is elsewhere",
    },
    {
      expect = "not H.no_errors({ 'sheet probe notify error' })",
      note = "H.no_errors() still works there",
    },
  },
}
