-- TESTS/plugin_repos/runner_spec.lua -- :MyPlugins runner: the pure data functions (is_known, runner_dir,
-- terminal_name). start/stop/status are not tested here: they drive a real terminal.nvim job (or gh api),
-- not deterministic data in, data out.

---@param H table
local function spec(H)
  local eq, ok = H.eq, H.ok
  local runner = require("bindings.usrcmds.plugin_repos.runner")

  for _, name in ipairs({
    "casedesk.nvim",
    "my.nvim",
    "tasks.nvim",
    "rules.nvim",
    "tasks-vault",
    "rules-vault",
    "appkit",
    "tasks-desktop",
    "rules-desktop",
    "ai-desktop",
    "docmap-desktop",
  }) do
    ok(runner.is_known(name), name .. " has a self-hosted runner")
  end
  ok(not runner.is_known("lib.nvim"), "a repo with no self-hosted runner is not known")

  local saved = vim.env.USERPROFILE
  vim.env.USERPROFILE = "C:\\Users\\tester"
  eq(
    runner.runner_dir("casedesk.nvim"),
    "C:/Users/tester/actions-runners/casedesk.nvim",
    "runner_dir is USERPROFILE/actions-runners/<name>, forward slashes"
  )
  vim.env.USERPROFILE = saved

  eq(
    runner.terminal_name("casedesk.nvim"),
    "runner-casedesk.nvim",
    "terminal name is runner-<repo>"
  )

  eq(#runner.REPOS, 11, "eleven runners are registered")

  -- autostart: the calls are built, not run (running them would change the real scheduled tasks)
  local script = runner.autostart_script("Task X", "C:\\cfg\\scripts\\runners.ps1")
  H.has(script, 'runners.ps1" ensure all', "the task runs runners.ps1 ensure all")
  H.has(script, "-AtLogOn", "one trigger is the logon")
  H.has(script, "-RepetitionInterval (New-TimeSpan -Hours 1)", "the other repeats every hour")
  H.has(script, "-MultipleInstances IgnoreNew", "two runs never overlap")
  H.has(script, "-Hidden", "the task stays hidden")
  H.has(script, "--headless", "no console window opens (conhost --headless)")
  H.has(script, "Register-ScheduledTask -TaskName 'Task X'", "the task has the given name")
  H.has(script, "-Force", "an existing task is replaced, not an error")

  local status_script = runner.autostart_status_script("Task X")
  H.has(status_script, "Get-ScheduledTask -TaskName 'Task X'", "status reads the task")
  H.has(status_script, "$t.Triggers", "status lists every trigger")

  for _, action in ipairs({ "on", "status" }) do
    local argv = assert(runner.autostart_argv(action))
    ok(argv[1] == "pwsh" or argv[1] == "powershell", action .. " goes through PowerShell")
    eq(argv[4], "-Command", action .. " hands the script over as plain text")
    eq(#argv, 5, action .. ": the script is one argument")
    -- an encoded command line is what Falcon reads as obfuscation; `status` runs on the workstation
    for _, word in ipairs(argv) do
      ok(
        not word:lower():match("^%-enc"),
        action .. " has no -EncodedCommand (or its -enc abbreviations)"
      )
    end
    H.has(argv[5], runner.AUTOSTART_TASK, action .. " names the fixed task")
    H.has(
      argv[5],
      "$ProgressPreference = 'SilentlyContinue'",
      action .. " keeps the progress records (`#< CLIXML`) out of the notification"
    )
  end
  H.has(
    runner.autostart_argv("on")[5],
    "scripts\\runners.ps1",
    "the script path has backslashes (a Windows path)"
  )

  -- the script reaches PowerShell as it was written: quotes, backslashes and lines, and a failure is an exit code
  -- (autostart tells "no such task" by it). Run for real, with a script that changes nothing.
  local probe = runner.pwsh_argv(table.concat({
    "$ErrorActionPreference = 'Stop'",
    [[$run = '--headless pwsh -File "C:\a b\runners.ps1" ensure all']],
    "$run",
    [["two: " + (1 + 1)]],
  }, "\n"))
  if vim.fn.executable(probe[1]) ~= 1 then
    print("n/a  no PowerShell on this machine: the round trip of the script is not run")
  else
    local res = vim.system(probe, { text = true }):wait(60000)
    eq(res.code, 0, "the probe script runs: " .. (res.stderr or ""))
    eq(
      vim.split(vim.trim((res.stdout or ""):gsub("\r", "")), "\n"),
      { [[--headless pwsh -File "C:\a b\runners.ps1" ensure all]], "two: 2" },
      "quotes, backslashes and lines arrive unchanged"
    )
    local fail = vim
      .system(
        runner.pwsh_argv(
          "$ErrorActionPreference = 'Stop'\nGet-Item 'C:\\no\\such\\file-zz'\n'not reached'"
        ),
        { text = true }
      )
      :wait(60000)
    ok(fail.code ~= 0, "a terminating error ends PowerShell with a non-zero exit code")
    ok(not (fail.stdout or ""):find("not reached"), "and the lines after it do not run")
  end
  eq(
    runner.autostart_argv("off"),
    { "schtasks", "/Delete", "/TN", "GitHub Runners", "/F" },
    "off deletes the task"
  )
  ---@diagnostic disable-next-line: param-type-mismatch -- an invalid action is the case under test
  local argv, why = runner.autostart_argv("nonsense")
  eq(argv, nil, "an unknown action builds nothing")
  H.has(why, "unknown action", "and says why")

  -- the routes: the autostart paths exist and the old ones are still there
  local paths = {}
  for _, r in ipairs(runner.routes()) do
    paths[#paths + 1] = table.concat(r.path, " ")
  end
  for _, p in ipairs({
    "runner start",
    "runner stop",
    "runner status",
    "runner autostart on",
    "runner autostart off",
    "runner autostart status",
  }) do
    ok(vim.tbl_contains(paths, p), "route: " .. p)
  end

  -- the dependency overrides (`*_NVIM_DIR`) are not handed to a started runner (twin of runners.ps1, e4b3147)
  local environ = {
    LIB_NVIM_DIR = "x",
    TESTING_NVIM_DIR = "x",
    lib_nvim_dir = "x",
    SNACKS_DIR = "x", -- no .nvim suffix: a known gap, kept in step with the PowerShell regex
    NVIM_DIR_X = "x",
    PATH = "x",
  }
  eq(
    runner.override_names(environ, true),
    { "LIB_NVIM_DIR", "TESTING_NVIM_DIR", "lib_nvim_dir" },
    "case-insensitive: the overrides, in any spelling"
  )
  eq(
    runner.override_names(environ, false),
    { "LIB_NVIM_DIR", "TESTING_NVIM_DIR" },
    "case-sensitive: only the upper-case names"
  )

  local uv = vim.uv or vim.loop
  local win = require("lib.nvim.cross.platform.is_windows")()
  local mine =
    { "ZZSPEC_NVIM_DIR", win and "zzspec2_nvim_dir" or "ZZSPEC2_NVIM_DIR", "ZZSPEC_OTHER_DIR" }
  local before = {}
  for _, n in ipairs(mine) do
    before[n] = uv.os_getenv(n)
    uv.os_setenv(n, "keep:" .. n)
  end
  local seen
  local fake = {
    names = function()
      return {}
    end,
    run = function()
      seen = {}
      for _, n in ipairs(mine) do
        seen[n] = uv.os_getenv(n)
      end
      return true, nil, {}
    end,
  }
  local userprofile = vim.env.USERPROFILE
  local home = H.tmpdir()
  H.write(home .. "/actions-runners/casedesk.nvim/run.cmd", "@echo off\n")
  vim.env.USERPROFILE = home
  runner._terminal = fake
  local started = pcall(runner.start, "casedesk.nvim")
  runner._terminal = nil
  vim.env.USERPROFILE = userprofile
  local after = {}
  for _, n in ipairs(mine) do
    after[n] = uv.os_getenv(n)
    uv.os_unsetenv(n)
    if before[n] then
      uv.os_setenv(n, before[n])
    end
  end
  ok(started and seen, "runner start reached term.run")
  eq(seen.ZZSPEC_NVIM_DIR, nil, "the runner start has no *_NVIM_DIR override in its environment")
  eq(seen[mine[2]], nil, "... in either case spelling that this system treats as the same name")
  eq(seen.ZZSPEC_OTHER_DIR, "keep:ZZSPEC_OTHER_DIR", "... and other variables are kept")
  eq(
    after.ZZSPEC_NVIM_DIR,
    "keep:ZZSPEC_NVIM_DIR",
    "the editor's own environment is restored afterwards"
  )
  eq(after[mine[2]], "keep:" .. mine[2], "... also the second spelling")

  -- restored when the start throws, and the error comes through unchanged
  uv.os_setenv("ZZSPEC_NVIM_DIR", "again")
  local thrown, thrown_why = pcall(runner.without_overrides, function()
    error("boom", 0)
  end)
  eq(thrown, false, "an error inside the clean run propagates")
  eq(thrown_why, "boom", "... unchanged")
  eq(uv.os_getenv("ZZSPEC_NVIM_DIR"), "again", "... and the environment is restored")
  eq(
    { runner.without_overrides(function()
      return 1, nil, 3
    end) },
    { 1, nil, 3 },
    "the results of the function are returned"
  )
  uv.os_unsetenv("ZZSPEC_NVIM_DIR")
  if before.ZZSPEC_NVIM_DIR then
    uv.os_setenv("ZZSPEC_NVIM_DIR", before.ZZSPEC_NVIM_DIR)
  end
end

-- `runner status` and `runner autostart` never wait for their processes (a gh api call per runner, one after the
-- other, froze the editor for every network round trip): the calls start at once, each with a timeout, and one
-- message lists the runners in the order of REPOS when the last one has answered. vim.system is a fake whose wait()
-- raises, so a synchronous call fails here instead of reaching GitHub.
---@param H table
local function async_status(H)
  local eq, ok = H.eq, H.ok
  local runner = require("bindings.usrcmds.plugin_repos.runner")
  local saved = { system = vim.system, notify = vim.notify }
  local calls, said = {}, {}
  local passed, err = pcall(function()
    ---@diagnostic disable-next-line: duplicate-set-field -- deliberate stub, restored below
    vim.notify = function(msg, level)
      said[#said + 1] = { msg = tostring(msg), level = level }
    end
    ---@diagnostic disable-next-line: duplicate-set-field -- deliberate stub, restored below
    vim.system = function(argv, opts, on_exit)
      calls[#calls + 1] = { argv = argv, opts = opts or {}, on_exit = on_exit }
      ---@diagnostic disable-next-line: return-type-mismatch -- minimal fake of vim.SystemObj
      return {
        wait = function()
          error("waited for " .. table.concat(argv, " "))
        end,
        kill = function() end,
      }
    end
    -- only what runner says counts: owner_repo loads plugins.personal on first use, which notifies on a machine
    -- without the local checkouts (CI: "No local repository folder found")
    local function ours()
      return vim.tbl_filter(function(m)
        return m.msg:find("[usrcmds.plugin_repos.runner]", 1, true) ~= nil
      end, said)
    end
    local function settle()
      vim.wait(2000, function()
        return #ours() > 0
      end, 10)
    end

    runner.status()
    eq(#calls, #runner.REPOS, "runner status starts one gh api call per runner, all at once")
    eq(calls[1].argv[1], "gh", "through gh")
    H.has(calls[1].argv[3], "/actions/runners", "gh api repos/<owner>/<repo>/actions/runners")
    ok((calls[1].opts.timeout or 0) > 0, "each call has a timeout")
    ok(type(calls[1].on_exit) == "function", "and answers through a callback")
    eq(#ours(), 0, "nothing is said before the answers")
    -- the answers come back in reverse order: the first runner online and busy, the others not registered
    for i = #calls, 1, -1 do
      local stdout = i == 1
          and vim.json.encode({ runners = { { status = "online", busy = true } } })
        or "{}"
      calls[i].on_exit({ code = 0, stdout = stdout, stderr = "" })
    end
    settle()
    eq(#ours(), 1, "one message once every call has answered")
    local text = ours()[1] and ours()[1].msg or ""
    H.has(text, ("%-14s online, busy"):format(runner.REPOS[1]), "the busy runner")
    H.has(
      text,
      ("%-14s no runner registered"):format(runner.REPOS[#runner.REPOS]),
      "a runner without registration"
    )
    local first = text:find(runner.REPOS[1], 1, true) or math.huge
    local second = text:find(runner.REPOS[2], 1, true) or -1
    ok(first < second, "the lines are in the order of REPOS, not of the answers")

    H.has(
      runner.status_line("x", { code = 124, signal = 15, stderr = "" }),
      "no answer within",
      "a call killed by its timeout says so"
    )
    H.has(
      runner.status_line("x", { code = 1, stderr = "HTTP 401" }),
      "gh api failed: HTTP 401",
      "gh's own error"
    )

    calls, said = {}, {}
    runner.autostart("status")
    eq(#calls, 1, "autostart status starts PowerShell once")
    eq(#ours(), 0, "and does not wait for it")
    calls[1].on_exit({ code = 1, stdout = "", stderr = "no task" })
    settle()
    H.has(
      ours()[1] and ours()[1].msg or "",
      "no scheduled task",
      "the answer comes when PowerShell is done"
    )
  end)
  vim.system, vim.notify = saved.system, saved.notify
  if not passed then
    error(err, 0)
  end
end

-- start refuses on the workstation (lua/machine_guard.lua, its own spec: workstation_spec): the
-- start here is the private machine's, whatever NVIM_MACHINE_ROLE this process has; put back on
-- failure too
return function(H)
  local role = require("machine")
  local saved_is = role.is
  ---@diagnostic disable-next-line: duplicate-set-field -- deliberate stub, restored below
  role.is = function(r)
    return r == "default"
  end
  local passed, err = pcall(function()
    spec(H)
    async_status(H)
  end)
  role.is = saved_is
  if not passed then
    error(err, 0)
  end
end
