-- TESTS/plugin_repos/runner_service_spec.lua -- scripts/runner_service.ps1: a runner as a Windows service (session 0,
-- no window on the desktop). Only what needs no administrator: the plan (service name, emptied variables), the status,
-- the refusal of install/remove without elevation, and runners.ps1 leaving a service runner alone. A fake runner folder;
-- nothing is installed, no service is touched.

---@param H table
return function(H)
  local eq, ok = H.eq, H.ok
  if vim.fn.has("win32") ~= 1 or vim.fn.executable("pwsh") ~= 1 then
    print("n/a  runner services exist on Windows only")
    return
  end
  local root_dir = vim.fn.getcwd()
  local script = vim.fs.joinpath(root_dir, "scripts", "runner_service.ps1")
  local runners = vim.fs.joinpath(root_dir, "scripts", "runners.ps1")
  ok(vim.uv.fs_stat(script) ~= nil, "the spec runs from the root of the config")

  ---@param code string
  ---@return integer code, string stdout
  local function pwsh(code)
    local done = vim
      .system({ "pwsh", "-NoProfile", "-NonInteractive", "-Command", code .. "; exit $LASTEXITCODE" }, {
        text = true,
        env = { NVIM_MACHINE_ROLE = "default" },
      })
      :wait(120000)
    return done.code, (done.stdout or "") .. (done.stderr or "")
  end

  -- An elevated test run would really install a service: refuse to run then.
  local _, elevated = pwsh(
    "([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')"
  )
  if vim.trim(elevated) == "True" then
    print("n/a  this spec does not run elevated (install would touch the real service manager)")
    return
  end

  local tmp = vim.fs.normalize(vim.fn.tempname())
  local dir = tmp .. "/tasks-vault"
  vim.fn.mkdir(dir .. "/bin", "p")
  local function write(path, text)
    local f = assert(io.open(path, "wb"))
    f:write(text)
    f:close()
  end
  -- .runner is written by config.cmd with a byte order mark
  write(dir .. "/.runner", "\239\187\191" .. vim.json.encode({
    agentName = "STEVESPC-tasks-vault",
    gitHubUrl = "https://github.com/WKDSteve/tasks-vault",
    workFolder = "_work",
  }))
  write(dir .. "/run.cmd", "@echo off\r\n")
  write(dir .. "/bin/RunnerService.exe", "")
  local win_root = tmp:gsub("/", "\\")

  local function plan()
    return pwsh(
      ("& '%s' plan tasks-vault -Root '%s' -EnvNames @('ANTHROPIC_API_KEY','LIB_NVIM_DIR','CLAUDE_X','CLAUDECODE','GITHUB_TOKEN','KEEP_ME','MYCLAUDE')"):format(
        script,
        win_root
      )
    )
  end

  local code, out = plan()
  eq(code, 0, "plan: " .. out)
  ok(
    out:find("service:  actions.runner.WKDSteve-tasks-vault.STEVESPC-tasks-vault", 1, true) ~= nil,
    "plan: the service name config.cmd would give: " .. out
  )
  ok(out:find("RunnerService.exe", 1, true) ~= nil, "plan: the runner's own service program")
  local emptied = out:match("emptied:%s+([^\r\n]*)") or ""
  eq(
    emptied,
    "ANTHROPIC_API_KEY, CLAUDE_X, CLAUDECODE, LIB_NVIM_DIR",
    "plan: keys, session variables and checkout overrides are emptied"
  )
  ok(
    not emptied:find("GITHUB_TOKEN", 1, true)
      and not emptied:find("KEEP_ME", 1, true)
      and not emptied:find("MYCLAUDE", 1, true),
    "plan: other variables stay"
  )
  ok(out:find("started by runners.ps1", 1, true) ~= nil, "plan: not a service yet")

  code, out = pwsh(("& '%s' install tasks-vault -Root '%s'"):format(script, win_root))
  eq(code, 2, "install without elevation is refused: " .. out)
  ok(out:find("needs an elevated PowerShell", 1, true) ~= nil, "install: says why and how")
  code = pwsh(("& '%s' remove tasks-vault -Root '%s'"):format(script, win_root))
  eq(code, 2, "remove without elevation is refused")
  ok(vim.uv.fs_stat(dir .. "/.service") == nil, "a refused install writes nothing")

  -- the runner as a service: status names it, runners.ps1 leaves it alone
  write(dir .. "/.service", "actions.runner.WKDSteve-tasks-vault.spec-does-not-exist")
  _, out = plan()
  ok(out:find("runs as a service already", 1, true) ~= nil, "plan: knows the service: " .. out)
  code, out = pwsh(("& '%s' status -Root '%s'"):format(script, win_root))
  eq(code, 0, "status")
  ok(
    out:find("tasks-vault", 1, true) and out:find("MISSING", 1, true),
    "status: a .service without a service is named: " .. out
  )

  code, out = pwsh(("& '%s' stop tasks-vault -Root '%s'"):format(runners, win_root))
  eq(code, 0, "runners.ps1 stop: " .. out)
  ok(
    out:find("runs as a service: left alone", 1, true) ~= nil,
    "runners.ps1 stop leaves the service runner alone: " .. out
  )

  vim.fn.delete(tmp, "rf")
end
