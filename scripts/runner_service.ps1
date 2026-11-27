<#
.SYNOPSIS
  Run one self-hosted runner as a Windows service (session 0), so its jobs can never show a window on the desktop.

.DESCRIPTION
  A runner started by runners.ps1 (WMI, hidden console) lives in the desktop session of the person at the machine. Some
  steps of its jobs get a console of their own (actions/checkout's git and sh, chcp, the job-completed hook), and each
  becomes a Windows Terminal window that takes the focus: 75 such windows on 2026-11-27, 69 from tasks-vault jobs
  (tasks-vault nvim-config/runner-jobs-oeffnen-terminal-fenster-checkout-node-chcp-und). A service runs in session 0,
  which has no visible desktop: whatever a job opens there is never seen.

  The service runs as the current user (the tools, scoop shims, gh login and the runner folder are that user's) and
  starts the runner's own RunnerService.exe, as `config.cmd --runasservice` would. Its environment is the user's
  environment from the registry; the variables a WMI start leaves out (scripts/runner_detached.ps1: CLAUDECODE,
  CLAUDE_*, ANTHROPIC_*, and the *_NVIM_DIR overrides of runners.ps1) are set empty for the service, so no job sees a
  key or a local checkout override.

  Actions:
    plan     what install would do, for one runner: service name, program, account, the emptied variables. No admin.
    install  stop the runner (runners.ps1 stop), ask for the user's password (in this window; it goes to the service
             manager only), grant "log on as a service", create and start the service, write <runner>\.service.
             Needs an elevated PowerShell (run it yourself; nothing here elevates).
    remove   stop and delete the service, delete <runner>\.service, start the runner the usual way again. Elevated.
    status   one line per runner that has a .service: the service and its state. No admin.

  runners.ps1 leaves a runner with a .service alone: `start`/`ensure` do not start a second listener, `stop` does not
  kill the service's listener (use the service manager or `remove`).

  Not on the workstation (NVIM_MACHINE_ROLE=workstation): no runner runs there.

.EXAMPLE
  pwsh scripts/runner_service.ps1 plan tasks-vault
  # in a PowerShell opened with "Run as administrator":
  pwsh scripts/runner_service.ps1 install tasks-vault
#>
param(
  [Parameter(Position = 0)] [ValidateSet('plan', 'install', 'remove', 'status')] [string] $Action = 'plan',
  [Parameter(Position = 1)] [string] $Repo = '',
  [string] $Root = (Join-Path $env:USERPROFILE 'actions-runners'),
  # For a test: the names of the user's environment variables (default: HKCU\Environment and the machine's).
  [string[]] $EnvNames = $null,
  # For a test: where the account comes from (Local, MicrosoftAccount, ...) and whether Windows Hello is required for
  # Microsoft accounts on this device (DevicePasswordLessBuildVersion 2). Default: read from this machine.
  [string] $AccountSource = '',
  [string] $PasswordLess = '',
  # For a test: only define the functions.
  [switch] $LibraryOnly
)

# Names of variables a runner never gets (as runner_detached.ps1, plus the dependency overrides runners.ps1 removes).
$script:ServiceDroppedVariables = '^(CLAUDECODE|CLAUDE_.*|ANTHROPIC_.*|[A-Z0-9_]+_NVIM_DIR)$'

# The service name config.cmd would give: actions.runner.<owner>-<repo>.<runner name>, from <runner>\.runner.
function Get-RunnerServiceName([string] $Dir) {
  $file = Join-Path $Dir '.runner'
  if (-not (Test-Path $file)) { throw "no runner configuration: $file" }
  # .runner is written with a byte order mark; ConvertFrom-Json takes it
  $cfg = Get-Content $file -Raw | ConvertFrom-Json
  $path = ([uri] $cfg.gitHubUrl).AbsolutePath.Trim('/')
  if (-not $path -or -not $cfg.agentName) { throw "no gitHubUrl/agentName in $file" }
  return 'actions.runner.{0}.{1}' -f ($path -replace '/', '-'), $cfg.agentName
}

# The variables the service gets empty: every name of the user's or the machine's environment that matches.
function Get-ServiceEnvironmentOverride([string[]] $Names) {
  if ($null -eq $Names) {
    $Names = @(
      (Get-Item 'HKCU:\Environment').GetValueNames()
      (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').GetValueNames()
    )
  }
  [string[]] @($Names | Where-Object { $_ -match $script:ServiceDroppedVariables } | Sort-Object -Unique | ForEach-Object { "$_=" })
}

# Does this runner run as a service (runners.ps1 asks this)?
function Test-RunnerService([string] $Dir) {
  Test-Path (Join-Path $Dir '.service')
}

function Test-Elevated {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  ([Security.Principal.WindowsPrincipal] $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Grants "log on as a service" (SeServiceLogonRight) to an account; the service manager does not, and a service of an
# account without it fails to start (error 1069). Idempotent.
function Grant-ServiceLogonRight([string] $Account) {
  if (-not ('RunnerService.Lsa' -as [type])) {
    Add-Type -Namespace RunnerService -Name Lsa -MemberDefinition @'
[StructLayout(LayoutKind.Sequential)] public struct UNICODE_STRING { public ushort Length; public ushort MaximumLength; public System.IntPtr Buffer; }
[StructLayout(LayoutKind.Sequential)] public struct OBJECT_ATTRIBUTES { public int Length; public System.IntPtr RootDirectory; public System.IntPtr ObjectName; public uint Attributes; public System.IntPtr SecurityDescriptor; public System.IntPtr SecurityQualityOfService; }
[DllImport("advapi32.dll")] public static extern uint LsaOpenPolicy(System.IntPtr system, ref OBJECT_ATTRIBUTES attr, uint access, out System.IntPtr handle);
[DllImport("advapi32.dll")] public static extern uint LsaAddAccountRights(System.IntPtr handle, byte[] sid, UNICODE_STRING[] rights, uint count);
[DllImport("advapi32.dll")] public static extern uint LsaClose(System.IntPtr handle);
[DllImport("advapi32.dll")] public static extern int LsaNtStatusToWinError(uint status);
'@
  }
  $sid = (New-Object Security.Principal.NTAccount($Account)).Translate([Security.Principal.SecurityIdentifier])
  $bytes = New-Object byte[] $sid.BinaryLength
  $sid.GetBinaryForm($bytes, 0)
  $attr = New-Object RunnerService.Lsa+OBJECT_ATTRIBUTES
  $handle = [IntPtr]::Zero
  $st = [RunnerService.Lsa]::LsaOpenPolicy([IntPtr]::Zero, [ref] $attr, 0x00000800 -bor 0x00000010, [ref] $handle)  # POLICY_CREATE_ACCOUNT | POLICY_LOOKUP_NAMES
  if ($st -ne 0) { throw "LsaOpenPolicy failed: $([RunnerService.Lsa]::LsaNtStatusToWinError($st))" }
  $name = 'SeServiceLogonRight'
  $ptr = [Runtime.InteropServices.Marshal]::StringToHGlobalUni($name)
  try {
    $right = New-Object RunnerService.Lsa+UNICODE_STRING
    $right.Buffer = $ptr; $right.Length = [uint16] ($name.Length * 2); $right.MaximumLength = [uint16] (($name.Length + 1) * 2)
    $st = [RunnerService.Lsa]::LsaAddAccountRights($handle, $bytes, @($right), 1)
    if ($st -ne 0) { throw "LsaAddAccountRights failed: $([RunnerService.Lsa]::LsaNtStatusToWinError($st))" }
  }
  finally {
    [Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
    [void][RunnerService.Lsa]::LsaClose($handle)
  }
}

# Why a service logon of this account will fail before anybody types a password, or $null. A Microsoft account on a
# device that requires Windows Hello for it (passwordless sign-in) is checked against a cached password that is often
# not there: the service fails with event 7038 "user name or password is incorrect" (2026-11-27, tasks-vault).
function Get-LogonProblem([string] $Source, [string] $Passwordless) {
  if (-not $Source) {
    $Source = try { [string] (Get-LocalUser -Name $env:USERNAME -ErrorAction Stop).PrincipalSource } catch { '' }
  }
  if (-not $Passwordless) {
    $Passwordless = try { [string] (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device' -ErrorAction Stop).DevicePasswordLessBuildVersion } catch { '' }
  }
  if ($Source -eq 'MicrosoftAccount' -and $Passwordless -eq '2') {
    return 'a Microsoft account with "require Windows Hello sign-in" on: a service cannot log on with it (event 7038). ' +
      'Turn that setting off (Settings > Accounts > Sign-in options), sign in once with the account password, then install; ' +
      'or run the runner under a local account'
  }
  return $null
}

function Get-Plan([string] $Dir) {
  [pscustomobject]@{
    Runner      = Split-Path $Dir -Leaf
    Service     = Get-RunnerServiceName $Dir
    Program     = Join-Path $Dir 'bin\RunnerService.exe'
    Account     = '{0}\{1}' -f $env:USERDOMAIN, $env:USERNAME
    EmptiedVars = @(Get-ServiceEnvironmentOverride $EnvNames)
  }
}

if ($LibraryOnly) { return }

$ErrorActionPreference = 'Stop'
if (($env:NVIM_MACHINE_ROLE + '') -ieq 'workstation') { Write-Output 'not on the workstation: no runner runs there'; exit 2 }
if ($Action -eq 'status') {
  if (-not (Test-Path $Root)) { Write-Output "no runners: $Root"; exit 0 }
  foreach ($d in Get-ChildItem $Root -Directory | Where-Object { Test-RunnerService $_.FullName }) {
    $svcName = (Get-Content (Join-Path $d.FullName '.service') -Raw).Trim()
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    Write-Output ('{0,-16} service {1}: {2}' -f $d.Name, $svcName, $(if ($svc) { $svc.Status } else { 'MISSING (the .service names no service)' }))
  }
  exit 0
}
if (-not $Repo) { Write-Output "usage: runner_service.ps1 $Action <runner folder name>"; exit 2 }
$dir = Join-Path $Root $Repo
if (-not (Test-Path (Join-Path $dir 'run.cmd'))) { Write-Output "unknown runner: $Repo (no $dir\run.cmd)"; exit 2 }
$plan = Get-Plan $dir

if ($Action -eq 'plan') {
  Write-Output "runner:   $($plan.Runner)"
  Write-Output "service:  $($plan.Service)  (start: automatic, delayed; restart on failure)"
  Write-Output "program:  $($plan.Program)"
  Write-Output "account:  $($plan.Account)  (its password is asked in the elevated window at install)"
  Write-Output "emptied:  $(if ($plan.EmptiedVars.Count) { ($plan.EmptiedVars | ForEach-Object { $_.TrimEnd('=') }) -join ', ' } else { '(none)' })"
  Write-Output "state:    $(if (Test-RunnerService $dir) { 'runs as a service already' } else { 'started by runners.ps1' })"
  $problem = Get-LogonProblem $AccountSource $PasswordLess
  if ($problem) { Write-Output "warning: $problem"; exit 1 }
  if (-not (Test-Path $plan.Program)) { Write-Output "warning: $($plan.Program) is missing (an old runner version?)"; exit 1 }
  exit 0
}

if (-not (Test-Elevated)) {
  Write-Output "$Action needs an elevated PowerShell: open one with `"Run as administrator`" and run"
  Write-Output "  pwsh `"$PSCommandPath`" $Action $Repo"
  exit 2
}

if ($Action -eq 'install') {
  if (Test-RunnerService $dir) {
    $existing = Get-Service -Name $plan.Service -ErrorAction SilentlyContinue
    if ($existing -and $existing.Status -eq 'Running') { Write-Output "$Repo runs as a service already ($($plan.Service))"; exit 0 }
    Write-Output "$Repo has a .service but its service is $(if ($existing) { $existing.Status } else { 'missing' }): run `"runner_service.ps1 remove $Repo`" first"
    exit 1
  }
  $problem = Get-LogonProblem $AccountSource $PasswordLess
  if ($problem) { Write-Output "not installed: $problem"; exit 1 }
  if (-not (Test-Path $plan.Program)) { Write-Output "missing $($plan.Program)"; exit 1 }
  & (Join-Path $PSScriptRoot 'runners.ps1') stop $Repo
  $cred = Get-Credential -UserName $plan.Account -Message "Password of $($plan.Account) for the runner service $($plan.Service) (goes to the service manager only)"
  if (-not $cred) { Write-Output 'no password given: nothing installed'; exit 1 }
  Grant-ServiceLogonRight $plan.Account
  New-Service -Name $plan.Service -BinaryPathName "`"$($plan.Program)`"" -DisplayName "GitHub Actions Runner ($($plan.Runner))" `
    -Description 'Self-hosted runner in session 0 (no window on the desktop). nvim-config scripts/runner_service.ps1.' `
    -StartupType AutomaticDelayedStart -Credential $cred | Out-Null
  $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$($plan.Service)"
  if ($plan.EmptiedVars.Count) { New-ItemProperty -Path $key -Name Environment -PropertyType MultiString -Value $plan.EmptiedVars -Force | Out-Null }
  & sc.exe failure $plan.Service reset= 86400 actions= restart/60000/restart/60000/restart/300000 | Out-Null
  Set-Content -Path (Join-Path $dir '.service') -Value $plan.Service -NoNewline -Encoding ascii
  try { Start-Service -Name $plan.Service }
  catch {
    # Never leave the runner without a listener: take the service out again and start the runner the usual way.
    $why = $_.Exception.Message
    $logon = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 7038; StartTime = (Get-Date).AddMinutes(-5) } -MaxEvents 5 -ErrorAction SilentlyContinue |
      Where-Object { $_.Message -match [regex]::Escape($plan.Service) } | Select-Object -First 1
    & sc.exe delete $plan.Service | Out-Null
    Remove-Item (Join-Path $dir '.service') -ErrorAction SilentlyContinue
    Write-Output "the service did not start: $why"
    if ($logon) { Write-Output '  the logon failed (event 7038: user name or password is incorrect)' }
    Write-Output '  rolled back: the service is deleted, the runner starts the usual way again'
    & (Join-Path $PSScriptRoot 'runners.ps1') start $Repo
    exit 1
  }
  Write-Output "$Repo runs as the service $($plan.Service); check: pwsh scripts/runners.ps1 status $Repo"
  exit 0
}

if ($Action -eq 'remove') {
  $svc = Get-Service -Name $plan.Service -ErrorAction SilentlyContinue
  if ($svc) {
    if ($svc.Status -ne 'Stopped') { Stop-Service -Name $plan.Service -Force }
    & sc.exe delete $plan.Service | Out-Null
  }
  Remove-Item (Join-Path $dir '.service') -ErrorAction SilentlyContinue
  Write-Output "$Repo is no service any more; starting it the usual way"
  & (Join-Path $PSScriptRoot 'runners.ps1') start $Repo
  exit $LASTEXITCODE
}
