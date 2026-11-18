-- TESTS/cdx/luarc_repos_root_spec.lua -- the LuaLS config that setup-claude-code.* copies to $REPOS_DIR/.luarc.jsonc.
--
-- Without it every Claude Code session with cwd = $REPOS_DIR starts a lua-language-server (plugin lua-lsp) over the
-- whole repos tree: measured 5.4 GB / 456 s on 2026-11-18, against 1.4 GB / 36 s with this file. A hand test of the
-- deploy step (first copy, second run, changed target backed up) passed for both scripts; this spec keeps what a static
-- check can: the file parses, the keys that make the difference stay, and both scripts still ship it.

return function(H)
  local ok, eq = H.ok, H.eq

  local cdx = vim.fs.normalize(vim.fn.stdpath("config")) .. "/docs/NOTES/CDX"
  local src = cdx .. "/luarc.repos-root.jsonc"
  local text = H.read(src)
  ok(text and text ~= "", "the template exists: " .. src)

  -- JSONC -> JSON: whole-line comments only, which is all the template uses (a `//` inside a string, e.g. the
  -- $schema URL, must survive)
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if not line:match("^%s*//") then
      lines[#lines + 1] = line
    end
  end
  local parsed_ok, cfg = pcall(vim.json.decode, table.concat(lines, "\n"))
  ok(parsed_ok, "the template is valid JSONC: " .. tostring(cfg))

  eq(cfg["diagnostics.workspaceDelay"], -1, "no diagnosis of the whole workspace (the 5 GB part)")
  ok(
    type(cfg["workspace.maxPreload"]) == "number" and cfg["workspace.maxPreload"] <= 5000,
    "preload is capped"
  )
  eq(cfg["workspace.useGitIgnore"], true)
  eq(cfg["workspace.checkThirdParty"], false, "no third-party prompt")
  for _, dir in ipairs({
    ".git",
    ".claude",
    ".wt",
    "node_modules",
    "target",
    "ARCHIV_NICHT_BEARBEITEN",
  }) do
    ok(vim.tbl_contains(cfg["workspace.ignoreDir"], dir), "ignores " .. dir)
  end

  -- `.jsonc` on purpose: lsp.nvim's lua_ls root resolver takes `.luarc.json` as a project marker
  local repos = vim.env.REPOS_DIR
  local resolver = repos and H.read(repos .. "/lsp.nvim/lua/lsp/servers/lua_ls/rootresolver.lua")
  if resolver then
    ok(
      resolver:find('".luarc.json"', 1, true),
      "lsp.nvim still marks roots by .luarc.json (the reason for .jsonc)"
    )
    ok(not resolver:find('".luarc.jsonc"', 1, true), "...and not by .luarc.jsonc")
  end

  for script, installer in pairs({
    ["setup-claude-code.ps1"] = "install-repos-luarc.ps1",
    ["setup-claude-code.sh"] = "install-repos-luarc.sh",
  }) do
    local body = H.read(cdx .. "/" .. script) or ""
    ok(body:find(installer, 1, true), script .. " calls " .. installer)
  end

  -- Run each installer against a temp repos dir: first copy, unchanged second run, changed target backed up.
  local runners = {}
  local pwsh = vim.fn.executable("pwsh") == 1 and "pwsh"
    or vim.fn.executable("powershell") == 1 and "powershell"
  if pwsh then
    runners.ps1 = function(dir)
      return {
        pwsh,
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        cdx .. "/install-repos-luarc.ps1",
        "-ReposDir",
        dir,
      }
    end
  end
  if vim.fn.executable("bash") == 1 then
    runners.sh = function(dir)
      return { "bash", cdx .. "/install-repos-luarc.sh", dir }
    end
  end
  ok(next(runners) ~= nil, "at least one shell to run an installer with")

  local function backups(dir)
    return vim.fn.glob(dir .. "/.luarc.jsonc.bak-*", true, true)
  end
  for kind, argv in pairs(runners) do
    local dir = vim.fn.tempname() .. "-luarc-" .. kind
    vim.fn.mkdir(dir, "p")
    local function run()
      local res = vim.system(argv(dir), { text = true }):wait()
      eq(res.code, 0, kind .. " installer exits 0: " .. (res.stdout or "") .. (res.stderr or ""))
      return res.stdout or ""
    end
    local target = dir .. "/.luarc.jsonc"

    ok(run():find("Kopiert", 1, true), kind .. ": first run copies")
    eq(H.read(target), text, kind .. ": target equals the template")

    ok(run():find("Bereits aktuell", 1, true), kind .. ": second run leaves it alone")
    eq(#backups(dir), 0, kind .. ": no backup for an unchanged target")

    vim.fn.writefile({ "{}" }, target)
    ok(run():find("gesichert", 1, true), kind .. ": a changed target is backed up")
    eq(H.read(target), text, kind .. ": ...and replaced by the template")
    local saved = backups(dir)
    eq(#saved, 1, kind .. ": exactly one backup")
    eq(vim.trim(H.read(saved[1]) or ""), "{}", kind .. ": the backup holds the old content")

    vim.fn.delete(dir, "rf")
  end

  -- A missing repos dir is skipped, not created.
  for kind, argv in pairs(runners) do
    local missing = vim.fn.tempname() .. "-missing-" .. kind
    local res = vim.system(argv(missing), { text = true }):wait()
    eq(res.code, 0, kind .. ": missing repos dir is no error")
    eq(vim.fn.isdirectory(missing), 0, kind .. ": missing repos dir is not created")
  end
end
