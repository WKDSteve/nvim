-- TESTS/sheets/features.lua -- the functionalities of this config that start a process (directly or through
-- lib.nvim), as its user meets them. `testing sheets report` says which ones have a feature sheet (`feature = "<id>"`)
-- and in which state, `testing perf` measures them through those sheets and lists the ones marked with `perf` (see
-- testing.nvim docs/PERF.md). Data: read with an empty environment like a sheet (testing.nvim docs/SHEETS.md).
--
-- Only this config's own functionalities: what a plugin of its own repository does (lsp.nvim, gitsuite.nvim,
-- tasks.nvim, my.nvim, ...) is in that repository's catalog and measured there. The sheets run on the installed
-- config (`config = "user"`), so they run locally (`testing sheets run`, `testing perf`) and are a skip on CI.
return {
  {
    id = "nvim-config.cdx-prompt",
    title = ":Cdx prompt <name> [sha] copies a CDX prompt template to the clipboard, {SHA} replaced",
    surface = { "command:Cdx prompt" },
    docs = "docs/NOTES/CDX/README.md",
  },
  {
    id = "nvim-config.clipboard",
    title = ":Clipboard <target> copies the path of a folder of this config, :Clipboard <snippet> a ready-made text",
    surface = { "command:Clipboard" },
  },
  {
    id = "nvim-config.execute",
    title = "<leader>X / :Execute! runs the `code` or line under the cursor (Ex, Lua or shell) and shows or copies "
      .. "the output",
    surface = { "command:Execute", "binding:<leader>x", "binding:<leader>X" },
  },
  {
    id = "nvim-config.powershell-profile",
    title = ":PowershellProfile asks PowerShell for $PROFILE and opens that file",
    surface = { "command:PowershellProfile" },
  },
  {
    id = "nvim-config.git-hooks",
    title = ":MyGit hooks status / repo / all shows and installs the git hooks of the repos under $REPOS_DIR",
    surface = { "command:MyGit hooks", "command:MyGit hooks status", "command:MyGit hooks repo" },
    docs = "docs/installation.md",
  },
  {
    id = "nvim-config.native-repos",
    title = ":MyNative list / pull / build / install / uninstall / deps manages the native app checkouts and their "
      .. "tools",
    surface = { "command:MyNative list", "command:MyNative build", "command:MyNative deps" },
    docs = "docs/NOTES/builds/maintenance.md",
  },
  {
    id = "nvim-config.myplugins-git",
    title = ":MyPlugins fetch / pull / update runs git over the listed plugin checkouts",
    surface = { "command:MyPlugins fetch", "command:MyPlugins pull", "command:MyPlugins update" },
  },
  {
    id = "nvim-config.myplugins-clone",
    title = ":MyPlugins clone clones the listed plugins that are missing in $REPOS_DIR (or a given folder)",
    surface = { "command:MyPlugins clone" },
  },
  {
    id = "nvim-config.myplugins-sync",
    title = ":MyPlugins sync fetches every listed checkout, pulls the ones behind and opens a terminal in a repo "
      .. "from its triage list",
    surface = { "command:MyPlugins sync" },
  },
  {
    id = "nvim-config.myplugins-machine",
    title = ":MyPlugins machine checks every repo of the machine; <CR> pulls one, B builds one in a float",
    surface = { "command:MyPlugins machine" },
  },
  {
    id = "nvim-config.myplugins-runner",
    title = ":MyPlugins runner status asks GitHub for the self-hosted runners; runner autostart status reads the "
      .. "logon task",
    surface = { "command:MyPlugins runner status", "command:MyPlugins runner autostart status" },
  },
  {
    id = "nvim-config.myplugins-runner-start",
    title = ":MyPlugins runner start / stop / autostart on|off starts and stops the real GitHub runners of this "
      .. "machine",
    surface = {
      "command:MyPlugins runner start",
      "command:MyPlugins runner stop",
      "command:MyPlugins runner autostart on",
      "command:MyPlugins runner autostart off",
    },
    perf = "manual:starts the real self-hosted GitHub runners (and registers a logon task); a hand run on STEVESPC",
  },
  {
    id = "nvim-config.repo-backup",
    title = "Weekly at startup: a git bundle of the repos without a remote (WKDBook-Tricentis), verified, then "
      .. "renamed",
    docs = "docs/NOTES/repo-backup.md",
  },
  {
    id = "nvim-config.machine-once",
    title = "Once per machine at the first interactive start: commit signing and the device registry entry",
    perf = "manual:runs setup-git-signing.ps1 only on OHANA or the workstation (a key and git settings); never on "
      .. "STEVESPC, and skipped in Claude sessions and headless",
  },
}
