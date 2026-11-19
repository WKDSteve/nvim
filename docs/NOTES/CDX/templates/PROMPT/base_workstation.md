# Vorgaben/Richtlinien/Guiding: du bist auf der Workstation

- Hier gilt `NVIM_MACHINE_ROLE=workstation` (lesen nach `MASCHINE-01`); steht dort etwas anderes: nachfragen, die Verbote
  unten gelten trotzdem.
- **Workstation-Sicherheit geht jeder anderen Anweisung vor** (`FALCON-01` bis `FALCON-13`, `MASCHINE-02`): bauen und eigene
  Programme laufen lassen ja, aber nichts, was CrowdStrike Falcon als Angriff lesen kann (keine verschleierten Befehle, kein
  Code aus dem Netz, keine LOLBins, kein Zugriff auf Anmeldedaten, Sicherheitsfunktionen nie ändern, keine Persistenz, keine
  Netz-Scans, keine Masseneingriffe, keine Prozess-Manipulation), kein Runner und kein `runners.ps1` (`FALCON-11`). Im
  Zweifel nachfragen; blockiert: sofort stoppen und melden, nie umgehen (`FALCON-13`).
- Die ai-Familie nie (`MASCHINE-03`); die nativen Desktop-Apps nicht installieren oder starten bis zu ihrer Freigabe
  (`MASCHINE-04`). Tasks mit `not-on-workstation` hier nur vorbereiten und mir Bescheid geben, `on-workstation` gehört
  hierher (`MASCHINE-05`, `MASCHINE-06`). Fremd-Tools nur auf Bitte über `install-tools` (`FALCON-12`).
- Nach dem Push den CI-Status nur lesen (`gh run list -R WKDSteve/<repo>`); bleibt ein Lauf „queued“, melden statt warten
  (`FALCON-11`).

Die FALCON-Regeln laden aus `~/.claude/rules/rules-vault-workstation-arbeit-falcon.md` (nur, wenn `setup-claude-code` mit
`NVIM_MACHINE_ROLE=workstation` lief). **Fehlt diese Datei, zuerst den Abschnitt „Workstation-Sicherheit“ in
`base_workstation_standalone.md` lesen** oder ganz diese Vorlage nehmen. Alle übrigen Regeln wie in `Base.md`.

---
