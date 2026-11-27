-- TESTS/bindings/copy_ctrl_c_spec.lua -- <C-c> in bindings.mappings.general: in visual mode it
-- yanks the selection to `+`; in normal mode it copies the whole buffer in EVERY buffer (a file,
-- a nofile plugin view or picker list, a float, a terminal's scrollback) and says so, so no plugin
-- view has to bind it again.
-- The copy goes to register `a` here: this runner has no fake clipboard, and a spec must not
-- write the user's `+` (XP-08).

return function(H)
  local eq, ok = H.eq, H.ok
  local general = require("bindings.mappings.general")
  general.setup()

  local x = vim.fn.maparg("<C-c>", "x", false, true)
  eq(x.rhs, '"+y', "visual <C-c> yanks the selection to the system clipboard")
  ok(vim.fn.maparg("<C-c>", "n", false, true).callback ~= nil, "normal <C-c> is a function")

  local notes = {}
  local orig_notify = vim.notify
  vim.notify = function(msg)
    notes[#notes + 1] = msg
  end
  local cok, cerr = pcall(function()
    -- a file window: the whole buffer, linewise, and a message
    local file = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(file, vim.fn.tempname() .. "/copy_me.txt")
    vim.api.nvim_buf_set_lines(file, 0, -1, false, { "one", "two", "three" })
    vim.api.nvim_win_set_buf(0, file)
    vim.fn.setreg("a", "before")
    eq(general.copy_file(0, "a"), 3, "a file window is copied")
    eq(vim.fn.getreg("a", 1, 1), { "one", "two", "three" }, "the whole buffer")
    eq(vim.fn.getregtype("a"), "V", "linewise")
    eq(notes[#notes], "Copied 3 lines of copy_me.txt", "and it says what it copied")

    -- a plugin view (nofile): copied like a file
    vim.fn.setreg("a", "before")
    local nofile = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(nofile, 0, -1, false, { "view", "lines" })
    vim.api.nvim_win_set_buf(0, nofile)
    eq(general.copy_file(0, "a"), 2, "a nofile plugin view is copied")
    eq(vim.fn.getreg("a", 1, 1), { "view", "lines" }, "its whole text")
    eq(notes[#notes], "Copied 2 lines of [No Name]", "an unnamed buffer is said so")

    -- a float over it: copied too
    local float = vim.api.nvim_open_win(
      nofile,
      true,
      { relative = "editor", row = 1, col = 1, width = 10, height = 2 }
    )
    vim.fn.setreg("a", "before")
    eq(general.copy_file(float, "a"), 2, "a float is copied")
    vim.api.nvim_win_close(float, true)

    -- a terminal buffer: its scrollback is copied
    local term = vim.api.nvim_create_buf(false, true)
    local chan = vim.api.nvim_open_term(term, {})
    vim.api.nvim_chan_send(chan, "hello")
    vim.wait(1000, function()
      return (vim.api.nvim_buf_get_lines(term, 0, 1, false)[1] or ""):find("hello") ~= nil
    end)
    vim.api.nvim_win_set_buf(0, term)
    eq(vim.bo[term].buftype, "terminal", "a terminal buffer")
    eq(general.copy_file(0, "a"), 1, "a terminal buffer is copied without its blank rows")
    eq(vim.fn.getreg("a", 1, 1), { "hello" }, "only what the terminal shows")
  end)
  vim.notify = orig_notify
  if not cok then
    error(cerr, 0)
  end
end
