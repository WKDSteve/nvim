# UC-05 Linux im Container (`testing.container`)

**Beispiele:** (a) filetree.nvim schickt Datei, Ordner und Batch in den freedesktop-Papierkorb (`gio trash`, dann `trash-put`);
(b) lib.nvim `open_default` übergibt `xdg-open` genau **ein** unverändertes Argument; (c) ein Linux **ohne** `wslpath` auf
WSL2-Kernel ist kein WSL.

## Ziel
Linux-Verhalten prüfen, obwohl ich unter Windows entwickle und ohne die Workstation anzufassen.

## Wann einsetzen
Echte Linux-Werkzeuge (Papierkorb, `xdg-open`, `tmux`, Dateisystem-Eigenheiten), Pfade, `XDG_*`-Variablen, Pakete.

## Wo
- Engine: `testing.nvim/lua/testing/container.lua`; Image: `testing.nvim/containers/linux/Containerfile` (Alpine 3.22: Neovim, `gio`, `trash-cli`,
  `xdg-utils`, `tmux`, DejaVu; Benutzer `tester`; Netz aus, Mounts nur lesend).
- Specs: `filetree.nvim/TESTS/trash_linux_container_spec.lua` + `TESTS/container/trash_linux.lua`, `trash_wsl_no_wslpath.lua`;
  `lib.nvim/TESTS/cross_open_default_container_spec.lua` + `TESTS/container/open_default_linux.lua`.
- Commits: testing.nvim `20c9f84`, `1a77bfa` (docker-Probe); filetree.nvim `baf8f6d`, `be021d8`, `011d751`, `32208bf`; lib.nvim `8a544ed`, `e2c65c8`, `220cca9`.

## Voraussetzungen
Podman (Windows: `podman machine start`) und das Image `localhost/testing-linux:1`:
```bash
podman build -t localhost/testing-linux:1 testing.nvim/containers/linux
```
`container.available()` meldet `n/a`-Gründe: Engine fehlt, Maschine gestoppt, Image nicht gebaut.

## Schritte
1. **Zweigeteilt**: die Host-Spec startet den Container; das Skript **im Container** (`nvim --headless -l …`) macht die Arbeit
   und druckt am Ende ein Merkwort (`TRASH_OK gio`, `OPEN_OK`).
   ```lua
   local res = container.run(
     { "nvim", "--headless", "--clean", "-u", "NONE", "-l", "/repos/filetree.nvim/TESTS/container/trash_linux.lua", "/repos" },
     { mounts = { [root] = "/repos/filetree.nvim", [lib_dir] = "/repos/lib.nvim" } })   -- Host-Pfad → Container-Pfad
   H.ok(res.code == 0 and (res.stdout .. res.stderr):find("TRASH_OK gio", 1, true))
   ```
   Die Abhängigkeiten werden **gesucht** (Nachbar, `.deps/`, `$LIB_NVIM_DIR`) und einzeln gemountet, damit die Spec in jeder Checkout-Anordnung (auch CI) läuft.
2. **Zweiter Backend-Pfad** erzwingen: PATH auf ein Verzeichnis ohne `gio` kürzen (`sh -c "mkdir … ln -s /usr/bin/trash-put … PATH=… nvim …"`),
   dann muss `trash-cli` das Backend sein.
3. **Aufruf abfangen** (`xdg-open`): ein Stub `xdg-open` vor dem PATH schreibt seine Argumente in eine Datei; `open_default(target, {on_exit=…})` wartet,
   dann wird die Datei gelesen und mit dem Ziel verglichen (URL mit `?`, `&`, `%3F`; Pfad mit Leerzeichen und `&`). Ohne `xdg-open`:
   `false, "xdg-open not found"`.
4. **Ohne `wslpath` auf WSL2-Kernel**: der Container teilt den Kernel der Podman-Maschine („microsoft“). Das Skript erzwingt `is_wsl()` auf `true`
   und prüft, dass `trash` ein `ok=false` mit „wslpath“ meldet statt zu werfen; die anderen Skripte prüfen, dass die **echte** Erkennung hier `false` ist.

## Ergebnis
Papierkorb-Spec: 6 Prüfungen grün (gio, trash-cli, wslpath-Fehler); `xdg-open`-Spec grün; lib.nvim-Vollsuite grün. Die Specs fanden zwei
echte Fehler: `trash_wsl` warf ENOENT (be021d8) und `is_wsl()` hielt Container für WSL (e2c65c8).

## Wenn es nicht läuft
- `n/a  image … is not built` → `podman build …` (siehe oben).
- Podman-Maschine startet nicht (`ext4.vhdx` fehlt) → `podman machine rm -f podman-machine-default && podman machine init && podman machine start`.
- Git Bash biegt `/repos/…` zu `C:/Program Files/Git/repos/…` → `MSYS_NO_PATHCONV=1` setzen (nur beim Handaufruf; aus Lua kein Problem).
- `GUARD … process_net … podman` → `"podman"` in `guard_allow.spawn` (und `allow_exec` bei testing.nvim selbst).

## Nachmachen
Neues Container-Skript unter `TESTS/container/`, Host-Spec nach dem Muster, Image-Build in den CI-Workflow ([UC-09](UC-09-ci-pipeline-und-workflow.md)).
