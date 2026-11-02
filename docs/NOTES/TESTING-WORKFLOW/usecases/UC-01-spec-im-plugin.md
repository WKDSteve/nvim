# UC-01 Spec in der Suite, Fix mit Rot-Beweis

**Beispiel:** `lib.nvim` `cross.platform.is_wsl()` hielt jedes Linux auf einem WSL2-Kernel für WSL (auch einen
Container ohne `wslpath`).

## Ziel
Eine Logikänderung mit einem Test absichern, der **ohne den Fix rot** wird.

## Wann einsetzen
Reine Logik, Erkennungen, Befehle, Tabellen; alles, was ohne Bildschirm prüfbar ist und sich durch Einspeisen
von Eingaben (Kernel-Name, Umgebung, Dateien) testen lässt.

## Wo
- Code: `lib.nvim/lua/lib/nvim/cross/platform/is_wsl.lua` (Kernel-Treffer zählt nur mit `wslpath`; die Variablen
  `WSL_DISTRO_NAME`/`WSL_INTEROP` zählen allein).
- Spec: `lib.nvim/TESTS/cross_is_wsl_spec.lua`, eingetragen in `TESTS/run.lua`.
- Commit: lib.nvim `e2c65c8`. Auslöser: filetree.nvim `be021d8` (Papierkorb warf ENOENT ohne `wslpath`).

## Voraussetzungen
Neovim, das Repo. lib.nvim hat einen **eigenen** Runner (`nvim --headless -u NONE -l TESTS/run.lua`, Meldung
`LIB_TESTS_OK`), bewusst nicht testing.nvim (Entscheidung 2026-10-06, siehe `lib.nvim/TESTS/README.md`).

## Schritte
1. Den Fehler in einer Spec festnageln. Die Eingaben werden **eingespeist**, nicht auf dem Rechner gesucht:

   ```lua
   -- Ausschnitt TESTS/cross_is_wsl_spec.lua
   local function detect(release, wslpath, env)
     uv.os_uname = function() return { release = release } end           -- Kernel-Name
     uv.fs_stat = function(path)                                          -- gibt es wslpath?
       if path:find("wslpath", 1, true) then return wslpath and {} or nil end
       return real_stat(path)
     end
     for _, k in ipairs(env_keys) do vim.env[k] = env and env[k] or nil end
     package.loaded["lib.nvim.cross.platform.is_wsl"] = nil               -- Cache der Funktion verwerfen
     return require("lib.nvim.cross.platform.is_wsl")()
   end
   H.eq(detect("5.15.153.1-microsoft-standard-WSL2", false), false, "WSL kernel without wslpath is not WSL")
   ```
   Am Ende **alles zurücksetzen** (`uv.os_uname`, `uv.fs_stat`, `vim.env`, `package.loaded`), auch wenn die Zusicherung wirft
   (`pcall` + Wiederherstellung + `error`), weil lib.nvim alle Specs in **einem** Neovim laufen lässt.
2. Rot sehen (vor dem Fix), Fix machen, grün sehen.
3. **Rot-Beweis**: den Fix zurücknehmen und prüfen, dass die Spec rot wird:
   ```bash
   git stash push -- lua/lib/nvim/cross/platform/is_wsl.lua
   nvim --headless -u NONE -l TESTS/run.lua      # muss rot sein
   git stash pop
   ```
4. Ganze Suite grün, dann `stylua`, committen, pushen.

## Ergebnis
`LIB_TESTS_OK`; im Fix-Commit `e2c65c8` liegen Code und Spec zusammen. Zusätzlich lief die **echte WSL** (Arch): dort
bleibt `is_wsl()` `true` (`wsl --exec nvim --headless … is_wsl()` → `true`).

## Wenn es nicht läuft
- Eine Spec lässt etwas global verändert zurück → die nachfolgenden Specs scheitern (kaskadierende Fehler): immer
  zurücksetzen, `H.with_patched` nutzen, wo vorhanden.
- Repos mit testing.nvim: `scripts/test.sh --file <name>`; Skip-Regel: `print("n/a  …")` + `return`.

## Nachmachen
Beliebiges `*_spec.lua` kopieren, `H.eq`/`H.ok` nutzen, in `TESTS/run.lua` eintragen. Vorlage für ein ganzes neues Repo:
`testing init <root>`.
