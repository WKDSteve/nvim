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

.EXAMPLE
  pwsh scripts/runner_env.ps1 -Root $env:USERPROFILE\actions-runners -Name tasks.nvim,appkit
#>
param(
  [Parameter(Mandatory)] [string] $Root,
  [Parameter(Mandatory)] [string[]] $Name
)

$ErrorActionPreference = 'Stop'
# Name, value and what the runner gains, in the order they join a .env.
$settings = @(
  @{ Name = 'GITHUB_ACTIONS_RUNNER_CHANNEL_TIMEOUT'; Value = '300'; Says = 'waits 300 s for its worker' },
  @{ Name = 'CARGO_BUILD_JOBS'; Value = '4'; Says = 'builds with 4 cargo jobs' }
)

# `pwsh -File` hands a list over as one string with commas.
foreach ($n in @($Name | ForEach-Object { $_ -split ',' })) {
  $path = Join-Path (Join-Path $Root $n) '.env'
  # One .env that cannot be written costs that runner its settings, not the start of the others.
  try {
    $lines = if (Test-Path $path) { @(Get-Content $path) } else { @() }
    $added = @($settings | Where-Object { $s = $_; @($lines | Where-Object { $_ -like "$($s.Name)=*" }).Count -eq 0 })
    if ($added.Count -eq 0) { continue }
    # No byte order mark: the runner splits each line at '=', and a mark would become part of the first name.
    $text = ((@($lines) + @($added | ForEach-Object { "$($_.Name)=$($_.Value)" })) -join "`n") + "`n"
    [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
    Write-Output "$n now $(($added | ForEach-Object { $_.Says }) -join ' and ') (a running runner reads .env after stop and start)"
  }
  catch {
    Write-Output "warning: $n keeps its .env as it is (no longer worker wait, no cargo job limit): $($_.Exception.Message)"
  }
}
