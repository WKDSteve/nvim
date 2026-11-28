-- Run the test suite of every personal plugin and print one row per repo.
--
-- Started by `scripts/run_all_tests.sh` (`nvim -l`). Each migrated repo is run through its own
-- `scripts/test.sh --json <ir>` and the machine-readable result (the IR of testing.nvim: `summary`
-- counts per status) is read back; no sentinel is grepped and no runner is searched for.
--
-- The list of repos is not rebuilt here from a directory glob: it is what the config already knows,
-- `plugins.personal.core.export.projects()` ({ name, repo, dir } of every enabled personal plugin
-- with a checkout on this machine). This script stays in nvim-config/scripts because it depends on
-- that checkout layout (TOOL-PLACEMENT.md, case 5); testing.nvim itself knows nothing of it.
--
-- Exit code: 0 every repo green, 1 at least one repo red, 2 usage error, 3 infrastructure error (a
-- repo without a runner or without testing.nvim, an IR that is missing or unreadable or contradicts
-- the exit code, a run that timed out, a name in --only that is no repo, any error of this script).
-- An infrastructure error is never reported as success and wins over red: the verdict cannot be trusted.
--
-- The whole run holds one slot of the queue of heavy runs of testing.nvim (one at a time per machine), so another
-- session's suite cannot run between two repos; the repo runs it starts inherit the slot and never wait. Under the
-- table every red repo lists its red cases (id and status) from its IR, at most 10.
--
-- It tests the checkouts as they are. A row whose checkout is behind its upstream says so ("N behind upstream"): such
-- a red may be fixed on main already. `--fetch` updates the remote refs first (`git fetch`, nothing else is touched).
--
-- `--at=origin` tests what is on `origin/main` instead: each repo is fetched and checked out as a detached worktree
-- at `$REPOS_DIR/.run_all_tests-origin/<name>` (below the trusted root of testing.nvim: a worktree in the temp folder
-- would be refused as untrusted, and widening `$TESTING_TRUST_ROOTS` is not this script's call; without `$REPOS_DIR`
-- the temp folder), and so is every dependency its `scripts/test.sh` lists
-- (`DEPS=(...)`), handed over as `$<NAME>_DIR` (which test.sh looks at first). The shared checkouts are not touched
-- (other sessions work in them); a worktree is removed after use with `git worktree remove` (never `--force`: one the
-- suite left dirty stays and is named). A worktree left by an aborted run sits at the same path and is removed first.
--
-- Usage:  nvim -l scripts/run_all_tests.lua [--only=a.nvim,b.nvim] [--timeout=SECONDS] [--fetch] [--at=origin]
--
-- Exceptions, on purpose:
--   * lib.nvim keeps its own runner (decision of 2026-10-06, "Bootstrap circle"): `TESTS/run.lua`,
--     verdict by exit code and the sentinel `LIB_TESTS_OK`.
--   * replacer.nvim has no specs: listed as such, not as a failure.

local uv = vim.uv or vim.loop
local is_windows = vim.fn.has("win32") == 1

--- Repos that have no tests at all (not an infrastructure error).
local NO_SPECS = { ["replacer.nvim"] = true }
--- Repos whose suite runs on its own runner, not on testing.nvim.
local OWN_RUNNER = { ["lib.nvim"] = "LIB_TESTS_OK" }

local STATUSES = { "pass", "fail", "error", "skip", "xfail", "xpass", "timeout", "crash" }

---@param message string
---@param code integer
local function die(message, code)
  io.stderr:write("run_all_tests: " .. message .. "\n")
  os.exit(code)
end

local USAGE = "[--only=a.nvim,b.nvim] [--timeout=SECONDS] [--fetch] [--at=origin]"

--- The options: `--only=a,b`, `--timeout=SECONDS`, `--fetch` and `--at=origin`, nothing else. A value that cannot be
--- read is refused: a mistyped `--only` that fell back to "every repo" would start a 20 minute run.
---@return table<string, boolean> only
---@return integer timeout_ms
---@return boolean fetch
---@return boolean at_origin
local function parse_args()
  local only, timeout_ms, fetch, at_origin = {}, 900 * 1000, false, false
  for _, a in ipairs(_G.arg or {}) do
    local names = a:match("^%-%-only=(.*)$")
    local seconds = a:match("^%-%-timeout=(.*)$")
    local at = a:match("^%-%-at=(.*)$")
    if a == "--fetch" then
      fetch = true
    elseif at then
      if at ~= "origin" then
        die("--at only knows 'origin' (origin/main), got '" .. at .. "'", 2)
      end
      at_origin = true
    elseif names then
      for name in names:gmatch("[^,]+") do
        only[name] = true
      end
      if next(only) == nil then
        die("--only needs at least one repo name (--only=a.nvim,b.nvim)", 2)
      end
    elseif seconds then
      local n = tonumber(seconds)
      if not n or n ~= n or n <= 0 then
        die("--timeout needs a number of seconds above zero, got '" .. seconds .. "'", 2)
      end
      timeout_ms = math.floor(n * 1000)
    else
      die("unknown argument '" .. a .. "' (usage: " .. USAGE .. ")", 2)
    end
  end
  return only, timeout_ms, fetch, at_origin
end

---@param dir string
---@param args string[]
---@return table
local function git(dir, args)
  local cmd = { "git", "-C", dir }
  vim.list_extend(cmd, args)
  return vim.system(cmd, { text = true }):wait(120000)
end

---@param res table
---@return string
local function first_line(res)
  local text = (res.stderr or "") ~= "" and res.stderr or (res.stdout or "")
  return vim.trim(text:match("[^\n]*") or ""):sub(1, 80)
end

--- The variable `scripts/test.sh` reads a dependency's folder from: `testing.nvim` -> `TESTING_NVIM_DIR`.
---@param name string
---@return string
local function env_name_of(name)
  return (name:upper():gsub("[^A-Z0-9]", "_")) .. "_DIR"
end

--- The dependencies a repo's `scripts/test.sh` resolves (its line `DEPS=('testing.nvim' 'lib.nvim')`), in order.
---@param dir string
---@return string[]
local function test_deps(dir)
  local f = io.open(dir .. "/scripts/test.sh", "rb")
  if not f then
    return {}
  end
  local text = f:read("*a")
  f:close()
  local list = ("\n" .. text):match("\nDEPS=%(([^)]*)%)")
  local out = {}
  for name in (list or ""):gmatch("[%w%._%-]+") do
    out[#out + 1] = name
  end
  return out
end

--- A detached worktree of the checkout `dir` at its `origin/main` (fetched first), at `base`/`name`. The checkout
--- itself is not touched: no branch, index or working tree of it moves. A worktree already at that path (left by an
--- aborted run) is removed first, without `--force`.
---@param dir string
---@param name string
---@param base string
---@return string|nil path
---@return string sha_or_problem the short commit on success, else why there is none
local function origin_worktree(dir, name, base)
  local fetched = git(dir, { "fetch", "-q", "origin" })
  if fetched.code ~= 0 then
    return nil, "git fetch failed: " .. first_line(fetched)
  end
  local rev = git(dir, { "rev-parse", "--verify", "-q", "origin/main^{commit}" })
  if rev.code ~= 0 then
    return nil, "no origin/main"
  end
  local sha = vim.trim(rev.stdout or "")
  local path = vim.fs.joinpath(base, name)
  if uv.fs_stat(path) then
    local gone = git(dir, { "worktree", "remove", path })
    if gone.code ~= 0 then
      return nil, "a leftover worktree is in the way (" .. path .. "): " .. first_line(gone)
    end
  end
  vim.fn.mkdir(base, "p")
  local added = git(dir, { "worktree", "add", "-q", "--detach", path, sha })
  if added.code ~= 0 then
    return nil, "git worktree add failed: " .. first_line(added)
  end
  return path, sha:sub(1, 9)
end

--- Remove a worktree made by `origin_worktree`, never with `--force`: one the suite left dirty stays, and the
--- problem comes back (nil when it is gone).
---@param dir string the checkout it belongs to
---@param path string
---@return string|nil problem
local function remove_worktree(dir, path)
  local res = git(dir, { "worktree", "remove", path })
  if res.code == 0 then
    return nil
  end
  return ("worktree left at %s: %s"):format(path, first_line(res))
end

--- How many commits the checkout in `dir` is behind its upstream, or nil when that cannot be told (no upstream, not
--- a repository). The run tests the shared checkouts as they are, and the sessions push from worktrees of their own:
--- a checkout that lags `origin/main` shows reds that `main` fixed long ago (2026-11-28: casedesk.nvim 1 behind,
--- filetree.nvim 6 behind, both red for exactly that). `fetch` first updates the remote refs (`git fetch`: no
--- working tree, branch or index is touched).
---@param dir string
---@param fetch boolean
---@return integer|nil behind
local function behind_upstream(dir, fetch)
  if fetch then
    vim.system({ "git", "-C", dir, "fetch", "-q" }, { text = true }):wait(60000)
  end
  local res = vim
    .system({ "git", "-C", dir, "rev-list", "--count", "HEAD..@{upstream}" }, { text = true })
    :wait(30000)
  if res.code ~= 0 then
    return nil
  end
  return tonumber(vim.trim(res.stdout or ""))
end

---@return string
local function find_bash()
  if not is_windows then
    return "bash"
  end
  -- `bash` on PATH is often the WSL one, which sees none of these paths.
  for _, candidate in ipairs({
    "C:/Program Files/Git/bin/bash.exe",
    "C:/Program Files/Git/usr/bin/bash.exe",
    "C:/Program Files (x86)/Git/bin/bash.exe",
  }) do
    if uv.fs_stat(candidate) then
      return candidate
    end
  end
  local found = vim.fn.exepath("bash")
  if found:lower():find("system32", 1, true) then
    die("only the WSL bash was found (" .. found .. "); install Git for Windows", 3)
  end
  return found
end

---@return table[] projects
local function projects()
  local config_dir = vim.env.NVIM_CONFIG_DIR
  if not config_dir or config_dir == "" then
    config_dir = vim.fn.stdpath("config")
  end
  local lib = vim.env.LIB_NVIM_DIR
  if not lib or lib == "" then
    lib = (vim.env.REPOS_DIR or "") .. "/lib.nvim"
  end
  vim.opt.rtp:append(config_dir)
  vim.opt.rtp:append(lib)
  local ok, export = pcall(require, "plugins.personal.core.export")
  if not ok then
    die("cannot load plugins.personal.core.export: " .. tostring(export), 3)
  end
  local list, err = export.projects()
  if err then
    die(tostring(err), 3)
  end
  if type(list) ~= "table" then
    die("export.projects() returned no list", 3)
  end
  return list
end

---@param path string
---@return boolean
local function exists(path)
  return uv.fs_stat(path) ~= nil
end

---@class RunRow
---@field repo string
---@field kind "ok"|"red"|"infra"|"none"
---@field counts table<string, integer|string>
---@field secs number
---@field note string
---@field failed? string[] The red cases of the repo (`file::case (status)`), from its IR.
---@field failed_total? integer How many red cases there are (`failed` holds at most `MAX_FAILED_SHOWN`).
---@field behind? integer Commits the checkout is behind its upstream (nil: unknown).

--- The red cases listed per repo under the table.
local MAX_FAILED_SHOWN = 10
--- Statuses that make a case red.
local RED = { fail = true, error = true, timeout = true, crash = true }

--- The red cases of an IR, as `id (status)`, sorted; at most `limit` of them and how many there are in all. A red
--- row of the table only says "RED": a red run under load must say which specs went red, or a timeout and a real
--- failure look the same.
---@param ir table
---@param limit integer
---@return string[] cases
---@return integer total
local function failed_cases(ir, limit)
  local out = {}
  for _, c in ipairs(type(ir.cases) == "table" and ir.cases or {}) do
    if type(c) == "table" and RED[c.status] then
      local id = type(c.id) == "string" and c.id or tostring(c.file or "?")
      out[#out + 1] = ("%s (%s)"):format(id, c.status)
    end
  end
  table.sort(out)
  local total = #out
  for i = total, limit + 1, -1 do
    out[i] = nil
  end
  return out, total
end

--- The red spec files of lib.nvim's own runner (`FAIL  <file>` and the error on the next line), at most `limit`
--- and how many there are: its row said only "1 spec file(s) failed", and which one is the first question.
---@param out string
---@param limit integer
---@return string[] cases
---@return integer total
local function own_failures(out, limit)
  local cases = {}
  local lines = vim.split(out, "\n", { plain = true })
  for i, line in ipairs(lines) do
    local name = line:match("^FAIL%s+(%S+)")
    if name then
      local why = vim.trim(lines[i + 1] or "")
      cases[#cases + 1] = why ~= "" and ("%s (%s)"):format(name, why:sub(1, 100)) or name
    end
  end
  local total = #cases
  for i = total, limit + 1, -1 do
    cases[i] = nil
  end
  return cases, total
end

--- Take the queue of heavy runs of testing.nvim (one at a time per machine) for the WHOLE run, not per repo. Each
--- repo's `scripts/test.sh` queues on its own; without this the Gesamtlauf left the slot between two repos, another
--- session's suite ran in between, and the wait for it counted into the next repo's timeout (an INFRA row), or two
--- suites ran at once (the specs that time out under load went red, other repos each run). The holder's token in
--- `$TESTING_HEAVY_RUN` reaches every repo run this script starts: they belong to this run and never wait. nil when
--- testing.nvim is not found (said once; the repos then queue one by one, as before).
---@param testing_dir string|nil
---@param say fun(s: string)
---@return table|nil queue the module, to release the handle
---@return table|nil handle
local function take_queue(testing_dir, say)
  if not testing_dir or not uv.fs_stat(testing_dir .. "/lua/testing/queue.lua") then
    say("run_all_tests: testing.nvim not found, every repo queues on its own\n")
    return nil, nil
  end
  vim.opt.rtp:append(testing_dir)
  local ok, queue = pcall(require, "testing.queue")
  if not ok then
    say("run_all_tests: cannot load testing.queue: " .. tostring(queue) .. "\n")
    return nil, nil
  end
  local handle, problem =
    queue.acquire(queue.from_env(), "run_all_tests (every personal plugin)", say)
  if not handle then
    die("queue: " .. tostring(problem), 3)
  end
  return queue, handle
end

--- Run `argv` and wait at most `timeout_ms`. On a timeout the whole process tree is stopped (the editor that
--- `test.sh` started is a grandchild and would otherwise run on into the next repo) and nil comes back.
---@param argv string[]
---@param opts table
---@param timeout_ms integer
---@return table|nil result  # nil: timed out
local function spawn(argv, opts, timeout_ms)
  local done, res = false, nil
  local obj = vim.system(argv, vim.tbl_extend("force", opts, { text = true }), function(r)
    res, done = r, true
  end)
  vim.wait(timeout_ms, function()
    return done
  end, 50)
  if done then
    return res
  end
  if is_windows then
    -- by the PID of our own child, with its children: never by image name
    vim.system({ "taskkill", "/PID", tostring(obj.pid), "/T", "/F" }):wait(10000)
  end
  pcall(obj.kill, obj, 9)
  vim.wait(5000, function()
    return done
  end, 50)
  return nil
end

--- One repo through `scripts/test.sh --json`.
---@param p table
---@param bash string
---@param timeout_ms integer
---@param env? table<string, string> `$<NAME>_DIR` of the dependencies (`--at=origin`)
---@return RunRow
local function run_testing(p, bash, timeout_ms, env)
  local ir_file = vim.fn.tempname() .. "-" .. p.name .. ".json"
  local started = uv.hrtime()
  -- The editor's RPC socket must not leak into the child: a spec could reach back into this session.
  local script = 'unset NVIM NVIM_LISTEN_ADDRESS; exec bash scripts/test.sh --json "$1"'
  local res = spawn(
    { bash, "-c", script, "run_all_tests", ir_file },
    { cwd = p.dir, env = env },
    timeout_ms
  )
  local secs = (uv.hrtime() - started) / 1e9

  ---@type RunRow
  local row = { repo = p.name, kind = "infra", counts = {}, secs = secs, note = "" }
  local raw
  local f = io.open(ir_file, "rb")
  if f then
    raw = f:read("*a")
    f:close()
  end
  os.remove(ir_file) -- on every path, a timed out run included
  if not res or res.signal ~= 0 or res.code == 124 then
    row.note = ("timed out after %d s"):format(timeout_ms / 1000)
    return row
  end
  -- JSON null stays out of the tables (`luanil`): a null count must not pass for a number
  local ok, ir = pcall(vim.json.decode, raw or "", { luanil = { object = true, array = true } })
  if not raw or raw == "" or not ok or type(ir) ~= "table" or type(ir.summary) ~= "table" then
    local tail = vim.trim(
      ((res.stderr or "") ~= "" and res.stderr or res.stdout or ""):match("([^\n]*)%s*$") or ""
    )
    row.note = ("no result IR (exit %s): %s"):format(tostring(res.code), tail:sub(1, 60))
    return row
  end
  for _, s in ipairs(STATUSES) do
    local v = ir.summary[s]
    if v ~= nil and type(v) ~= "number" then
      row.counts = {}
      row.note = "the IR holds a non-number for '" .. s .. "'"
      return row
    end
    row.counts[s] = v or 0
  end
  local bad = row.counts.fail + row.counts.error + row.counts.timeout + row.counts.crash
  if bad > 0 then
    row.failed, row.failed_total = failed_cases(ir, MAX_FAILED_SHOWN)
  end
  if res.code == 0 and bad == 0 then
    row.kind = "ok"
  elseif res.code == 0 then
    row.note = "exit 0 but the IR holds failures"
  elseif res.code == 1 and bad > 0 then
    row.kind = "red" -- a red run exits 1 and still wrote its IR
  elseif res.code == 1 then
    row.note = "exit 1 but the IR holds no failure"
  else
    row.note = "exit " .. tostring(res.code) .. " (the runner's own error)"
  end
  return row
end

--- lib.nvim: its own runner, verdict by exit code and sentinel.
---@param p table
---@param sentinel string
---@param timeout_ms integer
---@param bash string
---@return RunRow
local function run_own(p, sentinel, timeout_ms, bash)
  local started = uv.hrtime()
  local lib = p.dir
  -- the same RPC-socket hygiene as `run_testing`; nvim's own path is handed over as an argument
  local script =
    'unset NVIM NVIM_LISTEN_ADDRESS; exec "$1" -n --clean --headless -u NONE -c "set rtp+=." -l TESTS/run.lua'
  local res = spawn(
    { bash, "-c", script, "run_all_tests", vim.v.progpath },
    { cwd = p.dir, env = { LIB_NVIM_PATH = lib, LIB_NVIM_DIR = lib } },
    timeout_ms
  )
  ---@type RunRow
  local row = {
    repo = p.name,
    kind = "infra",
    counts = {},
    secs = (uv.hrtime() - started) / 1e9,
    note = "own runner",
  }
  if not res or res.signal ~= 0 or res.code == 124 then
    row.note = "own runner: timed out"
    return row
  end
  local out = (res.stdout or "") .. (res.stderr or "")
  if res.code == 0 and out:find(sentinel, 1, true) then
    row.kind = "ok"
  elseif out:find("spec(s) failed", 1, true) then
    row.kind = "red"
    row.failed, row.failed_total = own_failures(out, MAX_FAILED_SHOWN)
    row.note = "own runner: "
      .. (out:match("(%d+) spec%(s%) failed") or "?")
      .. " spec file(s) failed"
  else
    row.note = "own runner: no verdict (exit " .. tostring(res.code) .. ")"
  end
  return row
end

--- Set by `main` under `--at=origin`: removes the worktrees still standing. Also called when the script fails.
---@type fun()|nil
local cleanup_worktrees = nil

--- The worktrees of `--at=origin`: one per repo name, made on first use, shared by every repo that needs it as a
--- dependency. `checkouts` maps a repo name to its shared checkout. A name with no checkout under `$REPOS_DIR` is
--- not one of ours (telescope.nvim for cmdlog.nvim): `external`, and test.sh resolves it as always.
---@param checkouts table<string, string>
---@param base string
local function worktree_pool(checkouts, base)
  ---@alias RatWorktree {src: string, path?: string, sha?: string, err?: string, external?: boolean}
  local made = {} ---@type table<string, RatWorktree>
  local pool = {}
  ---@param name string
  ---@return RatWorktree
  function pool.get(name)
    if not made[name] then
      local src = checkouts[name]
      if not src then
        local candidate = (vim.env.REPOS_DIR or "") .. "/" .. name
        src = uv.fs_stat(candidate .. "/.git") and candidate or nil
      end
      if not src then
        made[name] = { src = "", external = true }
      else
        local path, info = origin_worktree(src, name, base)
        made[name] = path and { src = src, path = path, sha = info } or { src = src, err = info }
      end
    end
    return made[name]
  end
  --- Remove one worktree (it is made again when asked for later); the problem when it stays.
  ---@param name string
  ---@return string|nil
  function pool.drop(name)
    local w = made[name]
    made[name] = nil
    if w and w.path then
      return remove_worktree(w.src, w.path)
    end
    return nil
  end
  ---@return string[] problems
  function pool.drop_all()
    local problems = {}
    for _, name in ipairs(vim.tbl_keys(made)) do
      problems[#problems + 1] = pool.drop(name)
    end
    return problems
  end
  return pool
end

local function main()
  local only, timeout_ms, fetch, at_origin = parse_args()
  local bash = find_bash()
  if bash == "" then
    die("no bash found", 3)
  end
  -- first: it puts lib.nvim on the runtimepath, which testing.queue needs
  local list = projects()
  local testing_dir = vim.env.TESTING_NVIM_DIR
  if not testing_dir or testing_dir == "" then
    testing_dir = (vim.env.REPOS_DIR or "") .. "/testing.nvim"
  end
  local queue, handle = take_queue(testing_dir, function(s)
    io.stdout:write(s)
    io.stdout:flush()
  end)

  local pool
  if at_origin then
    local checkouts = {}
    for _, p in ipairs(list) do
      checkouts[p.name] = p.dir
    end
    local repos = vim.env.REPOS_DIR
    local parent = (repos and repos ~= "" and uv.fs_stat(repos)) and repos or uv.os_tmpdir()
    pool = worktree_pool(checkouts, vim.fs.joinpath(parent, ".run_all_tests-origin"))
    cleanup_worktrees = function()
      for _, problem in ipairs(pool.drop_all()) do
        io.stdout:write("run_all_tests: " .. problem .. "\n")
      end
    end
  end
  local is_dep = {} ---@type table<string, boolean> worktrees kept for later repos

  ---@param row RunRow
  ---@param text string
  local function add_note(row, text)
    row.note = row.note == "" and text or (row.note .. "; " .. text)
  end

  local known = {}
  local rows = {} ---@type RunRow[]
  for _, p in ipairs(list) do
    known[p.name] = true
    if next(only) == nil or only[p.name] then
      local row
      local env, problem, at_sha
      if pool and not NO_SPECS[p.name] then
        local w = pool.get(p.name)
        if w.err then
          problem = w.err
        else
          at_sha = w.sha
          p = { name = p.name, repo = p.repo, dir = w.path }
          env = {}
          for _, dep in ipairs(test_deps(w.path)) do
            if dep ~= p.name then
              is_dep[dep] = true
              local d = pool.get(dep)
              if d.err then
                problem = "dependency " .. dep .. ": " .. d.err
                break
              end
              if not d.external then
                env[env_name_of(dep)] = d.path
              end
            else
              env[env_name_of(dep)] = w.path
            end
          end
        end
      end
      if problem then
        row = { repo = p.name, kind = "infra", counts = {}, secs = 0, note = problem }
      elseif NO_SPECS[p.name] then
        row = { repo = p.name, kind = "none", counts = {}, secs = 0, note = "no specs" }
      elseif OWN_RUNNER[p.name] then
        row = run_own(p, OWN_RUNNER[p.name], timeout_ms, bash)
      elseif not exists(p.dir .. "/scripts/test.sh") then
        row = {
          repo = p.name,
          kind = "infra",
          counts = {},
          secs = 0,
          note = exists(p.dir .. "/TESTS") and "TESTS/ but no scripts/test.sh"
            or "no runner (no scripts/test.sh)",
        }
      else
        row = run_testing(p, bash, timeout_ms, env)
      end
      if pool then
        if at_sha then
          add_note(row, "origin/main " .. at_sha)
        end
        if not is_dep[p.name] then
          local left = pool.drop(p.name)
          if left then
            add_note(row, left)
          end
        end
      else
        row.behind = behind_upstream(p.dir, fetch)
        if row.behind and row.behind > 0 then
          add_note(row, ("%d behind upstream"):format(row.behind))
        end
      end
      rows[#rows + 1] = row
      -- shown as they finish: a full run takes a while
      io.stdout:write(("  ... %s: %s\n"):format(row.repo, row.kind))
      io.stdout:flush()
    end
  end
  -- the dependencies' worktrees, kept for later repos until now
  if cleanup_worktrees then
    cleanup_worktrees()
    cleanup_worktrees = nil
  end

  -- a name that is no repo (a typo) must not turn into "nothing ran, all green"
  local unknown = {}
  for name in pairs(only) do
    if not known[name] then
      unknown[#unknown + 1] = name
    end
  end
  table.sort(unknown)
  if #unknown > 0 then
    rows[#rows + 1] = {
      repo = table.concat(unknown, ","),
      kind = "infra",
      counts = {},
      secs = 0,
      note = "--only names no repo of export.projects()",
    }
  end
  if #rows == 0 then
    die("no repo to run: export.projects() is empty", 3)
  end

  local labels = { ok = "green", red = "RED", infra = "INFRA", none = "-" }
  local head_cells = {}
  for _, st in ipairs(STATUSES) do
    head_cells[#head_cells + 1] = ("%5s"):format(st)
  end
  io.stdout:write(
    ("\n%-24s %-6s %s %6s  %s\n"):format(
      "repo",
      "result",
      table.concat(head_cells, " "),
      "secs",
      "note"
    )
  )
  local any_red, any_infra = false, false
  local totals = {}
  for _, s in ipairs(STATUSES) do
    totals[s] = 0
  end
  for _, row in ipairs(rows) do
    local cells = {}
    for _, s in ipairs(STATUSES) do
      local v = row.counts[s]
      cells[#cells + 1] = ("%5s"):format(v == nil and "-" or tostring(v))
      if type(v) == "number" then
        totals[s] = totals[s] + v
      end
    end
    io.stdout:write(
      ("%-24s %-6s %s %6.1f  %s\n"):format(
        row.repo,
        labels[row.kind],
        table.concat(cells, " "),
        row.secs,
        row.note
      )
    )
    any_red = any_red or row.kind == "red"
    any_infra = any_infra or row.kind == "infra"
  end
  local tcells = {}
  for _, s in ipairs(STATUSES) do
    tcells[#tcells + 1] = ("%5d"):format(totals[s])
  end
  io.stdout:write(("%-24s %-6s %s\n"):format("TOTAL", "", table.concat(tcells, " ")))
  if queue then
    queue.release(handle)
  end

  for _, row in ipairs(rows) do
    if row.failed and #row.failed > 0 then
      io.stdout:write(("\n%s: %d red case(s)\n"):format(row.repo, row.failed_total or #row.failed))
      if row.behind and row.behind > 0 then
        io.stdout:write(
          ("  (the checkout is %d commit(s) behind its upstream: main may have fixed this)\n"):format(
            row.behind
          )
        )
      end
      for _, case in ipairs(row.failed) do
        io.stdout:write("  " .. case .. "\n")
      end
      if (row.failed_total or 0) > #row.failed then
        io.stdout:write(("  ... and %d more\n"):format(row.failed_total - #row.failed))
      end
    end
  end

  if any_infra then
    io.stdout:write("\nINFRASTRUCTURE ERROR: at least one repo could not be judged (exit 3).\n")
    os.exit(3)
  elseif any_red then
    io.stdout:write("\nRED (exit 1).\n")
    os.exit(1)
  end
  io.stdout:write("\nALL GREEN\n")
  os.exit(0)
end

-- TESTS/scripts/run_all_tests_spec.lua loads the file for its pieces and runs nothing.
if rawget(_G, "RUN_ALL_TESTS_AS_LIBRARY") then
  return {
    failed_cases = failed_cases,
    own_failures = own_failures,
    take_queue = take_queue,
    behind_upstream = behind_upstream,
    env_name_of = env_name_of,
    test_deps = test_deps,
    origin_worktree = origin_worktree,
    remove_worktree = remove_worktree,
    worktree_pool = worktree_pool,
  }
end

-- Any error of this script is an infrastructure error, never the "red" exit code 1 that nvim uses for it.
local ok, err = xpcall(main, debug.traceback)
if not ok then
  io.stderr:write("run_all_tests: internal error: " .. tostring(err) .. "\n")
  if cleanup_worktrees then
    pcall(cleanup_worktrees)
  end
  os.exit(3)
end
