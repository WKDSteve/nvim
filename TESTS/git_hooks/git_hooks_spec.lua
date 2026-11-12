-- TESTS/git_hooks/git_hooks_spec.lua -- :MyGit hooks: hook state, install plan and a real install.sh run.

---@param H table
local function spec(H)
  local eq, ok = H.eq, H.ok
  local hooks = require("bindings.usrcmds.git_hooks")

  -- classify: marker present = ours, other content = foreign, no file = missing
  eq(hooks.classify(nil, "# large-files-hook"), "missing", "no file is missing")
  eq(
    hooks.classify("#!/bin/sh\n# large-files-hook\n", "# large-files-hook"),
    "ok",
    "marker means ours"
  )
  eq(
    hooks.classify("#!/bin/sh\necho hi\n", "# large-files-hook"),
    "foreign",
    "other content is foreign"
  )

  -- the manual-push repos expect pre-push as well, the others do not
  local function names(list)
    return vim.tbl_map(function(h)
      return h.name
    end, list)
  end
  eq(names(hooks.expected("lib.nvim")), { "pre-commit", "commit-msg" }, "plain repo")
  eq(
    names(hooks.expected("tricentis-vault")),
    { "pre-commit", "commit-msg", "pre-push" },
    "manual-push repo"
  )

  -- repo_state summary
  local function files(map)
    return function(hook)
      return map[hook]
    end
  end
  eq(hooks.repo_state("lib.nvim", files({})), "missing", "nothing installed")
  eq(
    hooks.repo_state("lib.nvim", files({ ["pre-commit"] = "# large-files-hook" })),
    "partial",
    "one of two"
  )
  eq(
    hooks.repo_state(
      "lib.nvim",
      files({ ["pre-commit"] = "# large-files-hook", ["commit-msg"] = "# no-claude-trailer-hook" })
    ),
    "ok",
    "both installed"
  )
  eq(
    hooks.repo_state("lib.nvim", files({ ["pre-commit"] = "echo mine" })),
    "foreign",
    "a foreign hook wins over the rest"
  )

  -- plan: manual-push repos get a second call with --manual-push-only
  local calls = hooks.plan_calls("bash", "install.sh", "B", { "lib.nvim", "tricentis-vault" })
  eq(#calls, 2, "two install.sh calls")
  eq(calls[1], { "bash", "install.sh", "B/lib.nvim", "B/tricentis-vault" }, "default call")
  eq(
    calls[2],
    { "bash", "install.sh", "--manual-push-only", "B/tricentis-vault" },
    "manual-push call"
  )
  eq(
    #hooks.plan_calls("bash", "install.sh", "B", { "lib.nvim" }),
    1,
    "no second call without a manual repo"
  )

  -- repos(): only folders with a .git
  local base = H.tmpdir()
  vim.fn.mkdir(base .. "/with-git/.git", "p")
  vim.fn.mkdir(base .. "/plain", "p")
  eq(hooks.repos(base), { "with-git" }, "repos lists git folders only")

  -- real install.sh through the same bash the command uses
  local bash = require("lib.nvim.cross.bash").find()
  if not bash or vim.fn.executable("git") ~= 1 then
    print("n/a  no bash or git: skipping the real install.sh run")
    return
  end
  local repo = base .. "/real"
  vim.fn.mkdir(repo, "p")
  vim.system({ "git", "-C", repo, "init", "-q" }):wait()
  -- Like the machines that ran setup-claude-code.ps1: a global core.hooksPath at a shared folder. The hooks must
  -- land in the repo's own .git/hooks and leave that shared folder alone. The real global config is hidden.
  local shared = base .. "/shared-hooks"
  vim.fn.mkdir(shared, "p")
  H.write(base .. "/gitconfig", "[core]\n\thooksPath = " .. shared .. "\n")
  vim.env.GIT_CONFIG_GLOBAL = base .. "/gitconfig"
  local done, result
  vim.env.REPOS_DIR = base
  hooks.install({ "real" }, function(installed, problems)
    done, result = true, { installed = installed, problems = problems }
  end)
  ok(
    vim.wait(20000, function()
      return done
    end, 50),
    "install finished"
  )
  eq(result.problems, {}, "no problems on a fresh repo")
  eq(result.installed, 2, "pre-commit and commit-msg installed")
  local state = hooks.repo_state("real", function(hook)
    return H.read(repo .. "/.git/hooks/" .. hook)
  end)
  eq(state, "ok", "the repo reads as ok afterwards")
  eq(vim.fn.glob(shared .. "/*", false, true), {}, "the shared hooksPath folder is left alone")
  vim.env.GIT_CONFIG_GLOBAL = nil
end

return spec
