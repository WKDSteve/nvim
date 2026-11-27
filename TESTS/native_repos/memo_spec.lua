-- TESTS/native_repos/memo_spec.lua -- :MyNative asks git log and the tool probes (vswhere) once, not once per command.
--
-- `list`, `build` and `deps` typed one after the other started `git log -1` per app and `vswhere.exe` again for the
-- same answer (nvim-config.mynative sheet, repeat run 2026-11-21: 924 ms and 763 ms). `vim.system` is a counting
-- stand-in; nothing real starts.
---@diagnostic disable: duplicate-set-field

return function(H)
  local eq = H.eq
  local native = require("bindings.usrcmds.native_repos")
  local toolchain = require("bindings.usrcmds.native_repos.toolchain")

  local saved = { system = vim.system }
  local starts = {}
  ---@param code integer
  ---@param stdout string
  local function counting(code, stdout)
    starts = {}
    vim.system = function(argv, _opts, on_exit)
      starts[#starts + 1] = table.concat(argv, " ")
      if on_exit then
        vim.schedule(function()
          on_exit({ code = code, stdout = stdout })
        end)
      end
      return {
        wait = function()
          return { code = code, stdout = stdout }
        end,
      }
    end
  end

  local passed, err = pcall(function()
    -- commit time: the second asker gets the kept answer, a forgotten one goes to git again
    local dir = H.tmpdir()
    counting(0, "123\n")
    native.forget_commit_times()
    local answers = {}
    local function ask()
      native.commit_time(dir, { "crates" }, function(t)
        answers[#answers + 1] = t
      end)
    end
    ask()
    ask() -- while the first is running: shared
    vim.wait(1000, function()
      return #answers == 2
    end, 5)
    eq(answers, { 123, 123 }, "both askers get the answer")
    eq(#starts, 1, "two askers at once start git log once")
    ask()
    vim.wait(1000, function()
      return #answers == 3
    end, 5)
    eq(#starts, 1, "a later asker is answered from the kept result")
    native.forget_commit_times(dir)
    ask()
    vim.wait(1000, function()
      return #answers == 4
    end, 5)
    eq(#starts, 2, "after the checkout changed git is asked again")

    -- a failed git log is not kept
    native.forget_commit_times()
    counting(128, "")
    answers = {}
    ask()
    vim.wait(1000, function()
      return #answers == 1
    end, 5)
    ask()
    vim.wait(1000, function()
      return #answers == 2
    end, 5)
    eq(#starts, 2, "a failed answer is asked again")

    -- tool probes: the same command twice runs once; forget_probes starts it again
    toolchain.forget_probes()
    counting(0, "C:/vs\n")
    eq({ toolchain._runs({ "vswhere.exe", "-property", "installationPath" }) }, { true, "C:/vs\n" })
    eq({ toolchain._runs({ "vswhere.exe", "-property", "installationPath" }) }, { true, "C:/vs\n" })
    eq(#starts, 1, "the second probe of the same command is answered from the kept result")
    toolchain._runs({ "vswhere.exe", "-other" })
    eq(#starts, 2, "another command is its own probe")
    toolchain.forget_probes()
    toolchain._runs({ "vswhere.exe", "-property", "installationPath" })
    eq(#starts, 3, "forgotten probes run again")
  end)
  vim.system = saved.system
  toolchain.forget_probes()
  native.forget_commit_times()
  H.cleanup()
  if not passed then
    error(err, 0)
  end
end
