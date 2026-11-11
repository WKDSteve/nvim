-- TESTS/multicursor/multicursor_spec.lua -- the <C-n> flow of lua/multicursor: mark a word, mark the next
-- occurrences, change/insert/append/delete them all at once, skip, take back, clear. Keys are typed with
-- nvim_feedkeys so the buffer-local mappings and the InsertLeave replay run for real.

return function(H)
  local eq, ok = H.eq, H.ok
  local mc = require("multicursor")

  local function feed(keys)
    local t = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(t, "x", false)
    -- the InsertLeave replay is scheduled
    vim.wait(100, function()
      return false
    end)
  end

  local function fresh(lines, cursor)
    vim.cmd("enew!")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, cursor)
    -- the set_lines above is its own undo step, not part of the edit under test
    vim.cmd("let &undolevels = &undolevels")
    mc.clear()
  end
  local function text()
    return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "|")
  end

  -- marking: the word under the cursor, then the next occurrences, wrapping, whole words only
  fresh({ "foo bar foo", "foobar foo", "a foo" }, { 1, 0 })
  mc.find_under()
  ok(mc.active() and mc.count() == 1, "the first press marks the word under the cursor")
  mc.find_under()
  eq(mc.count(), 2, "the second press marks the next occurrence")
  eq(vim.api.nvim_win_get_cursor(0)[2], 8, "...and moves the cursor there")
  mc.find_under()
  mc.find_under()
  eq(
    mc.count(),
    4,
    "line 2's 'foobar' is not a whole-word match; its trailing 'foo' and line 3's are"
  )
  mc.find_under()
  eq(mc.count(), 4, "nothing left to mark")
  mc.clear()
  ok(not mc.active(), "clear drops the state")

  -- change: the text typed at the first place appears in all of them, as one undo step
  fresh({ "foo bar foo", "foobar foo", "a foo" }, { 1, 0 })
  mc.find_under()
  mc.find_under()
  mc.find_under()
  mc.find_under()
  feed("cXY<Esc>")
  eq(text(), "XY bar XY|foobar XY|a XY", "c replaces every marked word with what was typed")
  ok(not mc.active(), "the marks are gone after the edit")
  feed("u")
  eq(text(), "foo bar foo|foobar foo|a foo", "one undo restores all of it")

  -- append / insert before
  fresh({ "x foo y foo" }, { 1, 2 })
  mc.find_under()
  mc.find_under()
  feed("a!<Esc>")
  eq(text(), "x foo! y foo!", "a appends after every marked word")
  fresh({ "x foo y foo" }, { 1, 2 })
  mc.find_under()
  mc.find_under()
  feed("i<<Esc>")
  eq(text(), "x <foo y <foo", "i inserts before every marked word")

  -- delete
  fresh({ "foo a foo b", "foo" }, { 1, 0 })
  mc.find_under()
  mc.find_under()
  mc.find_under()
  feed("d")
  eq(text(), " a  b|", "d deletes every marked word")
  feed("u")
  eq(text(), "foo a foo b|foo", "and is one undo step")

  -- several places on one line shift correctly while typing
  fresh({ "aa aa aa" }, { 1, 0 })
  mc.find_under()
  mc.find_under()
  mc.find_under()
  feed("cbbb<Esc>")
  eq(text(), "bbb bbb bbb", "marks on one line stay in place as the text grows")

  -- multi-line text typed in Insert mode is replicated as typed
  fresh({ "k-k" }, { 1, 0 })
  mc.find_under()
  mc.find_under()
  feed("cA<CR>B<Esc>")
  eq(text(), "A|B-A|B", "a typed newline is replicated")

  -- skip and take back
  fresh({ "w w w w" }, { 1, 0 })
  mc.find_under()
  mc.find_under()
  eq(mc.count(), 2, "two marked")
  mc.skip()
  eq(mc.count(), 2, "skip drops the newest and marks the one after it")
  eq(vim.api.nvim_win_get_cursor(0)[2], 4, "...the cursor is on the third word")
  mc.undo_mark()
  eq(mc.count(), 1, "undo_mark takes back the newest")
  mc.undo_mark()
  ok(not mc.active(), "taking back the last one clears everything")

  -- a visual selection marks exactly that text, not whole words
  fresh({ "abc ab abc" }, { 1, 0 })
  feed("vl")
  mc.find_under()
  mc.find_under()
  mc.find_under()
  eq(
    mc.count(),
    3,
    "the selected 'ab' is found inside 'abc' too (no word boundary for a selection)"
  )
  mc.clear()

  -- the buffer-local keys exist only while marks are active
  fresh({ "foo foo" }, { 1, 0 })
  local function has_local(lhs)
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
      if m.lhs == lhs then
        return true
      end
    end
    return false
  end
  ok(not has_local("c"), "no buffer-local c before marking")
  mc.find_under()
  ok(has_local("c") and has_local("<Esc>"), "the keys appear with the first mark")
  mc.clear()
  ok(not has_local("c"), "and are gone after clear")

  -- not on a word: nothing happens
  fresh({ "   " }, { 1, 1 })
  mc.find_under()
  ok(not mc.active(), "whitespace marks nothing")
end
