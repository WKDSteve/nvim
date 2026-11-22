-- TESTS/sheets/fixtures/helpers.lua -- the preparation the process feature sheets share: temp folders, fixture git
-- repositories and what the config said.
--
-- A sheet loads it with `dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/helpers.lua")` and keeps the table in
-- `_G.H`: starts from this file (the git calls that build a fixture) are the sheet's preparation for `testing perf`,
-- never the config's.
local H = {}

---A fresh folder below the child's temp folder (forward slashes).
---@return string
function H.tmpdir()
  local d = vim.fs.normalize(vim.fn.tempname())
  vim.fn.mkdir(d, "p")
  return d
end

---@param path string
---@param text string
function H.write(path, text)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local f = assert(io.open(path, "wb"))
  f:write(text)
  f:close()
end

---Run git in `dir`; raises with its output when it fails.
---@param dir string
---@param args string[]
---@return string stdout
function H.git(dir, args)
  local argv = { "git", "-C", dir, "-c", "user.name=sheet", "-c", "user.email=sheet@example.test" }
  argv[#argv + 1] = "-c"
  argv[#argv + 1] = "commit.gpgsign=false"
  vim.list_extend(argv, args)
  local res = vim.system(argv, { text = true }):wait(30000)
  assert(res.code == 0, table.concat(argv, " ") .. ": " .. (res.stderr or "") .. (res.stdout or ""))
  return res.stdout or ""
end

---A repository at `dir` with one commit of `files` (path -> text, default a README).
---@param dir string
---@param files? table<string, string>
---@return string dir
function H.repo(dir, files)
  vim.fn.mkdir(dir, "p")
  H.git(dir, { "init", "-q", "-b", "main" })
  for path, text in pairs(files or { ["README.md"] = "fixture\n" }) do
    H.write(dir .. "/" .. path, text)
  end
  H.git(dir, { "add", "-A" })
  H.git(dir, { "commit", "-q", "-m", "fixture" })
  return dir
end

---A bare `origin` for `dir` that is one commit ahead of it (`dir` tracks `origin/main`): a fetch finds a new commit,
---a fast-forward pull takes it. Returns the path of the bare repository.
---@param dir string
---@return string bare
function H.remote_ahead(dir)
  local bare = dir .. ".origin.git"
  H.git(vim.fs.dirname(dir), { "clone", "-q", "--bare", dir, bare })
  H.git(dir, { "remote", "add", "origin", bare })
  H.git(dir, { "fetch", "-q", "origin" })
  H.git(dir, { "branch", "-q", "--set-upstream-to=origin/main", "main" })
  local other = dir .. ".other"
  H.git(vim.fs.dirname(dir), { "clone", "-q", bare, other })
  H.write(other .. "/NEW.md", "from the remote\n")
  H.git(other, { "add", "NEW.md" })
  H.git(other, { "commit", "-q", "-m", "remote commit" })
  H.git(other, { "push", "-q", "origin", "main" })
  return bare
end

---Did the config say `text`? This config shows lib.nvim's messages as popups (not in :messages); their history has
---them, and vim.notify's when popups are off.
---@param text string
---@return boolean
function H.heard(text)
  local said = {}
  local ok, popup = pcall(require, "lib.nvim.notify.popup")
  for _, e in ipairs(ok and popup.history() or {}) do
    said[#said + 1] = tostring(e.message)
  end
  said[#said + 1] = vim.fn.execute("messages")
  return table.concat(said, " "):gsub("%s+", " "):find(text, 1, true) ~= nil
end

---The calls a stand-in recorded (`fakes` of the sheet).
---@param program string
---@return { argv: string[], cwd: string }[]
function H.calls(program)
  return require("testing.fake_programs").read(vim.env.TESTING_FAKES, program)
end

---Load a fixture chunk as runtime for `testing perf` (see stand_ins.lua) and call it with `...`.
---@param name string file below TESTS/sheets/fixtures, without .lua
---@return any
function H.runtime(name, ...)
  local path = vim.fn.getcwd() .. "/TESTS/sheets/fixtures/" .. name .. ".lua"
  local text = table.concat(vim.fn.readfile(path), "\n")
  return assert(load(text, "=" .. name))(...)
end

-- loaded with the helpers, while the cwd is still the project root: a sheet may `:cd` away (or the config's root
-- detection does when it opens a file) before its last step checks for errors
local errors = dofile(vim.fn.getcwd() .. "/TESTS/sheets/fixtures/errors.lua")

---No error message on the way (fixtures/errors.lua: `:messages`, noice's history and lib.nvim's popups).
---@param ignore? string[] texts of errors the sheet raises on purpose
---@return boolean
function H.no_errors(ignore)
  return errors.none(ignore)
end

return H
