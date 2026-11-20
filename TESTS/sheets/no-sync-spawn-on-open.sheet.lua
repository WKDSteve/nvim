-- Live check: opening a Lua file on the installed config (LuaLS attaches, lensline draws its lens) starts no
-- process synchronously on the main thread. Found 2026-11-18 (report ALL/ROADMAP/reports/2026-11-18_performance-
-- hungrige-prozesse.md in the vault): lensline's last_author ran `git blame` of the whole file through
-- vim.fn.systemlist on every attach (196-441 ms frozen UI per file) and `git check-ignore` through vim.fn.system
-- (55-70 ms). lsp.nvim turned both off (7bad357, 9bc7f66); this sheet keeps every plugin of the config to that.
-- Counted: vim.fn.system, vim.fn.systemlist and vim.system(...):wait() while the file opens and the LSP settles.
return {
  id = "nvim-config.no-sync-spawn-on-open",
  title = "nvim-config: opening a Lua file starts no process synchronously (LuaLS, lensline, gitsigns, ...)",
  task = "nvim-config/abnahme-dateien-oeffnen-ohne-sync-spawn",
  config = "user",
  sizes = { { rows = 30, cols = 120 } },
  steps = {
    { wait = "package.loaded['lazy'] ~= nil", timeout = 10000, note = "the config is up" },
    {
      -- Loaded as a chunk without a file name: runtime to `testing perf`'s trace, so a start through these
      -- wrappers keeps the plugin that asked for it as its caller (a step's own chunk would make every start the
      -- sheet's preparation).
      lua = [==[
        assert(load([[
        _G.__sync = {}
        local uv = vim.uv
        local function rec(kind, cmd, t0)
          table.insert(_G.__sync, {
            kind = kind,
            ms = (uv.hrtime() - t0) / 1e6,
            cmd = type(cmd) == "table" and table.concat(cmd, " ") or tostring(cmd),
            src = debug.getinfo(3, "S").short_src,
          })
        end
        for _, name in ipairs({ "system", "systemlist" }) do
          local orig = vim.fn[name]
          vim.fn[name] = function(cmd, ...)
            local t0 = uv.hrtime()
            local r = orig(cmd, ...)
            rec("fn." .. name, cmd, t0)
            return r
          end
        end
        local orig_system = vim.system
        vim.system = function(cmd, opts, on_exit)
          local obj = orig_system(cmd, opts, on_exit)
          local orig_wait = obj.wait
          obj.wait = function(self, ...)
            local t0 = uv.hrtime()
            local r = orig_wait(self, ...)
            rec("vim.system:wait", cmd, t0)
            return r
          end
          return obj
        end
        -- A line inside a function, so lensline (render = "focused") has a function to draw for.
        _G.__file = vim.fn.stdpath("config") .. "/lua/bindings/autocmds/git/blame_on_hold.lua"
        -- The lens data lensline computed for this buffer. Its focused mode draws with ephemeral extmarks
        -- (a decoration provider during redraw), which nvim_buf_get_extmarks never sees, so the check
        -- reads lensline's own per-provider store instead.
        _G.__lens_data = function()
          local ok, r = pcall(require, "lensline.renderer")
          return ok and r.provider_lens_data and r.provider_lens_data[vim.api.nvim_get_current_buf()] or nil
        end
        _G.__lens = function()
          local d = _G.__lens_data()
          return d ~= nil and d.usages ~= nil and #d.usages > 0
        end
        _G.__report = function()
          local out = {}
          for _, s in ipairs(_G.__sync) do
            out[#out + 1] = ("%s %.0f ms %s (%s)"):format(s.kind, s.ms, s.cmd, s.src)
          end
          return table.concat(out, "\n")
        end
        ]], "=no_sync_probe"))()
      ]==],
      note = "count synchronous process calls from here on",
    },
    {
      lua = "vim.cmd.edit(vim.fn.fnameescape(_G.__file)); vim.api.nvim_win_set_cursor(0, { 28, 4 })",
    },
    {
      wait = "#vim.lsp.get_clients({ bufnr = 0 }) > 0",
      timeout = 60000,
      note = "an LSP client attaches",
    },
    {
      wait = "_G.__lens()",
      timeout = 60000,
      note = "lensline computed its usages lens for the buffer",
    },
    {
      expect = "_G.__lens_data().last_author == nil",
      note = "last_author stays off (its git blame ran synchronously)",
    },
    { steady = 2000, timeout = 30000 },
    {
      measure = "#_G.__sync",
      name = "synchronous process calls while opening",
      max = 0,
      note = "no plugin starts a process synchronously (see _G.__report() in the child for which)",
    },
    { expect = "not vim.fn.execute('messages'):find('E%d+:')", note = "no error message" },
  },
  judge = {
    "The lens over the function reads well (reference count, no author line) and appeared without a noticeable delay",
  },
  manual = {
    "Open three files of different repos in a real session: none of them freezes noticeably while it opens",
  },
}
