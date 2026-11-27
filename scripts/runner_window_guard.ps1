<#
.SYNOPSIS
  The window guard of the self-hosted runners: one watcher for the machine, and a report of the windows each job
  opened, at the end of that job.

.DESCRIPTION
  A job step that starts a console program in a console of its own makes Windows open a window (Windows Terminal,
  the default console host here), and that window takes the focus of the person at the machine. This finds such
  steps; it does not stop them.

  -Ensure starts the watcher unless it runs: window-log.ps1 (tasks-vault TOOLS/scripts/app-proc-watch) logs every
  top-level window shown on the desktop with its process chain, into %LOCALAPPDATA%\runner-window-guard\
  windows-<start>.jsonl, for 25 hours. It is started through WMI (outside the caller's process tree, like the
  runners themselves) and `conhost --headless` (no window of its own). `runners.ps1 start|ensure` calls it, so the
  logon task and its hourly run keep a watcher alive. Logs older than two days are deleted.

  -Report is the job-completed hook (ACTIONS_RUNNER_HOOK_JOB_COMPLETED, scripts/runner_job_completed.ps1): it finds
  the Runner.Worker of its job among its own parents and lists every window whose process chain passes through that
  worker, as a ::warning:: in the job's log. It always exits 0: a window is a finding, not a failed job.

  Not on the workstation (NVIM_MACHINE_ROLE=workstation): a global window hook and process snapshots there can read
  as an attack to the endpoint protection, and no runner runs there.

.EXAMPLE
  pwsh scripts/runner_window_guard.ps1 -Ensure
  pwsh scripts/runner_window_guard.ps1 -Report -WorkerPid 1234 -LogDir C:\tmp\guard
#>
param(
  [switch] $Ensure,
  [switch] $Report,
  [string] $LogDir = (Join-Path $env:LOCALAPPDATA 'runner-window-guard'),
  # The window logger. Default: $env:RUNNER_WINDOW_LOG, else the copy in the tasks-vault checkout.
  [string] $WindowLog = '',
  # For a test: the worker whose windows -Report lists (default: the Runner.Worker among this process's parents).
  [int] $WorkerPid = 0,
  # For a test: list windows from this time on (default: the start of the worker).
  [datetime] $Since = [datetime]::MinValue,
  # For a test: how long a started watcher runs, in seconds.
  [int] $Seconds = 90000
)

$ErrorActionPreference = 'Stop'

function Test-Workstation {
  return "$env:NVIM_MACHINE_ROLE".Trim().ToLowerInvariant() -eq 'workstation'
}

# The watchers that log into this folder, by the -OutFile of their command line (not this process: its own command
# line names the folder and the logger too).
function Get-Watcher([string] $dir) {
  # conhost hands the arguments on without quotes when a path has no space in it
  $needle = '-OutFile\s+"?' + [regex]::Escape((Join-Path $dir 'windows-'))
  # conhost.exe too: it is there from the first moment, before it has started pwsh (a second -Ensure right after
  # the first would start another watcher otherwise)
  @(Get-CimInstance Win32_Process -Filter "Name = 'pwsh.exe' OR Name = 'conhost.exe'" -Property ProcessId, CommandLine |
      Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -match $needle })
}

function Resolve-WindowLog {
  if ($WindowLog) { return $WindowLog }
  if ($env:RUNNER_WINDOW_LOG) { return $env:RUNNER_WINDOW_LOG }
  if ($env:REPOS_DIR) { return (Join-Path $env:REPOS_DIR 'tasks-vault\TOOLS\scripts\app-proc-watch\window-log.ps1') }
  return ''
}

# The Runner.Worker among the parents of this process, or 0.
function Find-Worker {
  $id = $PID
  for ($i = 0; $i -lt 16 -and $id -gt 0; $i++) {
    $p = Get-CimInstance Win32_Process -Filter "ProcessId = $id" -Property ProcessId, ParentProcessId, Name
    if (-not $p) { return 0 }
    if ($p.Name -eq 'Runner.Worker.exe') { return [int] $p.ProcessId }
    $id = [int] $p.ParentProcessId
  }
  return 0
}

# The windows of the log lines whose chain passes through the worker, in the order they were shown.
function Select-JobWindows([string[]] $files, [int] $worker) {
  foreach ($file in $files) {
    foreach ($line in [System.IO.File]::ReadAllLines($file)) {
      if (-not $line.Trim()) { continue }
      try { $rec = $line | ConvertFrom-Json } catch { continue }
      $chain = @($rec.chain)
      if (@($chain | Where-Object { [int] $_.pid -eq $worker -and $_.name -eq 'Runner.Worker.exe' }).Count -gt 0) { $rec }
    }
  }
}

if ($Ensure -eq $Report) {
  Write-Output 'usage: runner_window_guard.ps1 -Ensure | -Report'
  exit 2
}

if (Test-Workstation) {
  Write-Output 'window-guard: not on the workstation (a global window hook can read as an attack there)'
  exit 0
}

if ($Ensure) {
  $null = New-Item -ItemType Directory -Force -Path $LogDir
  $running = @(Get-Watcher $LogDir)
  if ($running.Count -gt 0) {
    Write-Output "window-guard: the watcher runs (pid $($running[0].ProcessId))"
    exit 0
  }
  $logger = Resolve-WindowLog
  if (-not $logger -or -not (Test-Path -LiteralPath $logger)) {
    Write-Output "warning: window-guard has no window logger ($(if ($logger) { $logger } else { 'REPOS_DIR is not set' })); the jobs' windows are not watched"
    exit 0
  }
  Get-ChildItem -LiteralPath $LogDir -Filter 'windows-*.jsonl' |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-2) } |
    Remove-Item -Force -ErrorAction SilentlyContinue
  $out = Join-Path $LogDir ('windows-{0:yyyyMMdd-HHmmss}.jsonl' -f (Get-Date))
  $pwsh = (Get-Command pwsh).Source
  $line = "conhost.exe --headless `"$pwsh`" -NoProfile -NonInteractive -File `"$logger`" -Seconds $Seconds -OutFile `"$out`""
  # Not tracked by a runner's orphan cleanup when a hook or a job step calls this.
  $env:RUNNER_TRACKING_ID = ''
  # The profile as the working folder, not the log folder: a caller inside a packaged app (the Claude desktop app)
  # writes AppData\Local into its own virtual view, where WMI does not see the folder it just made (exit 8). The
  # logger makes its folder itself.
  $made = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $line; CurrentDirectory = $env:USERPROFILE }
  if ($made.ReturnValue -ne 0) {
    Write-Output "warning: window-guard could not start its watcher (Win32_Process.Create: $($made.ReturnValue))"
    exit 0
  }
  Write-Output "window-guard: watcher started -> $out"
  exit 0
}

# -Report
$worker = if ($WorkerPid -gt 0) { $WorkerPid } else { Find-Worker }
if ($worker -eq 0) {
  Write-Output 'window-guard: not inside a runner job (no Runner.Worker among the parents)'
  exit 0
}
if ($Since -eq [datetime]::MinValue) {
  $proc = Get-Process -Id $worker -ErrorAction SilentlyContinue
  $Since = if ($proc) { $proc.StartTime } else { (Get-Date).AddHours(-6) }
}
if (-not (Test-Path -LiteralPath $LogDir)) {
  Write-Output 'window-guard: no watcher has run on this machine (runners.ps1 ensure starts it); the windows of this job are not known'
  exit 0
}
$files = @(Get-ChildItem -LiteralPath $LogDir -Filter 'windows-*.jsonl' | Where-Object { $_.LastWriteTime -ge $Since } |
    Sort-Object Name | ForEach-Object { $_.FullName })
$hits = @(Select-JobWindows $files $worker)
if (@(Get-Watcher $LogDir).Count -eq 0) {
  Write-Output 'window-guard: the watcher does not run now (runners.ps1 ensure starts it); windows after it ended are not known'
}
if ($hits.Count -eq 0) {
  Write-Output 'window-guard: this job opened no window'
  exit 0
}
foreach ($h in $hits) {
  $names = @($h.chain | ForEach-Object { $_.name })
  $upto = [array]::IndexOf($names, 'Runner.Worker.exe')
  $shown = if ($upto -ge 0) { $names[0..$upto] } else { $names }
  $title = if ($h.title) { " '$($h.title)'" } else { '' }
  Write-Output "::warning title=window-guard::$($h.at) $($h.class)$title opened by $($shown -join ' <- ')"
}
Write-Output "window-guard: this job opened $($hits.Count) window(s); a step that starts a console program with a console of its own does (CREATE_NO_WINDOW, Start-Process -NoNewWindow, a GUI-subsystem helper avoid it)"
exit 0
