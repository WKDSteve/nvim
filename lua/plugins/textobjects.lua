---@module 'plugins.textobjects'
--- Textobject extensions for motions and selections.

---@type LazyPluginSpec[]
return {

  --  mini.ai: Modern textobjects powered by Lua
  {
    "echasnovski/mini.ai",
    version = "*",
    event = "VeryLazy",
    config = function()
      -- Neovim 0.12 ships `an` / `in` (incremental selection); mini.ai's default "next" mappings
      -- would shadow them. Next and last move to capitals: `aN`/`iN` next, `aL`/`iL` last.
      require("mini.ai").setup({
        mappings = {
          around_next = "aN",
          inside_next = "iN",
          around_last = "aL",
          inside_last = "iL",
        },
      })
    end,
  },
}
