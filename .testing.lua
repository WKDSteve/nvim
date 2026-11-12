-- .testing.lua -- what testing.nvim needs to know about this config. Read as DATA (no calls, no `vim`): the config's
-- own specs run through TESTS/run.lua, not through testing.nvim, so nothing else is set here.
return {
  sheets = {
    -- The config lives in a folder `nvim`; its tasks and its checkout are `nvim-config`. The test sheets name it so
    -- in a task's block (`nvim-config/TESTS/sheets/...`), where tasks-desktop looks for their snapshots.
    project = "nvim-config",
  },
}
