-- TESTS/bindings/gitsigns_refresh_spec.lua -- `bindings.autocmds.git.gitsigns_refresh`: off by default, FocusGained
-- only when on; it only calls gitsigns when it is loaded already and must never `require` it (that
-- loaded the plugin with the first buffer, long before its own trigger).

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
    vim.api.nvim_exec_autocmds("FocusGained", { group = "spec_gitsigns_refresh" })
    ok(not required, "FocusGained does not load gitsigns")
    ok(package.loaded["gitsigns"] == nil, "…and leaves it unloaded")

    -- loaded: refresh is called
    local refreshed = 0
    package.loaded["gitsigns"] = {
      refresh = function()
        refreshed = refreshed + 1
      end,
    }
    vim.api.nvim_exec_autocmds("FocusGained", { group = "spec_gitsigns_refresh" })
    eq(refreshed, 1, "a loaded gitsigns is refreshed on FocusGained")
    -- gitsigns runs its deferred updates on BufEnter itself; refresh() there re-read the
    -- index blob of every attached buffer on each buffer switch.
    eq(
      #vim.api.nvim_get_autocmds({ group = "spec_gitsigns_refresh", event = "BufEnter" }),
      0,
      "default events: no BufEnter autocmd"
    )
    vim.api.nvim_exec_autocmds("BufEnter", { group = "spec_gitsigns_refresh" })
    eq(refreshed, 1, "…so a buffer switch does not refresh")

    -- explicit events still win
    mod.enable({ enable = true, events = { "BufEnter" } }, shared)
    vim.api.nvim_exec_autocmds("BufEnter", { group = "spec_gitsigns_refresh" })
    eq(refreshed, 2, "configured BufEnter refreshes")

    -- shipped default: off (gitsigns' own watch_gitdir keeps the signs current)
    local defaults = require("bindings.autocmds.git.defaults").get_defaults()
    eq(defaults.gitsigns_refresh.enable, false, "refresh is off by default")
  end)

  package.loaded["gitsigns"] = saved
  package.preload["gitsigns"] = saved_preload
  pcall(vim.api.nvim_del_augroup_by_name, "spec_gitsigns_refresh")
  if not ok_run then
    error(err, 0)
  end
end
