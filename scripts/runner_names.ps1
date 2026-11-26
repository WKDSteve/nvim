# scripts/runner_names.ps1 -- the folders of the self-hosted runners and the repositories they serve.
#
# Dot-sourced by runners.ps1. One runner of a repository lives in <root>\<repo>; a further instance of the same
# repository (jobs of one run in parallel) in <root>\<repo>+<n>, registered on GitHub as <COMPUTERNAME>-<repo>-<n>
# (tasks-vault/TOOLS/scripts/self-hosted-runner/setup-runner.ps1 -Instance <n>). Plain functions, no I/O except
# the folder listing of Expand-RunnerFolder, so a spec can call them (TESTS/plugin_repos/runner_names_spec.lua).

# The repository a runner folder serves: the name without a trailing +<n>.
function Get-RunnerRepo([string] $folder) {
  return ($folder -replace '\+\d+$', '')
}

# The end of the runner's name on GitHub: -<repo> for the first instance, -<repo>-<n> for a further one.
function Get-RunnerRemoteSuffix([string] $folder) {
  if ($folder -match '^(.+)\+(\d+)$') { return "-$($Matches[1])-$($Matches[2])" }
  return "-$folder"
}

# Whether a program path lies in the folder of this runner: <root>\<folder>\ with the backslash, so the folder
# tasks-desktop does not claim the listener of tasks-desktop+2. Case does not matter (Windows paths). Built by hand,
# not with Join-Path: pwsh on Linux (the hosted CI) would join with / and no Windows path would ever match.
function Test-RunnerOwnsPath([string] $root, [string] $folder, [string] $path) {
  if (-not $path) { return $false }
  $dir = ($root.Replace('/', '\').TrimEnd('\') + '\' + $folder + '\').ToLowerInvariant()
  return $path.Replace('/', '\').ToLowerInvariant().StartsWith($dir)
}

# The runner folders a request names: `all` is every folder below the root (none that starts with _ or .); a name
# is that folder and each further instance of it (<name>+<n>); a folder name with +<n> is just that one. A name with
# no folder stays in the list, so the caller can report it as unknown.
function Expand-RunnerFolder([string] $root, [string[]] $requested) {
  $folders = @(Get-ChildItem $root -Directory | Where-Object { $_.Name -notmatch '^[_.]' } | Select-Object -ExpandProperty Name)
  if ($requested -contains 'all') { return $folders }
  $out = [System.Collections.Generic.List[string]]::new()
  foreach ($r in $requested) {
    $hit = @($folders | Where-Object { $_ -eq $r -or ($r -notmatch '\+\d+$' -and $_ -match ('^' + [regex]::Escape($r) + '\+\d+$')) })
    if ($hit.Count -eq 0) { $hit = @($r) }
    foreach ($h in ($hit | Sort-Object)) { if (-not $out.Contains($h)) { $out.Add($h) } }
  }
  return $out.ToArray()
}
