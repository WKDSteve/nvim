Du darfst bis zu 3 child-chats gleichzeitig orchestrieren. Wenn ein child-chat fertig ist, als Abschluss:

  ```text
  Gibt es in diesem Chat noch etwas, dass nicht als Task angelegt wurde?
  Wenn ja:
    a) Erledige alles was offen ist und du erledigen kannst gleich hier
    b) Decisions erledigen wir gleich: Erkläre mir das Problem, empfehle etwas und lass mich in einer Selection wählen
    c) Den Rest lege als Task im tasks-vault an

  Bezüglich möglicher Handläufe:
    - Checke, ob davon etwas mit `testing.nvim` sheets/ bzw featuresheets testbar ist.

    Das ist mir immer lieber, weil die Tests dann dauerhaft bleiben und bei anderen Änderungen im Repo nochmals geprüft werden können.
    Alles was trotzdem händisch bleibt bitte als "Abnahme- Liste" in den tasks-vault eintragen. also `needs-live-test`-Tag.
  ```

ausführen.

Jeder Brief an ein child nennt das Mandat im Wortlaut von `ORCH-01` (Chat-Name und Datum eingesetzt), sonst wartet
das child auf eine Bestätigung. Der Brief verlangt auch:
jede angelegte Task bekommt Kontext, Akzeptanz und Notizen (kein leerer `<!-- -->`-Rumpf); der Abschluss prüft das mit
`grep -c '<!--'` über die neuen Task-Dateien.

Während die child-chats arbeiten, arbeitest du ebenfalls an Tasks weiter. neben der Orchestration.

Den Brief zuerst als Datei ablegen, dann starten; ein Befund gehört genau einem child, zwei childs nie zur selben Zeit im
selben Repo; `start_session` mit `cwd` in Backslash-Form (`E:\repos\x`). Vor dem Start den Brief prüfen:
`node $REPOS_DIR/tasks-vault/TOOLS/scripts/brief-check/brief-check.mjs <brief.md>` (Commits, Tasks, Pfade und Namen,
die der Brief nennt, gegen `origin/main`); was `MISSING` oder `NOT-ON-MAIN` ist, korrigieren oder im Brief als
„ungeprüft“ kennzeichnen. Jeder Brief nennt außerdem:
- `tasks` liegt in der Git-Bash nicht auf dem PATH: `nvim -n -i NONE --headless -u NONE -l "$REPOS_DIR/tasks.nvim/scripts/tasks.lua" <befehl> … --vault=<absoluter pfad>`
- Befehle auf eine geclaimte Task (`done`, `unclaim`, `set status=…`) mit `--by=<Name>`
- Vault-Arbeit in einem eigenen Vault-Worktree, wenn der geteilte Checkout schmutzig ist; nach einem Rebase will der
  pre-push-Hook des Vaults einen neu erzeugten Index (`tasks index`), nie `--no-verify`
- ein mit geändertes Basis-Repo (appkit, lib.nvim) bekommt vor dem Push denselben vollen Lauf (`CI-02`)
- was nur in den Notizen oder im Bericht steht, ist erst erledigt, wenn es eine Task ist

Regeln: Brief mit Mandat, Task, Worktree, Branch und Claim, gefüllte Task-Rümpfe, nebenher selbst arbeiten (`ORCH-01`, `TASKS-06`, `CI-10`);
Abschluss-Fragenkatalog vor dem Archivieren, vorher im Transkript prüfen, ob ich ihn schon geschickt habe, der Worktree
bleibt bis zum Archivieren (`ORCH-02`); App- und CLI-Fallen (`ORCH-04`). Wortlaut: `$RULES_VAULT/rulesets/arbeit/regeln/ORCHESTRIERUNG.md`.
