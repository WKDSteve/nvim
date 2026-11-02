# UC-11 Ergebnisse lesen: Skip, Rot, Wächter, Teillauf

## Ziel
Aus der Ausgabe in einer Minute ablesen, **ob** etwas wirklich geprüft wurde und was zu tun ist.

## Die Ergebniszeile

```
GREEN | 221 pass | 0 from cache, 221 ran, 0 skipped on purpose | 211.7 s | exit 0
PARTIAL | 1 pass | 0 from cache, 1 ran, 220 skipped on purpose, 1 case(s) n/a here | 11.2 s | exit 0
RED | 1 timeout, 220 pass | …                                           exit 1
```

| Wort | Bedeutung | Beweist den ganzen Stand? |
| --- | --- | --- |
| `GREEN` | die ganze Suite lief grün | ja (Sentinel, Stempel) |
| `PARTIAL` | nur ein Teil lief (`--file`, `--filter`), `no sentinel` | **nein** |
| `RED` | Fehler, Timeout oder Wächter-Fund | nein |
| `n case(s) n/a here` | gemeldete Skips (`n/a  <Grund>`) | die Fälle liefen **nicht**; Grund lesen |
| `from cache` | Ergebnis aus dem Cache, Spec lief nicht neu | ja, solange der Schlüssel stimmt (`testing explain`) |

## Der Fehlerzweig in der Reihenfolge

1. **Exit 2**: Aufruf oder Vertrauen. `testing trust check`, `$TESTING_TRUST_ROOTS`.
2. **Exit 3**: Umgebung (Werkzeug/Abhängigkeit fehlt) **bevor** etwas lief.
3. **`GUARD … [fs]`** (Datei außerhalb erlaubter Wurzeln): `guards.fs.allow = { "<pfad>" }` oder das Schreibziel in den Temp-Ordner verlegen.
4. **`GUARD … [process_net]`** (Prozess/Netz): Programmname in `guard_allow.spawn` oder `@spawn`-Tag am Fall.
5. **`GUARD … [state]`** (Leck: Autocmds, Highlights, Globals, Puffer): im Spec zurücksetzen (`H.snapshot`/`H.restore`) oder in `guards.state` einordnen.
6. **Timeout** in der Vollsuite: Spec-Namen aus dem Bericht/IR notieren, Spec einzeln laufen lassen; bleibt es grün, ist es Lastempfindlichkeit
   (Task `guard-core-spec-wrapper-overhead-messung-s-scheitert-unter-l`). Nie einfach das Limit erhöhen.
7. **Rot im Blatt**: die erste Zeile nennt `<Größe> step <n>, <Notiz> (<Aktion>)`; Details (z. B. Snapshot-Diff) stehen darunter.

## Skips sind Bestandteil der Aussage

| Skip-Grund | Quelle | Beheben |
| --- | --- | --- |
| `tmux is not available` | `testing.pty` | WSL + tmux |
| `image localhost/testing-linux:1 is not built` | `testing.container` | `podman build …` |
| `podman is not usable (is its machine running?)` | `testing.container` | `podman machine start` |
| `playwright-core is not installed …` | Blatt `browser` | `npm install` / `$TESTING_PLAYWRIGHT_DIR` |
| `chromium cannot be started …` | Blatt `browser` | `npx playwright install chromium` |
| Exit 77 `SKIP: …` | Playwright-/Tauri-Skripte | Werkzeug einrichten (`:checkhealth testing`) |

Auf einem Runner, der alles können soll, ist ein `n/a` ein **Befund**, kein Normalzustand (offene Task: Warnung im Bericht).

## Der Rot-Beweis (jedes Mal bei einem Fix)

```bash
git stash push -- <datei-mit-dem-fix>
scripts/test.sh --file <spec>        # muss RED sein
git stash pop
scripts/test.sh --file <spec>        # wieder GREEN
```

Beispiele dieses Verlaufs: pty `raw()` (testing.nvim `1a77bfa`), übersprungenes Blatt (`f4e683c`), `trash_wsl` ohne `wslpath` (filetree.nvim `be021d8`),
Keyword-Karte (docmap.nvim `5efcf63`: das Blatt ist rot ohne den Fix).

## Häufige Stolpersteine bei Neuem

- Spec in einem Repo mit eigener Liste vergessen einzutragen (`TESTS/run.lua`) → Hinweis „on disk but not in TESTS/run.lua (run last)“.
- Große Skripte durch Shell-Heredocs schicken (Escapes, `\033`, Anführungszeichen) → Datei mit dem Editor/`Write` schreiben (`tasks-vault/HEREDOC.md`).
- Git Bash und Windows-Pfade bei Podman: `MSYS_NO_PATHCONV=1`.
- Geteilte Checkouts: nur eigene Dateien per Pfad stagen, fremde Änderungen (`docs/map/…`) nie anfassen.
