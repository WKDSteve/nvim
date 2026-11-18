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

  for _, script in ipairs({ "setup-claude-code.ps1", "setup-claude-code.sh" }) do
    local body = H.read(cdx .. "/" .. script) or ""
    ok(body:find("luarc.repos-root.jsonc", 1, true), script .. " ships the template")
    ok(body:find(".luarc.jsonc", 1, true), script .. " writes $REPOS_DIR/.luarc.jsonc")
  end
end
