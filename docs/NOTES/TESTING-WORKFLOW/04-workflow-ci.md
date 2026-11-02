# 04 Workflow CI: eine Definition, überall dieselbe Pipeline

Eine Definition von „dieses Repo ist in Ordnung“, benutzt im Terminal, vor dem Push, im Editor und auf dem Runner.
Referenz: `testing.nvim/docs/CI.md`, `docs/WORKFLOW-CI.md`.

## Die Bausteine

- **Pipeline**: der Abschnitt `ci` in `.testing.lua`. Ohne ihn wird sie abgeleitet: `stylua` (wenn `stylua.toml`),
  `luacheck` (wenn `.luacheckrc`), die Suite, `conformance` (wenn Gate). `testing ci list` zeigt, was abgeleitet wurde.
- **Eine Engine**: `testing ci`. **Ein Einstieg je Repo**: `scripts/ci.sh` bzw. `scripts/test.sh ci`.
- **Beweis**: ein grüner Lauf schreibt `ci-<profil>.json` und den Stempel der Suite; `testing ci verify` sagt in einer
  Zehntelsekunde, ob der Stand schon bewiesen ist.

```bash
scripts/test.sh ci                    # Profil full
scripts/test.sh ci --profile=fast     # stylua + luacheck
scripts/test.sh ci --keep-going       # alle Schritte, alle roten auf einmal
scripts/test.sh ci --step=luacheck    # ein Schritt (Teillauf, nur für ihn grün)
testing ci verify                     # schon bewiesen?
testing ci list                       # welche Schritte, woher
testing ci hook install               # Pre-Push-Hook
testing ci remote <root>              # letzter GitHub-Lauf je System (fragt GitHub)
testing ci overview --repos-root=$REPOS_DIR --out=ci.html   # Flottenseite
```

Fehlt ein Werkzeug oder eine Abhängigkeit: Exit `3` **vor** dem ersten Schritt, nie ein stilles Grün.

## Die GitHub-Workflows (`.github/workflows/ci.yml`)

Alle Plugin-Repos haben denselben Aufbau: `lint` (stylua, luacheck), `test` als Matrix `ubuntu`, `windows`, `macos`
(`fail-fast: false`: welches System bricht, ist die Information), Abhängigkeiten als Checkout des Zweigs
`ci-verified` (der sich erst bewegt, wenn die CI der Abhängigkeit grün ist), Fehler-Artefakte `test-output-*`.
Die Abhängigkeiten liegen als `.deps/<name>` oder als Nachbarordner; `scripts/test.sh` sucht in dieser Reihenfolge
`$<NAME>_DIR`, `.deps/<name>`, `../<name>`, `lazy/<name>`.

### Was für die neuen Techniken dazukam (Stand 2026-11-02, **auf GitHub noch ungelaufen**)

| Repo | Änderung im Workflow | Wirkung |
| --- | --- | --- |
| mdview.nvim | Job `browser`: Go/Node/Rust-wasm, `npm run build`, `build:go`, `npx playwright-core install --with-deps chromium`, `npm run test:browser`, Screenshots als Artefakt | echter Browser-Test des Cursor-Bands; Exit 77 lässt den Job rot werden |
| images.nvim | `apt-get install tmux` auf Linux | die PTY-Spec liest Bytes aus einem echten Terminal |
| filetree.nvim | Linux: `podman build -t localhost/testing-linux:1 testing.nvim/containers/linux` | Papierkorb-Spec läuft im Container |
| lib.nvim | Linux: testing.nvim nach `.deps/` und derselbe Image-Build | `xdg-open`-Spec läuft im Container |

Ohne Image, tmux oder Playwright melden sich die Specs mit `n/a` (kein Grün, keine Rotmeldung). Die Container-Specs
mounten ihre Abhängigkeiten selbst (Projekt und `lib.nvim`), egal wo die Checkouts liegen.

## Self-hosted Runner

Die CI bleibt auf dem eigenen Runner; er ist ein privater Rechner (`STEVESPC`), **nie die Workstation**. Foreign Code
fernhalten: `testing ci runner-guard check|install|remove|status` (Hook beim Jobstart: keine Pull-Requests, keine
fremden Akteure, keine ungeprüften Commits öffentlicher Repos) und `testing ci trust <owner/repo> <sha>` (Liste der
freigegebenen Commits). Keine PR-Trigger auf dem self-hosted Runner, Fork-PRs nur nach Freigabe.

Was der Runner können muss: Neovim, Node, `playwright-core` + chromium (Browser), WSL/Linux mit tmux (PTY), Podman mit
dem Image (Container), für den Tauri-Smoke Windows mit WebView2 und passendem `msedgedriver`. `:checkhealth testing`
listet, was fehlt (bewusst fehlend ist ein Hinweis, kein Fehler).

## Das Container-Image

`testing.nvim/containers/linux/Containerfile`: Alpine 3.22 (die Version legt alle Pakete fest) mit Neovim,
`gio` (Paket `glib`), `trash-cli`, `xdg-utils`, `tmux`, `fontconfig`, DejaVu-Schriften; Benutzer `tester`.

```bash
podman build -t localhost/testing-linux:1 testing.nvim/containers/linux
MSYS_NO_PATHCONV=1 podman run --rm --network none -v 'E:\repos:/repos:ro' localhost/testing-linux:1 \
  nvim --headless --clean -u NONE -l /repos/lib.nvim/TESTS/container/open_default_linux.lua /repos
```

(`MSYS_NO_PATHCONV=1` in Git Bash, sonst verbiegt es `/repos/...`.) Podman unter Windows: `podman machine start`; ist
die Maschine kaputt (`ext4.vhdx` fehlt), `podman machine rm -f podman-machine-default`, `podman machine init`,
`podman machine start` (lädt ein Maschinen-Image).

## Typische Fehlerbilder

| Bild | Ursache | Was tun |
| --- | --- | --- |
| Exit 2 bei lokalen Läufen | Projekt nicht vertraut | `$TESTING_TRUST_ROOTS` setzen oder `testing trust add` |
| `GUARD … [process_net] started a process: node …` | Programm nicht in `guard_allow.spawn` | eintragen |
| `GUARD … [fs] writes outside the allowed roots` | Schreibziel nicht erlaubt | `guards.fs.allow = { "TESTS/sheets/out" }` |
| `PARTIAL … no sentinel` | `--file` benutzt | für den Beweis die ganze Suite laufen lassen |
| Spec `n/a` | Werkzeug fehlt | Grund lesen; im Runner einrichten |
| einzelner Timeout in der Vollsuite unter Last | bekannte Lastempfindlichkeit | Wiederholung; Spec-Namen aus dem Bericht in die Task `guard-core-spec-wrapper-overhead-…` notieren |
