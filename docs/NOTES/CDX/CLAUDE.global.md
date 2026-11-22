# Globale Claude-Code-Regeln (Stefan Bartl)

Diese Datei ist die Quelle der Wahrheit und wird per `setup-claude-code.ps1`
nach `~/.claude/CLAUDE.md` verlinkt (bzw. kopiert, falls kein Symlink möglich
ist). Änderungen hier -> committen/pushen -> auf den anderen Rechnern pullen
und Setup-Skript erneut laufen lassen (bei Symlink reicht sogar nur `git
pull`).

Sie hält nur den Kern, der auch ohne Regel-Vault gelten muss (Rechner ohne
Klon, Cloud-Sitzungen); die Regel-IDs in Klammern verweisen auf den Wortlaut.
**Die übrigen Arbeitsregeln laden aus `~/.claude/rules/rules-vault-*.md`
(Quelle `$RULES_VAULT/rulesets/arbeit`); fehlen sie, `setup-claude-code`
laufen lassen bzw. `$RULES_VAULT/rulesets/arbeit/regeln/` lesen.**
Stack-spezifische Regeln (Lua/Nvim, Rust, C++, Web/Tauri) stehen in der
`CLAUDE.md` des jeweiligen Repos (Vorlagen:
`$NVIM_CONFIG_DIR/docs/NOTES/CDX/templates/`, ausrollen mit
`node new-project-claude.js <stack>`).

## Sprache und Arbeitsweise

- Antworte immer auf Deutsch, auch in Chip-/Background-Tasks; Code,
  Kommentare und Commit-Messages auf Englisch (`ALLG-01`).
- Nie mehr als 1 Agent gleichzeitig (`ALLG-02`); laufend sagen, was gerade
  passiert (`ALLG-03`).

## Maschine: Workstation oder privater Rechner

- Erkennen an `NVIM_MACHINE_ROLE` (dieselbe Variable wie `lua/machine.lua`
  der nvim-Config), PowerShell `$env:NVIM_MACHINE_ROLE`, Bash
  `$NVIM_MACHINE_ROLE` (`$env:…` gibt es in Bash nicht): `workstation` =
  Tricentis-Workstation, leer oder `default` = privater Rechner (`STEVESPC`),
  Groß-/Kleinschreibung egal; jeder andere Wert: nachfragen. Nicht aus dem
  Rechnernamen raten. Leer, aber `USERDOMAIN` ist `AzureAD` oder
  `COMPUTERNAME` beginnt mit `TRI-`: unklar, nachfragen, bevor etwas gebaut
  oder gestartet wird (`MASCHINE-01`).
- Workstation: bauen und eigene Programme laufen lassen ja (auch rustup,
  MSVC, CMake, `cargo build/test`), aber nichts, was CrowdStrike Falcon als
  Angriff lesen kann, und kein Runner (`MASCHINE-02`). Konkret nie:
  verschleierte/kodierte Befehle, Code direkt aus dem Netz, LOLBins,
  Zugriff auf Anmeldedaten oder fremden Prozessspeicher, Sicherheitsfunktionen
  ändern, Persistenz (Run-Keys, Dienste, geplante Tasks), Netz-Scans,
  Masseneingriffe, Code in fremde Prozesse. Im Zweifel nachfragen; wird etwas
  blockiert: sofort stoppen und melden, nie umgehen (`FALCON-01..13`).
  Fremd-Tools aus Paketquellen dort nur auf Bitte und nur über
  `scripts/install-tools` der nvim-Config (`FALCON-12`).
- **Die ai-Familie (`ai.nvim`, `ai-desktop` samt Mobil-Variante) wird auf der
  Workstation nie installiert, gebaut oder gestartet**, auch nicht als
  Abhängigkeit (`MASCHINE-03`).
- **Die nativen Desktop-Apps (`tasks-`, `rules-`, `docmap-desktop`, ihre
  Hubs, Installer, Autostart) werden dort nicht installiert oder gestartet**,
  bis `appkit/edr-ausloeser-aus-allen-nativen-apps-entfernen` erledigt ist
  und ein `on-workstation`-Handlauf sie freigibt; bis dahin nur die
  Web-Variante (`file://`) (`MASCHINE-04`).
- Tags: `on-workstation` = nur dort, `not-on-workstation` = nie dort
  (`MASCHINE-05`). Vor einer getaggten Task (oder einem Auftrag zu
  Workstation, Falcon, EDR) die Maschine lesen und in einer Zeile nennen;
  passt sie nicht: nur vorbereiten und Bescheid geben (`MASCHINE-06`).
- Der Git-User `lavalue` bin ich auf der Workstation; seine Commits, auch
  unsignierte, sind kein Befund (`MASCHINE-07`).

## Env-Variablen

Gesetzt von `setup-claude-code.ps1` pro Maschine (User-Scope); Bedeutung:
`MASCHINE-08`.

- `$REPOS_DIR` (Wurzel aller Repos), `$NVIM_CONFIG_DIR` (nvim-Config; der
  alte Name `$NVIM_CONFIG` wird mit demselben Wert weiter gesetzt),
  `$RULES_VAULT` (gesetzt, wenn `$REPOS_DIR/rules-vault` existiert; sonst
  Repo klonen und das Setup-Skript erneut laufen lassen),
  `$TESTING_TRUST_ROOTS` (ohne sie enden lokale testing.nvim-Läufe mit
  Exit 2; die CI vertraut über `CI=true`), `$TESTING_ALLOWED_SIGNERS`, `PATH` +=
  `$REPOS_DIR/{testing,tasks,rules}.nvim/bin` (Befehle `testing`, `tasks`,
  `rules`). Die Befehle der nativen Apps (`hub-desktop`, `tasks-desktop`, …)
  legt deren `install` in `%LOCALAPPDATA%\appkit-family\bin` an.
- `$NVIM_MACHINE_ROLE` setzt das Skript nie, es zeigt sie nur an: auf einer
  (neuen) Workstation einmal von Hand setzen (`setx NVIM_MACHINE_ROLE
  workstation`, `WORKFLOW.md` Abschnitt 4) und die App neu starten.

## Git

- Kein Co-Author-Trailer von Claude (`GIT-02`).
- Commits immer signiert: kein `-c commit.gpgsign=false`, kein
  `--no-gpg-sign`; scheitert das Signieren, melden (`GIT-03`).
- **`WKDBook-Tricentis` und `tricentis-vault` nie pushen**, nur committen;
  den pre-push-Hook nie mit `--no-verify` umgehen (`GIT-04`).
- Geteilte Checkouts: in den Repos unter `$REPOS_DIR` arbeiten oft mehrere
  Sitzungen. Fremde uncommittete Änderungen nie committen, zurücksetzen,
  formatieren oder stashen (nur `pull --rebase --autostash` legt sie sofort
  zurück); nur eigene Dateien mit Pfad stagen und mit Pfad committen
  (`git commit -m … -- <pfade>`: der Index ist geteilt), nie `git add -A`/`.`
  oder `commit -a` (`GIT-05`, Flotte: `GIT-07`).
- Am Ende jeder Ausgabe eine laufende Liste aller Commits des Chats (Repo,
  SHA, kurze Beschreibung); grüner Haken = mit Reasoning über `normal`
  reviewed (reine Doku ohne Review), Stern = zusätzlich durch `ultracode`;
  nicht gepushte Commits als solche markiert (`REVIEW-01`).
