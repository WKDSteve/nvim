<#
.SYNOPSIS
  Commit signing of this device and its entry in the device registry (git-allowed-signers).
  Idempotent; called by setup-claude-code.ps1, also runnable on its own.

.DESCRIPTION
  Each device signs its commits with an SSH key of its own, without a passphrase (commits run unattended, also from
  Claude sessions). Its public key goes into git-allowed-signers next to this script: the device registry that the
  runner-guard of testing.nvim reads (TESTING_ALLOWED_SIGNERS). A push run of a public repository then goes through
  without `testing ci trust` when every new commit is signed by a key of the registry
  (testing.nvim docs/RUNNER-GUARD.md). Removing a device = deleting its line.

.USAGE
  pwsh -File setup-git-signing.ps1
#>

$ErrorActionPreference = 'Stop'

$signers = (Join-Path $PSScriptRoot 'git-allowed-signers').Replace('\', '/')
$keyFile = (Join-Path $HOME '.ssh/git-signing_ed25519').Replace('\', '/')
$device = $env:COMPUTERNAME

$keygen = (Get-Command ssh-keygen -ErrorAction SilentlyContinue).Source
if (-not $keygen) {
    Write-Host "  ssh-keygen fehlt (Windows-Feature 'OpenSSH-Client' oder Git for Windows): Signatur nicht eingerichtet." -ForegroundColor Yellow
    return
}

if (-not (Test-Path $keyFile)) {
    New-Item -ItemType Directory -Path (Split-Path $keyFile) -Force | Out-Null
    # Start-Process joins the arguments as written: '""' is the empty passphrase on every PowerShell version
    Start-Process -FilePath $keygen -Wait -NoNewWindow -ArgumentList @(
        '-q', '-t', 'ed25519', '-N', '""', '-C', "git-signing@$device", '-f', "`"$keyFile`""
    )
    if (-not (Test-Path "$keyFile.pub")) {
        Write-Host "  Signing-Key konnte nicht erzeugt werden ($keyFile)." -ForegroundColor Yellow
        return
    }
    Write-Host "  Signing-Key erzeugt: $keyFile"
} else {
    Write-Host "  Signing-Key vorhanden: $keyFile"
}

git config --global gpg.format ssh
git config --global user.signingkey "$keyFile.pub"
git config --global commit.gpgsign true
git config --global gpg.ssh.allowedSignersFile $signers
Write-Host "  git signiert Commits (gpg.format ssh, commit.gpgsign true)."

$parts = (Get-Content "$keyFile.pub" -Raw).Trim() -split '\s+'
$email = (git config --global user.email)
if (-not $email) { $email = 'unknown' }
$present = (Test-Path $signers) -and (Select-String -Path $signers -SimpleMatch $parts[1] -Quiet)
if ($present) {
    Write-Host "  $device steht bereits in der Registry."
} else {
    # LF only: ssh-keygen reads the registry, a CR would end up in the line
    $line = "$email,$device namespaces=`"git`" $($parts[0]) $($parts[1]) $device`n"
    [IO.File]::AppendAllText($signers, $line, [Text.UTF8Encoding]::new($false))
    Write-Host "  $device in die Registry eingetragen: $signers" -ForegroundColor Yellow
    Write-Host "  -> nvim-Config committen und pushen; auf dem Runner-Rechner pullen." -ForegroundColor Yellow
}

$current = [Environment]::GetEnvironmentVariable('TESTING_ALLOWED_SIGNERS', 'User')
if ($current -ne $signers) {
    [Environment]::SetEnvironmentVariable('TESTING_ALLOWED_SIGNERS', $signers, 'User')
    Write-Host "  TESTING_ALLOWED_SIGNERS gesetzt: $signers"
} else {
    Write-Host "  TESTING_ALLOWED_SIGNERS bereits korrekt gesetzt."
}
