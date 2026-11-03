-- TESTS/machine_once/machine_once_spec.lua -- lua/machine_once.lua: a step runs once on the machines it names
-- (host or role), only with a UI and outside a Claude session, is marked done only when it exits with 0, and a
-- failed one runs again. The command is a fake (`spawn`), nothing is started.

return function(H)
  local eq = H.eq
  local once = require("machine_once")

  local step = assert(once.steps[1])
  eq(step.id, "git-signing", "the first step is the commit signing")
  eq(vim.tbl_contains(step.hosts, "BERNHARDPC"), true, "it is for BERNHARDPC")
  eq(vim.tbl_contains(step.roles, "workstation"), true, "and for the workstation")
  eq(
    step.argv[#step.argv]:match("setup%-git%-signing%.ps1$") ~= nil,
    true,
    "it runs setup-git-signing.ps1"
  )

  local dir = vim.fn.tempname()
  local calls, said
  local answer = 0
  local function ctx(over)
    return vim.tbl_extend("force", {
      host = "bernhardpc",
      is_role = function()
        return false
      end,
      state_dir = dir,
      has_ui = true,
      claude = false,
      spawn = function(argv, done)
        calls[#calls + 1] = argv
        done(answer, "fake output")
      end,
      notify = function(msg, level)
        said[#said + 1] = { msg = msg, level = level }
      end,
    }, over or {})
  end
  local function run(over)
    calls, said = {}, {}
    return once.run(ctx(over))
  end
  local marker = dir .. "/git-signing.done"

  eq(run({ host = "STEVESPC" }), {}, "another machine runs nothing")
  eq(#calls, 0, "... and starts nothing")
  eq(run({ has_ui = false }), {}, "headless runs nothing")
  eq(run({ claude = true }), {}, "a Claude session runs nothing")

  answer = 1
  eq(run(), { "git-signing" }, "BERNHARDPC (any case) runs the step")
  eq(#calls, 1, "... once")
  eq(vim.uv.fs_stat(marker), nil, "a failed step is not marked done")
  eq(said[#said].level, vim.log.levels.ERROR, "... and says so")
  eq(said[#said].msg:find("fake output", 1, true) ~= nil, true, "... with the output")

  answer = 0
  eq(run(), { "git-signing" }, "the failed step runs again on the next start")
  eq(vim.uv.fs_stat(marker) ~= nil, true, "a step that succeeds is marked done")
  eq(said[#said].msg:find("git-signing done", 1, true) ~= nil, true, "... and says so")
  eq(run(), {}, "a step that is done does not run again")
  eq(#calls, 0, "... and starts nothing")

  vim.fn.delete(dir, "rf")
  eq(
    run({
      host = "TRI-12345",
      is_role = function(r)
        return r == "workstation"
      end,
    }),
    { "git-signing" },
    "the workstation role runs it too"
  )
  vim.fn.delete(dir, "rf")
end
