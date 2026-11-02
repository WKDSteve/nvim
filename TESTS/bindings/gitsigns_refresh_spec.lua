-- TESTS/bindings/gitsigns_refresh_spec.lua -- `bindings.autocmds.git.gitsigns_refresh`: the refresh
-- on BufEnter / FocusGained only calls gitsigns when it is loaded already; it must never `require`
-- it (that loaded the plugin with the first buffer, long before its own trigger).

return function(H)
  local eq, ok = H.eq, H.ok
  local mod = require("bindings.autocmds.git.gitsigns_refresh")

  local shared = {
    norm_events = function(events, default)
      return events or default
    end,
    augroup = function(name)
      return vim.api.nvim_create_augroup("spec_" .. name, { clear = true })
    end,
  }

  local saved = package.loaded["gitsigns"]
  local saved_preload = package.preload["gitsigns"]

  local ok_run, err = pcall(function()
    -- disabled: nothing registered
    mod.enable({ enable = false }, shared)
    ok(
      not pcall(vim.api.nvim_get_autocmds, { group = "spec_gitsigns_refresh" }),
      "disabled: no group, no autocmd"
    )

    mod.enable({ enable = true }, shared)

    -- not loaded: the event must not load it
    package.loaded["gitsigns"] = nil
    local required = false
    package.preload["gitsigns"] = function()
      required = true
      return { refresh = function() end }
    end
    vim.api.nvim_exec_autocmds("BufEnter", { group = "spec_gitsigns_refresh" })
    ok(not required, "BufEnter does not load gitsigns")
    ok(package.loaded["gitsigns"] == nil, "…and leaves it unloaded")

    -- loaded: refresh is called
    local refreshed = 0
    package.loaded["gitsigns"] = {
      refresh = function()
        refreshed = refreshed + 1
      end,
    }
    vim.api.nvim_exec_autocmds("BufEnter", { group = "spec_gitsigns_refresh" })
    eq(refreshed, 1, "a loaded gitsigns is refreshed")
    vim.api.nvim_exec_autocmds("FocusGained", { group = "spec_gitsigns_refresh" })
    eq(refreshed, 2, "…on FocusGained too")
  end)

  package.loaded["gitsigns"] = saved
  package.preload["gitsigns"] = saved_preload
  pcall(vim.api.nvim_del_augroup_by_name, "spec_gitsigns_refresh")
  if not ok_run then
    error(err, 0)
  end
end
