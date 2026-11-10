# Offene Live-Checks: jetzt im Vault und in der Abnahme

Diese Datei war bis 2026-11-10 die Handliste aller Live-Checks, die nur Stefan abnehmen kann. Nach zehn Tagen war sie zur
Hälfte veraltet (30 der 70 Punkte schon erledigt, 20 weitere hatten inzwischen Testblätter). Die Liste wird darum nicht
mehr hier geführt, sondern dort, wo die Checks ohnehin stehen:

- **Live-Checks mit Testblatt** (der Maschinenteil läuft, dein Urteil fehlt): Abnahme-Ansicht von tasks-desktop, bzw.
  `tasks list --sheet=inbox,manual`. Der Block `## Test sheets` jeder Task zeigt, was zu beurteilen und was von Hand zu tun ist.
- **Alle offenen Live-Checks**, auch ohne Blatt (echte Konten, Mac, sauberes Konto, Alltagsnutzung über Tage):
  `tasks list --tag=needs-live-test` (seit 2026-11-10 trägt jede Live-Check-Task diesen Tag).
- **Stand, Einordnung und Lücken**: Bericht
  `$REPOS_DIR/tasks-vault/testing.nvim/NOTES/Final-Checks-Analyse-2026-11-10.md` (je Check: automatisiert mit Blatt,
  bleibt manuell, oder braucht ein Feature von testing.nvim mit Task).

Sobald die Abnahme auch Tasks ohne Blatt zeigt (`tasks-desktop/abnahme-ansicht-auch-live-check-tasks-ohne-testblatt-needs-l`),
ist sie die eine Liste.

Die übrigen Dateien in diesem Ordner sind Checklisten und Protokolle einzelner Runden, auf die Tasks verweisen; sie
bleiben hier. `BINDINGS-RUNTIME-CHECKLIST.md` liest zudem der Code (`:Bindings`, `bindings_explorer/config.lua`).

Der alte Inhalt dieser Datei steht in der Git-Geschichte (letzter Stand: `git show 7fd9e5b03:docs/ROADMAP/Final_Checks/offene-live-checks-2026-10-30.md`).
