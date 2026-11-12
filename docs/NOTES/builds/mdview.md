# mdview.nvim bauen (Workstation und privater Rechner)

Kurz zum Nachschauen: woher mdview Relay (`mdview-server.exe`) und Browser-Client (`dist/client`) nimmt, wann man
selbst bauen muss und mit welchem Befehl.

## Woher kommen Relay und Client?

mdview sucht in dieser Reihenfolge (`lua/mdview/adapter/server_args.lua`, `sources()`):

1. `dev.binary_path` / `dev.web_root` aus `setup()` (oder `$MDVIEW_DEV_BINARY` / `$MDVIEW_DEV_WEB_ROOT`)
2. **ein Build im eigenen Plugin-Verzeichnis** (`native/server/mdview-server.exe`, `dist/client/`): wird ohne
   jede Config genommen (`source = "local"`)
3. das Release, gepinnt über `install.version` (`config/DEFAULTS.lua`, Stand 2026-11-12: `v0.4.3` vom 2026-10-06),
   geladen nach `stdpath("data")/mdview/bin/<version>/`

**Das Release hinkt `main` hinterher.** `:MDView edit` und alles, was nach `v0.4.3` in `src/` oder `native/` kam,
fehlt im Release. Wer den aktuellen Stand will, braucht einen eigenen Build (Punkt 2). Wie das für reine
Remote-Installationen besser werden soll: tasks-vault
`mdview.nvim/ROADMAP/tasks/features-ohne-lokalen-build-fuer-remote-installationen.md`.

## Wo liegt das Plugin?

| Rechner | Verzeichnis | Woher |
|---|---|---|
| privat, mit Klon | `$REPOS_DIR/mdview.nvim` | `local_dev()` in `lua/plugins/personal/core/utils.lua`, wenn der Ordner existiert |
| Workstation / ohne Klon | `$LOCALAPPDATA/nvim-data/lazy/mdview.nvim` | lazy.nvim, Remote-Spec `WKDSteve/mdview.nvim` |

Im laufenden nvim: `:lua print(require("lazy.core.config").plugins["mdview.nvim"].dir)`.

## Werkzeuge (einmalig)

| Werkzeug | Für | Installieren |
|---|---|---|
| Node 18+ / npm | `npm ci`, vite | vorhanden (nvm) |
| Go 1.22+ | `npm run build:go` (Relay) | `winget install --id GoLang.Go -e --source winget` (MSI, fragt UAC) |
| Rust + Target `wasm32-unknown-unknown` | `npm run build` (WASM-Renderer) | `rustup target add wasm32-unknown-unknown` |
| wasm-pack | `npm run build` | `npm install -g wasm-pack` |

Prüfen: `go version`, `wasm-pack --version`, `rustup target list --installed`.

- Go landet in `C:\Program Files\Go\bin`. Eine Shell, die vor der Installation offen war, kennt es nicht: neue Shell
  öffnen (oder in Git Bash `export PATH="/c/Program Files/Go/bin:$PATH"`).
- npm warnt bei `wasm-pack`, dass dessen postinstall-Skript nicht in `allowScripts` steht. Trotzdem lief
  `wasm-pack --version` danach (2026-11-12); falls nicht: `npm install -g --allow-scripts=wasm-pack wasm-pack`.

## Bauen

Im Plugin-Verzeichnis (siehe Tabelle oben). Workstation (Git Bash):

```bash
cd "$LOCALAPPDATA/nvim-data/lazy/mdview.nvim" && npm ci && npm run build:go && npm run build
```

Privater Rechner mit Klon:

```bash
cd "$REPOS_DIR/mdview.nvim" && git pull && npm ci && npm run build:go && npm run build
```

PowerShell: dieselben Befehle, `cd "$env:LOCALAPPDATA\nvim-data\lazy\mdview.nvim"` bzw. `cd "$env:REPOS_DIR\mdview.nvim"`.

| Schritt | Ergebnis |
|---|---|
| `npm run build:go` | `native/server/mdview-server.exe` (`.exe` erst seit 2026-08-30; ältere Checkouts einmal neu bauen) |
| `npm run build` | `build:wasm` (wasm-pack → `src/client/wasm-render`) und `build:client` (vite → `dist/client`) |

Die Ausgaben sind gitignored, ein `git pull` oder lazy-Update lässt sie stehen.

Danach nvim neu starten (oder `:Lazy reload mdview.nvim`), dann `:MDView start` und z. B. `:MDView edit on`.

**Prüfen, was mdview nimmt** (beide Einträge sollen `source = "local"` sein):

```vim
:lua print(vim.inspect(require("mdview.adapter.server_args").sources()))
```

Oder `:checkhealth mdview`.

## Workstation vs. privater Rechner

| | Workstation (`NVIM_MACHINE_ROLE=workstation`) | privater Rechner |
|---|---|---|
| lazy-`build`-Hook | ausgelassen (`machine_guard.lazy_build` in `lua/plugins/personal/specs/view.lua`) | `npm ci && npm run build:go && npm run build` bei Install/Update über lazy |
| Release-Download | nur auf Anfrage: `vim.g.lib_binaries = "manual"` (`init.lua`) | automatisch beim ersten `:MDView start` |
| eigener Build | von Hand, Befehl oben (seit 2026-11-12 erlaubt) | lazy-Hook oder von Hand im Klon |

Auf der Workstation braucht man **nach jedem lazy-Update von mdview einen neuen Build von Hand**, sonst läuft neuer
Lua-Code gegen alten Relay und alten Client. `lazy_build` und dieser Abschnitt in [README.md](README.md) stammen noch
aus der Zeit, als dort gar nicht gebaut werden durfte; offen in der Task oben.

## Fehlermeldungen

| Meldung | Ursache | Abhilfe |
|---|---|---|
| `downloading binaries is on request only (vim.g.lib_binaries = "manual"); fetch them by hand` | kein eigener Build, und auf der Workstation lädt mdview das Release nicht von selbst | bauen (oben) oder das Release holen: `:MyPlugins binaries fetch mdview.nvim` (dann aber ohne neue Features) |
| `[build:go] Go is not on PATH` | Go fehlt oder die Shell ist älter als die Installation | Go installieren / neue Shell |
| `dev.binary_path is not spawnable, ignoring it` | `dev.binary_path` gesetzt, Datei fehlt | Pfad korrigieren oder `dev` entfernen (der Build im Plugin-Verzeichnis braucht keinen) |
| Feature (z. B. `:MDView edit`) tut nichts / Route 404 | Relay oder Client stammen aus einem älteren Release oder einem veralteten Build | neu bauen, mit `sources()` prüfen |
