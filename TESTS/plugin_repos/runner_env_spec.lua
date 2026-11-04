-- TESTS/plugin_repos/runner_env_spec.lua -- scripts/runner_env.ps1: the .env of a runner gets the longer wait
-- for its worker, without touching what is already there.

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
  for _, name in ipairs({ "broken", "hooked", "empty", "own" }) do
    vim.fn.mkdir(vim.fs.joinpath(root, name), "p")
  end
  local hook = "ACTIONS_RUNNER_HOOK_JOB_STARTED=C:\\guard\\job-started.ps1"
  local hooked = vim.fs.joinpath(root, "hooked", ".env")
  local own = vim.fs.joinpath(root, "own", ".env")
  write(hooked, hook)
  write(own, "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=120\n")
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
        "broken,hooked,empty,own",
      }, { text = true })
      :wait(60000)
    eq(done.code, 0, tostring(done.stderr))
    return done.stdout
  end

  local first = run()
  local line = "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=300"
  eq(read(hooked), hook .. "\n" .. line .. "\n", "the hook stays and the wait joins it")
  eq(read(vim.fs.joinpath(root, "empty", ".env")), line .. "\n", "a runner without .env gets one")
  eq(read(own), "GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=120\n", "a value set by hand stays")
  ok(first:find("hooked", 1, true), "says which runner changed")
  ok(not first:find("own", 1, true), "and not the one that did not")
  ok(
    first:find("warning: broken", 1, true),
    "a .env that cannot be written is told, and the others go on"
  )

  ok(not run():find("now waits", 1, true), "a second run changes nothing")
  eq(read(hooked), hook .. "\n" .. line .. "\n", "and adds no second line")

  vim.fn.delete(root, "rf")
end
