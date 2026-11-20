-- TESTS/sheets/fixtures/clipboard_memory.lua -- the + and * registers of the installed config without the real
-- system clipboard.
--
-- The config's clipboard provider (my.nvim, `vim.g.clipboard`) stays the one that copies: its copy function runs and
-- starts its tool (on Windows `win32yank.exe -i --crlf`, sent to a stand-in by `stand_ins.lua`). Only the paste side
-- is replaced by what was copied last: lib.nvim's `copy_to_clipboard` reads the + register back to verify the copy,
-- and on Windows the real paste (`win32yank.exe -o`) would read the real clipboard, find something else and fall back
-- to `Set-Clipboard` in PowerShell, which writes it.
--
-- Called as `chunk()`; returns a function that gives the lines copied last to `reg` (default `+`). Loaded with
-- `load(text, "=clipboard_memory")` for the same reason as `stand_ins.lua`.
local cb = vim.g.clipboard
assert(type(cb) == "table" and cb.copy, "the installed config set no vim.g.clipboard provider")
local last = {}

local function copier(reg)
  local orig = cb.copy[reg]
  return function(lines, regtype)
    last[reg] = { vim.deepcopy(lines), regtype }
    if type(orig) == "function" then
      return orig(lines, regtype)
    elseif type(orig) == "string" then
      vim.fn.system(vim.split(orig, " ", { trimempty = true }), table.concat(lines, "\n"))
    end
  end
end

local function paster(reg)
  return function()
    return last[reg] or { {}, "v" }
  end
end

vim.g.clipboard = {
  name = "sheet-memory",
  copy = { ["+"] = copier("+"), ["*"] = copier("*") },
  paste = { ["+"] = paster("+"), ["*"] = paster("*") },
  cache_enabled = 0,
}
-- The provider reads g:clipboard when it loads; load it again so the new one is taken.
vim.g.loaded_clipboard_provider = nil
vim.cmd("runtime autoload/provider/clipboard.vim")

return function(reg)
  local got = last[reg or "+"]
  return got and got[1] or nil
end
