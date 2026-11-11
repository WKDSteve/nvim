-- Live check: `M-o` / `M-O` (`lua/bindings/usrcmds/context_open/`) on the targets of
-- `TESTS/fixtures/context-open/targets.md` in the installed config. The candidates of each target are read from the
-- providers (nothing runs); then the keys a person presses: `M-o` on a `path:line`, the chooser, `<CR>` on the
-- gopath entry; `M-O` on a Lua file and its `require` line. Nothing here starts a browser, a viewer or a file
-- manager: only the gopath entries are picked, and they open inside the editor.
return {
  id = "nvim-config.context-open",
  title = "nvim-config: M-o offers the right providers per target and opens the gopath pick, M-O lists the targets",
  task = "nvim-config/context-open-review",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      lua = [[
        require("bindings.usrcmds.context_open.util").ensure_loaded("open.nvim")
        -- The labels M-o would offer at (line, col) of the current buffer, joined by " | ".
        _G.__offers = function(line, col)
          vim.api.nvim_win_set_cursor(0, { line, col })
          local signals = require("open.context").gather()
          local labels = {}
          for _, c in ipairs(require("bindings.usrcmds.context_open.providers").collect(signals)) do
            labels[#labels + 1] = c.label
          end
          return table.concat(labels, " | ")
        end
        -- The title of the floating chooser, or nil.
        _G.__chooser = function()
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            local b = vim.api.nvim_win_get_buf(w)
            if vim.bo[b].filetype == "lib-kit-chooser" then
              local t = vim.api.nvim_win_get_config(w).title
              if type(t) == "table" then
                t = table.concat(vim.tbl_map(function(c) return c[1] end, t))
              end
              return t or ""
            end
          end
        end
      ]],
    },
    { lua = "vim.cmd.edit('TESTS/fixtures/context-open/targets.md')" },
    {
      expect = "_G.__offers(5, 12):find('toggle table view', 1, true) and _G.__offers(5, 12):find('browser', 1, true)",
      note = "a URL in a table cell: the table view and the browser, so M-o asks",
    },
    {
      expect = "_G.__offers(7, 9):find('images: show image', 1, true)",
      note = "an image link: images.nvim",
    },
    {
      expect = "_G.__offers(9, 11):find('pdfport', 1, true) and _G.__offers(9, 11):find('PDF viewer', 1, true)",
      note = "a PDF link: pdfport and the system viewer",
    },
    {
      expect = "not _G.__offers(9, 11):find('split', 1, true)",
      note = "a PDF is never offered as a text buffer",
    },
    {
      expect = "_G.__offers(11, 10):find('notes.md', 1, true)",
      note = "a Markdown link to a file: gopath opens it",
    },
    -- M-o on `../structure/sample.lua:12`: several candidates, the chooser, the first (gopath) picked.
    { lua = "vim.api.nvim_win_set_cursor(0, { 13, 8 })" },
    { input = "<M-o>" },
    { wait = "_G.__chooser() ~= nil", timeout = 10000, note = "M-o opens the chooser" },
    { expect = "_G.__chooser():find('Open with', 1, true)", note = "titled 'Open with…'" },
    { input = "<CR>" },
    {
      wait = "vim.fn.expand('%:t') == 'sample.lua'",
      timeout = 5000,
      note = "the gopath pick opens the file in the editor",
    },
    { expect = "vim.api.nvim_win_get_cursor(0)[1] == 12", note = "on the line the path names" },
    -- M-O on a Lua file: its require line is a gopath target of the buffer list.
    {
      lua = "vim.cmd.edit('TESTS/fixtures/context-open/imports.lua'); vim.api.nvim_win_set_cursor(0, { 3, 0 })",
    },
    { input = "<M-O>" },
    { wait = "_G.__chooser() ~= nil", timeout = 10000, note = "M-O opens the list" },
    {
      expect = "_G.__chooser():find('buffer targets', 1, true)",
      note = "titled with the buffer targets",
    },
    {
      lua = [[
        local buf = vim.api.nvim_get_current_buf()
        for i, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
          if l:find("gopath", 1, true) then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            return
          end
        end
        error("no gopath entry in the M-O list")
      ]],
      note = "the require line is listed as a gopath target",
    },
    { input = "<CR>" },
    {
      wait = "vim.api.nvim_buf_get_name(0):gsub('\\\\', '/'):find('context_open/util.lua', 1, true) ~= nil",
      timeout = 5000,
      note = "picking it opens the required module",
    },
    {
      expect = "not vim.fn.execute('messages'):find('E%d+:')",
      note = "no error message on the way",
    },
  },
  judge = {
    "The labels of the chooser say clearly what each entry will do",
  },
  manual = {
    "Try M-o and M-O on real targets in daily work (URL in a table cell, image, PDF, Markdown link, media file, path:line) and note what surprises",
    "List the plugins added since context_open was built that deserve a provider (one task each); a media file today only gets split/vsplit/tab",
    "Bring the provider table of lua/bindings/usrcmds/context_open/README.md up to date with the result",
  },
}
