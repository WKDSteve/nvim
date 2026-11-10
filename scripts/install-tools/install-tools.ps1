<#
.SYNOPSIS
  Installs the CLI tools the own nvim plugins and repos need - one command on a new machine.

.DESCRIPTION
  Thin starter for install_tools.py (the logic lives there once, shared with install-tools.sh):
  makes sure a real Python is there (winget Python.Python.3.14; the Microsoft Store stub does not
  count), then runs the script. Routes: winget, then scoop, then npm / pip / cargo, else a link.
  Windows PowerShell 5.1 and PowerShell 7.

.EXAMPLE
  pwsh -File scripts\install-tools\install-tools.ps1 -List          # what is there, what is missing
  pwsh -File scripts\install-tools\install-tools.ps1 -DryRun -All   # show the commands only
  pwsh -File scripts\install-tools\install-tools.ps1                # core, plugins, dev
  pwsh -File scripts\install-tools\install-tools.ps1 -All -Yes      # everything, no questions
  pwsh -File scripts\install-tools\install-tools.ps1 -Only core,dev
#>
param(
    [switch] $List,
    [switch] $Markdown,
    [switch] $WriteReadme,
    [switch] $DryRun,
    [switch] $All,
    [string[]] $Only,
    [string[]] $Skip,
    [switch] $Yes,
    [string] $ReposDir,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Update-ProcessPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = (@($machine, $user, $env:Path) | Where-Object { $_ }) -join ';'
}

function Find-Python {
    foreach ($name in 'python', 'py') {
        $cmd = Get-Command $name -CommandType Application -ErrorAction SilentlyContinue |
            Where-Object { $_.Source -notlike '*\WindowsApps\*' } | Select-Object -First 1
        if ($cmd) { return $cmd.Source }
    }
    $local = Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python3*\python.exe') -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending | Select-Object -First 1
    if ($local) { return $local.FullName }
    return $null
}

$python = Find-Python
if (-not $python) {
    $readOnly = $List -or $Markdown -or $WriteReadme -or $DryRun
    $role = "$env:NVIM_MACHINE_ROLE".Trim().ToLower()
    if ($role -eq 'workstation' -and -not $Force) {
        Write-Host 'Python fehlt, und auf der Workstation wird nichts installiert (EDR/Falcon).' -ForegroundColor Red
        exit 2
    }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host 'Weder Python noch winget gefunden. winget kommt mit dem "App Installer" aus dem Microsoft Store:' -ForegroundColor Red
        Write-Host '  https://apps.microsoft.com/detail/9NBLGGH4NNS1'
        exit 2
    }
    Write-Host 'Python fehlt - das Skript braucht es. Installiere es per winget (Python.Python.3.14).' -ForegroundColor Yellow
    if ($readOnly) { Write-Host '(auch fuer -List/-DryRun noetig)' }
    $wingetArgs = @('install', '-e', '--id', 'Python.Python.3.14', '--source', 'winget')
    if ($Yes) { $wingetArgs += @('--accept-package-agreements', '--accept-source-agreements') }
    & winget @wingetArgs
    Update-ProcessPath
    $python = Find-Python
    if (-not $python) {
        Write-Host 'Python ist nach der Installation nicht zu finden - neues Terminal oeffnen und erneut starten.' -ForegroundColor Red
        exit 2
    }
}

$pyArgs = @('-I', (Join-Path $here 'install_tools.py'))
if ($List) { $pyArgs += '--list' }
if ($Markdown) { $pyArgs += '--markdown' }
if ($WriteReadme) { $pyArgs += '--write-readme' }
if ($DryRun) { $pyArgs += '--dry-run' }
if ($All) { $pyArgs += '--all' }
if ($Only) { $pyArgs += @('--only', ($Only -join ',')) }
if ($Skip) { $pyArgs += @('--skip', ($Skip -join ',')) }
if ($Yes) { $pyArgs += '--yes' }
if ($ReposDir) { $pyArgs += @('--repos-dir', $ReposDir) }
if ($Force) { $pyArgs += '--force' }

& $python @pyArgs
exit $LASTEXITCODE
