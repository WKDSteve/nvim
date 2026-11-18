-- TESTS/bindings/save_ctrl_s_spec.lua -- <C-s> in bindings.mappings.general: a [No Name] buffer
-- goes to fileops.nvim's name-and-folder prompt (`fileops.save`) instead of `:write`'s E32; a
-- named buffer is written as before. `fileops` is a stand-in at `package.loaded`, restored.

return function(H)
  local eq, ok = H.eq, H.ok
  local general = require("bindings.mappings.general")
  general.setup()

  local n = vim.fn.maparg("<C-s>", "n", false, true)
  local i = vim.fn.maparg("<C-s>", "i", false, true)
  ok(n.callback ~= nil, "normal <C-s> is a function")
  ok(i.callback ~= nil, "insert <C-s> is a function")

  local before = package.loaded["fileops"]
  local calls = {}
  package.loaded["fileops"] = {
    save = function(bufnr)
      calls[#calls + 1] = bufnr
    end,
  }
  local cok, cerr = pcall(function()
    local scratch = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_lines(scratch, 0, -1, false, { "0" })
    vim.api.nvim_win_set_buf(0, scratch)
    n.callback()
    eq(#calls, 1, "[No Name]: handed to fileops.save, no E32")

    local path = vim.fn.tempname() .. "-ctrl-s.txt"
    local named = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(named, path)
    vim.api.nvim_buf_set_lines(named, 0, -1, false, { "named" })
    vim.api.nvim_win_set_buf(0, named)
    i.callback()
    eq(#calls, 1, "named buffer: not handed to fileops")
    eq(vim.fn.readfile(path), { "named" }, "named buffer: written")
    vim.fn.delete(path)
    vim.api.nvim_buf_delete(named, { force = true })
    vim.api.nvim_buf_delete(scratch, { force = true })
  end)
  package.loaded["fileops"] = before
  ok(cok, tostring(cerr))
end
