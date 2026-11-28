# Claude-Code-Setup (Multi-Machine: PC / Heim-PC / Workstation)

Dieser Ordner ist Teil des nvim-Config-Repos (`WKDSteve/nvim` auf GitHub)
und damit auf allen drei Maschinen per `git pull` synchron. Er enthaelt die
Vorlagen fuer die globale Claude-Code-Konfiguration - die eigentlich in
`~/.claude/` (also pro Maschine, nicht versioniert) liegt - plus ein Skript,
das diese Vorlagen dorthin ausrollt.

Hintergrund: `~/.claude/CLAUDE.md` und `~/.claude/settings.json` sind reine
Maschinen-lokale Dateien, die Claude Code selbst nicht synct. Ohne diesen
Ordner muesste man Regeln/Settings auf jedem Rechner von Hand nachpflegen.

## Dateien in diesem Ordner

| Datei                       | Zweck                                                                 |
|------------------------------|------------------------------------------------------------------------|
| `CLAUDE.global.md`           | Quelle der Wahrheit fuer `~/.claude/CLAUDE.md`: nur der Kern, der ohne rules-vault gelten muss (Sprache, Maschine/Workstation, Signatur, Push-Verbote, geteilte Checkouts, Commit-Liste), mit Regel-IDs; alles andere laedt aus `~/.claude/rules/` |
| `settings.global.json`       | Quelle der Wahrheit fuer `~/.claude/settings.json` (Permissions-Allowlist + Hooks) |
| `check-hook.js`              | Vom PostToolUse-Hook aufgerufener Dispatcher: prueft je nach Endung `.lua` (stylua+luacheck), `.rs` (rustfmt mit der Edition aus der naechsten `Cargo.toml`, auch `edition.workspace`), C/C++ (clang-format, nur mit `.clang-format`), `.ts/.js/.css/.json` (projektlokales prettier) |
| `check-hook.test.js`         | End-to-end-Test der Edition-Erkennung von `check-hook.js` (Wegwerf-Crates im Temp-Ordner, braucht rustfmt): `node check-hook.test.js` |
| `check-stop.js`              | Stop-Hook: bei geaenderten Dateien `cargo clippy -D warnings` (Rust) bzw. die Typpruefung des Projekts (TS): das `check`-Skript der `package.json` neben der `tsconfig.json` (pnpm/yarn/npm nach Lockfile, nur mit `node_modules`; gesucht bis zur Repo-Wurzel), ohne Skript `tsc --noEmit`; nach `CHECK_STOP_TIMEOUT_MS` (5 min) blockiert es und beendet den ganzen Prozessbaum. Der Eintrag in `settings.global.json` hat ein eigenes `timeout` (330 s) über diesen 5 min, damit Claude Code den Hook nicht vorher abbricht |
| `check-stop.test.js`         | End-to-end-Test der TS-Wahl von `check-stop.js` (Wegwerf-Repos im Temp-Ordner, falsche pnpm/yarn/npm in eigenem PATH, Timeout; braucht git und npm): `node check-stop.test.js` |
| `WORKFLOW.md`                | Anleitung: neuer Chat, neues Repo, neue Maschine |
| `../../../scripts/install-tools/` | Ersetzt `setup-devtools.js` + `tools.json`: installiert fehlende Toolchains pro Profil (`nvim`, `cpp`, `rust`, `web`, `tauri`, oder `all` für alle) und die CLI-Tools der Plugins, bevorzugt per winget. `install-tools.ps1 -Profile nvim,rust -DryRun`; `-Status` zeigt je Profil, was schon installiert ist, und installiert nichts. Siehe dortiges README |
| `new-project-claude.js`      | Kopiert die Projekt-Vorlage aus `templates/<stack>/` (`CLAUDE.md`) in ein Repo und installiert den Cloud-Push-Guard (unten): `node new-project-claude.js rust [zielordner]` |
| `hooks/cloud-push-guard.mjs` | Quelle des PreToolUse-Hooks (Bash), den jedes Code-Repo unter `.claude/hooks/` committet hat: in einer Cloud-Sitzung (`CLAUDE_CODE_REMOTE` gesetzt) weist er jedes `git push` ab, das `main` bewegen würde (`HEAD:main`, `+main`, `refs/heads/main`, `--all`, Löschen, `git push` auf `main` …), und nennt `GIT-09`. Lokal startet der Eintrag nicht einmal `node`. Schützt gegen Versehen, nicht gegen Absicht. Nur hier ändern, dann neu ausrollen |
| `install-cloud-push-guard.js` | Installiert den Hook in Repos: `node install-cloud-push-guard.js <repo>…` kopiert ihn und merged den Eintrag in `.claude/settings.json`, lässt ein ignoriertes `.claude/` in der `.gitignore` für `settings.json` und `hooks/` durch; `--check` meldet fehlende oder alte Kopien (Exit 1). Verweigert die Vaults, hält ein Repo mit fremden uncommitteten Änderungen in diesen Dateien an (`held`). Geprüft von `TESTS/cdx/cloud_push_guard_spec.lua` |
| `templates/`                 | Vorlagen je Stack: `nvim-plugin`, `rust`, `cpp`, `tauri`, `web`; dazu `PROMPT/` (Prompt-Vorlagen fuer `:Cdx prompt`): `Base.md`, `base_workstation.md`, `full.md`, `tasks.md` verweisen per Regel-ID auf den rules-vault, ihre Langfassungen `*_standalone.md` stehen fuer sich (Sitzungen ohne `~/.claude/rules`). `TESTS/cdx/rule_refs_spec.lua` prueft, dass jede zitierte Regel-ID im Vault existiert, `TESTS/cdx/rule_drift_spec.lua`, dass kein Regeltext (Saetze ab 50 Zeichen) aus dem Vault in `CLAUDE.global.md`, den Kurz-Vorlagen oder den Repo-Vorlagen wiederkehrt |
| `KONZEPT-multi-stack.md`     | Begruendung/Architektur der drei Schichten |
| `merge-claude-settings.js`   | Gemeinsame Merge-Logik fuer `settings.json`, von beiden Setup-Skripten unten aufgerufen (verhindert, dass Windows- und Unix-Skript bei dieser Logik auseinanderlaufen). Einem schon vorhandenen Hook gibt sie das `timeout` der Vorlage. Test: `node merge-claude-settings.test.js` |
| `luarc.repos-root.jsonc`     | LuaLS-Config fuer `$REPOS_DIR/.luarc.jsonc`, von beiden Setup-Skripten kopiert. Sitzungen mit cwd = `$REPOS_DIR` starten (Plugin `lua-lsp`) einen LuaLS ueber den ganzen Repos-Baum: ohne die Datei 5,4 GB, mit ihr 1,4 GB (gemessen 2026-11-18). Bewusst `.jsonc`, damit lsp.nvim sie nicht als Root-Marker nimmt |
| `install-repos-luarc.ps1`/`.sh` | Kopiert `luarc.repos-root.jsonc` nach `<repos>/.luarc.jsonc` (eine abweichende Datei wird vorher gesichert). Von den Setup-Skripten aufgerufen und von `TESTS/cdx/luarc_repos_root_spec.lua` gegen einen Temp-Ordner geprueft |
| `rules-vault.js`             | Gemeinsamer Helfer beider Setup-Skripte: `ensure <vault>` klont den rules-vault bzw. holt ihn per `git pull --ff-only` (nur sauber und auf `main`, sonst nur Warnung); `link <vault> <~/.claude> [--workstation]` verlinkt `rulesets/arbeit/kontext/*.md` nach `~/.claude/rules/rules-vault-<name>.md`. Geprueft von `TESTS/cdx/rules_vault_spec.lua` (Fake-Vault, Fake-`~/.claude`) |
| `setup-claude-code.ps1`      | Windows: rollt die Vorlagen oben nach `~/.claude/` aus. Idempotent. |
| `setup-claude-code.sh`       | Linux/macOS: dasselbe wie oben, plus `~/.claude/env.sh` fuer die Env-Variablen. Idempotent. |
| `setup-git-signing.ps1/.sh`  | Commit-Signatur dieses Geraets: eigener SSH-Key (`~/.ssh/git-signing_ed25519`), `commit.gpgsign`, Eintrag in `git-allowed-signers`. Von beiden Setup-Skripten aufgerufen, auch allein lauffaehig. Idempotent. |
| `git-allowed-signers`        | **Geraete-Registry**: je Geraet eine Zeile (`allowed_signers` von ssh-keygen). Der runner-guard von testing.nvim gibt Push-Laeufe oeffentlicher Repos ohne `testing ci trust` frei, wenn alle neuen Commits von einem dieser Keys signiert sind. Geraet raus = Zeile loeschen, committen, auf dem Runner-Rechner pullen. |

## Funktionsprinzip

- **`CLAUDE.md`**: Wird per Symlink nach `~/.claude/CLAUDE.md` verlinkt.
  Aenderungen an `CLAUDE.global.md` wirken sich nach `git pull` sofort aus -
  kein erneutes Setup noetig. Nur falls Symlinks auf einer Maschine nicht
  moeglich sind (kein Developer Mode, keine Admin-Rechte), wird stattdessen
  kopiert - dann muss man nach Aenderungen `setup-claude-code.ps1` erneut
  laufen lassen.
- **`~/.claude/rules/`** (Arbeitsregeln aus dem rules-vault): Claude Code laedt
  `~/.claude/rules/*.md` beim Start jeder Sitzung ohne Freigabedialog. Das
  Setup legt je Datei `$RULES_VAULT/rulesets/arbeit/kontext/*.md` einen
  Symlink `rules-vault-<name>.md` an (Fallback Kopie), auf der Workstation
  (`NVIM_MACHINE_ROLE=workstation`) zusaetzlich `kontext/workstation/*.md` als
  `rules-vault-workstation-<name>.md`. Eigene Eintraege erkennt es am Praefix
  `rules-vault-`: verwaiste werden entfernt, fremde Dateien in `rules/` nie
  angefasst. Weil jede Sitzung vom lokalen Vault abhaengt, klont das Setup ihn
  bei Bedarf (`gh repo clone WKDSteve/rules-vault`, Rueckfall `git clone`) und
  holt ihn per `git pull --ff-only`; mit uncommitteten Aenderungen, auf einem
  anderen Branch oder bei einem Pull-Fehler nur eine Warnung. Ohne Vault oder
  `kontext/`-Ordner: Hinweis, kein Fehler. Mit Symlinks wirkt eine Aenderung
  im Vault nach dem Pull sofort, mit Kopien erst nach erneutem Setup.
  `~/.claude` liegt im echten Profil, die MSIX-Virtualisierung der Claude-App
  betrifft nur AppData.
- **`settings.json`**: Wird **gemerged**, nicht ueberschrieben (Logik in
  `merge-claude-settings.js`, per `node` von beiden Setup-Skripten
  aufgerufen). Bestehende Eintraege (z. B. maschinenspezifische Permissions)
  bleiben erhalten, die Vorlage wird nur ergaenzt (Allowlist-Eintraege
  vereinigt, Hooks nur hinzugefuegt, wenn noch nicht vorhanden). Vor jedem
  Schreiben wird ein Backup `settings.json.bak-<timestamp>` angelegt.
  Braucht `node` auf PATH (wird eh fuer `check-hook.js` gebraucht).
- **Env-Variablen**: `$NVIM_CONFIG_DIR` wird automatisch aus dem Speicherort
  dieses Skripts ermittelt. `$REPOS_DIR` ist pro Maschine unterschiedlich
  (z. B. `B:\repos` hier, ggf. andere Pfade auf Heim-PC/Workstation) und wird
  beim ersten Lauf interaktiv abgefragt, danach wiederverwendet.
  `$NVIM_MACHINE_ROLE` (`workstation` auf der Tricentis-Workstation, sonst
  nicht gesetzt) setzt das Skript nicht (auf der Workstation einmal von Hand:
  `setx NVIM_MACHINE_ROLE workstation`, siehe `WORKFLOW.md` Abschnitt 4); sie wird von `lua/machine.lua` der
  nvim-Config und von den Claude-Regeln (`MASCHINE-01` bis `MASCHINE-06`,
  Kurzfassung im Abschnitt „Maschine“ von `CLAUDE.global.md`) gelesen und
  entscheidet über die Task-Tags `on-workstation` / `not-on-workstation`.
  - **Windows**: als User-Env-Var gesetzt
    (`[Environment]::SetEnvironmentVariable(..., 'User')`) - gilt in neu
    gestarteten Shells/der Claude-Code-App.
  - **Linux/macOS**: es gibt kein Registry-Pendant, daher landen die Werte in
    `~/.claude/env.sh` (bei jedem Lauf neu generiert), und `setup-claude-code.sh`
    ergaenzt eine `source`-Zeile in `~/.bashrc` und/oder `~/.zshrc` (welche
    Datei jeweils existiert), falls dort noch nicht vorhanden. Gilt ab der
    naechsten Shell bzw. `source ~/.claude/env.sh`.

## Drei Schichten (Multi-Stack)

1. **Claude-Setup** (`setup-claude-code.*`): globale `CLAUDE.md` (stack-neutral) + `settings.json`.
2. **Toolchains** (`scripts/install-tools`, `-Profile`): Programme pro Profil installieren (winget; MSVC primaer, clang als Fallback). Gewaehlte Profile landen in `~/.claude/devtools.profile` (`-Profile saved` nimmt sie wieder).
3. **Projekt-Konfig** (`new-project-claude.js`): stack-spezifische `CLAUDE.md` + Allowlist pro Repo, im Repo versioniert.

Neues Repo einrichten: `node $NVIM_CONFIG_DIR/docs/NOTES/CDX/new-project-claude.js <stack>` im Repo-Root, dann committen.
Wichtig: Die Lua-/Plugin-Regeln stehen nicht mehr global, sondern in `templates/nvim-plugin/CLAUDE.md` - jedes Plugin-Repo einmal mit `new-project-claude.js nvim-plugin` ausstatten.

## Was die Hooks konkret machen

`settings.global.json` registriert einen `PostToolUse`-Hook auf
`Edit|Write`: Nach jedem Datei-Edit prueft `check-hook.js` anhand der Dateiendung und laesst die
passenden Checks darueber laufen (bei `.lua`: `stylua --check` und `luacheck`). Schlaegt eine der beiden Pruefungen fehl, bricht
der Hook mit Exit-Code 2 ab - Claude bekommt die Fehlermeldung direkt
zurueckgespielt und muss die Datei korrigieren, bevor es weitergeht. Das
erzwingt technisch, was in `CLAUDE.global.md` als Regel steht ("Code muss
luacheck/stylua clean sein").

Die Permissions-Allowlist in `settings.global.json` erlaubt ein paar
ungefaehrliche, haeufig gebrauchte Befehle ohne Rueckfrage (`git status/diff/
log/add/commit/pull`, `luacheck`, `stylua`, `ls`). `git push` ist bewusst
**nicht** als `push:*`-Wildcard freigegeben, sondern nur als exakte,
ungefaehrliche Formen (`git push`, `git push origin main`, `git push origin
HEAD`) - ein Wildcard wuerde stillschweigend auch `git push --force`
durchlassen. `find` ist aus demselben Grund nicht in der Liste: `find -exec`
kann beliebige Befehle ausfuehren, ein `find:*`-Wildcard haette das ohne
Rueckfrage erlaubt.

## Setup auf einer (neuen) Maschine

Windows:

```powershell
pwsh -File "$env:LOCALAPPDATA\nvim\docs\NOTES\CDX\setup-claude-code.ps1"
```

Linux/macOS (Pfad je nach Ort des nvim-Config-Repos anpassen, z. B.
`~/.config/nvim` oder `~/.local/share/nvim` - wo auch immer dieses Repo dort
liegt):

```bash
bash ~/.config/nvim/docs/NOTES/CDX/setup-claude-code.sh
```

Ablauf (beide Skripte, gleiches Prinzip):

1. Setzt/prueft `NVIM_CONFIG_DIR` (automatisch aus dem Skript-Pfad; der alte
   Name `NVIM_CONFIG` bekommt denselben Wert) und `REPOS_DIR` (fragt beim
   ersten Mal nach, validiert dass der Pfad existiert). Zeigt die
   Maschinenrolle `NVIM_MACHINE_ROLE` an (setzt sie nie; unbekannte Werte und
   ein AzureAD-/`TRI-`-Rechner ohne Rolle werden gemeldet).
   Klont bzw. aktualisiert den rules-vault (`rules-vault.js ensure`) und
   setzt danach `RULES_VAULT`.
2. Verlinkt/kopiert `CLAUDE.global.md` nach `~/.claude/CLAUDE.md` (mit
   Backup, falls dort schon etwas anderes liegt).
3. Merged `settings.global.json` in `~/.claude/settings.json` (mit Backup,
   ueber `merge-claude-settings.js`) und verlinkt die Kontext-Dokumente des
   rules-vault nach `~/.claude/rules/` (`rules-vault.js link`, siehe oben).
4. Richtet die Commit-Signatur ein (`setup-git-signing.*`): erzeugt bei Bedarf
   den Signing-Key, setzt `gpg.format ssh`/`commit.gpgsign true` und traegt
   das Geraet in `git-allowed-signers` ein. Neuer Eintrag: nvim-Config
   committen und pushen, auf dem Runner-Rechner (STEVESPC) pullen. Dort setzt
   es auch `TESTING_ALLOWED_SIGNERS`; nach einer Aenderung des Pfads einmal
   `testing ci runner-guard install` (macht `runners.ps1 start|ensure` mit).
   Aus der Claude-App gestartet landet die User-Env-Var nur im App-Container:
   das Skript selbst in einem normalen Terminal laufen lassen.
5. Optional: zeigt mit `scripts/install-tools/install-tools.ps1 -Status`, was
   schon installiert ist, und fragt nach Toolchain-Profilen
   (`nvim,cpp,rust,web,tauri`, `all` = alle, leer = ueberspringen). Fehlt
   Python, fragt der Starter vorher, ob er es per winget installieren darf.
   Auf der Workstation kommt alles wie ueberall, auch die Bau-Toolchains;
   ausgelassen werden nur die Tools der ai-Familie (ai.nvim, ai-desktop).

Danach Claude-Code-App/Terminal neu starten, damit die Env-Vars gezogen
werden.

## Bei Aenderungen an den Regeln

1. `CLAUDE.global.md` bzw. `settings.global.json` in diesem Ordner anpassen.
2. Committen/pushen (siehe Git-Regel in `CLAUDE.global.md` - main branch,
   sofort).
3. Auf den anderen Maschinen `git pull` (+ bei `settings.json`-Aenderungen
   das jeweilige Setup-Skript erneut ausfuehren, da die Merge-Logik nicht
   automatisch bei jedem Claude-Code-Start laeuft).

## API-Zugang

Kein `ANTHROPIC_API_KEY` als Env-Var setzen - die Anmeldung laeuft ueber die
Claude-Desktop-App-Subscription (OAuth-Login), nicht ueber einen API-Key.
Ein API-Key waere nur fuer separates API-Billing (z. B. CI-Nutzung ausserhalb
der App) relevant und gehoert dann in keinem Fall in eine versionierte Datei
in diesem Ordner, sondern hoechstens als maschinenlokale User-Env-Var oder
Secret-Manager-Eintrag.

## Bekannte Einschraenkungen

- `install-tools` ist unter Arch/WSL im Trockenlauf geprueft, unter macOS
  ungetestet. Neovim wird unter Debian/Ubuntu bewusst nicht per apt
  installiert (zu alt), das Skript nennt den Release-Link. `stylua` gibt es
  dort nicht per apt.

- Der Merge in `merge-claude-settings.js` ist bewusst simpel gehalten
  (Array-Union bei Permissions, Vorhandensein-Check bei Hooks ueber
  `matcher`+`command`). Komplexere manuelle `settings.json`-Strukturen
  (z. B. verschachtelte `PreToolUse`-Hooks mit demselben Matcher aber
  anderem Inhalt) bitte im Zweifel manuell pruefen statt blind laufen
  lassen.
- Symlink-Erstellung fuer `CLAUDE.md` braucht auf Windows entweder
  Developer Mode oder Admin-Rechte. Ohne beides faellt `setup-claude-code.ps1`
  automatisch auf eine Kopie zurueck (siehe oben). Auf Linux/macOS
  funktionieren unprivilegierte Symlinks immer, `setup-claude-code.sh` hat
  daher keinen Kopie-Fallback.
- Beide Setup-Skripte brauchen `node` auf PATH (fuer den Settings-Merge und
  fuer `check-hook.js`). `stylua`/`luacheck` sind nur fuer den Hook
  noetig - fehlen sie auf einer Maschine, wird der jeweilige Check
  uebersprungen statt hart zu blockieren (siehe `check-hook.js`).
