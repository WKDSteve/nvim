---@module 'machine_once'
---@brief Setup steps that run once per machine, on the first interactive start of nvim there.
---@description
--- A step that a machine has to do once (a key, a git setting) but that nobody remembers to run by hand. Each
--- step names the machines it is for (`hosts`: COMPUTERNAME, compared without case; `roles`: `machine.is`), runs
--- in the background when nvim has a UI, and says how it went. No marker file: a step knows from its result
--- whether it is done (`done(host)`, e.g. the device registry has a line for this machine), so nothing is left
--- behind once it is, and a failed or undone step runs again on the next start. Skipped: headless nvim (specs,
--- scripts) and a Claude session (`CLAUDECODE`: the Claude app redirects AppData and the registry, so the step
--- would land in its container).

local M = {}

local notify = require("lib.nvim.notify").create("[machine_once]")

---@class MachineOnce.Step
---@field id string Name in the messages
---@field hosts? string[] COMPUTERNAME values the step is for
---@field roles? string[] Machine roles (`machine.is`) the step is for
---@field argv string[] The command
---@field what string What it does, for the message
---@field done fun(host: string): boolean Whether the step's result is already there on this machine

-- pwsh when there is one, else the Windows PowerShell every Windows has
local shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"

local cdx = vim.fn.stdpath("config") .. "/docs/NOTES/CDX"

---Does the device registry (an allowed_signers file) have a line whose principals name `host`?
---@param path string
---@param host string
---@return boolean
function M.registered(path, host)
  local f = io.open(path, "r")
  if not f then
    return false
  end
  local want = host:lower()
  local found = false
  for line in f:lines() do
    local principals = line:match("^%s*([^%s#]+)") or ""
    for p in principals:gmatch("[^,]+") do
      if p:lower() == want then
        found = true
      end
    end
  end
  f:close()
  return found
end

---@type MachineOnce.Step[]
M.steps = {
  {
    -- each device signs its commits; its key goes into the device registry of the runner-guard
    -- (docs/NOTES/CDX/README.md, testing.nvim docs/RUNNER-GUARD.md)
    id = "git-signing",
    hosts = { "OHANA" },
    roles = { "workstation" },
    argv = {
      shell,
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      cdx .. "/setup-git-signing.ps1",
    },
    what = "commit signing and the entry in the device registry (setup-git-signing.ps1)",
    -- the script writes the registry line last, after the key and the git settings
    done = function(host)
      return M.registered(cdx .. "/git-allowed-signers", host)
    end,
  },
}

---@class MachineOnce.Ctx A seam for specs; the start passes none.
---@field host? string
---@field is_role? fun(role: string): boolean
---@field has_ui? boolean
---@field claude? boolean
---@field spawn? fun(argv: string[], done: fun(code: integer, out: string))
---@field notify? fun(msg: string, level: integer)

---@param step MachineOnce.Step
---@param host string
---@param is_role fun(role: string): boolean
---@return boolean
local function applies(step, host, is_role)
  for _, h in ipairs(step.hosts or {}) do
    if h:lower() == host:lower() then
      return true
    end
  end
  for _, r in ipairs(step.roles or {}) do
    if is_role(r) then
      return true
    end
  end
  return false
end

---@param argv string[]
---@param done fun(code: integer, out: string)
local function spawn(argv, done)
  local ok, err = pcall(vim.system, argv, { text = true }, function(r)
    vim.schedule(function()
      done(r.code, vim.trim((r.stdout or "") .. "\n" .. (r.stderr or "")))
    end)
  end)
  if not ok then
    done(-1, tostring(err))
  end
end

---Start every step that is due on this machine. Returns the ids it started.
---@param ctx? MachineOnce.Ctx
---@return string[]
function M.run(ctx)
  ctx = ctx or {}
  local has_ui = ctx.has_ui
  if has_ui == nil then
    has_ui = #vim.api.nvim_list_uis() > 0
  end
  local claude = ctx.claude
  if claude == nil then
    claude = (vim.env.CLAUDECODE or "") ~= ""
  end
  if not has_ui or claude then
    return {}
  end
  local host = ctx.host or vim.env.COMPUTERNAME or vim.uv.os_gethostname() or ""
  local is_role = ctx.is_role or function(role)
    return require("machine").is(role)
  end
  local say = ctx.notify or function(msg, level)
    notify.notify(msg, level)
  end
  local run = ctx.spawn or spawn
  local started = {}
  for _, step in ipairs(M.steps) do
    if applies(step, host, is_role) and not step.done(host) then
      started[#started + 1] = step.id
      say(("once on %s: %s ..."):format(host, step.what), vim.log.levels.INFO)
      run(step.argv, function(code, out)
        -- exit 0 without the result is no success either: the step runs again
        if code ~= 0 or not step.done(host) then
          say(
            ("%s failed (exit %d), runs again on the next start:\n%s"):format(step.id, code, out),
            vim.log.levels.ERROR
          )
          return
        end
        say(("%s done, it does not run here again:\n%s"):format(step.id, out), vim.log.levels.WARN)
      end)
    end
  end
  return started
end

return M
