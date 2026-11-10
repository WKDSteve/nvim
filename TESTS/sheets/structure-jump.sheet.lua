-- Live check: `[u`/`]u` climb out of the enclosing structure in the installed config (nvim-treesitter-textobjects
-- `move` with `@block.outer`, extended per language in `after/queries/<lang>/textobjects.scm`). The fixtures under
-- `TESTS/fixtures/structure/` nest three levels; the cursor starts on the innermost line. Lua goes through typed keys,
-- the other five languages through `:normal` (mappings apply). On CI and without an installed config: a skip.
return {
  id = "nvim-config.structure-jump",
  title = "nvim-config: [u/]u climb out of the enclosing structure in lua, json, python, rust, toml and yaml",
  task = "nvim-config/live-check-structure-jump-and-bindings-check",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      wait = "vim.fn.maparg('[u', 'n') ~= '' and vim.fn.maparg(']u', 'n') ~= ''",
      timeout = 10000,
      note = "[u and ]u are mapped",
    },
    {
      lua = [[
        -- Jumps from (line, col) with `key` three times; the lines reached, as "a,b,c".
        _G.__climb = function(file, line, col, key)
          vim.cmd.edit("TESTS/fixtures/structure/" .. file)
          assert(pcall(vim.treesitter.get_parser, 0), "no tree-sitter parser for " .. file)
          vim.api.nvim_win_set_cursor(0, { line, col })
          local seen = {}
          for _ = 1, 3 do
            vim.cmd.normal(key)
            seen[#seen + 1] = vim.api.nvim_win_get_cursor(0)[1]
          end
          return table.concat(seen, ",")
        end
      ]],
    },
    -- Lua by typed keys: in a function, for -> if -> function.
    {
      lua = "vim.cmd.edit('TESTS/fixtures/structure/sample.lua'); vim.api.nvim_win_set_cursor(0, { 4, 6 })",
    },
    { wait = "pcall(vim.treesitter.get_parser, 0)", timeout = 10000, note = "lua has a parser" },
    { keys = "[u" },
    { expect = "vim.api.nvim_win_get_cursor(0)[1] == 3", note = "[u: the head of the if" },
    { keys = "[u" },
    { expect = "vim.api.nvim_win_get_cursor(0)[1] == 2", note = "[u again: the head of the for" },
    { keys = "[u" },
    {
      expect = "vim.api.nvim_win_get_cursor(0)[1] == 1",
      note = "[u again: the head of the function",
    },
    { lua = "vim.api.nvim_win_set_cursor(0, { 4, 6 })" },
    { keys = "]u" },
    { expect = "vim.api.nvim_win_get_cursor(0)[1] == 5", note = "]u: the end of the if" },
    { keys = "]u" },
    { expect = "vim.api.nvim_win_get_cursor(0)[1] == 6", note = "]u again: the end of the for" },
    -- A configuration table climbs table head by table head (the query of after/queries/lua).
    {
      expect = "_G.__climb('sample.lua', 12, 6, '[u') == '11,10,9'",
      note = "lua table: tls -> server -> config",
    },
    {
      expect = "_G.__climb('sample.lua', 12, 6, ']u') == '13,14,15'",
      note = "lua table: the closing braces",
    },
    {
      expect = "_G.__climb('sample.py', 4, 12, '[u') == '3,2,1'",
      note = "python: if -> for -> def",
    },
    { expect = "_G.__climb('sample.rs', 4, 12, '[u') == '3,2,1'", note = "rust: if -> for -> fn" },
    {
      expect = "_G.__climb('sample.rs', 4, 12, ']u') == '5,6,7'",
      note = "rust: the closing braces",
    },
    {
      expect = "_G.__climb('sample.json', 4, 6, '[u') == '3,2,1'",
      note = "json: tls -> server -> root",
    },
    {
      expect = "_G.__climb('sample.json', 4, 6, ']u') == '5,6,7'",
      note = "json: the closing braces",
    },
    {
      expect = "_G.__climb('sample.toml', 5, 0, '[u') == '4,1,1'",
      note = "toml: [server.tls] -> [server]",
    },
    {
      expect = "_G.__climb('sample.yaml', 4, 6, '[u') == '3,2,1'",
      note = "yaml: files -> tls -> server",
    },
    -- The keys next to it stay what they were (`[b`/`]b` is a Neovim 0.12 default, `[s`/`]s` spelling).
    {
      expect = [[(function()
        local mine = vim.fn.maparg('[u', 'n', false, true).desc
        for _, k in ipairs({ '[b', ']b', '[s', ']s' }) do
          if vim.fn.maparg(k, 'n', false, true).desc == mine then return false end
        end
        return true
      end)()]],
      note = "[b ]b [s ]s are not the structure jump",
    },
  },
  judge = {
    "In a real session the jump feels right where it matters to you (a function of your own code, a lazy spec table)",
  },
}
