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
    eq(argv[4], "-EncodedCommand", action .. " hands the script over encoded (no quoting)")
    local decoded = vim.iconv(vim.base64.decode(argv[5]), "utf-16le", "utf-8")
    H.has(decoded, runner.AUTOSTART_TASK, action .. " names the fixed task")
  end
  H.has(
    vim.iconv(vim.base64.decode(runner.autostart_argv("on")[5]), "utf-16le", "utf-8"),
    "scripts\\runners.ps1",
    "the script path has backslashes (a Windows path)"
  )
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
  local passed, err = pcall(spec, H)
  role.is = saved_is
  if not passed then
    error(err, 0)
  end
end
