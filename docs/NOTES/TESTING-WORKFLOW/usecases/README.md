# Anwendungsfälle (Use Cases)

Jeder Fall ist **echt**: er beschreibt etwas, das in der Arbeit vom 2026-11-02 gebaut oder ausgeführt wurde, mit den
Dateien, Befehlen, dem Ergebnis und den Commits zum Nachprüfen. Aufbau jeder Datei: *Ziel · Wann einsetzen · Wo (Dateien,
Commits) · Voraussetzungen · Schritte · Ergebnis · Wenn es nicht läuft · Nachmachen*.

| Fall | Technik | Beispiel | Repo |
| --- | --- | --- | --- |
| [UC-01](UC-01-spec-im-plugin.md) | Spec in der Suite, Fix mit Rot-Beweis | `is_wsl()` braucht `wslpath` | lib.nvim |
| [UC-02](UC-02-neovim-live-check-als-blatt.md) | Testblatt `rpc`: Neovim klicken | neo-tree-Badges, Entwurf aus der Task | filetree.nvim |
| [UC-03](UC-03-browser-blatt.md) | Testblatt `browser`: Seite bedienen | Keyword-Karte per Tab/Escape | docmap.nvim |
| [UC-04](UC-04-terminal-bytestrom.md) | `testing.pty`: Bytestrom im echten Terminal | OSC-1337-Bild in tmux | images.nvim |
| [UC-05](UC-05-linux-im-container.md) | `testing.container`: echtes Linux | Papierkorb, `xdg-open`, kein `wslpath` | filetree.nvim, lib.nvim |
| [UC-06](UC-06-playwright-skript.md) | Playwright-Skript gegen einen Server | Cursor-Band der Vorschau | mdview.nvim |
| [UC-07](UC-07-tauri-fenster.md) | `tauri-driver` + `msedgedriver` | echtes Fenster, Screenshot | docmap-desktop |
| [UC-08](UC-08-tasks-desktop-hub-und-web.md) | Playwright gegen Hub und Web-Variante | Hub-Binary, axe, eine HTML-Datei | tasks-desktop |
| [UC-09](UC-09-ci-pipeline-und-workflow.md) | `testing ci` und GitHub-Workflows | Browser-Job, Image-Build, tmux | mdview, images, filetree, lib |
| [UC-10](UC-10-abnahme-inbox-und-task.md) | Bericht, Abnahme-Inbox, Task-Verknüpfung | `sheets report`, `sheets run --task` | docmap.nvim, tasks-vault |
| [UC-11](UC-11-skip-und-rot-lesen.md) | Skips, Rot, Wächter lesen und beheben | `n/a`, `GUARD`, `PARTIAL`, Timeout | alle |

## Welche Frage führt zu welchem Fall

| Ich will … | Fall |
| --- | --- |
| eine Logik prüfen und einen Bug mit Beweis fixen | UC-01 |
| einen Neovim-Live-Check automatisieren (Tasten, Float, Bildschirm) | UC-02 |
| eine Seite im Browser per Tastatur prüfen | UC-03 |
| prüfen, was wirklich ans Terminal geschrieben wird | UC-04 |
| Linux-Verhalten prüfen, obwohl ich unter Windows arbeite | UC-05 |
| ein Web-Frontend mit echtem Server prüfen | UC-06 |
| das echte Desktop-Fenster prüfen | UC-07 |
| eine App mit Hub und UI (ohne Tauri) prüfen | UC-08 |
| alles in der CI laufen lassen | UC-09 |
| dem Menschen die Abnahme zeigen und die Task nachführen | UC-10 |
| verstehen, warum ein Lauf `n/a`, rot oder `PARTIAL` ist | UC-11 |
