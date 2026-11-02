# UC-09 CI: Pipeline lokal und die GitHub-Workflows

**Beispiel:** vier Workflows wurden für die neuen Techniken erweitert: Browser-Job (mdview.nvim), tmux (images.nvim),
Container-Image (filetree.nvim, lib.nvim). Dazu die lokale Pipeline `testing ci`.

## Ziel
Alles, was lokal läuft, läuft auf dem Runner gleich, und was dort nicht kann, ist ein **sichtbarer** Skip, kein Grün.

## Wann einsetzen
Sobald eine neue Prüftechnik ein Werkzeug braucht (tmux, Podman, chromium, Node) oder ein Repo eine eigene Pipeline.

## Wo
- Lokale Pipeline: `.testing.lua` → `ci = { profiles, steps, skip }`; sonst abgeleitet (`testing ci list`). Einstieg `scripts/ci.sh`, `scripts/test.sh ci`.
- Workflows: `mdview.nvim/.github/workflows/ci.yml` (Job `browser`, Commit `7b6a190`), `images.nvim/.github/workflows/ci.yml` (`fb1bbfe`),
  `filetree.nvim/.github/workflows/ci.yml` (`32208bf`), `lib.nvim/.github/workflows/ci.yml` (`220cca9`).
- Referenz: `testing.nvim/docs/CI.md`, `WORKFLOW-CI.md`, `RUNNER-GUARD.md`.

## Voraussetzungen
Lokal: wie [02](../02-workflow-alltag.md). Auf GitHub: Zweig `ci-verified` der Abhängigkeiten (testing.nvim, lib.nvim); Runner mit den Werkzeugen aus [04](../04-workflow-ci.md).

## Schritte
1. **Lokal beweisen**:
   ```bash
   scripts/test.sh ci --profile=fast && scripts/test.sh ci && testing ci verify
   ```
2. **Werkzeug in den Job holen** (Muster je Technik):
   - tmux: `- run: sudo apt-get update && sudo apt-get install -y tmux` mit `if: runner.os == 'Linux'`.
   - Podman-Image: `podman build -t localhost/testing-linux:1 <testing.nvim>/containers/linux` (`if: runner.os == 'Linux'`; testing.nvim vorher auschecken).
   - Browser: `npx playwright-core install --with-deps chromium` (die gepinnte Version), dazu Bundle und Relay bauen.
3. **Abhängigkeiten ausrichten**: der Spec findet seine Nachbarn selbst (`.deps/<name>`, Nachbarordner, `$<NAME>_DIR`); der Job legt sie dorthin.
4. **Skip vs. Rot im Job festlegen**: ein Skript, das in der CI alles gebaut hat, soll bei „Werkzeug fehlt“ **rot** enden (mdview: Exit 77 lässt den Job scheitern);
   eine Spec, die auch ohne das Werkzeug sinnvoll ist, meldet `n/a`.
5. **Artefakte**: Screenshots (`actions/upload-artifact`, `if: always()`), bei Fehlern `test-output-*`.
6. YAML prüfen (z. B. `python -c "import yaml; yaml.safe_load(open('ci.yml'))"`), dann pushen und den ersten Lauf **auf GitHub ansehen**.

## Ergebnis (Stand 2026-11-02)
Lokal alles grün. Die Workflows sind syntaktisch gültig, aber **auf GitHub noch nicht gelaufen**; der erste Lauf und der Tauri-Smoke in der CI stehen
in der Task `testing.nvim/browser-tauri-und-container-specs-in-ci-und-testing-einbinden`.

## Wenn es nicht läuft
- Der Job findet testing.nvim nicht: Zweig `ci-verified` und Pfad prüfen; `scripts/test.sh` beendet sich dann mit Exit 1, nicht grün.
- Specs bleiben `n/a`: Das Werkzeug wurde nicht installiert, oder der Pfad stimmt nicht (Image-Name `localhost/testing-linux:1`).
- Hosted Runner ≠ eigener Runner: Podman, tmux, Docker können dort anders vorhanden sein; `TESTING_CONTAINER_ENGINE=docker` nutzt `docker` (Probe `image inspect`).

## Nachmachen
Ein Beispiel-Job je Technik steht in den vier Workflow-Dateien. Mehrere Repos auf einmal: `testing ci --repos-root=$REPOS_DIR` (zuerst `verify`),
Flottenseite `testing ci overview --out ci.html`, GitHub-Stand `testing ci remote`.
