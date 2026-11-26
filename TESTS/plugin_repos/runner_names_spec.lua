-- TESTS/plugin_repos/runner_names_spec.lua -- scripts/runner_names.ps1: a repository may have more than one runner
-- folder (<repo>, <repo>+2); a repository name stands for all of them, the GitHub name of a further instance ends in
-- -<repo>-<n>, and the folder tasks-desktop does not claim the listener of tasks-desktop+2.

---@param H table
return function(H)
  local eq, ok = H.eq, H.ok
  if vim.fn.executable("pwsh") ~= 1 then
    print("n/a  pwsh is not on PATH")
    return
  end
  local script = vim.fs.joinpath(vim.fn.getcwd(), "scripts", "runner_names.ps1")
  ok(vim.uv.fs_stat(script) ~= nil, "the spec runs from the root of the config")

  local root = vim.fn.tempname()
  for _, name in ipairs({
    "tasks-desktop",
    "tasks-desktop+2",
    "tasks-desktop-mobile",
    "appkit",
    "_guard",
  }) do
    vim.fn.mkdir(vim.fs.joinpath(root, name), "p")
  end

  ---@param body string PowerShell after the dot-source; each result on its own line
  ---@return string[]
  local function ps(body)
    local cmd = ". '" .. script .. "'; " .. body
    local done = vim
      .system({ "pwsh", "-NoProfile", "-NonInteractive", "-Command", cmd }, { text = true })
      :wait(60000)
    eq(done.code, 0, tostring(done.stderr))
    return vim.split(vim.trim((done.stdout:gsub("\r", ""))), "\n", { trimempty = true })
  end

  local r = "'" .. root .. "'"
  eq(
    ps(("(Expand-RunnerFolder %s @('tasks-desktop')) -join ','"):format(r))[1],
    "tasks-desktop,tasks-desktop+2",
    "a repository name stands for all its instances, not for a longer name that starts like it"
  )
  eq(
    ps(("(Expand-RunnerFolder %s @('tasks-desktop+2')) -join ','"):format(r))[1],
    "tasks-desktop+2",
    "a folder with +<n> names that one only"
  )
  local all = vim.split(ps(("(Expand-RunnerFolder %s @('all')) -join ','"):format(r))[1], ",")
  table.sort(all)
  eq(
    table.concat(all, ","),
    "appkit,tasks-desktop,tasks-desktop+2,tasks-desktop-mobile",
    "all is every folder, _ folders left out"
  )
  eq(
    ps(("(Expand-RunnerFolder %s @('nope')) -join ','"):format(r))[1],
    "nope",
    "an unknown name stays, so runners.ps1 can report it"
  )

  local names = ps(
    "Get-RunnerRepo 'tasks-desktop+2'; Get-RunnerRepo 'tasks-desktop'; "
      .. "Get-RunnerRemoteSuffix 'tasks-desktop+2'; Get-RunnerRemoteSuffix 'tasks-desktop'"
  )
  eq(names, { "tasks-desktop", "tasks-desktop", "-tasks-desktop-2", "-tasks-desktop" })

  local owns = ps(
    "Test-RunnerOwnsPath 'C:\\r' 'tasks-desktop' 'C:\\R\\tasks-desktop\\bin\\Runner.Listener.exe'; "
      .. "Test-RunnerOwnsPath 'C:\\r' 'tasks-desktop' 'C:\\r\\tasks-desktop+2\\bin\\Runner.Listener.exe'; "
      .. "Test-RunnerOwnsPath 'C:\\r' 'tasks-desktop+2' 'C:\\r\\tasks-desktop+2\\bin\\Runner.Listener.exe'; "
      .. "Test-RunnerOwnsPath 'C:\\r' 'tasks-desktop' ''"
  )
  eq(owns, { "True", "False", "True", "False" }, "the folder owns only its own listener")
  vim.fn.delete(root, "rf")
end
