---@module 'bindings.autocmds.git.defaults'

---@type AutoCmds.Git.Cfg
local AUTOCMDS_GIT_DEFAULTS = {
  commit_ft = {
    enable = true,
    spell = true,
    textwidth = 72,
    colorcolumn = "73",
    formatoptions = "tcqj",
    start_in_insert = false,
  },
  -- Off: gitsigns keeps itself current. watch_gitdir sees external `git add`
  -- and commits, a reloaded buffer re-diffs, and its own BufEnter handler runs
  -- the updates it deferred for hidden buffers. refresh() on top re-read the
  -- index blob of every attached buffer on each event: 8 extra `git show` per
  -- scripted 100 s session (A/B 2026-11-18, task
  -- nvim-config/gitsigns-refresh-git-churn). Enable only where the watcher
  -- cannot work (network drives without fs events).
  gitsigns_refresh = {
    enable = false,
    events = { "FocusGained" },
  },
  blame_on_hold = {
    enable = false,
    delay = 0,
    virt = true,
    ignore_buftypes = { "nofile", "prompt" },
  },
}

local M = {}

---@return AutoCmds.Git.Cfg
function M.get_defaults()
  return AUTOCMDS_GIT_DEFAULTS
end

return M
