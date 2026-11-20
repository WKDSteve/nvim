-- Feature sheet: `:Execute!` runs the `code` under the cursor (lua/bindings/usrcmds/execute/), typed in the installed
-- config. A shell command runs for real through 'shell' (`vim.fn.jobstart`, asynchronous; on this machine pwsh), its
-- output lands in a split; `result` copies the output to the + register. The copy goes through the config's own
-- clipboard provider, whose program is a recording stand-in (fixtures/stand_ins.lua), and the + register reads back
-- what was copied (fixtures/clipboard_memory.lua): the real clipboard is neither written nor read. `--yes` stands for
-- the [R]un answer of the question a shell command asks first. On CI and without an installed config: a skip.
return {
  id = "nvim-config.execute-shell",
  feature = "nvim-config.execute",
  title = "nvim-config: :Execute! split runs the `echo` under the cursor in the shell, result copies its output",
  task = "nvim-config/abnahme-prozess-features-der-config-von-hand-zwischenablage",
  config = "user",
  fakes = { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" },
  sizes = { { rows = 24, cols = 110 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    { wait = "vim.fn.exists(':Execute') == 2", timeout = 30000, note = ":Execute is there" },
    {
      lua = [[
        vim.opt.shortmess:append("I")
        _G.H = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")
        H.runtime("stand_ins", vim.env.TESTING_FAKES, { "win32yank", "wl-copy", "xclip", "xsel", "pbcopy" })
        _G.COPIED = H.runtime("clipboard_memory")
        local file = H.tmpdir() .. "/notes.md"
        _G.FILE = file
        H.write(file, "# Notes\n\nCheck the shell with `echo sheet-ran` now.\n")
        vim.cmd.edit(vim.fn.fnameescape(file))
        vim.api.nvim_win_set_cursor(0, { 3, 24 })
        _G.SPLIT_TEXT = function()
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local b = vim.api.nvim_win_get_buf(w)
            if b ~= vim.fn.bufnr(file) then
              local text = table.concat(vim.api.nvim_buf_get_lines(b, 0, -1, false), "\n")
              if text:find("sheet-ran", 1, true) then
                return text
              end
            end
          end
          return ""
        end
      ]],
      note = "a Markdown note with a shell command in backticks, the cursor inside it",
    },
    { keys = ":Execute! split --yes --from=backtick --as=shell<CR>" },
    {
      wait = "SPLIT_TEXT() ~= ''",
      timeout = 20000,
      note = "the shell ran and its output is in a split",
    },
    {
      lua = [[
        vim.api.nvim_set_current_win(vim.fn.bufwinid(FILE))
        vim.cmd("only!")
        vim.api.nvim_win_set_cursor(0, { 3, 24 })
      ]],
      note = "back in the note, the cursor in the backticks again",
    },
    { keys = ":Execute! result --yes --from=backtick --as=shell<CR>" },
    {
      wait = "table.concat(COPIED('+') or {}, '\\n'):find('sheet-ran', 1, true) ~= nil",
      timeout = 20000,
      note = "result: the output of the command is in the + register",
    },
    { expect = "H.heard('Copied')", note = "it says that it copied" },
    { expect = "H.no_errors()", note = "no error message on the way" },
  },
  judge = {
    "The split shows the output of the command and nothing of the shell's own noise",
  },
  manual = {
    "Once in a real session: <leader>X on a `code` span asks before it runs; [R]un shows the output as a message",
  },
}
