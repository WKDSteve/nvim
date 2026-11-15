-- TESTS/profile/source_workstation_spec.lua -- plugins.personal.core.source on the workstation:
-- the ai family is never installed there, so ai.nvim's spec comes out disabled whatever the
-- profile says, while the other personal plugins stay on; elsewhere ai.nvim is untouched.

return function(H)
  local eq, ok = H.eq, H.ok

  local saved = {
    machine = package.loaded["machine"],
    profile = package.loaded["profile"],
    source = package.loaded["plugins.personal.core.source"],
  }

  ---@param role string
  ---@return table<string, LazyPluginSpec>
  local function export_as(role)
    package.loaded["machine"] = {
      is = function(r)
        return r == role
      end,
    }
    package.loaded["profile"] = {
      is = function()
        return false
      end,
    }
    package.loaded["plugins.personal.core.source"] = nil
    local plugins = require("plugins.personal.core.source")
    plugins.add({ { "WKDSteve/ai.nvim" }, { "WKDSteve/lib.nvim" } })
    local by_name = {}
    for _, spec in ipairs(plugins.export()) do
      by_name[vim.fn.fnamemodify(spec[1], ":t")] = spec
    end
    return by_name
  end

  local done, err = pcall(function()
    local ws = export_as("workstation")
    eq(ws["ai.nvim"].enabled, false, "workstation: ai.nvim is disabled")
    ok(ws["lib.nvim"].enabled ~= false, "workstation: lib.nvim stays on")

    local home = export_as("default")
    ok(home["ai.nvim"].enabled ~= false, "private machine: ai.nvim stays on")
  end)

  package.loaded["machine"] = saved.machine
  package.loaded["profile"] = saved.profile
  package.loaded["plugins.personal.core.source"] = saved.source
  if not done then
    error(err, 0)
  end
end
