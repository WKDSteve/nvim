-- TESTS/plugin_repos/runner_detached_spec.lua -- scripts/runner_detached.ps1: a runner starts outside the caller's
-- job and without the variables of a Claude Code session, but with the rest of the caller's environment.

---@param H table
return function(H)
  local eq, ok = H.eq, H.ok
  if vim.fn.has("win32") ~= 1 or vim.fn.executable("pwsh") ~= 1 then
    print("n/a  a detached runner start exists on Windows only (needs pwsh on Windows)")
    return
  end
  local script = vim.fs.joinpath(vim.fn.getcwd(), "scripts", "runner_detached.ps1")
  ok(vim.uv.fs_stat(script) ~= nil, "the spec runs from the root of the config")

  -- What a session would hand over; MYCLAUDE_X and KEEP_ME only look alike and stay.
  local session_env = {
    CLAUDECODE = "1",
    CLAUDE_CODE_SESSION_ID = "spec-session",
    CLAUDE_CODE_MESSAGING_TOKEN = "spec-token",
    ANTHROPIC_BASE_URL = "https://spec.invalid",
    MYCLAUDE_X = "kept",
    KEEP_ME = "kept",
  }

  ---@param code string PowerShell after the dot-source
  ---@return string stdout
  local function pwsh(code)
    local done = vim
      .system({
        "pwsh",
        "-NoProfile",
        "-NonInteractive",
        "-Command",
        ("$ErrorActionPreference = 'Stop'; . '%s'; %s"):format(script, code),
      }, { text = true, env = session_env })
      :wait(60000)
    eq(done.code, 0, tostring(done.stderr))
    return done.stdout
  end

  ---@param text string NAME=value lines
  ---@return table<string, string>
  local function names(text)
    local found = {}
    for line in text:gmatch("[^\r\n]+") do
      local name = line:match("^([^=]+)=")
      if name then
        found[name:upper()] = line
      end
    end
    return found
  end

  ---@param found table<string, string>
  ---@param what string
  local function check(found, what)
    for _, gone in ipairs({
      "CLAUDECODE",
      "CLAUDE_CODE_SESSION_ID",
      "CLAUDE_CODE_MESSAGING_TOKEN",
      "ANTHROPIC_BASE_URL",
    }) do
      eq(found[gone], nil, what .. ": " .. gone .. " is left out")
    end
    eq(found.KEEP_ME, "KEEP_ME=kept", what .. ": an ordinary variable is handed over")
    eq(found.MYCLAUDE_X, "MYCLAUDE_X=kept", what .. ": only the anchored names are left out")
    ok(found.PATH ~= nil, what .. ": PATH is handed over (scoop shims, Git, nvim)")
  end

  check(names(pwsh("Get-RunnerEnvironment")), "Get-RunnerEnvironment")

  -- The real start: a .cmd that writes its environment and the name of its parent's parent (cmd.exe < WmiPrvSE).
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local out = vim.fs.joinpath(dir, "env.txt")
  local cmd = vim.fs.joinpath(dir, "run.cmd")
  local fh = assert(io.open(cmd, "wb"))
  fh:write("@echo off\r\nset > env.tmp\r\nmove /y env.tmp env.txt > nul\r\n")
  fh:close()
  local started = pwsh(
    ("$p = Start-Detached -Exe '%s' -Dir '%s'; "):format(
      (cmd:gsub("/", "\\")),
      (dir:gsub("/", "\\"))
    )
      .. '$c = Get-CimInstance Win32_Process -Filter "ProcessId=$p"; '
      .. "if ($c) { (Get-CimInstance Win32_Process -Filter \"ProcessId=$($c.ParentProcessId)\").Name } else { 'gone' }"
  )
  local parent = vim.trim(started)
  ok(
    parent == "WmiPrvSE.exe" or parent == "gone",
    "the runner's cmd.exe is a child of WMI, not of the caller: " .. parent
  )
  ok(
    vim.wait(15000, function()
      return vim.uv.fs_stat(out) ~= nil
    end, 100),
    "the started .cmd ran in its folder"
  )
  local text = assert(io.open(out, "rb")):read("*a")
  check(names(text), "the started process")
  vim.fn.delete(dir, "rf")
end
