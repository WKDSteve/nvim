-- TESTS/cdx/setup_cli_path_check_spec.lua -- setup-claude-code.ps1 checks, as a new PowerShell would, that `testing`,
-- `tasks` and `rules` resolve to the `.cmd` shim of their checkout: it reads the PATH from the registry, names an alias
-- or function of the same name that would shadow the shim, and without a shim prints the long `nvim -l` form as a
-- plain line to copy (no prompt characters). The check itself reads the registry of the machine, so only the text of
-- the script is checked here.

return function(H)
  local ok = H.ok

  -- From this file, not stdpath("config"): in a worktree that is the main checkout.
  local spec = debug.getinfo(1, "S").source:sub(2)
  local root =
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(spec, ":p")))))
  local body = H.read(root .. "/docs/NOTES/CDX/setup-claude-code.ps1") or ""
  ok(body ~= "", "the setup script is there")

  local start = body:find("# Kontrolle wie in einer neuen PowerShell", 1, true)
  ok(start, "the script checks the commands as a new PowerShell would")
  local block = body:sub(start or 1, (body:find("# TASKS_VAULT:", start or 1, true) or #body) - 1)
  for _, name in ipairs({ "'testing'", "'tasks'", "'rules'" }) do
    ok(block:find(name, 1, true), "the check covers " .. name)
  end
  ok(
    block:find("GetEnvironmentVariable('Path', 'User')", 1, true)
      and block:find("GetEnvironmentVariable('Path', 'Machine')", 1, true),
    "the PATH of a new shell, from the registry (not this process's)"
  )
  ok(
    block:find("-CommandType Alias, Function", 1, true),
    "an alias or function that shadows the shim is named"
  )
  ok(
    block:find("nvim -n -i NONE --headless -u NONE -l ", 1, true),
    "without a shim the long form is printed"
  )
  -- a line to copy starts with the command: no `>`, `$` or `PS>` in front of it
  for line in block:gmatch('Write%-Host "([^"]*)"') do
    local t = vim.trim(line)
    -- `$name` is a variable of the script, `$ ` a prompt
    ok(not (t:match("^>") or t:match("^%$%s") or t:match("^PS>")), "no prompt character: " .. line)
  end
end
