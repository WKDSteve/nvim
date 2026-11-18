-- TESTS/plugins_cmd_mirror_spec.lua -- the `cmd` of a lazy-loaded plugin spec against the user commands the plugin
-- registers. `cmd` is what loads the plugin on the first use of a command: a command missing there does not exist
-- until another one has loaded the plugin (E492), which is how `:RulesVault` failed before the first `:Rules`.
-- The plugin's sources are read (`composer.verb("Name"` and `nvim_create_user_command("Name"`), not run: setting a
-- plugin up here would leave its commands in the editor of the whole run.

return function(H)
  local ok = H.ok

  ---The checkout of a plugin: next to the lib.nvim the runner found (CI: `.deps/`), else below `$REPOS_DIR`.
  ---@param name string
  ---@return string|nil
  local function checkout(name)
    local lib = vim.env.LIB_NVIM_DIR
    for _, base in ipairs({ lib and vim.fs.dirname(lib) or false, vim.env.REPOS_DIR or false }) do
      if base and vim.fn.isdirectory(base .. "/" .. name .. "/lua") == 1 then
        return base .. "/" .. name
      end
    end
    return nil
  end

  local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
  local root = vim.fn.fnamemodify(here, ":h:h"):gsub("\\", "/")

  ---The one spec of a category for this plugin.
  ---@param category string
  ---@param repo string
  ---@return table|nil
  local function spec_of(category, repo)
    for _, spec in ipairs(dofile(("%s/lua/plugins/personal/specs/%s.lua"):format(root, category))) do
      if type(spec) == "table" and spec[1] == repo then
        return spec
      end
    end
    return nil
  end

  ---The user commands a checkout registers, read from its Lua sources.
  ---@param dir string
  ---@return table<string, true>
  local function registered(dir)
    local out = {}
    for _, file in
      ipairs(vim.fs.find(function(name)
        return name:match("%.lua$") ~= nil
      end, { path = dir .. "/lua", type = "file", limit = math.huge }))
    do
      local f = io.open(file, "rb")
      local text = f and f:read("*a") or ""
      if f then
        f:close()
      end
      for _, pattern in ipairs({
        'composer%.verb%(%s*"([%u][%w]*)"',
        'nvim_create_user_command%(%s*"([%u][%w]*)"',
      }) do
        for name in text:gmatch(pattern) do
          out[name] = true
        end
      end
    end
    return out
  end

  -- The plugins whose spec loads them by `cmd` alone. Add one here when its spec gets a `cmd` list.
  local plugins = {
    { category = "inspect", repo = "WKDSteve/rules.nvim", name = "rules.nvim" },
  }

  for _, p in ipairs(plugins) do
    local spec = spec_of(p.category, p.repo)
    ok(spec ~= nil, ("%s: a spec in specs/%s.lua"):format(p.repo, p.category))
    local dir = checkout(p.name)
    if not dir then
      print(("n/a  %s: no checkout next to lib.nvim or below $REPOS_DIR"):format(p.name))
    elseif spec then
      local declared = {}
      for _, name in ipairs(spec.cmd or {}) do
        declared[name] = true
      end
      local commands = registered(dir)
      ok(next(commands) ~= nil, p.name .. ": registers user commands (the source scan found some)")
      for name in pairs(commands) do
        ok(
          declared[name],
          ("%s: :%s is in the spec's cmd (else it is E492 until another one loads the plugin)"):format(
            p.name,
            name
          )
        )
      end
      for name in pairs(declared) do
        ok(
          commands[name],
          ("%s: :%s of the spec's cmd is a command the plugin registers"):format(p.name, name)
        )
      end
    end
  end
end
