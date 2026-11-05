<#
.SYNOPSIS
  Download or list the binaries of own plugins from a shell (the by-hand way, e.g. on the workstation).
.DESCRIPTION
  Runs the config headless and calls `:MyPlugins binaries status|fetch [plugin]` (lua/bindings/usrcmds/plugin_repos/binaries.lua).
  On the workstation vim.g.lib_binaries is "manual": no plugin downloads unasked, this does it on request.
  Exit code 0 all fine, 1 something failed, 2 unknown action.
.EXAMPLE
  pwsh -File scripts\binaries.ps1 status
  pwsh -File scripts\binaries.ps1 fetch mdview.nvim
#>
param(
    [ValidateSet('status', 'fetch')] [string] $Action = 'status',
    [string] $Plugin
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host 'nvim is not on PATH.' -ForegroundColor Red
    exit 3
}
if ($Plugin -and $Plugin -notmatch '^[A-Za-z0-9._-]+$') {
    Write-Host "Not a plugin name: $Plugin" -ForegroundColor Red
    exit 2
}

$arg = if ($Plugin) { ", '$Plugin'" } else { '' }
$lua = "lua os.exit(require('bindings.usrcmds.plugin_repos.binaries').cli('$Action'$arg))"
& nvim --headless -c $lua -c 'qa!'
exit $LASTEXITCODE
