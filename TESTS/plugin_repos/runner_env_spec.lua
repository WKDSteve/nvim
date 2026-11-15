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

  local first = run()
  local lines = "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=300\nCARGO_BUILD_JOBS=4\n"
  eq(read(hooked), hook .. "\n" .. lines, "the hook stays and the settings join it")
  eq(read(vim.fs.joinpath(root, "empty", ".env")), lines, "a runner without .env gets one")
  eq(
    read(own),
    "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=120\nCARGO_BUILD_JOBS=4\n",
    "a value set by hand stays, the missing setting joins it"
  )
  eq(read(set), set_by_hand, "a .env with every setting set by hand stays as it is")
  ok(
    first:find("hooked now waits 300 s for its worker and builds with 4 cargo jobs", 1, true),
    "says what changed"
  )
  ok(first:find("own now builds with 4 cargo jobs", 1, true), "and only what was missing")
  ok(not first:find("set now", 1, true), "and nothing for a runner that had it all")
  ok(
    first:find("warning: broken", 1, true),
    "a .env that cannot be written is told, and the others go on"
  )

  ok(not run():find(" now ", 1, true), "a second run changes nothing")
  eq(read(hooked), hook .. "\n" .. lines, "and adds no second line")

  vim.fn.delete(root, "rf")
end
