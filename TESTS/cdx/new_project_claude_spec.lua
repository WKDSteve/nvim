-- TESTS/cdx/new_project_claude_spec.lua -- docs/NOTES/CDX/new-project-claude.js offers only real stacks.
--
-- A stack is a folder of templates/ with a CLAUDE.md; templates/PROMPT holds the prompt templates and must never be
-- copied into a repo as if it were one.

return function(H)
  local ok, has, lacks = H.ok, H.has, H.lacks

  if vim.fn.executable("node") ~= 1 then
    print("n/a  node missing")
    return
  end

  local spec = debug.getinfo(1, "S").source:sub(2)
  local root =
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(spec, ":p")))))
  local js = root .. "/docs/NOTES/CDX/new-project-claude.js"

  -- without a stack: the usage line lists the stacks
  local usage = vim.system({ "node", js }, { text = true }):wait()
  ok(usage.code == 1, "no stack: exit 1")
  has(usage.stderr, "nvim-plugin", "the usage lists a real stack")
  lacks(usage.stderr, "PROMPT", "the prompt folder is no stack")

  -- PROMPT as a stack is refused and copies nothing
  local target = H.tmpdir()
  local refused = vim.system({ "node", js, "PROMPT", target }, { text = true }):wait()
  ok(refused.code == 1, "PROMPT is refused")
  ok(not H.exists(target .. "/Base.md"), "nothing was copied")

  -- a real stack still works
  local done = vim.system({ "node", js, "rust", target }, { text = true }):wait()
  ok(done.code == 0, "rust is a stack: " .. (done.stderr or ""))
  ok(H.exists(target .. "/CLAUDE.md"), "its CLAUDE.md was copied")
end
