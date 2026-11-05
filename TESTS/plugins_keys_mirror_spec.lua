-- TESTS/plugins_keys_mirror_spec.lua -- the `keys` of a lazy-loaded plugin spec against the keymaps the plugin registers.
-- `keys` is what loads the plugin on the first press: a binding missing there never loads it and silently does nothing,
-- and an entry that the plugin no longer maps loads it and then does nothing. The plugins are asked themselves: their own
-- `bindings.keymaps.setup` runs with the prefix of the spec, against the registry of lib.nvim.

return function(H)
  local eq, ok = H.eq, H.ok

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

  -- The specs of this checkout, by file: a `require` here would meet what an earlier spec of the run did to that module.
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

  ---`<mode> <lhs>` of one binding, in normal form.
  ---@param mode string
  ---@param lhs string
  ---@return string
  local function key(mode, lhs)
    return mode .. " " .. vim.fn.keytrans(vim.keycode(lhs))
  end

  ---What a list of lazy `keys` binds.
  ---@param keys table[]
  ---@return table<string, true>
  local function declared(keys)
    local out = {}
    for _, k in ipairs(keys) do
      local modes = k.mode or "n"
      for _, mode in ipairs(type(modes) == "table" and modes or { modes }) do
        out[key(mode, k[1])] = true
      end
    end
    return out
  end

  ---What the plugin registered.
  ---@param registered table[]
  ---@return table<string, true>
  local function bound(registered)
    local out = {}
    for _, r in ipairs(registered) do
      local modes = r.mode or "n"
      for _, mode in ipairs(type(modes) == "table" and modes or { modes }) do
        out[key(mode, r.lhs)] = true
      end
    end
    return out
  end

  ---@param set table<string, true>
  ---@return string[]
  local function sorted(set)
    local list = vim.tbl_keys(set)
    table.sort(list)
    return list
  end

  ---Both ways: no binding without a key that loads it, no key for a binding the plugin does not make.
  ---@param what string
  ---@param keys table[]
  ---@param registered table[]
  local function mirrors(what, keys, registered)
    local want, have = declared(keys), bound(registered)
    ok(next(have) ~= nil, what .. ": the plugin registered something")
    eq(sorted(want), sorted(have), what .. ": the keys of the spec are the keymaps of the plugin")
  end

  -- ── dap.nvim ──
  local dap_dir = checkout("dap.nvim")
  ok(
    dap_dir,
    "dap.nvim is there (CI: .deps/dap.nvim; here: $REPOS_DIR): this spec cannot say anything without it"
  )
  vim.opt.rtp:prepend(dap_dir)
  -- nvim-dap itself is not needed: the keymaps name its functions and no key is pressed here
  local function noop() end
  local functions = {
    __index = function()
      return noop
    end,
  }
  package.loaded["dap"] = setmetatable({ repl = setmetatable({}, functions) }, functions)
  local dap_spec = spec_of("inspect", "WKDSteve/dap.nvim")
  ok(dap_spec and dap_spec.keys, "the spec of dap.nvim has keys")
  ok(
    dap_spec.opts and dap_spec.opts.keymaps and dap_spec.opts.keymaps.prefix,
    "and hands its prefix to the plugin"
  )
  mirrors(
    "dap.nvim",
    dap_spec.keys,
    require("wkddap.bindings.keymaps").setup(
      { prefix = dap_spec.opts.keymaps.prefix, enable = true },
      false
    )
  )

  -- ── ai.nvim ──
  local ai_dir = checkout("ai.nvim")
  ok(
    ai_dir,
    "ai.nvim is there (CI: .deps/ai.nvim; here: $REPOS_DIR): this spec cannot say anything without it"
  )
  vim.opt.rtp:prepend(ai_dir)
  local ai_spec = spec_of("ai", "WKDSteve/ai.nvim")
  ok(ai_spec and ai_spec.keys, "the spec of ai.nvim has keys")
  ok(
    ai_spec.opts and ai_spec.opts.keymaps and ai_spec.opts.keymaps.prefix,
    "and hands its prefix to the plugin"
  )
  mirrors(
    "ai.nvim",
    ai_spec.keys,
    require("ai.bindings.keymaps").setup({
      keymaps = { prefix = ai_spec.opts.keymaps.prefix },
      which_key = { enable = false },
    })
  )
end
