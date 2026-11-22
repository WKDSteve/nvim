-- Live check: the skip routes of noice in the installed config (`lua/config/noice/init.lua`) swallow the known noise
-- and let an ordinary notify through to the mini view. A message counts as shown when any window's buffer holds its
-- text; the noise is sent first and a plain notify after it, so by the time the plain one shows, the noise would
-- have shown too. "No signature help" is sent as a notify of its text: the route matches the text, not the LSP call.
-- The mini view closes after its timeout (4 s), and under load a wrongly shown noise message can be gone before a
-- check looks: the "not shown" checks read every line any window ever drew (fixtures/drawn.lua), after the mini view
-- closed again.
return {
  id = "nvim-config.noice-skip",
  title = "nvim-config: noice skips the known noise, an ordinary notify still shows, nui.nvim is a dependency",
  task = "nvim-config/live-check-structure-jump-and-bindings-check",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "package.loaded['noice'] ~= nil", timeout = 15000, note = "noice is loaded" },
    {
      lua = [[
        _G.D = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/drawn.lua")
        D.start()
      ]],
      note = "every drawn line is recorded from here on",
    },
    { lua = "vim.notify('Buffer is not modifiable', vim.log.levels.WARN)" },
    { lua = "vim.notify('No signature help available', vim.log.levels.INFO)" },
    {
      lua = "vim.notify('Error detected while processing BufReadPost Autocommands for \"*\": probe', vim.log.levels.ERROR)",
    },
    { lua = "vim.notify('sheet probe: an ordinary message')" },
    {
      wait = "D.now('sheet probe: an ordinary message')",
      timeout = 5000,
      note = "an ordinary notify shows",
    },
    -- as under load: the mini view times out before the checks below run, and they still hold
    {
      wait = "not D.now('sheet probe: an ordinary message')",
      timeout = 15000,
      note = "the mini view closed again after its timeout",
    },
    {
      expect = "D.ever('sheet probe: an ordinary message')",
      note = "the record holds what the screen no longer shows",
    },
    { expect = "not D.ever('Buffer is not modifiable')", note = "no 'Buffer is not modifiable'" },
    { expect = "not D.ever('No signature help')", note = "no 'No signature help'" },
    {
      expect = "not D.ever('Error detected while processing BufReadPost')",
      note = "no BufReadPost noise",
    },
    {
      expect = [[(function()
        local plugins = require('lazy.core.config').plugins
        if not plugins['nui.nvim'] then return false end
        for _, name in ipairs({ 'noice.nvim', 'neo-tree.nvim' }) do
          local deps = plugins[name] and plugins[name].dependencies or {}
          if not vim.tbl_contains(deps, 'nui.nvim') then return false end
        end
        return true
      end)()]],
      note = "nui.nvim is a dependency of noice and neo-tree, not a plugin of its own",
    },
    { expect = "not vim.fn.execute('messages'):find('E%d+:')", note = "no error message" },
  },
}
