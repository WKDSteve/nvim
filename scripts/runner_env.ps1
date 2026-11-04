<#
.SYNOPSIS
  Give the self-hosted runners of this machine the longer wait for their worker.

.DESCRIPTION
  A runner hands a job to its worker process and kills that worker when the hand-over takes longer than
  30 seconds. On a busy machine it does: the worker is gone before the first step, and GitHub reports "The
  self-hosted runner lost communication" ten minutes later. 26 workers on 8 runners went that way from 2026-10-30
  to 2026-11-04
  ("Job request message sending ... been cancelled, kill running worker" in _diag\Runner_*.log).

  The wait is GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT, read from the .env of the runner when it starts. Idempotent;
  a value that is already there stays, and so does every other line (the job-started hook of the guard is one).

.EXAMPLE
  pwsh scripts/runner_env.ps1 -Root $env:USERPROFILE\actions-runners -Name tasks.nvim,appkit
#>
param(
  [Parameter(Mandatory)] [string] $Root,
  [Parameter(Mandatory)] [string[]] $Name
)

$ErrorActionPreference = 'Stop'
$variable = 'GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT'
$line = "$variable=300"

# `pwsh -File` hands a list over as one string with commas.
foreach ($n in @($Name | ForEach-Object { $_ -split ',' })) {
  $path = Join-Path (Join-Path $Root $n) '.env'
  $lines = if (Test-Path $path) { @(Get-Content $path) } else { @() }
  if (@($lines | Where-Object { $_ -like "$variable=*" }).Count -gt 0) { continue }
  # No byte order mark: the runner splits each line at '=', and a mark would become part of the first name.
  $text = ((@($lines) + $line) -join "`n") + "`n"
  [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
  Write-Output "$n now waits 300 s for its worker (a running runner reads .env after stop and start)"
}
