# 05 Workflow Desktop und Web: dasselbe für die Apps

Die Desktop-Apps (tasks-desktop, docmap-desktop, rules-desktop, ai-desktop) und die Web-Seiten (mdview, die erzeugte
docmap-Seite, die Web-Variante der Apps) werden mit **denselben Mitteln** geprüft wie die Plugins: Specs, Klicker,
CI. Nur die Engine wechselt: statt Neovim ist es ein Browser oder ein Fenster.

## Welche App wird womit geprüft

| App / Seite | Was es ist | Prüfung | Werkzeug | UC |
| --- | --- | --- | --- | --- |
| **tasks-desktop** (Hub + Svelte-UI) | Rust-Hub, UI im Browser, **kein** Tauri-Fenster | Playwright gegen das echte Hub-Binary und die echte Engine, axe (Barrierefreiheit) | `pnpm e2e` in `ui/` | [UC-08](usecases/UC-08-tasks-desktop-hub-und-web.md) |
| **tasks-desktop Web-Variante** | eine einzelne HTML-Datei, von der Platte geöffnet, kein Server | Playwright (chrome; firefox/webkit nur für die Lese-Wege) | `pnpm web:build`, `pnpm web:e2e` | [UC-08](usecases/UC-08-tasks-desktop-hub-und-web.md) |
| **docmap-desktop** | echtes Tauri-Fenster (WebView2) | `tauri-driver` + `msedgedriver` (W3C WebDriver per HTTP) | `node scripts/e2e/tauri_smoke.mjs` | [UC-07](usecases/UC-07-tauri-fenster.md) |
| **mdview.nvim** | Go-Relay + Web-Client, Vorschau im Browser | Playwright-Skript gegen das echte Relay | `npm run test:browser` | [UC-06](usecases/UC-06-playwright-skript.md) |
| **docmap-Seite** (erzeugtes HTML) | Karte, Tabs, Keyword-Karte | Testblatt `engine = "browser"` | `scripts/test.sh --file sheets` | [UC-03](usecases/UC-03-browser-blatt.md) |
| **Standalone unter Linux** (tasks-desktop) | Hub-Binary im Linux | Container; Handlauf liegt als Task vor | `testing.container` | [UC-05](usecases/UC-05-linux-im-container.md) |

macOS hat keinen Tauri-WebDriver; dort bleibt es ein Handlauf.

## Die Schichten einer Desktop-App

```
Rust-Kern (cargo test)            → Logik, Engine-Vertrag               kein Fenster nötig
UI-Einheiten (vitest)             → Komponenten, Stores                 Node
UI im Browser (Playwright e2e)    → Bedienung gegen echten Hub          chrome, Port je Lauf
Web-Variante (Playwright web)     → eine HTML-Datei von der Platte      chrome (+ firefox, webkit)
echtes Fenster (tauri-driver)     → Titel, Text, Größe, Screenshot      Windows/Linux, WebView2
Abnahme (Blatt `judge`)           → Aussehen, Gefühl                    Mensch / später KI
```

Der Beweis, dass **das Fenster** und nicht nur die UI geprüft wird, liegt nur bei Apps mit Tauri-Fenster (docmap-desktop).
tasks-desktop hat keines: dort ist der Hub der echte Teil, die UI wird im Browser geprüft.

## Befehle je App

tasks-desktop (`E:\repos\tasks-desktop`, Anweisungen in dessen `CLAUDE.md`):

```bash
cd ui && pnpm check && pnpm test && pnpm build                       # UI-Einheiten
cargo fmt --check && cargo clippy --workspace --all-targets --locked -- -D warnings
cargo test --workspace --locked
cd ui && pnpm e2e                                                    # echtes Binary, echte Engine, axe
cd ui && pnpm web:build && pnpm web:e2e [--project=chrome]           # Web-Variante
```

Umgebung: `TASKS_ENGINE_DIR=E:/repos/tasks.nvim` (ohne Engine werden die Engine-Tests still übersprungen). Je Lauf ein
freier Port (`ui/e2e/port.ts`) und ein eigener Ergebnisordner `ui/test-results/run-<pid>`; Runner, Terminal und
andere Sitzungen können gleichzeitig laufen. `TASKS_E2E_PORT` erzwingt einen Port. Die Tests teilen einen Vault:
Titel und Dateinamen müssen eindeutig sein.

docmap-desktop (`E:\repos\docmap-desktop`):

```bash
cargo tauri build                                                    # Release-Binary src-tauri/target/release/docmap-desktop.exe
TESTING_MSEDGEDRIVER=E:/repos/.tools/msedgedriver-156.0.4314.58/msedgedriver.exe \
  node scripts/e2e/tauri_smoke.mjs                                   # 0 grün, 1 rot, 77 Werkzeug fehlt (Skip)
```

Die Version des `msedgedriver` muss zur installierten WebView2 passen (msedgedriver nicht auf den PATH legen; Pfad per
`$TESTING_MSEDGEDRIVER`, `tauri-driver` per `$TESTING_TAURI_DRIVER` oder PATH). Screenshot: `src-tauri/target/e2e/docmap_window.png`.

mdview.nvim:

```bash
npm ci && npm run build && npm run build:go      # Client-Bundle + Relay-Binary
npm run test:browser                              # Cursor-Band in echtem chromium; Screenshot TESTS/browser/out/
```

## Prüfen, ob die Werkzeuge da sind

`:checkhealth testing` (Abschnitt Tier 3) zeigt: `node`, `tauri-driver`, `msedgedriver`, `wsl`, Playwright-Browser. Fehlt
etwas, ist das ein Hinweis; die Fälle werden gemeldete Skips. Installation (nur privater Rechner, nie die Workstation):
`cargo install tauri-driver --locked`; `msedgedriver` für die genaue WebView2-Version von `msedgedriver.microsoft.com`
laden, die Authenticode-Signatur prüfen, außerhalb der Repos ablegen; `npx playwright install chromium` mit dem
gepinnten Playwright. Ausführlich: `testing.nvim/docs/TIER3.md`.

## Wie es zusammenhängt

- Dasselbe Blattformat gilt für Apps: ein Blatt mit `engine = "browser"` kann eine Seite der App öffnen; die Seite
  muss als Datei oder URL erreichbar sein (Fixture oder Build-Ausgabe), ein Blatt startet keine Programme.
- Der Bericht (`testing sheets report`) und der Task-Block sind für Plugins und Apps gleich; tasks-desktop zeigt den
  Blatt-Stand und die Abnahme-Inbox (`tasks-export/1`).
- Die Ergebnisse aller Repos laufen in den Vertrag `testing-export/1` (`testing call fleet|repo`, `testing export`), den
  eine Web-/Desktop-Ansicht von testing (testing-desktop, noch eine Task) lesen soll.
