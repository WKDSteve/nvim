---@module 'bindings.autocmds.git.gitsigns_refresh'
--- Refresh gitsigns hunks on focus/enter to keep UI accurate.

---@class AutoCmds.Git.GitsignsRefresh
local M = {}

local Autocmd = require("lib.nvim.bindings.autocmd")

---@param cfg AutoCmds.Git.GitsignsRefreshCfg
---@param shared table
---@return nil
function M.enable(cfg, shared)
  if not (cfg and cfg.enable) then
    return
  end

  local events = shared.norm_events(cfg.events, { "BufEnter", "FocusGained" })
  Autocmd.create(events, function()
    -- Never `require` it here: that loaded gitsigns with the first buffer, long before its own
    -- trigger. Not loaded yet means nothing to refresh.
    local gs = package.loaded["gitsigns"]
    if type(gs) == "table" and gs.refresh then
      pcall(gs.refresh)
    end
  end, {
    group = shared.augroup("gitsigns_refresh"),
    desc = "Git: refresh gitsigns on focus/enter",
  })
end

return M
