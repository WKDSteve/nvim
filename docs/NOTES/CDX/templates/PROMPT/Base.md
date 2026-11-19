
# Vorgaben/Richtlinien/Guiding

Die Arbeitsregeln stehen im rules-vault (`$RULES_VAULT/rulesets/arbeit`) und laden als Kontext aus
`~/.claude/rules/rules-vault-arbeit-*.md` in jede Sitzung; Verweise hier per Regel-ID. Fehlen sie (kein Klon, Cloud-Sitzung):
`$RULES_VAULT/rulesets/arbeit/regeln/` lesen oder statt dieser Vorlage `Base_standalone.md` nehmen.

## Worauf es in jeder Aufgabe ankommt

- Deutsch im Chat, Englisch im Code (`ALLG-01`); höchstens ein Agent gleichzeitig (`ALLG-02`); laufend sagen, was passiert (`ALLG-03`).
- Maschine lesen, bevor etwas Getaggtes oder Workstation-Bezogenes läuft (`MASCHINE-01`, `MASCHINE-05`, `MASCHINE-06`); Plugin-Pfade: `MASCHINE-08`.
- Tasks im tasks-vault: erkennen, claimen, anlegen, abschließen nach `TASKS-01` bis `TASKS-12` (CLI-Hilfe: `tasks --help`).
- Git: fertig = committet und auf `main` gepusht, ohne PR (`GIT-01`), ohne Co-Author (`GIT-02`), signiert (`GIT-03`); geteilte Checkouts (`GIT-05`), vor dem Push `git log origin/main..HEAD` (`GIT-06`), Flotte (`GIT-07`).
- Commit-Liste mit Haken und Stern am Ende jeder Ausgabe (`REVIEW-01`); nach Abschluss selbst reviewen (`REVIEW-02`); jeder Fix mit Test, der ohne ihn rot wird (`REVIEW-03`); Linter auf null (`REVIEW-04`).
- Prüfen und pushen im CI-Takt: je Commit quick im Hintergrund, ein voller Lauf pro Push, fertig erst bei grüner CI je System (`CI-01` bis `CI-16`, vor allem `CI-01`, `CI-02`, `CI-06`, `CI-11`); Runner privater Repos: `CI-12`, Runner-Guard: `CI-13`.
- Doku: Endnutzer-Docs im Repo, alles andere im tasks-vault (`DOKU-01`), README/Bindings mitziehen (`DOKU-02`), Tools nach `TOOL-PLACEMENT.md` (`DOKU-03`).
- Code-Regelwerke: Lua/Neovim `$RULES_VAULT/rulesets/lua/regeln/LUA_NVIM.md` und `PERFORMANCE.md`, native Apps `$RULES_VAULT/rulesets/native`; `$REPOS_DIR/lib.nvim` nutzen, wo sinnvoll (`DOKU-04`).
- Fallen dieser Umgebung: Backslashes nie durch die Shell (`FALLEN-01`), Temp-Skripte neu benennen (`FALLEN-02`), Windows-Pipes (`FALLEN-03`), Detektor braucht Positivtest (`FALLEN-04`), Windows-Pfade nicht in den Bash-PATH (`FALLEN-05`).

---
