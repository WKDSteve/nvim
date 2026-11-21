---@module 'bindings.usrcmds.powershell_profile'
---@brief `:PowershellProfile`: open the file Windows PowerShell names as `$PROFILE`, without making the editor wait.
---@description
--- Only Windows PowerShell itself knows `$PROFILE` reliably (the Documents folder may be redirected,
--- e.g. to OneDrive), and starting it takes 0.2 s on an idle machine and several seconds on a busy
--- one (8 s measured by testing perf, 2026-11-21). So the path is asked for in the background, once
--- per session: the answer is kept, the next `:PowershellProfile` opens the file at once.
---
--- The file opens in the window the command was given in, once the answer is in. A newer
--- `:PowershellProfile` before the answer replaces the older one (the answer opens the file once).

local notify = require("lib.nvim.notify").create("[bindings.usrcmds]")

local M = {}

---The query: a bare program name, no shell, no profile scripts, no prompt.
M.ARGV = {
  "powershell",
  "-NoLogo",
  "-NoProfile",
  "-NonInteractive",
  "-Command",
  "[Console]::Write($PROFILE)",
}

---Upper bound for the query (ms); a PowerShell that hangs longer counts as a failure.
M.TIMEOUT_MS = 30000

---The path PowerShell named, once known (it does not change within a session).
---@type string|nil
local cached = nil

---Callbacks waiting for the query that is running; nil while none runs.
---@type (fun(path: string|nil, err: string|nil))[]|nil
local waiters = nil

---The `M.open` whose answer is still awaited: a fresh table per call, so a newer call (or
---`M.cancel`) makes the older answer go nowhere.
---@type table|nil
local pending = nil

---@param path string|nil
---@param err string|nil
local function finish(path, err)
  local list = waiters or {}
  waiters = nil
  if path then
    cached = path
  end
  for _, cb in ipairs(list) do
    cb(path, err)
  end
end

---The `$PROFILE` path, from the session cache or from a PowerShell started in the background.
---`on_done(path, err)` runs on the main loop: at once when the path is known, else after the
---query. Calls during a running query share it (one PowerShell start).
---@param on_done fun(path: string|nil, err: string|nil)
function M.path_async(on_done)
  if cached then
    on_done(cached, nil)
    return
  end
  if waiters then
    waiters[#waiters + 1] = on_done
    return
  end
  waiters = { on_done }
  local ok, err = pcall(vim.system, M.ARGV, { text = true, timeout = M.TIMEOUT_MS }, function(res)
    vim.schedule(function()
      local out = res.code == 0 and vim.trim(res.stdout or "") or ""
      if out ~= "" then
        finish(out, nil)
      else
        local why = vim.trim(res.stderr or "")
        finish(
          nil,
          why ~= "" and why or ("powershell exited with code %s"):format(tostring(res.code))
        )
      end
    end)
  end)
  if not ok then
    finish(nil, "powershell could not be started: " .. tostring(err))
  end
end

---Open the profile in the current window, now (path known) or once PowerShell has answered.
function M.open()
  if vim.fn.executable("powershell") ~= 1 then
    notify.error("Error: powershell is not available on this system.")
    return
  end
  local this = { win = vim.api.nvim_get_current_win() }
  pending = this
  M.path_async(function(path, err)
    if pending ~= this then
      return
    end
    pending = nil
    if not path then
      notify.error(
        "Error: could not determine the PowerShell profile path (" .. tostring(err) .. ")."
      )
      return
    end
    local ok, edit_err = pcall(function()
      if vim.api.nvim_win_is_valid(this.win) then
        vim.api.nvim_set_current_win(this.win)
      end
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end)
    if not ok then
      notify.error("Error: could not open " .. path .. ": " .. tostring(edit_err))
    end
  end)
end

---Drop a pending `M.open` (its answer then opens nothing).
function M.cancel()
  pending = nil
end

---Forget the cached path and any running query (specs only).
function M._reset()
  cached, waiters, pending = nil, nil, nil
end

return M
