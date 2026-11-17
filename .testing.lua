-- .testing.lua -- what testing.nvim needs to know about this config. Read as DATA (no calls, no `vim`): the config's
-- own specs run through TESTS/run.lua; testing.nvim runs them too for `testing ci commit` and the sheets.
return {
  sheets = {
    -- The config lives in a folder `nvim`; its tasks and its checkout are `nvim-config`. The test sheets name it so
    -- in a task's block (`nvim-config/TESTS/sheets/...`), where tasks-desktop looks for their snapshots.
    project = "nvim-config",
  },
  -- The `sync/` specs build real git repositories and run real git on them (TESTS/README.md): `sync_assist` takes
  -- ~26 s on an idle machine, and a git process on Windows gets several times slower while other sessions run their
  -- suites. The default 60 s per file turned a slow machine into a REGRESSION (2026-11-16, 131 s under load, before
  -- the fixture was cut from ~21 to 3 git processes per repo); 120 s keeps a hang a timeout and load a pass.
  timeouts = { file_ms = 120000 },
}
