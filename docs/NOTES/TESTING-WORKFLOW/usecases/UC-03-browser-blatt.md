# UC-03 Testblatt `browser`: eine Seite per Tastatur bedienen

**Beispiel:** docmap.nvim, die Keyword-Karte der erzeugten Seite: ein Keyword-Badge fokussieren (Karte geht auf),
`Escape` schließt sie, `Tab` geht weiter.

## Ziel
Eine Prüfung im echten Browser (Fokus, Tab-Reihenfolge, Karte, Screenshot) als Blatt laufen lassen, ohne ein Skript zu schreiben.

## Wann einsetzen
HTML/JS-Seiten, die man bedient: erzeugte Reports, Karten, Popups, Tab-Navigation. Braucht **keinen** Server, wenn die Seite
eine Datei ist.

## Wo
- Fixture-Modul: `docmap.nvim/TESTS/fixtures/keyword_page/lua/kwfix/init.lua` (zwei Funktionen mit `@async`/`@nodiscard`, damit Badges entstehen).
- Seite erzeugen: `docmap.nvim/TESTS/sheets_spec.lua` (`docmap.scan_full` + `docmap.render.html` → `TESTS/sheets/out/keyword-page.html`).
- Blatt: `docmap.nvim/TESTS/sheets/keyword-card-tab.sheet.lua` (`engine = "browser"`).
- Engine: `testing.nvim/lua/testing/sheet/browser.lua` und `browser_runner.mjs` (Node + `playwright-core`).
- Commits: docmap.nvim `6f7bf21` (Blatt), `5efcf63` (Fix der Seite: Fokus-Scroll schließt die Karte nicht mehr); testing.nvim `f93992e` (Engine).
- Konfiguration: `.testing.lua` → `dialect = { ["TESTS/sheets_spec.lua"] = "busted", … }`, `deps` mit `testing.nvim`,
  `guards.fs.allow = { "TESTS/sheets/out" }`; `.gitignore`: `TESTS/sheets/out/`.

## Voraussetzungen
Node, `playwright-core` (hier aus `../mdview.nvim/node_modules` gefunden, sonst `$TESTING_PLAYWRIGHT_DIR`), chromium
(`npx playwright install chromium`). Fehlt etwas: das Blatt meldet `n/a` (Zustand `never`).

## Schritte
1. **Seite herausfinden.** Den Weg zum Ziel einmal mit einem Wegwerf-Playwright-Skript erkunden (nicht einchecken): hier
   stellte sich heraus, dass die Keyword-Spans erst im Reiter *Index* nach Klick auf eine Funktion entstehen und dass die
   committete `docs/map/index.html` gar keine hat. Daraus folgte das Fixture.
2. **Seite erzeugen**, im Spec vor dem Blatt:
   ```lua
   local opts = require("docmap.config").build(fixture, { source = "lua" })
   local ir, findings = docmap.scan_full(opts)
   local html = docmap.render.html(ir, findings, opts)   -- → TESTS/sheets/out/keyword-page.html
   ```
3. **Blatt schreiben** (Schritte in der Reihenfolge eines Menschen; `wait`/`expect` sind JavaScript in der Seite):
   ```lua
   { open = "TESTS/sheets/out/keyword-page.html" },
   { click = 'text="Index"' },
   { click = 'a.nfn:has-text("M.count()")' },
   { wait = "[...document.querySelectorAll('.bd[data-kw]')].some(e => e.offsetParent !== null)", timeout = 5000 },
   { expect = "(<sichtbares Badge>.focus(), document.activeElement.hasAttribute('data-kw'))" },
   { expect = "new Promise(r => setTimeout(() => r(true), 700))", note = "let the scroll events pass" },
   { expect = "document.getElementById('kwpop').classList.contains('on')" },
   { shot = "card-open" },
   { press = "Escape" },
   { expect = "!document.getElementById('kwpop').classList.contains('on')" },
   ```
4. **Laufen lassen**: `scripts/test.sh --file sheets_spec` (docmap.nvim).
5. **Screenshot ansehen** (`TESTS/sheets/out/keyword-card-tab.card-open.1000x700.png`): er ist die Eingabe für `judge`.

## Ergebnis
Fall `sheet:keyword-card-tab` grün (docmap-Vollsuite 137 grün). Der Screenshot zeigt die Karte mit `@async`-Erklärung.

## Was der Fall aufgedeckt hat (ein echter Fehler)
Anfangs war das Blatt rot: Die Karte schloss sich direkt nach dem Öffnen. Ursache: das Fokussieren scrollt, und die Seite
schließt Karten bei **jedem** Scroll; zusätzlich meldet ein ruhender Mauszeiger unter bewegtem Inhalt ein `mouseover`,
das die Karte ebenfalls schloss. Entscheidung (2026-11-02): Tastaturfokus-Scroll schließt nicht, Maus-/Touch-Scroll
schon. Fix: `lua/docmap/core/render/html.lua` (`kwFocusScrollUntil`, 500 ms). **Rot-Beweis**: ohne den Fix ist das Blatt rot.

## Wenn es nicht läuft
- `n/a  playwright-core is not installed` → `TESTING_PLAYWRIGHT_DIR` oder `npm install` im Projekt.
- `GUARD … [fs] writes outside the allowed roots` → `guards.fs.allow = { "TESTS/sheets/out" }`.
- `GUARD … [process_net] started a process: node` → `"node"` in `guard_allow.spawn`.
- Klick findet nichts (5 s): Selektor prüfen; Playwright-Selektoren (`text="Index"`, `a:has-text("…")`) sind erlaubt.

## Nachmachen
Blatt kopieren, `open` auf die eigene Seite, Schritte ändern. Die Seite als Datei erzeugen (Spec/Build), nie im Blatt.
