# rauchmelder.ps1 -- the smoke detector of the installed config: runs every test sheet of $NVIM_CONFIG_DIR once a day
# and files a task in the vault when one is red (or when the run cannot start). Red is a hint, never a push blocker.
#
#   pwsh -NoProfile -File scripts/rauchmelder.ps1             one run now
#   pwsh -NoProfile -File scripts/rauchmelder.ps1 -Install    a daily scheduled task "nvim-config Rauchmelder" at 09:30
#   pwsh -NoProfile -File scripts/rauchmelder.ps1 -Uninstall  removes it again
#
# Why: `testing sheets run --all --root $NVIM_CONFIG_DIR` would have shown the gopath rename (M-o broken from
# 2026-09-21) on the same day. Task nvim-config/rauchmelder-blaetter-der-installierten-config-regelmaessig-l.
#
# The config must be trusted by testing.nvim once (`testing trust add $NVIM_CONFIG_DIR`): a sheet run executes its
# .testing.lua and specs. Until then every run ends with exit 2 and files a "does not run" task, once a day.
#
# Logs: %LOCALAPPDATA%\nvim-rauchmelder\<date>.log (the last 30 are kept). A task is filed at most once a day
# (slug rauchmelder-<rot|laeuft-nicht>-<date>), committed with its own paths only and pushed: the vault is a shared
# checkout, nothing else of it is touched.

param(
  [switch]$Install,
  [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$TaskName = 'nvim-config Rauchmelder'

if ($Install) {
  $action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-NoProfile -NonInteractive -File `"$PSCommandPath`""
  $trigger = New-ScheduledTaskTrigger -Daily -At '09:30'
  # A missed run (machine off at 09:30) runs at the next start; never two at once.
  $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Hours 1)
  Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
  Write-Output "registered: $TaskName, daily 09:30 (remove with -Uninstall)"
  exit 0
}
if ($Uninstall) {
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
  Write-Output "removed: $TaskName"
  exit 0
}

$config = $env:NVIM_CONFIG_DIR
$repos = $env:REPOS_DIR
if (-not $config -or -not $repos) {
  Write-Error 'NVIM_CONFIG_DIR and REPOS_DIR must be set (setup-claude-code.ps1)'
  exit 2
}
$vault = Join-Path $repos 'tasks-vault'
$testing = Join-Path $repos 'testing.nvim/scripts/testing.lua'
$tasksLua = Join-Path $repos 'tasks.nvim/scripts/tasks.lua'

$logDir = Join-Path $env:LOCALAPPDATA 'nvim-rauchmelder'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$day = Get-Date -Format 'yyyy-MM-dd'
$log = Join-Path $logDir "$day.log"

Push-Location $config
try {
  & nvim -n -i NONE --headless -u NONE -l $testing sheets run --all --root $config *> $log
  $code = $LASTEXITCODE
} finally {
  Pop-Location
}
Get-ChildItem $logDir -Filter '*.log' | Sort-Object Name -Descending | Select-Object -Skip 30 | Remove-Item -Force

if ($code -eq 0) {
  Write-Output "green ($log)"
  exit 0
}

# Red (1) or not run (2 and anything else): one task a day, with the lines that say why.
$kind = if ($code -eq 1) { 'rot' } else { 'laeuft-nicht' }
$slug = "rauchmelder-$kind-$day"
if (Test-Path (Join-Path $vault "nvim-config/ROADMAP/tasks/$slug.md")) {
  Write-Output "already filed today: $slug"
  exit $code
}
$lines = Get-Content $log | Where-Object { $_ -match 'FAIL|fail|red|not trusted|error' } | Select-Object -First 8
if (-not $lines) { $lines = Get-Content $log -Tail 8 }
$summary = (($lines -join ' / ') -replace '\s+', ' ')
if ($summary.Length -gt 600) { $summary = $summary.Substring(0, 600) + ' ...' }
$title = if ($code -eq 1) { "Rauchmelder: Blätter der Config rot am $day" } else { "Rauchmelder: Blattlauf der Config lief am $day nicht (exit $code)" }

Push-Location $vault
try {
  & nvim -n -i NONE --headless -u NONE -l $tasksLua new nvim-config $title --kind=bug --prio=2 --effort=S --value=4 `
    --tags=sheets,not-on-workstation --slug=$slug "--summary=$summary (Protokoll: $log)" | Out-Null
  $paths = @("nvim-config/ROADMAP/tasks/$slug.md", 'nvim-config/ROADMAP/TASKS.md', 'nvim-config/Backlog/README.md') |
    Where-Object { Test-Path $_ }
  git add -- $paths
  git commit -q -m "nvim-config: $title" -- $paths
  git pull -q --rebase --autostash
  git push -q
} finally {
  Pop-Location
}
Write-Output "filed: nvim-config/$slug ($log)"
exit $code
