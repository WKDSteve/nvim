# UC-02 Neovim-Live-Check als Testblatt (Engine `rpc`)

**Beispiel:** filetree.nvim, die E:/W:-Diagnose-Badges im echten neo-tree bleiben bei Refresh und Fokuswechsel stehen.

## Ziel
Einen Live-Check, den ich früher in einer echten Sitzung von Hand gemacht habe, als wiederholbares Blatt laufen lassen.

## Wann einsetzen
Tasten und Maus in Neovim, Floats, Dialoge, Fenster, Statuszeile, ein Plugin im Zusammenspiel mit einem anderen (hier neo-tree).

## Wo
- Blatt: `filetree.nvim/TESTS/sheets/diag-badges-neotree.sheet.lua` (`engine = "rpc"`, `minit = "TESTS/minimal_init_sheet_neotree.lua"`).
- Lauf als Fall `sheet:filetree.diag-badges-neotree` durch `filetree.nvim/TESTS/sheets_spec.lua` (busted-Stil).
- Task: `filetree.nvim/diag-badges-vanish-live-check`.
- Konfiguration: `filetree.nvim/.testing.lua` → `dialect = { ["TESTS/sheets_spec.lua"] = "busted", ["*"] = "script" }`.

## Voraussetzungen
Der echte neo-tree (die Commits, die `TESTS/minimal_init_sheet_neotree.lua` festnagelt) in `.deps/` oder daneben; `nvim` in
`guard_allow.spawn`.

## Schritte
1. **Entwurf aus der Task** (liest die Akzeptanz-Checkboxen als `judge`):
   ```bash
   testing sheets new --from-task filetree.nvim/diag-badges-vanish-live-check --repo E:/repos/filetree.nvim --vault E:/repos/tasks-vault
   ```
   Schreibt `TESTS/sheets/<slug>.sheet.lua` mit `DRAFT`-Kommentar, einem lauffähigen Skelett (Intro aus, Setup, `settle`,
   ein `screen`) und einem `judge`-Eintrag je Checkbox. Überschreibt nie ein vorhandenes Blatt (Exit 2).
2. **Schritte schreiben**, wie ein Mensch vorgehen würde:
   - Kleines Projekt in ein Temp-Verzeichnis legen (`lua`-Schritt), `vim.cmd.cd`.
   - Diagnosen ohne Language-Server setzen: `vim.diagnostic.set(ns, bufnr, { … })` (das Feature liest `vim.diagnostic.get`).
   - neo-tree öffnen, auf den Baum warten (`wait`), Refresh auslösen, Fokus wegnehmen und zurück.
   - Je Zustand ein `expect` (Zähler an Datei und Ordner) oder ein `screen` mit Maske.
   - Alles, was ein Mensch beurteilt, in `judge`; was nur von Hand geht (eine Woche echte Arbeit mit Language-Server)
     in `manual`.
3. **Laufen lassen**:
   ```bash
   scripts/test.sh --file sheets_spec
   ```
4. **Snapshots** (`screen`-Schritte): beim ersten lokalen Lauf wird `TESTS/__snapshots__/…` angelegt; ansehen, dann
   einchecken. Auf CI gilt ein fehlender Snapshot als Fehler.

## Ergebnis
Fall `sheet:filetree.diag-badges-neotree` grün; im Bericht steht das Blatt unter „Review inbox“, solange `judge` offen ist.

## Wenn es nicht läuft
- Rot mit `step N, <note> (…)`: die erste Zeile nennt Größe, Schritt und Notiz; weitere Fehler folgen darunter.
- `settle` scheitert („not idle“): ein Plugin setzt Timer endlos neu (neo-tree Größenabfrage) → dort abschalten.
- Der Screen zeigt die Neovim-Version oder einen temporären Pfad: Intro (`shortmess+=I`) und Statuszeile
  (`laststatus=0`) im ersten Schritt ausschalten.
- Maus und Tasten gehen über den RPC-Klicker des Kind-Editors (`child.feed`, `child.input`; Referenz `testing.nvim/docs/CHILD.md`).

## Nachmachen
`testing sheets new --from-task <bereich/task>` → Schritte füllen → `scripts/test.sh --file sheets`. Die Referenz der Schritte
steht in `testing.nvim/docs/SHEETS.md`; weitere Blätter: `markdown.nvim/TESTS/sheets/*.sheet.lua`.
