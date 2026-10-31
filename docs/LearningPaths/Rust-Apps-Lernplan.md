# Lernplan: Native Apps in Rust (appkit, tasks-desktop, rules-desktop, docmap-desktop)

Stand: 2026-10-31. Ziel: den gesamten Stack der eigenen `*-desktop`-/`*-web`-Apps **selbst** beherrschen,
nicht nur bedienen: Rust (Idiome, Syntax, Besonderheiten), lokaler HTTP-Server, Tauri, Svelte-5-UI,
Tests und DevOps (CI, Release, Lieferkette). Er ergänzt den [Lernplan](Lernplan.md) (Phase 5 nennt Rust)
und die [Kompetenzmatrix](Kompetenzmatrix.md) (Rust steht dort bei 1/2/2/3); er ersetzt sie nicht.

Annahme: 8–10 Stunden pro Woche, davon ca. 5 h Rust-Spur. Dauer: etwa 26 Wochen. Es gelten dieselben
Grundregeln wie im Lernplan: ein Buch pro Thema, jedes Kapitel endet mit selbst geschriebenem Code
(ohne KI, danach Review erlaubt), Feynman-Notiz pro Kapitel.

---

## 1. Bestandsaufnahme: was es gibt

Alle Pfade unter `$REPOS_DIR`. Zeilenzahlen sind Rust-Zeilen ohne `target/`.

| Repo | Art | Inhalt | Rust-LOC |
|---|---|---|---|
| `appkit` | Rust-Workspace (4 Crates) + `ui-kit` + `web-kit` + `release-kit` | **Geteilter Unterbau** aller Apps: Wächter (Guard), Pairing, Sessions, Engine-Naht, Store, Watcher, Suche, Installation, Sicherheitsmatrix (`appkit-testkit`) | ca. 11,6 k |
| `tasks-desktop` | Rust-Workspace (`tasks-hub`, `hub-testkit`) + Svelte-UI | Hub zu `tasks.nvim` (Lua-Engine im Kindprozess), axum auf Loopback | ca. 14,6 k |
| `rules-desktop` | Rust-Workspace (`rules-hub`) + Svelte-UI | Dasselbe Muster für `rules.nvim` (kleinster Fall, gut zum Einstieg) | ca. 9,5 k |
| `docmap-desktop` | **Tauri 2** (`src-tauri`) + Vanilla-JS-Frontend | Viewer für `docmap.nvim`, Engine als Sidecar-Binary | ca. 15,2 k (davon `main.rs` 5,8 k) |
| `tasks-web` | eine HTML-Datei (+ `SHA256SUMS`) | Webvariante von tasks: Engine in `wasmoon` (Lua 5.4 in WASM), kein Server, kein Request | – |
| `testing-web` | nur README + CLAUDE.md | Platzhalter | – |
| `ai-desktop` | **C++17**, CMake | lokaler Server (`cpp-httplib`, `nlohmann/json`, OpenSSL), Modell-Router (Ollama/OpenAI/Anthropic/Gemini), Windows-Credential-Manager | – (28 Dateien C++) |
| `Literatur-Web` | Büchersammlung | keine App | – |

Die Regelwerke dazu liegen in `$RULES_VAULT/rulesets/native` (Datei `regeln/APPS_RUST_WEB.md`, 2851 Zeilen,
Kategorien `RS-`, `SRV-`, `ENG-`, `WEB-`, `TAU-`, `WIN-`, `NREL-`, `TST-`, `APP-`) mit den Gates
`gates/NEW_PROJECT.md` und `gates/REVIEW.md`. **Diese Regeln sind der Prüfstein dieses Plans:** zu jedem
Block unten gehört, die genannten Regeln zu lesen und im echten Code die Stelle zu finden, die sie erfüllt.

---

## 2. Architektur, wie sie tatsächlich gebaut ist

### 2.1 Schichten

```
Browser-Tab / Tauri-Fenster          Svelte 5 (tasks, rules)  |  Vanilla JS (docmap)
        │  HTTP + SSE, nur Loopback
        ▼
  <app>-hub  (axum 0.8, tokio)       Routen, Datenklassen, Store, Watcher        ← App-eigen
        │  appkit-hub                Guard, Pairing, Sessions, Accept-Schleife   ← geteilt
        │  appkit-core               Secrets, Host/Origin-Regeln, proc, Registry ← geteilt, ohne HTTP
        ▼
  Engine = Lua-Plugin in nvim -l     (Kindprozess, leere Umgebung, Zeitlimit)
        ▲
  Vertrag  tasks-export/1, tasks-ops/1  (JSON-Schema, .d.ts, engine.lock)
```

Merksatz aus dem Code: **Hub und Oberfläche rechnen keine Regeln der Domäne, das tut die Engine** (WEB-13).
Rust ist Tür, Wächter und Zwischenspeicher, nicht Fachlogik.

### 2.2 Muster, die du erklären können musst

1. **Workspace + geteilter Kit per Git-Tag.** `[workspace.dependencies]` mit `git = ".../appkit", tag = "v0.26.0"`;
   `Cargo.lock` pinnt den Commit, `tools/check-appkit-pin.py` prüft, dass Tag, Lock, `ui/package.json`, `pnpm-lock.yaml`
   und die `uses:`-Zeilen der Workflows denselben Commit meinen. Gleichzeitig arbeiten über `[patch]` in einer
   **nicht eingecheckten** `.cargo/config.toml` (Falle: schreibt `Cargo.lock` um, siehe `tasks-desktop/CLAUDE.md`).
2. **Engine-Naht.** `trait Engine { fn call<'a>(&'a self, Method, Option<&'a Value>) -> CallFuture<'a>; }`
   (`appkit-hub/src/engine/mod.rs`). `CliEngine` startet pro Aufruf `nvim`; später kann ein `Host` (persistenter
   Prozess) dasselbe Trait erfüllen. Tests nehmen `fake-nvim` oder `fake_engine`. `Method` ist eine
   **geschlossene Liste** (`static SPECS: [MethodSpec; 18]` + `const Calls::Hello: Method = Method::new(&SPECS[0])`),
   nie ein String von außen (ENG-Regeln).
3. **Guard als Vertrag.** Eine Middleware, feste Reihenfolge (Host → Body-Limit → Origin/Sec-Fetch-Site → Methode →
   Programm-Client braucht Bearer → Rate-Limit → Credential → Content-Type), Default geschlossen; jede Stufe hat einen
   Test in `hub-testkit/tests/security.rs` bzw. `appkit-testkit/src/security.rs` (SRV-02…SRV-22).
4. **Generik statt Vererbung.** `Core<R: Runtime>` und `trait Runtime: Send + Sync + 'static`: `appkit-hub` kennt die
   App nicht, die App liefert Routen, `Runtime` und `GuardRules`. Zweite App (`rules-desktop`) beweist die Naht.
5. **Pairing statt Passwort.** Einmal-Code → Session-Token; `Secret` ohne `PartialEq`, redigiertes `Debug`,
   Vergleich nur über `ct_eq` (konstante Zeit); `Clock`-Trait + `ManualClock` für Ablauf ohne Warten.
6. **Datenklassen fail-closed** (`classes.rs`, SRV-21, `areas.json`): ohne Klasse wird nichts ausgeliefert/exportiert.
7. **UI eingebettet.** `build.rs` erzeugt `ui_embedded.rs` mit `include_bytes!`, Tabelle im Speicher, kein Dateipfad zur
   Laufzeit (SRV-20); `touch crates/tasks-hub/src/ui.rs`, sonst bleibt die alte UI im Binary.
8. **Kindprozess-Disziplin** (`appkit-core/src/proc.rs`): `env_clear`, Programm+Argumente ohne Shell, Watchdog, Limits
   für stdout/stderr, Kill statt Warten (RS-04, RS-06).
9. **Eine Stelle für `unsafe`.** Workspace `unsafe_code = "forbid"` (Apps) bzw. `"deny"` (appkit); genau ein Modul
   `handles.rs` erlaubt es (`SetHandleInformation`, Windows) mit `// SAFETY:`-Kommentar.
10. **Vertrag zur Engine mit Pin:** `engine.lock` (Commit auf `origin/main`), `contract.d.ts` wird kopiert,
    CI vergleicht per `cmp`.
11. **Zwei Varianten derselben Oberfläche:** Hub-Variante (Rust-Server) und Web-Variante (`vite build --mode web`,
    eine HTML-Datei, Engine in wasmoon, Daten in IndexedDB, `appkit-web`); beide gegen dieselbe Fixture getestet.
12. **Discovery-Datei** (`registry.rs`): laufende Instanz meldet Port/Instanz-ID ohne Geheimnis, atomar geschrieben (RS-02, SRV-15).
13. **Plattformpflege:** Autostart (Run-Key / Autostart-Eintrag / Launch-Agent), Shell-Link, Login-Items
    (`loginitems.rs`, `shell_link.rs`), `NVIM_MACHINE_ROLE` (Workstation: nichts Unsigniertes bauen/starten).
14. **Tauri-Gegenentwurf (docmap):** Commands im selben Prozess statt HTTP-Hub; Rechte stehen in
    `capabilities/default.json`; Engine als Sidecar (`tauri-plugin-shell`, `binaries/docmap`); `protocol-asset` mit
    `assetProtocol.scope`; `csp: null` und ein 5,8-k-Zeilen-`main.rs` sind die offenen Lücken (siehe Übung 8.4).

---

## 3. Rust: die verwendeten Idiome (mit Fundort)

Gezählt über alle vier Rust-Repos (grob): ~520 `async fn`, ~600 `#[test]` + ~250 `#[tokio::test]`, ~3000 `assert*`,
~560 `?`, ~290 `let … else`, ~230 `Arc<`, ~140 `dyn Trait`, 164 `#[must_use]`, 118 `serde(`-Attribute, 15 `unsafe`.
**Bewusst nicht benutzt:** `thiserror`, `anyhow`, `clap`, `tracing`, `proptest`, `async_trait`, `let`-Ketten
(`if let … &&`), `#[non_exhaustive]`. Warum, ist selbst Lernstoff (kleine Dependency-Fläche, `cargo deny`, Lieferkette).

### 3.1 Fehlerbehandlung (RS-05)

- **Geschlossene Fehler-Enums von Hand**: `enum EngineError { Refused, BadRequest, Busy, Timeout, Spawn, … }` mit
  `impl fmt::Display` (ein `match self`, `write!`/`f.write_str`) und `impl std::error::Error {}` (`proc.rs`,
  `engine/mod.rs`). Jede Variante hat einen eigenen HTTP-Status.
- **Semantische Umdeutung**: `EngineError::for_write(self)` macht aus `Timeout|Process|Failed|Protocol` ein
  `OutcomeUnknown` — „nach dem Start eines Schreibvorgangs ist der Ausgang offen“. Fehlertyp trägt Domänenwissen.
- **`Result<T, String>` in Binaries** (`main.rs`: `async fn run(...) -> Result<(), String>`), `Result<_, ProbeProblem>` in Libs.
- Operatoren: `?`, `.ok_or_else(|| format!(...))`, `.map_err`, `unwrap_or(u64::MAX)` nach `u64::try_from(...)`
  (kein `as`-Cast bei Zeiten), `let Some(x) = … else { return … }`, `matches!`.
- Panics nur in Tests und bei Programmierfehlern (`expect("a scratch folder lives until it is dropped")`).

### 3.2 Typen und Traits

- **Newtypes und Marker-Typen**: `Secret`, `Method(&'static MethodSpec)`, `Scratch { dir: Option<TempDir> }` mit
  `impl Deref<Target = Path>`.
- **Const-Tabellen statt Strings**: `const DIALECT: EngineDialect = EngineDialect { … }`, `static SPECS: [MethodSpec; N]`,
  `const fn` (`MethodSpec::bare/read/write/aside`), `#[allow(non_upper_case_globals)] impl Calls { pub const Hello … }`.
- **Trait-Objekte** `Arc<dyn Engine>`, `Arc<dyn Clock>`, `&dyn Engine`; **Generik mit Bounds** `Core<R: Runtime>`,
  `where R: AsyncRead + Unpin`.
- **Objektsichere async-Traits ohne Makro**: `type CallFuture<'a> = Pin<Box<dyn Future<Output = …> + Send + 'a>>`
  und `BoxFuture<'a, T>`; Methode nimmt `&'a self` und gibt `Box::pin(async move { … })` zurück.
- **Lifetimes in Signaturen**: `fn call<'a>(&'a self, method: Method, params: Option<&'a Value>) -> CallFuture<'a>`,
  `impl<'de> Deserialize<'de> for Top`, `DeserializeSeed<'de> for LiteSeed<'_>`, `EngineVars<'a>`.
- **Builder-/Config-Structs** mit allen Feldern (`CliEngineConfig`, `ServerConfig`) und `..Default::default()`
  bzw. `Limits { snapshot_max_age: None, ..limits }` (struct update syntax).
- **Default/Display/Debug von Hand**, wo Redaktion nötig ist (`Secret`).
- **`#[must_use]`** an Konstruktoren und reinen Funktionen (Clippy-Gate `all = deny`).
- **Newtype-Drop als RAII**: `impl Drop for RunningServer`, `Drop for Place`, `Scratch` (aufräumen auch bei Panic).

### 3.3 Async und Nebenläufigkeit (tokio, bewusst klein: `default-features = false`)

- Features einzeln gewählt: `sync, rt, rt-multi-thread, net, time, macros, io-util, process, signal`.
- **Kanäle**: `watch::channel(false)` als Stop-Signal, `mpsc::Unbounded*` (Watcher → Store), `oneshot` (Antwort der
  Queue), `Semaphore` (max. Verbindungen, `hub.rs`), `AtomicBool/AtomicU64` mit `SeqCst`.
- **`tokio::select!`** in der Accept-Schleife (SRV-08: überlebt Fehler) und im Store.
- **Zeitlimits** überall: `tokio::time::timeout`, `timeout_at(deadline, …)`.
- **`spawn_blocking`** für Blockierendes (Ordnerdialog, Fingerprint von Verzeichnissen).
- **`Mutex`/`RwLock` aus `std`** (nicht tokio) mit kurzen kritischen Abschnitten; `MutexGuard` nie über `.await`.
- **Stack-Falle**: große Futures werden in eigene `async fn run(args)` ausgelagert, damit sie auf dem Heap leben
  (Windows-Hauptthread 1 MB, siehe Kommentar in `main.rs`).
- **hyper/axum direkt**: `hyper::server::conn::http1`, `TowerToHyperService`, `TokioIo` — eigene Accept-Schleife statt `axum::serve`,
  damit Verbindungslimit, Timer und Zustand kontrollierbar sind.
- **axum**: `Router`, `State<Arc<Core<R>>>`, `middleware::from_fn_with_state`, Extractors (`RawQuery`, `Request`),
  `IntoResponse`, `DefaultBodyLimit`.

### 3.4 Daten, Serde, Strings, Dateien

- `#[derive(Debug, Clone, Serialize, Deserialize)]`, `#[serde(default)]` (43×), `rename_all` (39×), `deny_unknown_fields` (15×),
  `skip_serializing_if`, `rename`, `flatten`;
  `serde_json::{Value, json!, RawValue}`, **handgeschriebenes `Deserialize` mit Seed** für Streaming (`store.rs`).
- Strikt parsen: Header einmalig (`single`), Query nur Gelistetes (SRV-17), Dateien erst Größe prüfen dann lesen
  (`safe_read`, RS-03), Konfig atomar schreiben (Temp-Datei + Rename, RS-02).
- `format!("{x:?}")`, Inline-Format-Args, `&str` vs `String` (`to_owned`), `OsString`/`PathBuf` statt `String` für Pfade,
  `strip_prefix`, `split_first`, **Slice-Patterns** (`match args { [flag, value] if flag == "--port" => … }`).
- Eigenes CLI-Parsing in `main.rs` (`parse_port`, `parse_days`, `parse_areas`) mit `const USAGE`.

### 3.5 Plattform, Build, Lints

- `#[cfg(windows)]`/`#[cfg(unix)]`/`#[cfg(test)]`, `[target.'cfg(windows)'.dependencies] windows-sys`.
- `edition = "2024"`, `resolver = "3"`, `rust-version = "1.95"` (docmap noch 2021!), `&raw mut`, `[lints] workspace = true`,
  `unsafe_code = "forbid"`, Clippy `all = deny`, `rustfmt.toml` (`style_edition = "2021"`, `newline_style = "Unix"`).
- `build.rs` (Code generieren, `OUT_DIR`, `include!`), `include_str!("../../../engine.lock")`, `env!("CARGO_BIN_EXE_fake-nvim")`.
- Release-Profil: `lto = "fat"`, `codegen-units = 1`, `strip = true`, **kein** `panic = "abort"` (Begründung im Kommentar);
  docmap: `opt-level = "s"`.
- `cargo deny` (`deny.toml`: Lizenz-Allowlist, `unknown-git = deny`, `wildcards = deny`), `cargo audit`, `--locked` überall.
- Dokumentation: `//!` Modulkopf mit Begründung, `/// # Errors`, `[`Verweis`]`, **Kommentare erklären das Warum**
  (und verweisen auf Konzept-/Regelnummern).

### 3.6 Tests (TST-Regeln)

- **Integrationstests als „Rig“**: `async fn rig(name) -> Rig` baut echten Server auf `127.0.0.1:0` mit `fake-nvim`,
  `ManualClock`, `Scratch`-Ordner; Feld-Reihenfolge der Struktur steuert die Drop-Reihenfolge (`_dir` zuletzt).
- **Testnamen als Sätze** (`an_inheritable_handle_is_no_longer_inheritable_after_the_call`).
- **Sabotage-Regel**: ein Fix gilt erst, wenn der Test ohne den Fix rot wird (`touch` + neu bauen!).
- **Testkit-Crates** (`hub-testkit`, `appkit-testkit` mit `security.rs` 1053 Zeilen, `dialect.rs`, `second_dialect.rs`)
  statt Wiederholung; **Scratch** räumt Temp-Ordner auch nach Panic auf, die CI zählt Übriggebliebenes
  (`tools/check-temp-leftovers.mjs --strict`).
- Echte Engine nur mit `TASKS_DESKTOP_REQUIRE_ENGINE=1` (sonst stilles Überspringen = falsches Grün).
- Browser: Playwright (Chrome, Firefox, WebKit), `@axe-core/playwright`, XSS-Korpus, freier Port pro Lauf (`e2e/port.ts`).
- UI: `vitest` (Dateien `*.test.ts` neben dem Code), `svelte-check`, `tsc`.
- Tauri: `tauri::test::mock_app()` für Sidecar-Auflösung.
- Tools haben eigene Tests (`tools/test_check_*.py`, `*.test.mjs`).

---

## 4. UI-Seite (so weit sie zum Stack gehört)

- **Svelte 5 mit Runes** (in tasks-desktop `$state` 243×, `$derived` 219×, `$effect` 57×, `$props` 45×) in `*.svelte` und `*.svelte.ts` (`app.svelte.ts`);
  Vite 8, TypeScript 6, Vitest 5. Gemeinsame Pakete `appkit-ui` (Tokens, MenuBar, MultiSelect, Markdown-Leser, SSE-Client,
  Pairing-Code) und `appkit-web`, per `github:…#vX.Y.Z&path:ui-kit` gepinnt.
- **Regeln**: keine Farbliterale außerhalb der Tokens (`tools/check-color-literals.py`), keine Steuerzeichen
  (`check-control-chars.py`), Typen des Vertrags kommen aus `contract.d.ts` (kopiert, nicht gebaut).
- **SSE** für „es hat sich etwas geändert“, nie für Daten (SRV-19).
- **docmap**: Vanilla JS in `src/lib/*.js` mit Tests über `node:test` + `node:assert/strict`, `withGlobalTauri: true`, `invoke()` gegen
  `#[tauri::command]`/`#[tauri::command(async)]`.

---

## 5. DevOps, wie es hier gelebt wird

| Thema | Umsetzung | Regeln/Dateien |
|---|---|---|
| CI | GitHub Actions, **self-hosted Windows-Runner**, nur `push` auf `main`, **kein** `pull_request`-Trigger (Fork-PR würde mit Rechten des Runners laufen) | `.github/workflows/ci.yml` |
| Reihenfolge | UI bauen → `cargo fmt --check` → `clippy -D warnings --locked` → `cargo test --locked` → Temp-Leichen-Check → Install-/Uninstall-Skripte → PSScriptAnalyzer → Playwright | `ci.yml`, `CLAUDE.md` („vor fertig“) |
| Lieferkette | Actions **per Commit-SHA gepinnt** (Kommentar nennt den Tag), `permissions: contents: read`, `cargo deny`/`audit`, `check-lock-age.py`, `persist-credentials: false` | NREL-03, `deny.toml` |
| Pins | `engine.lock` (Engine+lib.nvim), appkit-Tag in Cargo/pnpm/Workflows, `tools/bump-apps.py vX.Y.Z` für alle vier Apps | `check-appkit-pin.py` |
| Rolling Build | `workflow_run` nach grüner CI → Pre-Release `latest`, nur Spitze von `main`, Gruppe mit `cancel-in-progress`-Trick | `rolling.yml` |
| Release | Tag `vX.Y.Z` → Check (Tag = Version = main = grüne CI) → Build → **Entwurf**, den ein Mensch öffnet, installiert und veröffentlicht; `SHA256SUMS`; veröffentlicht wird nie nachträglich verändert | NREL-07/08/10, `RELEASING.md` |
| Installation | `release-kit` in appkit: gestempeltes `install.ps1`; `uninstall.*` im App-Repo; `test-install.*` prüft gegen den Build | NREL-16 |
| Shell | Git Bash explizit (8.3-Pfad), `-e -o pipefail`; Unix-sh-Skripte und PowerShell parallel | `ci.yml` `defaults.run.shell` |
| Secrets/Sicherheit | `SECURITY.md`, Loopback-only, Tokens nie in Antworten, Secret-Datei mit Rechten | SRV-11…SRV-16 |
| Maschinenrolle | `NVIM_MACHINE_ROLE=workstation` ⇒ nichts Unsigniertes bauen/starten (EDR) | globale `CLAUDE.md` |
| Konzept-Disziplin | Gates `NEW_PROJECT.md` und `REVIEW.md` | `rules-vault/rulesets/native/gates` |

---

## 6. Nebenspur: `ai-desktop` (C++17)

Kleiner Vergleichsfall, weil dieselben Probleme (lokaler Server, Secrets, Tests) in C++ gelöst sind:
CMake ≥ 3.20, `/W4` bzw. `-Wall -Wextra`, **Kern als statische Bibliothek** (`ai_desktop_core`) ohne HTTP/OpenSSL,
damit Unit-Tests ohne Netz linken; vendored Header-only (`httplib.h`, `nlohmann/json`), `CPPHTTPLIB_OPENSSL_SUPPORT`,
Windows-Credential-Manager (`advapi32`), Provider-Clients hinter `model_client.hpp`, API-Tests in Node (`tests/*.test.mjs`).
Lernziel: den Vergleich ziehen können (Ownership/RAII in C++ vs. Rust; was Rust dir hier abnimmt).

---

## 7. Der Plan

Jede Woche hat: **Lesen** (Primärquelle), **Code lesen** (konkrete Dateien), **Selbst bauen** (ohne KI), **Nachweis**.
Bücher aus `$REPOS_DIR/Literatur/02_Programming/Rust`: *Rust for Rustaceans* (Gjengset), *Command-Line Rust*
(Youens-Clark), *Rust Programming Foundations*, *Rust Web Programming*. Online (frei): *The Rust Book*, *Rust by Example*,
*The Rustonomicon* (nur für `unsafe`), *Asynchronous Programming in Rust*, *Tokio Tutorial*, *Cargo Book*, *Clippy Lints*,
*axum*-Doku, *Tauri v2*-Doku, *Svelte 5*-Doku.

### Block A — Rust-Kern (Woche 1–6)

| Woche | Lesen | Code lesen | Selbst bauen | Nachweis |
|---|---|---|---|---|
| 1 | Rust Book Kap. 1–6 (Cargo, Typen, Ownership, Structs, Enums, `match`) | `appkit-core/src/identity.rs`, `lib.rs` | `wc`/`grep`-Klon mit eigenem Arg-Parsing wie `parse_port` (Slice-Patterns, ohne `clap`) | Erkläre Move/Borrow an deinem Code, ohne Nachschlagen |
| 2 | Kap. 7–10 (Module, Collections, **Fehler**, Generics, Traits, **Lifetimes**) | `appkit-core/src/proc.rs` (`ProcError`, `Display`, `Error`) | Eigener Fehler-Enum mit `Display`+`Error`+`From`, `?` über drei Schichten | Tabelle: wann `String`, wann Enum, wann `Box<dyn Error>` |
| 3 | Kap. 11–13 (Tests, Closures, Iteratoren); Rust by Example „Tests“ | `appkit-core/src/authn.rs` (Clock, `ManualClock`, `Secret`) | `Clock`-Trait + `RateLimiter` (Fenster, Limit), Tests mit manueller Uhr | Alle Tests grün; Sabotage: Test wird rot, wenn Limit-Logik kaputt |
| 4 | Kap. 14–17 (Cargo-Workspaces, `Rc`/`Arc`/`Mutex`, Threads) ; Gjengset Kap. 1–3 | `appkit-scratch/src/lib.rs` (RAII, `Drop`, `Deref`) | `Scratch`-Klon mit Retry-Entfernung; Test, der bei Panic aufräumt | `drop`-Reihenfolge erklärt (Feldreihenfolge, Locals) |
| 5 | Kap. 18–19 (Pattern, **Slice-Patterns**, `let else`, `matches!`), Gjengset Kap. 4 (Fehler) , Cargo Book „Workspaces, Features, Profiles“ | `tasks-hub/src/main.rs` komplett | Mini-Workspace mit 2 Crates, `[workspace.lints]`, `forbid(unsafe_code)`, `rustfmt.toml`, `clippy all=deny` | CI-gleiche Befehle (`fmt --check`, `clippy -D warnings`, `test --locked`) grün |
| 6 | Gjengset Kap. 2–3 (Typen, Design-Schnittstellen), Kap. 6 (Testing); Clippy-Lints durchblättern | `engine/method.rs`, `engine/mod.rs` | `Method`/`MethodSpec`-Tabelle (`const fn`, `static`) für 5 Aufrufe nachbauen | Warum ist ein Aufruf aus String unmöglich? (ENG-Regel zitieren) |

**Meilenstein A:** `proc.rs` aus dem Gedächtnis neu schreiben (Spawn, `env_clear`, Limit, Watchdog), nur synchron mit Threads.

### Block B — Async und Server (Woche 7–12)

| Woche | Lesen | Code lesen | Selbst bauen | Nachweis |
|---|---|---|---|---|
| 7 | Async Book Kap. 1–4 (Futures, `Pin`, `async/.await`), Tokio Tutorial bis „Shared state“ | `engine/mod.rs` (`CallFuture`, `BoxFuture`) | Trait mit `Pin<Box<dyn Future + Send + 'a>>`, Fake- und echte Impl | Erkläre, warum `async fn` in Traits hier **nicht** genommen wird |
| 8 | Tokio Tutorial „Channels“, „I/O“, „Select“; Gjengset Kap. 8 (Async) | `hub.rs` (Accept-Schleife, `select!`, `Semaphore`, `watch`, Drop) | TCP-Echo-Server mit Verbindungslimit, sauberem Shutdown, Timeout | Last-Test (100 Verbindungen); Shutdown ohne hängende Tasks |
| 9 | Tokio „Bridging with sync“, `spawn_blocking`, Prozesse; Atomics (Gjengset Kap. 10) | `proc.rs` (async), `engine/cli.rs` (Queue, `oneshot`) | Async-`run_with_limits(Spec)` mit Watchdog und Kill; Queue mit `max_queue` + `Busy` | Test: Kind schläft ewig ⇒ `Timeout`, Kind ist tot |
| 10 | axum-Doku (Router, State, Extractors, Middleware); hyper 1.x Grundlagen; HTTP-Semantik (RFC 9110 Auszüge: Methoden, Header, Fehlercodes) | `guard.rs`, `http.rs`, `access.rs` | Mini-Server: Host-Check, Body-Limit, `Content-Type`-Pflicht, Origin/Sec-Fetch-Site als Middleware in fester Reihenfolge | Je Stufe ein Test (SRV-02…SRV-09) |
| 11 | Webanwendungs-Sicherheit: DNS-Rebinding, CSRF/Origin, Sec-Fetch-*, CSP; OWASP ASVS Kap. 3,4 | `authn.rs` (Pairing, Session, Rate-Limit, `ct_eq`), `registry.rs` | Pairing-Flow nachbauen (Einmal-Code, TTL, Session, Limit); Timing-sicherer Vergleich | Angriffsliste (SRV-10…SRV-13) abgehakt, je Punkt ein roter→grüner Test |
| 12 | Serde-Buch/Doku (`#[serde]`, Seeds, `RawValue`), `serde_json`; atomares Schreiben unter Windows | `store.rs` (Streaming-Deserialize), `config.rs`, `fs_watch.rs` (notify) | Konfig laden: Größenlimit, strikte Felder, atomar speichern, Watcher mit Entprellung | Fuzz-ähnlich: kaputte/zu große Dateien, nichts crasht |

**Meilenstein B:** „Mini-appkit“ (siehe 8.1) steht: Guard + Pairing + Engine-Trait + Fake-Engine + Sicherheitsmatrix-Tests.

### Block C — App, Plattform, Tests (Woche 13–18)

| Woche | Lesen | Code lesen | Selbst bauen | Nachweis |
|---|---|---|---|---|
| 13 | `tasks-desktop/README`, `SECURITY.md`; Regeln `ENG-01…15`, `APP-01…10` | `tasks-hub/src/app.rs`, `server/mod.rs`, `server/routes.rs` | Eigene Route „GET /api/snapshot“ + „POST /api/write“ gegen Fake-Engine, nur Form prüfen (SRV-18) | Route nur mit Session erreichbar (Default geschlossen) |
| 14 | Regeln `SRV-19…22`; SSE-Spezifikation | `watch.rs`, `classes.rs`, `server/check.rs` | SSE-Stream „etwas hat sich geändert“ mit Session-Bindung und Limit; Datenklassen fail-closed | Stream-Test: ohne Klasse nichts im Export |
| 15 | Windows-Fallen (`WIN-`-Regeln), `windows-sys`, Handle-Vererbung; Rustonomicon „Unsafe“ | `handles.rs`, `background.rs` (Autostart, Start im Hintergrund), `loginitems.rs`, `shell_link.rs` | Funktion „Standard-Handles nicht vererbbar“ mit `// SAFETY:`; `start`/`stop` mit PID-/Discovery-Datei | Test aus `handles.rs` selbst schreiben, ohne hinzusehen |
| 16 | Regeln `TST-`; Playwright-Doku; axe-core | `hub-testkit/tests/*` (zuerst `write_route.rs`, `vaults.rs`), `appkit-testkit/src/security.rs` | Eigenes `testkit`-Crate: Rig, Fake-Engine, `Scratch`; 10 Sicherheitstests als Matrix | Matrix läuft gegen deinen Mini-Hub **und** gegen `rules-hub` (zweiter Dialekt) |
| 17 | Svelte-5-Tutorial (Runes), Vite, Vitest, TypeScript-Handbuch (Kap. Typen/Generics) | `ui/src/App.svelte`, `lib/app.svelte.ts`, `lib/api.ts`, `contract.d.ts` | Kleine Svelte-Seite für deinen Mini-Hub: Pairing-Code, Liste, SSE, Tests mit Vitest | `pnpm check && pnpm test && pnpm build`; Playwright-Smoke inkl. axe |
| 18 | `rules-desktop` komplett lesen (kleinster Fall), `crates/rules-hub/src/{lib,runtime}.rs`; Vergleich mit tasks | `rules-desktop/crates/rules-hub`, `appkit-testkit/tests/second_dialect.rs` | Diff-Notiz: was ist App-eigen, was geteilt? Eine fehlende Funktion in rules nachziehen | Notiz in WKDBooks; Tag-Bump-Prozess (`bump-apps.py`) im Trockenlauf erklärt |

**Meilenstein C:** Der Mini-Hub besteht `fmt`, `clippy`, `test --locked` und die Playwright-Smoke-Tests.

### Block D — Tauri, DevOps, Abschluss (Woche 19–26)

| Woche | Lesen | Code lesen | Selbst bauen | Nachweis |
|---|---|---|---|---|
| 19 | Tauri v2 (Architektur, Commands, State, Events, Capabilities/Permissions, Sidecar, CSP, Asset-Protocol) | `docmap-desktop/src-tauri/{Cargo.toml,tauri.conf.json,capabilities/default.json,build.rs}` | Tauri-App „Hello Command“ + Ordnerdialog + Sidecar-Aufruf | Erkläre je Capability: was bricht, wenn sie fehlt |
| 20 | Tauri Testing (`mock_app`), Fehlerdesign (`apperr.rs`) | `main.rs` (erst Inhaltsverzeichnis per `grep "#\[tauri::command"`), `apperr.rs`, `proc.rs`, `safe_read.rs`, `contract.rs` | Commands + Fehler-Enum + Test mit `mock_app` | Liste: welche 5 Module würdest du aus `main.rs` herauslösen? (siehe 8.4) |
| 21 | GitHub-Actions-Doku (Events, Concurrency, Permissions, `workflow_run`), Sicherheits-Härtung (GitHub „Security hardening“) | alle drei Workflows von tasks-desktop | Eigener Workflow: fmt/clippy/test/Artefakt, Pins per SHA, kein `pull_request` | Erklärung, warum `workflow_run` + `head_sha`-Vergleich nötig ist |
| 22 | Cargo Book „Publishing/Lockfile/Features“, `cargo-deny`-Buch, `cargo-audit`; SLSA-/Supply-Chain-Grundlagen | `deny.toml`, `tools/check-lock-age.py`, `check-appkit-pin.py` | `deny.toml` für den Mini-Hub; ein eigenes Prüfskript mit Test | `cargo deny check` grün; Skript-Test rot→grün |
| 23 | Release-Prozess: Semver, Checksummen, Entwurf-Releases; PowerShell + sh Installer | `appkit/release-kit/`, `scripts/{test-install,uninstall}.*`, `RELEASING.md`, `release.yml` | Release-Workflow für den Mini-Hub (Tag ⇒ Entwurf ⇒ `SHA256SUMS`) und `install.ps1` | Trockenlauf: installieren, starten, deinstallieren in Temp-Ordner |
| 24 | Performance & Binärgröße: LTO, `codegen-units`, `strip`, `panic`-Strategien; `cargo bloat`/`cargo flamegraph` | `Cargo.toml`-Kommentare der Release-Profile (Begründung mit Messwert) | Eigene Messung: Größe vs. Startzeit bei thin/fat LTO | Tabelle mit Zahlen, Entscheidung begründet |
| 25 | WebAssembly-Variante: wasmoon, IndexedDB, Datei-System-Zugriff im Browser, eine HTML-Datei packen | `ui/web/*`, `appkit-web`, `tasks-web/` (Prüfsummen, CSP) | Pack-Skript, das eine Seite zu einer Datei bündelt und per `SHA256SUMS` prüft | Seite öffnet offline, null Requests (Playwright-Check) |
| 26 | Rückblick: `rules-vault/…/APPS_RUST_WEB.md` komplett; `gates/REVIEW.md` | eigene Mini-App gegen das **Review-Gate** | Review-Protokoll: jede Regel erfüllt/Lücke/n. a. | Kompetenzmatrix aktualisieren (Rust → 4) |

---

## 8. Übungen, die den Plan tragen

### 8.1 Das Abschlussprojekt: „Mini-appkit“ (Woche 6–26 wächst es mit)
Ein Workspace `mini-appkit` mit `mini-core` (Secret, Clock, proc, Registry), `mini-hub` (Guard, Pairing, Accept-Schleife,
Engine-Trait, `CliEngine` + Fake), `mini-testkit` (Rig, Scratch, Sicherheitsmatrix), `ui/` (Svelte 5), eigene CI und Release.
Engine ist ein kleines Lua-Skript oder ein Rust-Fake. **Regel:** nichts kopieren; nach jedem Block erst selbst bauen,
dann gegen das Original vergleichen und die Unterschiede notieren.

### 8.2 Nachbau-Reihenfolge (schwer ⇒ später)
`Secret`+`ct_eq` → `Clock`/`ManualClock` → `RateLimiter` → `proc::run` → `Scratch` → Guard-Middleware → Pairing →
`Engine`-Trait + `Method`-Tabelle → `CliEngine`-Queue → Accept-Schleife → Store/Watcher → SSE → Datenklassen.

### 8.3 Code-Lesepfad (Reihenfolge, jeweils mit Stift: Was ist die Invariante?)
1. `appkit-core/src/{lib,identity,proc,authn,registry}.rs`
2. `appkit-hub/src/{lib,hub,guard,http,access,limits}.rs`
3. `appkit-hub/src/engine/{mod,method,cli,wire,host}.rs`
4. `appkit-hub/src/{store,fs_watch,config,vaults,discovery,search}.rs`
5. `appkit-hub/src/{background,setup,loginitems,shell_link,handles}.rs` (Plattform)
6. `rules-desktop/crates/rules-hub/src/*` (klein) ⇒ danach `tasks-desktop/crates/tasks-hub/src/*`
7. `appkit-testkit`, `hub-testkit/tests/*`
8. `docmap-desktop/src-tauri/src/*` (anders: kein HTTP, dafür Tauri-Commands)

### 8.4 Review-Übungen
- **docmap-desktop:** `main.rs` hat 5827 Zeilen, `csp: null`, `assetProtocol.scope: ["**"]`, `edition = "2021"`. Schreibe
  ein Review gegen `gates/REVIEW.md` und einen Aufteilungsplan der Module; begründe jede Lücke mit der Regelnummer.
- **Idiom-Review:** suche in `tasks-hub/src/app.rs` (1313 Zeilen) drei Stellen, die du anders schreiben würdest, und
  begründe, warum die vorhandene Lösung (oder deine) besser ist.
- **Unsafe-Audit:** alle 15 `unsafe`-Treffer finden, je `// SAFETY:` prüfen (Annahmen, Lebensdauern, Windows-Semantik).

---

## 9. Selbsttest (alle müssen ohne Nachschlagen gehen)

**Rust**
1. Warum ist `trait Engine` nicht `async fn call`, sondern liefert `Pin<Box<dyn Future … + 'a>>`? Was würde `async_trait`/native `async fn in trait` ändern?
2. Warum `Arc<dyn Engine>` statt `Box<dyn Engine>` oder generisch `E: Engine`?
3. Welche Drop-Reihenfolge hat `struct Rig { server, vault, token, _dir }`, und warum steht `_dir` zuletzt?
4. Warum darf ein `std::sync::MutexGuard` nicht über `.await` gehalten werden? Was passiert mit `Send`?
5. Was ist der Unterschied zwischen `unsafe_code = "forbid"` und `"deny"` und warum nutzt appkit `deny`?
6. Warum `u64::try_from(by.as_millis()).unwrap_or(u64::MAX)` statt `as u64`?
7. Wann ist `?` auf `Option` erlaubt? Wie wirkt `let … else` auf den Kontrollfluss?
8. Erkläre `impl<'de> Deserialize<'de> for Top` und wann ein `DeserializeSeed` nötig wird.
9. Warum `tokio` mit `default-features = false`? Was bricht, wenn `rt-multi-thread` fehlt?
10. Was macht `build.rs` hier, und warum der `touch` auf `ui.rs`?

**Architektur/Sicherheit**
11. Nenne die acht Stufen des Guards in Reihenfolge und den Angriff, den jede abwehrt.
12. Warum ist eine Mutation ohne `Origin` ein „Programm-Client“ und was verlangt der Guard dann?
13. Wie vergleicht man Geheimnisse, und warum hat `Secret` kein `PartialEq`?
14. Was bedeutet „fail-closed“ bei Datenklassen? Was passiert mit einem neuen Bereich ohne Klasse?
15. Warum läuft die Engine mit `env_clear` und welche Variablen bekommt sie (`child_env`)?
16. Warum wird die UI in das Binary eingebettet statt vom Datenträger bedient?

**DevOps**
17. Warum kein `pull_request`-Trigger? Was würde ein Fork-PR auf dem Runner tun können?
18. Wie stellt `rolling.yml` sicher, dass nur die Spitze von `main` gebaut wird?
19. Welche fünf Dinge müssen vor einem Release übereinstimmen (NREL-08)? Warum bleibt der Entwurf ein Entwurf?
20. Wie hebst du den appkit-Tag in allen vier Apps an, ohne eine Stelle zu vergessen?

**Tauri**
21. Was passiert, wenn eine Capability fehlt (Build- oder Laufzeitfehler)? Wie testest du das?
22. Sidecar vs. Ressource vs. PATH: Reihenfolge und Begründung in `engine_info()`.

---

## 10. Aufwand und Reihenfolge

- **Mindestweg (ca. 12 Wochen):** Block A (1–6) + Woche 7–10 + Woche 13 + 16 + 21. Du kannst dann jede Datei lesen und kleine Änderungen sicher machen.
- **Voller Weg (26 Wochen):** wie oben; Ergebnis: Mini-appkit, das die Sicherheitsmatrix besteht, plus Release-Pipeline.
- **Danach:** Kompetenzmatrix Rust von 1/2/2/3 auf 3/4/4/4 heben; offene Punkte (z. B. `docmap-desktop`-Refactoring,
  Edition 2024, CSP) als eigene Tasks anlegen.

## 11. Quellen im Detail

- Repo-Docs: `tasks-desktop/CLAUDE.md`, `docs/{RELEASING,SECURITY}.md`, `rules-desktop/docs/{USAGE,WORKFLOW}.md`, `appkit/{README,SECURITY}.md`,
  `appkit/docs/`, `docmap-desktop/docs/`.
- Regeln: `$RULES_VAULT/rulesets/native/regeln/APPS_RUST_WEB.md`, `_rules/{RS,SRV,ENG,WEB,TAU,WIN,NREL,TST,APP}`.
- Bücher: Gjengset *Rust for Rustaceans* (Bestand), Youens-Clark *Command-Line Rust* (Bestand), Flitton *Rust Web Programming* (Bestand;
  zum Vergleich, nutzt andere Frameworks), Rust-Programming-Foundations (Bestand).
- Frei: Rust Book, Rust by Example, Rustonomicon, Async Book, Tokio Tutorial, Cargo Book, Tauri v2, Svelte 5, Playwright, GitHub Actions Security Hardening.
