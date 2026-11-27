-- TESTS/bindings/quit_all_spec.lua -- `<leader>Q` (buf_win_tab.quit_all) asks before quitting when a
-- buffer has unsaved changes (an unsaved [No Name] buffer was lost without a question). The kit
-- dialog is answered through its dialog hook; `quit` is injected so the test editor stays alive.

return function(H)
  local eq, ok = H.eq, H.ok
  local bwt = require("bindings.mappings.buf_win_tab")
  local kit = require("lib.nvim.ui.kit")

  local function dirty_buf(name)
    local b = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, b)
    if name then
      vim.api.nvim_buf_set_name(b, name)
    end
    vim.api.nvim_buf_set_lines(b, 0, -1, false, { "text" })
    ok(vim.bo[b].modified, "buffer is modified")
    return b
  end

  -- run quit_all with the dialog answered `answer`; returns quit count and the asked options
  local function run(answer)
    local quits, asked = 0, nil
    kit.set_dialog_hook(function(kind, opts)
      if kind == "confirm" then
        asked = opts
        return true, answer
      end
      return false
    end)
    bwt.quit_all(function()
      quits = quits + 1
    end)
    vim.wait(200, function()
      return answer ~= nil and quits > 0
    end, 10)
    vim.wait(50)
    kit.set_dialog_hook(nil)
    return quits, asked
  end

  -- nothing unsaved: quits at once, no question
  local quits, asked = run("Cancel")
  eq(quits, 1, "clean editor quits without asking")
  eq(asked, nil, "no dialog")

  -- unsaved [No Name]: asks, Cancel keeps the editor
  local b = dirty_buf()
  quits, asked = run("Cancel")
  ok(asked ~= nil, "unsaved buffer: dialog shown")
  eq(asked.default, "Cancel", "Cancel is the default button")
  eq(quits, 0, "Cancel does not quit")
  ok(vim.api.nvim_buf_is_valid(b) and vim.bo[b].modified, "text still there")

  -- dismissed (Esc) does not quit either
  quits = run(nil)
  eq(quits, 0, "dismissed does not quit")

  -- Save all with an unnamed buffer: nothing is lost, editor stays, that buffer is shown
  quits = run("Save all and quit")
  eq(quits, 0, "unnamed buffer cannot be saved: no quit")
  eq(vim.api.nvim_get_current_buf(), b, "the unnamed buffer is shown")

  -- Discard quits
  quits = run("Discard and quit")
  eq(quits, 1, "Discard quits")
  vim.bo[b].modified = false

  -- Save all with a named buffer writes it, then quits
  local path = vim.fn.tempname() .. "_quit_all.txt"
  local nb = dirty_buf(path)
  quits = run("Save all and quit")
  eq(quits, 1, "Save all quits")
  eq(vim.fn.readfile(path), { "text" }, "the file was written")
  vim.api.nvim_buf_delete(nb, { force = true })
  vim.fn.delete(path)
  vim.api.nvim_buf_delete(b, { force = true })
end
