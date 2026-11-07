# Nvim-Plugin (Lua)

## Konventionen

- Installations-Specs meiner Plugins:
  `$NVIM_CONFIG_DIR/lua/plugins/personal/init.lua`
- Alle eigenen `.nvim`-Plugin-Repos liegen unter `$REPOS_DIR/repos`.
- Code muss luacheck- und stylua-clean sein, bevor er als fertig gilt (wird
  zusätzlich per globalem Hook `check-hook.js` erzwungen).
- Neue Features nach Möglichkeit im plugin-eigenen `/TESTS/`-Ordner testen.
- Lua-Tools: `$REPOS_DIR/tasks-vault/TOOLS/lua-plugin-tools.md`
- Performance: `$RULES_VAULT/rulesets/lua/regeln/PERFORMANCE.md`
- Lua-Projekte für Neovim: `$RULES_VAULT/rulesets/lua/regeln/LUA_NVIM.md`

## Bindings

- Wird ein Keybinding geändert/hinzugefügt, ggf.
  `$NVIM_CONFIG_DIR/docs/NOTES/BINDINGS` aktualisieren.

## Commits prüfen

**Commits prüfen: `testing ci commit`.** Wenn du einen Commit reviewst oder prüfen sollst, ob er etwas kaputt macht,
prüfe ihn mit `scripts/test.sh ci commit <sha>` im Repo (ohne Template-Skript:
`nvim -n -i NONE --headless -u NONE -l "$REPOS_DIR/testing.nvim/scripts/testing.lua" ci commit <sha> --root=<repo>`),
nie mit `scripts/test.sh` oder `testing ci` im Arbeitsbaum. Mehrere: `ci commit <a> <b>` oder `--range=<von>..<bis>`.
Das Urteil gilt nur für das System, auf dem der Befehl lief: nach dem Push `scripts/test.sh ci remote` (die CI je System),
fertig ist ein Commit erst, wenn sie grün ist.
Der Befehl prüft jeden Commit in einem eigenen Git-Worktree, andere Chats im selben Checkout stören also nicht, und
er vergleicht Rot mit dem Parent. Lies die erste Zeile: `CLEAN`, `KNOWN-RED` und `FLAKY` heißen "der Commit macht nichts
neu kaputt" (Exit 0), `REGRESSION` listet darunter die neuen Befunde (`new ...`, Exit 1; beheben oder melden),
`UNCLASSIFIED` (Root-Commit oder Basis lief nicht) prüfst du von Hand, `DOCS-ONLY` lief bewusst nicht. **Lass nie
einen Commit aus, weil eine Suite rot ist**; `known-red` ist ein Ergebnis, kein Grund zum Überspringen, und im
Bericht steht das Urteil je Commit. Ein schon geprüfter Commit kommt sofort aus dem Gedächtnis (`(kept result)`);
`--force` nur, wenn sich Werkzeuge oder Abhängigkeiten geändert haben. `--json=<datei>` liefert das Dokument
`testing-ci-commit/1`, `--keep` lässt die Worktrees zum Nachstellen stehen (die `rerun`-Zeile nennt den Befehl).
Mit `-- --cached` teilen Commit und Basis einen Cache und laufen schneller. Auf der Workstation läuft es nicht (wie jeder Lauf).

**Sofort prüfen, nicht am Ende.** Jeden Commit gleich nach dem Erstellen mit `scripts/test.sh ci commit <sha>` im
Hintergrund prüfen und währenddessen weiterarbeiten (immer nur ein `ci commit` zur Zeit); das Urteil vor dem Push und
im Review lesen. Am Ende alle auf einmal (`--range`) kostet je Commit einen vollen Lauf plus den der Basis, mehrere
am Stück dauern schnell 40 Minuten. Ein umgeschriebener Commit (Rebase, Amend) mit gleichem Baum behält sein Urteil.

**Schnell prüfen, nicht jedes Mal alles.** Zwischenläufe beim Arbeiten mit `scripts/test.sh --changed` (nur die Specs, die die geänderten Dateien erreichen; wählt laut `testing.nvim/docs/CACHE.md` nie weniger als nötig). Einen Commit prüfst du mit `scripts/test.sh ci commit <sha> -- --cached`. Die volle Suite ohne `--changed`/`--cached` läuft einmal vor dem Push; `--changed` ist kein CI-Gate.
