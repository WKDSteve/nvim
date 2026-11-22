# Nvim-Plugin (Lua)

Die allgemeinen Arbeitsregeln laden aus `~/.claude/rules/rules-vault-arbeit-*.md` (Quelle
`$RULES_VAULT/rulesets/arbeit`); hier nur, was für Lua-Plugins dazukommt, mit Verweis per Regel-ID.

## Konventionen

- Installations-Specs und Plugin-Pfade: `MASCHINE-08` (auf `STEVESPC` direkt unter `E:/repos/<name>`, sonst
  `$REPOS_DIR/repos/<name>`; Specs in `$NVIM_CONFIG_DIR/lua/plugins/personal/init.lua`).
- Code muss luacheck- und stylua-clean sein, bevor er als fertig gilt; neue Features nach Möglichkeit im plugin-eigenen
  `TESTS/`-Ordner testen (`REVIEW-04`; luacheck/stylua erzwingt zusätzlich der globale Hook `check-hook.js`).
- Regelwerke: `$RULES_VAULT/rulesets/lua/regeln/LUA_NVIM.md` und `PERFORMANCE.md` (Skill `lua-nvim`), `lib.nvim` nutzen
  (`DOKU-04`); Lua-Tools: `$REPOS_DIR/tasks-vault/TOOLS/lua-plugin-tools.md`.
- Keybinding geändert oder neu: ggf. `$NVIM_CONFIG_DIR/docs/NOTES/BINDINGS` nachziehen (`DOKU-02`).
- Bootstrap-Dateien (`scripts/test.sh`, `TESTS/minimal_init.lua`) nur über `testing init --update` (`CI-15`); ein hier
  nicht anwendbarer Testfall endet mit `n/a` (`CI-16`).

## Commits prüfen und CI-Takt

Regeln `CI-01` bis `CI-16`, vor allem: Commits mit `scripts/test.sh ci commit <sha>` prüfen, nie im Arbeitsbaum, nie
auslassen (`CI-11`); je Commit quick im Hintergrund (`CI-01`), ein voller Lauf pro Push mit `--wsl` (`CI-02`), roten
Endstand eingrenzen (`CI-04`), öffentliche Repos mit `land = true` per `testing ci land` (`CI-05`), fertig erst bei
grüner CI je System, `scripts/test.sh ci remote` (`CI-06`); vor einem Push, der Exporte entfernt: `testing callers`
(`CI-09`).

Werkzeug-Hinweise zu `ci commit`: ein schon geprüfter Commit kommt aus dem Gedächtnis (`(kept result)`); `-- --cached`
lässt Commit und Basis einen Cache teilen; `--json=<datei>` liefert `testing-ci-commit/1`; `--keep` lässt die Worktrees
zum Nachstellen stehen (die `rerun`-Zeile nennt den Befehl). Auf der Workstation läuft kein Runner (`FALCON-11`).
- Git: In einer Cloud-Sitzung (`CLAUDE_CODE_REMOTE` gesetzt) nie auf `main` pushen, nur auf den eigenen Branch `claude/…`; gelandet wird lokal per Rebase, der Geräteschlüssel signiert dabei (`GIT-09`). Das „auf main pushen“ (`GIT-01`) gilt nur lokal.
