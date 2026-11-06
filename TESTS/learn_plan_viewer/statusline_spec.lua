-- TESTS/learn_plan_viewer/statusline_spec.lua -- the progress the statusline shows: empty until a week is open,
-- the ticked boxes of that week's page, read once and again only after a write.

---@param H table
local function spec(H)
  local eq = H.eq
  local config = require("bindings.usrcmds.learn_plan_viewer.config")
  local statusline = require("bindings.usrcmds.learn_plan_viewer.statusline")

  local dir = H.tmpdir()
  local real_path = config.week_path
  config.week_path = function(n)
    return dir .. "/week-" .. n .. ".md"
  end
  local ok_run, err = pcall(function()
    eq(statusline.status(), "", "nothing before a week was opened")

    H.write(dir .. "/week-3.md", "- [x] one\n- [ ] two\n* [X] three\ntext [x] not a box\n")
    statusline.set_week(3)
    eq(statusline.status(), "Woche 3/12 · 2 Checks", "only list items count, in either case")

    -- A statusline runs on every redraw: the file is read once.
    H.write(dir .. "/week-3.md", "- [x] one\n- [x] two\n- [x] three\n")
    eq(statusline.status(), "Woche 3/12 · 2 Checks", "the file is not read on every redraw")
    statusline.invalidate()
    eq(statusline.status(), "Woche 3/12 · 3 Checks", "after a write the new count")

    H.write(dir .. "/week-4.md", "- [ ] none\n")
    statusline.set_week(4)
    eq(statusline.status(), "Woche 4/12", "no ticked box: no count")

    statusline.set_week(5) -- a page that is not there
    eq(statusline.status(), "Woche 5/12", "a missing page is no error")
  end)
  config.week_path = real_path
  statusline.reset()
  if not ok_run then
    error(err, 0)
  end
end

return spec
