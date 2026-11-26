<#
.SYNOPSIS
  Richtet Claude Code auf dieser Maschine gemaess der in diesem Ordner
  versionierten Vorlagen ein (Env-Vars, ~/.claude/CLAUDE.md,
  ~/.claude/settings.json). Idempotent - auf jeder Maschine (und nach jedem
  Pull) erneut ausfuehrbar.

.USAGE
  pwsh -File setup-claude-code.ps1
#>

$ErrorActionPreference = 'Stop'

# CDX -> NOTES -> docs -> nvim-config-root
$nvimConfig = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
$claudeDir  = Join-Path $HOME '.claude'

Write-Host "NVIM_CONFIG_DIR = $nvimConfig"

# --- 1. Env-Variablen (User-Scope) -----------------------------------------

function Set-UserEnvVar($name, $value) {
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($current -eq $value) {
        Write-Host "  $name bereits korrekt gesetzt."
        return
    }
    [Environment]::SetEnvironmentVariable($name, $value, 'User')
    Write-Host "  $name gesetzt: $value"
}

Write-Host "`n[1/3] Env-Variablen"
Set-UserEnvVar -name 'NVIM_CONFIG_DIR' -value $nvimConfig
# Alter Name, fuer aeltere Skripte/Notizen weiter gesetzt.
Set-UserEnvVar -name 'NVIM_CONFIG' -value $nvimConfig

$reposDir = [Environment]::GetEnvironmentVariable('REPOS_DIR', 'User')
if (-not $reposDir) {
    do {
        $reposDir = Read-Host '  REPOS_DIR ist auf dieser Maschine nicht gesetzt. Pfad zur Repos-Wurzel eingeben (z.B. B:\repos)'
        if ($reposDir -and -not (Test-Path $reposDir)) {
            Write-Host "  Pfad '$reposDir' existiert nicht - bitte erneut eingeben." -ForegroundColor Yellow
            $reposDir = $null
        }
    } while (-not $reposDir)
    Set-UserEnvVar -name 'REPOS_DIR' -value $reposDir
} else {
    Write-Host "  REPOS_DIR bereits gesetzt: $reposDir"
}

# RULES_VAULT: Wurzel des Repos rules-vault (Regelwerke, rulesets/lua und rulesets/native). Jede Sitzung laedt dessen
# Kontext-Dokumente (Schritt [rules] unten), deshalb wird er hier geklont bzw. per ff-Pull aktuell gehalten; mit
# fremden Aenderungen oder auf einem anderen Branch nur eine Warnung (rules-vault.js ensure, nur git).
$rulesVault = [Environment]::GetEnvironmentVariable('RULES_VAULT', 'User')
$rulesVaultDir = if ($rulesVault) { $rulesVault } else { Join-Path $reposDir 'rules-vault' }
$rulesVaultJs = Join-Path $PSScriptRoot 'rules-vault.js'
if (Get-Command node -ErrorAction SilentlyContinue) {
    node $rulesVaultJs ensure $rulesVaultDir
} else {
    Write-Host "  node fehlt: rules-vault nicht geklont/aktualisiert." -ForegroundColor Yellow
}
if (-not $rulesVault) {
    $candidate = Join-Path $reposDir 'rules-vault'
    if (Test-Path $candidate) {
        Set-UserEnvVar -name 'RULES_VAULT' -value $candidate
    } else {
        Write-Host "  RULES_VAULT nicht gesetzt und $candidate fehlt: Repo rules-vault klonen, dann das Skript erneut ausfuehren." -ForegroundColor Yellow
    }
} else {
    Write-Host "  RULES_VAULT bereits gesetzt: $rulesVault"
}

# TESTING_TRUST_ROOTS: testing.nvim fuehrt die .testing.lua eines Projekts erst aus, wenn es vertraut ist (Workspace
# trust, docs/CONFIG.md). Alle eigenen Repos unter $REPOS_DIR gelten als vertraut; sonst enden lokale Laeufe
# (scripts/test.sh, :Testing) mit Exit 2. Eine schon gesetzte Liste (mehrere Wurzeln, ';'-getrennt) bleibt stehen.
$trustRoots = [Environment]::GetEnvironmentVariable('TESTING_TRUST_ROOTS', 'User')
if (-not $trustRoots) {
    Set-UserEnvVar -name 'TESTING_TRUST_ROOTS' -value $reposDir
} else {
    Write-Host "  TESTING_TRUST_ROOTS bereits gesetzt: $trustRoots"
}

# PATH: die Befehle der Lua-Plugins aus ihren Checkouts, die Meldungen und Doku nennen: `testing`
# (z.B. "after a review: testing ci trust ..."), `tasks` und `rules` (je <repo>/bin/<befehl>.cmd). Ohne sie gibt es
# die Befehle nicht. Die Befehle der nativen Apps (tasks-desktop, hub-desktop, ...) legt deren install an
# (%LOCALAPPDATA%\appkit-family\bin), nicht dieses Skript. Roh ueber die Registry gelesen und als REG_EXPAND_SZ
# geschrieben: [Environment]::SetEnvironmentVariable wuerde %VAR%-Eintraege aufloesen.
foreach ($cli in @(
        @{ name = 'testing'; repo = 'testing.nvim' },
        @{ name = 'tasks'; repo = 'tasks.nvim' },
        @{ name = 'rules'; repo = 'rules.nvim' })) {
    $cliBin = Join-Path $reposDir "$($cli.repo)\bin"
    if (-not (Test-Path (Join-Path $cliBin "$($cli.name).cmd"))) {
        Write-Host "  $cliBin fehlt: Befehl $($cli.name) nicht auf dem PATH ($($cli.repo) klonen/pullen, Skript erneut ausfuehren)." -ForegroundColor Yellow
        continue
    }
    $envKey = Get-Item 'HKCU:\Environment'
    $userPath = $envKey.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
    $entries = @($userPath -split ';' | Where-Object { $_ })
    if ($entries | Where-Object { $_.TrimEnd('\') -ieq $cliBin }) {
        Write-Host "  PATH enthaelt bereits $cliBin"
    } else {
        Set-ItemProperty -Path 'HKCU:\Environment' -Name 'Path' -Value (($entries + $cliBin) -join ';') -Type ExpandString
        # Set-ItemProperty sendet kein WM_SETTINGCHANGE; das unveraenderte Neusetzen einer anderen Variable ueber .NET
        # tut es, damit neu gestartete Shells den PATH sehen.
        [Environment]::SetEnvironmentVariable('REPOS_DIR', $reposDir, 'User')
        Write-Host "  PATH ergaenzt: $cliBin (neue Shells; die App erst nach einem Neustart)"
    }
}
# Kontrolle wie in einer neuen PowerShell: der PATH aus der Registry, darin <befehl>.cmd. Ein Alias oder eine Funktion
# gleichen Namens (Profil, z.B. zoxide) gewinnt in PowerShell vor dem .cmd: das wird genannt. Ohne Shim geht immer die
# lange Form, als einfache Zeile zum Kopieren (ohne Prompt-Zeichen).
$freshPath = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine'),
    [Environment]::GetEnvironmentVariable('Path', 'User')
) -join ';'
foreach ($name in @('testing', 'tasks', 'rules')) {
    $shim = $freshPath -split ';' | Where-Object { $_ } |
        ForEach-Object { Join-Path ([Environment]::ExpandEnvironmentVariables($_)) "$name.cmd" } |
        Where-Object { Test-Path $_ } | Select-Object -First 1
    $shadow = Get-Command $name -CommandType Alias, Function -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $shim) {
        Write-Host "  $name nicht auf dem PATH einer neuen Shell; Ersatz:" -ForegroundColor Yellow
        Write-Host "    nvim -n -i NONE --headless -u NONE -l $($reposDir.Replace('\', '/'))/$name.nvim/scripts/$name.lua <befehl>"
    } elseif ($shadow) {
        Write-Host "  $name ist in dieser PowerShell ein $($shadow.CommandType) ($($shadow.Definition)) und ueberdeckt $shim" -ForegroundColor Yellow
    } else {
        Write-Host "  $name -> $shim (neue PowerShell pruefen: Get-Command $name)"
    }
}

# TASKS_VAULT: Wurzel des Repos tasks-vault (Task-Vault: Areas mit ROADMAP/tasks, Backlog, Notizen, TOOLS). Der Hub
# von tasks-desktop und die CLI von tasks.nvim lesen sie; der Vault ist seit 2026-10-12 ein eigenes Repo, nicht
# mehr ein Ordner in WKDBooks. Auf jeder Maschine liegt er unter $REPOS_DIR/tasks-vault.
$tasksVault = [Environment]::GetEnvironmentVariable('TASKS_VAULT', 'User')
if (-not $tasksVault) {
    $candidate = Join-Path $reposDir 'tasks-vault'
    if (Test-Path $candidate) {
        Set-UserEnvVar -name 'TASKS_VAULT' -value $candidate
    } else {
        Write-Host "  TASKS_VAULT nicht gesetzt und $candidate fehlt: Repo tasks-vault klonen, dann das Skript erneut ausfuehren." -ForegroundColor Yellow
    }
} else {
    Write-Host "  TASKS_VAULT bereits gesetzt: $tasksVault"
}

# TASKS_MARKER_DOCS: Dokumente mit `<!-- GENERATED:plan ... -->`-Bloecken, die `tasks done` nach jedem Abschluss neu
# erzeugt (kommagetrennt; die CLI hat kein `setup`). Das Mobile-Projektdokument liegt im tasks-vault; vorhandene
# Eintraege bleiben, der Pfad wird nur ergaenzt.
$markerDoc = if ($reposDir) { Join-Path $reposDir 'tasks-vault\ALL\ROADMAP\projects\mobile-integration-mobil-apps-der-familien.md' } else { $null }
if ($markerDoc -and (Test-Path $markerDoc)) {
    $cur = [Environment]::GetEnvironmentVariable('TASKS_MARKER_DOCS', 'User')
    $have = @(($cur -split ',') | Where-Object { $_ })
    if ($have | Where-Object { $_.Trim() -ieq $markerDoc }) {
        Write-Host "  TASKS_MARKER_DOCS enthaelt bereits $markerDoc"
    } else {
        Set-UserEnvVar -name 'TASKS_MARKER_DOCS' -value (($have + $markerDoc) -join ',')
    }
} else {
    Write-Host "  TASKS_MARKER_DOCS: Mobile-Projektdokument fehlt (tasks-vault pullen, Skript erneut ausfuehren)." -ForegroundColor Yellow
}

# NVIM_MACHINE_ROLE (workstation | unset = privater Rechner) wird hier nicht gesetzt: lua/machine.lua der nvim-Config
# liest sie schon, und die Claude-Regeln (CLAUDE.global.md, Abschnitt Maschine) lesen dieselbe Variable. Gelesen wie
# machine.lua: Prozess-Umgebung, lower(), nur bekannte Rollen. Ist sie dort leer, aber im User- oder Machine-Scope
# gesetzt, kennt diese Shell sie nur noch nicht (Neustart noetig).
# BEGIN machine-role
$roleRaw = $env:NVIM_MACHINE_ROLE
$roleNote = ''
if (-not $roleRaw) {
    foreach ($scope in 'User', 'Machine') {
        $scopeValue = [Environment]::GetEnvironmentVariable('NVIM_MACHINE_ROLE', $scope)
        if ($scopeValue) {
            $roleRaw = $scopeValue
            $roleNote = " (nur im $scope-Scope; diese Shell/App kennt sie erst nach einem Neustart)"
            break
        }
    }
}
$machineRole = if ($roleRaw) { $roleRaw.ToLowerInvariant() } else { '' }
$isWorkstation = $machineRole -eq 'workstation'
if ($isWorkstation) {
    Write-Host "  Maschine: workstation (NVIM_MACHINE_ROLE)$roleNote" -ForegroundColor Yellow
} elseif ($machineRole -eq '' -or $machineRole -eq 'default') {
    Write-Host "  Maschine: privater Rechner (NVIM_MACHINE_ROLE$(if ($machineRole) { '=default' } else { ' nicht gesetzt' }))$roleNote"
    if (-not $machineRole -and ($env:USERDOMAIN -eq 'AzureAD' -or $env:COMPUTERNAME -like 'TRI-*')) {
        Write-Host "  Achtung: AzureAD-/TRI-Rechner ohne NVIM_MACHINE_ROLE. Ist das die Workstation, zuerst von Hand setzen:" -ForegroundColor Yellow
        Write-Host "    setx NVIM_MACHINE_ROLE workstation   (dann Terminal/App neu starten und dieses Skript erneut ausfuehren)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Maschine: unbekannte NVIM_MACHINE_ROLE '$roleRaw'$roleNote - nvim nimmt 'default'; Tippfehler?" -ForegroundColor Yellow
}
# END machine-role

Write-Host "  Hinweis: neu gesetzte User-Env-Vars gelten erst in neuen Shells/Sessions."

# --- 2. ~/.claude/CLAUDE.md (Symlink, Fallback Kopie) -----------------------

Write-Host "`n[2/3] CLAUDE.md"
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null

$claudeMdSource = Join-Path $PSScriptRoot 'CLAUDE.global.md'
$claudeMdTarget = Join-Path $claudeDir 'CLAUDE.md'

$targetItem = Get-Item -Path $claudeMdTarget -ErrorAction SilentlyContinue
$alreadyLinked = $targetItem -and $targetItem.LinkType -and ($targetItem.Target -eq $claudeMdSource)

if ($alreadyLinked) {
    Write-Host "  Symlink bereits korrekt."
} else {
    if (Test-Path $claudeMdTarget) {
        $backup = "$claudeMdTarget.bak-$(Get-Date -Format 'yyyyMMdd-HHmmssfff')"
        Move-Item $claudeMdTarget $backup -Force
        Write-Host "  Bestehende CLAUDE.md gesichert nach: $backup"
    }
    try {
        New-Item -ItemType SymbolicLink -Path $claudeMdTarget -Target $claudeMdSource | Out-Null
        Write-Host "  Symlink angelegt: $claudeMdTarget -> $claudeMdSource"
    } catch {
        Copy-Item $claudeMdSource $claudeMdTarget
        Write-Host "  Kein Symlink moeglich (Developer Mode / Admin noetig) - stattdessen kopiert."
        Write-Host "  Bei Aenderungen an CLAUDE.global.md dieses Skript erneut ausfuehren."
    }
}

# --- 3. ~/.claude/settings.json (Merge, ueber gemeinsames Node-Skript) -----
# Merge-Logik lebt in merge-claude-settings.js, geteilt mit
# setup-claude-code.sh (Linux/macOS), damit beide Plattformen nicht
# auseinanderlaufen.

Write-Host "`n[3/3] settings.json"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "node nicht gefunden. Wird sowohl fuer den Merge als auch fuer check-lua-hook.js gebraucht - bitte Node.js installieren und Skript erneut ausfuehren."
}

$templatePath = Join-Path $PSScriptRoot 'settings.global.json'
$settingsPath = Join-Path $claudeDir 'settings.json'
$mergeScript = Join-Path $PSScriptRoot 'merge-claude-settings.js'

node $mergeScript $templatePath $settingsPath $nvimConfig

# --- ~/.claude/rules: Kontext-Dokumente aus dem rules-vault -----------------
# Claude Code laedt ~/.claude/rules/*.md beim Start jeder Sitzung ohne Freigabedialog (Symlinks erlaubt). Je Datei
# rulesets/arbeit/kontext/*.md ein Link rules-vault-<name>.md (Fallback Kopie), auf der Workstation zusaetzlich
# kontext/workstation/*.md. Fremde Dateien in rules/ bleiben unberuehrt. $HOME ist das echte Profil (die
# MSIX-Virtualisierung der Claude-App betrifft nur AppData), also derselbe Ordner, den die App liest.
Write-Host "`n[rules] ~/.claude/rules aus dem rules-vault"
$rulesVaultNow = [Environment]::GetEnvironmentVariable('RULES_VAULT', 'User')
# '-' = kein Vault (ein leeres Argument verschluckt PowerShell 5.1 beim Aufruf von node)
$linkArgs = @('link', $(if ($rulesVaultNow) { $rulesVaultNow } else { '-' }), $claudeDir)
if ($isWorkstation) { $linkArgs += '--workstation' }
node $rulesVaultJs @linkArgs

# --- LuaLS-Config fuer die Repos-Wurzel ------------------------------------
# Sitzungen mit cwd = $REPOS_DIR starten (Plugin lua-lsp) einen LuaLS ueber den
# ganzen Repos-Baum; ohne diese Datei laedt er tausende Dateien inkl. Worktrees
# vor (gemessen bis 5 GB). Kopie statt Link, damit kein Symlink-Recht noetig ist.
Write-Host "`n[luals] .luarc.jsonc fuer die Repos-Wurzel"
& (Join-Path $PSScriptRoot 'install-repos-luarc.ps1') -ReposDir $reposDir

# --- 4. Globale Git-Hooks (pre-push: kein Force-Push ueber fremde Commits) -----

Write-Host "`n[git] Globale Hooks"
$hookSource = if ($reposDir) { Join-Path $reposDir 'tasks-vault/TOOLS/scripts/git-global-hooks' } else { $null }
$hookTarget = Join-Path $HOME '.config/git/global-hooks'
if (-not $hookSource -or -not (Test-Path $hookSource)) {
    Write-Host "  Quelle fehlt ($hookSource): Repo tasks-vault klonen, dann das Skript erneut ausfuehren." -ForegroundColor Yellow
} else {
    New-Item -ItemType Directory -Path $hookTarget -Force | Out-Null
    # Alle Dateien (pre-push = Guard, die uebrigen reichen an den Hook des Repos weiter); Copy-Item laesst die LF-Zeilenenden (sh).
    Get-ChildItem $hookSource -File | ForEach-Object { Copy-Item $_.FullName (Join-Path $hookTarget $_.Name) -Force }
    $hooksPath = (git config --global --get core.hooksPath)
    $wanted = $hookTarget.Replace('\', '/')
    if (-not $hooksPath) {
        git config --global core.hooksPath $wanted
        Write-Host "  core.hooksPath gesetzt: $wanted"
    } elseif ($hooksPath.Replace('\', '/') -eq $wanted) {
        Write-Host "  core.hooksPath bereits gesetzt."
    } else {
        Write-Host "  core.hooksPath zeigt auf '$hooksPath' (fremd): nicht ueberschrieben. pre-push dort selbst einbinden." -ForegroundColor Yellow
    }
    Write-Host "  Hinweis: History-Rewrites brauchen ALLOW_FORCE_PUSH=1 (TOOLS/history-rewrite-runbook.md)."
}

# merge=ours in .gitattributes (generierte docs/map): Git kennt den Treiber nur, wenn er pro Rechner konfiguriert ist.
# Ohne ihn bleibt es beim Konflikt in pull --rebase --autostash, sobald eine Sitzung die Karte neu erzeugt hat.
git config --global merge.ours.driver true
Write-Host "  merge.ours.driver gesetzt."

# Der pre-push des Vaults liegt in .git/hooks (nicht versioniert, der globale Hook ruft ihn auf): prueft den gepushten
# Commit im Snapshot, nicht den geteilten Arbeitsbaum. Auf der Workstation wird testing ci abgelehnt, der Hook wuerde
# dort jeden Push blockieren.
Write-Host "`n[git] pre-push-Gate von tasks-vault"
$vaultRoot = if ($reposDir) { Join-Path $reposDir 'tasks-vault' } else { $null }
$testingDriver = if ($reposDir) { Join-Path $reposDir 'testing.nvim/scripts/testing.lua' } else { $null }
if ($isWorkstation) {
    Write-Host "  Workstation: nicht installiert (dort prueft nur die CI)."
} elseif (-not $vaultRoot -or -not (Test-Path $vaultRoot) -or -not (Test-Path $testingDriver)) {
    Write-Host "  tasks-vault oder testing.nvim fehlt unter '$reposDir': klonen, dann das Skript erneut ausfuehren." -ForegroundColor Yellow
} elseif (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host "  nvim nicht auf dem PATH: Hook nicht installiert." -ForegroundColor Yellow
} else {
    & nvim -n -i NONE --headless -u NONE -l $testingDriver ci hook install --run=fast --verify=fast --snapshot "--root=$vaultRoot"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Hook nicht installiert (Exit $LASTEXITCODE), siehe Ausgabe oben." -ForegroundColor Yellow
    }
}

# WKDBook-Tricentis und tricentis-vault werden nur von Hand gepusht (Kundendaten, Arbeitsaufgaben): der pre-push fragt
# nach (Terminal oder Neovim) und weist jeden unbestaetigten Push ab - Claude, Agenten, Plugin-Jobs, GUI-Clients.
# Auf jeder Maschine, auch der Workstation. Ein fremder pre-push bleibt, wie er ist (install.sh meldet ihn).
Write-Host "`n[git] pre-push nur von Hand: WKDBook-Tricentis, tricentis-vault"
$manualPushRepos = @()
if ($reposDir) {
    foreach ($name in @('WKDBook-Tricentis', 'tricentis-vault')) {
        $path = Join-Path $reposDir $name
        if (Test-Path (Join-Path $path '.git')) { $manualPushRepos += $path.Replace('\', '/') }
        else { Write-Host "  $name fehlt unter '$reposDir': uebersprungen." }
    }
}
# Der bash von Git for Windows, nicht der aus WindowsApps (WSL): der kennt keine Windows-Pfade wie C:/repos.
$bash = $null
if (Get-Command git -ErrorAction SilentlyContinue) {
    $candidate = Join-Path (Split-Path (Split-Path (Get-Command git).Source)) 'bin/bash.exe'
    if (Test-Path $candidate) { $bash = $candidate }
}
if (-not $bash) {
    $found = (Get-Command bash -ErrorAction SilentlyContinue).Source
    if ($found -and $found -notmatch 'WindowsApps') { $bash = $found }
}
$installSh = (Join-Path $PSScriptRoot '../../../scripts/git-hooks/install.sh').Replace('\', '/')
if ($manualPushRepos.Count -eq 0) {
    Write-Host "  Keines der beiden Repos vorhanden: nichts installiert."
} elseif (-not $bash) {
    Write-Host "  bash nicht gefunden (Git for Windows): Hook nicht installiert." -ForegroundColor Yellow
} else {
    & $bash $installSh --manual-push-only @manualPushRepos
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Nicht ueberall installiert (Exit $LASTEXITCODE), siehe Ausgabe oben." -ForegroundColor Yellow
    }
}

Write-Host "`n[git] Commit-Signatur (Geraete-Registry fuer den runner-guard von testing.nvim)"
& (Join-Path $PSScriptRoot 'setup-git-signing.ps1')

$installTools = Join-Path $PSScriptRoot '..\..\..\scripts\install-tools\install-tools.ps1'
Write-Host "`n[optional] Dev-Toolchains (nvim/cpp/rust/web/tauri) per winget installieren?"
if ($isWorkstation) {
    # install-tools itself leaves out the ai family's tools there; build toolchains are allowed
    Write-Host "  Workstation: Bau-Toolchains ja; die Tools der ai-Familie werden hier ausgelassen." -ForegroundColor Yellow
}
Write-Host "  Was auf dieser Maschine schon da ist:"
& $installTools -Status
$profileAnswer = Read-Host '  Profile kommagetrennt (nvim,cpp,rust,web,tauri), all = alle, leer = ueberspringen'
if ($profileAnswer) {
    & $installTools -Profile ($profileAnswer -split '[,\s]+' | Where-Object { $_ })
}
Write-Host "  Die CLI-Tools der Plugins (lazygit, pandoc, poppler, ...) bringt nach dem Klonen der Repos:"
Write-Host "  pwsh -File `"$installTools`" -List   (dann ohne -List zum Installieren)"

Write-Host "`nFertig."
