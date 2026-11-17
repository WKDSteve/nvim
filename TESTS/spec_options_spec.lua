-- TESTS/spec_options_spec.lua -- drift guard for the install specs of the own plugins: every option of a plugin's
-- `config/DEFAULTS.lua` has to be named in its spec in `lua/plugins/personal/specs/<category>.lua` (set, or commented
-- with its default; the convention is tasks-vault TOOLS/spec-full-options.md). The check itself is the vault's
-- `TOOLS/scripts/spec-options/audit.py --check`, run against this checkout and the plugin checkouts below $REPOS_DIR.
--
-- A gap FAILS this spec (decided 2026-11-17): the fix is a comment line in this repository, and the failure names
-- the missing paths. It says n/a and passes where it cannot judge: no $REPOS_DIR, no vault script or no python
-- (CI), and on the workstation, whose plugins come from lazy and whose $REPOS_DIR checkouts may be old.

return function(H)
  local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h"):gsub("\\", "/")
  local repos = vim.env.REPOS_DIR
  -- $SPEC_OPTIONS_AUDIT names another audit.py (a vault worktree), e.g. to try a change of the tool.
  local script = vim.env.SPEC_OPTIONS_AUDIT ---@type string|nil
  if (not script or script == "") and repos and repos ~= "" then
    script = repos .. "/tasks-vault/TOOLS/scripts/spec-options/audit.py"
  end
  local python = vim.fn.exepath("python3")
  if python == "" then
    python = vim.fn.exepath("python")
  end
  local role_ok, machine = pcall(require, "machine")
  if role_ok and machine.is("workstation") then
    print("n/a  workstation: the plugin checkouts below $REPOS_DIR are not what lazy loads")
    return
  end
  if not script or vim.fn.filereadable(script) ~= 1 or python == "" or not repos or repos == "" then
    print("n/a  no $REPOS_DIR/tasks-vault audit.py or no python: the spec-options audit cannot run")
    return
  end

  local lib = vim.env.LIB_NVIM_DIR or (repos .. "/lib.nvim")
  local argv = { python, script, root, repos, "--lib", lib, "--check" }
  local res = vim.system(argv, { text = true }):wait(120000)
  local out = (res.stdout or "") .. (res.stderr or "")
  H.ok(res.code ~= 124 and res.signal == 0, "audit.py finished within 2 minutes\n" .. out)
  -- Only the per-plugin sections ("### <name>" then "Spec: ..."), the table is noise when it fails.
  local gaps = {}
  local current
  for line in out:gmatch("[^\r\n]+") do
    current = line:match("^### (.+)$") or current
    local spec = line:match("^Spec: (.+)$")
    if spec then
      gaps[#gaps + 1] = ("%s: %s"):format(current or "?", spec)
    end
  end
  H.eq(
    res.code,
    0,
    "every DEFAULTS option is named in its install spec (missing, add them per TOOLS/spec-full-options.md):\n  "
      .. (#gaps > 0 and table.concat(gaps, "\n  ") or out)
  )
end
