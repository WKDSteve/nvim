Verstanden: Für den Rest gebe ich dir Prompts für eigene Orchestrator-Chats aus, je einer für fünf Repos. Damit die Prompts kurz bleiben, kommt der gemeinsame Ablauf in eine Datei im Vault, und jeder Prompt verweist darauf. sandbox und insights wandern in die erste Gruppe. Ich starte sie also nicht mehr selbst; hier laufen nur noch die vier Childs aus Welle C (casedesk, pdfport, docmap, mdview).

Der gemeinsame Ablauf liegt jetzt im Vault: [Performance-Pruefung-Orchestrator-Brief.md](E:/repos/tasks-vault/ALL/Performance-Pruefung-Orchestrator-Brief.md) (`bc85d0f`). Darin stehen Lesestoff, Ablauf, Abschluss-Check je Child und Archivieren, die Regel „Werkzeug nicht ändern, Fehler nur als Task“, die Last-Hinweise und die Gruppentabelle.

Hier die sechs Prompts. Starte am besten eine Gruppe nach der anderen, weil Runner und Childs auf demselben PC laufen. Repos, die noch nie eine Sitzung hatten, brauchen in jedem Orchestrator-Chat deinen Klick auf „Trust repository“, immer eins nach dem anderen.

**Gruppe 1**
```text
Du bist Orchestrator für die Performance-Prüfung, Gruppe 1: sandbox.nvim, insights.nvim, media.nvim, images.nvim, replacer.nvim (alle unter E:\repos).
Lies zuerst vollständig E:\repos\tasks-vault\ALL\Performance-Pruefung-Orchestrator-Brief.md und arbeite ihn für diese fünf Repos ab: Tasks anlegen bzw. vorhandene nutzen, Push-Folgen prüfen, Briefe aus der Vorlage im Konzept-Anhang erzeugen, je Repo ein Opus-Child starten (höchstens fünf), begleiten, Abschluss-Check je Child, archivieren, Worktrees aufräumen, Dach-Task ergänzen.
Gruppenhinweise: sandbox – keine echten Container im Sheet (podman/docker als Stand-in oder manual:), landet per ci land. insights – der rg-Burst (26 Starts je Schritt, scan/rg.lua:85) als Folge-Task mit Messwert anlegen, landet per ci land. Die Lücken-Tasks von sandbox und insights existieren schon.
Nenne zuerst die Maschine. Am Ende Commit-Liste der Gruppe.
```

**Gruppe 2**
```text
Du bist Orchestrator für die Performance-Prüfung, Gruppe 2: buffer-ctx.nvim, gopath.nvim, hover.nvim, tasks.nvim, rules.nvim (alle unter E:\repos).
Lies zuerst vollständig E:\repos\tasks-vault\ALL\Performance-Pruefung-Orchestrator-Brief.md und arbeite ihn für diese fünf Repos ab: Tasks anlegen, Push-Folgen prüfen, Briefe aus der Vorlage im Konzept-Anhang erzeugen, je Repo ein Opus-Child starten (höchstens fünf), begleiten, Abschluss-Check je Child, archivieren, Worktrees aufräumen, Dach-Task ergänzen.
Gruppenhinweise: hover – Netz nur per Stub (example.test), echte Seiten bleiben Live-Sheets. tasks.nvim – schreibt nie in den echten Vault, nur in Fixtures. gopath – ein config=user-Sheet hat im ersten Lauf über github_stats einen gh repo clone ausgelöst (Task github_stats.nvim/sheet-mit-echter-config-startet-gh-repo-clone-des-daten-vaul), nicht doppelt anlegen.
Nenne zuerst die Maschine. Am Ende Commit-Liste der Gruppe.
```

**Gruppe 3**
```text
Du bist Orchestrator für die Performance-Prüfung, Gruppe 3: open.nvim, language.nvim, ui.nvim, dap.nvim, debugging.nvim (alle unter E:\repos).
Lies zuerst vollständig E:\repos\tasks-vault\ALL\Performance-Pruefung-Orchestrator-Brief.md und arbeite ihn für diese fünf Repos ab: Tasks anlegen, Push-Folgen prüfen, Briefe aus der Vorlage im Konzept-Anhang erzeugen, je Repo ein Opus-Child starten (höchstens fünf), begleiten, Abschluss-Check je Child, archivieren, Worktrees aufräumen, Dach-Task ergänzen.
Gruppenhinweise: open – System-Öffner über fakes (unter Windows fangen Stand-ins keine .exe-Namen: so umgehen wie markdown.nvim es im Sheet tut). dap/debugging – haben keinen Katalog und keine Sheets; echte Debug-Adapter meist perf = "manual:<grund>". language – Netzdienste (Übersetzung, Grammatik) nur per Stub. ui.nvim – ui.kit lebt in lib.nvim, Fixes dort, nicht in ui.nvim.
Nenne zuerst die Maschine. Am Ende Commit-Liste der Gruppe.
```

**Gruppe 4**
```text
Du bist Orchestrator für die Performance-Prüfung, Gruppe 4: reposcope.nvim, runtime-analysis.nvim, github_stats.nvim, my.nvim, ai.nvim (alle unter E:\repos).
Lies zuerst vollständig E:\repos\tasks-vault\ALL\Performance-Pruefung-Orchestrator-Brief.md und arbeite ihn für diese fünf Repos ab: Tasks anlegen, Push-Folgen prüfen, Briefe aus der Vorlage im Konzept-Anhang erzeugen, je Repo ein Opus-Child starten (höchstens fünf), begleiten, Abschluss-Check je Child, archivieren, Worktrees aufräumen, Dach-Task ergänzen.
Gruppenhinweise: ai.nvim – gehört zur ai-Familie (nie auf der Workstation); Live-Sheets kosten Geld und laufen nie ohne Stefans ausdrückliche Freigabe im Child; ai.completion-blink war im ersten Lauf rot. runtime-analysis – seine Telemetrie verpackt vim.system in der echten Config; das Werkzeug überspringt sie schon. github_stats – nie den echten Daten-Vault anfassen; offene Task zum blockierten Klon (520 Dateien) beachten.
Nenne zuerst die Maschine. Am Ende Commit-Liste der Gruppe.
```

**Gruppe 5**
```text
Du bist Orchestrator für die Performance-Prüfung, Gruppe 5: diff.nvim, emojis.nvim, color_my_ascii.nvim, cascade.nvim, cmdlog.nvim (alle unter E:\repos).
Lies zuerst vollständig E:\repos\tasks-vault\ALL\Performance-Pruefung-Orchestrator-Brief.md und arbeite ihn für diese fünf Repos ab: Tasks anlegen, Push-Folgen prüfen, Briefe aus der Vorlage im Konzept-Anhang erzeugen, je Repo ein Opus-Child starten (höchstens fünf), begleiten, Abschluss-Check je Child, archivieren, Worktrees aufräumen, Dach-Task ergänzen.
Gruppenhinweise: Diese Repos haben wenige oder keine Startstellen (cascade, cmdlog: 0). Ziel ist dann vor allem ein vollständiger Katalog: jedes Feature ohne eigenen Prozess mit perf = "skip:<grund>" markieren, Sheets nur für Features, die wirklich Prozesse starten. color_my_ascii – offene Task zu den 31 Sprachtabellen beim Markdown-Öffnen nicht doppelt anlegen.
Nenne zuerst die Maschine. Am Ende Commit-Liste der Gruppe.
```

**Gruppe 6**
```text
Du bist Orchestrator für die Performance-Prüfung, Gruppe 6: data.nvim, recommender.nvim, spotlight.nvim (unter E:\repos), die nvim-Config (C:\Users\bartl\AppData\Local\nvim) und lib.nvim (E:\repos\lib.nvim).
Lies zuerst vollständig E:\repos\tasks-vault\ALL\Performance-Pruefung-Orchestrator-Brief.md und arbeite ihn ab: Tasks anlegen, Push-Folgen prüfen, Briefe aus der Vorlage im Konzept-Anhang erzeugen, je Repo ein Opus-Child starten (höchstens fünf), begleiten, Abschluss-Check je Child, archivieren, Worktrees aufräumen, Dach-Task ergänzen.
Gruppenhinweise: lib.nvim hat keine .testing.lua und keine Sheets (126 Startstellen): BEVOR du dafür ein Child startest, frag Stefan per Auswahl mit Empfehlung, ob lib eigene Sheets bekommt oder seine Abdeckung aus den Läufen der Konsumenten zusammengezählt wird (das wäre eine Werkzeug-Task in testing.nvim); erst dann handeln. nvim-Config – das Child arbeitet in einem eigenen Worktree des Config-Repos (der Haupt-Checkout hat fremde uncommittete Änderungen), Sheets mit config = "user", Katalog fehlt; das Sheet nvim-config.bindings-check war im ersten Lauf rot (über 100 Binding-Befunde, kein Performance-Thema). data/recommender/spotlight haben keine Startstellen: Katalog vollständig, Features ohne Prozess mit perf = "skip:<grund>".
Schließe als letzte Gruppe die Dach-Task, wenn alle Lücken-Tasks erledigt sind. Nenne zuerst die Maschine. Am Ende Commit-Liste der Gruppe.
```

Hier im Chat begleite ich nur noch die vier laufenden Childs aus Welle C (casedesk, pdfport, docmap, mdview) bis zu Abschluss-Check und Archivierung.
