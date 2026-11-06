-- TESTS/wkdbook_picker/wkdbook_picker_spec.lua -- :WKDBook: which book, and which picker.

---@param H table
local function spec(H)
  local eq, ok = H.eq, H.ok
  local picker = require("bindings.usrcmds.wkdbook_picker")

  eq(picker.root(nil, "default", "E:/r"), "E:/r/WKDBooks", "the private book by default")
  eq(
    picker.root(nil, "workstation", "E:/r"),
    "E:/r/WKDBook-Tricentis",
    "the workstation has its own"
  )
  eq(picker.root("private", "workstation", "E:/r"), "E:/r/WKDBooks", "an argument wins")
  local none, err = picker.root("other", "default", "E:/r")
  eq(none, nil, "an unknown book is refused")
  ok(err:find("other", 1, true), "and named")
  none, err = picker.root(nil, "default", nil)
  eq(none, nil, "without $REPOS_DIR nothing")
  ok(err:find("REPOS_DIR", 1, true), "and says so")

  local base = H.tmpdir()
  H.write(base .. "/WKDBooks/a/note.md", "# n")
  H.write(base .. "/WKDBooks/a/data.txt", "x")
  local saved_env, saved_snacks, saved_select =
    vim.env.REPOS_DIR, rawget(_G, "Snacks"), vim.ui.select
  vim.env.REPOS_DIR = base
  local run_ok, run_err = pcall(function()
    local seen
    rawset(_G, "Snacks", {
      picker = {
        files = function(o)
          seen = o
        end,
      },
    })
    picker.pick("private")
    eq(seen and seen.cwd, vim.fs.joinpath(base, "WKDBooks"), "snacks gets the checkout")
    eq(seen and seen.ft, "md", "and only notes")

    rawset(_G, "Snacks", nil)
    local listed
    vim.ui.select = function(items, opts, _)
      listed = vim.tbl_map(opts.format_item, items)
    end
    picker.pick("private")
    eq(listed, { "a/note.md" }, "without snacks a list of the notes, relative to the book")
  end)
  vim.env.REPOS_DIR = saved_env
  rawset(_G, "Snacks", saved_snacks)
  vim.ui.select = saved_select
  if not run_ok then
    error(run_err, 0)
  end
end

return spec
