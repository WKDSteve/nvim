# UC-08 tasks-desktop: Hub, UI und Web-Variante

**Beispiel:** tasks-desktop (Rust-Hub + Svelte-UI) wird mit Playwright gegen das **echte Hub-Binary** und die **echte Engine**
geprüft, dazu die Web-Variante als eine HTML-Datei.

## Ziel
Dieselbe Prüfkette wie bei Plugins für eine App: Logik, UI-Einheiten, Bedienung im echten Browser, Barrierefreiheit.

## Wann einsetzen
Apps mit lokalem Hub und Browser-UI, **ohne** Tauri-Fenster. (Mit Fenster: [UC-07](UC-07-tauri-fenster.md).)

## Wo (alles im Repo `E:\repos\tasks-desktop`)
- Rust: `cargo fmt --check`, `cargo clippy --workspace --all-targets --locked -- -D warnings`, `cargo test --workspace --locked`.
- UI: `ui/package.json` (`check`, `test` = vitest, `build`, `e2e` = Playwright, `web:build`, `web:e2e`).
- Hub-Tests: `ui/playwright.config.ts`, `ui/e2e/*.spec.ts` (`app`, `durchgang`, `floats`, `plan-size`, `shell`), `ui/e2e/global.ts` (startet den Hub), `ui/e2e/hub.ts`, `ui/e2e/port.ts` (freier Port je Lauf), `ui/e2e/a11y.ts` (axe).
- Web-Variante: `ui/playwright.web.config.ts`, `ui/e2e-web/*.spec.ts` (`readonly`, `engines`, …).
- Regeln: `tasks-desktop/CLAUDE.md` (Abschnitt „Browser-Tests (Playwright)“).

## Voraussetzungen
`pnpm`, Rust-Toolchain, Chrome (`channel: 'chrome'`, nichts wird geladen); `TASKS_ENGINE_DIR=E:/repos/tasks.nvim` (ohne Engine werden
Engine-Tests **still übersprungen** – prüfen, dass sie nicht ausfallen). Firefox/WebKit für die Web-Variante:
`pnpm exec playwright install firefox webkit` (rund 184 MiB), sonst `--project=chrome`.

## Schritte
```bash
cd E:/repos/tasks-desktop
cd ui && pnpm check && pnpm test && pnpm build              # UI-Einheiten + Typen
cd .. && cargo fmt --check && cargo clippy --workspace --all-targets --locked -- -D warnings && cargo test --workspace --locked
cd ui && pnpm e2e                                           # echter Hub, echte Engine, axe
cd ui && pnpm web:build && pnpm web:e2e                     # eine HTML-Datei von der Platte
```
1. `global.ts` wählt einen **freien Port** (`TASKS_E2E_PORT` erzwingt einen), startet den Hub und schreibt einen State-Pfad; die Worker lesen ihn.
2. Die Tests laufen mit **einem** Worker nacheinander gegen **einen** Vault: Titel und Dateinamen müssen je Test eindeutig sein.
3. Jeder Lauf bekommt einen eigenen Ergebnisordner `ui/test-results/run-<pid>`; Runner, Terminal und andere Sitzungen stören sich nicht.
   `--last-failed` liest `test-results/.last-run-hub.json` bzw. `-web.json`.
4. Ein Fix gilt erst mit einem Test, der **ohne den Fix rot** wird; nach der Sabotage neu bauen (`touch` + `cargo build`), sonst bleibt der Test grün.

## Ergebnis
**In diesem Verlauf nicht ausgeführt** (nach den Dateien und `CLAUDE.md` des Repos beschrieben; vor Gebrauch einmal laufen lassen). Die Specs decken nach ihren Namen Shell, Durchgang, Floats, Plan-Größe, App und Barrierefreiheit (axe) ab. Der Rest der Kachel-/Filter-Handprüfung war
bereits automatisiert; **offen** bleibt nur das Ziehen mit der Maus (Task `tasks-desktop/hand-pruefung-kacheln-der-uebersicht-und-filter-im-echten-ta`).

## Wenn es nicht läuft
- Port belegt → `TASKS_E2E_PORT` anders setzen oder alte Läufe beenden.
- Engine-Tests übersprungen → `TASKS_ENGINE_DIR` setzen.
- Web-Variante: nur chrome vorhanden → `pnpm web:e2e --project=chrome`.

## Nachmachen / Verknüpfung mit Testblättern
Die Ergebnisse und der Blatt-Stand der Tasks erscheinen in tasks-desktop über den Vertrag `tasks-export/1` (siehe [UC-10](UC-10-abnahme-inbox-und-task.md)).
Ein Standalone-Handlauf unter Linux (`xdg-open`, Papierkorb) liegt als Task vor (`tasks-desktop/…standalone-handlauf-unter-linux…`); der
Container-Weg dafür steht in [UC-05](UC-05-linux-im-container.md).
