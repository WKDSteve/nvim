---@module 'bindings.usrcmds.plugin_repos.binaries'
---@brief `:MyPlugins binaries status|fetch [plugin]` - download the binaries of own plugins by hand (workstation: never automatic).
---@description
--- Own plugins download binaries (mdview.nvim: the relay server and the client bundle) on first use. The setting
--- `vim.g.lib_binaries` (lib.nvim.binaries) says whether they may do that unasked; `init.lua` sets it to `"manual"`
--- on the workstation (`NVIM_MACHINE_ROLE=workstation`: an unsigned download is what the EDR reports there), and
--- leaves the private machine on the default `"auto"`. This module is the by-hand way:
---
---  - `binaries status`          what each plugin that downloads has (server, client bundle)
---  - `binaries fetch [plugin]`  download now (works in "manual", refused in "never")
---
--- The same from a shell, without a UI: `scripts/binaries.ps1 status|fetch [plugin]`.
---
--- Plugins are lazy: asking one means loading it first so that it has registered its fetcher with lib.nvim.
--- `M.PLUGINS` lists those that download (module = what registers them).

local notify = require("lib.nvim.notify").create("[usrcmds.plugin_repos.binaries]")

local M = {}

---Own plugins that download binaries: the lazy.nvim name and the module whose load registers the fetcher.
---@type table<string, { lazy: string, module: string }>
M.PLUGINS = {
  ["mdview.nvim"] = { lazy = "mdview.nvim", module = "mdview.adapter.install" },
}

---@return string[] names Sorted
function M.names()
  local names = vim.tbl_keys(M.PLUGINS)
  table.sort(names)
  return names
end

---Load a plugin so that it has registered its fetcher. Returns nil and why when it cannot.
---@param name string
---@return boolean|nil ok
---@return string|nil err
function M.load(name)
  local entry = M.PLUGINS[name]
  if not entry then
    return nil, ("'%s' downloads no binaries (%s)"):format(name, table.concat(M.names(), ", "))
  end
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    pcall(lazy.load, { plugins = { entry.lazy } })
  end
  local ok, err = pcall(require, entry.module)
  if not ok then
    return nil, ("%s is not loadable: %s"):format(name, tostring(err))
  end
  return true
end

---@param name? string One plugin, or all of them
---@return string[] lines
---@return boolean ok
function M.status_lines(name)
  local lines, all_ok =
    { ("vim.g.lib_binaries = %s"):format(require("lib.nvim.binaries").mode()) }, true
  for _, n in ipairs(name and { name } or M.names()) do
    local loaded, err = M.load(n)
    if loaded then
      lines[#lines + 1] = ("%s: %s"):format(
        n,
        require("lib.nvim.binaries").status()[n] or "not registered"
      )
    else
      all_ok = false
      lines[#lines + 1] = ("%s: %s"):format(n, err)
    end
  end
  return lines, all_ok
end

---Download now. Returns one line per plugin and whether all worked.
---@param name? string One plugin, or all of them
---@return string[] lines
---@return boolean ok
function M.fetch_lines(name)
  local binaries = require("lib.nvim.binaries")
  local lines, all_ok = {}, true
  for _, n in ipairs(name and { name } or M.names()) do
    local loaded, err = M.load(n)
    if not loaded then
      all_ok = false
      lines[#lines + 1] = ("%s: %s"):format(n, err)
    else
      local result = binaries.fetch(n)[n]
      if result.ok then
        lines[#lines + 1] = ("%s: %s"):format(n, binaries.status()[n] or "done")
      else
        all_ok = false
        lines[#lines + 1] = ("%s: %s"):format(n, result.err or "failed")
      end
    end
  end
  return lines, all_ok
end

---`:MyPlugins binaries status|fetch [plugin]`
---@param action "status"|"fetch"
---@param name? string
function M.run(action, name)
  local lines, ok
  if action == "fetch" then
    notify.info("fetching ... (the editor waits for the download)")
    lines, ok = M.fetch_lines(name)
  else
    lines, ok = M.status_lines(name)
  end
  local text = table.concat(lines, "\n")
  if ok then
    notify.info(text)
  else
    notify.warn(text)
  end
end

---The shell form (`scripts/binaries.ps1`): prints the lines and returns the exit code.
---@param action? string "status" (default) or "fetch"
---@param name? string
---@return integer code 0 all worked, 1 something failed, 2 unknown action
function M.cli(action, name)
  action = action or "status"
  if action ~= "status" and action ~= "fetch" then
    io.stderr:write(("binaries: unknown action '%s' (status, fetch)\n"):format(action))
    return 2
  end
  local lines, ok
  if action == "fetch" then
    lines, ok = M.fetch_lines(name)
  else
    lines, ok = M.status_lines(name)
  end
  io.stdout:write(table.concat(lines, "\n") .. "\n")
  return ok and 0 or 1
end

---The argument type of the plugin name (the plugins that download binaries).
function M.register_types()
  require("lib.nvim.bindings.usercmd.composer").register_type("MYPLUGINS_BINARIES_PLUGIN", {
    desc = "An own plugin that downloads binaries (<Tab> lists them)",
    validate = function(raw)
      if M.PLUGINS[raw] then
        return true, raw, nil
      end
      return false,
        nil,
        ("'%s' downloads no binaries (%s)"):format(raw, table.concat(M.names(), ", "))
    end,
    complete = function(arg_lead)
      return vim.tbl_filter(function(name)
        return arg_lead == "" or name:sub(1, #arg_lead) == arg_lead
      end, M.names())
    end,
  })
end

---@return table[]
function M.routes()
  local plugin_arg = { { name = "plugin", type = "MYPLUGINS_BINARIES_PLUGIN", optional = true } }
  return {
    {
      path = { "binaries", "status" },
      args = plugin_arg,
      desc = "What the own plugins that download binaries have (and the vim.g.lib_binaries setting)",
      run = function(ctx)
        M.run("status", ctx.args.plugin)
      end,
    },
    {
      path = { "binaries", "fetch" },
      args = plugin_arg,
      desc = "Download the binaries of one plugin (or all) now, also where vim.g.lib_binaries is 'manual' (the workstation)",
      run = function(ctx)
        M.run("fetch", ctx.args.plugin)
      end,
    },
  }
end

return M
