# install-repos-luarc.ps1 -- copy luarc.repos-root.jsonc to <ReposDir>/.luarc.jsonc.
#
# Called by setup-claude-code.ps1; on its own so TESTS/cdx/luarc_repos_root_spec.lua can run it against a temp folder.
# Claude Code sessions with cwd = $REPOS_DIR start a lua-language-server (plugin lua-lsp) over the whole repos tree;
# without this file it preloads thousands of files incl. worktrees (measured up to 5 GB). Copy instead of a link, so no
# symlink right is needed. An existing, different file is moved to <name>.bak-<timestamp> first.

param(
    [string]$ReposDir,
    [string]$Source = (Join-Path $PSScriptRoot 'luarc.repos-root.jsonc')
)

if (-not $ReposDir -or -not (Test-Path $ReposDir)) {
    Write-Host "  REPOS_DIR fehlt oder existiert nicht: uebersprungen." -ForegroundColor Yellow
    return
}
$target = Join-Path $ReposDir '.luarc.jsonc'
if ((Test-Path $target) -and ((Get-FileHash $target).Hash -eq (Get-FileHash $Source).Hash)) {
    Write-Host "  Bereits aktuell: $target"
    return
}
if (Test-Path $target) {
    $backup = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmssfff')"
    Move-Item $target $backup -Force
    Write-Host "  Bestehende Datei gesichert nach: $backup"
}
Copy-Item $Source $target
Write-Host "  Kopiert: $target"
