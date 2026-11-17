-- TESTS/sync/fixture.lua -- throwaway git repositories for the `:MyPlugins sync` specs.
--
-- `require`d through dofile by the specs: `local fx = dofile(dir .. "/fixture.lua")(H)`.
-- Everything lives under `H.tmpdir()`; the real repositories are never touched. The helpers are
-- synchronous on purpose (fixture code, not the code under test).

---@param H table  The spec harness (`H.tmpdir`, `H.write`).
return function(H)
  local F = {}

  ---Where the clones under test live (the sync's base directory).
  F.base = H.tmpdir() .. "/repos"
  vim.fn.mkdir(F.base, "p")

  local ENV = { GIT_TERMINAL_PROMPT = "0", GIT_CONFIG_NOSYSTEM = "1" }
  local NO_HOOKS = H.tmpdir() .. "/no-hooks"
  vim.fn.mkdir(NO_HOOKS, "p")
  -- What every repo of the fixture is pinned to in its OWN config. The code under test runs git
  -- with the machine's real global/system config (autocrlf=true is the Git for Windows default,
  -- signing and a hooks path are common), so the clones must not inherit anything that changes
  -- the bytes or the behaviour of a commit, merge or checkout.
  local PINNED = {
    { "core.autocrlf", "false" },
    { "core.hooksPath", NO_HOOKS },
    { "commit.gpgsign", "false" },
    { "tag.gpgsign", "false" },
    { "user.name", "Spec" },
    { "user.email", "spec@example.invalid" },
  }
  local ID = {}
  for _, kv in ipairs(PINNED) do
    vim.list_extend(ID, { "-c", kv[1] .. "=" .. kv[2] })
  end

  ---Run git with the argument list `args` in `dir`; raises with git's own complaint on failure.
  ---@param dir string
  ---@param args string[]
  ---@param level integer  error level of the caller to blame
  ---@return string stdout
  local function git_args(dir, args, level)
    local cmd = { "git", "-C", dir }
    vim.list_extend(cmd, ID)
    vim.list_extend(cmd, args)
    -- 60 s: a fixture call that is only slow (a machine under load) is no failure; a real hang is
    -- still stopped, by this and by the file limit of the runner.
    local res = vim.system(cmd, { text = true, env = ENV }):wait(60000)
    if res.code ~= 0 then
      -- The exit code and signal too: a call killed at the deadline (124) has an empty stderr.
      local how = res.code == 124 and "timed out after 60 s" or ("exit %d"):format(res.code)
      if (res.signal or 0) ~= 0 then
        how = how .. (", signal %d"):format(res.signal)
      end
      error(
        ("git %s failed in %s (%s): %s"):format(table.concat(args, " "), dir, how, res.stderr or ""),
        level + 1
      )
    end
    return res.stdout or ""
  end

  ---Run git in `dir`; raises with git's own complaint on failure.
  ---@param dir string
  ---@param ... string
  ---@return string stdout
  function F.git(dir, ...)
    return git_args(dir, { ... }, 2)
  end

  ---Write the pinned settings into the repo's own config (a `-c` before `clone` is transient).
  ---@param dir string
  function F.pin(dir)
    for _, kv in ipairs(PINNED) do
      F.git(dir, "config", kv[1], kv[2])
    end
  end

  -- `clone -c key=value` (after the subcommand) writes the setting into the new repo's own
  -- config: one process instead of a `git config` per setting.
  local CLONE_PINNED = { "clone", "-q" }
  for _, kv in ipairs(PINNED) do
    vim.list_extend(CLONE_PINNED, { "-c", kv[1] .. "=" .. kv[2] })
  end

  ---`git clone` of `from` into `to` with the pinned settings in the clone's config.
  ---@param from string
  ---@param to string
  local function clone_pinned(from, to)
    local args = vim.list_extend({}, CLONE_PINNED)
    vim.list_extend(args, { from, to })
    git_args(vim.fs.dirname(to), args, 2)
  end

  ---@param dir string
  ---@param file string
  ---@param text string
  ---@param message string
  function F.commit_file(dir, file, text, message)
    H.write(dir .. "/" .. file, text)
    F.git(dir, "add", file)
    F.git(dir, "commit", "-q", "-m", message)
  end

  ---The bare remote every `F.make` starts from: `a.txt` and `b.txt` on `main`, built once per
  ---fixture. A remote of its own was ~21 git processes per repo (init, clone, commits, push and a
  ---`git config` per pinned setting); cloning this one is 3, and a sync spec makes a dozen repos.
  ---One template per distinct `base` of `F.make` (the commits on top of `a` and `b`).
  ---@type table<string, string>
  local templates = {}

  ---@param base? { [1]: string, [2]: string, [3]: string }[]  file, text, message
  ---@return string
  local function template_remote(base)
    base = base or {}
    local key = vim.inspect(base)
    if templates[key] then
      return templates[key]
    end
    local remote = H.tmpdir() .. "/template.git"
    local dev = H.tmpdir() .. "/template-dev"
    local res = vim
      .system({ "git", "init", "-q", "--bare", "-b", "main", remote }, { env = ENV })
      :wait(30000)
    assert(res.code == 0, res.stderr)
    clone_pinned(remote, dev)
    F.git(dev, "checkout", "-q", "-B", "main")
    F.commit_file(dev, "a.txt", "a1\n", "a")
    F.commit_file(dev, "b.txt", "b1\n", "b")
    for _, c in ipairs(base) do
      F.commit_file(dev, c[1], c[2], c[3])
    end
    F.git(dev, "push", "-q", "-u", "origin", "main")
    templates[key] = remote
    return remote
  end

  ---A bare remote with `a.txt` and `b.txt` on `main`, a developer clone of it (what the other
  ---machine pushes from) and the clone under test `F.base/<name>`. Every repo is its own: the
  ---remote is a clone of the template, not the template. `base` adds commits after `a` and `b`
  ---that all three already have (`{ { "c.txt", text, "c base" } }`): what a spec would otherwise
  ---commit in `dev`, push and pull into `repo` itself, four git processes per repo.
  ---@param name string
  ---@param base? { [1]: string, [2]: string, [3]: string }[]  file, text, message
  ---@return { remote: string, dev: string, repo: string }
  function F.make(name, base)
    local remote = H.tmpdir() .. "/remotes/" .. name .. ".git"
    local dev = H.tmpdir() .. "/dev/" .. name
    local repo = F.base .. "/" .. name
    vim.fn.mkdir(vim.fs.dirname(remote), "p")
    vim.fn.mkdir(vim.fs.dirname(dev), "p")
    -- --no-local: copied objects, no hardlinks into the template (a repo of a spec may be
    -- damaged on purpose, the next one must not see it).
    F.git(
      vim.fs.dirname(remote),
      "clone",
      "-q",
      "--bare",
      "--no-local",
      template_remote(base),
      remote
    )
    clone_pinned(remote, dev)
    clone_pinned(remote, repo)
    return { remote = remote, dev = dev, repo = repo }
  end

  ---A new commit pushed from the developer clone.
  ---@param c { dev: string }
  ---@param file string
  ---@param text string
  function F.incoming(c, file, text)
    F.commit_file(c.dev, file, text, "incoming " .. file)
    F.git(c.dev, "push", "-q")
  end

  return F
end
