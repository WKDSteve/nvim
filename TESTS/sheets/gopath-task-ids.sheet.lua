-- Live check: `gF` on a task id opens the task file of either vault (tasks-vault and the second vault), and
-- `:checkhealth gopath` reports both vaults. The ids are picked at run time from the vaults on this machine (the first
-- open task of each), so no id of the private vault is written into this repository, and nothing of its content is
-- shown: the sheet compares file names only.
return {
  id = "nvim-config.gopath-task-ids",
  title = "nvim-config: gF opens a task of either vault, checkhealth gopath counts two vaults",
  task = "nvim-config/gopath-gf-auf-task-ids-beider-vaults-und-checkhealth-von-han",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        -- The first open task of a vault as { id = "<area>/<slug>", file = "<path>" }, or nil.
        local function first_task(root)
          if not root or vim.fn.isdirectory(root) == 0 then
            return nil
          end
          local files = vim.fn.glob(root .. "/*/ROADMAP/tasks/*.md", false, true)
          table.sort(files)
          for _, f in ipairs(files) do
            local norm = vim.fs.normalize(f)
            local area, slug = norm:match("([^/]+)/ROADMAP/tasks/([^/]+)%.md$")
            if area and slug then
              return { id = area .. "/" .. slug, file = norm }
            end
          end
        end
        local repos = vim.env.REPOS_DIR or ""
        _G.__vaults = {
          first_task(repos .. "/tasks-vault"),
          first_task(repos .. "/tricentis-vault"),
        }
        -- gF on `id` in a scratch buffer; returns nothing, the next steps wait for the file.
        _G.__gf = function(id)
          vim.cmd("enew")
          vim.bo.buftype = "nofile"
          vim.api.nvim_buf_set_lines(0, 0, -1, false, { "see " .. id .. " here" })
          vim.api.nvim_win_set_cursor(0, { 1, 5 })
        end
        _G.__at = function(file)
          return vim.fs.normalize(vim.api.nvim_buf_get_name(0)):lower() == file:lower()
        end
      ]],
    },
    { expect = "_G.__vaults[1] ~= nil", note = "tasks-vault has an open task to jump to" },
    { expect = "_G.__vaults[2] ~= nil", note = "the second vault has an open task to jump to" },
    { lua = "vim.cmd('checkhealth gopath')" },
    {
      wait = "vim.bo.filetype == 'checkhealth' and #vim.api.nvim_buf_get_lines(0, 0, -1, false) > 3",
      timeout = 15000,
      note = ":checkhealth gopath opens its report",
    },
    {
      expect = "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n'):find('in 2 vault(s)', 1, true) ~= nil",
      note = "the tasks.nvim section says: in 2 vault(s)",
    },
    { lua = "_G.__gf(_G.__vaults[1].id)" },
    { input = "gF" },
    {
      wait = "_G.__at(_G.__vaults[1].file)",
      timeout = 5000,
      note = "gF on a tasks-vault id opens its task file",
    },
    { lua = "_G.__gf(_G.__vaults[2].id)" },
    { input = "gF" },
    {
      wait = "_G.__at(_G.__vaults[2].file)",
      timeout = 5000,
      note = "gF on an id of the second vault opens its task file",
    },
    {
      expect = "not vim.fn.execute('messages'):find('E%d+:')",
      note = "no error message on the way",
    },
  },
}
