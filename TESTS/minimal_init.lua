-- TESTS/minimal_init.lua -- testing.nvim's per-child init (`minit`, its default path).
--
-- Puts the checkout under test first on the runtimepath. Without it a spec child keeps the
-- default runtimepath, whose `stdpath("config")` entry is the user's live config: in a git
-- worktree (a Claude session, `testing ci commit`'s own worktree) every `require` of a config
-- module then loaded the MAIN checkout's file, so a changed module was tested in its old form
-- (2026-11-18: a changed default of bindings.autocmds.git showed up as a false REGRESSION).
-- TESTS/run.lua does the same prepend for its own runs.

local source = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/")
local root = vim.fs.dirname(vim.fs.dirname(source))
vim.opt.rtp:prepend(root)
