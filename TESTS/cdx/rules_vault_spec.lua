-- TESTS/cdx/rules_vault_spec.lua -- docs/NOTES/CDX/rules-vault.js, called by both setup-claude-code scripts.
--
-- `ensure` clones rules-vault when it is missing and fast-forwards it when it is clean and on main; anything else
-- only warns. `link` puts the context documents of rulesets/arbeit/kontext into <claude-dir>/rules as
-- rules-vault-<name>.md and removes stale own entries, never a foreign file. Everything runs against a fake vault
-- (a local bare remote via RULES_VAULT_REMOTE) and a fake claude dir; the real ~/.claude is never written.

return function(H)
  local ok, eq = H.ok, H.eq

  -- From this file, not stdpath("config"): in a worktree that is the main checkout.
  local spec = debug.getinfo(1, "S").source:sub(2)
  local root =
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(spec, ":p")))))
  local cdx = root .. "/docs/NOTES/CDX"
  local js = cdx .. "/rules-vault.js"
  ok(H.exists(js), "the helper exists: " .. js)

  for _, script in ipairs({ "setup-claude-code.ps1", "setup-claude-code.sh" }) do
    local body = H.read(cdx .. "/" .. script) or ""
    ok(body:find("rules-vault.js", 1, true), script .. " calls rules-vault.js")
    ok(
      body:find("ensure", 1, true) and body:find("link", 1, true),
      script .. " runs ensure and link"
    )
  end

  if vim.fn.executable("node") ~= 1 or vim.fn.executable("git") ~= 1 then
    print("  skip: node or git missing")
    return
  end

  local base = vim.fs.normalize(H.tmpdir())
  -- Isolated git: no global hooks, no signing, a fixed identity.
  local gitcfg = base .. "/gitconfig"
  H.write(gitcfg, "")
  local env = {
    GIT_CONFIG_GLOBAL = gitcfg,
    GIT_CONFIG_NOSYSTEM = "1",
    GIT_AUTHOR_NAME = "t",
    GIT_AUTHOR_EMAIL = "t@example.invalid",
    GIT_COMMITTER_NAME = "t",
    GIT_COMMITTER_EMAIL = "t@example.invalid",
    RULES_VAULT_REMOTE = base .. "/remote.git",
    RULES_VAULT_NO_SYMLINK = "",
  }

  local function sh(argv, cwd, extra)
    local e = vim.tbl_extend("force", env, extra or {})
    local res = vim.system(argv, { cwd = cwd, env = e, text = true }):wait()
    return res.code, (res.stdout or "") .. (res.stderr or "")
  end
  local function git(cwd, ...)
    local code, out = sh({ "git", ... }, cwd)
    eq(code, 0, "git " .. table.concat({ ... }, " ") .. ": " .. out)
    return out
  end
  local function node(extra, ...)
    local code, out = sh({ "node", js, ... }, nil, extra)
    eq(code, 0, "rules-vault.js " .. table.concat({ ... }, " ") .. " exits 0: " .. out)
    return out
  end

  -- Seed repo -> bare remote.
  local seed = base .. "/seed"
  vim.fn.mkdir(seed, "p")
  git(seed, "init", "-q", "-b", "main")
  H.write(seed .. "/rulesets/arbeit/kontext/a.md", "A\n")
  H.write(seed .. "/rulesets/arbeit/kontext/b.md", "B\n")
  H.write(seed .. "/rulesets/arbeit/kontext/notes.txt", "not markdown\n")
  H.write(seed .. "/rulesets/arbeit/kontext/workstation/falcon.md", "F\n")
  git(seed, "add", ".")
  git(seed, "commit", "-q", "-m", "seed")
  git(base, "clone", "-q", "--bare", seed, base .. "/remote.git")
  git(seed, "remote", "add", "origin", base .. "/remote.git")
  local function publish(file, text)
    H.write(seed .. "/" .. file, text)
    git(seed, "add", ".")
    git(seed, "commit", "-q", "-m", file)
    git(seed, "push", "-q", "origin", "main")
  end

  -- ensure: clone, then fast-forward.
  local vault = base .. "/repos/rules-vault"
  vim.fn.mkdir(base .. "/repos", "p")
  ok(node(nil, "ensure", vault):find("geklont", 1, true), "a missing vault is cloned")
  eq(H.read(vault .. "/rulesets/arbeit/kontext/a.md"), "A\n", "the clone has the files")

  publish("rulesets/arbeit/kontext/c.md", "C\n")
  ok(node(nil, "ensure", vault):find("aktuell", 1, true), "a clean vault on main is pulled")
  ok(H.exists(vault .. "/rulesets/arbeit/kontext/c.md"), "the pull brought the new file")

  -- ensure: foreign changes, another branch, a failing pull -> warning, nothing touched.
  publish("rulesets/arbeit/kontext/d.md", "D\n")
  H.write(vault .. "/foreign.txt", "work in progress\n")
  ok(node(nil, "ensure", vault):find("WARNUNG", 1, true), "a dirty vault only warns")
  ok(not H.exists(vault .. "/rulesets/arbeit/kontext/d.md"), "...and is not pulled")
  eq(H.read(vault .. "/foreign.txt"), "work in progress\n", "...and the foreign file stays")
  vim.fn.delete(vault .. "/foreign.txt")

  git(vault, "checkout", "-q", "-b", "feature")
  ok(node(nil, "ensure", vault):find("nicht auf main", 1, true), "another branch only warns")
  ok(not H.exists(vault .. "/rulesets/arbeit/kontext/d.md"), "...and is not pulled")
  git(vault, "checkout", "-q", "main")

  H.write(vault .. "/local.md", "local\n")
  git(vault, "add", "local.md")
  git(vault, "commit", "-q", "-m", "diverge")
  local before = vim.trim(git(vault, "rev-parse", "HEAD"))
  ok(
    node(nil, "ensure", vault):find("pull --ff-only schlug fehl", 1, true),
    "a diverged vault warns"
  )
  eq(vim.trim(git(vault, "rev-parse", "HEAD")), before, "...and keeps its HEAD")
  git(vault, "reset", "-q", "--hard", "origin/main")
  ok(node(nil, "ensure", vault):find("aktuell", 1, true), "back on track it pulls again")
  ok(H.exists(vault .. "/rulesets/arbeit/kontext/d.md"), "...and has d.md")

  local orphan_parent = base .. "/nowhere/repos/rules-vault"
  ok(
    node(nil, "ensure", orphan_parent):find("WARNUNG", 1, true),
    "a missing parent folder only warns"
  )
  eq(vim.fn.isdirectory(base .. "/nowhere"), 0, "...and is not created")

  -- link: symlinks (or copies where the system refuses symlinks), foreign files untouched.
  local claude = base .. "/home/.claude"
  local rules = claude .. "/rules"
  H.write(rules .. "/mine.md", "foreign\n")
  H.write(rules .. "/rules-vaultish.md", "foreign too\n")
  local kontext = vault .. "/rulesets/arbeit/kontext"
  local function entries()
    local names = {}
    for name in vim.fs.dir(rules) do
      names[#names + 1] = name
    end
    table.sort(names)
    return names
  end
  local function foreign_intact()
    eq(H.read(rules .. "/mine.md"), "foreign\n", "foreign mine.md untouched")
    eq(
      H.read(rules .. "/rules-vaultish.md"),
      "foreign too\n",
      "foreign rules-vaultish.md untouched"
    )
  end

  node(nil, "link", vault, claude)
  eq(entries(), {
    "mine.md",
    "rules-vault-a.md",
    "rules-vault-b.md",
    "rules-vault-c.md",
    "rules-vault-d.md",
    "rules-vaultish.md",
  }, "one entry per kontext/*.md, no workstation file off the workstation")
  eq(H.read(rules .. "/rules-vault-a.md"), "A\n", "the entry shows the source")
  local linked = (vim.uv.fs_lstat(rules .. "/rules-vault-a.md") or {}).type == "link"
  if linked then
    H.write(kontext .. "/a.md", "A2\n")
    eq(H.read(rules .. "/rules-vault-a.md"), "A2\n", "a symlink follows the source")
  else
    print("  note: no symlink right here, the copy fallback was taken")
  end
  foreign_intact()
  ok(
    node(nil, "link", vault, claude):find("0 verlinkt", 1, true) or not linked,
    "a second run changes nothing"
  )

  node(nil, "link", vault, claude, "--workstation")
  eq(
    H.read(rules .. "/rules-vault-workstation-falcon.md"),
    "F\n",
    "the workstation adds kontext/workstation"
  )

  H.write(rules .. "/rules-vault-old.md", "stale\n")
  local out = node(nil, "link", vault, claude)
  ok(
    out:find("rules-vault-workstation-falcon.md", 1, true),
    "the stale workstation entry is reported"
  )
  ok(
    not H.exists(rules .. "/rules-vault-workstation-falcon.md"),
    "...and removed off the workstation"
  )
  ok(not H.exists(rules .. "/rules-vault-old.md"), "a stale own entry is removed")
  foreign_intact()

  -- Copy fallback: regular files, refreshed when the source changes. A correct symlink would stay as it is, so the
  -- own entries go first (as on a machine that never had the symlink right).
  for _, name in ipairs(entries()) do
    if vim.startswith(name, "rules-vault-") then
      vim.fn.delete(rules .. "/" .. name)
    end
  end
  node({ RULES_VAULT_NO_SYMLINK = "1" }, "link", vault, claude)
  eq(
    (vim.uv.fs_lstat(rules .. "/rules-vault-b.md") or {}).type,
    "file",
    "the fallback writes a copy"
  )
  H.write(kontext .. "/b.md", "B2\n")
  node({ RULES_VAULT_NO_SYMLINK = "1" }, "link", vault, claude)
  eq(H.read(rules .. "/rules-vault-b.md"), "B2\n", "a changed source refreshes the copy")
  foreign_intact()

  -- No kontext folder / no vault: a hint, exit 0, own entries gone, foreign files stay.
  local bare_vault = base .. "/empty-vault"
  vim.fn.mkdir(bare_vault, "p")
  ok(
    node(nil, "link", bare_vault, claude):find("Hinweis", 1, true),
    "a vault without kontext/ is a hint"
  )
  ok(node(nil, "link", "-", claude):find("Hinweis", 1, true), "no vault is a hint")
  eq(entries(), { "mine.md", "rules-vaultish.md" }, "only the foreign files are left")

  -- A claude dir without rules/ and nothing to link is not touched.
  local fresh = base .. "/fresh/.claude"
  node(nil, "link", "-", fresh)
  eq(vim.fn.isdirectory(fresh), 0, "nothing to link creates no folder")

  local code = sh({ "node", js, "link" })
  eq(code, 2, "bad usage exits 2")
end
