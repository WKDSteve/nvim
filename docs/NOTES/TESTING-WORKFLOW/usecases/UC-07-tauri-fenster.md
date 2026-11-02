# UC-07 Das echte Tauri-Fenster (`tauri-driver` + `msedgedriver`)

**Beispiel:** docmap-desktop startet im echten Fenster, Titel, gerenderter Text und Größe stimmen, Screenshot als Artefakt.

## Ziel
Prüfen, dass **die App selbst** (nicht nur ihre UI im Browser) startet und etwas anzeigt.

## Wann einsetzen
Apps mit echtem Tauri-Fenster (WebView2). Nicht für Apps ohne Fenster (tasks-desktop: dort [UC-08](UC-08-tasks-desktop-hub-und-web.md)). Nicht auf macOS (kein WebDriver).

## Wo
- Skript: `docmap-desktop/scripts/e2e/tauri_smoke.mjs` (W3C-WebDriver per `fetch`, keine Client-Bibliothek).
- Commits: docmap-desktop `38f36c1`, `773dd30` (Screenshot-Ordner), `dd2a924` (30 s Timeout je Aufruf).
- Werkzeuge: `~/.cargo/bin/tauri-driver` 2.1.0; `E:\repos\.tools\msedgedriver-156.0.4314.58\msedgedriver.exe` (Version = installiertes WebView2, Signatur geprüft).
- Screenshot: `docmap-desktop/src-tauri/target/e2e/docmap_window.png`.

## Voraussetzungen
Release-Binary (`cargo tauri build` → `src-tauri/target/release/docmap-desktop.exe`), beide Treiber, privater Rechner (**nicht** die Workstation).

## Schritte
1. `tauri-driver --port <p> --native-driver <msedgedriver>` starten; auf `/status` warten.
2. Sitzung: `POST /session` mit `capabilities.alwaysMatch["tauri:options"].application = <exe>`.
3. Prüfen: `GET /title` enthält „docmap“; `POST /execute/sync` `return document.body.innerText.length` > 0; `GET /window/rect` hat Größe.
4. `GET /screenshot` (Base64) in eine PNG-Datei; `DELETE /session`, Treiber beenden.

```bash
TESTING_MSEDGEDRIVER=E:/repos/.tools/msedgedriver-156.0.4314.58/msedgedriver.exe node scripts/e2e/tauri_smoke.mjs
```

## Ergebnis
Drei Prüfungen grün (Titel, 1008 Zeichen Text, Fenster 1400x880), Screenshot geschrieben. Exit 77 bei fehlendem Werkzeug oder Binary.

## Wenn es nicht läuft
- `msedgedriver` nicht gefunden: Pfad per `$TESTING_MSEDGEDRIVER` (es liegt bewusst nicht im PATH).
- Fenster startet nicht / Version passt nicht: WebView2-Version prüfen, passenden `msedgedriver` laden.
- Aufruf hängt: seit `dd2a924` bricht jeder WebDriver-Aufruf nach 30 s ab, statt den Job bis zum Limit zu blockieren.

## Noch offen
Einbindung in die CI (Windows-Runner mit WebView2 + Release-Build): Task `testing.nvim/browser-tauri-und-container-specs-in-ci-und-testing-einbinden`.
Sheet-Engine für Fenster-Schritte gibt es nicht; der Smoke ist ein Skript.
