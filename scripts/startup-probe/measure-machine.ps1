<#
.SYNOPSIS
  Startup measurement for ONE machine (written for OHANA): bench plus a probe
  run, everything in one output folder, a summary to paste into the task.

.DESCRIPTION
  Needs a human at the machine and a real terminal session (the starts run with
  a UI, see tui.lua). Close other programs first: the numbers swing by 15 % and
  more with the load, and only runs of the same session are comparable.

  Steps (about 3 to 5 minutes):
    1. machine, Neovim version and role are printed
    2. bench.lua <Runs> tui          -> bench.txt   (median / min / max)
    3. PROBE=stall,where,lazy,marks  -> probe.txt   (who owns the stalls)

  Written for Windows PowerShell 5.1 (no `&&`, no ternary, no `$args` parameter).

.PARAMETER Runs
  Number of counted bench runs (default 5; the first, uncounted run warms up).

.PARAMETER OutDir
  Where the result files go (default: a new folder under $env:TEMP).

.EXAMPLE
  powershell -NoProfile -File scripts\startup-probe\measure-machine.ps1
#>
param(
  [int]$Runs = 5,
  [string]$OutDir = ""
)

# Not "Stop": Windows PowerShell 5.1 turns any stderr line of a native command
# (nvim prints "Config loaded in ... ms" there) into a terminating error.
$ErrorActionPreference = "Continue"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$bench = Join-Path $PSScriptRoot "bench.lua"
$tui = Join-Path $PSScriptRoot "tui.lua"

if ($OutDir -eq "") {
  $OutDir = Join-Path $env:TEMP ("startup-measure-" + $env:COMPUTERNAME + "-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
}
New-Item -ItemType Directory -Force $OutDir | Out-Null

$nvimCmd = Get-Command nvim -ErrorAction SilentlyContinue
if (-not $nvimCmd) {
  throw "nvim is not on PATH"
}

$version = (& nvim --version | Select-Object -First 1)
$role = $env:NVIM_MACHINE_ROLE
if (-not $role) { $role = "(unset = private machine)" }
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).LoadPercentage

$header = @(
  "machine:    $env:COMPUTERNAME",
  "nvim:       $version",
  "role:       $role",
  "config:     $root",
  "cpu load:   $cpu % (should be low; close other programs)",
  "runs:       $Runs",
  "date:       $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)
$header | Set-Content -Encoding UTF8 (Join-Path $OutDir "machine.txt")
$header | ForEach-Object { Write-Host $_ }

# The config under test is the one nvim finds by itself; make sure it is this repo.
# `-u NONE`: silent, and stdpath() does not depend on the config.
$stdConfig = (& nvim --headless -u NONE -c "lua io.stdout:write(vim.fn.stdpath('config'))" -c "q" 2>&1) | Out-String
Write-Host ("stdpath:    " + $stdConfig.Trim())

Write-Host ""
Write-Host "== 1/2 bench.lua $Runs tui (this takes a few minutes, do not touch the machine)"
$benchOut = Join-Path $OutDir "bench.txt"
# `< NUL`: an open stdin pipe stalls the probed nvim before VimEnter (see tui.lua).
cmd /c "nvim --headless -l `"$bench`" $Runs tui < NUL > `"$benchOut`" 2>&1"
Get-Content -Encoding UTF8 $benchOut

Write-Host ""
Write-Host "== 2/2 probe stall,where,lazy,marks (one start)"
$probeOut = Join-Path $OutDir "probe.txt"
$env:PROBE = "stall,where,lazy,marks"
$env:PROBE_OUT = $probeOut
try {
  cmd /c "nvim --headless -l `"$tui`" > NUL < NUL"
}
finally {
  Remove-Item Env:PROBE -ErrorAction SilentlyContinue
  Remove-Item Env:PROBE_OUT -ErrorAction SilentlyContinue
}
if (Test-Path $probeOut) {
  Get-Content -Encoding UTF8 $probeOut | Select-Object -First 60
}
else {
  Write-Warning "no probe report written to $probeOut"
}

Write-Host ""
Write-Host "Results in: $OutDir"
Write-Host "Paste machine.txt and the table of bench.txt into the task ohana-startup-remeasure."
Write-Host "Compare with STEVESPC: stalls over 60 ms sum 612 ms, longest 351 ms, 47 plugins (2026-10-01, old busy rule)."
