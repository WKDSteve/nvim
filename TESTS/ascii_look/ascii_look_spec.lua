-- TESTS/ascii_look/ascii_look_spec.lua -- the ASCII look follows the ui.kit preset: on an ASCII preset 'fillchars',
-- 'listchars' and 'winborder' change, on any other the user's own values come back, and the fixed borders follow.

return function(H)
  local eq, ok = H.eq, H.ok
  local look = require("config.ascii_look")
  local theme = require("lib.nvim.ui.kit.theme")

  local before_preset = theme.default()
  local fill, list, border = vim.o.fillchars, vim.o.listchars, vim.o.winborder

  local function run()
    look.disable()
    vim.o.fillchars = "eob: ,vert:X"
    vim.o.listchars = "tab:>>"
    pcall(function()
      vim.o.winborder = "rounded"
    end)
    look.setup()
    -- start from a non-ASCII preset so the switches below are real changes
    theme.setup({ default = "rounded" })
    ok(not look.active(), "a non-ASCII preset: the look is off")
    eq(look.border("rounded"), "rounded", "off: border() returns the fallback")

    theme.setup({ default = "hacker" })
    ok(look.active(), "the hacker preset switches the look on")
    ok(vim.o.fillchars:find("vert:|", 1, true) ~= nil, "on: the vertical separator is |")
    ok(vim.o.fillchars:find("horiz:-", 1, true) ~= nil, "on: the horizontal separator is -")
    ok(vim.o.listchars:find("tab:>-", 1, true) ~= nil, "on: listchars are ASCII")
    ok(vim.o.winborder ~= "rounded", "on: winborder is no longer the old value")
    eq(#look.border("rounded"), 8, "on: border() is the eight-character ASCII box")
    eq(look.border("rounded")[1], "+", "on: ...with + corners")

    theme.setup({ default = "rounded" })
    ok(not look.active(), "back on a non-ASCII preset: the look is off")
    eq(vim.o.fillchars, "eob: ,vert:X", "off: fillchars is what the user had")
    eq(vim.o.listchars, "tab:>>", "off: listchars is what the user had")
    eq(vim.o.winborder, "rounded", "off: winborder is what the user had")

    -- enable twice keeps the first values, not the ASCII ones
    look.enable()
    look.enable()
    look.disable()
    eq(
      vim.o.fillchars,
      "eob: ,vert:X",
      "enable is idempotent: the originals are kept from the first call"
    )
  end

  local finished, err = pcall(run)
  look.disable()
  pcall(theme.setup, { default = before_preset })
  vim.o.fillchars, vim.o.listchars = fill, list
  pcall(function()
    vim.o.winborder = border
  end)
  if not finished then
    error(err, 0)
  end
end
