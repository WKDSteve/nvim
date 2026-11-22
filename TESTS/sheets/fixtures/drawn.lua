-- TESTS/sheets/fixtures/drawn.lua -- what the windows show now and what they ever drew, for sheets that check that a
-- message is (not) shown.
--
-- A view can close again before a check runs (noice's mini view after its timeout, and under load the steps between
-- a message and its check take longer than that), so a "not shown" check against the screen at the end proves
-- nothing. `start()` records every line any window draws from then on (a decoration provider, `on_win`); `ever()`
-- reads that record. Load it with `dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/drawn.lua")` and call `start()`
-- before the messages are sent.
local M = {}

---@type table<string, true>
local record = {}

---Whether a line of `lines` contains `text` (plain).
---@param lines string[]
---@param text string
---@return boolean
local function contains(lines, text)
  for _, l in ipairs(lines) do
    if l:find(text, 1, true) then
      return true
    end
  end
  return false
end

---Whether any window shows `text` now.
---@param text string
---@return boolean
function M.now(text)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if contains(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(w), 0, -1, false), text) then
      return true
    end
  end
  return false
end

---Whether any window drew `text` since `start()`, also in a view that closed again.
---@param text string
---@return boolean
function M.ever(text)
  return contains(vim.tbl_keys(record), text)
end

---Record from now on every line any window draws; a second call starts a fresh record.
function M.start()
  record = {}
  local ns = vim.api.nvim_create_namespace("sheet_drawn_record")
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf, toprow, botrow)
      for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, toprow, botrow + 1, false)) do
        record[l] = true
      end
      return false
    end,
  })
end

return M
