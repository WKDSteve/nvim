---@module 'bindings.usrcmds.wkdbook_picker'
--- `:WKDBook [private|tricentis]`: pick a note of a WKDBook repository. Without an argument the book of this machine:
--- the Tricentis one on the workstation, the private one elsewhere. The markdown files of the checkout go through
--- snacks.picker; without it through `vim.ui.select`.

local usercmd = require("lib.nvim.bindings.usercmd")
local notify = require("lib.nvim.notify").create("[wkdbook]")

local M = {}

---Folder names of the books below `$REPOS_DIR`.
---@type table<string, string>
M.BOOKS = { private = "WKDBooks", tricentis = "WKDBook-Tricentis" }

---Files `vim.ui.select` is given at most: a list of everything is no help beyond that.
local MAX_SELECT = 2000

---The folder of a book.
---@param name string|nil A key of `M.BOOKS`; nil: the book of this machine
---@param role string `machine.role()`
---@param repos string|nil `$REPOS_DIR`
---@return string|nil root
---@return string|nil err
function M.root(name, role, repos)
  if not repos or repos == "" then
    return nil, "$REPOS_DIR is not set"
  end
  local key = name or (role == "workstation" and "tricentis" or "private")
  local folder = M.BOOKS[key]
  if not folder then
    return nil, ("unknown book %q (private, tricentis)"):format(key)
  end
  return vim.fs.joinpath(repos, folder)
end

---Without snacks.picker: every markdown file below `root`, in a plain list.
---@param root string
local function select_note(root)
  local files = vim.fs.find(function(name)
    return name:match("%.md$") ~= nil
  end, { path = root, type = "file", limit = MAX_SELECT })
  vim.ui.select(files, {
    prompt = "WKDBook",
    format_item = function(path)
      return path:sub(#root + 2)
    end,
  }, function(path)
    if path then
      vim.cmd.edit(vim.fn.fnameescape(path))
    end
  end)
end

---@param name string|nil
function M.pick(name)
  local root, err = M.root(name, require("machine").role(), vim.env.REPOS_DIR)
  if not root then
    notify.error(tostring(err))
    return
  end
  if vim.fn.isdirectory(root) ~= 1 then
    notify.error("no checkout at " .. root)
    return
  end
  local snacks = rawget(_G, "Snacks")
  if snacks and snacks.picker and snacks.picker.files then
    snacks.picker.files({ cwd = root, ft = "md", title = "WKDBook" })
  else
    select_note(root)
  end
end

function M.enable()
  usercmd.create("WKDBook", function(args)
    M.pick(args.fargs[1])
  end, {
    nargs = "?",
    desc = "Pick a note of a WKDBook repository (private, tricentis; default: the book of this machine)",
    complete = function()
      return vim.tbl_keys(M.BOOKS)
    end,
  })
end

return M
