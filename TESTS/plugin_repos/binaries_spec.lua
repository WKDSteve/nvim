-- TESTS/plugin_repos/binaries_spec.lua -- :MyPlugins binaries status|fetch: loading a plugin to register its
-- fetcher, the by-hand download in "manual", the refusal in "never", the shell exit codes. A fake plugin stands in
-- for mdview.nvim: no network, no checkout needed.

---@param H table
local function spec(H)
  local eq, ok = H.eq, H.ok
  local binaries = require("bindings.usrcmds.plugin_repos.binaries")
  local lib = require("lib.nvim.binaries")
  local saved_mode = vim.g.lib_binaries

  ok(binaries.PLUGINS["mdview.nvim"] ~= nil, "mdview.nvim is listed as a plugin that downloads")
  eq(binaries.names()[1], "mdview.nvim", "names are listed")

  -- a fake plugin: requiring its module registers the fetcher, like mdview.adapter.install does
  local fetched = 0
  local installed = false
  package.preload["spec_fake_binaries_mod"] = function()
    lib.register("spec.fake", {
      fetch = function()
        local allowed, why = lib.guard("spec.fake")
        if not allowed then
          return false, why
        end
        fetched = fetched + 1
        installed = true
        return true
      end,
      status = function()
        return installed and "fake installed" or "fake missing"
      end,
    })
    return true
  end
  binaries.PLUGINS["spec.fake"] = { lazy = "spec.fake", module = "spec_fake_binaries_mod" }

  local loaded, err = binaries.load("spec.unknown")
  eq(loaded, nil, "an unknown plugin does not load")
  H.has(err, "downloads no binaries", "and the message says which ones do")

  -- status: the setting and the plugin's own line
  vim.g.lib_binaries = "manual"
  local lines, all_ok = binaries.status_lines("spec.fake")
  eq(all_ok, true, "status of a loadable plugin is fine")
  eq(lines[1], "vim.g.lib_binaries = manual", "status names the setting first")
  eq(lines[2], "spec.fake: fake missing", "then what the plugin has")

  -- fetch in manual: allowed, because it is on request
  lines, all_ok = binaries.fetch_lines("spec.fake")
  eq(all_ok, true, "fetch works in manual")
  eq(fetched, 1, "the plugin downloaded once")
  eq(lines[1], "spec.fake: fake installed", "and the line says what is there now")
  eq(lib.guard("spec.fake"), false, "afterwards an unasked download is stopped again")

  -- fetch in never: refused, the plugin is not asked to download
  vim.g.lib_binaries = "never"
  fetched = 0
  lines, all_ok = binaries.fetch_lines("spec.fake")
  eq(all_ok, false, "fetch is refused in never")
  eq(fetched, 0, "...without downloading")
  H.has(lines[1], "off", "and says why")

  -- the shell form: exit codes (stdout is not asserted, it is the lines above)
  vim.g.lib_binaries = "manual"
  eq(binaries.cli("nonsense"), 2, "an unknown action exits 2")
  vim.g.lib_binaries = "never"
  eq(binaries.cli("fetch", "spec.fake"), 1, "a refused fetch exits 1")
  vim.g.lib_binaries = "manual"
  eq(binaries.cli("fetch", "spec.fake"), 0, "a fetch that worked exits 0")

  -- the routes
  local paths = {}
  for _, r in ipairs(binaries.routes()) do
    paths[#paths + 1] = table.concat(r.path, " ")
  end
  eq(paths, { "binaries status", "binaries fetch" }, "the two routes exist")

  binaries.PLUGINS["spec.fake"] = nil
  package.preload["spec_fake_binaries_mod"] = nil
  vim.g.lib_binaries = saved_mode
end

return spec
