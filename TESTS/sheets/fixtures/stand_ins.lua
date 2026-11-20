-- TESTS/sheets/fixtures/stand_ins.lua -- send this config's starts of some programs to testing.nvim's recording
-- stand-ins (`fakes` of a sheet), on every system.
--
-- A stand-in first on the PATH is not enough here:
-- * libuv (`vim.system`, `jobstart` with a list) looks only for `.exe` and `.com` on Windows, so the `.cmd` stand-in
--   is passed over and the real program runs (reposcope.nvim saw a real `curl`, 2026-11-19);
-- * a start by the `.exe` name (`win32yank.exe` in my.nvim's clipboard) finds the real program behind it (testing.nvim
--   task fakes-unter-windows-exe-namen-explorer-exe-rundll32-exe-und).
-- So `vim.system`, `vim.fn.jobstart` and `vim.fn.system` are wrapped: a program the sheet names, with or without
-- `.exe`, becomes the absolute path of its stand-in. On Windows the characters cmd treats as operators become `_` in
-- its arguments (testing.nvim task fake-programs-der-windows-stand-in-fuehrt-die-teile-eines-ar).
--
-- Called as `chunk(dir, names)`, `dir` = `vim.env.TESTING_FAKES`. A sheet loads it with `load(text, "=stand_ins")`,
-- never `dofile`: a chunk without a file name is runtime to `testing perf`'s trace, so the config's own line stays the
-- caller of the start (a `dofile` from `TESTS/` would make every start the sheet's).
local dir, names = ...
local windows = vim.fn.has("win32") == 1
local path_of = {}
for _, name in ipairs(names) do
  path_of[name] = dir .. "/" .. name .. (windows and ".cmd" or "")
end

local function redirect(cmd)
  if type(cmd) ~= "table" or type(cmd[1]) ~= "string" then
    return cmd
  end
  local name = vim.fs.basename(cmd[1]):gsub("%.[eE][xX][eE]$", "")
  local path = path_of[name]
  if not path then
    return cmd
  end
  local copy = { path }
  for i = 2, #cmd do
    copy[i] = windows and (tostring(cmd[i]):gsub("[&|<>^%%]", "_")) or cmd[i]
  end
  return copy
end

local system = vim.system
vim.system = function(cmd, opts, on_exit)
  return system(redirect(cmd), opts, on_exit)
end

local jobstart = vim.fn.jobstart
rawset(vim.fn, "jobstart", function(cmd, opts)
  return jobstart(redirect(cmd), opts)
end)

local fn_system = vim.fn.system
rawset(vim.fn, "system", function(cmd, ...)
  return fn_system(redirect(cmd), ...)
end)
