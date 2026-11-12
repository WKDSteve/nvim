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

**CI-Takt: schnell je Commit, voll einmal pro Push** (Regeln `CI-01` bis `CI-10` in
`$RULES_VAULT/rulesets/arbeit/regeln/CI_TAKT.md`). Je Commit sofort im Hintergrund `scripts/test.sh ci commit <sha> --quick -- --cached` und
weiterarbeiten: Lint und die Specs, die der Diff erreicht; eine `REGRESSION` sofort beheben; quick ist kein Beweis.
Einmal pro Push voll für den Endstand: `scripts/test.sh ci commit HEAD --base=@{upstream} --wsl -- --cached` (auf
Windows in WSL2, etwa zehnmal schneller; ohne WSL ohne `--wsl`). Ein CLEANer Windows-Lauf legt den Beweis für den
pre-push-Hook ab, sonst läuft der Hook nur `fast` (Sekunden). Ist der Endstand rot, grenzt
`--range=@{upstream}..HEAD` den Commit ein. Öffentliche Repos mit `ci.workflow.land = true` landen per
`testing ci land` (gehostete CI vor `main`). Gebündelt pushen; fertig erst bei grüner CI je System. Im Arbeitsbaum
läuft nur `scripts/test.sh --file <teil>`. Ein umgeschriebener Commit (Rebase, Amend) mit gleichem Baum behält sein
Urteil.
