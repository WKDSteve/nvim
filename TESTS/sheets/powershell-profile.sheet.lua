-- Feature sheet: `:PowershellProfile` (lua/bindings/usrcmds/init.lua) asks Windows PowerShell for `$PROFILE` and opens
-- that file, typed in the installed config. PowerShell runs for real (in the background, once per session); the
-- file is only opened, never written. Without `powershell` on the PATH (Linux, macOS) the sheet is a reported skip;
-- on CI and without an installed config: a skip.
return {
  id = "nvim-config.powershell-profile",
  feature = "nvim-config.powershell-profile",
  title = "nvim-config: :PowershellProfile opens the file PowerShell names as $PROFILE",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  requires = {
    {
      lua = "vim.fn.executable('powershell') == 1",
      reason = "no Windows PowerShell on this machine",
    },
  },
  sizes = { { rows = 24, cols = 110 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      wait = "vim.fn.exists(':PowershellProfile') == 2",
      timeout = 30000,
      note = ":PowershellProfile is there",
    },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
      ]],
    },
    { keys = ":PowershellProfile<CR>" },
    {
      wait = "vim.api.nvim_buf_get_name(0):lower():find('profile%.ps1$') ~= nil",
      timeout = 20000,
      note = "the current buffer is the profile script",
    },
    { expect = "not vim.bo.modified", note = "opened, not changed" },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  manual = {
    "Once in a real session: :PowershellProfile opens the same file as `notepad $PROFILE` in a PowerShell",
  },
}
