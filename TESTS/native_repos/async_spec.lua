-- TESTS/native_repos/async_spec.lua -- :MyNative list and the tool probes never make the editor wait.
--
-- `vim.system` is replaced by a stand-in whose `wait()` throws and whose exit callbacks the spec fires by hand:
-- the old code (`vim.system(...):wait()` per app in `list`, per probe in `toolchain.check`) froze the editor up to
-- 670 ms on one app (testing perf, 2026-11-20) and multiplied with every cloned app. Nothing real starts.
---@diagnostic disable: duplicate-set-field

---@param H table
local function spec(H)
  local eq, ok = H.eq, H.ok
  local native = require("bindings.usrcmds.native_repos")
  local natives = require("plugins.personal.core.natives")
  local toolchain = require("bindings.usrcmds.native_repos.toolchain")

  local saved = { system = vim.system, notify = vim.notify, repos = vim.env.REPOS_DIR }
  local function restore()
    vim.system, vim.notify, vim.env.REPOS_DIR = saved.system, saved.notify, saved.repos
  end

  ---@type { argv: string[], finish: fun(res: table) }[]
  local started = {}
  local function stand_in()
    started = {}
    vim.system = function(argv, _opts, on_exit)
      local entry = {
        argv = argv,
        finish = function(res)
          on_exit(res)
        end,
      }
      started[#started + 1] = entry
      return {
        wait = function()
          error("waited for " .. table.concat(argv, " "))
        end,
      }
    end
  end

  local function settle(pred)
    vim.wait(1000, pred, 5)
  end

  local passed, err = pcall(function()
    -- toolchain: a probe inside check_async hands the wait to the event loop
    stand_in()
    local probing = {
      id = "probe",
      desc = "a probe that starts a program",
      hint = "hp",
      check = function()
        return (toolchain._runs({ "probe-tool", "--version" }))
      end,
    }
    local got
    toolchain.check_async({ "probe" }, function(missing)
      got = missing
    end, { probing })
    eq(#started, 1, "the probe started its program")
    eq(got, nil, "no answer before the probe finished")
    started[1].finish({ code = 0, stdout = "probe 1.0\n" })
    settle(function()
      return got ~= nil
    end)
    eq(got, {}, "a probe that succeeds in the background counts as present")

    stand_in()
    got = nil
    toolchain.check_async({ "probe" }, function(missing)
      got = missing
    end, { probing })
    started[1].finish({ code = 1, stdout = "" })
    settle(function()
      return got ~= nil
    end)
    eq(got, { probe = true }, "a failing probe counts as missing")

    got = nil
    vim.system = function()
      error("cannot start")
    end
    toolchain.check_async({ "probe" }, function(missing)
      got = missing
    end, { probing })
    eq(got, { probe = true }, "a probe that cannot start counts as missing, without raising")

    -- the synchronous check is unchanged for callers outside a check_async run
    stand_in()
    vim.system = function()
      return {
        wait = function()
          return { code = 0, stdout = "x" }
        end,
      }
    end
    eq(toolchain.check({ "probe" }, { probing }), {}, "check() still answers synchronously")

    -- :MyNative list: every app is asked at once, the answer comes once, nothing waits
    local repos = H.tmpdir()
    local cloned = {}
    for i, entry in ipairs(natives.list) do
      if entry.artifact and #cloned < 2 then
        vim.fn.mkdir(repos .. "/" .. entry.name, "p")
        cloned[#cloned + 1] = entry.name
      end
      if i > 50 then
        break
      end
    end
    ok(#cloned == 2, "two apps with an artifact to clone in the fixture")
    vim.env.REPOS_DIR = repos
    local heard = {}
    vim.notify = function(msg)
      heard[#heard + 1] = msg
    end
    stand_in()
    native.list()
    eq(#started, 2, "both cloned apps' git log started before any answered")
    eq(#heard, 0, "nothing shown before the answers")
    for _, s in ipairs(started) do
      eq(s.argv[1], "git", "the list asks git")
    end
    -- answer the first app's git log; its git status then starts
    started[1].finish({ code = 0, stdout = "100\n" })
    started[2].finish({ code = 0, stdout = "100\n" })
    settle(function()
      return #started == 4
    end)
    eq(#started, 4, "each cloned app's git status started after its log")
    eq(#heard, 0, "still nothing shown while a git status is open")
    started[3].finish({ code = 0, stdout = "## main\n" })
    started[4].finish({ code = 0, stdout = "## main...origin/main [behind 2]\n M x\n" })
    settle(function()
      return #heard > 0
    end)
    eq(#heard, 1, "the list is shown once")
    for _, name in ipairs(cloned) do
      H.has(heard[1], name, "the list names " .. name)
    end
    H.has(heard[1], "not cloned", "the apps that are not there say so")
    H.has(heard[1], "behind 2, dirty", "the git column comes from git status")
  end)
  restore()
  H.cleanup()
  if not passed then
    error(err, 0)
  end

  eq(native.git_state_text({ code = 128 }), "no git", "a failed git status is 'no git'")
  eq(native.git_state_text({ code = 0, stdout = "## main\n" }), "clean", "nothing to say is clean")
end

return spec
