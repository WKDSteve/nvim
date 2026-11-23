# Native Apps starten, stoppen, prüfen

Die Befehle für die installierten Apps, in einem normalen PowerShell (nicht aus einer Claude-Sitzung, die AppData
und HKCU umleitet). Installationsorte und Bauen: [toolchain.md](toolchain.md).

Kurze Befehle unter dem App-Namen (`hub-desktop status` statt des ganzen Pfads) legt jedes `install` an, sobald die App
appkit ab `v0.77.0` nutzt: ein Starter in `%LOCALAPPDATA%\appkit-family\bin`, der einmal in den Benutzer-PATH kommt
(Plan im Vault: `ALL/cli-befehle-der-app-familien`). Nach dem ersten `install` ein **neues** Terminal öffnen. Bisher
umgestellt: hub-desktop, tasks-desktop, rules-desktop. Die übrigen Apps folgen; bis dahin gelten ihre langen Befehle unten.

## hub-desktop

```powershell
hub-desktop                  # Hub starten, falls er nicht läuft, und die Seite öffnen
hub-desktop open             # dasselbe
hub-desktop start --open     # im Hintergrund starten (Tray-Icon), Seite öffnen
hub-desktop stop             # stoppen (auch: quit)
hub-desktop restart          # stoppen und neu starten
hub-desktop status           # läuft er? Prozess, Port, Version; Exit 0 ja, 1 nein (--json für Skripte)
hub-desktop link             # einmaliger Kopplungs-Link, ohne ihn zu öffnen
hub-desktop logs -f          # Log des Hubs im Hintergrund mitlesen
hub-desktop paths            # Programm, Einstellungen, Log, Befehl
hub-desktop autostart status # startet er mit der Anmeldung? (on|off|status)
hub-desktop help status      # Hilfe zu einem Befehl
```

Vor dem ersten `install` mit appkit `v0.77.0` (oder wenn der Befehl fehlt) der lange Weg:
`& "$env:LOCALAPPDATA\hub-desktop\bin\hub-desktop.exe" install`.

## tasks-desktop

Installiert über `install.ps1` oder `scripts\build-install.ps1` nach `%LOCALAPPDATA%\tasks-desktop\bin`; das Programm
heißt `tasks-hub.exe`, der Befehl im Terminal `tasks-desktop` (ab appkit `v0.77.0`).

```powershell
tasks-desktop                  # Hub starten, falls er nicht läuft, und die Seite öffnen
tasks-desktop open             # dasselbe
tasks-desktop start --open     # im Hintergrund starten, Seite öffnen
tasks-desktop stop             # stoppen (auch: quit)
tasks-desktop restart          # stoppen und neu starten
tasks-desktop status           # läuft er? Prozess, Port, Version; Exit 0 ja, 1 nein (--json für Skripte)
tasks-desktop link             # einmaliger Kopplungs-Link, ohne ihn zu öffnen (mit Tailnet auch der fürs Handy)
tasks-desktop logs -f          # Log des Hubs im Hintergrund mitlesen
tasks-desktop paths            # Programm, Einstellungen, Log, Befehl
tasks-desktop autostart status # startet er mit der Anmeldung? (on|off|status)
tasks-desktop help             # alle Befehle, auch setup, devices, phone, areas
```

Vor dem ersten `install` mit appkit `v0.77.0` der lange Weg:
`& "$env:LOCALAPPDATA\tasks-desktop\bin\tasks-hub.exe" install`.

## rules-desktop

Installiert nach `%LOCALAPPDATA%\rules-desktop\bin`; das Programm heißt `rules-hub.exe`, der Befehl im Terminal
`rules-desktop` (ab appkit `v0.77.0`), mit denselben Befehlen wie `tasks-desktop`.

```powershell
rules-desktop                  # Hub starten, falls er nicht läuft, und die Seite öffnen
rules-desktop open             # dasselbe
rules-desktop start --open     # im Hintergrund starten, Seite öffnen
rules-desktop stop             # stoppen (auch: quit)
rules-desktop restart          # stoppen und neu starten
rules-desktop status           # läuft er? Prozess, Port, Version; Exit 0 ja, 1 nein (--json für Skripte)
rules-desktop link             # einmaliger Kopplungs-Link, ohne ihn zu öffnen
rules-desktop logs -f          # Log des Hubs im Hintergrund mitlesen
rules-desktop paths            # Programm, Einstellungen, Log, Befehl
rules-desktop autostart status # startet er mit der Anmeldung? (on|off|status)
rules-desktop help             # alle Befehle
```

Vor dem ersten `install` mit appkit `v0.77.0` der lange Weg:
`& "$env:LOCALAPPDATA\rules-desktop\bin\rules-hub.exe" install`.

## Auf der Workstation (CrowdStrike Falcon)

Auf der Workstation endet `<hub> start` still, ohne Ausgabe, mit Exit `0xE0000027` (-536870873), und es läuft kein
Hub. `start` startet den Hub über `wscript.exe` und ein Skript `start-hub.vbs`, und diese Kette aus einem
unsignierten Programm wird dort (vermutlich von Falcon) beendet. Betroffen sind auch der Autostart (der Run-Key ruft
`start`), der Doppelklick, `install --shortcut` und das Entfernen des Links in `uninstall`. Bug im Vault:
`appkit/start-ueber-wscript-von-edr-beendet`.

Bis zum Fix einer der beiden Wege, für rules-desktop mit `rules-hub` und `rules-desktop`:

```powershell
# a) im Vordergrund, das Terminal bleibt offen (Ctrl-C stoppt den Hub); im zweiten Terminal `open --launch`
& "$env:LOCALAPPDATA\tasks-desktop\bin\tasks-hub.exe" serve

# b) im Hintergrund: start legt das Skript an (und wird beendet), dann das Skript von Hand ausführen
& "$env:LOCALAPPDATA\tasks-desktop\bin\tasks-hub.exe" start
wscript.exe "$env:APPDATA\tasks-desktop\start-hub.vbs"
Get-Process tasks-hub
```

`stop` und `open --launch` gehen normal. Der Autostart nach der Anmeldung startet hier keinen Hub.

## docmap-desktop

Das NSIS-Setup (auch still über `install.ps1`) installiert nach `%LOCALAPPDATA%\docmap-desktop`.

```powershell
& "$env:LOCALAPPDATA\docmap-desktop\docmap-desktop.exe"   # App-Fenster öffnen
Get-Process docmap-desktop                                # läuft sie?
Stop-Process -Name docmap-desktop                         # beenden (normal: Fenster schließen)
```

## ai-desktop

Zwei Orte, je nach Weg der Installation:

- Setup des Release (auch über `install.ps1`): `%LOCALAPPDATA%\Programs\ai-desktop\app\ai-desktop.exe`
- `scripts\build-install.ps1`: Starter `%LOCALAPPDATA%\ai-desktop\ai-desktop.cmd`, der Ordner liegt auf dem
  Benutzer-PATH (in einem neuen Terminal reicht `ai-desktop`)

```powershell
& "$env:LOCALAPPDATA\Programs\ai-desktop\app\ai-desktop.exe"   # Server starten (Setup-Installation)
ai-desktop                                                     # Server starten (build-install-Installation)
Invoke-RestMethod http://127.0.0.1:8080/health                 # antwortet er?
Stop-Process -Name ai-desktop                                  # beenden
```
