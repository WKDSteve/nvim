# Log-Lesekopie: offen, zu testen, worauf achten

Stand 2026-11-17, nach dem Orchestrator-Chat. Fertig und auf main sind:
- **casedesk.nvim:** alle 7 Stufen der Log-Lesekopie, Fehlerkatalog, Nacharbeiten, Kern ohne Neovim;
- **casedesk-web:** Gerüst und Lesekopie im Browser;
- **tasks-web:** Vault-Wechsel, veröffentlicht;
- **Schwester-Plugins:** mdview-Eingang für erzeugte Ansichten, hover-Vorschau-Kette, lib-/emojis-Fix.

Bedienung: `casedesk.nvim/docs/logview-cheatsheet.md`.

Jeder Abschnitt nennt die Task, die nach dem Test per `tasks done <id>` geschlossen wird. Gefundene Fehler kommen als eigene bug-Task in den Bereich.

---

## 1. Vorher erledigen (du)

- [ ] **WKDBook-Tricentis pushen:** Der Commit `fd3a402` (`Workflow/log-patterns.conf`, 6 Katalogeinträge) ist nur committet. Ohne ihn hat die Workstation keinen Katalog.
- [ ] **Workstation: `:Lazy update`.** Dort kommen die Plugins aus lazy; `git pull` in `$REPOS_DIR` wirkt nicht. Betroffen: casedesk.nvim, lib.nvim, mdview.nvim, hover.nvim, emojis.nvim.
- [ ] **Privater PC:** Neovim neu starten (oder Plugins neu laden), damit der Stand von main gilt.
- [ ] **Gerüst-Sitzung „casedesk-web: Repo-Gerüst“ selbst archivieren.** Sie lief direkt in `E:\repos`, ohne eigenen Worktree.

## 2. Testen am privaten PC (Neovim, echte Fall-Logs)

Die Originale liegen unter `tasks-vault/casedesk.nvim/NOTES/log-view/original/<Fall>/`. Das sind Kundenlogs: nur ansehen, nichts daraus in Repos, Specs oder Commits übernehmen.

### 2a. Grundfunktion und Formate
Task `casedesk.nvim/abnahme-log-lesekopie-f7-bis-f13-berichte-und-dateikopf`, dazu `…-tbox-und-serilog-logs-live` und `…-datei-picker-und-appium-logs-live`.
- [ ] `:Case log view` ohne Datei in einem Fall mit vielen Logs (1335876): Der Picker zeigt Datei, Größe, Format und Konfidenz bündig, die Vorschau zeigt die Lesekopie. Ohne pickers.nvim: `ui.kit.select`.
- [ ] `:Case log formats` an 1335876: Die Tabelle ist lesbar, kein Log läuft roh durch.
- [ ] Je Format ein echtes Log öffnen und lesen:

  | Format | Log |
  | --- | --- |
  | BrowserStack | 1451858, der Auslöser |
  | Appium | 1245018 `*_appium.log` |
  | TBox-Agent | 1468342 |
  | ToscaCommander | 996010 |
  | Serilog-Text | 1335876 Gateway/DistributionExecutionMonitor |
  | Serilog-JSON | 1201484 |
  | Workspace | 1335876 `Log_*.txt` |
  | Launcher | 1252115 |
  | Flow-Agent | 1547736 |
  | FlexNet | 1245018 |
  | ToscaModuleLogs | 711373 |
  | LiveCompare | 1135620 |
  | SupportInfo | 859769 |
  | FailedJobDetails | 1335876 |

  **Prüfen:** Öffnet ohne spürbare Wartezeit? Kopfzeile mit Release und Log level? `]e` findet die Fehler? Stacktraces klappen als Baum auf, der eigene `Tricentis.*`-Frame ist hervorgehoben? `gO` trifft die richtige Originalzeile?
- [ ] **Auslöser 1451858:** Die zwei Seitenquelltexte vor und nach dem Klick lesen sich. `gs` wechselt labelled / all / clickable. `m` auf beide, dann `gd`: Der Diff zeigt, was nach dem Klick fehlt.

### 2b. Wiederholungen, Zeit, Filter, Mischen
Tasks `…-zeit-filter-und-merge-live`, `…-bloecke-undatiert-und-katalog-hover`.
- [ ] **FileService-Log** (`Log20261002.txt`, liegt nur im WKDBook): Herzschläge und der stündliche Block falten zu wenigen Zeilen, Anzahl und Zeitraum stimmen. `gr` zeigt alles und zurück, der Cursor bleibt beim Eintrag.
- [ ] **`:Case log merge`** über die 10 Dienst-Logs eines Tages (1335876):
  - öffnet in unter einer Sekunde;
  - die Spalte „Log“ hilft;
  - Lückenzeilen und `]g` stimmen;
  - ein verneinter `source`-Filter (`gf`) blendet einen Dienst aus, `gF`/`g0` nehmen ihn zurück.
- [ ] **`tz` auf einem TBox-Log** (ohne Zone): Die Statuszeile nennt „without zone: as written“.
- [ ] **Merge mit einer `ToscaModuleLogs.txt`** (ohne Datum): Hinweis, und die Einträge landen an einem sinnvollen Tag.

### 2c. Katalog
Task `casedesk.nvim/abnahme-katalog-bekannter-fehlermeldungen-live`.
- [ ] **`:Case log catalog seed`** am echten Korpus: Die Vorschau ist lesbar, ein Nein schreibt nichts, ein Ja hängt an, ohne Bestehendes zu ändern, ein zweiter Lauf schlägt nichts doppelt vor.
- [ ] **TBox-Log mit `NullReferenceException`:**
  - `⚑` in der Signspalte, im Kopf `· N known (]k)`;
  - `]k` zeigt Titel, Erklärung und Links;
  - der Hover zeigt den Katalogeintrag.
- [ ] **Absichtlich kaputter Block in `log-patterns.conf`:** wird mit Zeilennummer gemeldet, die anderen Einträge gelten weiter.

### 2d. Integrationen
Tasks `…-diff-spotlight-hover-und-picker`, `…-live-im-browser-und-export-in-den-fall`, `mdview.nvim/abnahme-erzeugte-ansicht-live-aus-neovim-im-echten-browser`.
- [ ] **`gp`:** Der Eintrags-Picker zeigt in der Vorschau den aufgeklappten Eintrag; `<M-o>` öffnet das Original.
- [ ] **`ge`:** Die Quickfix-Liste hat die Fehler an den Originalzeilen.
- [ ] **`*`:** Das Token leuchtet in allen Fenstern, ein zweites `*` nimmt es weg.
- [ ] **Hover (`:Hover show`):** Eintrag dekodiert, Session mit Anzahl, Originalzeilen. Bei einer normalen Datei bleibt die Vorschau von hover.nvim/testing.nvim wie bisher (Vorschau-Kette).
- [ ] **`gm` (mdview):**
  - der Browser zeigt die Lesekopie;
  - Aufklappen, `gs`, Filter und `tz` kommen dort an;
  - ein Klick auf „Z. …“ springt in Neovim;
  - ein Wechsel in eine andere Datei nimmt den Tab nicht weg.
- [ ] **`:Case log export` im Fall:** `Research/NN_LogView.md` mit Fall-Überschrift, gefalteten Wiederholungen und aufgeklappten Körpern; `:Case grep` findet die Datei.
- [ ] **Rechtsklick (ui.nvim-Menü):** „Log (Lesekopie)“ mit allen Aktionen, jede tut dasselbe wie ihre Taste.
- [ ] **`:Case ki logs --readable --preview`** mit dem FileService-Log: Die Vorschau ist kurz und enthält nur den Dateinamen, nie Pfad, Benutzer oder Fallnummer aus dem Pfad.

## 3. Testen auf der Workstation (`on-workstation`)

Vorher `NVIM_MACHINE_ROLE` lesen, es muss `workstation` sein. Läuft etwas schief: anhalten, Falcon-Meldung notieren, nichts erneut versuchen.

### 3a. casedesk-web
Tasks `casedesk-web/probe-und-engine-check-auf-der-workstation`, dann `casedesk-web/abnahme-auf-der-workstation-probe-seite-ordnerwahl-schreiben`.
- [ ] `git clone https://github.com/WKDSteve/casedesk-web.git`; `Get-FileHash` von `probe.html`, `engine-check.html` und `casedesk.html` gegen `SHA256SUMS` prüfen.
- [ ] **`probe.html`** mit einem **leeren** Testordner: alle Zeilen OK; „Marker of the previous visit“ nach einem Chrome-Neustart prüfen; `chrome://policy` notieren.
- [ ] **`engine-check.html`:** alle Zeilen OK, 11 Einträge, Zeiten von 07:58:30.904 bis 08:01:01.262. „Copy result“ in die Task-Notizen.
- [ ] **`casedesk.html`:**
  - echten Fallordner wählen, je Log-Art ein Log öffnen;
  - Seitenleiste mit Fehlern, Warnungen, Exceptions, Lücken, Wiederholungen;
  - Katalog-Datei wählen: Gruppe „Bekannt“;
  - zwei Server-Logs zusammenlegen;
  - großes Log (mehrere MB): Ladezeit und Scrollen notieren.
- [ ] **Chrome neu starten:** Der Fallordner steht unter „Zuletzt benutzt“, ein Klick fragt einmal nach dem Zugriff.
- [ ] **DevTools → Application:** In der IndexedDB `casedesk-web` stehen nur Handles, in `localStorage` nur Ansichtseinstellungen, **kein Log-Text**.
- [ ] **Falcon:** keine Meldung, auch nicht beim `git clone` oder beim Öffnen der großen HTML-Datei.

### 3b. tasks-web Vault-Wechsel
Task `tasks-desktop/abnahme-tasks-web-vault-wechsel-auf-der-workstation`.
- [ ] Im tasks-web-Klon `git pull --ff-only`. „Optionen > Seite aktualisieren …“ nennt `915dc77` oder neuer.
- [ ] `tasks-vault` und `tricentis-vault` je einmal öffnen; das Menü „Projekt“ zeigt beide, der aktive ist markiert.
- [ ] Wechsel per Klick; Ansicht und Filter je Vault kommen zurück.
- [ ] **Nach einem Chrome-Neustart:** Beim Wechsel fragt Chrome genau einmal nach dem Zugriff.
- [ ] Wechsel während eines Schreibvorgangs wird mit „Speichert noch …“ abgelehnt.
- [ ] Falcon meldet nichts.

## 4. Noch zu tun (Tasks im Vault)

**Für dich**
- [ ] `casedesk.nvim/katalog-bekannter-fehlermeldungen-titel-erklaerungen-und-kb`: Titel, Erklärung und KB-/SWAT-Links der 6 vorbefüllten Katalogeinträge schreiben. Keine Kundennamen.
- [ ] `ALL/konzept-termine-und-kalender-vault-tasks-outlook-ics-arbeitg`: Kalender-Konzept durchsehen und entscheiden. Offen sind:
  - der Ort der Ansicht (Vorschlag: tasks-Familie);
  - ob Outlook-Termine aufs Handy dürfen;
  - wo die `.ics` liegt;
  - ob Tricentis den ICS-Link erlaubt.

**Bauen, wenn Zeit ist** (alle Priorität 3, Kandidaten für Children)
- casedesk-web:
  - `casedesk-web/schreiben-export-nach-research-und-katalogeintrag-aus-der-se`: Export und Katalogeintrag aus der Seite, mit Konfliktprüfung.
  - `casedesk-web/ci-fuer-casedesk-web`: CI auf dem Runner.
- casedesk.nvim:
  - `casedesk.nvim/casedesk-web-api-wiederkehrende-bloecke-liefern`: die Faltung ganzer Blöcke auch im Browser.
  - `casedesk.nvim/log-lesekopie-einzelnes-log-ohne-datum-mit-abstaenden`.
  - `casedesk.nvim/log-view-formats-der-konfiguration-im-browser-format-specs-a`: eigene Formate auch im Browser.
  - `casedesk.nvim/tier-of-extensions-und-to-utf8-aus-logs-lua-in-den-reinen-ke`: Kopien in casedesk-web auflösen.
  - `casedesk.nvim/luals-warnungen-in-logview-view-und-logview-integrations-ber`.
- tasks-desktop:
  - `tasks-desktop/web-vault-menue-zugriff-beim-oeffnen-neu-lesen`: zwei Kleinigkeiten aus dem Review.
  - `tasks-desktop/fremde-kalender-ics-in-kalender-und-zeitleisten-ansicht-einb`: niedrige Priorität, wartet auf das Kalender-Konzept.
- Geparkt: `ALL/outlook-kalender-ueber-microsoft-graph-anbinden-geparkt`.

## 5. Worauf achten

- **Kundendaten**
  - Die Originale in `NOTES/log-view/original/` nie in ein Repo, eine Spec, eine Fixture oder einen Commit.
  - casedesk-web ist **öffentlich**: dort nur erfundene Fixtures. Die Seite bündelt den Lua-Kern aus dem privaten casedesk.nvim, das ist in der Entwicklungsphase so gewollt.
  - Vor dem Wechsel auf privat ist zu klären, wie die Workstation dann klont (Anmeldung wie beim WKDBook).
- **KI**
  - Logs gehen nur über `:Case ki logs` hinaus, mit Schwärzung und Bestätigung.
  - Erst `--preview` ansehen; `--readable` schickt nur den Dateinamen, nie den Pfad.
- **Katalog**
  - Er liegt im WKDBook-Tricentis und wird nur von dir gepusht.
  - Muster immer verankert, wörtliche Muster gelten als ganzes Wort; zu breite Muster meldet der Lader.
- **Workstation / Falcon**
  - Dort nur die Web-Seiten (`file://`); keine nativen Apps, kein `start-*.cmd`, kein Autostart, bis ein `on-workstation`-Handlauf sie freigibt.
  - Jede neue Seite zuerst über `SHA256SUMS` prüfen.
  - Plugin-Updates dort nur über `:Lazy update`.
- **Original unberührt:** Die Lesekopie schreibt nie ins Log. Zum Nachsehen immer `gO`, nie die Lesekopie als Beleg zitieren, sondern `Datei:Zeile` des Originals.
- **Leistung:** Alle gemessenen Logs (bis 590 kB) bauen sich in unter 0,2 s auf. Ein Log über 25 MB wird abgelehnt (`logs.MAX_FILE_BYTES`). Fühlt sich etwas langsam an: Zahlen in die Abnahme-Task, nicht raten.
