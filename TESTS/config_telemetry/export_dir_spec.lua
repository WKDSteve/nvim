-- TESTS/config_telemetry/export_dir_spec.lua -- the default target of `:RATelemetry export-all`: the vault archive
-- `$REPOS_DIR/tasks-vault/_Telemetry/<PC|Workstation>/<YYYY-MM-DD>`, and no target at all when it cannot be one.

return function(H)
  local eq, ok = H.eq, H.ok
  local telemetry = require("config.telemetry")
  local machine = require("machine")

  local saved_repos = vim.env.REPOS_DIR
  local real_is = machine.is
  local base = vim.fs.normalize(vim.fn.tempname()) .. "_repos"

  local function run()
    local today = os.date("%Y-%m-%d")

    vim.env.REPOS_DIR = nil
    eq(telemetry.export_dir(), nil, "no REPOS_DIR: no target")

    vim.env.REPOS_DIR = base
    eq(
      telemetry.export_dir(),
      nil,
      "no vault under REPOS_DIR: no target (the command does not create a vault)"
    )

    vim.fn.mkdir(base .. "/tasks-vault", "p")
    eq(telemetry.export_dir(), nil, "a vault without the _Telemetry archive: still no target")

    vim.fn.mkdir(base .. "/tasks-vault/_Telemetry", "p")
    machine.is = function()
      return false
    end
    eq(
      telemetry.export_dir(),
      base .. "/tasks-vault/_Telemetry/PC/" .. today,
      "a private machine files under PC, ISO date"
    )

    machine.is = function(role)
      return role == "workstation"
    end
    eq(
      telemetry.export_dir(),
      base .. "/tasks-vault/_Telemetry/Workstation/" .. today,
      "the workstation files under Workstation"
    )

    local built = telemetry.build({})
    ok(
      type(built.export) == "table" and built.export.dir == telemetry.export_dir,
      "build() hands the resolver to the plugin"
    )
  end

  local finished, err = pcall(run)
  machine.is = real_is
  vim.env.REPOS_DIR = saved_repos
  vim.fn.delete(base, "rf")
  if not finished then
    error(err, 0)
  end
end
