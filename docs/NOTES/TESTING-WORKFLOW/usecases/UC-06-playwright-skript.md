# UC-06 Playwright-Skript gegen einen echten Server

**Beispiel:** mdview.nvim, das Cursorzeilen-Band der Vorschau folgt dem Cursor.

## Ziel
Ein Web-Frontend mit **echter Geometrie** prüfen (Layout, Positionen, Scroll), mit dem echten Relay-Server dahinter.

## Wann einsetzen
Die Seite braucht einen Server oder viel Vorbereitung (Daten per HTTP einspeisen), oder die Prüfung ist zu verzweigt für ein Blatt.
Reine Dateiseiten gehören eher in ein Blatt ([UC-03](UC-03-browser-blatt.md)). jsdom-Tests sehen keine Geometrie: dafür ist dieses Skript da.

## Wo
- Skript: `mdview.nvim/TESTS/browser/cursor_band.e2e.mjs`; npm-Befehl `npm run test:browser`; Suite-Fall `mdview.nvim/TESTS/lua/browser_e2e_spec.lua`.
- Commits: mdview.nvim `3368c21`, `efa7ea0`, `a1fd06b` (Relay bei Skip beenden), `7b6a190` (CI-Job). `playwright-core` ist in `package.json` gepinnt (4.1).
- Ergebnis-Screenshot: `TESTS/browser/out/cursor_band.png`.

## Voraussetzungen
`npm ci`, `npm run build` (Client-Bundle `dist/client`), `npm run build:go` (Relay `native/server/mdview-server`), chromium
(`npx playwright-core install chromium`). Sonst Exit 77 = gemeldeter Skip.

## Schritte
1. Relay auf freiem Port starten (`--port`, `--token`, `--web-root`, `--open=false`), auf `/health` warten.
2. Browser öffnen: `/?key=…&token=…&cursor=line`.
3. Dokument **wie Neovim** einspeisen: `POST /update` (Text), `POST /scroll` (`3/8` = Zeile 3 von 8), danach kurz warten.
4. Messen mit `getBoundingClientRect`: Band deckt die Zeile (`band.top <= box.top + 4 && band.bottom >= box.bottom - 4`), folgt zu Zeile 7, hat sich bewegt.
5. Screenshot, `finally`: Browser schließen, **Relay beenden**; Exit 0/1, bei fehlendem Werkzeug 77.

```bash
cd E:/repos/mdview.nvim && npm run test:browser
```

## Ergebnis
Drei Prüfungen grün, Screenshot abgelegt. **Sabotage geprüft**: mit abgeschaltetem Marker (`cursor=off`) wird das Skript rot.

## Wenn es nicht läuft
- Exit 77 `relay binary missing` / `client bundle missing` / `no chromium`: bauen bzw. installieren (Skip, kein Grün).
- Port belegt: das Skript nimmt einen Zufallsport 43500–43899; bei Dauerproblemen anpassen.
- In der CI ist Exit 77 **rot** (alles wird dort gebaut, ein Skip wäre ein Fehler im Job).

## Nachmachen
Das Skript kopieren: Server starten, `fetch`-Helfer, `check()`-Liste, `finally`-Aufräumen, Exit-Codes 0/1/77.
