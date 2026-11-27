-- TESTS/plugin_repos/runner_env_spec.lua -- scripts/runner_env.ps1: the .env of a runner gets the longer wait
-- for its worker and the cargo job limit, without touching what is already there.

---@param path string
---@return string
local function read(path)
  local file = assert(io.open(path, "rb"))
  local text = file:read("*a")
  file:close()
  return text
end

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
  if vim.fn.executable("pwsh") ~= 1 then
    return
  end
  local script = vim.fs.joinpath(vim.fn.getcwd(), "scripts", "runner_env.ps1")
  ok(vim.uv.fs_stat(script) ~= nil, "the spec runs from the root of the config")

  local root = vim.fn.tempname()
  for _, name in ipairs({ "broken", "hooked", "empty", "own", "set" }) do
    vim.fn.mkdir(vim.fs.joinpath(root, name), "p")
  end
  local hook = "ACTIONS_RUNNER_HOOK_JOB_STARTED=C:\\guard\\job-started.ps1"
  local hooked = vim.fs.joinpath(root, "hooked", ".env")
  local own = vim.fs.joinpath(root, "own", ".env")
  local set = vim.fs.joinpath(root, "set", ".env")
  local set_by_hand = "CARGO_BUILD_JOBS=2\nGITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=600\n"
    .. "ACTIONS_RUNNER_HOOK_JOB_COMPLETED=C:\\own\\hook.ps1\n"
  write(hooked, hook)
  write(own, "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=120\n")
  write(set, set_by_hand)
  -- A folder where the file belongs: neither readable nor writable as a file, and it comes first.
  vim.fn.mkdir(vim.fs.joinpath(root, "broken", ".env"), "p")

  local function run()
    local done = vim
      .system({
        "pwsh",
        "-NoProfile",
        "-NonInteractive",
        "-File",
        script,
        "-Root",
        root,
        "-Name",
        "broken,hooked,empty,own,set",
      }, { text = true })
      :wait(60000)
    eq(done.code, 0, tostring(done.stderr))
    return done.stdout
  end

  ---@param names string
  ---@param mode string "-Check" or "-Started"
  ---@param listeners string|nil start times of fake listeners, "name=<ISO time>;..."
  ---@return integer, string
  local function call(names, mode, listeners)
    local done = vim
      .system({
        "pwsh",
        "-NoProfile",
        "-NonInteractive",
        "-File",
        script,
        "-Root",
        root,
        "-Name",
        names,
        mode,
      }, { text = true, env = { RUNNER_ENV_LISTENERS = listeners or "" } })
      :wait(60000)
    return done.code, done.stdout .. done.stderr
  end

  ---@param names string
  ---@param listeners string|nil
  ---@return integer, string
  local function check(names, listeners)
    return call(names, "-Check", listeners)
  end

  local code, said = check("hooked,empty,own,set")
  eq(code, 1, "-Check fails while a .env lacks a setting")
  ok(
    said:find(
      "missing  hooked lacks GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT, CARGO_BUILD_JOBS, ACTIONS_RUNNER_HOOK_JOB_COMPLETED",
      1,
      true
    ),
    said
  )
  ok(said:find("missing  empty lacks", 1, true), "a runner without .env lacks everything")
  ok(
    said:find("missing  own lacks CARGO_BUILD_JOBS, ACTIONS_RUNNER_HOOK_JOB_COMPLETED in", 1, true),
    "names only what is missing"
  )
  ok(said:find("ok       set", 1, true), "a .env set by hand is ok")
  eq(read(hooked), hook, "-Check writes nothing")

  local first = run()
  -- The job-completed hook of the window guard: the script next to runner_env.ps1, a path of this machine.
  local completed =
    read(vim.fs.joinpath(root, "empty", ".env")):match("ACTIONS_RUNNER_HOOK_JOB_COMPLETED=([^\n]+)")
  ok(completed and completed:match("runner_job_completed%.ps1$"), tostring(completed))
  ok(
    vim.uv.fs_stat(completed) ~= nil,
    "the hook names a file that is there: " .. tostring(completed)
  )
  local hook_line = "ACTIONS_RUNNER_HOOK_JOB_COMPLETED=" .. completed .. "\n"
  local lines = "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=300\nCARGO_BUILD_JOBS=4\n" .. hook_line
  eq(read(hooked), hook .. "\n" .. lines, "the hook stays and the settings join it")
  eq(read(vim.fs.joinpath(root, "empty", ".env")), lines, "a runner without .env gets one")
  eq(
    read(own),
    "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=120\nCARGO_BUILD_JOBS=4\n" .. hook_line,
    "a value set by hand stays, the missing settings join it"
  )
  eq(read(set), set_by_hand, "a .env with every setting set by hand stays as it is")
  ok(
    first:find(
      "hooked now waits 300 s for its worker and builds with 4 cargo jobs and reports the windows of each job",
      1,
      true
    ),
    "says what changed"
  )
  ok(
    first:find("own now builds with 4 cargo jobs and reports the windows of each job", 1, true),
    "and only what was missing"
  )
  ok(not first:find("set now", 1, true), "and nothing for a runner that had it all")
  ok(
    first:find("warning: broken", 1, true),
    "a .env that cannot be written is told, and the others go on"
  )

  ok(not run():find(" now ", 1, true), "a second run changes nothing")
  eq(read(hooked), hook .. "\n" .. lines, "and adds no second line")

  code, said = check("hooked,empty,own,set")
  eq(code, 0, "-Check passes once every .env has the settings: " .. said)
  ok(not said:find("restart", 1, true), "a runner that does not run needs no restart")
  code = check("broken")
  eq(code, 1, "a .env that is not a file counts as missing")

  -- What a running listener read: runners.ps1 records the .env right before the start (-Started).
  eq(call("hooked,empty", "-Started"), 0, "-Started records the .env")
  eq(read(vim.fs.joinpath(root, "hooked", ".env.started")), read(hooked), "as a copy")
  local later = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time() + 60)
  local listeners = "hooked=" .. later .. ";empty=2020-01-01T00:00:00Z;own=" .. later
  code, said = check("hooked,empty,own", listeners)
  eq(code, 0, said)
  ok(said:find("ok       hooked\n", 1, true), "started with the .env there now: ok")
  ok(
    said:find("unknown  empty", 1, true),
    "a listener older than the record was not started with it"
  )
  ok(said:find("unknown  own", 1, true), "a listener without a record is unknown, not a failure")

  -- `runner-guard install` rewrites every .env on each start: a new time with the same text is no restart.
  write(hooked, read(hooked))
  code, said = check("hooked", listeners)
  eq(code, 0, "the same .env written again needs no restart: " .. said)
  write(hooked, read(hooked) .. "SOMETHING=new\n")
  code, said = check("hooked", listeners)
  eq(code, 1, "a changed .env fails the check")
  ok(said:find("restart  hooked", 1, true), said)

  vim.fn.delete(root, "rf")
end
