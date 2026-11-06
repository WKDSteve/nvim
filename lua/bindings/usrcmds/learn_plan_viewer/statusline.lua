---@module 'bindings.usrcmds.learn_plan_viewer.statusline'
--- The progress of `:LearnPlanViewer` for a statusline, e.g. "Woche 3/12 · 5 Checks": the week open in this
--- session and the ticked boxes on its page. Empty until a week was opened, so a statusline that reads this through
--- `package.loaded` shows nothing in a session without the viewer. A statusline runs on every redraw, so the page is
--- read once and again only after the viewer said it was written.

local config = require("bindings.usrcmds.learn_plan_viewer.config")

local M = {}

---@type integer|nil
local week
---@type string|nil
local cached

---The ticked boxes of a page: list items only, a `[x]` in running text is no box.
---@param path string
---@return integer
local function ticked(path)
  if vim.fn.filereadable(path) ~= 1 then
    return 0
  end
  local count = 0
  for _, line in ipairs(vim.fn.readfile(path)) do
    if line:match("^%s*[-*+]%s+%[[xX]%]") then
      count = count + 1
    end
  end
  return count
end

---The week the viewer has open.
---@param n integer
function M.set_week(n)
  week = n
  cached = nil
end

---The page of the open week was written.
function M.invalidate()
  cached = nil
end

---Back to "nothing open" (for the specs).
function M.reset()
  week = nil
  cached = nil
end

---@return string
function M.status()
  if not week then
    return ""
  end
  if not cached then
    local checks = ticked(config.week_path(week))
    cached = ("Woche %d/%d"):format(week, config.week_count)
    if checks > 0 then
      cached = ("%s · %d Checks"):format(cached, checks)
    end
  end
  return cached
end

return M
