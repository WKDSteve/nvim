# Offene Live-Checks: jetzt im Vault und in der Abnahme

Diese Datei war bis 2026-11-10 die Handliste aller Live-Checks, die nur Stefan abnehmen kann. Nach zehn Tagen war sie zur
Hälfte veraltet (30 der 70 Punkte schon erledigt, 20 weitere hatten inzwischen Testblätter). Die Liste wird darum nicht
mehr hier geführt, sondern dort, wo die Checks ohnehin stehen: in den Tasks des Vaults.

Die eine Liste aller offenen Live-Checks ist die **Abnahme-Ansicht von tasks-desktop** (`g a`). Sie ist eine Abfrage über
den Vault und zeigt drei Gruppen, jede mit ihrer Anzahl:

- **Wartet auf dein Urteil**: Das Testblatt ist maschinell grün, dein Urteil fehlt (`tasks list @abnahme-inbox`, gleich
  `--sheet=inbox`).
- **Von Hand, mit Testblatt**: `tasks list @abnahme-manual` (`--sheet=manual`). Der Block `## Test sheets` jeder Task
  zeigt, was zu beurteilen und was von Hand zu tun ist.
- **Von Hand, ohne Testblatt** (echte Konten, Mac, sauberes Konto, Alltagsnutzung über Tage): die offenen Tasks mit dem
  Tag `needs-live-test` ohne Blatt, mit ihren Akzeptanz-Kästchen zum Abhaken (`tasks list @abnahme-by-hand`, gleich
  `--tag=needs-live-test --sheet=none --status=open,doing,decision`).

Im Dashboard von tasks.nvim zeigt das Listen-Menü (`gl`) dieselben drei Listen mit Anzahl. Alle Live-Checks, auch
geparkte und blockierte: `tasks list --tag=needs-live-test`.

Stand, Einordnung und Lücken stehen im Bericht
`$REPOS_DIR/tasks-vault/testing.nvim/NOTES/Final-Checks-Analyse-2026-11-10.md` (je Check: automatisiert mit Blatt,
bleibt manuell, oder braucht ein Feature von testing.nvim mit Task).

Die übrigen Dateien in diesem Ordner sind Checklisten und Protokolle einzelner Runden, auf die Tasks verweisen; sie
bleiben hier. `BINDINGS-RUNTIME-CHECKLIST.md` liest zudem der Code (`:Bindings`, `bindings_explorer/config.lua`).

Der alte Inhalt dieser Datei steht in der Git-Geschichte (letzter Stand: `git show 7fd9e5b03:docs/ROADMAP/Final_Checks/offene-live-checks-2026-10-30.md`).
