-- TESTS/ui_statusline_testing_ci_spec.lua -- the statusline module `testing_ci` (config/ui_statusline/variant.lua):
-- empty while testing.nvim is not loaded (a require would make lazy.nvim load the plugin at the first redraw),
-- afterwards the verdict of testing.ci.editor in the module's highlight, a `%` escaped for the statusline, and an
-- error of the component never reaches the statusline.

-- The spec puts stand-ins into package.loaded on purpose (restored at the end).
---@diagnostic disable: duplicate-set-field

return function(H)
  local eq = H.eq
  local saved =
    { testing = package.loaded["testing"], editor = package.loaded["testing.ci.editor"] }

  -- the variant loads ui.nvim's modules when it is required: stand-ins for exactly those it names, so the spec needs
  -- no ui.nvim checkout (read from the file, not listed here twice)
  local variant_path =
    vim.api.nvim_get_runtime_file("lua/config/ui_statusline/variant.lua", false)[1]
  local stubbed = {}
  for line in io.lines(variant_path) do
    local name = line:match('lazy%.require%("([^"]+)"%)')
    if name and package.loaded[name] == nil then
      package.loaded[name] = setmetatable({}, {
        __index = function()
          return function()
            return ""
          end
        end,
        __call = function()
          return ""
        end,
      })
      stubbed[#stubbed + 1] = name
    end
  end
  package.loaded["config.ui_statusline.variant"] = nil

  local good, failure = pcall(function()
    local mod = require("config.ui_statusline.variant").ui.statusline.modules.testing_ci
    local asked = 0
    package.loaded["testing.ci.editor"] = {
      statusline = function()
        asked = asked + 1
        return "ci: ✓ full @abc1234"
      end,
    }
    package.loaded["testing"] = nil
    eq(mod(), "", "testing.nvim not loaded: empty")
    eq(asked, 0, "... and the component is not asked")

    package.loaded["testing"] = {}
    eq(mod(), " %#St_Lsp#ci: ✓ full @abc1234", "loaded: the verdict in the module's highlight")
    package.loaded["testing.ci.editor"].statusline = function()
      return "ci: ✗ 100%"
    end
    eq(mod(), " %#St_Lsp#ci: ✗ 100%%", "a % is escaped for the statusline")
    package.loaded["testing.ci.editor"].statusline = function()
      return ""
    end
    eq(mod(), "", "nothing to say: empty, no highlight")
    package.loaded["testing.ci.editor"].statusline = function()
      error("boom")
    end
    eq(mod(), "", "an error of the component: empty")
  end)

  package.loaded["testing"], package.loaded["testing.ci.editor"] = saved.testing, saved.editor
  for _, name in ipairs(stubbed) do
    package.loaded[name] = nil
  end
  package.loaded["config.ui_statusline.variant"] = nil
  if not good then
    error(failure, 0)
  end
end
