# Cheatsheet: Log-Lesekopie (`:Case log …`)

Die Lesekopie zeigt ein Fall-Log lesbar an, ein Eintrag je Zeile. Das Original bleibt unberührt: Die Lesekopie ist ein Scratch-Buffer (`filetype=caselog`), der nie gespeichert wird. Gesendet wird nichts, außer du rufst ausdrücklich `:Case ki logs` auf.
Ausführlich: `docs/FEATURES.md` (Abschnitt `:Case log view`), Optionen: `docs/configuration.md` (`log_view.*`), Katalogformat: `docs/log-patterns.md`.

## Öffnen

| Befehl | Was |
| --- | --- |
| `:Case log view` | aktuelle Log-Datei; sonst Auswahl über die Logs des Falls (`assets/`) mit Format und Konfidenz |
| `:Case log view <datei>` | eine bestimmte Datei |
| `:Case log view --tz=utc` | Zeitspalte gleich in UTC (`original` / `utc` / `relative`) |
| `:Case log merge [datei…]` | mehrere Logs nach UTC gemischt, das Log je Eintrag als Spalte; ohne Dateien: Auswahl, mehrere mit `<Tab>` |
| `:Case log formats [fall]` | welches Format jedes Log des Falls hat (Konfidenz, zweitbestes) |

## Lesen: eine Zeile

```
  64 ▸ 07:59:21.516  REQ    GET /source → page source · 214 nodes (177 ms)   +2,3 s
  │  │ │             │      │                                                  └ Abstand zum vorigen Eintrag
  │  │ │             │      └ Zusammenfassung (Request und Antwort in einer Zeile)
  │  │ │             └ Art / Level (rot = Fehler, gelb = Warnung)
  │  │ └ Zeit (tz: Original → UTC → relativ)
  │  └ ▸ aufklappbar · ▾ offen
  └ Original-Zeilennummer (zitierbar als Datei:Zeile)
⚑ in der Signspalte = bekannte Fehlermeldung aus dem Katalog
── 14 min without an entry ──   = Lücke
×38 (00:00:03 – 00:37:11)       = gefaltete Wiederholung
```

Die erste Zeile ist der Kopf: Datei, Format, Dateikopf (Release, Log level), Zeilen → Einträge, Anzahl bekannter Treffer.

## Tasten in der Lesekopie

`g?` zeigt sie alle. Umbelegen über `log_view.keys`.

**Auf- und zuklappen**
| Taste | Wirkung |
| --- | --- |
| `<CR>` / `za` | Eintrag oder Knoten auf/zu |
| `zo` / `zc` | auf / zu (auf einer Körperzeile: ihren Eintrag zu) |
| `zR` / `zM` | alle Einträge eine Ebene auf / alles zu |
| `gs` | Seitenquelltext: labelled → all → clickable |
| `gr` | Wiederholungen gefaltet ↔ jeder Eintrag |
| `tz` | Zeit: Original → UTC → relativ |

**Springen**
| Taste | Wirkung |
| --- | --- |
| `]e` / `[e` | nächster / voriger Fehler |
| `]w` / `[w` | Warnung |
| `]r` / `[r` | Request (bzw. seine Antwort) |
| `]k` / `[k` | bekannte Meldung aus dem Katalog (zeigt Titel, Erklärung, Links) |
| `]g` / `[g` | Lücke |
| `gO` | Original-Datei an dieser Zeile öffnen |
| `gp` | Eintrags-Picker (Vorschau: aufgeklappter Eintrag; `<M-o>` öffnet das Original) |
| `ge` | Fehler in die Quickfix-Liste (an den Original-Zeilen) |

**Filtern**
| Taste | Wirkung |
| --- | --- |
| `gf` | Filter dazu: Feld wählen (`level`, `source`, `dir`, `text`, `corr`), normal oder verneint, dann Text; `/muster/` = Lua-Muster (mit pickers.nvim; ohne: einfacher Textfilter) |
| `gF` | letzten Filter zurück |
| `g0` | alle Filter weg |

Die Statuszeile zeigt: Format, sichtbare/alle Einträge, aktive Filter, Zeitmodus.

**Vergleichen, markieren, nachsehen**
| Taste | Wirkung |
| --- | --- |
| `m` | Eintrag für den Vergleich markieren (höchstens zwei, auch über zwei Lesekopien) |
| `gd` | die zwei markierten vergleichen (z. B. Seitenquelltext vor / nach dem Klick) |
| `*` | Token unter dem Cursor als Spotlight, in allen Fenstern; nochmal `*` = weg |
| Hover (deine hover.nvim-Taste, `:Hover show`) | Eintrag dekodiert, gleiche Session, Katalogeintrag |
| `gm` | live im Browser (mdview.nvim): folgt Aufklappen, Filter, Zeitmodus; Klick im Browser springt hierher |
| `q` | Lesekopie schließen |
| Rechtsklick | Kontextmenü (ui.nvim) mit denselben Aktionen |

## Weitere Befehle

| Befehl | Was |
| --- | --- |
| `:Case log diff [a b] [--bounds]` | zwei Logs oder die zwei markierten Einträge vergleichen; IDs, Zeiten, Zahlen maskiert, `--bounds` auch Positionen |
| `:Case log export [--to=research\|tmp] [--open]` | Markdown wie gerade sichtbar → `Research/NN_LogView.md` (im Fall) oder Temp-Datei |
| `:Case log live` | wie `gm` |
| `:Case log catalog` | Katalog bekannter Fehlermeldungen öffnen (`WKDBook-Tricentis/Workflow/log-patterns.conf`) |
| `:Case log catalog seed [--min=N]` | Einträge aus den Fingerprints des Fallkorpus vorschlagen; erst Vorschau, dann Ja |
| `:Case ki logs --readable` | Logs als Lesekopie (eine Zeile je Eintrag) an die KI statt roh; mit `--preview` erst ansehen, nichts wird gesendet |

## Erkannte Formate

| Format | Beispiel-Datei |
| --- | --- |
| BrowserStack (Gerät + Session) | `*-logs-v2.txt.log`, `Browserstack_*.log` |
| Appium-Server (NDJSON) | `*_appium.log` |
| TBox: Commander, Agent, Mobile30Server, … | `ToscaCommander-*.log`, `Automation.Agent.Execution-*.log` |
| Serilog-Text (Server-Dienste) | `GatewayService_Log_*.txt`, `FileService/Log*.txt` |
| Serilog-JSON | `AuthenticationService_Log_*.txt`, `ShortenedLog.txt` |
| Workspace-/Commander-GUI-Log | `Log_YYYYMMDD_HHMMSS.txt` |
| Launcher, Flow-Agent | `log_*_YYYYMMDD.txt`, `logs.txt` |
| FlexNet-Lizenzserver | `flexnetls.*.log` |
| ToscaModuleLogs | `ToscaModuleLogs.txt` |
| LiveCompare | `__*…_YYYY-MM-DD.log` |
| ToscaSupportInfo (Bericht) | `ToscaSupportInfo.txt` |
| FailedJobDetails (Bericht) | `FailedJobDetails.txt` |

Unbekannt → Zeile für Zeile mit Hinweis. Eigene Formate: `log_view.formats` (Beispiele in `docs/configuration.md`).

## Optionen (Auswahl)

```lua
require("casedesk").setup({
  log_view = {
    split = "right",            -- wo die Lesekopie aufgeht
    pagesource_mode = "labelled",
    time_mode = "original",     -- "utc" | "relative"
    gap_minutes = 5,            -- 0 = keine Lückenzeilen
    delta_ms = 250,             -- Abstand am Zeilenende ab ...; negativ = nie
    collapse = true,            -- Wiederholungen falten
    own_frames = { "Tricentis." },
    keys = { original = "go" }, -- Tasten umbelegen; false = weglassen
  },
})
```

## Im Browser (casedesk-web, Workstation)

1. `git clone https://github.com/WKDSteve/casedesk-web.git`, dann `git pull` für neue Stände.
2. Prüfen: `(Get-FileHash casedesk.html).Hash.ToLower()` muss zur Zeile in `SHA256SUMS` passen.
3. In Chrome öffnen: `file:///C:/…/casedesk-web/casedesk.html`.
4. *Fallordner wählen …*, dann ein Log aus `assets/`; *Katalog → Katalog-Datei wählen …* (`log-patterns.conf`).
5. Menüleiste oben, Trefferliste rechts (Fehler, Warnungen, Exceptions, Lücken, Wiederholungen, Bekannt), dieselben Tasten wie in Neovim.

Im Browser gespeichert werden nur der Ordner-Zugriff und Ansichtseinstellungen, nie Log-Inhalte.
