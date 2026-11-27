-- TESTS/plugin_repos/runner_window_guard_spec.lua -- scripts/runner_window_guard.ps1: the job-completed hook lists the
-- windows whose process chain passes through its own Runner.Worker, and -Ensure keeps one watcher for the machine.

---@param path string
---@param text string
local function write(path, text)
  local file = assert(io.open(path, "wb"))
  file:write(text)
  file:close()
end

---@param H table
return function(H)
  local eq, ok = H.eq, H.ok
  if vim.fn.has("win32") ~= 1 or vim.fn.executable("pwsh") ~= 1 then
    print("n/a  the window guard watches Windows desktops only (needs pwsh on Windows)")
    return
  end
  local script = vim.fs.joinpath(vim.fn.getcwd(), "scripts", "runner_window_guard.ps1")
  ok(vim.uv.fs_stat(script) ~= nil, "the spec runs from the root of the config")

  -- The watcher's working folder is never the log folder: called from a packaged app (the Claude desktop app), a
  -- folder made under AppData\Local lands in the app's virtual view, WMI does not see it and the start fails (8).
  local text = table.concat(vim.fn.readfile(script), "\n")
  ok(text:find("CurrentDirectory = $env:USERPROFILE", 1, true), "the watcher starts in the profile")
  ok(not text:find("CurrentDirectory = $LogDir", 1, true), "never in the log folder")

  ---@param args string[]
  ---@param env table|nil
  ---@return integer, string
  local function guard(args, env)
    local cmd = { "pwsh", "-NoProfile", "-NonInteractive", "-File", script }
    vim.list_extend(cmd, args)
    local done = vim
      .system(cmd, { text = true, env = vim.tbl_extend("force", { NVIM_MACHINE_ROLE = "" }, env or {}) })
      :wait(60000)
    return done.code, (done.stdout or "") .. (done.stderr or "")
  end

  -- A log with three windows: two of the job of worker 4242 (one deep in its chain), one of another runner's job.
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local function rec(at, class, title, chain)
    return vim.json.encode({ at = at, class = class, title = title, chain = chain })
  end
  local mine = { pid = 4242, name = "Runner.Worker.exe" }
  local other = { pid = 5151, name = "Runner.Worker.exe" }
  write(vim.fs.joinpath(dir, "windows-20261127-010000.jsonl"), table.concat({
    rec("01:00:01.000", "PseudoConsoleWindow", "", {
      { pid = 11, name = "cmd.exe" },
      { pid = 12, name = "pwsh.exe" },
      mine,
      { pid = 1, name = "Runner.Listener.exe" },
    }),
    rec("01:00:02.000", "ConsoleWindowClass", "setup", { { pid = 21, name = "cmd.exe" }, other }),
    "not json",
    rec("01:00:03.000", "ConsoleWindowClass", "node", { { pid = 31, name = "node.exe" }, mine }),
    -- the same pid, but not a worker: a reused pid of another program does not count
    rec("01:00:04.000", "ConsoleWindowClass", "", { { pid = 4242, name = "notepad.exe" } }),
  }, "\n") .. "\n")

  local since = { "-Since", "2000-01-01" }
  local code, said =
    guard(vim.list_extend({ "-Report", "-WorkerPid", "4242", "-LogDir", dir }, since))
  eq(code, 0, "a report never fails the job: " .. said)
  local _, warnings = said:gsub("::warning title=window%-guard::", "")
  eq(warnings, 2, "the two windows of this worker, not the other runner's: " .. said)
  ok(
    said:find("cmd.exe <- pwsh.exe <- Runner.Worker.exe", 1, true),
    "the chain up to the worker: " .. said
  )
  ok(not said:find("Runner.Listener", 1, true), "nothing above the worker")
  ok(not said:find("setup", 1, true), "not the other worker's window")
  ok(said:find("this job opened 2 window(s)", 1, true), said)

  code, said = guard(vim.list_extend({ "-Report", "-WorkerPid", "7777", "-LogDir", dir }, since))
  eq(code, 0, said)
  ok(said:find("this job opened no window", 1, true), "a job without windows says so: " .. said)

  code, said = guard({ "-Report", "-LogDir", dir })
  eq(code, 0, said)
  ok(said:find("not inside a runner job", 1, true), "outside a job it says so: " .. said)

  code, said = guard(
    { "-Report", "-WorkerPid", "4242", "-LogDir", dir },
    { NVIM_MACHINE_ROLE = "Workstation" }
  )
  eq(code, 0, said)
  ok(said:find("not on the workstation", 1, true), "on the workstation nothing runs: " .. said)

  code = guard({})
  eq(code, 2, "neither -Ensure nor -Report: usage")

  code, said =
    guard({ "-Ensure", "-LogDir", dir, "-WindowLog", vim.fs.joinpath(dir, "no-such-logger.ps1") })
  eq(code, 0, "a missing logger never stops a runner start: " .. said)
  ok(said:find("has no window logger", 1, true), said)

  -- A real watcher, briefly, in a folder of its own: -Ensure starts it once and finds it the second time.
  local repos = vim.env.REPOS_DIR
  local logger = repos
    and vim.fs.joinpath(
      repos,
      "tasks-vault",
      "TOOLS",
      "scripts",
      "app-proc-watch",
      "window-log.ps1"
    )
  if not logger or not vim.uv.fs_stat(logger) then
    print("n/a  -Ensure with a real watcher: window-log.ps1 of the tasks-vault is not here")
  else
    local live = vim.fn.tempname()
    code, said = guard({ "-Ensure", "-LogDir", live, "-WindowLog", logger, "-Seconds", "20" })
    eq(code, 0, said)
    ok(said:find("watcher started", 1, true), said)
    local found = vim.wait(30000, function()
      local _, again = guard({ "-Ensure", "-LogDir", live, "-WindowLog", logger, "-Seconds", "20" })
      return again:find("the watcher runs", 1, true) ~= nil
    end, 1000)
    ok(found, "a second -Ensure finds the running watcher instead of starting another")
    -- the logger writes its file once its hook runs (up to 5 s after the start)
    local logs = {}
    vim.wait(20000, function()
      logs = {}
      for name in vim.fs.dir(live) do
        if name:match("^windows%-.*%.jsonl$") then
          logs[#logs + 1] = name
        end
      end
      return #logs > 0
    end, 500)
    eq(#logs, 1, "one watcher, one log file: " .. table.concat(logs, ", "))
    vim.fn.delete(live, "rf")
  end

  vim.fn.delete(dir, "rf")
end
