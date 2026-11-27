-- TESTS/bindings/undo_select_spec.lua -- `u` / `<C-r>` in bindings.mappings.undo_select: after an
-- operator on a Visual selection, `u` brings the text back AND selects it again; a second `u` takes
-- the selection off; `<C-r>` selects it again; the next `<C-r>` is the real redo. Driven with real
-- keys through the mappings, so a wrong mapping or a wrong event order shows up here.

return function(H)
  local eq, ok = H.eq, H.ok
  local us = require("bindings.mappings.undo_select")
  us.setup()

  local function keys(k)
    vim.api.nvim_feedkeys(vim.keycode(k), "mx", false)
  end

  local function fresh(lines)
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].undolevels = 1000
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    return buf
  end

  local function text()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  -- mode, the two ends of the selection (line, col), as the editor reports them
  local function sel()
    return vim.fn.mode(),
      { vim.fn.getpos("v")[2], vim.fn.getpos("v")[3] },
      { vim.fn.getpos(".")[2], vim.fn.getpos(".")[3] }
  end

  -- mappings are in place and are ours
  for _, m in ipairs({ { "n", "u" }, { "n", "<C-r>" }, { "x", "u" }, { "x", "<C-r>" } }) do
    ok(
      vim.fn.maparg(m[2], m[1], false, true).callback ~= nil,
      m[1] .. " " .. m[2] .. " is a function"
    )
  end

  -- charwise: the whole round trip
  fresh({ "hello world foo" })
  vim.api.nvim_win_set_cursor(0, { 1, 2 })
  keys("vlld")
  eq(text(), { "he world foo" }, "charwise: deleted")
  keys("u")
  eq(text(), { "hello world foo" }, "charwise: u brings the text back")
  local mode, v, dot = sel()
  eq(mode, "v", "charwise: and it is selected again")
  eq({ v, dot }, { { 1, 3 }, { 1, 5 } }, "charwise: exactly what was selected")
  keys("u")
  eq(vim.fn.mode(), "n", "second u takes the selection off")
  eq(text(), { "hello world foo" }, "second u leaves the text alone")
  keys("<C-r>")
  mode, v, dot = sel()
  eq({ mode, v, dot }, { "v", { 1, 3 }, { 1, 5 } }, "redo selects it again")
  eq(text(), { "hello world foo" }, "that redo did not touch the text")
  keys("<C-r>")
  eq(vim.fn.mode(), "n", "the next redo leaves Visual mode")
  eq(text(), { "he world foo" }, "and is the real redo")
  keys("u")
  eq(sel(), "v", "undo works again after a real redo")
  keys("<Esc>")

  -- linewise
  fresh({ "one", "two", "three", "four" })
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  keys("Vjd")
  eq(text(), { "one", "four" }, "linewise: deleted")
  keys("u")
  eq(text(), { "one", "two", "three", "four" }, "linewise: restored")
  mode, v, dot = sel()
  eq({ mode, v[1], dot[1] }, { "V", 2, 3 }, "linewise: lines 2-3 are selected again")
  keys("<Esc>")

  -- blockwise
  fresh({ "abcdef", "ghijkl", "mnopqr" })
  vim.api.nvim_win_set_cursor(0, { 1, 1 })
  keys("<C-v>jld")
  eq(text(), { "adef", "gjkl", "mnopqr" }, "blockwise: deleted")
  keys("u")
  mode, v, dot = sel()
  eq({ mode, v, dot }, { "\22", { 1, 2 }, { 2, 3 } }, "blockwise: the block is selected again")
  keys("<Esc>")

  -- a change that did not come from Visual mode leaves `u` alone
  fresh({ "plain text" })
  keys("x")
  keys("u")
  eq({ vim.fn.mode(), text() }, { "n", { "plain text" } }, "x then u: no selection appears")

  -- an operator that leaves Visual mode for Insert mode
  fresh({ "alpha beta gamma" })
  keys("wviwcXY<Esc>")
  eq(text(), { "alpha XY gamma" }, "change: replaced")
  keys("u")
  eq(text(), { "alpha beta gamma" }, "change: undone as one step")
  eq(vim.fn.mode(), "v", "change: and the old word is selected again")
  keys("<Esc>")

  -- a count is a plain undo
  fresh({ "abc" })
  keys("xxx")
  keys("3u")
  eq({ vim.fn.mode(), text() }, { "n", { "abc" } }, "3u is a plain undo")

  -- Visual `u` is still "lowercase" when no restored selection stands
  fresh({ "HELLO" })
  keys("viwu")
  eq(text(), { "hello" }, "Visual u still lowercases")

  -- a restored selection that was moved is a normal selection again: `u` lowercases it
  fresh({ "ABC DEF" })
  keys("viwd")
  keys("u")
  eq(vim.fn.mode(), "v", "restored")
  keys("l")
  keys("u")
  eq(vim.fn.mode(), "n", "moved selection: u ran the Visual u")
  eq(text(), { "abc DEF" }, "moved selection: and it lowercased the text")

  -- many Visual deletes never keep more than the limit per buffer
  fresh({ string.rep("x", 400) })
  for _ = 1, 150 do
    keys("vd")
  end
  local n = 0
  for _ in pairs(us._store_for_test(vim.api.nvim_get_current_buf()).map) do
    n = n + 1
  end
  ok(n <= 100, "at most 100 stored selections per buffer, got " .. n)
end
