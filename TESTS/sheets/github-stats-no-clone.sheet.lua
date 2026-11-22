-- Sheet: the installed config starts without github_stats.nvim cloning its data repository. A sheet child attaches its
-- UI a few ms after start, so github_stats.nvim's own no-UI check does not hold there; the config opts out with
-- `vim.g.github_stats_no_clone_on_start` (lua/plugins/personal/specs/project.lua). `gh` is a recording stand-in
-- (fixtures/stand_ins.lua), so the proof is that no `gh repo clone` was asked for. On CI and without an installed
-- config: a skip.
return {
  id = "nvim-config.github-stats-no-clone",
  title = "nvim-config: the start of a sheet child runs no gh repo clone (github_stats_no_clone_on_start)",
  config = "user",
  fakes = { "gh" },
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        H.runtime("stand_ins", vim.env.TESTING_FAKES, { "gh" })
        -- the clone is deferred by 500 ms after VimEnter: wait it out
        _G.T0 = vim.uv.hrtime()
        _G.CLONES = function()
          return vim.tbl_filter(function(c)
            return c.argv[1] == "repo" and c.argv[2] == "clone"
          end, H.calls("gh"))
        end
      ]],
      note = "gh is a recording stand-in",
    },
    {
      expect = "vim.g.github_stats_no_clone_on_start == true",
      note = "the config opted out of the clone",
    },
    {
      wait = "(vim.uv.hrtime() - T0) > 2e9",
      timeout = 10000,
      note = "past the deferred start-up check",
    },
    { expect = "#CLONES() == 0", note = "no gh repo clone was started" },
  },
}
