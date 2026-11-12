---@module 'multicursor'
--- A narrow replacement for vim-visual-multi: only the flow that was actually used.
---
---   `<C-n>`  on a word (or a visual selection): mark it; again: mark the next occurrence (wraps around)
---   then     `c` change, `i` insert before, `a` append after, `d` delete -- applied to every marked place at once
---   `<C-x>`  skip the current occurrence and mark the next one instead
---   `<C-p>`  take back the last mark
---   `<Esc>`  clear the marks
---
--- How a change works: the marked texts are deleted (for `c`), the cursor goes to the first place and Insert mode
--- starts. When Insert mode ends, whatever was typed at the first place (from the anchor to `'^`) is inserted at
--- every other place, bottom to top, and the whole thing is one undo step. Marks are extmarks, so edits made while
--- typing move the other places along. Multi-line text typed in Insert mode is replicated as typed.
---
--- Deliberately not here: several real cursors, regex search, per-cursor motions, visual-block tricks. One buffer
--- at a time; the keys exist (buffer-locally) only while marks are active.

local M = {}

local api = vim.api
local ns = api.nvim_create_namespace("multicursor")

---@class Multicursor.State
---@field buf integer
---@field word string the marked text
---@field boundary boolean match whole words only (a word under the cursor), not a visual selection
---@field marks integer[] extmark ids in the order they were marked
---@field keys string[] the buffer-local keys installed while active

---@type Multicursor.State|nil
local state

---@param ch string
---@return boolean
local function is_kw(ch)
  if ch == "" then
    return false
  end
  return vim.regex([[\k]]):match_str(ch) ~= nil
end

---@param line string
---@param col integer 0-based byte column
---@return string
local function char_at(line, col)
  if col < 0 or col >= #line then
    return ""
  end
  local ok, pos = pcall(vim.str_utf_pos, line)
  if not ok then
    return line:sub(col + 1, col + 1)
  end
  for i, start in ipairs(pos) do
    local stop = (pos[i + 1] or (#line + 1)) - 1
    if start - 1 <= col and col <= stop - 1 then
      return line:sub(start, stop)
    end
  end
  return ""
end

---@param line string
---@param col integer 0-based start of the match
---@param len integer
---@return boolean
local function whole_word(line, col, len)
  local before = col > 0 and char_at(line, col - 1) or ""
  -- the character before a multibyte neighbour starts earlier: look one UTF-8 character back
  if col > 0 and before ~= "" then
    local ok, idx = pcall(vim.str_utf_start, line, col)
    if ok and type(idx) == "number" and idx < 0 then
      before = char_at(line, col + idx - 1)
    end
  end
  local after = char_at(line, col + len)
  return not is_kw(before) and not is_kw(after)
end

---All occurrences of `word` in the buffer as `{ row, col }` (0-based), in order.
---@param buf integer
---@param word string
---@param boundary boolean
---@return integer[][]
local function occurrences(buf, word, boundary)
  local out = {}
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  for row, line in ipairs(lines) do
    local from = 1
    while true do
      local s = line:find(word, from, true)
      if not s then
        break
      end
      if not boundary or whole_word(line, s - 1, #word) then
        out[#out + 1] = { row - 1, s - 1 }
      end
      from = s + 1
    end
  end
  return out
end

---@param id integer
---@return integer row, integer col, integer end_row, integer end_col
local function range_of(id)
  local pos = api.nvim_buf_get_extmark_by_id(state.buf, ns, id, { details = true })
  return pos[1], pos[2], pos[3].end_row or pos[1], pos[3].end_col or pos[2]
end

---@return integer[] ids marks in buffer order
local function ordered()
  local ids = vim.deepcopy(state.marks)
  table.sort(ids, function(a, b)
    local ar, ac = range_of(a)
    local br, bc = range_of(b)
    return ar < br or (ar == br and ac < bc)
  end)
  return ids
end

---@param row integer
---@param col integer
---@param primary boolean
---@return integer id
local function mark_at(row, col, primary)
  return api.nvim_buf_set_extmark(state.buf, ns, row, col, {
    end_row = row,
    end_col = col + #state.word,
    hl_group = primary and "IncSearch" or "Visual",
    priority = 200,
  })
end

local clear

---@param mode string|string[]
---@param lhs string
---@param rhs fun()
local function bmap(lhs, rhs)
  vim.keymap.set(
    "n",
    lhs,
    rhs,
    { buffer = state.buf, nowait = true, silent = true, desc = "[Multicursor] " .. lhs }
  )
  state.keys[#state.keys + 1] = lhs
end

---Replace the text typed at the first anchor in every other anchor, bottom to top, as one undo step.
---@param anchors integer[] extmark ids (the first is where the typing happened)
---@param buf integer
local function replay(anchors, buf)
  local first = anchors[1]
  local pos = api.nvim_buf_get_extmark_by_id(buf, ns, first, {})
  if not pos or #pos == 0 then
    return
  end
  local stop = api.nvim_buf_get_mark(buf, "^")
  local lines = {}
  -- text from the anchor to where the insert ended
  if stop[1] > pos[1] + 1 or (stop[1] == pos[1] + 1 and stop[2] >= pos[2]) then
    local ok, got = pcall(api.nvim_buf_get_text, buf, pos[1], pos[2], stop[1] - 1, stop[2], {})
    if ok then
      lines = got
    end
  end
  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    return
  end
  local targets = {}
  for i = 2, #anchors do
    local p = api.nvim_buf_get_extmark_by_id(buf, ns, anchors[i], {})
    if p and #p > 0 then
      targets[#targets + 1] = p
    end
  end
  table.sort(targets, function(a, b)
    return a[1] > b[1] or (a[1] == b[1] and a[2] > b[2])
  end)
  pcall(vim.cmd, "undojoin")
  for _, p in ipairs(targets) do
    pcall(api.nvim_buf_set_text, buf, p[1], p[2], p[1], p[2], lines)
  end
end

---@param anchors_at { [1]: integer, [2]: integer }[] first is the primary
---@param buf integer
local function insert_at(anchors_at, buf)
  local ids = {}
  for _, p in ipairs(anchors_at) do
    ids[#ids + 1] = api.nvim_buf_set_extmark(buf, ns, p[1], p[2], { right_gravity = false })
  end
  local first = anchors_at[1]
  api.nvim_win_set_cursor(0, { first[1] + 1, first[2] })
  api.nvim_create_autocmd("InsertLeave", {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if api.nvim_buf_is_valid(buf) then
          replay(ids, buf)
          for _, id in ipairs(ids) do
            pcall(api.nvim_buf_del_extmark, buf, ns, id)
          end
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end

---Run `kind` over every mark: "c" change, "i" insert before, "a" append after, "d" delete.
---@param kind "c"|"i"|"a"|"d"
function M.edit(kind)
  if not state then
    return
  end
  local buf = state.buf
  local ids = ordered()
  local spots = {}
  for _, id in ipairs(ids) do
    local r, c, er, ec = range_of(id)
    spots[#spots + 1] = { r, c, er, ec }
  end
  clear()

  if kind == "d" or kind == "c" then
    for i = #spots, 1, -1 do
      local s = spots[i]
      pcall(api.nvim_buf_set_text, buf, s[1], s[2], s[3], s[4], { "" })
    end
    if kind == "d" then
      api.nvim_win_set_cursor(0, { spots[1][1] + 1, spots[1][2] })
      return
    end
    -- the first place's deletion shifted later places on the same line
    local shifted = {}
    local per_line = {}
    for _, s in ipairs(spots) do
      local removed = per_line[s[1]] or 0
      shifted[#shifted + 1] = { s[1], s[2] - removed }
      per_line[s[1]] = removed + (s[4] - s[2])
    end
    insert_at(shifted, buf)
    return
  end

  local at = {}
  for _, s in ipairs(spots) do
    at[#at + 1] = { s[1], (kind == "a") and s[4] or s[2] }
  end
  insert_at(at, buf)
end

---Remove every mark and the keys.
function clear()
  if not state then
    return
  end
  local s = state
  state = nil
  if api.nvim_buf_is_valid(s.buf) then
    pcall(api.nvim_buf_clear_namespace, s.buf, ns, 0, -1)
    for _, lhs in ipairs(s.keys) do
      pcall(vim.keymap.del, "n", lhs, { buffer = s.buf })
    end
  end
end

function M.clear()
  clear()
end

---Install the keys that exist while marks are active.
local function install_keys()
  state.keys = {}
  bmap("c", function()
    M.edit("c")
  end)
  bmap("s", function()
    M.edit("c")
  end)
  bmap("i", function()
    M.edit("i")
  end)
  bmap("a", function()
    M.edit("a")
  end)
  bmap("d", function()
    M.edit("d")
  end)
  bmap("x", function()
    M.edit("d")
  end)
  bmap("<C-n>", function()
    M.find_under()
  end)
  bmap("<C-x>", function()
    M.skip()
  end)
  bmap("<C-p>", function()
    M.undo_mark()
  end)
  bmap("<Esc>", function()
    clear()
  end)
  -- Marks belong to one buffer: leaving it drops them (and the buffer-local keys with them).
  api.nvim_create_autocmd("BufLeave", {
    buffer = state.buf,
    once = true,
    callback = function()
      if state and state.buf == api.nvim_get_current_buf() then
        clear()
      end
    end,
  })
end

---The word under the cursor or the single-line visual selection: its text, start column, row.
---@return string|nil word
---@return integer|nil row 0-based
---@return integer|nil col 0-based
---@return boolean|nil boundary
local function target_under_cursor()
  local mode = api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "\22" then
    local a, b = vim.fn.getpos("v"), vim.fn.getpos(".")
    if a[2] ~= b[2] then
      return nil
    end
    local row = a[2] - 1
    local c1, c2 = math.min(a[3], b[3]) - 1, math.max(a[3], b[3])
    local text = api.nvim_buf_get_text(0, row, c1, row, c2, {})[1]
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    return text ~= "" and text or nil, row, c1, false
  end
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()
  local start = col
  while start > 0 and is_kw(char_at(line, start - 1)) do
    start = start - 1
  end
  local stop = col
  while stop < #line and is_kw(char_at(line, stop)) do
    stop = stop + 1
  end
  if stop <= start then
    return nil
  end
  return line:sub(start + 1, stop), row - 1, start, true
end

---Mark the next free occurrence after `(after_r, after_c)` (default: the newest mark), wrapping around.
---@param after_r? integer
---@param after_c? integer
local function mark_next(after_r, after_c)
  local all = occurrences(state.buf, state.word, state.boundary)
  local taken = {}
  for _, id in ipairs(state.marks) do
    local r, c = range_of(id)
    taken[r .. ":" .. c] = true
  end
  if not after_r then
    after_r, after_c = range_of(state.marks[#state.marks])
  end
  local pick
  for _, p in ipairs(all) do
    if
      not taken[p[1] .. ":" .. p[2]] and (p[1] > after_r or (p[1] == after_r and p[2] > after_c))
    then
      pick = p
      break
    end
  end
  if not pick then
    for _, p in ipairs(all) do
      if not taken[p[1] .. ":" .. p[2]] then
        pick = p
        break
      end
    end
  end
  if not pick then
    return
  end
  state.marks[#state.marks + 1] = mark_at(pick[1], pick[2], false)
  api.nvim_win_set_cursor(0, { pick[1] + 1, pick[2] })
end

---First press: mark the word under the cursor (or the visual selection). Every further press: the next occurrence.
function M.find_under()
  if not state then
    local word, row, col, boundary = target_under_cursor()
    if not word then
      return
    end
    state = {
      buf = api.nvim_get_current_buf(),
      word = word,
      boundary = boundary == true,
      marks = {},
      keys = {},
    }
    state.marks[1] = mark_at(row, col, true)
    install_keys()
    return
  end

  mark_next()
end

---Skip the newest mark: drop it and mark the next occurrence instead.
function M.skip()
  if not state or #state.marks < 2 then
    return
  end
  local id = table.remove(state.marks)
  local dropped_r, dropped_c = range_of(id)
  api.nvim_buf_del_extmark(state.buf, ns, id)
  local count = #state.marks
  mark_next(dropped_r, dropped_c)
  if #state.marks == count then
    -- nothing else to mark: back to the last kept mark
    local r, c = range_of(state.marks[#state.marks])
    api.nvim_win_set_cursor(0, { r + 1, c })
  end
end

---Take back the newest mark (the first one is the last to go: then everything is cleared).
function M.undo_mark()
  if not state then
    return
  end
  if #state.marks <= 1 then
    clear()
    return
  end
  local id = table.remove(state.marks)
  api.nvim_buf_del_extmark(state.buf, ns, id)
  local r, c = range_of(state.marks[#state.marks])
  api.nvim_win_set_cursor(0, { r + 1, c })
end

---@return boolean
function M.active()
  return state ~= nil
end

---@return integer count of marked places
function M.count()
  return state and #state.marks or 0
end

---Map `<C-n>` (normal and visual) to start/continue.
function M.setup()
  vim.keymap.set({ "n", "x" }, "<C-n>", function()
    M.find_under()
  end, { desc = "[Multicursor] Mark word / next occurrence" })
end

return M
