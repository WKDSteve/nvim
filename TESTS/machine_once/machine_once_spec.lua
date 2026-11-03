-- TESTS/machine_once/machine_once_spec.lua -- lua/machine_once.lua: a step runs on the machines it names (host or
-- role), only with a UI and outside a Claude session, and only while its result is not there; there is no marker
-- file. The commit-signing step is done when the device registry names the machine. The command is a fake
-- (`spawn`), nothing is started.

return function(H)
  local eq = H.eq
  local once = require("machine_once")

  -- the registry check: principals are the first field, comma-separated, without case; comments do not count
  local reg = vim.fn.tempname()
  local f = assert(io.open(reg, "w"))
  f:write('STEVESPC,me@x namespaces="git" ssh-ed25519 AAAA STEVESPC\n')
  f:write("# BERNHARDPC,me@x ssh-ed25519 BBBB\n")
  f:write('me@x,Other namespaces="git" ssh-ed25519 CCCC\n')
  f:close()
  eq(once.registered(reg, "stevespc"), true, "a device in the registry (any case)")
  eq(once.registered(reg, "OTHER"), true, "... also as a later principal")
  eq(once.registered(reg, "BERNHARDPC"), false, "a commented line does not count")
  eq(once.registered(reg, "me"), false, "only whole principals")
  eq(once.registered(reg .. ".nope", "STEVESPC"), false, "no registry: not done")
  os.remove(reg)

  local step = assert(once.steps[1])
  eq(step.id, "git-signing", "the first step is the commit signing")
  eq(vim.tbl_contains(step.hosts, "BERNHARDPC"), true, "it is for BERNHARDPC")
  eq(vim.tbl_contains(step.roles, "workstation"), true, "and for the workstation")
  eq(
    step.argv[#step.argv]:match("setup%-git%-signing%.ps1$") ~= nil,
    true,
    "it runs setup-git-signing.ps1"
  )

  local real_done = step.done
  local good, failure = pcall(function()
    local registered = false
    step.done = function()
      return registered
    end
    local calls, said
    local answer, registers = 0, true
    local function run(over)
      calls, said = {}, {}
      return once.run(vim.tbl_extend("force", {
        host = "bernhardpc",
        is_role = function()
          return false
        end,
        has_ui = true,
        claude = false,
        spawn = function(argv, done)
          calls[#calls + 1] = argv
          if answer == 0 and registers then
            registered = true
          end
          done(answer, "fake output")
        end,
        notify = function(msg, level)
          said[#said + 1] = { msg = msg, level = level }
        end,
      }, over or {}))
    end

    eq(run({ host = "STEVESPC" }), {}, "another machine runs nothing")
    eq(#calls, 0, "... and starts nothing")
    eq(run({ has_ui = false }), {}, "headless runs nothing")
    eq(run({ claude = true }), {}, "a Claude session runs nothing")

    answer = 1
    eq(run(), { "git-signing" }, "BERNHARDPC (any case) runs the step")
    eq(#calls, 1, "... once")
    eq(said[#said].level, vim.log.levels.ERROR, "a failed step says so")
    eq(said[#said].msg:find("fake output", 1, true) ~= nil, true, "... with the output")

    answer, registers = 0, false
    eq(run(), { "git-signing" }, "the failed step runs again on the next start")
    eq(said[#said].level, vim.log.levels.ERROR, "exit 0 without the result is no success")

    registers = true
    eq(run(), { "git-signing" }, "it runs again")
    eq(
      said[#said].msg:find("git-signing done", 1, true) ~= nil,
      true,
      "a step with its result is done"
    )
    eq(run(), {}, "a step whose result is there does not run again")
    eq(#calls, 0, "... and starts nothing")

    registered = false
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
  end)
  step.done = real_done
  if not good then
    error(failure, 0)
  end
end
