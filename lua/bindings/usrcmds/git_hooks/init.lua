---@module 'bindings.usrcmds.git_hooks'
---@brief `:MyGit hooks` - install the git hooks of `scripts/git-hooks/` into the repos under `$REPOS_DIR`.
---@description
--- Front end for `scripts/git-hooks/install.sh` (the single source of truth for what a hook looks like):
---
---  - `:MyGit hooks`              pick the repos in a themed list (<Tab> marks, <CR> installs; no mark = the row
---                                under the cursor). Each row shows the state of that repo's hooks.
---  - `:MyGit hooks all`          every repo under `$REPOS_DIR` that has a `.git`
---  - `:MyGit hooks status`       the state of every repo, nothing is changed
---  - `:MyGit hooks repo <name>`  one repo
---
--- What a repo gets: `pre-commit` (large files) and `commit-msg` (no Claude trailer) everywhere, plus the
--- manual-push `pre-push` in the repos of `M.MANUAL_PUSH` (WKDBook-Tricentis, tricentis-vault: customer data,
--- pushed by hand only). A hook of someone else is never overwritten: `install.sh` reports it and this command
--- shows it as `foreign`.
---
--- Allowed on the workstation: the hooks are plain shell scripts, nothing is built or started.

local notify = require("lib.nvim.notify").create("[usrcmds.git_hooks]")
local composer = require("lib.nvim.bindings.usercmd.composer")
local ops = require("bindings.usrcmds.plugin_repos.ops")

local M = {}

local uv = vim.uv or vim.loop

---Repos that are pushed by hand only (keep in step with `docs/installation.md` and `setup-claude-code.ps1`).
---@type string[]
M.MANUAL_PUSH = { "WKDBook-Tricentis", "tricentis-vault" }

---The hooks `install.sh` writes and the marker line it puts in each.
---@type { name: string, marker: string, manual_only?: boolean }[]
M.HOOKS = {
  { name = "pre-commit", marker = "# large-files-hook" },
  { name = "commit-msg", marker = "# no-claude-trailer-hook" },
  { name = "pre-push", marker = "# manual-push-hook", manual_only = true },
}

---@param name string
---@return boolean
function M.is_manual_push(name)
  return vim.tbl_contains(M.MANUAL_PUSH, name)
end

---Which hooks a repo is supposed to have.
---@param name string  repo folder name
---@return { name: string, marker: string }[]
function M.expected(name)
  local list = {}
  for _, hook in ipairs(M.HOOKS) do
    if not hook.manual_only or M.is_manual_push(name) then
      list[#list + 1] = hook
    end
  end
  return list
end

---State of one hook file.
---@param content string|nil  file content, nil when there is no file
---@param marker string
---@return "ok"|"foreign"|"missing"
function M.classify(content, marker)
  if content == nil then
    return "missing"
  end
  return content:find(marker, 1, true) and "ok" or "foreign"
end

---State of one repo from the content of its hook files.
---@param name string  repo folder name
---@param read fun(hook: string): string|nil  content of `<hooks dir>/<hook>`
---@return "ok"|"partial"|"missing"|"foreign" summary
---@return table<string, string> per_hook
function M.repo_state(name, read)
  local per_hook, ok_count, foreign, total = {}, 0, false, 0
  for _, hook in ipairs(M.expected(name)) do
    local state = M.classify(read(hook.name), hook.marker)
    per_hook[hook.name] = state
    total = total + 1
    if state == "ok" then
      ok_count = ok_count + 1
    elseif state == "foreign" then
      foreign = true
    end
  end
  if foreign then
    return "foreign", per_hook
  end
  if ok_count == total then
    return "ok", per_hook
  end
  return (ok_count == 0 and "missing" or "partial"), per_hook
end

---`<git-common-dir>/hooks` of a repo, the same folder `install.sh` writes to. Not `--git-path hooks`: that follows
---a global `core.hooksPath`, whose scripts only hand over to this folder. Asks git for worktrees and submodules
---(`.git` is a file there).
---@param path string
---@return string|nil
local function hooks_dir(path)
  local stat = uv.fs_stat(path .. "/.git")
  if stat and stat.type == "directory" then
    return path .. "/.git/hooks"
  end
  local res = vim.system({ "git", "-C", path, "rev-parse", "--git-common-dir" }, { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  local dir = vim.trim(res.stdout or "")
  if dir == "" then
    return nil
  end
  if not (dir:match("^/") or dir:match("^%a:")) then
    dir = path .. "/" .. dir
  end
  return dir .. "/hooks"
end

---@param file string
---@return string|nil
local function read_file(file)
  local fh = io.open(file, "rb")
  if not fh then
    return nil
  end
  local text = fh:read("*a")
  fh:close()
  return text
end

---@return string|nil
local function base_dir()
  local base = ops.resolve_base_dir(nil)
  if not base then
    notify.error("REPOS_DIR is not set")
    return nil
  end
  return (base:gsub("[/\\]+$", ""))
end

---Folder names under `base` that hold a git repository, sorted.
---@param base string
---@return string[]
function M.repos(base)
  local names = {}
  local handle = uv.fs_scandir(base)
  while handle do
    local name, kind = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if (kind == "directory" or kind == "link") and uv.fs_stat(base .. "/" .. name .. "/.git") then
      names[#names + 1] = name
    end
  end
  table.sort(names, function(a, b)
    return a:lower() < b:lower()
  end)
  return names
end

---@param base string
---@param name string
---@return string summary, table<string, string> per_hook
local function state_of(base, name)
  local dir = hooks_dir(base .. "/" .. name)
  if not dir then
    return "missing", {}
  end
  return M.repo_state(name, function(hook)
    return read_file(dir .. "/" .. hook)
  end)
end

---@param name string
---@param state string
---@param per_hook table<string, string>
---@return string
local function format_row(name, state, per_hook)
  local detail = {}
  for _, hook in ipairs(M.expected(name)) do
    if per_hook[hook.name] and per_hook[hook.name] ~= "ok" then
      detail[#detail + 1] = hook.name .. ": " .. per_hook[hook.name]
    end
  end
  local tail = #detail > 0 and ("  (" .. table.concat(detail, ", ") .. ")") or ""
  return ("[%-8s] %s%s"):format(state, name, tail)
end

---Shows the state of every repo (or of `only`). Changes nothing.
---@param only? string[]
function M.status(only)
  local base = base_dir()
  if not base then
    return
  end
  local lines, attention = {}, false
  for _, name in ipairs(only or M.repos(base)) do
    local state, per_hook = state_of(base, name)
    lines[#lines + 1] = format_row(name, state, per_hook)
    attention = attention or state ~= "ok"
  end
  if #lines == 0 then
    notify.info("No git repository under " .. base)
    return
  end
  local text = table.concat(lines, "\n")
  if attention then
    notify.warn(text)
  else
    notify.info(text)
  end
end

---Path of `install.sh` of this config.
---@return string
function M.install_script()
  return (vim.fn.stdpath("config") .. "/scripts/git-hooks/install.sh"):gsub("\\", "/")
end

---argv of the `install.sh` calls for `names`: one for pre-commit/commit-msg, one more for the manual-push repos.
---@param bash string
---@param script string
---@param base string
---@param names string[]
---@return string[][] calls
function M.plan_calls(bash, script, base, names)
  local all, manual = {}, {}
  for _, name in ipairs(names) do
    all[#all + 1] = base .. "/" .. name
    if M.is_manual_push(name) then
      manual[#manual + 1] = base .. "/" .. name
    end
  end
  local calls = {}
  if #all > 0 then
    calls[#calls + 1] = vim.list_extend({ bash, script }, all)
  end
  if #manual > 0 then
    calls[#calls + 1] = vim.list_extend({ bash, script, "--manual-push-only" }, manual)
  end
  return calls
end

local running = false

---Installs the hooks into the named repos (one `install.sh` run after the other).
---@param names string[]
---@param on_done? fun(installed: integer, problems: string[])
function M.install(names, on_done)
  if #names == 0 then
    notify.info("No repository chosen")
    return
  end
  if running then
    notify.warn("A hook install is already running")
    return
  end
  local base = base_dir()
  if not base then
    return
  end
  local bash, reason = require("lib.nvim.cross.bash").find()
  if not bash then
    notify.error("Git hooks need bash (Git for Windows): " .. tostring(reason))
    return
  end
  local calls = M.plan_calls(bash, M.install_script(), base, names)
  local installed, problems, index = 0, {}, 0
  running = true

  local function finish()
    running = false
    local head = ("Git hooks: %d installed, %d repo(s) asked"):format(installed, #names)
    if #problems > 0 then
      notify.warn(head .. "\n" .. table.concat(problems, "\n"))
    else
      notify.info(head)
    end
    if on_done then
      on_done(installed, problems)
    end
  end

  local function next_call()
    index = index + 1
    local argv = calls[index]
    if not argv then
      finish()
      return
    end
    local started, err = pcall(vim.system, argv, { text = true }, function(res)
      vim.schedule(function()
        for _, line in ipairs(vim.split((res.stdout or ""), "\r?\n", { trimempty = true })) do
          if line:match("^installed:") then
            installed = installed + 1
          end
        end
        for _, line in ipairs(vim.split((res.stderr or ""), "\r?\n", { trimempty = true })) do
          problems[#problems + 1] = line
        end
        if res.code ~= 0 and #problems == 0 then
          problems[#problems + 1] = "install.sh exited with " .. tostring(res.code)
        end
        next_call()
      end)
    end)
    if not started then
      problems[#problems + 1] = "cannot start bash: " .. tostring(err)
      next_call()
    end
  end
  next_call()
end

---Themed multi-select: <Tab> marks, <CR> installs (no mark = the row under the cursor).
function M.pick()
  local base = base_dir()
  if not base then
    return
  end
  local names = M.repos(base)
  if #names == 0 then
    notify.info("No git repository under " .. base)
    return
  end
  local rows = {}
  for _, name in ipairs(names) do
    local state, per_hook = state_of(base, name)
    rows[name] = format_row(name, state, per_hook)
  end
  local ok, kit = pcall(require, "lib.nvim.ui.kit")
  if not ok then
    notify.error("lib.nvim.ui.kit is not available")
    return
  end
  kit.select({
    items = names,
    multi = true,
    title = "MyGit hooks  <Tab> mark  <CR> install",
    format_item = function(name)
      return rows[name]
    end,
    on_select = function(picked)
      M.install(picked)
    end,
  })
end

---@return table[]
function M.routes()
  return {
    {
      path = { "hooks" },
      desc = "Pick the repos under $REPOS_DIR that get the git hooks (pre-commit, commit-msg, manual-push pre-push)",
      run = function()
        M.pick()
      end,
    },
    {
      path = { "hooks", "all" },
      desc = "Install the git hooks into every repo under $REPOS_DIR",
      run = function()
        local base = base_dir()
        if base then
          M.install(M.repos(base))
        end
      end,
    },
    {
      path = { "hooks", "status" },
      desc = "Show the state of the git hooks of every repo under $REPOS_DIR (changes nothing)",
      run = function()
        M.status()
      end,
    },
    {
      path = { "hooks", "repo" },
      args = { { name = "name", type = "MYGIT_REPO" } },
      desc = "Install the git hooks into one repo under $REPOS_DIR",
      run = function(ctx)
        M.install({ ctx.args.name })
      end,
    },
  }
end

---Registers `:MyGit`.
function M.enable()
  composer.register_type("MYGIT_REPO", {
    desc = "Name of a git repository under $REPOS_DIR",
    validate = function(raw)
      local base = ops.resolve_base_dir(nil)
      if base and uv.fs_stat(base .. "/" .. raw .. "/.git") then
        return true, raw, nil
      end
      return false, nil, ("'%s' is not a git repository under $REPOS_DIR"):format(raw)
    end,
    complete = function(arg_lead)
      local base = ops.resolve_base_dir(nil)
      if not base then
        return {}
      end
      return vim.tbl_filter(function(name)
        return arg_lead == "" or name:sub(1, #arg_lead) == arg_lead
      end, M.repos((base:gsub("[/\\]+$", ""))))
    end,
  })
  composer.verb("MyGit", {
    desc = "Git helpers of this config (hooks: install the shared git hooks into the repos under $REPOS_DIR)",
    routes = M.routes(),
  })
end

return M
