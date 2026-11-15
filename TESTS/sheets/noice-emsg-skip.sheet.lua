-- Live check: the E-number skip routes of noice in the installed config (`lua/config/noice/init.lua`, kind "emsg"):
-- E20, E23, E31, E351 and E37 are raised for real through the keys a person types and must show in no window, while an
-- ordinary error after them still shows. E162 (a refused :qa) has a route to the mini view and must show. E418
-- is left out: it has no safe trigger. The buffer is a scratch buffer; nothing is written.
return {
  id = "nvim-config.noice-emsg-skip",
  title = "nvim-config: noice swallows E20/E23/E31/E351/E37, shows E162 and an ordinary error",
  task = "nvim-config/noice-hover-route-und-long-message-preset",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "package.loaded['noice'] ~= nil", timeout = 15000, note = "noice is loaded" },
    {
      lua = [[
        -- Whether any window shows `text`.
        _G.__shown = function(text)
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            for _, l in ipairs(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(w), 0, -1, false)) do
              if l:find(text, 1, true) then return true end
            end
          end
          return false
        end
        -- keepalt: the alternate file stays empty, so <C-^> below raises E23 instead of switching buffers
        vim.cmd("keepalt enew")
        vim.bo.buftype = "nofile"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "a", "  b", "  c", "d" })
      ]],
    },
    -- E20 Mark not set
    { input = ":normal! `q<CR>" },
    { wait = "vim.v.errmsg:find('E20', 1, true) ~= nil", timeout = 3000, note = "E20 was raised" },
    -- E23 No alternate file (a fresh scratch buffer has none)
    { input = ':exe "normal! \\<lt>C-^>"<CR>' },
    { wait = "vim.v.errmsg:find('E23', 1, true) ~= nil", timeout = 3000, note = "E23 was raised" },
    -- E31 No such mapping
    { input = ":nunmap <lt>F35><CR>" },
    { wait = "vim.v.errmsg:find('E31', 1, true) ~= nil", timeout = 3000, note = "E31 was raised" },
    -- E351 Cannot delete fold with current 'foldmethod'
    { lua = "vim.wo.foldmethod = 'indent'; vim.api.nvim_win_set_cursor(0, { 2, 0 })" },
    { input = "zd" },
    {
      wait = "vim.v.errmsg:find('E351', 1, true) ~= nil",
      timeout = 3000,
      note = "E351 was raised",
    },
    -- E37 No write since last change: a changed normal buffer, 'nohidden', then :edit
    {
      lua = [[
        vim.cmd("keepalt enew")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "changed, never written" })
        vim.o.hidden = false
      ]],
    },
    { input = ":e sheet-probe-e37.txt<CR>" },
    { wait = "vim.v.errmsg:find('E37', 1, true) ~= nil", timeout = 3000, note = "E37 was raised" },
    -- E162 No write since last change for buffer: that buffer hidden, then :qa refuses
    { lua = "vim.o.hidden = true; vim.cmd('keepalt enew'); vim.bo.buftype = 'nofile'" },
    { input = ":qa<CR>" },
    {
      wait = "vim.v.errmsg:find('E162', 1, true) ~= nil",
      timeout = 3000,
      note = "E162 was raised",
    },
    -- a refused :qa can leave a prompt (hit-enter or 'confirm'): close it before going on
    { input = "<Esc>" },
    {
      wait = "vim.api.nvim_get_mode().mode == 'n' and not vim.api.nvim_get_mode().blocking",
      timeout = 3000,
    },
    -- the control: an error no route skips
    { input = ":echoerr 'E9999: sheet probe'<CR>" },
    {
      wait = "vim.v.errmsg:find('E9999', 1, true) ~= nil",
      timeout = 5000,
      note = "the control error was really raised",
    },
    {
      -- the text of the message, not the typed command (that one says "echoerr")
      wait = "_G.__shown('E9999: sheet probe') and vim.fn.getcmdtype() == ''",
      timeout = 5000,
      note = "an ordinary error message still shows",
    },
    { expect = "not _G.__shown('E20')", note = "no E20 (mark not set)" },
    { expect = "not _G.__shown('E23')", note = "no E23 (no alternate file)" },
    { expect = "not _G.__shown('E31')", note = "no E31 (no such mapping)" },
    { expect = "not _G.__shown('E351')", note = "no E351 (cannot delete fold)" },
    { expect = "not _G.__shown('E37')", note = "no E37 (no write since last change)" },
    {
      expect = "_G.__shown('E162')",
      note = "E162 goes to the mini view (its own route), it is not skipped",
    },
  },
}
