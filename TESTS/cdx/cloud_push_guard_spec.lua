-- TESTS/cdx/cloud_push_guard_spec.lua -- the cloud push guard (rule GIT-09) and its installer. The hook itself goes
-- into public repositories, so it must not name a rule by its id (appkit's tools/check-rule-ids.py fails on that).
--
-- docs/NOTES/CDX/install-cloud-push-guard.js puts docs/NOTES/CDX/hooks/cloud-push-guard.mjs into a repository's
-- .claude/hooks/ and its PreToolUse entry into .claude/settings.json, and lets both through a .gitignore that hides
-- .claude/. In a cloud session (CLAUDE_CODE_REMOTE set) the hook refuses every `git push` that would move main, with
-- exit 2; locally the settings command does not even start node.

return function(H)
  local ok, eq, has = H.ok, H.eq, H.has

  if vim.fn.executable("node") ~= 1 or vim.fn.executable("git") ~= 1 then
    print("n/a  node or git missing")
    return
  end

  local spec = debug.getinfo(1, "S").source:sub(2)
  local root =
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(spec, ":p")))))
  local installer = root .. "/docs/NOTES/CDX/install-cloud-push-guard.js"

  local function git(dir, args)
    local cmd =
      { "git", "-C", dir, "-c", "user.name=fixture", "-c", "user.email=fixture@example.invalid" }
    vim.list_extend(cmd, args)
    local r = vim.system(cmd, { text = true }):wait()
    assert(r.code == 0, table.concat(args, " ") .. ": " .. (r.stderr or ""))
    return r.stdout
  end

  ---A fresh repository whose HEAD is `branch` (no commit needed for `symbolic-ref`).
  local function repo(branch, name)
    local dir = H.tmpdir() .. "/" .. (name or "repo")
    vim.fn.mkdir(dir, "p")
    git(dir, { "init", "-q", "-b", branch })
    return dir
  end

  ---Commit everything in the fixture, so that only later changes count as uncommitted.
  local function commit_all(dir)
    git(dir, { "add", "-A" })
    git(dir, { "commit", "-q", "-m", "fixture" })
  end

  local function ignored(dir, rel)
    return vim.system({ "git", "-C", dir, "check-ignore", "-q", rel }):wait().code == 0
  end

  -- installer: merges into a committed settings.json, keeps its keys, lets .claude/ through .gitignore, idempotent
  local main_repo = repo("main")
  H.write(
    main_repo .. "/.claude/settings.json",
    '{\n  "env": {\n    "DISABLE_TELEMETRY": "1"\n  }\n}\n'
  )
  H.write(main_repo .. "/.gitignore", "node_modules/\n/.claude/\n*.log\n")
  git(main_repo, { "add", "-f", ".claude/settings.json", ".gitignore" })
  git(main_repo, { "commit", "-q", "-m", "fixture" })
  local check = vim.system({ "node", installer, "--check", main_repo }, { text = true }):wait()
  eq(check.code, 1, "--check before the install: missing")
  has(check.stdout, "missing", "--check names the missing guard")
  local first = vim.system({ "node", installer, main_repo }, { text = true }):wait()
  eq(first.code, 0, "install: " .. (first.stderr or ""))
  has(first.stdout, "installed", "first run installs")
  local hook = main_repo .. "/.claude/hooks/cloud-push-guard.mjs"
  ok(H.exists(hook), "the hook script was copied")
  local settings = vim.json.decode(H.read(main_repo .. "/.claude/settings.json"))
  eq(settings.env.DISABLE_TELEMETRY, "1", "the other keys stay")
  eq(#settings.hooks.PreToolUse, 1, "one PreToolUse entry")
  eq(settings.hooks.PreToolUse[1].matcher, "Bash", "matcher Bash")
  local command = settings.hooks.PreToolUse[1].hooks[1].command
  has(command, "CLAUDE_CODE_REMOTE", "the command tests CLAUDE_CODE_REMOTE first")
  ok(not ignored(main_repo, ".claude/settings.json"), "settings.json is no longer ignored")
  ok(not ignored(main_repo, ".claude/hooks/cloud-push-guard.mjs"), "the hook is not ignored")
  ok(ignored(main_repo, ".claude/worktrees/x/file"), "the rest of .claude/ stays ignored")
  has(H.read(main_repo .. "/.gitignore"), "*.log", "the other .gitignore lines stay")
  commit_all(main_repo)
  local again = vim.system({ "node", installer, main_repo }, { text = true }):wait()
  has(again.stdout, "unchanged", "second run changes nothing")
  eq(
    #vim.json.decode(H.read(main_repo .. "/.claude/settings.json")).hooks.PreToolUse,
    1,
    "still one entry"
  )
  eq(
    vim.system({ "node", installer, "--check", main_repo }, { text = true }):wait().code,
    0,
    "--check after"
  )
  H.write(hook, "// old copy\n")
  local stale = vim.system({ "node", installer, "--check", main_repo }, { text = true }):wait()
  eq(stale.code, 1, "--check finds an old copy")
  has(stale.stdout, "outdated", "named outdated")
  has(
    vim.system({ "node", installer, main_repo }, { text = true }):wait().stdout,
    "updated",
    "an old copy is updated"
  )

  -- the vaults are refused
  local vault = repo("main", "tasks-vault")
  local refused = vim.system({ "node", installer, vault }, { text = true }):wait()
  has(refused.stdout, "refused", "a vault is refused")
  ok(not H.exists(vault .. "/.claude/settings.json"), "nothing written into the vault")

  -- someone else's uncommitted edit in settings.json: held, nothing written
  local busy = repo("main", "busy")
  H.write(busy .. "/.claude/settings.json", "{}\n")
  commit_all(busy)
  H.write(busy .. "/.claude/settings.json", '{ "env": {} }\n')
  local held = vim.system({ "node", installer, busy }, { text = true }):wait()
  eq(held.code, 1, "held: exit 1")
  has(held.stdout, "held", "named held")
  ok(not H.exists(busy .. "/.claude/hooks/cloud-push-guard.mjs"), "nothing written while held")

  -- a .gitignore rule the installer does not know: an error, not a guess
  local odd = repo("main", "odd")
  H.write(odd .. "/.gitignore", "*.json\n")
  commit_all(odd)
  local err = vim.system({ "node", installer, odd }, { text = true }):wait()
  has(err.stdout, "error", "an unknown rule is an error")
  has(err.stdout, "*.json", "it names the rule")

  -- a repository's own JSON format stays; `.claude/*` keeps its line and gets only the missing exception
  local styled = repo("main", "styled")
  local styled_json = '{\n  "env": { "X": "1" },\n  "permissions": {\n    "allow": ["a"]\n  }\n}\n'
  H.write(styled .. "/.claude/settings.json", styled_json)
  H.write(styled .. "/.gitignore", "dist/\n.claude/*\n!.claude/settings.json\n")
  commit_all(styled)
  has(
    vim.system({ "node", installer, styled }, { text = true }):wait().stdout,
    "installed",
    "styled: installed"
  )
  local styled_text = H.read(styled .. "/.claude/settings.json")
  eq(
    styled_text:sub(1, #styled_json - 3),
    styled_json:sub(1, #styled_json - 3),
    "every old byte stays"
  )
  has(styled_text, '"allow": ["a"]', "the one-line array stays one line")
  eq(
    vim.json.decode(styled_text).hooks.PreToolUse[1].matcher,
    "Bash",
    "the hook block is valid JSON"
  )
  local styled_ignore = H.read(styled .. "/.gitignore")
  eq(select(2, styled_ignore:gsub("settings%.json", "")), 1, "no second settings.json exception")
  has(styled_ignore, "\n.claude/*\n", "the .claude/* line stays")
  has(styled_ignore, "\n!.claude/settings.json\n", "the old exception stays")
  has(styled_ignore, "!/.claude/hooks/", "the hooks exception is added")
  ok(not ignored(styled, ".claude/hooks/cloud-push-guard.mjs"), "styled: the hook is not ignored")

  -- a new project gets the guard from new-project-claude.js
  local fresh = repo("main", "fresh")
  local np = vim
    .system({ "node", root .. "/docs/NOTES/CDX/new-project-claude.js", "rust", fresh }, { text = true })
    :wait()
  eq(np.code, 0, "new-project-claude: " .. (np.stderr or ""))
  ok(H.exists(fresh .. "/.claude/hooks/cloud-push-guard.mjs"), "the new project has the hook")

  -- the hook itself, as a cloud session runs it
  vim.fn.mkdir(main_repo .. "/sub", "p")
  local branch_repo = repo("claude/x", "branch")
  local function run(cmd, cwd, env, tool)
    local input =
      vim.json.encode({ tool_name = tool or "Bash", tool_input = { command = cmd }, cwd = cwd })
    return vim.system({ "node", hook }, { text = true, stdin = input, env = env }):wait()
  end
  local cloud = { CLAUDE_CODE_REMOTE = "true" }
  local cases = {
    -- { command, refused?, repository }
    { "git push origin HEAD:main", true },
    { "git push", true },
    { "git push origin HEAD", true },
    { "git push --force origin main", true },
    { "git push origin +main", true },
    { "git push origin refs/heads/main", true },
    { "git push origin claude/x:main", true },
    { "git push origin --delete main", true },
    { "git push origin :main", true },
    { "git push --all origin", true },
    { "git push origin 'refs/heads/*:refs/heads/*'", true },
    { "git pull --rebase && git push origin HEAD:main 2>&1 | tail -1", true },
    { "cd sub && git -C . push origin main", true },
    { 'bash -c "git push origin main"', true },
    { 'echo "$(git push origin main)"', true },
    { "timeout 60 git push origin main", true },
    { "git push origin 2>/dev/null", true },
    { "git push origin >/dev/null 2>&1", true },
    { "GIT_TRACE=1 git -c core.x=y push -u origin main", true },
    { "git push origin claude/x", false },
    { "git push -u origin HEAD:claude/x", false },
    { "git push --dry-run origin main", false },
    { "git push -n origin HEAD:main", false },
    { 'git commit -m "never git push origin main"', false },
    { "git status && git log -1", false },
    { "git push origin main:claude/x", false },
    { "git push --force-with-lease=main origin claude/x", false },
    { "echo git push origin main", false },
    { "git push origin refs/tags/main", false },
    { "git push", false, branch_repo },
    { "git push origin HEAD", false, branch_repo },
    { "git push origin HEAD:main", true, branch_repo },
  }
  local id = H.read(hook):match("%f[%w](%u+%-%d%d)%f[%W]")
  ok(id == nil, "the hook names no rule by its id: " .. tostring(id))
  for _, c in ipairs(cases) do
    local r = run(c[1], c[3] or main_repo, cloud)
    local where = c[3] and " (on claude/x)" or " (on main)"
    if c[2] then
      eq(r.code, 2, "refused: " .. c[1] .. where .. " " .. (r.stderr or ""))
      has(r.stderr, "Push your own branch instead", "the refusal says what to do: " .. c[1])
    else
      eq(r.code, 0, "allowed: " .. c[1] .. where .. " " .. (r.stderr or ""))
    end
  end
  eq(
    run("git push origin HEAD:main", main_repo, { CLAUDE_CODE_REMOTE = "" }).code,
    0,
    "local: no effect"
  )
  eq(run("git push origin HEAD:main", main_repo, cloud, "Write").code, 0, "another tool: no effect")

  -- the settings command through a POSIX shell: locally node is not even started
  local bash = vim.fn.has("win32") == 1 and "C:/Program Files/Git/bin/bash.exe"
    or vim.fn.exepath("bash")
  if bash == "" or vim.fn.executable(bash) ~= 1 then
    print("n/a  no POSIX bash for the settings command")
    return
  end
  local input =
    vim.json.encode({ tool_name = "Bash", tool_input = { command = "git push origin HEAD:main" } })
  local function shell(env)
    return vim
      .system({ bash, "-c", command }, { text = true, stdin = input, cwd = main_repo, env = env })
      :wait()
  end
  local missing = H.tmpdir() .. "/no-such-project"
  eq(
    shell({ CLAUDE_CODE_REMOTE = "", CLAUDE_PROJECT_DIR = missing }).code,
    0,
    "local: node is not started"
  )
  local remote = shell({ CLAUDE_CODE_REMOTE = "true", CLAUDE_PROJECT_DIR = main_repo })
  eq(remote.code, 2, "cloud: the settings command refuses " .. (remote.stderr or ""))
end
