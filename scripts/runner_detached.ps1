# scripts/runner_detached.ps1 -- dot-sourced by runners.ps1: how a runner is started so that it outlives its starter.
#
# Start-Process is not enough: its child stays in the job of whoever started runners.ps1, and a Claude Code session
# ends its job when it stops or goes idle, which took every runner it had started down with it, silently and mid-job
# (2026-11-16: the runners of the 22:42 and 04:52 starts died together at 00:27 and 05:31:12 UTC, within minutes of the
# starting session going idle; tasks-vault ALL/runner-gehen-still-offline). Win32_Process.Create lets WMI create the
# process (parent WmiPrvSE, no job) in the same desktop session.
#
# A runner that outlives the session must not carry the session with it: CLAUDECODE, CLAUDE_* and ANTHROPIC_* (session
# id, messaging socket and token, account) would reach every CI job for hours. Get-RunnerEnvironment leaves them out.

# Names of variables a runner never gets (anchored, case-insensitive like the Windows environment).
$script:RunnerDroppedVariables = '^(CLAUDECODE|CLAUDE_.*|ANTHROPIC_.*)$'

# The environment a started runner gets, as NAME=value lines: this process's environment (PATH with the scoop shims,
# without the *_NVIM_DIR overrides the caller took out) minus the variables of an agent session.
function Get-RunnerEnvironment {
  [string[]] @(Get-ChildItem Env: |
      Where-Object { $_.Name -notmatch $script:RunnerDroppedVariables } |
      ForEach-Object { "$($_.Name)=$($_.Value)" })
}

# Starts $Exe (a .cmd) through cmd.exe in $Dir, hidden, detached as described above. Returns the pid of cmd.exe.
function Start-Detached([string] $Exe, [string] $Dir) {
  $startup = New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{
    ShowWindow = [uint16] 0  # SW_HIDE: run.cmd is a console program, its window stays hidden
    # replaces the environment WMI would take from the registry (so the caller's PATH and removals hold)
    EnvironmentVariables = (Get-RunnerEnvironment)
  }
  $r = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine = "cmd.exe /d /c `"`"$Exe`"`""
    CurrentDirectory = $Dir
    ProcessStartupInformation = $startup
  }
  if ($r.ReturnValue -ne 0) { throw "Win32_Process.Create failed for ${Exe}: return value $($r.ReturnValue)" }
  return $r.ProcessId
}
