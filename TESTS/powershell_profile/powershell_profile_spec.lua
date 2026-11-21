-- TESTS/powershell_profile/powershell_profile_spec.lua -- :PowershellProfile never makes the editor wait.
--
-- `vim.system` is replaced by a stand-in whose `wait()` throws and whose exit callbacks the spec fires by hand: the
-- old code (`vim.system(...):wait()` on Windows PowerShell) froze the editor 0.2 s idle and 8 s under load (testing
-- perf, 2026-11-21). The path is asked once per session; nothing real starts and no real profile is opened.
---@diagnostic disable: duplicate-set-field

---@param H table
local function spec(H)
  local eq, ok = H.eq, H.ok
  local pp = require("bindings.usrcmds.powershell_profile")

  local saved = { system = vim.system, notify = vim.notify, executable = vim.fn.executable }
  local function restore()
    vim.system, vim.notify, vim.fn.executable = saved.system, saved.notify, saved.executable
    pp._reset()
  end

  ---@type { argv: string[], finish: fun(res: table) }[]
  local started = {}
  local function stand_in()
    started = {}
    vim.system = function(argv, _opts, on_exit)
      started[#started + 1] = { argv = argv, finish = on_exit }
      return {
        wait = function()
          error("waited for " .. table.concat(argv, " "))
        end,
      }
    end
  end

  local errors = {}
  vim.notify = function(msg, level)
    if level == vim.log.levels.ERROR then
      errors[#errors + 1] = msg
    end
  end
  vim.fn.executable = function(name)
    return name == "powershell" and 1 or saved.executable(name)
  end

  local dir = H.tmpdir()
  local profile = vim.fs.normalize(dir .. "/WindowsPowerShell/Microsoft.PowerShell_profile.ps1")
  local function current()
    return vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  end
  local function settle(pred)
    vim.wait(1000, pred, 5)
  end

  local passed, err = pcall(function()
    pp._reset()
    stand_in()
    vim.cmd("enew")
    local start_buf = vim.api.nvim_get_current_buf()

    pp.open()
    eq(#started, 1, "one PowerShell started")
    eq(started[1].argv[1], "powershell", "a bare program name")
    ok(
      vim.tbl_contains(started[1].argv, "-NoProfile"),
      "PowerShell without the user's profile scripts"
    )
    eq(vim.api.nvim_get_current_buf(), start_buf, "nothing opens before PowerShell answered")

    started[1].finish({ code = 0, stdout = profile, stderr = "" })
    settle(function()
      return current() == profile
    end)
    eq(current(), profile, "the answer opens the profile")
    eq(#errors, 0, "no error on the way")

    -- the second time: from the session cache, at once, nothing started
    vim.cmd("enew")
    pp.open()
    eq(#started, 1, "the path is asked once per session")
    eq(current(), profile, "a known path opens at once")

    -- two calls before the answer share one start and open the file once
    pp._reset()
    stand_in()
    vim.cmd("enew")
    pp.open()
    pp.open()
    eq(#started, 1, "calls during a running query share it")
    local edits = 0
    local au = vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if current() == profile then
          edits = edits + 1
        end
      end,
    })
    started[1].finish({ code = 0, stdout = profile .. "\r\n", stderr = "" })
    settle(function()
      return current() == profile
    end)
    vim.wait(50)
    vim.api.nvim_del_autocmd(au)
    eq(current(), profile, "the trailing line break is not part of the path")
    eq(edits, 1, "the superseded call opens nothing")

    -- cancel before the answer: nothing opens
    pp._reset()
    stand_in()
    vim.cmd("enew")
    local before = vim.api.nvim_get_current_buf()
    pp.open()
    pp.cancel()
    started[1].finish({ code = 0, stdout = profile, stderr = "" })
    vim.wait(50)
    eq(vim.api.nvim_get_current_buf(), before, "a cancelled call opens nothing")

    -- a failing PowerShell: an error, nothing cached, the next call asks again
    pp._reset()
    stand_in()
    errors = {}
    vim.cmd("enew")
    pp.open()
    started[1].finish({ code = 1, stdout = "", stderr = "boom" })
    settle(function()
      return #errors > 0
    end)
    eq(#errors, 1, "a failing PowerShell is reported")
    ok(errors[1]:find("boom", 1, true) ~= nil, "with its error text")
    pp.open()
    eq(#started, 2, "a failure is not cached")

    -- PowerShell cannot be started at all
    pp._reset()
    errors = {}
    vim.system = function()
      error("ENOENT")
    end
    pp.open()
    eq(#errors, 1, "a failed start is reported")
    pp.open()
    eq(#errors, 2, "and tried again next time")
  end)
  restore()
  if not passed then
    error(err, 0)
  end
end

-- `return function(H)` literally: testing.nvim recognises this spec's dialect by that signature
return function(H)
  spec(H)
end
