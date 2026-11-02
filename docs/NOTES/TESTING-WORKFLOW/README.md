# Testing-Workflow: wie ich testing.nvim ausnutze

Stand 2026-11-02. Eigener Ordner, damit nachvollziehbar bleibt, **welche Technik wofür** da ist und **wie sie
konkret benutzt wird**. Die Referenz (alle Optionen) steht im Repo `testing.nvim/docs/`, hier steht der
Gebrauch: Entscheidungen, Abläufe, echte Befehle, echte Fälle aus der Arbeit.

Der Ansatz in einem Satz: Prüfungen, die ich früher von Hand gemacht habe (Live-Checks), laufen als Daten
(**Testblätter**) durch einen „Klicker“, wie Testfälle in Tricentis Tosca; alles, was Code prüft, läuft als Specs
(**Suite**); beides läuft lokal und in der **CI** gleich.

## Leseweg

| Datei | Inhalt | Wann lesen |
| --- | --- | --- |
| [01-ueberblick.md](01-ueberblick.md) | Die Stufen der Technik, Tosca-Begriffe, Entscheidungsbaum „was setze ich ein“ | zuerst |
| [02-workflow-alltag.md](02-workflow-alltag.md) | Spec schreiben, schnell prüfen, Suite, vor dem Push | jeden Tag |
| [03-workflow-testblaetter.md](03-workflow-testblaetter.md) | Live-Check als Testblatt: Neovim-Klicker, Browser, manuell, Abnahme-Inbox, Task-Verknüpfung | wenn etwas „angeklickt“ werden muss |
| [04-workflow-ci.md](04-workflow-ci.md) | `testing ci`, Profile, GitHub-Workflows, Runner, Container-Image, Skips | wenn etwas in die CI soll |
| [05-workflow-desktop-und-web.md](05-workflow-desktop-und-web.md) | tasks-desktop, docmap-desktop, die Web-Seiten (mdview, docmap-Karte, Web-Variante) | für Desktop-/Web-Apps |
| [usecases/README.md](usecases/README.md) | Anwendungsfälle: je ein echter Fall mit Dateien, Befehlen, Ergebnis | zum Nachschlagen und Nachmachen |

## Die kürzeste Fassung

```bash
# im Repo: schnell prüfen, dann alles
scripts/test.sh --file <teil-des-spec-namens>      # eine Spec
scripts/test.sh                                    # die ganze Suite
scripts/test.sh ci --profile=fast                  # stylua + luacheck, Sekunden
scripts/test.sh ci                                 # die ganze Pipeline wie die CI
scripts/test.sh conformance                        # die Regelprüfung (K1..K16)

# ein Live-Check als Blatt
testing sheets new --from-task <bereich/task>      # Entwurf aus den Akzeptanz-Checkboxen
scripts/test.sh --file sheets                      # Blätter laufen als Fälle `sheet:<id>`
testing sheets run --task <bereich/task> --tasks <vault>   # sofort, Stand in die Task schreiben
testing sheets report <root> --from ir.json --tasks <vault> # Abnahme-Inbox und Task-Block
```

(`testing` steht für `nvim -n -i NONE --headless -u NONE -l <testing.nvim>/scripts/testing.lua`; siehe
[02-workflow-alltag.md](02-workflow-alltag.md#der-befehl-testing).)

## Regeln, die überall gelten

- **Ein Skip ist kein Grün.** Fehlt ein Werkzeug (tmux, Podman-Image, chromium, Playwright, `tauri-driver`),
  meldet sich der Fall mit `n/a  <Grund>` (Exit 77 bei Skripten) und zählt als „nicht gelaufen“, nie als bestanden.
- **Ein Fix ohne Test, der ohne den Fix rot wird, gilt nicht als fertig.** Nach dem Test den Fix kurz
  zurücknehmen und sehen, dass er rot wird.
- **Nie auf der Workstation** (`NVIM_MACHINE_ROLE=workstation`): nichts Unsigniertes bauen oder starten; Browser-,
  Tauri-, Container- und Runner-Läufe gehören auf den privaten Rechner.
- **Blätter sind Daten**, kein Code: sie starten keine Programme, die Engine tut das.
- **Beleg statt Behauptung**: jeder Anwendungsfall nennt die Dateien und Commits, an denen man es nachprüfen kann.

## Herkunft

Plan `tasks-vault/ALL/ROADMAP/plans/live-checks-automatisieren-klicker-fuer-neovim-browser-tauri.md` und die
Begriffsnotiz `tasks-vault/ALL/Tosca-Analogie-Live-Check-Automatisierung-2026-10-30.md`. Die Referenz:
`testing.nvim/docs/` (`CLI.md`, `CI.md`, `SHEETS.md`, `TIER3.md`, `CHILD.md`, `GUARDS.md`, `EXIT-CODES.md`).
