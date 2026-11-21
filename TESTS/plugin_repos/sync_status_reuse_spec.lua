-- TESTS/plugin_repos/sync_status_reuse_spec.lua -- :MyPlugins sync asks git for a repo's status once per pass.
--
-- `ops.git_async` is replaced by a stand-in that answers like git for one repo that is behind and blocked by an
-- untracked file the incoming commit brings. testing perf (2026-11-20/21) counted four `git status --porcelain=v2`
-- and two `git diff --name-only HEAD...@{u}` for that one repo: the classification, again right after the failed
-- pull, and again (with the diff) for the triage preview. Now the pull reuses the status it was classified from while
-- that is recent, and the preview shows the blocking files the pull's re-check found. Nothing real starts.
---@diagnostic disable: duplicate-set-field

---@param H table
local function spec(H)
  local eq, ok = H.eq, H.ok
  local ops = require("bindings.usrcmds.plugin_repos.ops")
  local sync = require("bindings.usrcmds.plugin_repos.sync")
  local dash = require("bindings.usrcmds.plugin_repos.sync_dash")

  local saved = { git_async = ops.git_async, reuse = sync.STATUS_REUSE_MS, notify = vim.notify }
  local function restore()
    ops.git_async, sync.STATUS_REUSE_MS, vim.notify = saved.git_async, saved.reuse, saved.notify
  end
  vim.notify = function() end

  local STATUS = table.concat({
    "# branch.oid 1111111111111111111111111111111111111111",
    "# branch.head main",
    "# branch.upstream origin/main",
    "# branch.ab +0 -1",
    "? NEW.md",
    "",
  }, "\0")

  ---@type string[]
  local calls = {}
  local function count(prefix)
    local n = 0
    for _, c in ipairs(calls) do
      if c:sub(1, #prefix) == prefix then
        n = n + 1
      end
    end
    return n
  end
  ops.git_async = function(_path, args, _opts, on_done)
    local line = table.concat(args, " ")
    calls[#calls + 1] = line
    local run = { code = 0, stdout = "", stderr = "", timed_out = false }
    if line:find("^status %-%-porcelain=v2") then
      run.stdout = STATUS
    elseif line:find("^merge ") then
      run.code = 1
      run.stderr =
        "error: The following untracked working tree files would be overwritten by merge:\n\tNEW.md\n"
    elseif line:find("^diff %-%-name%-only") then
      run.stdout = "NEW.md\0"
    end
    vim.schedule(function()
      on_done(run)
    end)
    return {
      stop = function() end,
      on_exit = function(cb)
        cb()
      end,
    }
  end

  local base = H.tmpdir()
  vim.fn.mkdir(base .. "/one/.git", "p")
  local state_path = H.tmpdir() .. "/sync-state.json"

  ---@return MyPlugins.SyncRecord
  local function run_sync()
    calls = {}
    local got
    sync.run({
      dir = base,
      names = { "one" },
      ui = false,
      quiet = true,
      state_path = state_path,
      on_done = function(records)
        got = records
      end,
    })
    vim.wait(2000, function()
      return got ~= nil
    end, 5)
    ok(got ~= nil, "the sync came to an end")
    eq(#got, 1, "one record")
    return got[1]
  end

  local passed, err = pcall(function()
    local rec = run_sync()
    eq(rec.state, "dirty_blocked", "behind, and the untracked file is in the way")
    eq(rec.blocking, { "NEW.md" }, "the record knows the blocking file")
    eq(count("status --porcelain=v2"), 1, "one status for the classification and the failed pull")
    eq(count("diff --name-only"), 1, "one diff for the incoming files")

    -- the triage preview of that record: no second status + diff
    calls = {}
    local loaded = false
    dash.load_preview(rec, function()
      loaded = true
    end)
    vim.wait(2000, function()
      return loaded
    end, 5)
    ok(loaded, "the preview loaded")
    eq(count("status --porcelain=v2"), 0, "the preview asks for no status")
    eq(count("diff --name-only"), 0, "the preview asks for no diff")
    eq(rec.preview_parts.blocking, { "NEW.md" }, "it shows the blocking file")
    ok(rec.preview_parts.blocking_known, "as known")

    -- the saved result never carries it (a dashboard opened later asks git)
    local saved_state = vim.json.decode(table.concat(vim.fn.readfile(state_path), "\n"))
    eq(saved_state.records[1].blocking, nil, "not persisted")
    rec.blocking = nil
    rec.preview, rec.preview_parts = nil, nil
    calls = {}
    loaded = false
    dash.load_preview(rec, function()
      loaded = true
    end)
    vim.wait(2000, function()
      return loaded
    end, 5)
    eq(count("status --porcelain=v2"), 1, "without it the preview asks git")
    eq(rec.preview_parts.blocking, { "NEW.md" }, "and finds the same file")

    -- an older status is asked for again after the failed pull
    sync.STATUS_REUSE_MS = -1
    rec = run_sync()
    eq(rec.state, "dirty_blocked", "the same outcome")
    eq(count("status --porcelain=v2"), 2, "a status that is not recent is asked again")
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
