# 03 Workflow Testblätter: Live-Checks wie in Tosca

Ein **Testblatt** schreibt eine Handprüfung als Daten auf: Schritte, Erwartung, Maske, Varianten. Die Maschine macht,
was sie kann; was nur ein Mensch beurteilen kann, steht als `judge` (Abnahme-Inbox) oder `manual`.
Referenz: `testing.nvim/docs/SHEETS.md`.

## Der Ablauf von der Task bis zur Abnahme

```
Live-Check-Task (Akzeptanz-Checkboxen)
   │  testing sheets new --from-task <bereich/task>        → Entwurf TESTS/sheets/<slug>.sheet.lua
   ▼
Blatt ausfüllen (Schritte, expect, screen/shot, judge, manual)
   │  scripts/test.sh --file sheets                         → Fall `sheet:<id>` in der Suite
   ▼
Lauf grün → Bericht
   │  testing sheets report <root> --from ir.json --tasks <vault>
   ▼
Task-Block (Stand je Blatt) + Abnahme-Inbox (judge) + Handschritte (manual)
   │  Mensch hakt ab → Task erledigt
```

`testing sheets run --task <bereich/task> --tasks <vault>` macht Lauf und Schreiben in einem Schritt (die Blätter
einer Task, ohne Suite). tasks.nvim ruft das als `:Tasks sheet-run` auf.

## Ein Blatt, drei Engines

| `engine` | Läuft in | Schritte | Gut für |
| --- | --- | --- | --- |
| `rpc` (Standard) | einem Kind-Neovim, ferngesteuert | `keys`, `input`, `lua`, `settle`, `wait`, `expect`, `screen` | Floats, Dialoge, Statusline, Mausaktionen, Fensteraufteilung |
| `browser` | echtem chromium (Playwright) | `open`, `press`, `click`, `wait`, `expect`, `shot` | Seiten: Fokus, Tab-Reihenfolge, Karten, Layout |
| `manual` | nichts | nur `manual = { … }` | macOS, Workstation, Langzeit, Gefühl |

Ein Schritt eines anderen Engines wird beim Laden abgelehnt (`steps[2]: keys is not a step of a browser sheet`).

### rpc: Neovim klicken

```lua
return {
  id = "ui.option-float",
  title = ":UI option float",
  task = "ui.nvim/try-the-ui-option-float-in-a-real-session",
  engine = "rpc",
  minit = "TESTS/minimal_init.lua",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = 'require("ui").setup({ usrcmds = true })' },
    { keys = ":UI<CR>", note = "open the float" },
    { wait = "vim.api.nvim_win_get_config(0).relative ~= ''" },
    { screen = "float", masks = { { row = 24 } } },       -- Vergleich mit einem Snapshot
    { keys = "q" },
    { expect = "vim.api.nvim_win_get_config(0).relative == ''", note = "the float is gone" },
  },
  judge = { "the rows and texts read well" },
}
```

- `keys` läuft über `child.feed` (Mappings greifen); ein Fehler der Tasten (`E492`) lässt den Schritt scheitern.
- `screen` vergleicht das Raster (Text und Attribute) mit `TESTS/__snapshots__/…`; **fehlt der Snapshot, ist es auf
  CI ein Fehler**, lokal wird er beim ersten Lauf angelegt (danach ansehen und einchecken).
- `wait`/`expect` sind Lua-Ausdrücke im Kind. Keine festen Pausen.
- Echtes Beispiel: `filetree.nvim/TESTS/sheets/diag-badges-neotree.sheet.lua` (neo-tree, Diagnostik-Badges, Fokus
  wechseln, Refresh).

### browser: eine Seite bedienen

```lua
return {
  id = "keyword-card-tab",
  title = "Keyword card: Tab navigation in a real window",
  task = "docmap.nvim/keyword-card-tab-navigation-live-check",
  engine = "browser",
  steps = {
    { open = "TESTS/sheets/out/keyword-page.html" },           -- Datei relativ zum Projekt, oder eine URL
    { click = 'text="Index"', note = "the Index tab" },
    { click = 'a.nfn:has-text("M.count()")', note = "open the function" },
    { wait = "[...document.querySelectorAll('.bd[data-kw]')].some(e => e.offsetParent !== null)", timeout = 5000 },
    { expect = "([...document.querySelectorAll('.bd[data-kw]')].find(e => e.offsetParent !== null).focus(), document.activeElement.hasAttribute('data-kw'))" },
    { shot = "card-open" },                                     -- Screenshot als Artefakt
    { press = "Escape" },
    { expect = "!document.getElementById('kwpop').classList.contains('on')", note = "Escape closes the card" },
  },
  judge = { "the keyword card is readable and sits next to its keyword (screenshot card-open)" },
}
```

- `wait` und `expect` sind **JavaScript in der Seite**. `sizes` sind der Viewport in Pixeln (Standard 1000 x 700).
- `shot = name` → `TESTS/sheets/out/<id>.<name>.<breite>x<höhe>.png` (nur Buchstaben, Ziffern, `_`, `-`).
- Es gibt **keinen Vorbereitungsschritt**: Blätter sind Daten. Die Seite, die ein Blatt braucht, erzeugt die Spec
  (`TESTS/sheets_spec.lua` rendert sie aus einem Fixture-Modul, siehe [UC-03](usecases/UC-03-browser-blatt.md)).
- Ohne Node, `playwright-core` oder chromium: gemeldeter Skip (`n/a`), der Task-Block zeigt `never` (nicht gelaufen).
  `playwright-core` wird gesucht in `$TESTING_PLAYWRIGHT_DIR`, dem Projekt, `../mdview.nvim`.

### manual: nur Handschritte

```lua
return { id = "x.mac", title = "macOS: …", engine = "manual", manual = { "auf einem Mac: … prüfen" } }
```

## Die Suite-Seite: ein Spec lässt alle Blätter laufen

```lua
-- TESTS/sheets_spec.lua   (dialect busted, in .testing.lua: ["TESTS/sheets_spec.lua"] = "busted")
local sheet = require("testing.sheet")
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p"))))
describe("test sheets", function()
  for _, path in ipairs(sheet.files(root .. "/TESTS/sheets")) do
    local s, err = sheet.load(path)
    it(s and sheet.spec_name(s) or path, function()
      assert(s, err)
      sheet.check(s, { root = root })       -- wirft bei rot, druckt `n/a` bei Skip
    end)
  end
end)
```

Der Kopf `-- @cache-inputs TESTS/sheets/ TESTS/__snapshots__/` sagt dem Cache, dass Blätter und Snapshots Eingaben
sind. Projekte mit strengem Prozess-Wächter tragen `nvim` (rpc) bzw. `node` (browser) in `guard_allow.spawn` ein.

## Die Zustände eines Blatts (im Task-Block, `testing:sheets:states`)

| Zustand | Bedeutung |
| --- | --- |
| `green` | automatisch grün, nichts bleibt für einen Menschen |
| `inbox` | automatisch grün, wartet auf das Urteil (`judge`) |
| `manual` | es bleiben Handschritte (`manual`) |
| `red` | ein Schritt ist gescheitert oder das Blatt lädt nicht |
| `stale` | Blatt, Spec oder Snapshot haben sich seit dem Lauf geändert |
| `never` | nie gelaufen oder übersprungen (kein Browser, kein Playwright) |

## Mit KI (optional)

`testing sheets prompt draft|explain` schreibt ein Übergabedokument: ein Blatt aus einer Task entwerfen lassen oder
einen roten Lauf erklären lassen. `testing sheets accept --task <id> --from <datei>` übernimmt das Blatt der KI **nur**,
wenn es lädt und die Task nennt. Der KI-Gutachter für Screenshots (ai.nvim) ist noch eine offene Task.

## Fallen aus der Praxis

- Bei `screen`-Schritten Intro und Statusline ausschalten (`shortmess+=I`, `laststatus=0`), sonst steht dort der
  Neovim-Stand oder ein temporärer Pfad im Snapshot.
- Ein Fenster, das Timer endlos neu setzt, macht `settle` unmöglich (neo-tree Größenabfrage: dort aus).
- Browser: ein **Scroll schließt Karten** (Seite hat Scroll-Wächter); ein per `focus()` ausgelöster Scroll darf das
  seit docmap.nvim `5efcf63` nicht mehr. Bei neuen Seiten auf so etwas achten und dem `wait` Zeit lassen.
- Ein Skip steht nie als „grün“ im Bericht; nach einem Lauf ohne Browser stehen die Blätter unter „nicht gelaufen“.
