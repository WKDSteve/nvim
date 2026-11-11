-- Live check: `:Bindings check` runs on the installed config and opens its drift report. The number of findings is in
-- the title (`Bindings — check (N)`); around 50 is the known state, a number far above 100 points at the tool rather
-- than at the bindings. Whether a reported keymap really is missing from the notes tree is a judgement (below).
return {
  id = "nvim-config.bindings-check",
  title = "nvim-config: :Bindings check runs and reports a plausible number of drift findings",
  task = "nvim-config/live-check-structure-jump-and-bindings-check",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        -- The title of the report float, or nil.
        _G.__report_title = function()
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            local t = vim.api.nvim_win_get_config(w).title
            if type(t) == "table" then
              t = table.concat(vim.tbl_map(function(c) return c[1] end, t))
            end
            if type(t) == "string" and t:find("Bindings", 1, true) and t:find("check", 1, true) then
              return t
            end
          end
        end
      ]],
    },
    -- `input`, not `keys`: the check reads the whole corpus and blocks for many seconds on a cold start.
    { input = ":Bindings check<CR>" },
    { wait = "_G.__report_title() ~= nil", timeout = 120000, note = "the report opens" },
    {
      expect = "tonumber(_G.__report_title():match('%((%d+)%)')) ~= nil",
      note = "the title carries the number of findings",
    },
    {
      expect = "tonumber(_G.__report_title():match('%((%d+)%)')) <= 100",
      note = "at most 100 findings (around 50 is the known state; far more means the tool is suspect)",
    },
    { expect = "not vim.fn.execute('messages'):find('E%d+:')", note = "no error message" },
  },
  judge = {
    "Sample against the notes tree: one reported keymap is really missing there, one not reported is really there",
  },
  manual = {
    "Every real finding becomes a task of its own (kind: bug), not text in the test plan",
  },
}
