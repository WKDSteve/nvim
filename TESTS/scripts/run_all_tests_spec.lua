return function(H)
  -- TESTS/scripts/run_all_tests_spec.lua -- scripts/run_all_tests.lua: the whole run holds ONE slot of the queue of
  -- heavy runs (so another session's suite cannot run between two repos, and its wait does not count into a repo's
  -- timeout), and a red repo names its red cases instead of a bare "RED".
  local eq, ok = H.eq, H.ok
  local script = vim.fs.joinpath(vim.fn.getcwd(), "scripts", "run_all_tests.lua")
  ok(vim.uv.fs_stat(script) ~= nil, "the spec runs from the root of the config")

  rawset(_G, "RUN_ALL_TESTS_AS_LIBRARY", true)
  local lib = dofile(script)
  rawset(_G, "RUN_ALL_TESTS_AS_LIBRARY", nil)
  ok(type(lib) == "table", "loaded as a library, the script runs nothing and returns its pieces")

  -- the red cases of an IR
  local ir = {
    summary = { pass = 2, fail = 2, error = 1, timeout = 1 },
    cases = {
      { id = "TESTS/b_spec.lua::slow", status = "timeout" },
      { id = "TESTS/a_spec.lua::one", status = "pass" },
      { id = "TESTS/a_spec.lua::two", status = "fail" },
      { file = "TESTS/c_spec.lua", status = "error" },
      { id = "TESTS/a_spec.lua::three", status = "skip" },
      { id = "TESTS/a_spec.lua::four", status = "fail" },
    },
  }
  local cases, total = lib.failed_cases(ir, 10)
  eq(total, 4, "fail, error and timeout are red; pass and skip are not")
  eq(cases, {
    "TESTS/a_spec.lua::four (fail)",
    "TESTS/a_spec.lua::two (fail)",
    "TESTS/b_spec.lua::slow (timeout)",
    "TESTS/c_spec.lua (error)",
  }, "each red case by its id (its file without one) and status, sorted")
  local few, all = lib.failed_cases(ir, 2)
  eq(#few, 2, "at most the limit is listed")
  eq(all, 4, "but the count is of all of them")
  eq({ lib.failed_cases({ summary = {} }, 5) }, { {}, 0 }, "an IR without cases has none")

  -- lib.nvim's own runner: its red spec files come from its output
  local own_out = table.concat({
    "ok    a_spec.lua",
    "FAIL  b_spec.lua",
    "      TESTS/b_spec.lua:12: expected 1, got 2",
    "ok    c_spec.lua",
    "FAIL  d_spec.lua",
    "",
    "2 spec(s) failed",
  }, "\n")
  eq({ lib.own_failures(own_out, 10) }, {
    { "b_spec.lua (TESTS/b_spec.lua:12: expected 1, got 2)", "d_spec.lua" },
    2,
  }, "each FAIL line by its file and the error under it")
  eq(
    { lib.own_failures(own_out, 1) },
    { { "b_spec.lua (TESTS/b_spec.lua:12: expected 1, got 2)" }, 2 },
    "at most the limit"
  )

  -- a checkout behind its upstream: a shared checkout that lags main shows reds main has fixed
  if vim.fn.executable("git") ~= 1 then
    print("n/a  git is not on PATH: behind_upstream is not checked")
  else
    local no_hooks = H.tmpdir() -- this machine's global hooks (pre-push guard, trailer strip) stay out
    local function git(dir, args, may_fail)
      local cmd = { "git", "-c", "core.hooksPath=" .. no_hooks, "-C", dir }
      vim.list_extend(cmd, args)
      local res = vim.system(cmd, { text = true }):wait(60000)
      assert(may_fail or res.code == 0, table.concat(cmd, " ") .. ": " .. (res.stderr or ""))
      return vim.trim(res.stdout or "")
    end
    local function commit(dir, name)
      H.write(dir .. "/" .. name, name)
      git(dir, { "add", name })
      git(
        dir,
        { "-c", "user.name=T", "-c", "user.email=t@example.com", "commit", "-q", "-m", name }
      )
    end
    local bare, a, b = H.tmpdir(), H.tmpdir(), H.tmpdir()
    git(bare, { "init", "-q", "--bare", "-b", "main" })
    git(a, { "init", "-q", "-b", "main" })
    git(a, { "remote", "add", "origin", bare })
    commit(a, "one")
    git(a, { "push", "-q", "-u", "origin", "main" })
    git(b, { "clone", "-q", bare, "." })
    commit(a, "two")
    git(a, { "push", "-q" })
    local head_before = git(b, { "rev-parse", "HEAD" })
    eq(
      lib.behind_upstream(b, false),
      0,
      "without --fetch: what the checkout last fetched (nothing new yet)"
    )
    eq(lib.behind_upstream(b, true), 1, "with --fetch: one commit behind its upstream")
    eq(
      git(b, { "rev-parse", "HEAD" }),
      head_before,
      "fetching moved neither the branch nor the working tree"
    )
    eq(lib.behind_upstream(a, false), 0, "a checkout at its upstream is 0 behind")
    eq(lib.behind_upstream(H.tmpdir(), false), nil, "a folder that is no repository: unknown")

    -- --at=origin: the run sees origin/main, never the (stale) shared checkout, and leaves that checkout alone
    commit(a, "three")
    git(a, { "push", "-q" })
    local origin_sha = git(a, { "rev-parse", "HEAD" })
    local b_head, b_status = git(b, { "rev-parse", "HEAD" }), git(b, { "status", "--porcelain" })
    local base = H.tmpdir() .. "/wt"
    local path, sha = lib.origin_worktree(b, "demo.nvim", base)
    ok(path ~= nil, "a worktree at origin/main: " .. tostring(sha))
    path = path or ""
    eq(sha, origin_sha:sub(1, 9), "at the commit of origin/main (fetched first)")
    eq(git(path, { "rev-parse", "HEAD" }), origin_sha, "its HEAD is origin/main")
    ok(vim.uv.fs_stat(path .. "/three") ~= nil, "it holds what only origin/main has")
    ok(vim.uv.fs_stat(b .. "/two") == nil, "the checkout itself did not move")
    eq(git(b, { "rev-parse", "HEAD" }), b_head, "the checkout's HEAD is where it was")
    eq(git(b, { "status", "--porcelain" }), b_status, "and its working tree is untouched")
    eq(
      git(path, { "symbolic-ref", "-q", "--short", "HEAD" }, true),
      "",
      "detached: no branch is made or taken"
    )

    local again = lib.origin_worktree(b, "demo.nvim", base)
    eq(again, path, "a worktree left at the same path (an aborted run) is replaced")
    eq(lib.remove_worktree(b, path), nil, "a clean worktree is removed")
    ok(vim.uv.fs_stat(path) == nil, "and its folder is gone")
    ok(not git(b, { "worktree", "list" }):find("demo.nvim", 1, true), "and git forgot it")

    path = lib.origin_worktree(b, "demo.nvim", base) or ""
    H.write(path .. "/left-by-a-spec", "x")
    local problem = lib.remove_worktree(b, path)
    H.has(problem or "", path, "a worktree the suite left dirty is not forced away, it is named")
    ok(vim.uv.fs_stat(path .. "/left-by-a-spec") ~= nil, "and what is in it stays")
    os.remove(path .. "/left-by-a-spec")
    eq(lib.remove_worktree(b, path), nil, "clean again, it goes")

    local pool = lib.worktree_pool({ ["demo.nvim"] = b }, base)
    local w = pool.get("demo.nvim")
    eq(w.sha, origin_sha:sub(1, 9), "the pool makes the worktree on first use")
    eq(pool.get("demo.nvim").path, w.path, "and hands the same one to every repo that needs it")
    local foreign = pool.get("no-such.nvim")
    ok(
      foreign.external and not foreign.err and not foreign.path,
      "a dependency without a checkout (telescope.nvim) is not ours: test.sh resolves it, no INFRA row"
    )
    eq(pool.drop_all(), {}, "the end of the run removes them all")
    ok(vim.uv.fs_stat(w.path) == nil, "nothing is left of them")

    local no_origin = H.tmpdir()
    git(no_origin, { "init", "-q", "-b", "main" })
    local none, why = lib.origin_worktree(no_origin, "x.nvim", base)
    ok(none == nil, "a checkout without a remote gets no worktree")
    ok(why ~= "", "and says why: " .. why)
  end

  -- the dependencies a repo's scripts/test.sh resolves, and the variable that hands one over
  eq(lib.env_name_of("testing.nvim"), "TESTING_NVIM_DIR", "testing.nvim -> $TESTING_NVIM_DIR")
  eq(lib.env_name_of("ui.nvim"), "UI_NVIM_DIR", "ui.nvim -> $UI_NVIM_DIR")
  local repo = H.tmpdir()
  H.write(
    repo .. "/scripts/test.sh",
    "#!/usr/bin/env bash\n# DEPS=('old.nvim')\nDEPS=('testing.nvim' 'lib.nvim' 'ui.nvim')\n"
  )
  eq(
    lib.test_deps(repo),
    { "testing.nvim", "lib.nvim", "ui.nvim" },
    "the DEPS line, in order (a comment does not count)"
  )
  eq(lib.test_deps(H.tmpdir()), {}, "no scripts/test.sh: no dependencies")

  -- the queue: one slot for the whole run
  local found = vim.api.nvim_get_runtime_file("lua/testing/queue.lua", false)[1]
  local testing_dir = found and vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(found)))
  -- not ipairs: an unset $TESTING_NVIM_DIR is a nil in the list and would end it before $REPOS_DIR
  local candidates = {
    vim.env.TESTING_NVIM_DIR or "",
    vim.env.REPOS_DIR and (vim.env.REPOS_DIR .. "/testing.nvim") or "",
  }
  for i = 1, #candidates do
    local dir = candidates[i]
    if not testing_dir and dir ~= "" and vim.uv.fs_stat(dir .. "/lua/testing/queue.lua") then
      testing_dir = dir
    end
  end
  if not testing_dir then
    print(
      "n/a  testing.nvim not found (runtimepath, $TESTING_NVIM_DIR, $REPOS_DIR): the queue is not checked"
    )
    return
  end
  local lock = vim.fs.joinpath(H.tmpdir(), "heavy.lock")
  -- the suite runs with the queue switched off for its specs (and maybe inside a holder's token): a fresh queue here
  local saved_env = {}
  for _, name in ipairs({
    "TESTING_QUEUE",
    "TESTING_HEAVY_RUN",
    "TESTING_QUEUE_FILE",
    "TESTING_QUEUE_SLOTS",
    "CI",
  }) do
    saved_env[name] = vim.env[name]
    vim.env[name] = nil
  end
  vim.env.TESTING_QUEUE_FILE = lock
  -- a module of its own: the runner's copy may hold the real queue, and a nested acquire would only count up
  local runners_queue = package.loaded["testing.queue"]
  package.loaded["testing.queue"] = nil
  local said = {}
  local okc, queue, handle = pcall(lib.take_queue, testing_dir, function(s)
    said[#said + 1] = s
  end)
  local held_lock = vim.uv.fs_stat(lock) ~= nil
  local token = vim.env.TESTING_HEAVY_RUN
  local child = okc
      and vim
        .system({ vim.v.progpath, "-n", "--clean", "--headless", "-u", "NONE", "-l", "-" }, {
          stdin = "io.stdout:write(os.getenv('TESTING_HEAVY_RUN') or '')",
          text = true,
        })
        :wait(30000)
    or {}
  if okc and queue then
    queue.release(handle)
  end
  local lock_after = vim.uv.fs_stat(lock) ~= nil
  package.loaded["testing.queue"] = runners_queue
  for name, value in pairs(saved_env) do
    vim.env[name] = value
  end
  vim.env.TESTING_QUEUE_FILE = saved_env.TESTING_QUEUE_FILE

  ok(okc, "take_queue does not throw: " .. tostring(queue))
  ok(
    queue ~= nil and handle ~= nil,
    "testing.nvim found: the run takes the queue (" .. table.concat(said) .. ")"
  )
  ok(held_lock, "the lock file of the queue is held while the repos run")
  ok(token ~= nil and token ~= "", "the holder's token is in $TESTING_HEAVY_RUN")
  eq(
    child.stdout,
    token,
    "a repo run started by the script inherits the token, so it never waits for the slot"
  )
  ok(not lock_after, "the slot is given back at the end")

  -- the script for real (one repo without specs: nothing is run), on a lock file of its own so that it never waits
  -- for this machine's queue: it must take the queue, not fall back to "every repo queues on its own"
  local real = vim
    .system({
      vim.v.progpath,
      "-n",
      "--clean",
      "--headless",
      "-u",
      "NONE",
      "-l",
      script,
      "--only=replacer.nvim",
    }, {
      text = true,
      cwd = vim.fn.getcwd(),
      env = {
        TESTING_QUEUE = "",
        TESTING_HEAVY_RUN = "",
        TESTING_QUEUE_FILE = vim.fs.joinpath(H.tmpdir(), "real.lock"),
        TESTING_NVIM_DIR = testing_dir,
        NVIM_CONFIG_DIR = vim.fn.getcwd(),
        NVIM = "",
        NVIM_LISTEN_ADDRESS = "",
      },
    })
    :wait(120000)
  local real_out = (real.stdout or "") .. (real.stderr or "")
  ok(
    not real_out:find("cannot load testing.queue", 1, true)
      and not real_out:find("testing.nvim not found", 1, true),
    "the real script loads testing.queue (lib.nvim is on its runtimepath first):\n" .. real_out
  )

  local none_said = {}
  local q2, h2 = lib.take_queue(vim.fs.joinpath(H.tmpdir(), "no-testing"), function(s)
    none_said[#none_said + 1] = s
  end)
  ok(q2 == nil and h2 == nil, "without testing.nvim the run goes on without the queue")
  H.has(table.concat(none_said), "testing.nvim not found", "and says so")
end
