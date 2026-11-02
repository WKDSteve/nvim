# 02 Workflow Alltag: Spec schreiben, prüfen, pushen

Für jedes Lua-Plugin-Repo (`*.nvim`), das mit testing.nvim läuft. Die Reihenfolge ist immer: **schnell → gezielt →
alles → Pipeline → Push**.

## Einmal: das Repo einrichten

```bash
testing init <root>                     # .testing.lua, TESTS/minimal_init.lua, scripts/test.sh, CI-Job, Lint-Konfig
testing migrate dry-run <root>          # wenn bisher plenary/busted/eigener Runner: Plan; mit `apply` schreiben
testing doctor <root>                   # aufgelöste Konfiguration + Abhängigkeiten
testing init <root> --update --check    # Vorlagen veraltet? (--write schreibt)
```

`.testing.lua` (Beispiele aus echten Repos): `plugin`, `dialect` (`h` = projekteigenes `TESTS/harness.lua`, `busted`,
`script`), `deps` (z. B. `lib.nvim`, `testing.nvim`), `isolated` (`file` = ein Neovim je Spec), `guards`,
`guard_allow`, `env_allow`, `timeouts`, `conformance`. Referenz: `testing.nvim/docs/CONFIG.md`.

Umgebungsvariablen (setzt `setup-claude-code.ps1`): `$REPOS_DIR`, `$TESTING_TRUST_ROOTS` (ohne sie enden lokale Läufe
mit Exit 2, weil `.testing.lua` erst nach Vertrauen läuft), `$RULES_VAULT`, `$NVIM_MACHINE_ROLE`.

## Der Befehl `testing`

```bash
nvim -n -i NONE --headless -u NONE -l <pfad>/testing.nvim/scripts/testing.lua <unterbefehl> [<root>] [optionen]
```

In jedem eingerichteten Repo ist `scripts/test.sh` dasselbe mit isoliertem State und gefundenen Abhängigkeiten.
Praktisch: `scripts/test.sh <optionen>` für Läufe, `testing …` (Alias bzw. der lange Aufruf) für `sheets`, `ci`,
`conformance`, `surface`, `call`.

## Eine Spec schreiben

Ort: `TESTS/<name>_spec.lua`, Eintrag in `TESTS/run.lua` (bei Repos mit eigener Liste). Form je nach `dialect`:

```lua
-- TESTS/foo_spec.lua   (dialect "h": die Datei gibt eine Funktion zurück, H ist das Projekt-Harness)
return function(H)
  local foo = require("foo")
  H.eq(foo.add(1, 2), 3, "add")
  H.ok(foo.enabled(), "enabled by default")
end
```

Regeln, die das Setup durchsetzt:

- **Fehlt etwas in der Umgebung** → `print("n/a  <Grund>")` und `return` (gemeldeter Skip, Lauf bleibt grün).
- **Prozesse/Netz/Dateien**: nur wenn erlaubt (`guard_allow`), sonst meldet der Wächter einen Fehler.
- **Keine festen `sleep`s**: auf Zustand warten (`vim.wait(…)`, im Blatt `wait`).
- **Zusicherungen zählen**: `assertions = "warn"` meldet Specs ohne eine einzige.

## Schnell → gezielt → alles

```bash
scripts/test.sh --file sheets_spec            # nur Dateien, deren Name das enthält
scripts/test.sh --filter "<fall>"             # ein Fall
scripts/test.sh                               # die ganze Suite (Ergebnis: GREEN/RED, Exit 0/1)
scripts/test.sh --json /tmp/ir.json           # zusätzlich das Result-IR
testing fast <root>                           # wahrscheinliche Specs zuerst (geändert, zuletzt rot), Zwischenstand
testing explain <root> <spec>                 # warum läuft/liegt im Cache/fehlt diese Spec
```

Ergebniszeile lesen: `GREEN | 221 pass | 0 from cache, 221 ran, 0 skipped on purpose | 211.7 s | exit 0`. Gemeldete
Skips stehen als `n case(s) n/a here`. `PARTIAL` heißt: nur ein Teil lief (`--file`), kein Sentinel, kein
Beweis für den ganzen Stand.

## Der Fix-Ablauf (Pflicht bei Bugs)

1. Einen Test schreiben, der den Fehler zeigt (rot).
2. Den Fix machen (grün).
3. Den Fix kurz zurücknehmen (`git stash push -- <datei>`), sehen, dass der Test **rot** wird, wieder holen
   (`git stash pop`).

Beispiele in diesem Verlauf: filetree `be021d8` (fehlendes `wslpath`), testing.nvim `f4e683c` (Skip nicht als grün),
docmap.nvim `5efcf63` (Fokus-Scroll schließt die Karte; das Blatt ist der Test).

## Vor dem Push

```bash
scripts/test.sh ci --profile=fast      # stylua + luacheck: Sekunden
scripts/test.sh ci                     # die volle Pipeline (Format, Lint, Suite, Conformance)
testing ci verify <root>               # ist dieser Stand schon bewiesen? (Zehntelsekunde, kein Lauf)
testing ci hook install                # Pre-Push-Hook: fragt `verify` zuerst
```

Dann `git pull --rebase`, `git push` (nur eigene Dateien stagen, nie `git add -A` in geteilten Checkouts).
Details der CI: [04-workflow-ci.md](04-workflow-ci.md).

## Im Editor

`:Testing` (Befehle in `testing.nvim/docs/BINDINGS.md`), `:Testing ci`, `:Testing ci status`, `:checkhealth testing`
(zeigt auch, welche Tier-2.5/3-Werkzeuge vorhanden sind: node, tauri-driver, msedgedriver, wsl, Playwright-Browser).

## Wo etwas nachschlagen

| Frage | Datei in `testing.nvim/docs/` |
| --- | --- |
| Alle Optionen, Unterbefehle | `CLI.md`, `CONFIG.md` |
| Exit-Codes | `EXIT-CODES.md` |
| Wächter | `GUARDS.md` |
| Kind-Editor, Klicker, Screen-Snapshots | `CHILD.md` |
| Cache und `fast` | `CACHE.md`, `PERFORMANCE.md` |
| Migration von plenary/busted | `MIGRATING.md` |
