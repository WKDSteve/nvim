---@module 'bindings.mappings.undo_select'
--- `u` / `<C-r>` that treat the Visual selection as a step of their own.
---
--- Select text, `d` it, `u`: the text comes back AND is selected again. The
--- selection is a virtual step in front of the real change:
---
---   state A (text there) -> [selection] -> state B (deleted)
---   `u`      B -> A with the selection back on
---   `u`      selection gone, A unselected
---   `<C-r>`  selection back on
---   `<C-r>`  real redo (B)
---
--- Why the selection is remembered and not rebuilt from `'[` / `']`: after an
--- undo those two marks are line-granular (column 0), so a characterwise
--- selection could not be restored exactly.
---
--- Cost: nothing in Normal mode. A `ModeChanged` handler fires on entering and
--- leaving Visual mode; while Visual mode lasts a `vim.on_key` handler keeps
--- the selection as it was before each key (two `getpos` calls). When Visual mode is
--- left and the text changed, the selection is stored under `changenr()`
--- (cheap, unlike `undotree()`); at most `LIMIT` per buffer.
---
--- Ordering fact the design rests on (measured): when `ModeChanged` for
--- `v` -> `n` fires, the operator's change has already happened and
--- `changenr()` has already moved on, so no timing heuristic is needed.

local M = {}

---Selections kept per buffer; the oldest go first.
local LIMIT = 100
local ESC = "\27"

---@class UndoSelect.Sel
---@field mode string "v", "V" or "\22" (blockwise)
---@field v integer[] getpos('v') of the selection's fixed end
---@field dot integer[] getpos('.') of the moving end (the cursor)

---@class UndoSelect.Store
---@field map table<integer, UndoSelect.Sel> undo sequence number -> selection
---@field order integer[] insertion order of the keys, for trimming

---@class UndoSelect.Live
---@field tick0 integer changedtick when Visual mode started
---@field cn0 integer changenr() when Visual mode started
---@field sel UndoSelect.Sel|nil last selection seen

---@class UndoSelect.State
---@field stage "marked"|"unmarked"
---@field tick integer changedtick it is valid for
---@field v integer[]|nil getpos('v') when marked
---@field dot integer[]|nil getpos('.') when marked

---@type table<integer, UndoSelect.Store>
local stores = {}
---@type table<integer, UndoSelect.Live>
local live = {}
---@type table<integer, UndoSelect.State>
local states = {}

---@param mode string
---@return boolean
local function is_visual(mode)
  local c = mode:sub(1, 1)
  return c == "v" or c == "V" or c == "\22"
end

---@param buf integer
---@return integer
local function tick(buf)
  return vim.api.nvim_buf_get_changedtick(buf)
end

---Remember the current selection in `l`.
---@param l UndoSelect.Live
local function snapshot(l)
  local mode = vim.fn.mode()
  if not is_visual(mode) then
    return
  end
  l.sel = { mode = mode:sub(1, 1), v = vim.fn.getpos("v"), dot = vim.fn.getpos(".") }
end

---@param buf integer
---@param seq integer
---@param sel UndoSelect.Sel
local function store(buf, seq, sel)
  local s = stores[buf]
  if not s then
    s = { map = {}, order = {} }
    stores[buf] = s
  end
  if s.map[seq] == nil then
    s.order[#s.order + 1] = seq
    if #s.order > LIMIT then
      s.map[table.remove(s.order, 1)] = nil
    end
  end
  s.map[seq] = sel
end

---Only one Visual mode runs at a time, so one `vim.on_key` namespace does.
local KEY_NS = vim.api.nvim_create_namespace("UndoSelect")

---@param buf integer
local function start_visual(buf)
  local l = { tick0 = tick(buf), cn0 = vim.fn.changenr() }
  live[buf] = l
  -- Before every key: the state then is the one the PREVIOUS key left, so the
  -- last snapshot before an operator key is exactly the selection it acts on.
  -- (`CursorMoved` would not do: it is skipped while keys are still queued, as
  -- in a macro or fast typing.)
  vim.on_key(function()
    snapshot(l)
  end, KEY_NS)
  snapshot(l)
end

---@param buf integer
local function finish_visual(buf)
  local l = live[buf]
  if not l then
    return
  end
  live[buf] = nil
  vim.on_key(nil, KEY_NS)
  if l.sel and tick(buf) ~= l.tick0 and vim.fn.changenr() ~= l.cn0 then
    store(buf, vim.fn.changenr(), l.sel)
  end
end

local function on_mode_changed()
  local ev = vim.v.event
  local was, now = is_visual(ev.old_mode), is_visual(ev.new_mode)
  local buf = vim.api.nvim_get_current_buf()
  if now and not was then
    start_visual(buf)
  elseif now and was then
    if live[buf] then
      snapshot(live[buf])
    end
  elseif was and not now then
    finish_visual(buf)
  end
end

---Select `sel` again (Normal mode only), clamped to the buffer as it is now.
---@param sel UndoSelect.Sel
local function restore(sel)
  local last = vim.api.nvim_buf_line_count(0)
  local function clamp(p)
    local l = math.min(math.max(p[2], 1), last)
    local text = vim.api.nvim_buf_get_lines(0, l - 1, l, false)[1] or ""
    local c = math.min(math.max(p[3], 1), math.max(#text, 1))
    return l, c - 1
  end
  local vl, vc = clamp(sel.v)
  local dl, dc = clamp(sel.dot)
  vim.api.nvim_win_set_cursor(0, { vl, vc })
  vim.cmd("normal! " .. sel.mode)
  vim.api.nvim_win_set_cursor(0, { dl, dc })
end

---@param buf integer
local function mark_state(buf)
  states[buf] =
    { stage = "marked", tick = tick(buf), v = vim.fn.getpos("v"), dot = vim.fn.getpos(".") }
end

---@param buf integer
---@param stage "marked"|"unmarked"
---@return boolean
local function valid(buf, stage)
  local st = states[buf]
  if not st or st.stage ~= stage or st.tick ~= tick(buf) then
    return false
  end
  if stage == "marked" then
    return is_visual(vim.fn.mode())
      and vim.deep_equal(vim.fn.getpos("v"), st.v)
      and vim.deep_equal(vim.fn.getpos("."), st.dot)
  end
  return true
end

---@param buf integer
---@param seq integer
---@return UndoSelect.Sel|nil
local function stored(buf, seq)
  local s = stores[buf]
  return s and s.map[seq] or nil
end

---Normal-mode `u`.
function M.undo()
  local buf = vim.api.nvim_get_current_buf()
  local count = vim.v.count1
  states[buf] = nil
  if count > 1 then
    vim.cmd("normal! " .. count .. "u")
    return
  end
  local cn = vim.fn.changenr()
  local sel = stored(buf, cn)
  vim.cmd("normal! u")
  if sel and vim.fn.changenr() ~= cn then
    restore(sel)
    mark_state(buf)
  end
end

---Visual-mode `u`, as an `expr` mapping: while the selection is the one an
---undo restored, take it off (the next `u` is a real undo); otherwise `u` stays
---Vim's "lowercase the selection".
---@return string
function M.undo_x()
  if valid(vim.api.nvim_get_current_buf(), "marked") then
    return "<Cmd>lua require('bindings.mappings.undo_select').unmark()<CR>"
  end
  return "u"
end

---Leave Visual mode and remember that the selection is the virtual step we
---are standing behind.
function M.unmark()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd("normal! " .. ESC)
  states[buf] = { stage = "unmarked", tick = tick(buf) }
end

---Normal-mode `<C-r>`: after the selection was taken off, put it back; else
---the branch-aware redo (`g+`) it always was.
function M.redo()
  local buf = vim.api.nvim_get_current_buf()
  local count = vim.v.count1
  if count == 1 and valid(buf, "unmarked") then
    local sel = stored(buf, vim.fn.changenr() + 1)
    if sel then
      restore(sel)
      mark_state(buf)
      return
    end
  end
  states[buf] = nil
  vim.cmd("normal! " .. count .. "g+")
end

---Visual-mode `<C-r>`, as an `expr` mapping: only meaningful while the
---restored selection stands (then it is the real redo); otherwise nothing.
---@return string
function M.redo_x()
  if valid(vim.api.nvim_get_current_buf(), "marked") then
    return "<Cmd>lua require('bindings.mappings.undo_select').redo_marked()<CR>"
  end
  return ""
end

---Leave the restored selection and redo for real.
function M.redo_marked()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd("normal! " .. ESC)
  states[buf] = nil
  vim.cmd("normal! g+")
end

---The stored selections of a buffer; for the spec.
---@param buf integer
---@return UndoSelect.Store
function M._store_for_test(buf)
  return stores[buf] or { map = {}, order = {} }
end

---@return nil
function M.setup()
  local group = vim.api.nvim_create_augroup("UndoSelect", { clear = true })
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    pattern = { "*:[vV\22]*", "[vV\22]*:*" },
    callback = on_mode_changed,
  })
  -- A reload resets Vim's undo numbering: stored numbers would point at nothing.
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufUnload" }, {
    group = group,
    callback = function(ev)
      stores[ev.buf], states[ev.buf] = nil, nil
      if live[ev.buf] then
        vim.on_key(nil, KEY_NS)
        live[ev.buf] = nil
      end
    end,
  })

  local map = require("lib.nvim.bindings.keymap")
  map("n", "u", M.undo, { desc = "Undo (restores the Visual selection)" })
  map("n", "<C-r>", M.redo, { desc = "Redo (branch-aware, re-marks the Visual selection)" })
  map(
    "x",
    "u",
    M.undo_x,
    { expr = true, desc = "Take the restored selection off (else lowercase)" }
  )
  map("x", "<C-r>", M.redo_x, { expr = true, desc = "Redo from a restored selection" })
end

return M
