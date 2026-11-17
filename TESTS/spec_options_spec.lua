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
  -- The first interpreter that answers: on Windows `python3` (and `python`) can be the Microsoft Store stub, which
  -- is on PATH but runs nothing.
  local python = ""
  for _, name in ipairs({ "python3", "python" }) do
    local exe = vim.fn.exepath(name)
    if python == "" and exe ~= "" then
      local probe = vim.system({ exe, "--version" }, { text = true }):wait(10000)
      if
        probe.code == 0 and ((probe.stdout or "") .. (probe.stderr or "")):find("Python 3", 1, true)
      then
        python = exe
      end
    end
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
  -- The audit stops its own children (30 s each, process tree included) and starts none after its
  -- --deadline; waiting 20 s longer than that never leaves a child behind, and both stay under the
  -- 120 s file limit of .testing.lua.
  local argv = { python, script, root, repos, "--lib", lib, "--check", "--deadline", "90" }
  local res = vim.system(argv, { text = true }):wait(110000)
  local out = (res.stdout or "") .. (res.stderr or "")
  H.ok(res.code ~= 124 and res.signal == 0, "audit.py finished within 110 s\n" .. out)
  -- Only the per-plugin sections ("### <name>" then "Spec: ..." or "Fehler: ..."), the table is noise.
  local gaps = {}
  local current
  for line in out:gmatch("[^\r\n]+") do
    current = line:match("^### (.+)$") or current
    local spec = line:match("^Spec: (.+)$")
    local failed = line:match("^Fehler: (.+)$")
    if spec then
      gaps[#gaps + 1] = ("%s: %s"):format(current or "?", spec)
    elseif failed then
      gaps[#gaps + 1] = ("%s: DEFAULTS not readable (%s)"):format(current or "?", failed)
    end
  end
  H.eq(
    res.code,
    0,
    "every DEFAULTS option is named in its install spec and every DEFAULTS loads"
      .. " (add missing ones per TOOLS/spec-full-options.md):\n  "
      .. (#gaps > 0 and table.concat(gaps, "\n  ") or out)
  )
end
