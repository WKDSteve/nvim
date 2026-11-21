<#
.SYNOPSIS
  Install the rolling builds (pre-release `latest`) of the own desktop apps for the current user.
.DESCRIPTION
  For each app the files of the pre-release `latest` come through `gh` into a new, empty temp folder:

    hub-desktop, tasks-desktop, rules-desktop, testing-desktop, ai-desktop
        the stamped install.ps1 of release-kit; it downloads the build and checks it against SHA256SUMS itself
    pult, takt, streamtap
        the zip and SHA256SUMS; the zip is checked, unpacked into a new folder, and its install.ps1 runs

  Every install script runs in a child `pwsh -NoProfile -File` (no execution policy switched off), so an
  `exit` in it ends only that app; a failed app is reported and the next one goes on.

  Run it in your own PowerShell (Start menu, Windows Terminal), not elevated and not from a Claude
  session: there %LOCALAPPDATA% and HKCU land in the MSIX container of the app and the rest of Windows
  never sees the install. Close the apps first; a running app can lock the files an update replaces.
  Private machine only: on the workstation the native apps and the ai family are not installed
  (MASCHINE-03, MASCHINE-04).

  Exit code 0 all installed, 1 at least one app failed, 2 refused (wrong place or unknown app).
.EXAMPLE
  pwsh -NoProfile -File scripts\install-latest.ps1
  pwsh -NoProfile -File scripts\install-latest.ps1 -Only pult,takt
  pwsh -NoProfile -File scripts\install-latest.ps1 -List
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'run by a person in a console: coloured status lines')]
param(
    [string[]] $Only = @(),
    [switch] $List
)

$ErrorActionPreference = 'Stop'

# kind 'stamped': install.ps1 of release-kit; kind 'zip': <asset> with install.ps1 at its root.
$apps = [ordered]@{
    'hub-desktop'     = @{ Kind = 'stamped' }
    'tasks-desktop'   = @{ Kind = 'stamped' }
    'rules-desktop'   = @{ Kind = 'stamped' }
    'testing-desktop' = @{ Kind = 'stamped' }
    'ai-desktop'      = @{ Kind = 'stamped' }
    'pult'            = @{ Kind = 'zip'; Asset = 'pult-windows-x86_64.zip' }
    'takt'            = @{ Kind = 'zip'; Asset = 'takt-windows-x86_64.zip'; Note = 'built without libmpv: shows the test picture only' }
    'streamtap'       = @{ Kind = 'zip'; Asset = 'streamtap-windows-x86_64.zip'; Note = 'press Reload on the extension card at chrome://extensions; needs ffmpeg on the PATH' }
}
$owner = 'WKDSteve'

function Get-LatestCommit([string] $Repo) {
    $json = & gh release download latest -R "$owner/$Repo" -p version.json -O - 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $json) { return '?' }
    $commit = [string] (($json | Out-String) | ConvertFrom-Json).commit
    if ($commit.Length -ge 7) { return $commit.Substring(0, 7) }
    return '?'
}

if ($List) {
    foreach ($name in $apps.Keys) { '{0,-16} latest = {1}' -f $name, (Get-LatestCommit $name) }
    exit 0
}

$unknown = @($Only | Where-Object { -not $apps.Contains($_) })
if ($unknown.Count -gt 0) {
    Write-Host "Unknown app: $($unknown -join ', ') (known: $($apps.Keys -join ', '))" -ForegroundColor Red
    exit 2
}
if ($env:CLAUDECODE) {
    Write-Host 'Refused: this shell runs inside a Claude session (MSIX container). Run it in your own PowerShell.' -ForegroundColor Red
    exit 2
}
if (([string] $env:NVIM_MACHINE_ROLE).ToLowerInvariant() -eq 'workstation') {
    Write-Host 'Refused: the workstation gets no native apps and no ai family (MASCHINE-03, MASCHINE-04).' -ForegroundColor Red
    exit 2
}
$identity = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if ($identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Refused: elevated session. The apps install for one user; start a normal PowerShell.' -ForegroundColor Red
    exit 2
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host 'gh is not on the PATH.' -ForegroundColor Red
    exit 2
}

$pwshExe = (Get-Process -Id $PID).Path
$selected = if ($Only.Count -gt 0) { @($apps.Keys | Where-Object { $Only -contains $_ }) } else { @($apps.Keys) }
$results = [ordered]@{}

foreach ($name in $selected) {
    $app = $apps[$name]
    $commit = Get-LatestCommit $name
    Write-Host ''
    Write-Host "== $name (latest $commit)" -ForegroundColor Cyan
    $work = Join-Path ([IO.Path]::GetTempPath()) ("install-latest-$name-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        if ($app.Kind -eq 'stamped') {
            & gh release download latest -R "$owner/$name" -p install.ps1 -D $work
            if ($LASTEXITCODE -ne 0) { throw 'download of install.ps1 failed' }
            $script = Join-Path $work 'install.ps1'
        } else {
            & gh release download latest -R "$owner/$name" -p $app.Asset -p SHA256SUMS -D $work
            if ($LASTEXITCODE -ne 0) { throw "download of $($app.Asset) failed" }
            $zip = Join-Path $work $app.Asset
            $line = Get-Content (Join-Path $work 'SHA256SUMS') |
                Where-Object { ($_ -split '\s+\*?', 2)[1] -ceq $app.Asset } | Select-Object -First 1
            if (-not $line) { throw "SHA256SUMS lists no $($app.Asset)" }
            $want = ($line -split '\s+', 2)[0].ToLowerInvariant()
            $got = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($got -ne $want) { throw "checksum of $($app.Asset) does not match SHA256SUMS" }
            Unblock-File $zip
            $unpacked = Join-Path $work 'unpacked'
            Expand-Archive -Path $zip -DestinationPath $unpacked
            $script = Join-Path $unpacked 'install.ps1'
            if (-not (Test-Path $script)) { throw 'the zip has no install.ps1 at its root' }
        }
        Push-Location (Split-Path $script)
        try {
            & $pwshExe -NoProfile -File $script
            $rc = $LASTEXITCODE
        } finally {
            Pop-Location
        }
        if ($rc -ne 0) { throw "install.ps1 ended with exit code $rc" }
        $results[$name] = "ok ($commit)"
        if ($app.Note) { Write-Host "note: $($app.Note)" -ForegroundColor Yellow }
    } catch {
        $results[$name] = "FAILED: $($_.Exception.Message)"
        Write-Host "$name failed: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
    }
}

Write-Host ''
Write-Host 'Summary' -ForegroundColor Cyan
foreach ($name in $results.Keys) { '{0,-16} {1}' -f $name, $results[$name] }
if (@($results.Values | Where-Object { $_ -like 'FAILED*' }).Count -gt 0) { exit 1 }
exit 0
