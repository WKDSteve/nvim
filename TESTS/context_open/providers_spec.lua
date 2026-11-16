-- TESTS/context_open/providers_spec.lua -- the media, hover and mdview providers of
-- `context_open` (M-o), against fake plugin modules in package.loaded: which targets
-- each one claims, what its candidate runs, and that open.nvim's split/vsplit/tab
-- candidates go away for a media file like they do for a PDF.

return function(H)
  local eq, ok = H.eq, H.ok

  local dir = H.tmpdir()
  local video = dir .. "/clip.mp4"
  local sheet = dir .. "/budget.xlsx"
  local notes = dir .. "/notes.md"
  local text = dir .. "/plain.txt"
  for _, p in ipairs({ video, sheet, notes, text }) do
    H.write(p, "x")
  end

  local saved = {}
  local function fake(name, mod)
    saved[name] = saved[name] or { package.loaded[name] }
    package.loaded[name] = mod
  end

  local played, shown = {}, 0
  fake("media", {
    is_media = function(p)
      return p ~= nil and (p:lower():match("%.mp4$") or p:lower():match("%.mp3$")) ~= nil
    end,
    play = function(p)
      played[#played + 1] = p
      return true
    end,
  })
  local fetch = false
  fake("hover", {
    show = function(opts)
      ok(opts and opts.force, "hover.show is forced")
      shown = shown + 1
      return true
    end,
  })
  fake("hover.config", {
    fetch_enabled = function()
      return fetch
    end,
  })
  fake("hover.classify", {
    kind_for_ext = function(ext)
      return ({ xlsx = "office", mp4 = "video", pdf = "pdf", md = "markdown" })[ext] or "file"
    end,
  })
  fake("hover.bare_git", {
    hex_run_at = function(line, col)
      local s, e = line:find("%f[%w]%x%x%x%x%x%x%x+%f[%W]")
      if s and col + 1 >= s and col + 1 <= e then
        return line:sub(s, e)
      end
    end,
  })

  local ok_run, err = pcall(function()
    local P = package.loaded["bindings.usrcmds.context_open.providers"]
      or require("bindings.usrcmds.context_open.providers")

    local function labels(list)
      return vim.tbl_map(function(c)
        return c.label
      end, list)
    end

    -- media: a video file under the cursor is played; nothing else is claimed.
    local got = P.media({ cfile = video, cfile_path = video })
    eq(labels(got), { "media: play clip.mp4" }, "media offers to play a video")
    got[1].run()
    eq(#played, 1, "the candidate calls media.play")
    ok(played[1]:find("clip.mp4", 1, true), "with the file under the cursor")
    eq(P.media({ cfile = text, cfile_path = text }), {}, "a text file is not media")
    eq(P.media({ cfile = dir .. "/gone.mp4" }), {}, "a missing file is not offered")

    -- media in the aggregate: it stands in the order, before open.nvim.
    local pos_media, pos_open
    for i, p in ipairs(P.ORDER) do
      if p == P.media then
        pos_media = i
      elseif p == P.open_nvim then
        pos_open = i
      end
    end
    ok(pos_media and pos_open and pos_media < pos_open, "media runs before open_nvim")

    -- open.nvim stays out of a media file (no split/vsplit/tab of video bytes).
    fake("open.context", {
      candidate_targets = function()
        return { "split", "vsplit" }
      end,
      resolve = function() end,
    })
    fake("open.registry", {
      get = function(key)
        return { desc = key }
      end,
      dispatch = function() end,
    })
    eq(
      P.open_nvim({ cfile = video, cfile_path = video }),
      {},
      "open_nvim leaves a media file alone"
    )
    eq(#P.open_nvim({ cfile = text, cfile_path = text }), 2, "open_nvim still offers a text file")

    -- hover: office and video files, a web PDF only while fetching is allowed, a git id.
    eq(
      labels(P.hover({ cfile = sheet, cfile_path = sheet })),
      { "hover: preview (office)" },
      "office file"
    )
    eq(
      labels(P.hover({ cfile = video, cfile_path = video })),
      { "hover: preview (video)" },
      "video file"
    )
    eq(
      P.hover({ cfile = notes, cfile_path = notes }),
      {},
      "markdown is gopath's/mdview's, not hover's"
    )
    eq(P.hover({ cfile = text, cfile_path = text }), {}, "a plain file has no hover candidate")
    local url = "https://example.com/files/report.PDF?dl=1"
    eq(P.hover({ cfile = url }), {}, "a web PDF is not offered while hover may not fetch")
    fetch = true
    eq(
      labels(P.hover({ cfile = url })),
      { "hover: preview (web PDF)" },
      "a web PDF with fetching on"
    )
    eq(P.hover({ cfile = "https://example.com/page" }), {}, "a plain URL stays the browser's")
    fetch = false

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "fixed in 3eda4bcaf today" })
    vim.api.nvim_win_set_cursor(0, { 1, 11 })
    got = P.hover({ cword = "3eda4bcaf" })
    eq(labels(got), { "hover: preview (git object)" }, "a git object id under the cursor")
    got[1].run()
    eq(shown, 1, "the candidate calls hover.show")
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    eq(P.hover({ cword = "fixed" }), {}, "an ordinary word is not a git id")

    -- mdview: an existing Markdown file, only when :MDView exists.
    eq(P.mdview({ cfile = notes, cfile_path = notes }), {}, "no :MDView, no candidate")
    local started = 0
    vim.api.nvim_create_user_command("MDView", function(o)
      eq(o.args, "start", ":MDView start")
      started = started + 1
    end, { nargs = "*" })
    got = P.mdview({ cfile = notes, cfile_path = notes })
    eq(labels(got), { "mdview: render notes.md in the browser" }, "a Markdown target")
    eq(P.mdview({ cfile = text, cfile_path = text }), {}, "a text file is not Markdown")
    got[1].run()
    eq(started, 1, "the candidate runs :MDView start")
    eq(
      vim.fs.normalize(vim.api.nvim_buf_get_name(0)),
      vim.fs.normalize(vim.fn.fnamemodify(notes, ":p")),
      "after opening the target"
    )
    vim.api.nvim_del_user_command("MDView")
    vim.cmd("silent! %bwipeout!")

    -- Without the plugins nothing is offered and nothing throws.
    for name in pairs(saved) do
      package.loaded[name] = nil
    end
    package.preload["media"] = function()
      error("not installed")
    end
    eq(P.media({ cfile = video, cfile_path = video }), {}, "no media.nvim, no media candidate")
    package.preload["media"] = nil
  end)

  for name, v in pairs(saved) do
    package.loaded[name] = v[1]
  end
  if not ok_run then
    error(err, 0)
  end
end
