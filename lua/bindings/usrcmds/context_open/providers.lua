---@module 'bindings.usrcmds.context_open.providers'
--- Cursor-context providers for `context_open.open()` (M-o / :ContextOpen).
--- Each provider is `fun(signals: OpenNvim.Signals): ContextOpen.Candidate[]`
--- -- read-only detection, zero to many candidates, never throws (callers
--- pcall it anyway as a second line of defence).
---@see bindings.usrcmds.context_open.README for the full design rationale.

local util = require("bindings.usrcmds.context_open.util")

local M = {}

---@class ContextOpen.Candidate
---@field label string
---@field lnum? integer
---@field col? integer
---@field run fun()

-- ---------------------------------------------------------------------------
-- open.nvim -- browser / filemanager / notepad / split / vsplit / tab / …
-- ---------------------------------------------------------------------------

---Whether open.nvim's own signals contain anything for it to work with.
---Deliberately excludes the "nothing found, fall back to reveal-buffer-in-
---filemanager" case: that catch-all isn't really "something under the
---cursor", and treating it as a candidate would make `#candidates > 0`
---always true, permanently disabling the line-search fallback below.
---@internal
---@param signals table
---@return boolean
local function has_open_target(signals)
  if signals.tree_path then
    return true
  end
  if signals.cfile and signals.cfile ~= "" then
    return true
  end
  if signals.cword and signals.cword ~= "" then
    return true
  end
  return false
end

---media.nvim, if it is installed: `nil` otherwise. It is `VeryLazy` in this
---config, so by the time a key can fire it is loaded or not there at all.
---@internal
---@return table|nil
local function media_module()
  local ok, media = pcall(require, "media")
  if ok and type(media) == "table" and type(media.is_media) == "function" then
    return media
  end
  return nil
end

---Extensions a more specific provider already owns (images.nvim, pdfport.nvim,
---media.nvim): open.nvim's generic split/vsplit/tab candidates for these would
---just load raw image/PDF/video bytes into a text buffer, which nobody wants.
---@internal
---@param path string|nil
---@return boolean
local function owned_extension(path)
  if not path then
    return false
  end
  local ext = path:match("%.([%w]+)$")
  if not ext then
    return false
  end
  ext = ext:lower()
  if ext == "pdf" then
    return true
  end
  local media = media_module()
  if media and media.is_media(path) then
    return true
  end
  local ok, images_cfg = pcall(function()
    return require("images.config").get()
  end)
  if ok and images_cfg.extensions then
    for _, e in ipairs(images_cfg.extensions) do
      if e:lower() == ext then
        return true
      end
    end
  end
  return false
end

---@param signals table
---@return ContextOpen.Candidate[]
function M.open_nvim(signals)
  if not has_open_target(signals) then
    return {}
  end

  util.ensure_loaded("open.nvim")
  local ok_ctx, context = pcall(require, "open.context")
  local ok_reg, registry = pcall(require, "open.registry")
  if not (ok_ctx and ok_reg) then
    return {}
  end

  if owned_extension(signals.cfile_path) then
    return {}
  end

  local out = {}
  for _, key in ipairs(context.candidate_targets(signals)) do
    local handler = registry.get(key)
    if handler then
      out[#out + 1] = {
        label = ("open: %s — %s"):format(key, handler.desc),
        run = function()
          local ctx = context.resolve(nil, key, signals)
          if ctx then
            registry.dispatch(key, ctx)
          end
        end,
      }
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- gopath.nvim -- gF equivalent
-- ---------------------------------------------------------------------------

---@param _signals table
---@return ContextOpen.Candidate[]
function M.gopath(_signals)
  local ok, gopath = pcall(require, "gopath")
  if not ok then
    return {}
  end

  local res = gopath.resolve()
  if not res then
    return {}
  end

  local what = res.path or res.subject or "target"
  return {
    {
      label = ("gopath: open %s (%s)"):format(what, res.kind or "?"),
      run = function()
        gopath.commands.goto_at_cursor("edit")
      end,
    },
  }
end

-- ---------------------------------------------------------------------------
-- markdown.nvim -- TableView toggle
-- ---------------------------------------------------------------------------

---@param _signals table
---@return ContextOpen.Candidate[]
function M.markdown_table(_signals)
  local ft = vim.bo.filetype
  if ft ~= "markdown" and ft ~= "mdx" and ft ~= "md" then
    return {}
  end
  if vim.fn.exists(":TableViewToggle") ~= 2 then
    return {}
  end

  local ok, parser = pcall(require, "markdown.tableview.parser")
  if not ok then
    return {}
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  for _, tbl in ipairs(parser.get_tables(0)) do
    if line >= tbl.start_line and line <= tbl.end_line then
      return {
        {
          label = "markdown: toggle table view",
          run = function()
            vim.cmd("TableViewToggle")
          end,
        },
      }
    end
  end
  return {}
end

-- ---------------------------------------------------------------------------
-- images.nvim -- show image under cursor
-- ---------------------------------------------------------------------------

---@param _signals table
---@return ContextOpen.Candidate[]
function M.images(_signals)
  local ok, resolve = pcall(require, "images.resolve")
  if not ok then
    return {}
  end

  local target = resolve.under_cursor()
  if not target then
    return {}
  end

  return {
    {
      label = "images: show image",
      run = function()
        require("images").hover()
      end,
    },
  }
end

-- ---------------------------------------------------------------------------
-- pdfport.nvim -- PDF under cursor: system viewer, or extract to buffer
-- ---------------------------------------------------------------------------

---The existing file under the cursor, as an absolute path. Pure filesystem
---check -- deliberately does NOT require any plugin's own modules, so
---detection works even before a cmd-only plugin has ever been loaded.
---@internal
---@param signals table
---@return string|nil abs
local function file_under_cursor(signals)
  local candidate = signals.cfile_path or signals.cfile
  if not candidate or candidate == "" then
    return nil
  end
  -- `expand_path`, not `vim.fn.expand()`: this string is whatever happens to
  -- sit under the cursor in someone else's buffer. `vim.fn.expand()` is
  -- filename expansion, so a backtick span in it is a command substitution
  -- run through 'shell', and `%`/`#`/`<cfile>` are Vim specials that silently
  -- resolve to other paths. Only `~` and environment variables are wanted.
  local abs = vim.fn.fnamemodify(require("lib.nvim.cross.fs.expand_path")(candidate), ":p")
  local stat = vim.uv.fs_stat(abs)
  if stat and stat.type == "file" then
    return abs
  end
  return nil
end

---@internal
---@param signals table
---@return string|nil abs
local function pdf_path_under_cursor(signals)
  local abs = file_under_cursor(signals)
  if abs and abs:lower():match("%.pdf$") then
    return abs
  end
  return nil
end

---@param signals table
---@return ContextOpen.Candidate[]
function M.pdfport(signals)
  local path = pdf_path_under_cursor(signals)
  if not path then
    return {}
  end

  return {
    {
      label = "open: default — system PDF viewer",
      run = function()
        util.ensure_loaded("open.nvim")
        local ok_ctx, context = pcall(require, "open.context")
        local ok_reg, registry = pcall(require, "open.registry")
        if not (ok_ctx and ok_reg) then
          return
        end
        local ctx = context.resolve("path=" .. path, "default")
        if ctx then
          registry.dispatch("default", ctx)
        end
      end,
    },
    {
      label = "pdfport: extract text to buffer",
      run = function()
        vim.cmd("PdfPort text " .. vim.fn.fnameescape(path))
      end,
    },
  }
end

-- ---------------------------------------------------------------------------
-- media.nvim -- play a video/audio file in a real player
-- ---------------------------------------------------------------------------

---@param signals table
---@return ContextOpen.Candidate[]
function M.media(signals)
  local media = media_module()
  if not media then
    return {}
  end
  local path = file_under_cursor(signals)
  if not path or not media.is_media(path) then
    return {}
  end
  return {
    {
      label = ("media: play %s"):format(vim.fn.fnamemodify(path, ":t")),
      run = function()
        local ok, err = media.play(path)
        if not ok then
          vim.notify(("media: cannot play %s: %s"):format(path, tostring(err)), vim.log.levels.WARN)
        end
      end,
    },
  }
end

-- ---------------------------------------------------------------------------
-- hover.nvim -- preview float for targets nothing else here can show
-- ---------------------------------------------------------------------------

---hover.nvim target types offered here: the ones it can *show* and no other
---provider covers. `image`/`pdf`/`markdown` are left out on purpose -- images,
---pdfport and gopath already answer for them, and a second candidate would
---only turn a one-key open into a chooser.
local HOVER_FILE_KINDS = { office = true, video = true }

---Detection stays cheap and never asks hover.nvim to resolve anything: the
---forced `hover.target_under_cursor` would run gopath's full pipeline (an LSP
---round-trip in this config) and a `git` start on every `M-o`. Instead:
---  * an existing file whose extension hover classifies as office/video;
---  * an http(s) URL whose path ends in `.pdf` (a "web PDF": hover only knows
---    for sure after fetching, so a plain URL stays the browser's alone), and
---    only while hover.nvim is allowed to fetch at all;
---  * a hex run shaped like a git object id (hover confirms it on `run`).
---@param signals table
---@return ContextOpen.Candidate[]
function M.hover(signals)
  local ok_hover, hover = pcall(require, "hover")
  local ok_classify, classify = pcall(require, "hover.classify")
  if not (ok_hover and ok_classify and type(hover.show) == "function") then
    return {}
  end

  local what
  local path = file_under_cursor(signals)
  if path then
    local ext = path:match("%.([%w]+)$")
    local kind = classify.kind_for_ext(ext and ext:lower() or nil)
    if HOVER_FILE_KINDS[kind] then
      what = kind
    end
  end

  -- A web PDF needs hover.nvim to download it, and `show({ force = true })`
  -- deliberately does not open that gate (`links.fetch`, off by default).
  local ok_cfg, hover_config = pcall(require, "hover.config")
  local can_fetch = ok_cfg
    and type(hover_config.fetch_enabled) == "function"
    and hover_config.fetch_enabled()
  if not what and can_fetch then
    for _, s in ipairs({ signals.cfile, signals.cword }) do
      if type(s) == "string" and s:match("^https?://") then
        local url_path = s:gsub("[?#].*$", "")
        if url_path:lower():match("%.pdf$") then
          what = "web PDF"
          break
        end
      end
    end
  end

  if not what then
    local ok_git, bare_git = pcall(require, "hover.bare_git")
    if ok_git and type(bare_git.hex_run_at) == "function" then
      local pos = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()
      if bare_git.hex_run_at(line, pos[2]) then
        what = "git object"
      end
    end
  end

  if not what then
    return {}
  end
  return {
    {
      label = ("hover: preview (%s)"):format(what),
      run = function()
        hover.show({ force = true })
      end,
    },
  }
end

-- ---------------------------------------------------------------------------
-- mdview.nvim -- render a Markdown target in the browser
-- ---------------------------------------------------------------------------

local MARKDOWN_EXT = { md = true, markdown = true, mdx = true }

---`require("mdview").open()` only previews the *current* buffer and only when
---a session already runs, so the candidate opens the target first and then
---runs `:MDView start` -- which starts the session when there is none and
---re-opens the preview for the current buffer when there is one.
---@param signals table
---@return ContextOpen.Candidate[]
function M.mdview(signals)
  if vim.fn.exists(":MDView") ~= 2 then
    return {}
  end
  local path = file_under_cursor(signals)
  if not path then
    return {}
  end
  local ext = path:match("%.([%w]+)$")
  if not (ext and MARKDOWN_EXT[ext:lower()]) then
    return {}
  end
  return {
    {
      label = ("mdview: render %s in the browser"):format(vim.fn.fnamemodify(path, ":t")),
      run = function()
        vim.cmd.edit(vim.fn.fnameescape(path))
        vim.cmd("MDView start")
      end,
    },
  }
end

-- ---------------------------------------------------------------------------
-- Aggregation
-- ---------------------------------------------------------------------------

--- Deliberate, fixed order -- also the ambiguity picker's display order.
--- gopath and the file-type-specific providers (markdown/images/pdfport/
--- media/hover/mdview) come before open.nvim's generic candidates, so a
--- specific match outranks "reveal in file manager" at a glance.
M.ORDER = {
  M.gopath,
  M.markdown_table,
  M.images,
  M.pdfport,
  M.media,
  M.hover,
  M.mdview,
  M.open_nvim,
}

---Run every provider against `signals`, concatenating their candidates.
---@param signals table
---@return ContextOpen.Candidate[]
function M.collect(signals)
  local out = {}
  for _, provider in ipairs(M.ORDER) do
    local ok, candidates = pcall(provider, signals)
    if ok and candidates then
      for _, c in ipairs(candidates) do
        out[#out + 1] = c
      end
    end
  end
  return out
end

return M
