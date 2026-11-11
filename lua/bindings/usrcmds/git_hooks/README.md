# `:MyGit hooks`

Installs the git hooks of [`scripts/git-hooks/`](../../../../scripts/git-hooks) into the repos under `$REPOS_DIR`. It is
a front end for `install.sh`, which stays the one place that knows what a hook looks like (it also works without nvim:
`bash scripts/git-hooks/install.sh <repo> ...`).

```vim
:MyGit hooks               " pick the repos: <Tab> marks, <CR> installs (no mark = the row under the cursor)
:MyGit hooks all           " every repo under $REPOS_DIR that has a .git
:MyGit hooks status        " state of every repo, changes nothing
:MyGit hooks repo <name>   " one repo
```

The list uses `lib.nvim.ui.kit.select` (multi-select). Each row shows the state of that repo's hooks:

| State | Meaning |
|---|---|
| `ok` | all expected hooks are ours (marker line found) |
| `partial` | some of them are installed |
| `missing` | none is installed |
| `foreign` | a hook of that name exists that is not ours; it is never overwritten (`install.sh` reports it) |

What a repo is expected to have: `pre-commit` (large files) and `commit-msg` (no Claude trailer) everywhere, plus the
manual-push `pre-push` in `WKDBook-Tricentis` and `tricentis-vault` (`M.MANUAL_PUSH`; keep in step with
`docs/NOTES/CDX/setup-claude-code.ps1`). Those two repos make the command run `install.sh --manual-push-only` as a
second call.

- **Where the hooks go:** `<git-common-dir>/hooks`, the repo's own folder. `install.sh` asks git for that and not for
  `--git-path hooks`, because `setup-claude-code.ps1` sets a global `core.hooksPath` whose scripts only hand over to
  `<git-common-dir>/hooks/<name>`; installing into the folder `--git-path` names would hit every repo at once, or be
  skipped as foreign.
- **Workstation:** allowed, the hooks are shell scripts and nothing is built or started.
- Needs Git Bash on Windows (`lib.nvim.cross.bash`, never the WSL launcher).
- One install at a time; the result is one notification (`installed`, plus every line `install.sh` printed to stderr).

Code: `init.lua`; spec: `TESTS/git_hooks/git_hooks_spec.lua` (pure parts, and a real `install.sh` run in a temp repo
with a global `core.hooksPath` set).
