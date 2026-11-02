# UC-04 Bytestrom im echten Terminal (`testing.pty`)

**Beispiel:** images.nvim zeichnet ein Bild per OSC 1337; unter tmux steckt die Nutzlast in der Passthrough-Hülle.

## Ziel
Prüfen, was ein Programm **wirklich an das Terminal schreibt**, nicht nur, was es an `nvim_ui_send` übergibt.

## Wann einsetzen
Bilder (OSC 1337, kitty), Fenstertitel, Steuersequenzen, Alt-Tasten, tmux-Verhalten. Der Bildschirm (Raster) verwirft
solche Sequenzen; der **Rohstrom** behält sie.

## Wo
- Engine: `testing.nvim/lua/testing/pty.lua` (tmux in WSL per `wsl --exec`, ohne Shell; unter Linux direkt).
- Spec: `images.nvim/TESTS/pty_osc1337_spec.lua` (Eintrag in `TESTS/run.lua`), Schwester: `osc1337_sequence_spec.lua` (vergleicht den
  String vor dem Senden).
- Commits: testing.nvim `bd2fad5` (Engine), `1a77bfa` (binärer Lesezugriff), images.nvim `fa4334d`, `fb1bbfe` (tmux in der CI).
- Konfiguration: `deps` mit `testing.nvim`, `guard_allow.spawn` mit `wsl`, `tmux`.

## Voraussetzungen
Windows: WSL mit `tmux` und Neovim (`$TESTING_WSL_DISTRO` wählt die Distribution); Linux: tmux. `pty.available()` prüft.
Auf der Workstation nicht (nichts Unsigniertes starten).

## Schritte
1. Eine Session starten, die **ein Programm** ausführt; der Rekorder hängt vor dem ersten Byte dran:
   ```lua
   local pty = require("testing.pty")
   local s = pty.open({ "nvim", "--clean", "--cmd", "set rtp+=/mnt/e/repos/images.nvim,/mnt/e/repos/lib.nvim",
                        "-c", "lua require('images.terminal').draw('/mnt/c/.../probe.png', 3, 7, 10, 4)" },
                      { cols = 100, rows = 30 })
   ```
   Windows-Pfade für WSL umrechnen (`E:\x` → `/mnt/e/x`); die Spec hat dafür `host_path()`.
2. Warten, bis es im **Rohstrom** steht, dann lesen:
   ```lua
   s:wait_for("]1337;File=inline=1", 10000, "raw")
   local stream = s:raw()          -- alle Bytes, binär (CRLF bleibt)
   s:close()                       -- tmux-Session beenden, Aufzeichnung löschen
   ```
3. Prüfen: unter tmux **Passthrough-Hülle** `ESC P tmux ;` (innere Escapes verdoppelt), Parameter
   `size=<Bytes>;width=10;height=4;preserveAspectRatio=1:`, Base64 der Datei, Cursorposition `ESC[3;7H` **außerhalb** der Hülle, BEL am Ende.
4. Tasten: `s:send({ "M-n" })` (tmux-Namen) oder `s:send({ "text" }, true)`; Bildschirm: `s:screen()` (`capture-pane -p -e`).

## Ergebnis
`pty_osc1337_spec.lua`: 7 Zusicherungen, ein echter tmux-Lauf (images.nvim-Suite 48/48 grün). Ohne tmux: `n/a`.

## Wenn es nicht läuft
- `n/a  tmux is not available`: WSL/tmux einrichten (`wsl --exec tmux -V`).
- `denied … tmux kill-server`: **nie** `kill-server` (stört andere Arbeit); nur die eigene Session (`kill-session -t <name>`) — das tut `s:close()`.
- Backslashes/`\033` in Lua: `\033` ist dezimal 33; für ESC `string.char(27)` oder `"\27"`.
- Es kommt LF statt CRLF an: den Rohstrom binär lesen (`raw()` tut das seit `1a77bfa`).

## Nachmachen
`pty_spec.lua` in testing.nvim (`TESTS/testing/pty_spec.lua`) zeigt sowohl die Prüfung mit Fake-Runner (Argumentvektoren) als auch eine
echte Session mit einer Sequenz, die der Bildschirm verwirft.
