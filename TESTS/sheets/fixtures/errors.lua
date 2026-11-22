-- TESTS/sheets/fixtures/errors.lua -- the error messages of a sheet's editor, for "no error on the way" checks.
--
-- What each source sees, measured under noice in this config (TESTS/sheets/no-errors-probe.sheet.lua):
-- * `:messages` keeps every error the editor itself shows: an `E123:` of a command, `echoerr`, `nvim_echo` with
--   `err`, and Lua errors of callbacks (`vim.schedule callback: ...`, an autocmd's `Lua callback: ...`), the last ones
--   without an E-number, so a search for `E%d+:` alone misses them; a Lua error always comes with its
--   `stack traceback:`. Errors from before noice attached are only here.
-- * noice's history keeps every message noice received, skipped ones too, with its level: `vim.notify` at ERROR is
--   only here (noice replaces `vim.notify`, nothing reaches `:messages`).
-- * lib.nvim's popup history keeps the messages this config shows as popups (not in `:messages`, not in noice).
--
-- Load it in the first step, while the cwd is the project root (a sheet may `:cd` away, and the config's root
-- detection does when it opens a file): `_G.SheetErrors = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/
-- errors.lua")`; `none()` is the check, `list()` says what it found (for a sheet run step by step).
local M = {}

---Whether one message of `:messages` (its first line and the lines that continue it) is an error.
---@param text string
---@return boolean
local function is_error(text)
  return text:find("E%d+:") ~= nil
    or text:find("stack traceback:", 1, true) ~= nil
    or text:find("^Error ") ~= nil
end

---The error messages in `:messages`: a line that starts with whitespace or `stack traceback:` continues the message
---above it.
---@return string[]
function M.from_messages()
  local blocks = {}
  for _, line in ipairs(vim.split(vim.fn.execute("messages"), "\n", { plain = true })) do
    if #blocks > 0 and (line:find("^%s") or line:find("^stack traceback:")) then
      blocks[#blocks] = blocks[#blocks] .. "\n" .. line
    elseif line ~= "" then
      blocks[#blocks + 1] = line
    end
  end
  return vim.tbl_filter(is_error, blocks)
end

---The messages at level error in noice's history (none while noice is not loaded: a `require` here would make
---lazy.nvim load and set up noice, so the check itself would change the editor it checks).
---@return string[]
function M.from_noice()
  local manager = package.loaded["noice.message.manager"]
  if type(manager) ~= "table" or type(manager.get) ~= "function" then
    return {}
  end
  local found = {}
  for _, message in ipairs(manager.get(nil, { history = true, sort = true })) do
    if message.level == "error" then
      found[#found + 1] = message:content()
    end
  end
  return found
end

---The messages at level ERROR in lib.nvim's popup history (none when it is not loaded).
---@return string[]
function M.from_popups()
  local popup = package.loaded["lib.nvim.notify.popup"]
  if type(popup) ~= "table" or type(popup.history) ~= "function" then
    return {}
  end
  local found = {}
  for _, entry in ipairs(popup.history()) do
    if (entry.level or 0) >= vim.log.levels.ERROR then
      found[#found + 1] = tostring(entry.message)
    end
  end
  return found
end

---Every error message of the three sources, without those that contain one of `ignore` (plain text).
---@param ignore? string[] texts of errors the sheet raises on purpose
---@return string[]
function M.list(ignore)
  local found = {}
  for _, source in ipairs({ M.from_messages(), M.from_noice(), M.from_popups() }) do
    for _, text in ipairs(source) do
      local wanted = true
      for _, skip in ipairs(ignore or {}) do
        if text:find(skip, 1, true) then
          wanted = false
          break
        end
      end
      if wanted then
        found[#found + 1] = text
      end
    end
  end
  return found
end

---No error message on the way (other than those of `ignore`).
---@param ignore? string[]
---@return boolean
function M.none(ignore)
  return #M.list(ignore) == 0
end

---Whether one of `texts` (a source's list) contains `text` (plain).
---@param texts string[]
---@param text string
---@return boolean
function M.has(texts, text)
  for _, t in ipairs(texts) do
    if t:find(text, 1, true) then
      return true
    end
  end
  return false
end

return M
