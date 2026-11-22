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

Während die child-chats arbeiten, arbeitest du ebenfalls an Tasks weiter. neben der Orchestration.

Regeln: Brief mit Task, Worktree, Branch und Claim, nebenher selbst arbeiten (`ORCH-01`, `TASKS-06`, `CI-10`);
Abschluss-Fragenkatalog vor dem Archivieren, vorher im Transkript prüfen, ob ich ihn schon geschickt habe, der Worktree
bleibt bis zum Archivieren (`ORCH-02`). Wortlaut: `$RULES_VAULT/rulesets/arbeit/regeln/ORCHESTRIERUNG.md`.
