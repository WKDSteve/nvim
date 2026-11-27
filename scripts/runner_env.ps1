<#
.SYNOPSIS
  Give the self-hosted runners of this machine the settings that keep their jobs alive on a busy machine.

.DESCRIPTION
  Each setting is a line of the runner's .env, read when the runner starts. Idempotent; a value that is already
  there stays (set by hand on purpose), and so does every other line (the job-started hook of the guard is one).

  GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT=300
    A runner hands a job to its worker process and kills that worker when the hand-over takes longer than
    30 seconds. On a busy machine it does: the worker is gone before the first step, and GitHub reports "The
    self-hosted runner lost communication" ten minutes later. 26 workers on 8 runners went that way from
    2026-10-30 to 2026-11-04 ("Job request message sending ... been cancelled, kill running worker" in
    _diag\Runner_*.log).

  CARGO_BUILD_JOBS=4
    All runners share one machine (12 logical cores). cargo starts as many rustc as there are cores, so six
    Rust jobs at once ran 72 and more rustc next to each other (2026-11-15, 19:11 UTC: CPU at 100 %, clippy
    3.7 times slower, browser tests of other repositories red at their 30 s limit). Four per job keep a
    lone build reasonably fast and a crowd of them near the core count.

  ACTIONS_RUNNER_HOOK_JOB_COMPLETED=<this folder>\runner_job_completed.ps1 (retired 2026-11-27, taken out again)
    It listed the windows each job opened, but the runner starts it as a pwsh with a console of its own, so the hook
    itself opened a window in every job (the black pwsh.EXE window of 2026-11-27; 11 of 75 terminal windows that
    day were next to it). The window logger (runner_window_guard.ps1 -Ensure) still records every window;
    tasks-vault TOOLS/scripts/app-proc-watch/console-origins.py reads its log. Only our own line is taken out: a
    hook of the same name set by hand stays.

  -Started records the .env a runner is started with (a copy, .env.started); `runners.ps1 start|ensure` calls it
  right before it starts the runner. The time of the .env says nothing: `testing ci runner-guard install`
  rewrites the .env of every runner on each start, changed or not.

  -Check writes nothing and tells, one line per runner:
    missing  a setting is not in its .env
    restart  its listener runs with an older .env than the one there now (stop and ensure once no job runs)
    unknown  its listener was not started by runners.ps1 (no record, or the record is younger than the listener):
             what it read is not known; counts as ok, a restart through runners.ps1 makes it known
    ok       otherwise, also a runner that does not run (it reads the .env at its start)
  Exit 1 when a runner is "missing" or "restart". `runners.ps1 status` runs it.

.EXAMPLE
  pwsh scripts/runner_env.ps1 -Root $env:USERPROFILE\actions-runners -Name tasks.nvim,appkit
  pwsh scripts/runner_env.ps1 -Root $env:USERPROFILE\actions-runners -Name tasks.nvim,appkit -Check
#>
param(
  [Parameter(Mandatory)] [string] $Root,
  [Parameter(Mandatory)] [string[]] $Name,
  [switch] $Check,
  [switch] $Started
)

$ErrorActionPreference = 'Stop'
# Name, value and what the runner gains, in the order they join a .env.
$settings = @(
  @{ Name = 'GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT'; Value = '300'; Says = 'waits 300 s for its worker' },
  @{ Name = 'CARGO_BUILD_JOBS'; Value = '4'; Says = 'builds with 4 cargo jobs' }
)
# Lines this script wrote once and takes out again, only when their value is ours (Ours matches it); a line of the
# same name set by hand stays.
$retired = @(
  @{ Name = 'ACTIONS_RUNNER_HOOK_JOB_COMPLETED'; Ours = 'runner_job_completed\.ps1$'; Says = 'no longer reports the windows of each job' }
)
# `pwsh -File` hands a list over as one string with commas.
$names = @($Name | ForEach-Object { $_ -split ',' })

function Read-Text([string] $path) {
  if (Test-Path $path -PathType Leaf) { return [System.IO.File]::ReadAllText($path) }
  return $null
}

if ($Started) {
  foreach ($n in $names) {
    $dir = Join-Path $Root $n
    $text = Read-Text (Join-Path $dir '.env')
    if ($null -eq $text) { $text = '' }
    [System.IO.File]::WriteAllText((Join-Path $dir '.env.started'), $text, [System.Text.UTF8Encoding]::new($false))
  }
  exit 0
}

# Start time of each running listener by runner name. RUNNER_ENV_LISTENERS ("name=<ISO time>;...") stands in for
# the process table in the spec, which has no runner process to look at.
function Get-ListenerStarts {
  $starts = @{}
  if ($env:RUNNER_ENV_LISTENERS) {
    foreach ($pair in $env:RUNNER_ENV_LISTENERS -split ';') {
      $k, $v = $pair -split '=', 2
      $starts[$k] = [datetime]::Parse($v, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AdjustToUniversal)
    }
    return $starts
  }
  # The runners are Windows services' processes; pwsh elsewhere (the spec job on Linux) has no Get-CimInstance and
  # no runner to find, so nothing is running there.
  if (-not (Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) { return $starts }
  # One process query for all runners; a listener belongs to the runner whose folder holds its executable.
  $root =(Resolve-Path $Root).Path.ToLowerInvariant().TrimEnd('\') + '\'
  foreach ($p in Get-CimInstance Win32_Process -Filter "Name = 'Runner.Listener.exe'") {
    if (-not $p.ExecutablePath) { continue }
    $exe = $p.ExecutablePath.ToLowerInvariant()
    if (-not $exe.StartsWith($root)) { continue }
    $starts[$exe.Substring($root.Length).Split('\')[0]] = $p.CreationDate.ToUniversalTime()
  }
  return $starts
}

if ($Check) {
  $bad = 0
  $listeners = Get-ListenerStarts
  foreach ($n in $names) {
    $dir = Join-Path $Root $n
    $text = Read-Text (Join-Path $dir '.env')
    $lines = if ($null -ne $text) { @($text -split "`r?`n") } else { @() }
    $missing = @($settings | Where-Object { $s = $_; @($lines | Where-Object { $_ -like "$($s.Name)=*" }).Count -eq 0 } | ForEach-Object { $_.Name })
    $record = Join-Path $dir '.env.started'
    # The record is written just before the start; a listener older than it was not started with it.
    $known = $listeners.ContainsKey($n) -and (Test-Path $record -PathType Leaf) -and
      $listeners[$n] -ge (Get-Item -LiteralPath $record -Force).LastWriteTimeUtc.AddSeconds(-5)
    if ($missing.Count -gt 0) {
      $bad++
      Write-Output "missing  $n lacks $($missing -join ', ') in .env (runners.ps1 start writes it)"
    }
    elseif (-not $listeners.ContainsKey($n)) {
      Write-Output "ok       $n (not running; reads .env at its start)"
    }
    elseif (-not $known) {
      Write-Output "unknown  $n was not started by runners.ps1: what it read from .env is not known (restart it through runners.ps1 to know)"
    }
    elseif ((Read-Text $record) -ne $text) {
      $bad++
      Write-Output "restart  $n runs with an older .env than the one there now (stop and ensure once no job runs)"
    }
    else {
      Write-Output "ok       $n"
    }
  }
  exit ([int] ($bad -gt 0))
}

foreach ($n in $names) {
  $path = Join-Path (Join-Path $Root $n) '.env'
  # One .env that cannot be written costs that runner its settings, not the start of the others.
  try {
    $lines = if (Test-Path $path) { @(Get-Content $path) } else { @() }
    $dropped = @($retired | Where-Object { $r = $_; @($lines | Where-Object { $_ -like "$($r.Name)=*" -and $_.Substring($r.Name.Length + 1) -match $r.Ours }).Count -gt 0 })
    $lines = @($lines | Where-Object { $line = $_; -not ($retired | Where-Object { $line -like "$($_.Name)=*" -and $line.Substring($_.Name.Length + 1) -match $_.Ours }) })
    $added = @($settings | Where-Object { $s = $_; @($lines | Where-Object { $_ -like "$($s.Name)=*" }).Count -eq 0 })
    if ($added.Count -eq 0 -and $dropped.Count -eq 0) { continue }
    # No byte order mark: the runner splits each line at '=', and a mark would become part of the first name.
    $text = ((@($lines) + @($added | ForEach-Object { "$($_.Name)=$($_.Value)" })) -join "`n") + "`n"
    [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
    Write-Output "$n now $((@($added + $dropped) | ForEach-Object { $_.Says }) -join ' and ') (a running runner reads .env after stop and start)"
  }
  catch {
    Write-Output "warning: $n keeps its .env as it is (no longer worker wait, no cargo job limit): $($_.Exception.Message)"
  }
}
