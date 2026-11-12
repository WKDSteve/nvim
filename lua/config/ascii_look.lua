---@module 'config.ascii_look'
--- The ASCII look follows the ui.kit preset: when the active preset is boxed in ASCII (`hacker`, `ascii`), the
--- editor's own box-drawing follows it too (window separators, fold fill, whitespace markers, the default float
--- border); on any other preset the values the user had are put back. Nothing here is a setting of its own: the
--- one switch is `:UI kit-preset <name>`.
---
--- Levers (see nvim-config/ROADMAP/reports/2026-11-06_ascii-look-stellhebel.md):
---   * 'fillchars'   vert, horiz, the T-junctions, fold, foldsep, diff
---   * 'listchars'   tab, trail, nbsp, extends, precedes (the 'list' option itself is not touched)
---   * 'winborder'   the border of every float that sets none (Neovim 0.11+)
---   * `M.border(fallback)` for the fixed borders in this config that are chosen when a float opens

local M = {}

local GROUP = "config_ascii_look"

--- What the options are set to in the ASCII look.
M.ASCII = {
  fillchars = "vert:|,horiz:-,horizup:+,horizdown:+,vertleft:+,vertright:+,verthoriz:+,fold:-,foldsep:|,diff:-",
  listchars = "tab:>-,trail:-,nbsp:+,extends:>,precedes:<",
  -- eight characters, as the kit's own ASCII border: top-left, top, top-right, right, bottom-right, bottom, bottom-left, left
  winborder = "+,-,+,|,+,-,+,|",
}

---The values in effect before the ASCII look was switched on; nil while it is off.
---@type table<string, string>|nil
local saved = nil

---@return boolean
function M.active()
  return saved ~= nil
end

---Set an option, tolerating a value this Neovim does not take (e.g. 'winborder' as a character list on 0.11.4).
---@param name string
---@param value string
---@param fallback? string
local function set(name, value, fallback)
  local ok = pcall(function()
    vim.o[name] = value
  end)
  if not ok and fallback then
    pcall(function()
      vim.o[name] = fallback
    end)
  end
end

---Switch the ASCII look on. Idempotent: the values the user had are kept from the first call.
function M.enable()
  if saved then
    return
  end
  saved = {}
  for _, name in ipairs({ "fillchars", "listchars", "winborder" }) do
    local ok, current = pcall(function()
      return vim.o[name]
    end)
    saved[name] = ok and current or ""
  end
  set("fillchars", M.ASCII.fillchars)
  set("listchars", M.ASCII.listchars)
  set("winborder", M.ASCII.winborder, "single")
end

---Switch the ASCII look off and put back what was there.
function M.disable()
  if not saved then
    return
  end
  local back = saved
  saved = nil
  for _, name in ipairs({ "fillchars", "listchars", "winborder" }) do
    set(name, back[name])
  end
end

---The border for a float this config opens itself: the ASCII box while the look is on, else `fallback`.
---@param fallback string|string[]
---@return string|string[]
function M.border(fallback)
  if saved then
    return { "+", "-", "+", "|", "+", "-", "+", "|" }
  end
  return fallback
end

---Follow the kit preset from now on, and match the one that is active already.
function M.setup()
  local group = vim.api.nvim_create_augroup(GROUP, { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "LibKitPresetChanged",
    desc = "config.ascii_look: follow the ui.kit preset",
    callback = function(args)
      local data = args.data
      if type(data) == "table" and data.ascii then
        M.enable()
      else
        M.disable()
      end
    end,
  })
  local ok, theme = pcall(require, "lib.nvim.ui.kit.theme")
  if ok and theme.resolve(theme.default()).ascii_border then
    M.enable()
  end
end

return M
