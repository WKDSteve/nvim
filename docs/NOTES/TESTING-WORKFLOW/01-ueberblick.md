# 01 Überblick: die Technik und was ich wofür einsetze

## Die Stufen

Je weiter unten, desto näher an dem, was ein Mensch sieht, und desto teurer und mehr „Umgebung“ braucht der Fall.
Jede Stufe meldet sich als **gemeldeter Skip**, wenn ihr Werkzeug fehlt.

| Stufe | Was läuft | Womit | Prüft | Typischer Ort |
| --- | --- | --- | --- | --- |
| **0 Suite** | Specs in `TESTS/*_spec.lua` | `testing.nvim` (`scripts/test.sh`) | Logik, Module, Befehle, Binding-Tabellen | alle Plugin-Repos |
| **1 Klicker (RPC)** | ein echtes Kind-Neovim, ferngesteuert | `testing.rpc`, `testing.sheet` Engine `rpc` | Tasten, Maus, Fenster, Bildschirm-Raster (Screen-Snapshot) | Live-Checks in Neovim |
| **2.5 PTY** | Neovim im echten Terminal (tmux, in WSL), Bytestrom | `testing.pty` | was ans Terminal geschrieben wird (OSC 1337 Bilder, Titel) | images.nvim |
| **Container** | ein echtes Linux (Podman) | `testing.container` | Papierkorb (`gio`, `trash-put`), `xdg-open`, Linux-Pfade | filetree.nvim, lib.nvim |
| **3 Browser** | echtes chromium | Playwright (`playwright-core`) oder Blatt-Engine `browser` | Layout, Fokus, Tab-Reihenfolge, Screenshots | mdview.nvim, docmap-Seite |
| **3 Fenster** | echtes Tauri-Fenster | `tauri-driver` + `msedgedriver` (WebDriver) | die App im echten WebView2 | docmap-desktop |
| **Gutachter** | Screenshot + Kriterien | ai.nvim (geplant) | „sieht richtig aus“ | Abnahme-Inbox |
| **CI** | alles oben, gleich | `testing ci`, GitHub Actions | „ist das Repo in Ordnung“ | jedes Repo |

Manuell bleiben: macOS, sauberes Windows-Konto, Workstation/Falcon, echtes Anmelden, Langzeit, reine
Gefühlsurteile. Sie stehen als `manual`-Schritte im Blatt, damit sie nicht vergessen werden.

## Tosca → hier

| Tosca | hier | Datei / Befehl |
| --- | --- | --- |
| Workspace | `tasks-vault` + Plugin-Repos | `$REPOS_DIR` |
| Requirement | Akzeptanz-Checkbox einer Task | `tasks-vault/<bereich>/ROADMAP/tasks/*.md` |
| TestCase | ein Testblatt (`*.sheet.lua`) oder ein Spec-Fall | `TESTS/sheets/`, `TESTS/*_spec.lua` |
| TestStep | ein Schritt im Blatt (`keys`, `click`, `expect`, …) | `docs/SHEETS.md` im testing.nvim |
| Input-Aktion | `keys`, `input`, `press`, `click` | |
| Verify-Aktion | `expect`, `screen`, `shot` + `judge` | |
| WaitOn | `wait` (nie feste Pausen) | |
| Ausführungsliste | `testing sheets run --task`, die Suite | |
| Engine | `rpc`, `browser`, `manual` | Feld `engine` im Blatt |
| Testbericht | `testing sheets report` (Abnahme-Inbox), Result-IR | `--json ir.json` |
| Defect | Task `kind=bug` im Vault | |

## Entscheidungsbaum: was setze ich ein?

1. **Ist es Logik oder ein reiner Befehl ohne Oberfläche?** → Spec in der Suite ([UC-01](usecases/UC-01-spec-im-plugin.md)).
2. **Muss ich in Neovim Tasten drücken und den Bildschirm ansehen?** → Blatt `engine = "rpc"`
   ([UC-02](usecases/UC-02-neovim-live-check-als-blatt.md)).
3. **Geht es um Bytes, die ans Terminal gehen (Bilder, Titel, Alt-Tasten)?** → `testing.pty`
   ([UC-04](usecases/UC-04-terminal-bytestrom.md)).
4. **Geht es um Linux-Verhalten (Papierkorb, `xdg-open`, Pfade)?** → Container
   ([UC-05](usecases/UC-05-linux-im-container.md)).
5. **Ist es eine Seite im Browser (Fokus, Tab, Layout)?** → Blatt `engine = "browser"`
   ([UC-03](usecases/UC-03-browser-blatt.md)) oder ein Playwright-Skript
   ([UC-06](usecases/UC-06-playwright-skript.md)), wenn ein Server nötig ist.
6. **Ist es das echte Desktop-Fenster?** → `tauri-driver`
   ([UC-07](usecases/UC-07-tauri-fenster.md)); bei Apps ohne Tauri-Fenster (tasks-desktop) Playwright gegen den Hub
   ([UC-08](usecases/UC-08-tasks-desktop-hub-und-web.md)).
7. **Urteilt ein Mensch (Aussehen, Gefühl)?** → `judge = { ... }` im Blatt; es landet in der Abnahme-Inbox
   ([UC-10](usecases/UC-10-abnahme-inbox-und-task.md)).
8. **Soll es bei jedem Push laufen?** → in die `ci`-Pipeline ([UC-09](usecases/UC-09-ci-pipeline-und-workflow.md)).

## Was bei jedem Lauf entsteht

| Artefakt | Wo | Wozu |
| --- | --- | --- |
| Urteil + Exit-Code | Terminal | 0 grün, 1 rot, 2 Aufruf, 3 Umgebung/Tool fehlt (`docs/EXIT-CODES.md`) |
| Result-IR | `--json <datei>` | Maschinenlesbar: Fälle, Zusicherungen, `effects` (gestartete Prozesse, Netz, Dateien) |
| State | `testing.state` (Editor) | letzter Stand je Fall, für den Bericht |
| Screenshots | `TESTS/sheets/out/`, `TESTS/browser/out/`, `src-tauri/target/e2e/` | Eingabe für Gutachter und Abnahme |
| Snapshots | `TESTS/__snapshots__/` | Referenz für `screen`-Schritte (Neovim) |
| Task-Block | in der Live-Check-Task | Stand jedes Blatts, von tasks.nvim/tasks-desktop gelesen |
| `ci-<profil>.json` | Repo | Beweis, dass dieser Stand grün war (`testing ci verify`) |

## Schutznetze (`guards`)

`.testing.lua` schaltet je Repo Wächter ein: Dateien außerhalb von `TESTS/tmp` (`fs`), Zustandslecks (`state`),
gestartete Prozesse und Netz (`process_net`, nur Programme aus `guard_allow.spawn`), Eingabeaufforderungen,
veraltete API. Ein Spec, das `node`, `podman`, `tmux` oder `wsl` startet, muss das Programm in `guard_allow.spawn`
haben; Schreibziele wie `TESTS/sheets/out` kommen in `guards.fs.allow`. Das Ergebnis steht je Fall im IR.
