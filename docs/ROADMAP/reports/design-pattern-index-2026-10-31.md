---
title: Design-Pattern-Index ueber alle Plugins und Apps
date: 2026-10-31
task: ALL/design-pattern-index
---

# Design-Pattern-Index (2026-10-31)

Ergebnis der Task `ALL/design-pattern-index`. 484 bestaetigte Verwendungen, 105 Kandidaten, 50 Repos mit Treffern.

**Methode:** 12 Durchlaeufe (je 1 Agent, Repo-Gruppen), je Repo Modulbaum + Grep nach Pattern-Signaturen + Lesen der Treffer-Stellen. Es ist ein Stichproben-Index (die Repos haben zusammen ca. 1 Mio. Zeilen), kein vollstaendiges Audit; Zeilenangaben sind teils der Beginn des Konstrukts. In Lua sind Patterns meist klasslos umgesetzt (Closures, Modul-Tabellen, Callbacks), Beispiele: Observer = Autocmd/User-Event, Strategy = Funktions-Tabelle, Facade = Modul-API.

Sichten: [1 Katalog](#1-pattern-katalog) | [2 Geprueft](#2-geprueft) | [3 Verwendungen nach Pattern](#3-verwendungen-nach-pattern) | [4 Verwendungen nach Repo](#4-verwendungen-nach-repo) | [5 Kandidaten nach Pattern](#5-kandidaten-nach-pattern) | [6 Kandidaten nach Repo](#6-kandidaten-nach-repo) | [7 Metriken](#7-metriken) | [8 Folge-Tasks](#8-folge-tasks)

## 1 Pattern-Katalog

GoF-23 (Erzeugung, Struktur, Verhalten) plus 16 moderne Patterns. Quelle der Beschreibungen: https://refactoring.guru/design-patterns. Spalten `V`/`K` = Anzahl Verwendungen/Kandidaten in diesem Index.

| Pattern | Gruppe | Kurzbeschreibung | V | K | Link |
|---|---|---|---|---|---|
| Abstract Factory | creational | Familien zusammengehoeriger Objekte ohne konkrete Klassen erzeugen. | 1 | 0 | [guru](https://refactoring.guru/design-patterns/abstract-factory) |
| Builder | creational | Komplexes Objekt schrittweise (fluent) aufbauen. | 5 | 1 | [guru](https://refactoring.guru/design-patterns/builder) |
| Factory Method | creational | Erzeugung an Unterklasse/Funktion delegieren (`M.new`, Constructor-Funktionen). | 3 | 1 | [guru](https://refactoring.guru/design-patterns/factory-method) |
| Prototype | creational | Objekte durch Klonen neu erzeugen (`vim.deepcopy`, Metatable-Vererbung). | 1 | 0 | [guru](https://refactoring.guru/design-patterns/prototype) |
| Singleton | creational | Genau eine Instanz (in Lua: Modul-Tabelle). | 12 | 0 | [guru](https://refactoring.guru/design-patterns/singleton) |
| Adapter | structural | Fremde Schnittstelle auf erwartete abbilden. | 20 | 0 | [guru](https://refactoring.guru/design-patterns/adapter) |
| Bridge | structural | Abstraktion und Implementierung trennen. | 2 | 0 | [guru](https://refactoring.guru/design-patterns/bridge) |
| Composite | structural | Baum aus Einzel- und Gruppenobjekten, einheitlich behandelt. | 6 | 0 | [guru](https://refactoring.guru/design-patterns/composite) |
| Decorator | structural | Verhalten per Wrapper ergaenzen. | 8 | 0 | [guru](https://refactoring.guru/design-patterns/decorator) |
| Facade | structural | Einfache Schnittstelle vor einem Subsystem (Modul-API). | 29 | 6 | [guru](https://refactoring.guru/design-patterns/facade) |
| Flyweight | structural | Gemeinsamen Zustand teilen, um Speicher zu sparen. | 1 | 0 | [guru](https://refactoring.guru/design-patterns/flyweight) |
| Proxy | structural | Platzhalter, der Zugriff kontrolliert (lazy, caching, logging). | 1 | 0 | [guru](https://refactoring.guru/design-patterns/proxy) |
| Chain of Responsibility | behavioral | Anfrage wandert durch Handler-Kette. | 20 | 1 | [guru](https://refactoring.guru/design-patterns/chain-of-responsibility) |
| Command | behavioral | Aktion als Objekt (Undo, Queue, Command-Tabellen). | 26 | 13 | [guru](https://refactoring.guru/design-patterns/command) |
| Interpreter | behavioral | Grammatik/Mini-Sprache auswerten. | 0 | 0 | [guru](https://refactoring.guru/design-patterns/interpreter) |
| Iterator | behavioral | Sequenziell durchlaufen, ohne Struktur offenzulegen. | 1 | 1 | [guru](https://refactoring.guru/design-patterns/iterator) |
| Mediator | behavioral | Kommunikation ueber Vermittler statt direkt. | 2 | 1 | [guru](https://refactoring.guru/design-patterns/mediator) |
| Memento | behavioral | Zustand sichern und wiederherstellen. | 13 | 0 | [guru](https://refactoring.guru/design-patterns/memento) |
| Observer | behavioral | Abonnenten werden bei Aenderung benachrichtigt (Autocmd/User-Event). | 21 | 0 | [guru](https://refactoring.guru/design-patterns/observer) |
| State | behavioral | Verhalten haengt vom Zustandsobjekt ab (Zustandsautomat). | 8 | 3 | [guru](https://refactoring.guru/design-patterns/state) |
| Strategy | behavioral | Austauschbare Algorithmen (Funktions-Tabelle). | 32 | 27 | [guru](https://refactoring.guru/design-patterns/strategy) |
| Template Method | behavioral | Algorithmus-Skelett, Schritte ueberschreibbar. | 12 | 14 | [guru](https://refactoring.guru/design-patterns/template-method) |
| Visitor | behavioral | Operation von der Objektstruktur trennen. | 0 | 0 | [guru](https://refactoring.guru/design-patterns/visitor) |
| Registry | modern | Zentrale Tabelle registrierter Eintraege/Plugins. | 47 | 10 | - |
| Dependency Injection | modern | Abhaengigkeiten von aussen uebergeben statt hart verdrahten. | 15 | 0 | - |
| Event Bus | modern | Publish/Subscribe ueber einen zentralen Kanal. | 10 | 2 | - |
| Middleware/Pipeline | modern | Stufenkette, die Daten nacheinander transformiert. | 13 | 5 | - |
| Repository | modern | Datenzugriff hinter einer Sammlungs-Schnittstelle. | 5 | 0 | - |
| Lazy Initialization | modern | Erst beim ersten Zugriff laden/erzeugen. | 29 | 1 | - |
| Null Object | modern | Neutrales Objekt statt nil-Pruefungen. | 11 | 0 | - |
| Object Pool | modern | Teure Objekte wiederverwenden. | 5 | 0 | - |
| Async/Promise | modern | Coroutines/Futures fuer asynchronen Ablauf. | 12 | 0 | - |
| Debounce/Throttle | modern | Ereignisflut zeitlich buendeln. | 31 | 5 | - |
| Circuit Breaker | modern | Wiederholte Fehlschlaege abfangen, Aufrufe sperren. | 2 | 0 | - |
| Cache/Memoize | modern | Ergebnisse zwischenspeichern. | 40 | 1 | - |
| Specification | modern | Regeln als kombinierbare Praedikate. | 12 | 2 | - |
| Result/Option | modern | Fehler als Wert (`ok, err`) statt Exception. | 15 | 4 | - |
| Reducer/MVU | modern | Zustand = reduce(Zustand, Aktion) (Elm-Architektur). | 1 | 0 | - |
| Module | modern | Modul-Tabelle als Namensraum/Singleton (`local M = {}`). | 1 | 0 | - |
| Sonstige (keinem Katalog-Pattern zuordenbar) | - | - | 11 | 7 | - |

GoF-Patterns ohne einen einzigen Treffer: Interpreter, Visitor.

## 2 Geprueft

Alle Gruppen lieferten ein Ergebnis (0 Fehler). Pro Repo laut Agent:

- lib.nvim (E:/repos/lib.nvim): lua/lib/lua/*, lua/lib/nvim/* (registry, hooks, debounce, async, progress, bindings/autocmd/dispatcher, bindings/usercmd/composer, ui/kit/history, cache, checkpoint, logger, store, notify), lua/lib/strategies/*
- runtime-analysis.nvim
- testing.nvim
- testing-web
- casedesk.nvim
- tasks.nvim
- docmap.nvim
- docmap-desktop
- filetree.nvim
- ui.nvim
- lsp.nvim
- gopath.nvim
- hover.nvim
- markdown.nvim
- mdview.nvim
- rules.nvim
- gitsuite.nvim
- ai.nvim
- buffer-ctx.nvim
- cascade.nvim
- cmdlog.nvim
- color_my_ascii.nvim
- dap.nvim
- data.nvim
- debugging.nvim
- diff.nvim
- emojis.nvim
- fileops.nvim
- github_stats.nvim
- images.nvim
- insights.nvim
- language.nvim
- media.nvim
- my.nvim
- open.nvim
- openinnvim
- pdfport.nvim
- pickers.nvim
- recommender.nvim
- replacer.nvim
- reposcope.nvim
- sandbox.nvim
- sessions.nvim
- spotlight.nvim
- terminal.nvim
- appkit
- tasks-desktop
- rules-desktop
- ai-desktop
- streamtap
- takt
- tasks-web

Nicht im Umfang bzw. leer: `testing-web` (nur Build-Artefakte, Quelle in testing-desktop), `openinnvim` (65 Zeilen). Nicht Teil der Pruefung: Doku-/Literatur-/Spiel-/Web-Repos (`Literatur*`, `FightingGame`, `portfolio*`, `RebellenHQ`, `Cyber-Security` u. a.), Vaults, `my-zsh`, `Configs`. Die nvim-Config selbst ist ebenfalls noch nicht durchgesehen.

Bemerkungen der Agents:

- Gruppe 1: Only lib.nvim was examined (Lua, no Rust/Svelte). The tree is about 78k lines; I surveyed it by grep and read the key modules. I confirmed the cited lines by reading them. I did not cite file:line for every module in the Facade/Module family. Elseif chains elsewhere (frontmatter, json/canonical, data_classes, logger/serialize) are tokenizers or type switches, which are fine as chains, so I dropped them as candidates. nvim/git/init.lua is 2293 lines and is a Facade over git CLI helpers; I did not audit it for a split, so that is unconfirmed. I found no Circuit Breaker, Object Pool, Visitor, Flyweight or Reducer/MVU. Retry or backoff text appears only in nvim/cache/disk.lua, nvim/checkpoint and nvim/contract (not read). The library is already well factored, so only two candidates were worth listing.
- Gruppe 2: Only runtime-analysis.nvim examined (about 14.9k lines of Lua under lua/runtime-analysis; no plugin/ dir; .deps/lib.nvim ignored as a vendored dependency). Nothing was edited or built. The code is almost entirely classless (closures, module tables); there is no setmetatable-based OOP. The only autocmd/User event use is in startup/init.lua via lib.nvim's autocmd wrapper (startup/init.lua:186/280), which is why a raw nvim_create_autocmd grep finds nothing. I read these usage and candidate sites directly: registry.lua, startup/init.lua, runner.lua, env.lua, statusline.lua, curl.lua, usrcmds.lua, telemetry/init.lua, command.lua, report_style.lua. The Observer pattern wasn't confirmed as an event bus anywhere. Line numbers are the starts of the cited regions; a few usage lines (e.g. toggle.lua:34, usrcmds.lua:213, runner.lua:84) are the nearest declaration, not the exact line of every behavior described.
- Gruppe 3: testing-web contains only CLAUDE.md and README.md (the repo holds built artifacts only; the source lives in testing-desktop, which was not in scope). It therefore has no pattern usages or candidates. testing.nvim is pure Lua (about 88k lines under lua/testing), with no classes, so most patterns are closure-, module-table- or metatable-based. The repo has no coroutine-based async, no Rust or Svelte, and only a few autocmds (VimLeavePre cleanup and the lint and hover hooks). Debounce is implemented as a polled state object (run/watch.lua), not vim.defer_fn. The checked line numbers were read at the time of the audit. A few candidate line numbers (project.lua:907, repos.lua:131) point at the start of the relevant branch, and the end of execute_run (about 1556) is estimated from the awk function-length count rather than read. No files were edited and no builds were run.
- Gruppe 4: Both repos examined (lua trees, grep for signatures, key files read). Both are classless Lua: patterns are mostly module tables, closures, composer route/type tables and User events. No Rust, Svelte or Tauri code in either repo. Cited paths were each read or listed by grep; a few line numbers point at the start of the construct. Not exhaustively read: casedesk anonymize.lua (3232 lines), tasks mutate.lua, contract.lua, cli.lua beyond the cited regions. Debounce in tasks.nvim is implemented once in ui/dash_watch.lua and casedesk has two independent implementations, one hand-rolled in bindings/autocmds.lua:55 and one via lib.nvim in ui/anonymize_diff.lua. The hand-rolled one could use lib.nvim.debounce, which is XS and marginal, so I left it out of candidates. I found no true Singleton, Flyweight, Interpreter, Visitor classes, Object Pool, Circuit Breaker or Elm-style reducer.
- Gruppe 5: Both repos were examined and are non-empty. Several candidates are structural (file size) rather than pattern-driven. I cited the docmap-desktop main.js:2151 candidate without reading the handler body, so it is lower confidence than the rest. The Lua code is largely classless (closures, module tables, metatables as lazy proxies). Rust uses enums, Mutex and OnceLock statics, and command functions rather than traits or builders. I found no coroutines, no Svelte (the frontend is vanilla JS), and no Rust traits beyond Display and Error impls.
- Gruppe 6: Both repos were found and examined: filetree.nvim (about 29k lines of Lua) and ui.nvim (about 20k lines under lua/ui). I did not exhaustively read every file. I mapped the module trees, grepped for pattern signatures (register, setmetatable, debounce, coroutine, listeners/emit, undo and history stacks, if/elseif chains) and read the key files. The cited lines were read, but a few anchors are approximate: ui.nvim render.lua:~45, which is the generic_click_id helper, and statusline/catalog.lua:1, which cites the whole file. I did not grep for singleton or Module-pattern usage because it is pervasive (nearly every file is `local M = {}`), so it is not listed. Neither repo has Rust, Svelte or Tauri code. I found no Circuit Breaker, Object Pool, Visitor, Interpreter or Specification pattern, and no Result/Option type beyond Lua's (ok, err) return convention, which is used throughout (for example registry.register returns ok, err). The ui.nvim kit modules are mostly one-line re-exports of lib.nvim.ui.kit.*, so the real implementations are outside the audited repos. In filetree.nvim, util/pdf.lua also reads as a Strategy: mode 'system' versus pdfport.nvim, loaded through pcall(require). ui.nvim's vim_ui and slots/kinds are the clearest Chain/Strategy designs, and filetree's adapter and refs registries are the clearest Registry/Adapter ones."
- Gruppe 7: All three repos exist under E:/repos and were examined. Nothing is missing or empty. Method: module trees, size listings and greps for pattern signatures; the key files were read around the hits; line numbers were taken from grep -n or from reading the surrounding lines. Non-Lua parts (Rust/Svelte/Tauri) do not exist in these repos. All patterns are classless: closures, module tables and callbacks. Observer is autocmds, Strategy is function tables, Facade is the module API. Candidates were limited to places with a real duplicate or ladder; no pattern was proposed for its own sake. The hover.nvim and gopath.nvim registries are already clean extension points. The two weakest spots are the type ladder in hover build() and the duplicated action blocks in lsp bindings/actions.lua. I did not edit files or run builds or tests. The usage entry for hover persist.lua:1 only cites the module header; the touch/snapshot/load functions were not opened individually.
- Gruppe 8: All four repos exist under E:/repos and were examined (read-only); no edits or builds were run. The Rust side of mdview.nvim (native/wasm-render/src/lib.rs) is small free-function code with no traits, Arc<Mutex> or enums, so it only yields the Adapter/Builder entry. TypeScript was only skimmed (transport factory, history, controlMessage, editState); main.ts and the Svelte/Tauri layers were not read in depth, and mdview.nvim's inbound_poll.lua (1114 lines) was only grepped. Line numbers were checked with grep -n on the cited definitions. The Lua code is mostly classless, so Strategy appears as function tables, Observer as autocmds or User events, and Facade as module APIs. Unspecified entries in the usage list such as Module-as-singleton hold for almost every file and are listed only where state is explicit.
- Gruppe 9: All 8 repos exist under E:/repos and were examined (module tree, grep for signatures, reads of key files; cited lines were checked with grep/sed). Not covered: test dirs were skipped, and not every module in each repo was read in full. Patterns are mostly classless in Lua (closures, module tables, callback conventions). I recorded those as usages with the Lua form noted: Observer is an autocmd or listener, Strategy is a function or module table, Facade is a module API. None of the 8 repos has Rust or Svelte code; they are pure Lua. Real Singleton/Builder/Visitor/Interpreter/Event-Bus/Reducer instances were not found in these repos. State here is module-level tables, and setmetatable appears only in cascade's Context and ai.nvim's lazy provider proxy. The candidate list is deliberately short; weak ones (for example more registries, or splitting the 593-line ai config) were dropped.
- Gruppe 10: All eight repos exist and were examined (module tree listed, pattern-signature greps run, key files read). Lines were verified by grep or by reading the surrounding region, except images/zen.lua:91 and a few secondary lines, which came from grep output only. The largest tests/TESTS directories were excluded. diff, emojis, fileops, github_stats, images and insights are mostly classless Lua, so Strategy/Command/Registry here mean function or module tables. language.nvim, media.nvim and insights.nvim have the clearest registries. There are no Rust/Svelte/Tauri parts in these eight repos. Side finding, not a pattern: language.nvim/lua/language/spell/providers/cspell_server.lua:331 has `cfg.scan_debounce_ms and 6000 or 6000`, which always evaluates to 6000, and the file's own comment at line 327 says so.
- Gruppe 11: All 12 repos were examined. openinnvim is a C# (.NET Framework style) plus PowerShell project with no Lua, so its usages are C# idioms in src/*.cs (setup/*.cs and the .ps1 scripts were only skimmed). Repos use a lib.nvim helper layer (hooks, debounce, autocmd, lazy.require, composer), so several patterns (Observer, Debounce, Registry) are partly delegated there; the entries cite the local call sites. Lua code is classless: Observer is lists or User autocmds, Strategy is function tables or modules sharing a contract, Facade is the module API. Cited line numbers were read from the files (some, e.g. engines/init.lua:31, from grep -n of the definition); a few usages cite a block start, not every line mentioned in the note. Not examined in depth: test files, @types, health.lua and some UI modules (pickers filegrep/quickfix, reposcope ui, sessions marks, terminal cheatsheet and navigate, my.nvim color_codes). Candidates dropped as weak: sessions core.lua listing meta/buforder/pins sidecars in four places (core.lua:590-604, 749-756, 869-871, 899-901; a sidecar participant list would only pay off with a fourth sidecar), terminal ask.lua:92 hard-wired tmux/wezterm list vs backends.MULTIPLEXERS, terminal status/init.lua EXPORTERS repeating Env.SIGNALS env var names, replacer's own fzf/telescope picker selection vs pickers.nvim engines (cross-repo, large), reposcope metrics.check_rate_limit duplicated threshold branches, and openinnvim's string-typed Mode checks in Program.cs. Duplication figures for reposcope and sandbox come from diffs after renaming the provider or engine name, so they are approximate."
- Gruppe 12: All seven repos exist and were examined. tasks-web contains only built single-file pages (tasks.html, probe.html, engine-check.html: minified bundles with base64 engine blobs) plus README and a launcher script; its README says the sources live in tasks-desktop, so no hand-written pattern sites exist there and none are listed. No Lua source exists in these repos (tasks-desktop's tools/*.lua are fixtures/measurement scripts; the engines live elsewhere), so the Lua-specific patterns could not be assessed. appkit/crates/appkit-core/src/registry.rs is NOT a Registry pattern (it only reads/writes hub.json and control.secret), so it is not cited. The Rust and TS code is mostly trait/closure based; patterns are recorded even where classless. Line numbers were read in the files, with these approximations: tasks-desktop app.svelte.ts:3230 is the scheduleTextSearch start (~3227-3237), config.rs HubStatus/Source lines were not needed. Dashboard JS in ai-desktop/dashboard/index.html and the ui-kit Svelte components were only skimmed. takt is small and well structured, so only one marginal candidate was kept.

## 3 Verwendungen nach Pattern

### Abstract Factory (1)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| reposcope.nvim | `reposcope.nvim/lua/reposcope/controllers/provider_controller.lua:27` | providers table (github, gitlab, codeberg) of entrypoints with the same shape (readme_manager, repo_fetcher, cloner, query_builder); _resolve_provider (:57) picks one. |

### Builder (5)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/bindings/usercmd/composer/init.lua:257` | make_builder returns a fluent builder (desc/bang/range/count/buffer/route/build) that finalises via register(). |
| testing.nvim | `testing.nvim/lua/testing/core/result.lua:98` | new_run/new_case/add_case/finish_case/finalize assemble the Result-IR step by step; finish_case turns a case without assertions into a failure. |
| filetree.nvim | `filetree.nvim/lua/filetree/features/system/file_clipboard/backend.lua:119` | M.build(plat, paths, probe) returns a pure command spec {argv, env, stdin, tool}. The probe is injected for tests. The spec is separate from execution, which also gives a testable seam. |
| filetree.nvim | `filetree.nvim/lua/filetree/features/system/compress/archiver.lua:51` | detect() (line 24) picks a zip or bsdtar tool. build(tool,out,sources) branches on tool.kind to produce the argv. |
| mdview.nvim | `mdview.nvim/native/wasm-render/src/lib.rs:298` | render_markdown wraps comrak (Options built in build_options, line 8) and ammonia::Builder (sanitizer, line 227); Rust uses free functions and no traits/Arc<Mutex> |

### Factory Method (3)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/init.lua:376` | M.new builds a closure-based instance (no setmetatable) per namespace; M.auto at line 1226 is a convenience factory that wraps and starts. |
| mdview.nvim | `mdview.nvim/src/client/transport/transportFactory.ts:35` | createTransport returns a Transport (interface at transport.interface.ts:4) as WebTransport or WebSocket, with silent fallback to WebSocket |
| open.nvim | `open.nvim/lua/open/handlers/browser.lua:96` | make_named_handler builds one handler table per browser (firefox, opera, ...) from a few parameters. |

### Prototype (1)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| streamtap | `streamtap/extension/src/hook.js:471` | patch(proto, name, make) wraps MediaSource/SourceBuffer methods (e.g. appendBuffer at hook.js:712), calls the original, then reports, swallowing hook errors. |

### Singleton (12)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/store/init.lua:12` | Every module returns a table M; the store namespace is a thin facade over store.project. Applies repo-wide. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/toggle.lua:34` | module-level `disabled` cache plus on-disk flag acts as global state shared by all callers; same for statusline caches. |
| testing.nvim | `testing.nvim/lua/testing/statelock.lua:86` | M.with(path, fn) takes an O_EXCL lock file around read-modify-write of state files, with stale takeover and a timeout. Module-level state is used widely (trust.lua armed context at line 465, hover registered flag). |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/bindings/usrcmds.lua:925` | setup() stops then re-arms sla.notify timer so re-sourcing does not leave two timers (sla/notify.lua:190 stop). |
| gopath.nvim | `gopath.nvim/lua/gopath/truncated/cache.lua:133` | Module-local state table plus timer; same convention in alias_index/binding_index (weak caches). |
| lsp.nvim | `lsp.nvim/lua/lsp/core/supervisor.lua:87` | Module-local state/tracked/expected tables with idempotent setup() that resets the augroup. |
| markdown.nvim | `markdown.nvim/lua/markdown/core/table_mode.lua:33` | module-level S[bufnr] holds per-buffer mode state (augroup, busy guard); same shape in refs.lua and render.lua:1001 |
| mdview.nvim | `mdview.nvim/lua/mdview/core/state.lua:27` | WebKey enum plus getters/setters guard the web_state table; mutations go through validated accessors |
| dap.nvim | `dap.nvim/lua/wkddap/memory/init.lua:115` | `current` module-level state of the single open memory view. |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/dashboard/state.lua:10` | Module-level state record with init_state/get_state/clear_state plus setters (sort, time range, scroll); state/ui_state.lua is the buffer/window twin. |
| images.nvim | `images.nvim/lua/images/win_clipboard_worker.lua:54` | Module-level worker spawned lazily by ensure_worker (201); save_to_file queues requests, send_next (102) serializes one in flight, fail_all resets. |
| ai-desktop | `ai-desktop/src/config.cpp:70` | g_mutex/g_loaded/g_doc behind config::inspect/mutate (config.cpp:549/555); same shape in secrets.cpp:37 and catalog.cpp:42. |

### Adapter (20)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/lazy.lua:1` | Adapts lazy.nvim's plugin specs and LazyLoad events into telemetry targets (candidates()/configured()); manager-agnostic setup_all.lua consumes only that. |
| testing.nvim | `testing.nvim/lua/testing/dialect/busted.lua:439` | Dialect modules adapt busted, luassert and the harness A/B/C/D styles to one run_file(a, spec, opts) -> cases signature; harness_conventions adapts differing failure conventions. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/stream_format.lua:20` | detect() picks snow vs saperesolve; two parsers (sla/stream.lua:238, extract/stream.lua:434) adapt each export to one shape. |
| ui.nvim | `ui.nvim/lua/ui/kit/history.lua:3` | Most ui.kit.* files are one-line re-exports of lib.nvim.ui.kit.* (async, sidebar_state, toast, viewer and others), a thin facade giving one module name for both namespaces. kit/async.lua is the coroutine-based async/await layer over the callback components. |
| gopath.nvim | `gopath.nvim/lua/gopath/create.lua:191` | ask() and ask_input() pick ui.kit when present, otherwise vim.ui.select/input; selected at load by pcall(require) at line 167. |
| lsp.nvim | `lsp.nvim/lua/lsp/integrations/cmp.lua:1` | One module per third-party plugin (cmp, blink, conform, trouble, mason, lazydev, ...) exposing capabilities/on_attach/on_init; the core does not know the plugins. |
| lsp.nvim | `lsp.nvim/lua/lsp/completion/blink.lua:24` | Source.__index and setmetatable at line 30 adapt the plugin's completion data to the blink.cmp source interface; register.lua:174 does the same for nvim-cmp. |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/dashboard/actions.lua:32` | by_changed wraps on_done for lib.nvim.git calls; actions reshape (opts,on_done,git_cmd) to (repo,on_done) |
| ai.nvim | `ai.nvim/lua/ai/providers/aliases.lua:16` | canonical(id) maps old provider ids (loomai) to current ones; used by providers.get/resolve and config. |
| dap.nvim | `dap.nvim/lua/wkddap/ui/provider.lua:134` | dispatch(actions, what) maps the active provider to a per-provider closure (toggle :168, eval :182), pcall-protected. |
| language.nvim | `language.nvim/lua/language/hover.lua:237` | setup() registers the plugin as a contributor with hover.nvim when present; registered() (218) reads state back from hover's registry. |
| insights.nvim | `insights.nvim/lua/insights/hover.lua:113` | Registers a position-preview contributor with hover.nvim via registry.register, guarded by pcall and a _registered flag. |
| diff.nvim | `diff.nvim/lua/diff/core/pickers_bridge.lua:28` | Wraps pickers.nvim engine as a vim.ui.select-compatible function, returning nil when absent so callers fall back. |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/backends/init.lua:15` | BUILTIN_BACKENDS (pdftotext, docling, marker, ollama, claude, gemini...) all expose available()/extract() behind the registry contract. |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/integrations/oil.lua:1` | neotree, nvim_tree, netrw, oil, telescope and fzf each adapt a host plugin to the same hook-up shape; integrations/init.lua:18 is the facade. |
| pickers.nvim | `pickers.nvim/lua/pickers/engines/telescope.lua:156` | telescope, fzf and snacks engines each implement pick_files (fzf.lua:193, snacks.lua:123), live_grep, smart, pick_item and pick_dir behind one contract; engines/init.lua:31 load() selects one. |
| pickers.nvim | `pickers.nvim/lua/pickers/keys/init.lua:323` | One resolved key spec is translated by telescope_mappings, fzf_keymap (:330) and snacks_win (:308); entry_actions/adapters/{telescope,fzf,snacks}.lua do the same for actions. |
| replacer.nvim | `replacer.nvim/lua/replacer/pickers/fzf.lua:1` | fzf and telescope pickers share pickers/common.lua (session_open :165, session_result :207) and are selected by init.lua:59. |
| sandbox.nvim | `sandbox.nvim/lua/sandbox/core/ports/container_engine.lua:4` | Port with erroring default stubs (abstract-class style); adapters docker, podman, nerdctl implement it; sandbox/init.lua:7 maps engine name to adapter and get_engine() resolves it. |
| tasks-desktop | `tasks-desktop/ui/src/web/hub.ts:165` | createWebHub answers the Rust hub's routes inside the page from the engine worker, behind the same fetch the Hub client takes; HubDeps (line 26) is the injected dependency set. |

### Bridge (2)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| appkit | `appkit/crates/appkit-hub/src/hub.rs:7` | Runtime trait with associated Target plus BuildRuntime factory closure (hub.rs:17) lets the shared Core<R> serve different apps; Pages (hub.rs:29) is a second app-supplied seam. |
| takt | `takt/crates/takt-backend/src/lib.rs:85` | VideoBackend trait; NullBackend (null.rs:152) is the synthetic implementation that also acts as Null Object/test double until a real decoder exists. |

### Composite (6)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/progress/init.lua:142` | A progress handle fans out start/update/finish to a list of interchangeable style impls (statusline, echo, fidget, notify, float, kit), each guarded by pcall. |
| testing.nvim | `testing.nvim/lua/testing/bindings/usrcmds.lua:611` | M.routes() declares the :Testing subcommand tree as data (path, args, flags, run fn); the same tree drives dispatch and completion. |
| docmap-desktop | `docmap-desktop/src-tauri/src/menu.rs:110` | Node enum {Item, Check, Sub(label, &[Node])} is a static composite menu; forward_clicks (menu.rs:370) emits a 'menu' event once to the frontend. |
| rules.nvim | `rules.nvim/lua/rules/engine/gate.lua:26` | Gate.run concatenates runner.check_family results over a configured list of families |
| media.nvim | `media.nvim/lua/media/hub/actions.lua:44` | TABLE keyed by kind lists action descriptors (id/label/mode/needs_text); run_batch (212) executes a list of them over entries. |
| sandbox.nvim | `sandbox.nvim/lua/sandbox/adapters/docker/engine.lua:17` | tbl_extend merges containers/images/volumes/networks/registry sub-engines into one engine object. |

### Decorator (8)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/strategies/telemetry_wrap.lua:1` | Wraps the lib aggregate and its submodules with telemetry without changing their API; soft dependency via pcall(require). |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:111` | make_wrapper replaces a function field with a counting/timing wrapper that forwards to the original with varargs; the core idea of the plugin. |
| testing.nvim | `testing.nvim/lua/testing/guard/patch.lua:33` | Patcher:wrap replaces tbl[key] with make(orig) and keeps a stack to undo in reverse order; every guard (fs, prompt, clock, process_net) wraps editor APIs through it. |
| docmap.nvim | `docmap.nvim/lua/docmap/core/check_policy.lua:155` | apply(findings, policy) re-grades or suppresses findings after all checks ran, so it also covers extra_checks. |
| ai.nvim | `ai.nvim/lua/ai/usage.lua:249` | wrap_callback / wrap_handlers (:274) wrap a callback or handler table to report usage once, then delegate; applied in init.lua:217 and :286. |
| cascade.nvim | `cascade.nvim/lua/cascade/init.lua:758` | counted_cycle(fn) captures vim.v.count1 into pending_cycle_count then calls fn, so dot-repeat replays with the same count. |
| language.nvim | `language.nvim/lua/language/translate/chunk.lua:342` | wrap(provider) returns a copy whose translate() splits oversized input into blocks and delegates to the original; transparent to callers. |
| rules-desktop | `rules-desktop/crates/rules-hub/src/bodies.rs:291` | BodiesEngine wraps Arc<dyn Engine> inner, handles Calls::Bodies itself and delegates everything else. |

### Facade (29)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/strategies/eager.lua:10` | Aggregator LIB table re-exports hundreds of submodule functions under one namespace; lazy.lua and eager.lua are two interchangeable strategies (classless Strategy via module tables). |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/init.lua:132` | Top-level setup() hides telemetry.lazy, usercmd registration and lib.nvim deps behind one entry; also runner.lua:116 M.run hides curl+format. |
| testing.nvim | `testing.nvim/lua/testing/cli.lua:838` | cli.main(argv, services) is the single entry that parses args, applies trust, loads config and delegates to run/ci/stamp/surface subsystems. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/ai/init.lua:1` | Single door to ai.nvim; send flow resolve->gates->availability->capabilities->call->audit; enforced by ai_facade_lint_spec. Classless module API. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/done_flow.lua:1` | Single entry for finishing a task (mutate.done plus plan/marker/next chain); command, dashboard and CLI all call run. |
| docmap-desktop | `docmap-desktop/src-tauri/src/main.rs:4057` | about 60 #[tauri::command] fns registered through generate_handler!; JS calls them via invoke(...). |
| filetree.nvim | `filetree.nvim/lua/filetree/util/autocmd.lua:41` | group/create/acmd wrap lib.nvim.bindings.autocmd. They give one call shape and record autocmds for health and the binding catalog. |
| filetree.nvim | `filetree.nvim/lua/filetree/commands.lua:1` | One :Filetree command routes through a TREE table to feature modules. Completion and routes derive from that table. ft() at line 28 resolves features lazily. |
| gopath.nvim | `gopath.nvim/lua/gopath/registry.lua:193` | run_language_pipeline hides the per-language resolver modules behind one call. |
| hover.nvim | `hover.nvim/lua/hover/init.lua:47` | The M API (show, hide, pin, zoom, set_mode, status...) fronts config, registry, preview/*, cache and autocmds (a 2861-line facade). |
| lsp.nvim | `lsp.nvim/lua/lsp/init.lua:488` | M.setup coordinates config, keymaps, handlers, capabilities, attach, formatter, servers and tools behind one call. |
| markdown.nvim | `markdown.nvim/lua/markdown/tables/registry.lua:133` | M.find (133), M.render (178), M.lossy (204) hide 13 format modules behind one API used by table_convert.lua:78 |
| markdown.nvim | `markdown.nvim/lua/markdown/commands/init.lua:25` | subcommand name -> run function table; M.execute (69) dispatches and feature-gates via SUBCOMMAND_FEATURES (line 8); classless Command |
| rules.nvim | `rules.nvim/lua/rules/api.lua:27` | one door `call(method, request)` with a methods table (hello/snapshot/list/rule/next_id/ops) validated by lib.nvim.contract.api |
| ai.nvim | `ai.nvim/lua/ai/init.lua:260` | M.ask / M.stream hide resolve, policy, key fetch, usage, bulk and provider dispatch behind two calls. |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/commands.lua:114` | DISPATCH subcmd->function shared by :Insert and :Copy via M._dispatch (:510); build_routes (:580) generates composer routes from it. |
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/bindings/autocmds.lua:19` | FileType autocmd sets up per-buffer highlighting and the buffer-local :Fence command; ColorScheme autocmds re-resolve highlight groups (init.lua:90). |
| data.nvim | `data.nvim/lua/data/init.lua:141` | resolve_io + deliver (:176) hide source/sink resolution and writing behind M.run/convert/filter/run_auto. |
| insights.nvim | `insights.nvim/lua/insights/scan/rg.lua:16` | build_cmd/run wrap ripgrep invocation for all scanners (imports, symbols, todos). |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/bindings/usrcmds/init.lua:135` | composer.verb route table maps subcommands to per-file executors (fetch, show, export, diff, ...); classless Command dispatch. |
| diff.nvim | `diff.nvim/lua/diff/core/init.lua:322` | execute() is the single pipeline entry (directory, image-compare, three-way, text outputs, buffer views); run() at ~750 adds arg parsing and pickers. |
| fileops.nvim | `fileops.nvim/lua/fileops/ops/file.lua:193` | notify_change() emits User FileopsChanged for any listener and reloads explorers; FileopsRetry (line 138) is a second event. |
| fileops.nvim | `fileops.nvim/lua/fileops/bindings/usrcmds.lua:633` | dispatch(subcmd, ...) routes ~20 subcommands; composer routes (915) forward into it. |
| emojis.nvim | `emojis.nvim/lua/emojis/commands.lua:199` | action_route() builds composer routes that forward() into the single execute() (91). |
| emojis.nvim | `emojis.nvim/lua/emojis/unicode/init.lua:375` | dispatch() fronts the Unicode toolkit subactions (name/search/table/digraphs). |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/core/dispatcher.lua:156` | dispatch()/open() (:360) hide resolver, cache, backend, progress and renderer behind two calls. |
| reposcope.nvim | `reposcope.nvim/lua/reposcope/providers/github/entrypoint.lua:8` | Each provider exposes one table bundling its four sub-modules. |
| ai-desktop | `ai-desktop/src/secrets.cpp:230` | store_read/write/delete_locked hide WinCred vs file backend behind one API (get/set in secrets.hpp). |
| streamtap | `streamtap/desktop/crates/streamtap-app/src/main.rs:63` | AppState wraps Inner with poison-tolerant lock; ten #[tauri::command] fns (main.rs:156 onward) are the facade for the UI; KillOnClose (jobs.rs:20) is an RAII guard for child lifetime. |

### Flyweight (1)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| media.nvim | `media.nvim/lua/media/core/dispatcher.lua:203` | inflight[key] jobs are shared; join() adds waiters and returns a cancel handle that only stops the shared run when the last waiter leaves (ref-counted shared job). |

### Proxy (1)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| pickers.nvim | `pickers.nvim/lua/pickers/engines/when_loaded.lua:64` | on_require inserts a one-shot package.searchers entry that wraps the real loader and schedules fn after the module loads. |

### Chain of Responsibility (20)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/bindings/autocmd/dispatcher/init.lua:241` | One autocmd fans out to many keyed handlers (glob keys, priorities, isolation, lazy { load = fn }); a single mediator in front of nvim autocmds. |
| testing.nvim | `testing.nvim/lua/testing/deps.lua:156` | resolve tries $<NAME>_DIR, .deps/, sibling checkout, then the lazy data dir in fixed order; the first valid one wins and all four are named on failure. |
| ui.nvim | `ui.nvim/lua/ui/vim_ui/init.lua:190` | M.select goes to confirm buttons if n<=buttons_max and they fit, then to the kit chooser if n<=chooser_max, else to the fallback_select. The fallback is also taken on passthrough kinds and when a float cannot open. The original vim.ui.select is kept as the fallback (Decorator/Proxy of the previous function). |
| gopath.nvim | `gopath.nvim/lua/gopath/resolve.lua:32` | resolve_at_cursor tries help, url, env, task-id, filetoken, linepath, language pipeline, loose url, fallback in order; the first stage that answers wins (classless, inline stages). |
| hover.nvim | `hover.nvim/lua/hover/registry.lua:148` | source_at asks each registered source in registration order; the first answer wins. |
| mdview.nvim | `mdview.nvim/lua/mdview/bindings/autocmds/enter_hub.lua:92` | register(owner, spec) with priority puts features on one BufEnter dispatcher; reset() unregisters by owner |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/adapter/init.lua:67` | resolve_first returns the first available of an ordered adapter list; features/plugins/sources.lua:26 uses AUTO = lazy, pack, clones |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/plugins/target.lua:73` | resolve tries pin, commit, tag, version, then branch in lazy.nvim's order, returning a tier-tagged result or unknown with reason |
| cascade.nvim | `cascade.nvim/lua/cascade/dispatch/init.lua:32` | dispatch.try runs an ordered handler list until one returns true, pcall-isolating each, then try_or_native falls back to the native key; used in init.lua:339/378/393/408. |
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/language_detector.lua:182` | detect_language tries fence marker, content heuristics, buffer context in priority order, returning nil for all keywords. |
| data.nvim | `data.nvim/lua/data/init.lua:669` | run_auto detects format via detect.format (fence, register, filetype, text sniff detect/init.lua:100), else asks via ask_format (kit.select / vim.ui.select). |
| media.nvim | `media.nvim/lua/media/core/resolver.lua:44` | build_chain() assembles requested/auto/fallback engine ids; resolve() (line 100) takes the first engine whose available()/ready() is true. |
| language.nvim | `language.nvim/lua/language/spell/core/collect.lua:53` | CLI_MODULES maps provider names to modules sharing available()/scan_async(); gather() (196) picks the first available provider from providers.cwd. |
| insights.nvim | `insights.nvim/lua/insights/symbols/init.lua:20` | get() chooses Treesitter+rg hybrid vs rg-only vs buffer scan from config; get_cwd_ts_lua (106) merges two sources. |
| emojis.nvim | `emojis.nvim/lua/emojis/picker.lua:140` | insert() tries try_telescope (30), then try_fzf_lua (70), then select_fallback (102), each returning true if it took over. |
| images.nvim | `images.nvim/lua/images/init.lua:98` | show() tries OSC 1337 draw, falls back to ASCII blocks when capability is missing, with remote fetch first when the path is a URL. |
| openinnvim | `openinnvim/src/Spawner.cs:143` | Wrap() returns SpawnPlan[] in order wezterm, wt, console and the caller tries them in turn; console is the guaranteed last. |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/core/resolver.lua:65` | resolve() walks build_chain (:24: requested, then config fallback_chain, then registry order) and picks the first backend whose available() is true; composer.lua:153 does the same for producers. |
| pickers.nvim | `pickers.nvim/lua/pickers/engines/init.lua:31` | Requested engine first, then telescope, fzf, snacks; try_load (:18) checks mod.available(). |
| sandbox.nvim | `sandbox.nvim/lua/sandbox/init.lua:50` | resolve_engine_name: vim.g override, then .sandboxrc, then config, then engine_utils.get_live_engine (:121) probe. |

### Command (26)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/ui/kit/history.lua:108` | History snapshots selected state keys and offers back/forward/go (jumplist-like undo stack), with history.CLEAR sentinel. |
| lib.nvim | `lua/lib/nvim/bindings/usercmd/composer/init.lua:321` | M.verb declares routes (token paths to run handlers) with typed args (register_type at :368), i.e. a command table and subcommand dispatcher. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/bindings/usrcmds.lua:1011` | composer.verb('RA') declares routes = {{path, desc, run}} as a table of command handlers; custom completer types registered at lines 62/79/114 (Strategy-ish). |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/plan.lua:115` | Scaffold actions are data records (mkdir/write/copy/skip) described by describe() and executed by apply.lua; dry-run capable. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/bindings/usrcmds.lua:936` | Declarative routes list {path,args,flags,desc,run} registered via composer.verb at :2231; trie dispatch. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/ops.lua:1371` | HANDLERS name->function and FIELDS schema per op (:143), assembled into ops registry at :1393 for the tasks-ops/1 door. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/cli.lua:950` | commands.<verb>(ctx) functions with SPECS option table at :173. |
| docmap.nvim | `docmap.nvim/lua/docmap/bindings/usrcmds/init.lua:39` | ACTIONS maps the first word of :DocMap args to a lazy thunk; dispatch() at line 350 validates the verb and has completion read from the same table (replaced an if-chain). |
| docmap.nvim | `docmap.nvim/lua/docmap/mcp/tools.lua:135` | each tool is a table {description, schema, run(handle,args)}; M.list (468) exposes them and protocol.dispatch routes JSON-RPC calls; call is pcall-wrapped at mcp/protocol.lua:177 (Result-style error containment). |
| filetree.nvim | `filetree.nvim/lua/filetree/refs/apply.lua:211` | Every apply pushes an undo token holding before/after line content onto _undo_stack. Tokens get stable ids from _next_id. Undo is content-verified. M.undo is at line 463. |
| hover.nvim | `hover.nvim/lua/hover/bindings/usrcmds.lua:148` | M.routes() builds :Hover subcommands as {path, desc, args, run} tables, extended from switches.names() (line 544) and registered via the composer. |
| lsp.nvim | `lsp.nvim/lua/lsp/bindings/usrcmds.lua:313` | dispatch(map, choice, fallback) picks a handler from an action map; switch_route (line 330) shares the toggle/on/off/status/clear behaviour for hints, lightbulb, winbar and implement. |
| mdview.nvim | `mdview.nvim/lua/mdview/adapter/ws_client.lua:411` | lane_post queues POSTs per channel+room, drops superseded or same merge_key entries, pumps one curl at a time with a stall watchdog (line 403) |
| rules.nvim | `rules.nvim/lua/rules/ops.lua:205` | new/set/retire/reinstate/move are operations; each returns an `inverse` op (e.g. line 769, 902); Tx records old bytes and rollback() (212) restores them |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/dashboard/view.lua:1703` | ROW_KEYMAPS entries {keys,label,desc,run(ctx)} drive keymaps, legend and context menu; _keymap_entry (2075) looks up by key and _context_menu_items (2111) reuses the run functions |
| ai.nvim | `ai.nvim/lua/ai/bulk.lua:235` | Per-label group with FIFO queue, head/tail indices, drain/pump (:263) and a `limit` of concurrent in-flight jobs; cancel empties the queue. |
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/commands/fence/init.lua:49` | SUBCOMMANDS name->fn(argv,ctx); execute (:100) tokenizes and dispatches, complete derives from the same table. |
| pickers.nvim | `pickers.nvim/lua/pickers/refine/init.lua:142` | Refine handle holds a filter stack plus the remembered full list; quickfix/init.lua:369 applies the stack and :396 restores. |
| recommender.nvim | `recommender.nvim/lua/recommender/bindings/usrcmds.lua:222` | execute() is the single entry point behind :Recommender; classify_pos_args (:157) classifies tokens by content. |
| replacer.nvim | `replacer.nvim/lua/replacer/history.lua:73` | add(request, result) persists each real apply; pick() (:118) replays one. |
| sandbox.nvim | `sandbox.nvim/lua/sandbox/bindings/usrcmds/init.lua:259` | container_routes, image_routes (:490), volume_routes, network_routes, compose_routes, wsl_routes... declare :Sandbox sub-commands as data. |
| appkit | `appkit/ui-kit/src/menu.ts:11` | MenuItem discriminated union with onselect closures; keymap.ts:29 withChord maps keys to command names as data. |
| tasks-desktop | `tasks-desktop/ui/src/lib/app.svelte.ts:1190` | inverseOf(result) computes the ops that take back a write; undo() (line 1289) replays them from the toast. Classless TS; no history stack, only the last write. |
| tasks-desktop | `tasks-desktop/ui/src/lib/paletteActions.ts:11` | Builds a list of {key,label,run} closures depending on current state; only possible actions are listed. |
| rules-desktop | `rules-desktop/ui/src/lib/app.svelte.ts:651` | command(Command) switch on name with palette/go/search/next/previous/open/escape; escape works as a small chain (palette, detail, selection). Undo via write notice at line 966. |
| streamtap | `streamtap/desktop/crates/streamtap-sink/src/main.rs:200` | Header enum Hello/Segment/Event decoded by serde tag; handle_connection (main.rs:809) matches (header, session) pairs as a small state machine (before hello, after hello). |

### Iterator (1)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/ui/cycle.lua:9` | Ordered `order` table of {name, show} pickers; attach() rotates to next source carrying prompt text. |

### Mediator (2)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| docmap.nvim | `docmap.nvim/lua/docmap/bindings/autocmds.lua:45` | declarative manifest of every autocmd with a why, per-root augroups (editor/registry.lua:133) give clean teardown. |
| markdown.nvim | `markdown.nvim/lua/markdown/bindings/autocmds.lua:43` | one FileType autocmd via lib dispatcher; features subscribe with on_filetype (line 76: register/unregister by owner) instead of each adding its own autocmd |

### Memento (13)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/checkpoint/init.lua:58` | create/restore/forget/discard of file checkpoints; a persistent memento. |
| testing.nvim | `testing.nvim/lua/testing/isolation/snapshot.lua:1` | capture() returns a plain-table snapshot of modules, globals, options, autocmds and keymaps; diff entries know how to restore themselves; used by the warm pool reset. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/mutate.lua:2334` | rollback_done restores from checkpoint snapshots when a multi-file done fails midway. |
| filetree.nvim | `filetree.nvim/lua/filetree/features/fileops/trash/undo.lua:56` | M.record inserts a TrashEntry at the head of _history, capped by max_history. M.restore (line 405) and restore_last (line 321) revert it, and attach_refs links it to the refs undo token. |
| ui.nvim | `ui.nvim/lua/ui/tabline/reopen.lua:152` | A ring of recently closed file buffers is kept and reopened with M.reopen(entry). |
| hover.nvim | `hover.nvim/lua/hover/persist.lua:1` | Only runtime-toggled settings are snapshotted and restored (touch/snapshot/load). |
| mdview.nvim | `mdview.nvim/src/client/render/history.ts:21` | installHistory pushes one browser history entry per document ping and reopens the document on popstate; viaPopstate flag prevents a loop |
| cascade.nvim | `cascade.nvim/lua/cascade/core/context.lua:16` | Context.new builds an immutable-ish cursor/buffer snapshot (setmetatable class) passed to every handler. |
| dap.nvim | `dap.nvim/lua/wkddap/memory/init.lua:674` | state.undo holds {ref,offset,old,new}; M.undo pops and writes old back; seq counter (:403-410) discards outdated async readMemory responses. |
| language.nvim | `language.nvim/lua/language/translate/history.lua:81` | Capped, deduped, newest-first history persisted to disk and re-pickable; closest is a recall list, not a full undo Memento. |
| replacer.nvim | `replacer.nvim/lua/replacer/checkpoint.lua:98` | create() snapshots files with a manifest, undo() (:160) restores; manifest entries are validated before use. |
| sessions.nvim | `sessions.nvim/lua/sessions/layout.lua:32` | capture() serialises the window tree and restore() (:145) rebuilds it; sidecars (meta, buforder, pins) are further mementos. |
| spotlight.nvim | `spotlight.nvim/lua/spotlight/sets.lua:153` | save/switch (:212)/delete (:226) store and restore named spotlight sets. |

### Observer (21)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/startup/init.lua:200` | Startup timeline subscribes to VimEnter, User VeryLazy, User LazyLoad and LspAttach via lib.nvim autocmd group, each stamping a mark; classless Observer. |
| testing.nvim | `testing.nvim/lua/testing/state.lua:673` | State.subscribe returns an unsubscribe closure; emit (line 684) calls subscribers under pcall so one failing listener cannot hurt the others. Classless, closure-based. |
| testing.nvim | `testing.nvim/lua/testing/hover/init.lua:425` | try_register reads package.loaded['hover.registry'] without requiring it (line 400) and retries on VimEnter or a User autocmd (lines 448-449). |
| docmap.nvim | `docmap.nvim/lua/docmap/editor/registry.lua:507` | handle.on_change(cb) appends to entry.watchers and returns an unsubscribe closure; notify_watchers (line 78) fans out and isolates subscriber errors. |
| docmap-desktop | `docmap-desktop/src/main.js:457` | document-level mouseover/focusin/focusout with a dwell timer (helpTimer, line 429) for help tooltips; Tauri 'menu' event is the other subscription. |
| ui.nvim | `ui.nvim/lua/ui/slots/store.lua:704` | on_change(fn) returns a listener id and off(id) removes it. emit() (line 93) bumps a revision and calls listeners under pcall. The views subscribe to it. |
| hover.nvim | `hover.nvim/lua/hover/bindings/autocmds.lua:143` | CursorHold/CursorMoved/BufLeave/BufWipeout autocmds per buffer, tracked in installed[] and removed by forget() (line 47). |
| lsp.nvim | `lsp.nvim/lua/lsp/core/supervisor.lua:582` | LspAttach and VimLeavePre autocmds plus on_exit feed the tracked[] table; backoff() at line 412 and max_attempts (line 496) cap retries; counters reset on survival (line 447). Circuit-breaker-like. |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/mark/init.lua:538` | BufDelete/BufWipeout clears the module-level `marked` buffer->extmark->category map (:39). |
| cascade.nvim | `cascade.nvim/lua/cascade/bindings/autocmds.lua:1` | Four idempotent autocmds bind per-filetype keys, hanging-indent options, save-time renumber and strings conversion. |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/core/tracker.lua:49` | One CmdlineLeave autocmd fans out to project_history, stats and errors via vim.schedule (:66). |
| dap.nvim | `dap.nvim/lua/wkddap/memory/init.lua:526` | attach_listeners subscribes END_EVENTS and REFRESH_EVENTS under key 'wkddap.memory'; detach_listeners (:511) removes them. |
| debugging.nvim | `debugging.nvim/lua/debugging/terminals/keylogger.lua:110` | on_key callback registered at :180 under a namespace, removed at :199; work deferred with vim.schedule. |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/background.lua:81` | start() runs run_cycle on a uv timer, and run_cycle (22) chains digest refresh, repo discovery, then fetch. |
| fileops.nvim | `fileops.nvim/lua/fileops/features/on_hold.lua:34` | augroup(name) creates a replaceable group per concern; setup (341) wires CursorHold-style events and a one-shot cleanup autocmd (~line 472). |
| my.nvim | `my.nvim/lua/my/config/core/observer.lua:25` | Classless observer: on_after_set(ns, fn) with identity de-dup, trigger() at :47 fans out under pcall; hl_config/init.lua:285 and persist subscribe. |
| recommender.nvim | `recommender.nvim/lua/recommender/float/autocmds.lua:160` | WinClosed and FileType autocmds drive float cleanup. |
| sandbox.nvim | `sandbox.nvim/lua/sandbox/ui/list_actions.lua:483` | setup_autorefresh runs a per-buffer uv timer guarded by a buffer-local flag. |
| spotlight.nvim | `spotlight.nvim/lua/spotlight/core/registry.lua:40` | on_change(fn) with notify_change (:52) calling each listener under pcall; persistence subscribes. |
| appkit | `appkit/crates/appkit-hub/src/search.rs:512` | spawn_indexer subscribes quietly to the store and applies each Change, rebuilding on Lagged. |
| ai-desktop | `ai-desktop/src/anthropic_client.hpp:30` | Each backend client's ask_stream takes std::function on_delta; main.cpp passes the same callback to every backend. |

### State (8)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| docmap-desktop | `docmap-desktop/src-tauri/src/main.rs:1283` | CloneTarget {Existing, Clone} decides the import path before cloning; LinkWalk (3097), search::Mode (search.rs:53), stats::Kind (stats.rs:58) are similar sum types. |
| hover.nvim | `hover.nvim/lua/hover/preview/playback.lua:82` | A single playback state table (playing, clock_pos, gen, timer) with generation guards on async audio callbacks. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/env_links.lua:990` | block_step advances an explicit LspNvim.EnvLink.Blocks state (lists, comment, fence) line by line (new_blocks at 951). |
| markdown.nvim | `markdown.nvim/lua/markdown/core/render.lua:242` | scan_fences walks lines with comment/math/fence state and tags each row with a role (open/in/close/cstart/mstart...); implemented with booleans, not objects |
| rules.nvim | `rules.nvim/lua/rules/engine/verdicts.lua:461` | stale() is a pure comparison of verdict date and evidence against git changes passed in; accept (408) is the only writer |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/dashboard/repo_state.lua:61` | phases pending/fetching/done/failed per repo, try_lock/unlock by path, generation counter (line 53, begin_bulk at 86) invalidates callbacks of a superseded bulk |
| appkit | `appkit/ui-kit/src/session.svelte.ts:97` | StreamSession follows the SSE stream, reconnects with growing delay; StreamDeps (line 82) injects fetch, sleep and callbacks. Connection state is the union 'live'/'reconnecting'/'offline'. |
| tasks-desktop | `tasks-desktop/crates/tasks-hub/src/server/check.rs:9` | CheckJob Idle/Running/Done/Failed with to_json; one check at a time, dropped with the vault. |

### Strategy (32)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/curl.lua:107` | VALUE_FLAGS maps curl flag to a kind, then a switch applies it (see candidate); at least the flag classification is table-driven. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/report_style.lua:21` | resolve() picks a renderer (kit/preview-tab/mdview/file/html) based on availability, falling back down the chain; renderers live in telemetry/renderers/. |
| testing.nvim | `testing.nvim/lua/testing/isolation/init.lua:54` | M.backend() picks the guard layer's soft_backend when it validates, else the internal snapshot backend; capture/diff/restore is the shared interface. |
| docmap.nvim | `docmap.nvim/lua/docmap/core/check.lua:71` | M.NEEDS maps a check to the backend capability it needs (module_tag, param_docs); checks consult the backend instead of switching on language. |
| filetree.nvim | `filetree.nvim/lua/filetree/features/fileops/trash/platform.lua:404` | M.send picks trash_wsl, trash_windows, trash_mac or trash_linux. Each has a batch variant (send_batch, line 425), all behind a common send(path, cb) shape. |
| ui.nvim | `ui.nvim/lua/ui/context/init.lua:1330` | draw() picks draw_chips or draw_mimic by cfg.style. This is a two-way if/else, a hard-wired Strategy. |
| gopath.nvim | `gopath.nvim/lua/gopath/open/init.lua:20` | PLACEMENT maps open mode (edit/window/vsplit/tab) to a window-creating function. |
| hover.nvim | `hover.nvim/lua/hover/registry.lua:168` | preview_for(target_type) returns the registered previewer, which build() in init.lua:632 tries before the built-ins. |
| rules.nvim | `rules.nvim/lua/rules/engine/checks/init.lua:21` | BY_TYPE maps grep/file_exists/json_key_absent/lua_predicate to impl.run; unknown type becomes an error result |
| ai.nvim | `ai.nvim/lua/ai/@types/init.lua:198` | Ai.Provider {available, ask, stream, capabilities} is the strategy contract; claude/openai/gemini/ollama/copilot/claude_cli implement it (classless duck typing). |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/commands.lua:69` | sink 'clip' vs 'insert' chooses the delivery behavior of every handler (sink_text/sink_lines). |
| cascade.nvim | `cascade.nvim/lua/cascade/strings/init.lua:459` | converter_for(ft) returns template_string / python_fstring / lua_format function by feature + filetype config. |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/ui/picker_utils.lua:161` | open_picker picks Telescope or fzf-lua from config; previewers (telescope-previewer, fzf-previewer) adapt the same preview_policy. |
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/parser.lua:180` | find_ascii_blocks picks comment_ascii, treesitter parser_ts or heuristic scanner and falls back on error; highlighter.lua:213 does the same for the optional TS pass. |
| dap.nvim | `dap.nvim/lua/wkddap/ui/provider.lua:53` | resolve(preference) picks provider with auto/fallback; setup (:102) loads ui/dapview or ui/dapui implementing the same setup(opts) contract. |
| data.nvim | `data.nvim/lua/data/format/json.lua:43` | Each format module provides decode/render with the same shape; data.init run/convert/filter are format-agnostic over it. |
| debugging.nvim | `debugging.nvim/lua/debugging/views/capture/init.lua:291` | capture_messages_raw tries noice, execute, exec2 in order and aggregates failures. |
| debugging.nvim | `debugging.nvim/lua/debugging/views/recent.lua:24` | FILTER_LEVELS / FILTER_TAG / FILTER_TITLE keyed by filter name instead of if-chains. |
| media.nvim | `media.nvim/lua/media/output/init.lua:26` | SUBTITLES maps mode to a writer module exposing path()/serialize(); deliver() at line 84 dispatches through it (third format = one line). |
| diff.nvim | `diff.nvim/lua/diff/features/diffopt_profile/profiles.lua:14` | Named diffopt profiles as full replacement values; init.lua:26/38 get/set apply one. |
| emojis.nvim | `emojis.nvim/lua/emojis/core/ops.lua:78` | clear/replace/unreplace/wrap are pure lines-to-(lines,count) transforms chosen by action in actions.edit (88). |
| images.nvim | `images.nvim/lua/images/screenshot.lua:84` | capture_mac/capture_linux/capture_windows selected inside capture() by platform checks. |
| my.nvim | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/base.lua:27` | Dynamic require of ctx.lang.<ft> (lua.lua, javascript.lua) selects the language strategy; not a class, just a module convention. |
| my.nvim | `my.nvim/lua/my/guicursor_profile/selector.lua:11` | Preset name looked up in a profiles table and applied; unknown name raises. |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/core/dispatcher.lua:396` | registry.get_renderer(mode) picks buffer, float, system or terminal rendering; failures are isolated with pcall. |
| recommender.nvim | `recommender.nvim/lua/recommender/bindings/usrcmds.lua:53` | ANALYZER_NAMES (regex, treesitter, javascript, python, perf) all expose analyze(threshold, aliases, blacklist, lines); get_analyzer (:130) lazy-requires and memoizes (:123). |
| replacer.nvim | `replacer.nvim/lua/replacer/rg.lua:755` | pick_backend chooses ripgrep or vimgrep; collect (:899), collect_async (:930) and collect_streaming (:975) branch on it; post_filter (:884) composes the line-range, word-boundary and code-only filters. |
| reposcope.nvim | `reposcope.nvim/lua/reposcope/network/clients/http_client.lua:87` | curl, gh and wget modules under request_tools/ share request(); selected by if-chain; auth header built per provider/tool at :32. |
| sessions.nvim | `sessions.nvim/lua/sessions/picker.lua:275` | pick() tries pick_snacks (:117), then pick_telescope (:190), else errors. |
| tasks-desktop | `tasks-desktop/crates/tasks-hub/src/editor.rs:20` | FileOpener trait (open/reveal/pick_folder) with TerminalOpener (editor.rs:215); pure plan() functions take os and a `find` closure so they test without spawning. |
| ai-desktop | `ai-desktop/src/models.cpp:168` | models::resolve() maps a model id to a Route (custom model first, then configurable prefixes, else Ollama); main.cpp:69 route_ask dispatches on route.provider. Classless C++, string-keyed. |
| takt | `takt/crates/takt-clock/src/lib.rs:62` | Clock trait with AudioMasterClock, WallClock, TimelineClock; ClockKind (lib.rs:49) tags the mode and may_drop encodes policy differences. |

### Template Method (12)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/lua/class/init.lua:45` | make_class with __index inheritance, init hook, extend and mixin include; used by async Semaphore/Condvar/LatestWins. |
| lib.nvim | `lua/lib/lua/context_manager/init.lua:49` | with(acquire, release, body) guarantees release around the body; a bracket pattern. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/runner.lua:84` | format_response shared by blocking M.run and async M.run_async; only the fetch step differs. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/ai/confirm.lua:1` | Serialising confirmation on lib dialog.ask with vim.ui.select fallback; a Facade over the dialog with degrade path. |
| ui.nvim | `ui.nvim/lua/ui/slots/kinds/lua.lua:32` | The slot context is a table with an __index function that resolves placeholders on demand. file.lua:148 and expand.lua:94 do the same, layering on a base context (prototype-style delegation). |
| lsp.nvim | `lsp.nvim/lua/lsp/init.lua:68` | step(label, fn) runs each bootstrap phase in pcall and records failures in _warnings; try_module (line 93) does the same for optional modules. |
| rules.nvim | `rules.nvim/lua/rules/ops.lua:1439` | lib.nvim.contract.ops door is configured with an ops table, context() and finish() hooks (line 1467, rebuild catalog once after all ops) |
| cascade.nvim | `cascade.nvim/lua/cascade/init.lua:858` | block_work and visual_work (:878) wrap a transform fn with the shared gating (enable, writable, filetype, feature) and range resolution. |
| dap.nvim | `dap.nvim/lua/wkddap/languages/rust.lua:76` | Each language module exposes setup() (adapter) and load() (configurations), driven by adapters/init.lua:22 and configurations/init.lua:18; contract_spec tests it. |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/export.lua:333` | Each report has build_*_lines() then a write_lines wrapper and a create_pdf wrapper; shape is shared but repeated four times. |
| images.nvim | `images.nvim/lua/images/convert.lua:293` | run_magick() is the shared run-to-temp, validate, atomic-rename template used by resize, crop, optimise, convert, redact. |
| sessions.nvim | `sessions.nvim/lua/sessions/util/sidecar.lua:21` | One write path for meta, buforder and pins; a stale sidecar is removed on failure. |

### Registry (47)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/registry/init.lua:53` | Registry class with register/unregister/get/find/validate/loader (class-based, metatable). |
| lib.nvim | `lua/lib/nvim/bindings/usercmd/composer/registry.lua:9` | Composer verbs kept in a lib.nvim.registry instance, giving stable ordering for generated docs. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:285` | attach() keeps one site per (container, field) in a weak-keyed table (line 34) so several instances share one wrapper; restored when last subscriber detaches. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:34` | sites = setmetatable({}, {__mode='k'}) as the global bookkeeping registry; also instances list in telemetry/init.lua:90 with M.get/M.instances (1252-1258). |
| testing.nvim | `testing.nvim/lua/testing/report/init.lua:16` | REPORTERS name->module map; resolve (line 38) does pcall(require) so term/github/junit/agent are interchangeable render(result, opts) strategies. |
| testing.nvim | `testing.nvim/lua/testing/guard/init.lua:107` | GUARD_MODULES + config.ORDER; the install loop at line 221 builds each guard with require(...).new(h, gcfg) and rolls back all on failure. |
| testing.nvim | `testing.nvim/lua/testing/dialect/harness_conventions.lua:182` | M.register(convention) appends to CONVENTIONS; each convention supplies optional hooks (classify, fail_line, counters) that are resolved into one adapter. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/bindings/usrcmds.lua:119` | composer.register_type('CASE', ...) and 'BLOCK' at :188 plug custom arg types (validate/complete) into the composer. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/ui/routes.lua:227` | register_types registers TASK_AREA, TASK_ID, TASK_QUERY etc with validate/complete; idempotent register() in bindings/usrcmds/init.lua:16. |
| docmap.nvim | `docmap.nvim/lua/docmap/editor/registry.lua:22` | module-local table keyed by normalised root holds one entry per repo; install/get return the same handle (Repository-like in-memory store of IR). |
| docmap.nvim | `docmap.nvim/lua/docmap/core/api.lua:450` | M.routes table maps route name to handler; looked up at line 500. |
| filetree.nvim | `filetree.nvim/lua/filetree/adapter/init.lua:17` | M.register keeps name->adapter in _registry. neotree/nvimtree/netrw/oil/mini_files each implement the FiletreeAdapter interface (is_available etc.) and self-register (oil.lua:358). Classless: modules act as adapters. |
| filetree.nvim | `filetree.nvim/lua/filetree/refs/registry.lua:26` | Providers (lua, markdown, python, ts_js, plaintext) supply plan/extract/retarget functions. Third parties register through the same contract. enabled() filters via cfg flags. |
| ui.nvim | `ui.nvim/lua/ui/tabline/styles.lua:92` | register/unregister map a name to a chip-boundary decorator function. cfg.style resolves through it, so hosts can add styles without patching. Old names stay as aliases. |
| ui.nvim | `ui.nvim/lua/ui/config/variants.lua:44` | register/unregister/list for statusline variants. Same shape as tabline.styles, and :UI variant completes over list(). |
| ui.nvim | `ui.nvim/lua/ui/statusline/utils/clickable.lua:58` | register(handlers) returns an integer id that the statusline %@ click protocol resolves via the UiSlClick global. render.lua:~45 caches one id per key (generic_click_id), so the registry does not grow on every redraw. |
| ui.nvim | `ui.nvim/lua/ui/statusline/catalog.lua:1` | A plain data list of segments (key, source, requires, used_by, essential, live). render.lua:221 pcall-requires entry.source on demand. The order/modules walk is a Pipeline-style composition. |
| gopath.nvim | `gopath.nvim/lua/gopath/registry.lua:113` | PIPELINE maps provider name (lsp/treesitter/builtin) to a handler function; RES (line 21) maps filetype to resolver modules; BUILTIN_ORDER (line 51) gives the order. |
| hover.nvim | `hover.nvim/lua/hover/registry.lua:96` | Plugins register ordered sources/positions and one preview per target type; re-registering the same name replaces its entry, so setup() is idempotent. |
| lsp.nvim | `lsp.nvim/lua/lsp/integrations/init.lua:32` | ADAPTERS names the optional-plugin adapters; load_all pcall-requires them and capability_contributors (line 107) and attach_hooks (line 123) collect their hooks. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/registry.lua:25` | setup_all resolves server names to lsp.servers.* (or webdev.*) modules and returns enabled names and warnings. |
| rules.nvim | `rules.nvim/lua/rules/ui/vault_routes.lua:116` | register_types registers RULES_VAULT_TARGET/PART with composer argtypes; routes.lua:117 expires_kv uses an __index metatable so help text is read lazily |
| rules.nvim | `rules.nvim/lua/rules/util/sandbox.lua:40` | created_here = setmetatable({}, { __mode = 'k' }) tracks sandboxes without keeping them alive |
| ai.nvim | `ai.nvim/lua/ai/providers/init.lua:91` | `registered` id->provider table with register/get/ids; last registration wins, so users can replace built-ins. |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/format/init.lua:35` | register_subcommand fills a name->{handler,complete,desc} table that composer turns into the :Format command. |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/mark/init.lua:39` | marked/categories (:87) tables live in the module closure with add/remove/clear accessors. |
| cascade.nvim | `cascade.nvim/lua/cascade/util/dotrepeat.lua:26` | repeatable(key, fn) stores actions in `store` and replays the last via operatorfunc g@. |
| dap.nvim | `dap.nvim/lua/wkddap/registry.lua:40` | register(language) resolves aliases, validates, pcall-requires wkddap.languages.<x> and calls its setup(); _registered/_enabled track state. |
| debugging.nvim | `debugging.nvim/lua/debugging/commands.lua:50` | build_registry (lazy, cached at :333) maps category->{feature,actions,run{}}; dispatch (:427) handles feature flags and __default free-form handlers. |
| debugging.nvim | `debugging.nvim/lua/debugging/config/KEYMAP_ACTIONS.lua:12` | One action list read by config schema and bindings/keymaps.lua:48 so spec and schema cannot drift. |
| media.nvim | `media.nvim/lua/media/core/registry.lua:20` | Engine registry (register/unregister/get/all, idempotent, insertion-ordered); engines are tables with id/available/transcribe, so duck-typed Strategies. |
| language.nvim | `language.nvim/lua/language/translate/providers/registry.lua:21` | PROVIDERS table of translate engines each wrapped once by chunk.wrap(); resolve() (line 40) walks engine then fallback chain. |
| insights.nvim | `insights.nvim/lua/insights/imports/langs/init.lua:13` | registry/order/tags tables of ImportLang modules sharing scan_source/is_external/rg_prefilter; consumers in imports/init.lua:171 iterate by order. |
| insights.nvim | `insights.nvim/lua/insights/symbols/patterns.lua:13` | PATTERNS table plus get_patterns(enabled) filter; a data-driven rule list. |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/api.lua:17` | ENDPOINTS maps metric name to request path template used by build_path. |
| diff.nvim | `diff.nvim/lua/diff/core/scratch.lua:49` | track/discard/cleanup_all/wipe_on_exit manage the lifetime of scratch buffers, an idempotent resource registry. |
| images.nvim | `images.nvim/lua/images/zen.lua:91` | views[win] table plus alive()/active() accessors holds per-window zen state (zoom, selection). |
| open.nvim | `open.nvim/lua/open/registry.lua:13` | Handler registry _handlers; register() at :22 validates the shape, dispatch() at :88 runs handler.run under pcall and returns (ok, err); keymaps/completion read the live registry (keymaps.lua:61). |
| open.nvim | `open.nvim/lua/open/bindings/usrcmds.lua:65` | composer.register_type registers OPEN_TARGET, OPEN_SCOPE, VIEWER_SCOPE and VIEWER_KIND completion types (live handler keys). |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/core/registry.lua:17` | register_backend (:17), register_producer (:69) and register_renderer (:122) keep insertion order and O(1) lookup. |
| pickers.nvim | `pickers.nvim/lua/pickers/builtins/init.lua:69` | M.REGISTRY name -> {engine = impl}; names() (:475), supported_engines() (:487) and run() (:503) query it; ENGINE_MODULE (:458) maps engine to native module. |
| reposcope.nvim | `reposcope.nvim/lua/reposcope/state/requests_state.lua:16` | register/start/end_request by UUID; api_client dedupes by UUID. |
| terminal.nvim | `terminal.nvim/lua/terminal/core/registry.lua:24` | Registry.new() returns a metatable instance (add/get/find/find_by_buf); no module-level state. |
| appkit | `appkit/crates/appkit-hub/src/engine/method.rs:7` | MethodSpec const table with read/bare/write/aside constructors; Method is a handle into the app's table, never built from a string. |
| tasks-desktop | `tasks-desktop/crates/tasks-hub/src/server/mod.rs:235` | app_routes builds the axum Router from named IDENTITY routes. |
| rules-desktop | `rules-desktop/crates/rules-hub/src/routes.rs:35` | ROUTES: &[(&str, MakeRoute)] is the one list; app_routes (routes.rs:55) folds it into the Router and DATA_ROUTES (lib.rs:95, LazyLock) feeds the security matrix from the same table. |
| streamtap | `streamtap/desktop/crates/streamtap-sink/src/proc.rs:46` | Tool enum is the closed verb set; Tools.program(tool) (proc.rs:116) resolves path overrides so tests substitute binaries. |

### Dependency Injection (15)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/env.lua:183` | M.select defaults to vim.ui.select but is replaceable by specs; M.choose uses it at line 191. Also soft deps injected via pcall(require) (health.lua:104). |
| testing.nvim | `testing.nvim/lua/testing/run/pool.lua:115` | self.opts.rpc or require('testing.rpc'): the RPC layer is injectable for specs. Similar: cli.main(argv, services) with services.trust (cli.lua:838) and watch opts.clock. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/ui/dash_watch.lua:262` | opts.start/schedule/now defaulted then injectable; also ci.lua run_lint, and M.select_task/M.select overrides at ui/cmd.lua:2244. |
| filetree.nvim | `filetree.nvim/lua/filetree/features/init.lua:25` | The FEATURES table maps name->{mod,category}. init.lua:152-164 loops it, pcall-requires each module and calls feat_mod.setup(fcfg, adapter), which injects the adapter. Failures are isolated per feature. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/attach.lua:31` | build(opts.hooks) receives on_attach/on_init hook lists from lsp.init instead of requiring plugins; the registry passes a shared table into each server's setup. |
| rules.nvim | `rules.nvim/lua/rules/ui/vault_cmd.lua:117` | M.select overrides vim.ui.select for specs; agent.lua:341 does the same with opts.ask or M.transport falling back to ai.ask |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/plugins/report_ui/preview.lua:108` | loader factory takes injectable run, partial and defer; put() (133) evicts oldest beyond CACHE_MAX; error entries expire via until_ms |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/plugins/sources.lua:173` | M.select or vim.ui.select lets specs replace the pick |
| openinnvim | `openinnvim/src/Program.cs:17` | Hooks is built from OPEN_IN_NVIM_* env vars and passed into Discovery.Find, Spawner.Start and Chooser.Pick, so tests control dry-run, pick index, PATH refresh and pid limits. |
| replacer.nvim | `replacer.nvim/lua/replacer/history.lua:156` | history, presets (:174), batch (:239), surround (:431) and command (:712) each register(run_fun) so they never require init back (no cycle). |
| terminal.nvim | `terminal.nvim/lua/terminal/backends/tmux.lua:96` | native, tmux and wezterm (wezterm.lua:95) all build a Terminal.Backend (spawn, send, probe, focus, capture, list, close); tmux/wezterm take an injectable runner (default_runner :63) so specs run without a real multiplexer. |
| appkit | `appkit/crates/appkit-hub/src/engine/mod.rs:135` | Engine trait with CliEngine (cli.rs:503) and host-backed impls; hub, search and store only hold Arc<dyn Engine>, tests plug in fakes. |
| appkit | `appkit/crates/appkit-core/src/authn.rs:20` | Clock trait with SystemClock/ManualClock; same style: Registry trait over reg.exe (appkit-hub/src/background.rs:302), setup Io trait (setup.rs:36), VaultAdmin<T> (vaults.rs:27). |
| rules-desktop | `rules-desktop/crates/rules-hub/src/locate.rs:23` | Locate trait with ProcessLocator (locate.rs:108); routes depend on the trait. |
| takt | `takt/crates/takt-clock/src/anchor.rs:49` | MonotonicSource trait with SystemMonotonic and ManualMonotonic, injected as Arc<dyn MonotonicSource> into every clock for deterministic tests. |

### Event Bus (10)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/hooks/init.lua:146` | hooks.new() builds an event registry with on/off/run, priorities and vetoable events; on() returns an unsubscribe function. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:89` | dispatch() fans one wrapped call out to every subscribed telemetry instance (site.subs), each recording via inst._record. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/tabgroup.lua:536` | Emits User CasedeskTabgroupChanged so the tab group knows no reader; pin.lua:261 subscribes. |
| filetree.nvim | `filetree.nvim/lua/filetree/features/infra/hooks_api/init.lua:71` | on/once/off/emit with handler ids and an event->ids index. Copies the id list before iterating so removals mid-emit are safe. The header comment says no emit() calls exist yet. |
| mdview.nvim | `mdview.nvim/lua/mdview/bindings/autocmds/init.lua:22` | teardown() clears the augroup and resets each subscriber; attach() wires bufenter, live_push, scroll_sync, selection_sync into one group |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/events.lua:18` | branch_switched, conflicts_resolved, plugins_reported, status_changed fire User autocmds (e.g. line 52) with typed payloads so consumers need no direct require |
| sessions.nvim | `sessions.nvim/lua/sessions/core.lua:459` | announce (SessionsSavePost/LoadPost) and announce_file (:473; Rename/Delete) fire User autocmds with data, any number of listeners, failures isolated. |
| spotlight.nvim | `spotlight.nvim/lua/spotlight/core/events.lua:97` | changed() merges reasons into one pending payload and flushes one User SpotlightChanged per tick via vim.schedule. |
| terminal.nvim | `terminal.nvim/lua/terminal/events.lua:23` | fire() emits TerminalCommandPost and TerminalExitPost via nvim_exec_autocmds. |
| appkit | `appkit/crates/appkit-hub/src/store.rs:211` | SnapshotStore publishes Arc<Change> on a broadcast channel; subscribe (store.rs:396) and subscribe_quiet (store.rs:240) for listeners, with listener counting so no scan runs for nobody. |

### Middleware/Pipeline (13)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| testing.nvim | `testing.nvim/lua/testing/conformance/catalog.lua:14` | ORDER lists k01..k16 check modules that share a Ctx and run through one runner; checks/common.lua holds shared steps. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/ai/init.lua:626` | M.send runs ordered steps (provider, policy, confirm, caps, call, audit) with a cancellable handle; ordered pipeline in one function. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/ci.lua:1` | Ordered steps check, index --check, md_lint with injectable run_lint. |
| docmap.nvim | `docmap.nvim/lua/docmap/core/check.lua:2341` | M.run sequentially applies ~24 check functions into one findings list, then opts.extra_checks (line 2369), then check_policy.apply grades findings, then sorts. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/capabilities.lua:36` | get() folds ordered contributor functions over the base capabilities, each in pcall, collecting warnings. |
| mdview.nvim | `mdview.nvim/lua/mdview/core/mirror.lua:75` | M.lines/lines_for_path are the single read entry for preview text, so a display transform hooks in once; a guard spec enforces it |
| mdview.nvim | `mdview.nvim/lua/mdview/core/display.lua:772` | M.stream feeds text through an optional browser.transform hook or language.nvim engine; per-room generation counter discards stale results (line 51 Room) |
| fileops.nvim | `fileops.nvim/lua/fileops/ops/bulk.lua:65` | Bulk rename is a staged pure pipeline: plan (65), analyze (205), select (274), order (353), execute (410) with temp-name cycle breaking. |
| my.nvim | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/init.lua:192` | _build_context walks configurable providers_order (lsp_symbols, ts_symbol, lang_extra, word); first non-empty result wins, disabled or failing providers are skipped. |
| openinnvim | `openinnvim/src/Config.cs:64` | Parse() switches over known keys; Choice (:103) and Flag (:114) validate and fall back to a default, recording a note instead of failing. |
| pickers.nvim | `pickers.nvim/lua/pickers/engines/patcher.lua:107` | Contributors (CONTRIBUTORS at :46) return functions over the engine's current config; run() merges all contributions, applies them once per engine; entry_actions/patch.lua:34 keeps host entries first. |
| replacer.nvim | `replacer.nvim/lua/replacer/hooks.lua:22` | Four events (before/after apply/write) on lib.nvim.hooks; before_apply may veto a file; on() at :42, run() at :66. |
| appkit | `appkit/crates/appkit-hub/src/guard.rs:181` | judge() runs eight ordered request checks (host, size, origin, fetch-site, limits, credential, content type) and short-circuits with an error response; classify() at guard.rs:110 picks the Class. |

### Repository (5)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| docmap-desktop | `docmap-desktop/src-tauri/src/main.rs:594` | with_workspace holds WORKSPACE_LOCK (line 588) across read_workspace, closure mutation, write_workspace; every mutating command goes through it. |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/core/store.lua:46` | load_json/save_json with validate and .corrupt backup is the shared storage layer for history, stats, errors, tags, favorites. |
| spotlight.nvim | `spotlight.nvim/lua/spotlight/core/registry.lua:551` | The registry is the item store (add, find_by_text, find_at); snapshot() and restore() (:491) serialise it, restore bypasses listeners. |
| appkit | `appkit/ui-kit/src/cache.ts:14` | CacheStore<T> load/save/clear interface with an IndexedDB implementation (cache.ts:47); tests use a fake. Classless TS. |
| ai-desktop | `ai-desktop/src/usage.hpp:101` | usage::Store append/read_all/query over usage.jsonl with a Filter; one process-wide write mutex (usage.cpp:21). |

### Lazy Initialization (29)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/strategies/lazy.lua:15` | lazy_module returns a setmetatable proxy whose __index/__call require the module on first access. |
| lib.nvim | `lua/lib/lua/lazy/init.lua:54` | LAZY.fn requires the target on first call and rebinds the wrapper to the real function. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/startup/init.lua:155` | get_lazy_cfg() requires lazy.core.config on first use and memoizes the result (or false) in lazy_cfg, since lazy may not be on rtp early; telemetry/command.lua:244 telemetry() also defers require. |
| testing.nvim | `testing.nvim/lua/testing/dialect/init.lua:89` | LOADERS table maps dialect name to a lazy loader returning run_file; M.get (line 123) resolves, M.run_file (line 139) dispatches; unknown name becomes a visible error case. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/wordings.lua:30` | setmetatable __index forwards to the live require('casedesk.config'), so a reloaded config is seen. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/init.lua:96` | setmetatable __index requires submodules on first access and rawsets them; facade plus lazy load. |
| docmap.nvim | `docmap.nvim/lua/docmap/core/lang_registry.lua:119` | registry.new with a lazy loader; each language backend (core/lang/*.lua) self-registers and the scan walk asks for_file() (line 211) who handles a filename; backends are interchangeable strategies. |
| docmap.nvim | `docmap.nvim/lua/docmap/init.lua:253` | M.browse/diff/cli/history/testing/generate_all are empty tables with __index requiring the real module on first access; init.lua is a single public facade. Classless (metatable proxy). |
| docmap-desktop | `docmap-desktop/src-tauri/src/main.rs:2713` | CACHE_ROOT OnceLock caches nvim stdpath(cache) from a subprocess; also server.rs:78 CURRENT Mutex<Option<Server>> is a one-server singleton slot. |
| filetree.nvim | `filetree.nvim/lua/filetree/adapter/init.lua:31` | resolve() pcall-requires adapter modules on demand. The 'auto' path (line 51) tries candidates in priority order until is_available() is true. |
| ui.nvim | `ui.nvim/lua/ui/slots/kinds/registry.lua:80` | Kinds are tables with apply/validate/render/preview/persist, validated by check_kind. Built-ins load lazily via ensure_builtins (line 41). Hosts add kinds through register() or setup({kinds=...}). |
| ui.nvim | `ui.nvim/lua/ui/health.lua:39` | A setmetatable proxy forwards to vim.health at call time so tests can stub it. menu/icons.lua:38 uses the same trick to resolve nerd-font glyphs lazily. |
| hover.nvim | `hover.nvim/lua/hover/cache.lua:29` | The store is built on first use, not at load. |
| lsp.nvim | `lsp.nvim/lua/lsp/usercmds/init.lua:14` | A table of start/stop/restart/info thunks that lazily require the command modules. |
| markdown.nvim | `markdown.nvim/lua/markdown/tables/registry.lua:23` | BUILTIN name list plus M.get (line 44) lazily pcall-requires markdown.tables.formats.<name> and memoizes it; each format module implements scan/parse/render/lossy (Strategy by duck typing) |
| markdown.nvim | `markdown.nvim/lua/markdown/commands/table_list.lua:99` | setmetatable on a picker item whose __index renders the table source only when the preview reads it |
| mdview.nvim | `mdview.nvim/lua/mdview/core/session.lua:38` | entry_mt.__index computes and rawsets the sha256 hash on first read |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/adapter/init.lua:20` | _registry plus register/resolve load adapters on demand by pcall-require; is_available() reads package.loaded only; Adapter interface in @types/init.lua:103 |
| ai.nvim | `ai.nvim/lua/ai/providers/init.lua:40` | make_lazy returns a setmetatable __index proxy that pcall-requires the provider module on first field access. |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/ops/boilerplate/init.lua:23` | REGISTRY entries name module+fn; M.get (:189) pcall-requires the template module only on demand. |
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/scheme_loader.lua:11` | AVAILABLE_SCHEMES name->module path, load_scheme (:28) pcall-requires on demand with validation. |
| data.nvim | `data.nvim/lua/data/format/init.lua:15` | try_register pcall-requires json/yaml/xml formatters so a missing dep only disables its own format; get(name) at :31. |
| media.nvim | `media.nvim/lua/media/engines/init.lua:25` | load_all() runs once behind a _loaded flag and pcall(require)s each built-in engine; also lazy-resolved images.nvim is_image in hub/kinds.lua:79. |
| diff.nvim | `diff.nvim/lua/diff/features/gitsigns_peek.lua:46` | gitsigns is require()d on keypress, not at setup, to avoid forcing a lazy load. |
| my.nvim | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/init.lua:46` | get_provider() pcall-requires providers by name, memoizes failure as false, and maps the legacy alias lsp_func to lsp_symbols. |
| open.nvim | `open.nvim/lua/open/init.lua:26` | HANDLER_MODULES maps keys to require paths; handlers are only required when configured (used at :101); each handler module exposes register_all(register_fn). |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/backends/init.lua:30` | make_lazy_backend returns a setmetatable proxy (:47) that requires the real backend on first field access; producers/init.lua:47 does the same. |
| sessions.nvim | `sessions.nvim/lua/sessions/chip.lua:201` | ensure_mounted() mounts the chip on first use; schedule_hide (:177) uses a generation counter to drop stale timers. |
| terminal.nvim | `terminal.nvim/lua/terminal/init.lua:122` | multiplexer(name) validates against backends.MULTIPLEXERS, probes available(), caches the instance and remembers unavailability reasons. |

### Null Object (11)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/lua/null/init.lua:19` | Shared NULL sentinel (setmetatable({})) used by json/yaml/xml to represent explicit null, distinct from nil; strictly a sentinel more than a behavioural null object. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/runner.lua:116` | M.run returns (lines, err, meta) Result-style tuple instead of throwing; run_async delivers the same through a callback scheduled onto the main loop (154-170). |
| testing.nvim | `testing.nvim/lua/testing/guard/init.lua:38` | M.CANCEL is a unique sentinel table with __tostring that stands for a cancelled prompt, distinct from nil or an empty string. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/mutate.lua:39` | M.REMOVE sentinel marks field removal in patches (distinguishes from nil). |
| ui.nvim | `ui.nvim/lua/ui/slots/kinds/registry.lua:196` | M.apply validates the slot, builds the context, then pcalls kind.apply. It turns errors into false,err so one bad kind cannot break a view. render() (line 215) falls back for an unregistered kind. |
| gopath.nvim | `gopath.nvim/lua/gopath/util/filetree.lua:11` | Returns filetree.nvim's adapter or nil; used by create.lua and open so there is one pcall(require) seam instead of two copies. |
| markdown.nvim | `markdown.nvim/lua/markdown/commands/export.lua:17` | pdfport() wraps pcall(require) and returns nil when absent; export/image commands are thin delegators to pdfport.nvim / images.nvim |
| media.nvim | `media.nvim/lua/media/hub/text.lua:148` | M.tool() returns a uniform {ok,tool,reason,fix} descriptor, including an explicit not-ok object for unknown kinds instead of nil. |
| openinnvim | `openinnvim/src/Log.cs:14` | Static Log buffers lines in memory; when Init gets no path pending stays null and Line() is a no-op (:28), so call sites never check. |
| appkit | `appkit/crates/appkit-hub/src/config.rs:58` | AppSettings trait has a default validate() and NoSettings (config.rs:74) is the empty implementation for apps without settings. |
| rules-desktop | `rules-desktop/crates/rules-hub/src/bodies.rs:37` | HostProbe trait with CliEngine impl (bodies.rs:58) and NoHost (bodies.rs:49) for the process-per-question engine. |

### Object Pool (5)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| testing.nvim | `testing.nvim/lua/testing/run/pool.lua:163` | Pool:acquire/release/shutdown lend warm child editors with a FIFO waiter queue; a leaking or crashed member is discarded instead of returned. |
| media.nvim | `media.nvim/lua/media/core/cache.lua:120` | inflight + high/normal/low priority queues + running counter cap concurrent renders (take/dequeue/settle at 168-200); classless. |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/fetcher.lua:289` | fetch_all fans repos out through lib.nvim async.map_limit with max_parallel_fetches (146), aggregating via a finish callback. |
| ai-desktop | `ai-desktop/src/http_pool.hpp:24` | thread_local map of httplib::Client per base URL, bounded to 16, so no locking is needed. |
| takt | `takt/crates/takt-core/src/frame.rs:214` | FramePool hands out PooledFrame (frame.rs:169) that returns to the pool in Drop (frame.rs:195); bounded capacity returns None instead of allocating. |

### Async/Promise (12)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/async/init.lua:68` | await yields a starter to a coroutine driver (run at :86, wrap at :129); includes Semaphore (:159), Condvar (:210), map_limit (:286). |
| docmap-desktop | `docmap-desktop/src/lib/status-cache.js:14` | mapStatus caches the in-flight promise per mapDir, deletes on rejection, invalidate() at line 29 on generate/remove. |
| docmap-desktop | `docmap-desktop/src/lib/busy-button.js:11` | withBusyButton wraps any async action with disable/relabel/restore in try/finally. |
| hover.nvim | `hover.nvim/lua/hover/init.lua:595` | build_async compares a generation counter (line 59) to drop stale results and shows a provisional placeholder after config.placeholder_grace_ms(). |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/dashboard/view.lua:1244` | pump inside _run_bulk (1129) fills up to `limit` running slots in row order, retries on lock with defer_fn, and can cancel |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/ui/history_picker.lua:18` | delete_from_nvim_history adapts boolean delete_entry to (cmd,on_done,opts); same idea in shell_picker.lua:17 and all_picker.lua:21. |
| data.nvim | `data.nvim/lua/data/init.lua:394` | refresh_source_from_mark re-reads the scope span from FILTER_NS extmark after the interactive filter prompt. |
| fileops.nvim | `fileops.nvim/lua/fileops/util/git.lua:45` | mv/rm/is_tracked and *_async variants hide the git CLI for ops modules. |
| tasks-desktop | `tasks-desktop/ui/src/web/vault-session.ts:172` | exclusive() chains every read/write of the folder onto one promise tail so a re-read never sees half a write; idle() (line 184) waits for it. |
| tasks-desktop | `tasks-desktop/ui/src/web/client.ts:68` | WorkerClient.ask keeps a pending Map<id, resolver>; WorkerRequest/WorkerReply union in worker.ts:16 is the protocol. |
| ai-desktop | `ai-desktop/src/catalog.cpp:159` | list() starts one std::async per provider so a dead provider costs one timeout. |
| streamtap | `streamtap/extension/src/content.js:313` | link.chain = link.chain.then(...) serialises segment posts per MediaSource while a queuedBytes budget drops overflow. |

### Debounce/Throttle (31)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/nvim/debounce/init.lua:34` | Closure-based debounce with libuv timer, vim.schedule, cancel; plus a variant counting skipped calls (line 90). |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/init.lua:840` | uv timer fires every flush_interval_ms and hops via vim.schedule into inst.flush(), batching writes instead of writing per call. |
| testing.nvim | `testing.nvim/lua/testing/run/watch.lua:162` | Watch:due fires after debounce_ms of quiet, or after max_wait_ms regardless; clock is injectable. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/bindings/autocmds.lua:55` | Hand-rolled uv timer collects saved articles and rewrites the KB index once after a delay. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/ui/anonymize_diff.lua:722` | lib.nvim.debounce.buffer with adaptive delay for the redaction diff refresh. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/ui/dash_watch.lua:253` | Watcher class with injected start/schedule/now (DI for tests); debounced on_refresh at :300; the dashboard wires it at ui/dash.lua:1173. |
| docmap.nvim | `docmap.nvim/lua/docmap/editor/registry.lua:138` | lib.nvim.debounce wraps the rescan so BufWritePost bursts become one rescan; cancelled on uninstall (line 561). Same primitive batches trail writes at editor/browse/trail_store.lua:45. |
| filetree.nvim | `filetree.nvim/lua/filetree/adapter/neotree.lua:1179` | redraw_soon builds a lib.nvim.debounce lazily and merges bursts of redraw requests. Many features expose a debounce_ms option. |
| ui.nvim | `ui.nvim/lua/ui/context/init.lua:1437` | build_refresher wraps refresh in lib.nvim.debounce.new with cfg.debounce_ms. The theme picker preview uses the same (bindings/usrcmds/themes/picker.lua:83). |
| gopath.nvim | `gopath.nvim/lua/gopath/bindings/autocmds.lua:35` | defer_fn plus needs_refresh(300) limits the cache rebuild to once per 5 minutes. |
| hover.nvim | `hover.nvim/lua/hover/init.lua:2509` | trigger() builds a lib.nvim.debounce wrapper rebuilt when delay_ms changes, with an undebounced fallback if the lib is missing. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/handlers.lua:123` | open_window keeps one uv timer per key and forwards only the last pending publishDiagnostics payload when it fires. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/lightbulb.lua:489` | lib.nvim.debounce.new(refresh, debounce_ms) rate-limits the code-action request. |
| markdown.nvim | `markdown.nvim/lua/markdown/core/table_mode.lua:120` | lib.nvim.debounce.buffer gives a per-buffer 120 ms debounced reformat after edits |
| markdown.nvim | `markdown.nvim/lua/markdown/core/refs.lua:268` | M.on_change restarts a uv timer per buffer for live ref reconcile; also autocmds.lua:304 for resize reflow |
| mdview.nvim | `mdview.nvim/lua/mdview/bindings/autocmds/live_push.lua:208` | on_text_changed sends at the leading edge and arms exactly one trailing uv timer (pending_timer, line 225) inside the window |
| mdview.nvim | `mdview.nvim/lua/mdview/bindings/autocmds/scroll_sync.lua:117` | on_cursor_moved drops events inside scroll_sync_throttle_ms; selection_sync.lua has a third copy |
| mdview.nvim | `mdview.nvim/lua/mdview/bindings/autocmds/spotlight_sync.lua:202` | debounce.new(M.sync_now, DEBOUNCE_MS) with call()/cancel() used from the sync/reset functions |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/integrations/lazy.lua:246` | setup subscribes to User LazySyncPre/LazySync; on_sync (208) restarts a uv timer (pending) so the report runs once after the sync burst |
| ai.nvim | `ai.nvim/lua/ai/completion/init.lua:231` | lib.nvim.debounce driven from a TextChangedI autocmd for idle-triggered auto completion; InsertLeave resets (:223). |
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/debounce_manager.lua:125` | One lib.nvim.debounce handle per buffer in `timers` (:40), recreated when the size-tier delay changes. |
| language.nvim | `language.nvim/lua/language/spell/live.lua:108` | Per-buffer uv timer stopped/restarted on each change; rescans after scan_debounce_ms. |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/dashboard/init.lua:59` | schedule_render() restarts a uv timer unless enough time has passed (should_render); stop_render_timer (48) releases the handle. |
| my.nvim | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/providers/lsp_symbols.lua:275` | Per-buffer debounced documentSymbol request; results cached per changedtick in __lsp_doc_cache (:117). |
| my.nvim | `my.nvim/lua/my/hl_config/cword_occurrences/init.lua:369` | update_debounced() with a handle recreated in enable() (:383) so debounce_ms changes apply. |
| reposcope.nvim | `reposcope.nvim/lua/reposcope/controllers/provider_controller.lua:85` | README fetch is debounced 100 ms via utils/protection.lua:36 (debounce_with_counter). |
| spotlight.nvim | `spotlight.nvim/lua/spotlight/persist.lua:143` | save() builds a lib.debounce saver on first use and calls .call(). |
| terminal.nvim | `terminal.nvim/lua/terminal/status/init.lua:30` | EXPORTERS table (tmux, wezterm) of module and env signal; failing exporters are switched off after one notice; publish is debounced (:218). |
| appkit | `appkit/crates/appkit-hub/src/store.rs:536` | settle() waits until no fs hint for `debounce`, capped by `max_wait`; options at store.rs:474. |
| tasks-desktop | `tasks-desktop/crates/tasks-hub/src/server/check.rs:217` | follow_changes waits for a quiet period and a minimum gap after store changes, only while an event stream listens; AutoCheckTiming at line 150. |
| tasks-desktop | `tasks-desktop/ui/src/lib/app.svelte.ts:3230` | scheduleTextSearch clears the timer and aborts the previous AbortController, 250 ms first try, 1500 ms retry. |

### Circuit Breaker (2)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| rules.nvim | `rules.nvim/lua/rules/engine/checks/init.lua:51` | safe_call turns a crashing check into status 'error' plus findings, so one bad rule does not abort the family run; the status/findings pair is the Result |
| appkit | `appkit/crates/appkit-hub/src/engine/host.rs:183` | After MAX_FAILURES (host.rs:44) the host is left alone for COOLDOWN (host.rs:46) before it is tried again. |

### Cache/Memoize (40)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| lib.nvim | `lua/lib/lua/memo/lru.lua:93` | LRU cache class (get/put/evict), reused by the dispatcher resolved-key cache (dispatcher/init.lua:27); TTL namespaces in nvim/cache/memory.lua:77. |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/statusline.lua:54` | STATUS_TTL_SECONDS whole-status cache and disk_cache (line 60) with expires_at, invalidated by M.invalidate (69) so statusline renders stay cheap. |
| testing.nvim | `testing.nvim/lua/testing/cache/hash.lua:152` | Hasher object keeps a hash index with lazy load (Hasher:load, line 166) so unchanged files are not re-hashed; entry store validates on read (cache/store.lua). The conformance runner also memoizes sources (conformance/runner.lua:94). |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/registry.lua:36` | Module-level cache of discovered cases plus invalidate() at :86; module-as-singleton and cache-aside. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/registry.lua:44` | canonical_dirs memo shares lifetime with the scan cache; tabgroup.lua key_of_buf also keeps a per-buffer key cache invalidated by registry generation. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/anonymize_rules.lua:304` | Rules loaded lazily and re-read only when file mtime changes. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/fsio.lua:68` | read_scope caches stat/lstat/realpath per coroutine, dropped on write (drop_cache :53); used by contract.lua:365. |
| filetree.nvim | `filetree.nvim/lua/filetree/util/buffer.lua:85` | is_valid_file_buffer caches results per bufnr with a timestamp TTL. invalidate() (line 116) drops an entry. ensure_hook() installs the BufDelete autocmd lazily on the first cache write. The comment explains why lib memo does not fit. |
| gopath.nvim | `gopath.nvim/lua/gopath/bindings/autocmds.lua:19` | BufWritePost invalidates the path-lookup caches; a second BufWritePost rebuilds the truncated cache (debounced). |
| gopath.nvim | `gopath.nvim/lua/gopath/util/path.lua:173` | Cached runtimepath list and module index keyed on the runtimepath string; invalidate_caches() drops them. |
| gopath.nvim | `gopath.nvim/lua/gopath/truncated/cache.lua:694` | start_periodic_refresh keeps a single module-scoped uv timer and replaces the old handle on reload; build_async at line 339. |
| hover.nvim | `hover.nvim/lua/hover/cache.lua:29` | Lazy store: lib LRU(64) or a plain-table fallback (Null Object style); key includes mtime; on_reset (line 112) lets previewers register stores to drop with the cache. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/workspace_diagnostics.lua:130` | Namespaced memory cache for walked file lists with a TTL; pending callbacks per key coalesce concurrent calls. |
| lsp.nvim | `lsp.nvim/lua/lsp/core/symbols.lua:75` | Per-buffer symbol cache, dropped on buffer wipe (autocmd at line 365). |
| lsp.nvim | `lsp.nvim/lua/lsp/core/env_links.lua:1930` | heading_index validates the cache entry with fs_stat; index_cache_order bounds the size; clear_cache at line 1901. |
| markdown.nvim | `markdown.nvim/lua/markdown/core/render.lua:84` | icon_cache memoizes the devicons/mini.icons lookup per filetype |
| rules.nvim | `rules.nvim/lua/rules/engine/checks/grep.lua:76` | cached_readfile memoizes file contents and read errors in ctx for one check_family run |
| rules.nvim | `rules.nvim/lua/rules/engine/agent/cache.lua:25` | key = sha256 of system, prompt, provider and model; a changed input gives a new key and an unreadable entry is a miss |
| ai.nvim | `ai.nvim/lua/ai/keys.lua:336` | file_cache keyed by path and mtime:size stamp; command_cache with cache_fresh (:214) TTL for command-sourced API keys. |
| ai.nvim | `ai.nvim/lua/ai/keys.lua:457` | Concurrent fetches of one key join an `inflight` waiter list; a failed command is not re-run within NEGATIVE_MS (:463). |
| cascade.nvim | `cascade.nvim/lua/cascade/cycle/packs/init.lua:40` | resolve(names) lazily pcall-requires language packs, memoizes by joined key in `cache` (:26), invalidate() on re-setup. |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/core/project_history.lua:21` | git_root_cache via lib.nvim.cache.memory namespace, with '' sentinel to cache a negative result. |
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/cache_manager.lua:93` | is_valid checks timeout, changedtick and line_count; used by highlight_buffer (init.lua:240); stats counters and periodic cleanup. |
| dap.nvim | `dap.nvim/lua/wkddap/memory/init.lua:119` | WINDOW_MODULES selects wkddap.memory.view or companion, both implementing open/show/close/focus_byte; view_module (:125). |
| dap.nvim | `dap.nvim/lua/wkddap/languages/rust.lua:19` | sysroot_cache keyed by cwd, stores only successful lookups. |
| debugging.nvim | `debugging.nvim/lua/debugging/autocmds/sources.lua:271` | scan_file picks scan_file_ts or scan_file_text; scan_cache (:100) is a lib.nvim.cache.memory namespace with TTL used by get_scan (:335). |
| language.nvim | `language.nvim/lua/language/translate/markdown/cache.lua:139` | get/set memory cache with lazy disk load, debounced flush via defer_fn (203) and a VimLeavePre autocmd (206). |
| language.nvim | `language.nvim/lua/language/spell/core/cache.lua:58` | Per-buffer native scan cache with get/set/invalidate keyed on buffer plus config. |
| insights.nvim | `insights.nvim/lua/insights/imports/index.lua:44` | BufWritePost autocmd (created lazily on first put) marks every cached scan stale; get() never builds. |
| insights.nvim | `insights.nvim/lua/insights/symbols/rg_index.lua:180` | get() loads from scan.cache keyed by cwd hash and variant, rebuilds on miss, saves back; ttl and validation live in scan/cache.lua:90. |
| insights.nvim | `insights.nvim/lua/insights/todos/init.lua:82` | derived() lazily builds keyword index once and caches it; regex_cache (49) memoizes compiled patterns; M.reset invalidates. |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/storage.lua:115` | history_cache keyed by metric dir with targeted/global invalidate(); statusline.lua:46 has slug_cache plus invalidate. |
| emojis.nvim | `emojis.nvim/lua/emojis/overlay/frecency.lua:137` | load/save around a usage table with record() and sort() scoring; no-op when the feature is off. |
| images.nvim | `images.nvim/lua/images/terminal.lua:104` | capability(force) caches the terminal probe result with reset_capability (222); zen.lua:~91 caches crops by file/mtime/rect. |
| open.nvim | `open.nvim/lua/open/context.lua:44` | with_cache() makes gather() (:277) return one memoized signals snapshot for the duration of a single open. |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/util/cache.lua:91` | dispatcher.dispatch consults cache.get before running a backend and cache.set after (dispatcher.lua:156 onward); evict_oldest at :72 caps size. |
| reposcope.nvim | `reposcope.nvim/lua/reposcope/cache/readme_cache.lua:164` | get()/has() (:179) check RAM first then file, with warm_ram_from_file_cache (:302) and freshness by updated_at (:285). |
| sandbox.nvim | `sandbox.nvim/lua/sandbox/bindings/usrcmds/init.lua:66` | cached_names caches daemon queries used for completion. |
| rules-desktop | `rules-desktop/crates/rules-hub/src/runtime.rs:306` | sources_body computed once per held snapshot via OnceLock (runtime.rs:128). |
| ai-desktop | `ai-desktop/src/catalog.cpp:110` | cached() returns a hit if fingerprint and TTL match, otherwise fetches outside the lock and stores; error entries use a shorter TTL. |

### Specification (12)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| docmap-desktop | `docmap-desktop/src-tauri/src/server.rs:99` | ROUTES const plus safe_sha guard what may reach the engine subprocess, deliberately mirroring core/api.lua. |
| hover.nvim | `hover.nvim/lua/hover/switches.lua:48` | SWITCHES declares path, implies, auto_type, labels and messages per switch; ORDER (line 159) fixes the display order, and routes and status derive from it. |
| rules.nvim | `rules.nvim/lua/rules/engine/runner.lua:47` | predicates_allowed evaluates a policy bool/function per rule; a throwing policy means not trusted |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/dashboard/export.lua:31` | DEFS list of {id,label,title,match(record)} selects records for each export report |
| ai.nvim | `ai.nvim/lua/ai/policy.lua:59` | is_allowed / filter(order, req) (:92) are composable provider predicates consulted by resolve; grant() adds session exceptions. |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/ui/preview_policy.lua:130` | M.plan returns a PreviewPlan {kind,executes,allowed,reason} gated by preview_execute, risky patterns and argument safety; explain() renders reasons. |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/core/risky.lua:13` | matching(cmd) evaluates configured Lua patterns (pcall-guarded) and is_risky builds on it; tracker.is_redacted (tracker.lua:20) is a sibling predicate. |
| data.nvim | `data.nvim/lua/data/scope/sink.lua:51` | resolve() turns flags into {kind=inplace/split/register} with mutual-exclusion checks; write() (:185) dispatches by sink.kind. |
| open.nvim | `open.nvim/lua/open/viewer/init.lua:39` | FILTERS table of predicates (all/urls/mdlinks/files/paths) over links, next to the SORTS set at :31. |
| tasks-desktop | `tasks-desktop/crates/tasks-hub/src/classes.rs:345` | AreaPolicy.shown/allows decides fail-closed whether an area may be used (Use enum at line 59); Classes (line ~190) holds one policy per vault. |
| rules-desktop | `rules-desktop/crates/rules-hub/src/sources.rs:465` | SourcePolicy.classify evaluates every key against a source path and picks the strictest/longest, returning a Verdict; loosens() (sources.rs:264) compares two policies. |
| rules-desktop | `rules-desktop/crates/rules-hub/src/write.rs:33` | OPS_ALLOWED const list gates which engine ops the page may request; policy.rs:38 apply() builds the next policy as an immutable copy (with_key/with_default). |

### Result/Option (15)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| testing.nvim | `testing.nvim/lua/testing/args.lua:590` | Options are data records (name, long, kind, field, min, help) walked by one parser at args.lua:1105; the same records feed help and completion. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/ops.lua:1391` | Operations answered with a tasks.result document, one entry per op; (nil, err) convention throughout. |
| docmap.nvim | `docmap.nvim/lua/docmap/core/soft_require.lua:30` | Single pcall(require) wrapper returning nil on missing optional plugins; callers degrade. |
| docmap-desktop | `docmap-desktop/src-tauri/src/apperr.rs:298` | AppError with i18n key, Display/Serialize impls; proc.rs:18 ProcError and traffic.rs:180 LoadError are specific error enums. |
| gopath.nvim | `gopath.nvim/lua/gopath/util/safe.lua:21` | safe.call returns (ok, result_or_error) over lib.lua.error.safe_call; used by resolve.lua to separate a resolver that threw from a no-match. |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/bindings/usrcmds.lua:600` | register_plugin_target_type registers GITSUITE_PLUGIN_OR_REPO with validate/complete; sources.lua:41 safe_list converts a throwing source into the nil,err pair |
| ai.nvim | `ai.nvim/lua/ai/init.lua:213` | All async callbacks use cb(ok, res_or_err) with lib_error.new(kind,...) tagged errors instead of throwing. |
| data.nvim | `data.nvim/lua/data/util/safe_call.lua:15` | pcall wrapper keeping a (value, err) pair for decode/render; Data.Problem {msg,level} returned from scope modules. |
| data.nvim | `data.nvim/lua/data/filter/init.lua:63` | Wraps pickers.refine and diff.nvim (preview.lua:116) with pcall(require) and error propagation via on_done(nil, err). |
| diff.nvim | `diff.nvim/lua/diff/core/init.lua:185` | reporters() wraps a caller on_done in pcall and returns done/fail closures so every path reports exactly once. |
| openinnvim | `openinnvim/src/MsgPack.cs:16` | DecodeStatus {Ok, Incomplete, Malformed} plus DecodeResult (:30) instead of exceptions for the streaming decoder. |
| replacer.nvim | `replacer.nvim/lua/replacer/error.lua:49` | safe_call returns {ok, result, err}; typed errors via M.new (:18); rg.collect returns (items, RP_Error/nil). |
| terminal.nvim | `terminal.nvim/lua/terminal/core/exec.lua:60` | result() normalises vim.system output to {code, stdout, stderr}, folding signals into code 128+signal. |
| streamtap | `streamtap/desktop/crates/streamtap-sink/src/main.rs:957` | Admit Skip/Write/Mark returned by TrackState::admit_media (main.rs:1083); Probe enum (main.rs:2995) does the same for ffprobe. |
| takt | `takt/crates/takt-backend/src/scheduler.rs:27` | Presentation Shown/Repeated/Eof returned by Scheduler::accept (scheduler.rs:122); core uses its own Result alias (takt-core/src/error.rs:12). |

### Reducer/MVU (1)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/plugins/report_ui/model.lua:38` | M.new builds the model; each transition (show, toggle_all, next_sort, mark) returns a new model via with() (line 86); render.lua is a separate pure renderer |

### Module (1)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| color_my_ascii.nvim | `color_my_ascii.nvim/lua/color_my_ascii/config/init.lua:113` | load_languages scans languages/*.lua, pcall-requires and validates each module shape before merging. |

### Sonstige (11)

| Repo | Fundstelle | Begruendung |
|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/bindings/usrcmds.lua:213` | pending_token/in_flight/is_current make stale async results no-ops; a logical cancel in a classless Future-like pattern. |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/statusline.lua:84` | Optional modules fetched by pcall(require); statusline degrades when absent. Classless. |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/soft.lua:14` | Single probe for optional plugins (pcall require plus required fields); callers fall back. |
| gopath.nvim | `gopath.nvim/lua/gopath/registry.lua:81` | User-supplied custom_resolvers (table or module name) run before the built-ins, each in pcall. |
| ai.nvim | `ai.nvim/lua/ai/context/init.lua:46` | pcall(require,'data.detect'/...) so optional plugins simply contribute nothing when absent. |
| my.nvim | `my.nvim/lua/my/config/persist.lua:276` | schedule_write coalesces dirty keys into one vim.schedule write with bounded retries; flush() at :327 runs on VimLeavePre. |
| openinnvim | `openinnvim/src/Discovery.cs:30` | Session : IDisposable owns the RPC connection to the instance that passed the probe. |
| terminal.nvim | `terminal.nvim/lua/terminal/backends/init.lua:28` | detect() builds the innermost-first list via Env.SIGNALS; resolve() (:51) falls back to native with a note. |
| streamtap | `streamtap/desktop/crates/streamtap-sink/src/main.rs:376` | Budget charges bytes via compare_exchange; Refusals (main.rs:411) is a mutex-guarded bounded FIFO set shared across connections. |
| streamtap | `streamtap/extension/src/sink-link.js:341` | Reconnect delay doubles to 10 s and resets only after a socket stayed open SINK_STABLE_MS; linkSend (sink-link.js:360) queues while connecting with byte caps. |
| takt | `takt/crates/takt-clock/src/audio_master.rs:180` | AudioClockWriter is deliberately not Clone and handed out once (writer_taken swap, audio_master.rs:74); AnchorCell (anchor.rs:130) is the seqlock cell. |

## 4 Verwendungen nach Repo

### ai-desktop (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Strategy | `ai-desktop/src/models.cpp:168` | models::resolve() maps a model id to a Route (custom model first, then configurable prefixes, else Ollama); main.cpp:69 route_ask dispatches on route.provider. Classless C++, string-keyed. |
| Singleton | `ai-desktop/src/config.cpp:70` | g_mutex/g_loaded/g_doc behind config::inspect/mutate (config.cpp:549/555); same shape in secrets.cpp:37 and catalog.cpp:42. |
| Cache/Memoize | `ai-desktop/src/catalog.cpp:110` | cached() returns a hit if fingerprint and TTL match, otherwise fetches outside the lock and stores; error entries use a shorter TTL. |
| Object Pool | `ai-desktop/src/http_pool.hpp:24` | thread_local map of httplib::Client per base URL, bounded to 16, so no locking is needed. |
| Async/Promise | `ai-desktop/src/catalog.cpp:159` | list() starts one std::async per provider so a dead provider costs one timeout. |
| Repository | `ai-desktop/src/usage.hpp:101` | usage::Store append/read_all/query over usage.jsonl with a Filter; one process-wide write mutex (usage.cpp:21). |
| Observer | `ai-desktop/src/anthropic_client.hpp:30` | Each backend client's ask_stream takes std::function on_delta; main.cpp passes the same callback to every backend. |
| Facade | `ai-desktop/src/secrets.cpp:230` | store_read/write/delete_locked hide WinCred vs file backend behind one API (get/set in secrets.hpp). |

### ai.nvim (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `ai.nvim/lua/ai/providers/init.lua:91` | `registered` id->provider table with register/get/ids; last registration wins, so users can replace built-ins. |
| Lazy Initialization | `ai.nvim/lua/ai/providers/init.lua:40` | make_lazy returns a setmetatable __index proxy that pcall-requires the provider module on first field access. |
| Strategy | `ai.nvim/lua/ai/@types/init.lua:198` | Ai.Provider {available, ask, stream, capabilities} is the strategy contract; claude/openai/gemini/ollama/copilot/claude_cli implement it (classless duck typing). |
| Decorator | `ai.nvim/lua/ai/usage.lua:249` | wrap_callback / wrap_handlers (:274) wrap a callback or handler table to report usage once, then delegate; applied in init.lua:217 and :286. |
| Facade | `ai.nvim/lua/ai/init.lua:260` | M.ask / M.stream hide resolve, policy, key fetch, usage, bulk and provider dispatch behind two calls. |
| Command | `ai.nvim/lua/ai/bulk.lua:235` | Per-label group with FIFO queue, head/tail indices, drain/pump (:263) and a `limit` of concurrent in-flight jobs; cancel empties the queue. |
| Cache/Memoize | `ai.nvim/lua/ai/keys.lua:336` | file_cache keyed by path and mtime:size stamp; command_cache with cache_fresh (:214) TTL for command-sourced API keys. |
| Cache/Memoize | `ai.nvim/lua/ai/keys.lua:457` | Concurrent fetches of one key join an `inflight` waiter list; a failed command is not re-run within NEGATIVE_MS (:463). |
| Debounce/Throttle | `ai.nvim/lua/ai/completion/init.lua:231` | lib.nvim.debounce driven from a TextChangedI autocmd for idle-triggered auto completion; InsertLeave resets (:223). |
| Specification | `ai.nvim/lua/ai/policy.lua:59` | is_allowed / filter(order, req) (:92) are composable provider predicates consulted by resolve; grant() adds session exceptions. |
| Result/Option | `ai.nvim/lua/ai/init.lua:213` | All async callbacks use cb(ok, res_or_err) with lib_error.new(kind,...) tagged errors instead of throwing. |
| Adapter | `ai.nvim/lua/ai/providers/aliases.lua:16` | canonical(id) maps old provider ids (loomai) to current ones; used by providers.get/resolve and config. |
| Sonstige | `ai.nvim/lua/ai/context/init.lua:46` | pcall(require,'data.detect'/...) so optional plugins simply contribute nothing when absent. |

### appkit (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Dependency Injection | `appkit/crates/appkit-hub/src/engine/mod.rs:135` | Engine trait with CliEngine (cli.rs:503) and host-backed impls; hub, search and store only hold Arc<dyn Engine>, tests plug in fakes. |
| Bridge | `appkit/crates/appkit-hub/src/hub.rs:7` | Runtime trait with associated Target plus BuildRuntime factory closure (hub.rs:17) lets the shared Core<R> serve different apps; Pages (hub.rs:29) is a second app-supplied seam. |
| Event Bus | `appkit/crates/appkit-hub/src/store.rs:211` | SnapshotStore publishes Arc<Change> on a broadcast channel; subscribe (store.rs:396) and subscribe_quiet (store.rs:240) for listeners, with listener counting so no scan runs for nobody. |
| Observer | `appkit/crates/appkit-hub/src/search.rs:512` | spawn_indexer subscribes quietly to the store and applies each Change, rebuilding on Lagged. |
| Debounce/Throttle | `appkit/crates/appkit-hub/src/store.rs:536` | settle() waits until no fs hint for `debounce`, capped by `max_wait`; options at store.rs:474. |
| Middleware/Pipeline | `appkit/crates/appkit-hub/src/guard.rs:181` | judge() runs eight ordered request checks (host, size, origin, fetch-site, limits, credential, content type) and short-circuits with an error response; classify() at guard.rs:110 picks the Class. |
| Circuit Breaker | `appkit/crates/appkit-hub/src/engine/host.rs:183` | After MAX_FAILURES (host.rs:44) the host is left alone for COOLDOWN (host.rs:46) before it is tried again. |
| Dependency Injection | `appkit/crates/appkit-core/src/authn.rs:20` | Clock trait with SystemClock/ManualClock; same style: Registry trait over reg.exe (appkit-hub/src/background.rs:302), setup Io trait (setup.rs:36), VaultAdmin<T> (vaults.rs:27). |
| Null Object | `appkit/crates/appkit-hub/src/config.rs:58` | AppSettings trait has a default validate() and NoSettings (config.rs:74) is the empty implementation for apps without settings. |
| Registry | `appkit/crates/appkit-hub/src/engine/method.rs:7` | MethodSpec const table with read/bare/write/aside constructors; Method is a handle into the app's table, never built from a string. |
| Repository | `appkit/ui-kit/src/cache.ts:14` | CacheStore<T> load/save/clear interface with an IndexedDB implementation (cache.ts:47); tests use a fake. Classless TS. |
| State | `appkit/ui-kit/src/session.svelte.ts:97` | StreamSession follows the SSE stream, reconnects with growing delay; StreamDeps (line 82) injects fetch, sleep and callbacks. Connection state is the union 'live'/'reconnecting'/'offline'. |
| Command | `appkit/ui-kit/src/menu.ts:11` | MenuItem discriminated union with onselect closures; keymap.ts:29 withChord maps keys to command names as data. |

### buffer-ctx.nvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `buffer-ctx.nvim/lua/buffer_ctx/format/init.lua:35` | register_subcommand fills a name->{handler,complete,desc} table that composer turns into the :Format command. |
| Facade | `buffer-ctx.nvim/lua/buffer_ctx/commands.lua:114` | DISPATCH subcmd->function shared by :Insert and :Copy via M._dispatch (:510); build_routes (:580) generates composer routes from it. |
| Strategy | `buffer-ctx.nvim/lua/buffer_ctx/commands.lua:69` | sink 'clip' vs 'insert' chooses the delivery behavior of every handler (sink_text/sink_lines). |
| Lazy Initialization | `buffer-ctx.nvim/lua/buffer_ctx/ops/boilerplate/init.lua:23` | REGISTRY entries name module+fn; M.get (:189) pcall-requires the template module only on demand. |
| Observer | `buffer-ctx.nvim/lua/buffer_ctx/mark/init.lua:538` | BufDelete/BufWipeout clears the module-level `marked` buffer->extmark->category map (:39). |
| Registry | `buffer-ctx.nvim/lua/buffer_ctx/mark/init.lua:39` | marked/categories (:87) tables live in the module closure with add/remove/clear accessors. |

### cascade.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Chain of Responsibility | `cascade.nvim/lua/cascade/dispatch/init.lua:32` | dispatch.try runs an ordered handler list until one returns true, pcall-isolating each, then try_or_native falls back to the native key; used in init.lua:339/378/393/408. |
| Template Method | `cascade.nvim/lua/cascade/init.lua:858` | block_work and visual_work (:878) wrap a transform fn with the shared gating (enable, writable, filetype, feature) and range resolution. |
| Memento | `cascade.nvim/lua/cascade/core/context.lua:16` | Context.new builds an immutable-ish cursor/buffer snapshot (setmetatable class) passed to every handler. |
| Cache/Memoize | `cascade.nvim/lua/cascade/cycle/packs/init.lua:40` | resolve(names) lazily pcall-requires language packs, memoizes by joined key in `cache` (:26), invalidate() on re-setup. |
| Registry | `cascade.nvim/lua/cascade/util/dotrepeat.lua:26` | repeatable(key, fn) stores actions in `store` and replays the last via operatorfunc g@. |
| Strategy | `cascade.nvim/lua/cascade/strings/init.lua:459` | converter_for(ft) returns template_string / python_fstring / lua_format function by feature + filetype config. |
| Observer | `cascade.nvim/lua/cascade/bindings/autocmds.lua:1` | Four idempotent autocmds bind per-filetype keys, hanging-indent options, save-time renumber and strings conversion. |
| Decorator | `cascade.nvim/lua/cascade/init.lua:758` | counted_cycle(fn) captures vim.v.count1 into pending_cycle_count then calls fn, so dot-repeat replays with the same count. |

### casedesk.nvim (16)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Facade | `casedesk.nvim/lua/casedesk/ai/init.lua:1` | Single door to ai.nvim; send flow resolve->gates->availability->capabilities->call->audit; enforced by ai_facade_lint_spec. Classless module API. |
| Middleware/Pipeline | `casedesk.nvim/lua/casedesk/ai/init.lua:626` | M.send runs ordered steps (provider, policy, confirm, caps, call, audit) with a cancellable handle; ordered pipeline in one function. |
| Event Bus | `casedesk.nvim/lua/casedesk/tabgroup.lua:536` | Emits User CasedeskTabgroupChanged so the tab group knows no reader; pin.lua:261 subscribes. |
| Cache/Memoize | `casedesk.nvim/lua/casedesk/registry.lua:36` | Module-level cache of discovered cases plus invalidate() at :86; module-as-singleton and cache-aside. |
| Cache/Memoize | `casedesk.nvim/lua/casedesk/registry.lua:44` | canonical_dirs memo shares lifetime with the scan cache; tabgroup.lua key_of_buf also keeps a per-buffer key cache invalidated by registry generation. |
| Lazy Initialization | `casedesk.nvim/lua/casedesk/wordings.lua:30` | setmetatable __index forwards to the live require('casedesk.config'), so a reloaded config is seen. |
| Debounce/Throttle | `casedesk.nvim/lua/casedesk/bindings/autocmds.lua:55` | Hand-rolled uv timer collects saved articles and rewrites the KB index once after a delay. |
| Debounce/Throttle | `casedesk.nvim/lua/casedesk/ui/anonymize_diff.lua:722` | lib.nvim.debounce.buffer with adaptive delay for the redaction diff refresh. |
| Sonstige | `casedesk.nvim/lua/casedesk/statusline.lua:84` | Optional modules fetched by pcall(require); statusline degrades when absent. Classless. |
| Command | `casedesk.nvim/lua/casedesk/plan.lua:115` | Scaffold actions are data records (mkdir/write/copy/skip) described by describe() and executed by apply.lua; dry-run capable. |
| Command | `casedesk.nvim/lua/casedesk/bindings/usrcmds.lua:936` | Declarative routes list {path,args,flags,desc,run} registered via composer.verb at :2231; trie dispatch. |
| Registry | `casedesk.nvim/lua/casedesk/bindings/usrcmds.lua:119` | composer.register_type('CASE', ...) and 'BLOCK' at :188 plug custom arg types (validate/complete) into the composer. |
| Adapter | `casedesk.nvim/lua/casedesk/stream_format.lua:20` | detect() picks snow vs saperesolve; two parsers (sla/stream.lua:238, extract/stream.lua:434) adapt each export to one shape. |
| Cache/Memoize | `casedesk.nvim/lua/casedesk/anonymize_rules.lua:304` | Rules loaded lazily and re-read only when file mtime changes. |
| Template Method | `casedesk.nvim/lua/casedesk/ai/confirm.lua:1` | Serialising confirmation on lib dialog.ask with vim.ui.select fallback; a Facade over the dialog with degrade path. |
| Singleton | `casedesk.nvim/lua/casedesk/bindings/usrcmds.lua:925` | setup() stops then re-arms sla.notify timer so re-sourcing does not leave two timers (sla/notify.lua:190 stop). |

### cmdlog.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Observer | `cmdlog.nvim/lua/cmdlog/core/tracker.lua:49` | One CmdlineLeave autocmd fans out to project_history, stats and errors via vim.schedule (:66). |
| Strategy | `cmdlog.nvim/lua/cmdlog/ui/picker_utils.lua:161` | open_picker picks Telescope or fzf-lua from config; previewers (telescope-previewer, fzf-previewer) adapt the same preview_policy. |
| Specification | `cmdlog.nvim/lua/cmdlog/ui/preview_policy.lua:130` | M.plan returns a PreviewPlan {kind,executes,allowed,reason} gated by preview_execute, risky patterns and argument safety; explain() renders reasons. |
| Specification | `cmdlog.nvim/lua/cmdlog/core/risky.lua:13` | matching(cmd) evaluates configured Lua patterns (pcall-guarded) and is_risky builds on it; tracker.is_redacted (tracker.lua:20) is a sibling predicate. |
| Iterator | `cmdlog.nvim/lua/cmdlog/ui/cycle.lua:9` | Ordered `order` table of {name, show} pickers; attach() rotates to next source carrying prompt text. |
| Cache/Memoize | `cmdlog.nvim/lua/cmdlog/core/project_history.lua:21` | git_root_cache via lib.nvim.cache.memory namespace, with '' sentinel to cache a negative result. |
| Repository | `cmdlog.nvim/lua/cmdlog/core/store.lua:46` | load_json/save_json with validate and .corrupt backup is the shared storage layer for history, stats, errors, tags, favorites. |
| Async/Promise | `cmdlog.nvim/lua/cmdlog/ui/history_picker.lua:18` | delete_from_nvim_history adapts boolean delete_entry to (cmd,on_done,opts); same idea in shell_picker.lua:17 and all_picker.lua:21. |

### color_my_ascii.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Debounce/Throttle | `color_my_ascii.nvim/lua/color_my_ascii/debounce_manager.lua:125` | One lib.nvim.debounce handle per buffer in `timers` (:40), recreated when the size-tier delay changes. |
| Cache/Memoize | `color_my_ascii.nvim/lua/color_my_ascii/cache_manager.lua:93` | is_valid checks timeout, changedtick and line_count; used by highlight_buffer (init.lua:240); stats counters and periodic cleanup. |
| Lazy Initialization | `color_my_ascii.nvim/lua/color_my_ascii/scheme_loader.lua:11` | AVAILABLE_SCHEMES name->module path, load_scheme (:28) pcall-requires on demand with validation. |
| Strategy | `color_my_ascii.nvim/lua/color_my_ascii/parser.lua:180` | find_ascii_blocks picks comment_ascii, treesitter parser_ts or heuristic scanner and falls back on error; highlighter.lua:213 does the same for the optional TS pass. |
| Chain of Responsibility | `color_my_ascii.nvim/lua/color_my_ascii/language_detector.lua:182` | detect_language tries fence marker, content heuristics, buffer context in priority order, returning nil for all keywords. |
| Command | `color_my_ascii.nvim/lua/color_my_ascii/commands/fence/init.lua:49` | SUBCOMMANDS name->fn(argv,ctx); execute (:100) tokenizes and dispatches, complete derives from the same table. |
| Module | `color_my_ascii.nvim/lua/color_my_ascii/config/init.lua:113` | load_languages scans languages/*.lua, pcall-requires and validates each module shape before merging. |
| Facade | `color_my_ascii.nvim/lua/color_my_ascii/bindings/autocmds.lua:19` | FileType autocmd sets up per-buffer highlighting and the buffer-local :Fence command; ColorScheme autocmds re-resolve highlight groups (init.lua:90). |

### dap.nvim (9)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `dap.nvim/lua/wkddap/registry.lua:40` | register(language) resolves aliases, validates, pcall-requires wkddap.languages.<x> and calls its setup(); _registered/_enabled track state. |
| Strategy | `dap.nvim/lua/wkddap/ui/provider.lua:53` | resolve(preference) picks provider with auto/fallback; setup (:102) loads ui/dapview or ui/dapui implementing the same setup(opts) contract. |
| Adapter | `dap.nvim/lua/wkddap/ui/provider.lua:134` | dispatch(actions, what) maps the active provider to a per-provider closure (toggle :168, eval :182), pcall-protected. |
| Cache/Memoize | `dap.nvim/lua/wkddap/memory/init.lua:119` | WINDOW_MODULES selects wkddap.memory.view or companion, both implementing open/show/close/focus_byte; view_module (:125). |
| Observer | `dap.nvim/lua/wkddap/memory/init.lua:526` | attach_listeners subscribes END_EVENTS and REFRESH_EVENTS under key 'wkddap.memory'; detach_listeners (:511) removes them. |
| Memento | `dap.nvim/lua/wkddap/memory/init.lua:674` | state.undo holds {ref,offset,old,new}; M.undo pops and writes old back; seq counter (:403-410) discards outdated async readMemory responses. |
| Singleton | `dap.nvim/lua/wkddap/memory/init.lua:115` | `current` module-level state of the single open memory view. |
| Template Method | `dap.nvim/lua/wkddap/languages/rust.lua:76` | Each language module exposes setup() (adapter) and load() (configurations), driven by adapters/init.lua:22 and configurations/init.lua:18; contract_spec tests it. |
| Cache/Memoize | `dap.nvim/lua/wkddap/languages/rust.lua:19` | sysroot_cache keyed by cwd, stores only successful lookups. |

### data.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Lazy Initialization | `data.nvim/lua/data/format/init.lua:15` | try_register pcall-requires json/yaml/xml formatters so a missing dep only disables its own format; get(name) at :31. |
| Strategy | `data.nvim/lua/data/format/json.lua:43` | Each format module provides decode/render with the same shape; data.init run/convert/filter are format-agnostic over it. |
| Specification | `data.nvim/lua/data/scope/sink.lua:51` | resolve() turns flags into {kind=inplace/split/register} with mutual-exclusion checks; write() (:185) dispatches by sink.kind. |
| Facade | `data.nvim/lua/data/init.lua:141` | resolve_io + deliver (:176) hide source/sink resolution and writing behind M.run/convert/filter/run_auto. |
| Result/Option | `data.nvim/lua/data/util/safe_call.lua:15` | pcall wrapper keeping a (value, err) pair for decode/render; Data.Problem {msg,level} returned from scope modules. |
| Chain of Responsibility | `data.nvim/lua/data/init.lua:669` | run_auto detects format via detect.format (fence, register, filetype, text sniff detect/init.lua:100), else asks via ask_format (kit.select / vim.ui.select). |
| Async/Promise | `data.nvim/lua/data/init.lua:394` | refresh_source_from_mark re-reads the scope span from FILTER_NS extmark after the interactive filter prompt. |
| Result/Option | `data.nvim/lua/data/filter/init.lua:63` | Wraps pickers.refine and diff.nvim (preview.lua:116) with pcall(require) and error propagation via on_done(nil, err). |

### debugging.nvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `debugging.nvim/lua/debugging/commands.lua:50` | build_registry (lazy, cached at :333) maps category->{feature,actions,run{}}; dispatch (:427) handles feature flags and __default free-form handlers. |
| Strategy | `debugging.nvim/lua/debugging/views/capture/init.lua:291` | capture_messages_raw tries noice, execute, exec2 in order and aggregates failures. |
| Cache/Memoize | `debugging.nvim/lua/debugging/autocmds/sources.lua:271` | scan_file picks scan_file_ts or scan_file_text; scan_cache (:100) is a lib.nvim.cache.memory namespace with TTL used by get_scan (:335). |
| Observer | `debugging.nvim/lua/debugging/terminals/keylogger.lua:110` | on_key callback registered at :180 under a namespace, removed at :199; work deferred with vim.schedule. |
| Strategy | `debugging.nvim/lua/debugging/views/recent.lua:24` | FILTER_LEVELS / FILTER_TAG / FILTER_TITLE keyed by filter name instead of if-chains. |
| Registry | `debugging.nvim/lua/debugging/config/KEYMAP_ACTIONS.lua:12` | One action list read by config schema and bindings/keymaps.lua:48 so spec and schema cannot drift. |

### diff.nvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Adapter | `diff.nvim/lua/diff/core/pickers_bridge.lua:28` | Wraps pickers.nvim engine as a vim.ui.select-compatible function, returning nil when absent so callers fall back. |
| Result/Option | `diff.nvim/lua/diff/core/init.lua:185` | reporters() wraps a caller on_done in pcall and returns done/fail closures so every path reports exactly once. |
| Strategy | `diff.nvim/lua/diff/features/diffopt_profile/profiles.lua:14` | Named diffopt profiles as full replacement values; init.lua:26/38 get/set apply one. |
| Facade | `diff.nvim/lua/diff/core/init.lua:322` | execute() is the single pipeline entry (directory, image-compare, three-way, text outputs, buffer views); run() at ~750 adds arg parsing and pickers. |
| Lazy Initialization | `diff.nvim/lua/diff/features/gitsigns_peek.lua:46` | gitsigns is require()d on keypress, not at setup, to avoid forcing a lazy load. |
| Registry | `diff.nvim/lua/diff/core/scratch.lua:49` | track/discard/cleanup_all/wipe_on_exit manage the lifetime of scratch buffers, an idempotent resource registry. |

### docmap-desktop (10)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Async/Promise | `docmap-desktop/src/lib/status-cache.js:14` | mapStatus caches the in-flight promise per mapDir, deletes on rejection, invalidate() at line 29 on generate/remove. |
| Async/Promise | `docmap-desktop/src/lib/busy-button.js:11` | withBusyButton wraps any async action with disable/relabel/restore in try/finally. |
| Facade | `docmap-desktop/src-tauri/src/main.rs:4057` | about 60 #[tauri::command] fns registered through generate_handler!; JS calls them via invoke(...). |
| Repository | `docmap-desktop/src-tauri/src/main.rs:594` | with_workspace holds WORKSPACE_LOCK (line 588) across read_workspace, closure mutation, write_workspace; every mutating command goes through it. |
| Lazy Initialization | `docmap-desktop/src-tauri/src/main.rs:2713` | CACHE_ROOT OnceLock caches nvim stdpath(cache) from a subprocess; also server.rs:78 CURRENT Mutex<Option<Server>> is a one-server singleton slot. |
| Result/Option | `docmap-desktop/src-tauri/src/apperr.rs:298` | AppError with i18n key, Display/Serialize impls; proc.rs:18 ProcError and traffic.rs:180 LoadError are specific error enums. |
| State | `docmap-desktop/src-tauri/src/main.rs:1283` | CloneTarget {Existing, Clone} decides the import path before cloning; LinkWalk (3097), search::Mode (search.rs:53), stats::Kind (stats.rs:58) are similar sum types. |
| Composite | `docmap-desktop/src-tauri/src/menu.rs:110` | Node enum {Item, Check, Sub(label, &[Node])} is a static composite menu; forward_clicks (menu.rs:370) emits a 'menu' event once to the frontend. |
| Specification | `docmap-desktop/src-tauri/src/server.rs:99` | ROUTES const plus safe_sha guard what may reach the engine subprocess, deliberately mirroring core/api.lua. |
| Observer | `docmap-desktop/src/main.js:457` | document-level mouseover/focusin/focusout with a dwell timer (helpTimer, line 429) for help tooltips; Tauri 'menu' event is the other subscription. |

### docmap.nvim (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Lazy Initialization | `docmap.nvim/lua/docmap/core/lang_registry.lua:119` | registry.new with a lazy loader; each language backend (core/lang/*.lua) self-registers and the scan walk asks for_file() (line 211) who handles a filename; backends are interchangeable strategies. |
| Strategy | `docmap.nvim/lua/docmap/core/check.lua:71` | M.NEEDS maps a check to the backend capability it needs (module_tag, param_docs); checks consult the backend instead of switching on language. |
| Lazy Initialization | `docmap.nvim/lua/docmap/init.lua:253` | M.browse/diff/cli/history/testing/generate_all are empty tables with __index requiring the real module on first access; init.lua is a single public facade. Classless (metatable proxy). |
| Command | `docmap.nvim/lua/docmap/bindings/usrcmds/init.lua:39` | ACTIONS maps the first word of :DocMap args to a lazy thunk; dispatch() at line 350 validates the verb and has completion read from the same table (replaced an if-chain). |
| Observer | `docmap.nvim/lua/docmap/editor/registry.lua:507` | handle.on_change(cb) appends to entry.watchers and returns an unsubscribe closure; notify_watchers (line 78) fans out and isolates subscriber errors. |
| Debounce/Throttle | `docmap.nvim/lua/docmap/editor/registry.lua:138` | lib.nvim.debounce wraps the rescan so BufWritePost bursts become one rescan; cancelled on uninstall (line 561). Same primitive batches trail writes at editor/browse/trail_store.lua:45. |
| Registry | `docmap.nvim/lua/docmap/editor/registry.lua:22` | module-local table keyed by normalised root holds one entry per repo; install/get return the same handle (Repository-like in-memory store of IR). |
| Middleware/Pipeline | `docmap.nvim/lua/docmap/core/check.lua:2341` | M.run sequentially applies ~24 check functions into one findings list, then opts.extra_checks (line 2369), then check_policy.apply grades findings, then sorts. |
| Decorator | `docmap.nvim/lua/docmap/core/check_policy.lua:155` | apply(findings, policy) re-grades or suppresses findings after all checks ran, so it also covers extra_checks. |
| Result/Option | `docmap.nvim/lua/docmap/core/soft_require.lua:30` | Single pcall(require) wrapper returning nil on missing optional plugins; callers degrade. |
| Command | `docmap.nvim/lua/docmap/mcp/tools.lua:135` | each tool is a table {description, schema, run(handle,args)}; M.list (468) exposes them and protocol.dispatch routes JSON-RPC calls; call is pcall-wrapped at mcp/protocol.lua:177 (Result-style error containment). |
| Mediator | `docmap.nvim/lua/docmap/bindings/autocmds.lua:45` | declarative manifest of every autocmd with a why, per-root augroups (editor/registry.lua:133) give clean teardown. |
| Registry | `docmap.nvim/lua/docmap/core/api.lua:450` | M.routes table maps route name to handler; looked up at line 500. |

### emojis.nvim (5)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Chain of Responsibility | `emojis.nvim/lua/emojis/picker.lua:140` | insert() tries try_telescope (30), then try_fzf_lua (70), then select_fallback (102), each returning true if it took over. |
| Facade | `emojis.nvim/lua/emojis/commands.lua:199` | action_route() builds composer routes that forward() into the single execute() (91). |
| Cache/Memoize | `emojis.nvim/lua/emojis/overlay/frecency.lua:137` | load/save around a usage table with record() and sort() scoring; no-op when the feature is off. |
| Strategy | `emojis.nvim/lua/emojis/core/ops.lua:78` | clear/replace/unreplace/wrap are pure lines-to-(lines,count) transforms chosen by action in actions.edit (88). |
| Facade | `emojis.nvim/lua/emojis/unicode/init.lua:375` | dispatch() fronts the Unicode toolkit subactions (name/search/table/digraphs). |

### fileops.nvim (5)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Facade | `fileops.nvim/lua/fileops/ops/file.lua:193` | notify_change() emits User FileopsChanged for any listener and reloads explorers; FileopsRetry (line 138) is a second event. |
| Facade | `fileops.nvim/lua/fileops/bindings/usrcmds.lua:633` | dispatch(subcmd, ...) routes ~20 subcommands; composer routes (915) forward into it. |
| Middleware/Pipeline | `fileops.nvim/lua/fileops/ops/bulk.lua:65` | Bulk rename is a staged pure pipeline: plan (65), analyze (205), select (274), order (353), execute (410) with temp-name cycle breaking. |
| Async/Promise | `fileops.nvim/lua/fileops/util/git.lua:45` | mv/rm/is_tracked and *_async variants hide the git CLI for ops modules. |
| Observer | `fileops.nvim/lua/fileops/features/on_hold.lua:34` | augroup(name) creates a replaceable group per concern; setup (341) wires CursorHold-style events and a one-shot cleanup autocmd (~line 472). |

### filetree.nvim (14)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `filetree.nvim/lua/filetree/adapter/init.lua:17` | M.register keeps name->adapter in _registry. neotree/nvimtree/netrw/oil/mini_files each implement the FiletreeAdapter interface (is_available etc.) and self-register (oil.lua:358). Classless: modules act as adapters. |
| Lazy Initialization | `filetree.nvim/lua/filetree/adapter/init.lua:31` | resolve() pcall-requires adapter modules on demand. The 'auto' path (line 51) tries candidates in priority order until is_available() is true. |
| Registry | `filetree.nvim/lua/filetree/refs/registry.lua:26` | Providers (lua, markdown, python, ts_js, plaintext) supply plan/extract/retarget functions. Third parties register through the same contract. enabled() filters via cfg flags. |
| Event Bus | `filetree.nvim/lua/filetree/features/infra/hooks_api/init.lua:71` | on/once/off/emit with handler ids and an event->ids index. Copies the id list before iterating so removals mid-emit are safe. The header comment says no emit() calls exist yet. |
| Facade | `filetree.nvim/lua/filetree/util/autocmd.lua:41` | group/create/acmd wrap lib.nvim.bindings.autocmd. They give one call shape and record autocmds for health and the binding catalog. |
| Dependency Injection | `filetree.nvim/lua/filetree/features/init.lua:25` | The FEATURES table maps name->{mod,category}. init.lua:152-164 loops it, pcall-requires each module and calls feat_mod.setup(fcfg, adapter), which injects the adapter. Failures are isolated per feature. |
| Command | `filetree.nvim/lua/filetree/refs/apply.lua:211` | Every apply pushes an undo token holding before/after line content onto _undo_stack. Tokens get stable ids from _next_id. Undo is content-verified. M.undo is at line 463. |
| Memento | `filetree.nvim/lua/filetree/features/fileops/trash/undo.lua:56` | M.record inserts a TrashEntry at the head of _history, capped by max_history. M.restore (line 405) and restore_last (line 321) revert it, and attach_refs links it to the refs undo token. |
| Strategy | `filetree.nvim/lua/filetree/features/fileops/trash/platform.lua:404` | M.send picks trash_wsl, trash_windows, trash_mac or trash_linux. Each has a batch variant (send_batch, line 425), all behind a common send(path, cb) shape. |
| Builder | `filetree.nvim/lua/filetree/features/system/file_clipboard/backend.lua:119` | M.build(plat, paths, probe) returns a pure command spec {argv, env, stdin, tool}. The probe is injected for tests. The spec is separate from execution, which also gives a testable seam. |
| Builder | `filetree.nvim/lua/filetree/features/system/compress/archiver.lua:51` | detect() (line 24) picks a zip or bsdtar tool. build(tool,out,sources) branches on tool.kind to produce the argv. |
| Cache/Memoize | `filetree.nvim/lua/filetree/util/buffer.lua:85` | is_valid_file_buffer caches results per bufnr with a timestamp TTL. invalidate() (line 116) drops an entry. ensure_hook() installs the BufDelete autocmd lazily on the first cache write. The comment explains why lib memo does not fit. |
| Debounce/Throttle | `filetree.nvim/lua/filetree/adapter/neotree.lua:1179` | redraw_soon builds a lib.nvim.debounce lazily and merges bursts of redraw requests. Many features expose a debounce_ms option. |
| Facade | `filetree.nvim/lua/filetree/commands.lua:1` | One :Filetree command routes through a TREE table to feature modules. Completion and routes derive from that table. ft() at line 28 resolves features lazily. |

### github_stats.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Facade | `github_stats.nvim/lua/github_stats/bindings/usrcmds/init.lua:135` | composer.verb route table maps subcommands to per-file executors (fetch, show, export, diff, ...); classless Command dispatch. |
| Debounce/Throttle | `github_stats.nvim/lua/github_stats/dashboard/init.lua:59` | schedule_render() restarts a uv timer unless enough time has passed (should_render); stop_render_timer (48) releases the handle. |
| Singleton | `github_stats.nvim/lua/github_stats/dashboard/state.lua:10` | Module-level state record with init_state/get_state/clear_state plus setters (sort, time range, scroll); state/ui_state.lua is the buffer/window twin. |
| Observer | `github_stats.nvim/lua/github_stats/background.lua:81` | start() runs run_cycle on a uv timer, and run_cycle (22) chains digest refresh, repo discovery, then fetch. |
| Object Pool | `github_stats.nvim/lua/github_stats/fetcher.lua:289` | fetch_all fans repos out through lib.nvim async.map_limit with max_parallel_fetches (146), aggregating via a finish callback. |
| Cache/Memoize | `github_stats.nvim/lua/github_stats/storage.lua:115` | history_cache keyed by metric dir with targeted/global invalidate(); statusline.lua:46 has slug_cache plus invalidate. |
| Registry | `github_stats.nvim/lua/github_stats/api.lua:17` | ENDPOINTS maps metric name to request path template used by build_path. |
| Template Method | `github_stats.nvim/lua/github_stats/export.lua:333` | Each report has build_*_lines() then a write_lines wrapper and a create_pdf wrapper; shape is shared but repeated four times. |

### gitsuite.nvim (14)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Lazy Initialization | `gitsuite.nvim/lua/gitsuite/adapter/init.lua:20` | _registry plus register/resolve load adapters on demand by pcall-require; is_available() reads package.loaded only; Adapter interface in @types/init.lua:103 |
| Chain of Responsibility | `gitsuite.nvim/lua/gitsuite/adapter/init.lua:67` | resolve_first returns the first available of an ordered adapter list; features/plugins/sources.lua:26 uses AUTO = lazy, pack, clones |
| Event Bus | `gitsuite.nvim/lua/gitsuite/events.lua:18` | branch_switched, conflicts_resolved, plugins_reported, status_changed fire User autocmds (e.g. line 52) with typed payloads so consumers need no direct require |
| Debounce/Throttle | `gitsuite.nvim/lua/gitsuite/integrations/lazy.lua:246` | setup subscribes to User LazySyncPre/LazySync; on_sync (208) restarts a uv timer (pending) so the report runs once after the sync burst |
| Command | `gitsuite.nvim/lua/gitsuite/features/dashboard/view.lua:1703` | ROW_KEYMAPS entries {keys,label,desc,run(ctx)} drive keymaps, legend and context menu; _keymap_entry (2075) looks up by key and _context_menu_items (2111) reuses the run functions |
| State | `gitsuite.nvim/lua/gitsuite/features/dashboard/repo_state.lua:61` | phases pending/fetching/done/failed per repo, try_lock/unlock by path, generation counter (line 53, begin_bulk at 86) invalidates callbacks of a superseded bulk |
| Async/Promise | `gitsuite.nvim/lua/gitsuite/features/dashboard/view.lua:1244` | pump inside _run_bulk (1129) fills up to `limit` running slots in row order, retries on lock with defer_fn, and can cancel |
| Reducer/MVU | `gitsuite.nvim/lua/gitsuite/features/plugins/report_ui/model.lua:38` | M.new builds the model; each transition (show, toggle_all, next_sort, mark) returns a new model via with() (line 86); render.lua is a separate pure renderer |
| Dependency Injection | `gitsuite.nvim/lua/gitsuite/features/plugins/report_ui/preview.lua:108` | loader factory takes injectable run, partial and defer; put() (133) evicts oldest beyond CACHE_MAX; error entries expire via until_ms |
| Chain of Responsibility | `gitsuite.nvim/lua/gitsuite/features/plugins/target.lua:73` | resolve tries pin, commit, tag, version, then branch in lazy.nvim's order, returning a tier-tagged result or unknown with reason |
| Specification | `gitsuite.nvim/lua/gitsuite/features/dashboard/export.lua:31` | DEFS list of {id,label,title,match(record)} selects records for each export report |
| Result/Option | `gitsuite.nvim/lua/gitsuite/bindings/usrcmds.lua:600` | register_plugin_target_type registers GITSUITE_PLUGIN_OR_REPO with validate/complete; sources.lua:41 safe_list converts a throwing source into the nil,err pair |
| Adapter | `gitsuite.nvim/lua/gitsuite/features/dashboard/actions.lua:32` | by_changed wraps on_done for lib.nvim.git calls; actions reshape (opts,on_done,git_cmd) to (repo,on_done) |
| Dependency Injection | `gitsuite.nvim/lua/gitsuite/features/plugins/sources.lua:173` | M.select or vim.ui.select lets specs replace the pick |

### gopath.nvim (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Chain of Responsibility | `gopath.nvim/lua/gopath/resolve.lua:32` | resolve_at_cursor tries help, url, env, task-id, filetoken, linepath, language pipeline, loose url, fallback in order; the first stage that answers wins (classless, inline stages). |
| Registry | `gopath.nvim/lua/gopath/registry.lua:113` | PIPELINE maps provider name (lsp/treesitter/builtin) to a handler function; RES (line 21) maps filetype to resolver modules; BUILTIN_ORDER (line 51) gives the order. |
| Sonstige | `gopath.nvim/lua/gopath/registry.lua:81` | User-supplied custom_resolvers (table or module name) run before the built-ins, each in pcall. |
| Facade | `gopath.nvim/lua/gopath/registry.lua:193` | run_language_pipeline hides the per-language resolver modules behind one call. |
| Strategy | `gopath.nvim/lua/gopath/open/init.lua:20` | PLACEMENT maps open mode (edit/window/vsplit/tab) to a window-creating function. |
| Null Object | `gopath.nvim/lua/gopath/util/filetree.lua:11` | Returns filetree.nvim's adapter or nil; used by create.lua and open so there is one pcall(require) seam instead of two copies. |
| Adapter | `gopath.nvim/lua/gopath/create.lua:191` | ask() and ask_input() pick ui.kit when present, otherwise vim.ui.select/input; selected at load by pcall(require) at line 167. |
| Cache/Memoize | `gopath.nvim/lua/gopath/bindings/autocmds.lua:19` | BufWritePost invalidates the path-lookup caches; a second BufWritePost rebuilds the truncated cache (debounced). |
| Cache/Memoize | `gopath.nvim/lua/gopath/util/path.lua:173` | Cached runtimepath list and module index keyed on the runtimepath string; invalidate_caches() drops them. |
| Debounce/Throttle | `gopath.nvim/lua/gopath/bindings/autocmds.lua:35` | defer_fn plus needs_refresh(300) limits the cache rebuild to once per 5 minutes. |
| Cache/Memoize | `gopath.nvim/lua/gopath/truncated/cache.lua:694` | start_periodic_refresh keeps a single module-scoped uv timer and replaces the old handle on reload; build_async at line 339. |
| Singleton | `gopath.nvim/lua/gopath/truncated/cache.lua:133` | Module-local state table plus timer; same convention in alias_index/binding_index (weak caches). |
| Result/Option | `gopath.nvim/lua/gopath/util/safe.lua:21` | safe.call returns (ok, result_or_error) over lib.lua.error.safe_call; used by resolve.lua to separate a resolver that threw from a no-match. |

### hover.nvim (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `hover.nvim/lua/hover/registry.lua:96` | Plugins register ordered sources/positions and one preview per target type; re-registering the same name replaces its entry, so setup() is idempotent. |
| Chain of Responsibility | `hover.nvim/lua/hover/registry.lua:148` | source_at asks each registered source in registration order; the first answer wins. |
| Strategy | `hover.nvim/lua/hover/registry.lua:168` | preview_for(target_type) returns the registered previewer, which build() in init.lua:632 tries before the built-ins. |
| Cache/Memoize | `hover.nvim/lua/hover/cache.lua:29` | Lazy store: lib LRU(64) or a plain-table fallback (Null Object style); key includes mtime; on_reset (line 112) lets previewers register stores to drop with the cache. |
| Lazy Initialization | `hover.nvim/lua/hover/cache.lua:29` | The store is built on first use, not at load. |
| Debounce/Throttle | `hover.nvim/lua/hover/init.lua:2509` | trigger() builds a lib.nvim.debounce wrapper rebuilt when delay_ms changes, with an undebounced fallback if the lib is missing. |
| Async/Promise | `hover.nvim/lua/hover/init.lua:595` | build_async compares a generation counter (line 59) to drop stale results and shows a provisional placeholder after config.placeholder_grace_ms(). |
| Observer | `hover.nvim/lua/hover/bindings/autocmds.lua:143` | CursorHold/CursorMoved/BufLeave/BufWipeout autocmds per buffer, tracked in installed[] and removed by forget() (line 47). |
| Command | `hover.nvim/lua/hover/bindings/usrcmds.lua:148` | M.routes() builds :Hover subcommands as {path, desc, args, run} tables, extended from switches.names() (line 544) and registered via the composer. |
| Specification | `hover.nvim/lua/hover/switches.lua:48` | SWITCHES declares path, implies, auto_type, labels and messages per switch; ORDER (line 159) fixes the display order, and routes and status derive from it. |
| State | `hover.nvim/lua/hover/preview/playback.lua:82` | A single playback state table (playing, clock_pos, gen, timer) with generation guards on async audio callbacks. |
| Memento | `hover.nvim/lua/hover/persist.lua:1` | Only runtime-toggled settings are snapshotted and restored (touch/snapshot/load). |
| Facade | `hover.nvim/lua/hover/init.lua:47` | The M API (show, hide, pin, zoom, set_mode, status...) fronts config, registry, preview/*, cache and autocmds (a 2861-line facade). |

### images.nvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Singleton | `images.nvim/lua/images/win_clipboard_worker.lua:54` | Module-level worker spawned lazily by ensure_worker (201); save_to_file queues requests, send_next (102) serializes one in flight, fail_all resets. |
| Strategy | `images.nvim/lua/images/screenshot.lua:84` | capture_mac/capture_linux/capture_windows selected inside capture() by platform checks. |
| Template Method | `images.nvim/lua/images/convert.lua:293` | run_magick() is the shared run-to-temp, validate, atomic-rename template used by resize, crop, optimise, convert, redact. |
| Chain of Responsibility | `images.nvim/lua/images/init.lua:98` | show() tries OSC 1337 draw, falls back to ASCII blocks when capability is missing, with remote fetch first when the path is a URL. |
| Cache/Memoize | `images.nvim/lua/images/terminal.lua:104` | capability(force) caches the terminal probe result with reset_capability (222); zen.lua:~91 caches crops by file/mtime/rect. |
| Registry | `images.nvim/lua/images/zen.lua:91` | views[win] table plus alive()/active() accessors holds per-window zen state (zoom, selection). |

### insights.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Adapter | `insights.nvim/lua/insights/hover.lua:113` | Registers a position-preview contributor with hover.nvim via registry.register, guarded by pcall and a _registered flag. |
| Registry | `insights.nvim/lua/insights/imports/langs/init.lua:13` | registry/order/tags tables of ImportLang modules sharing scan_source/is_external/rg_prefilter; consumers in imports/init.lua:171 iterate by order. |
| Cache/Memoize | `insights.nvim/lua/insights/imports/index.lua:44` | BufWritePost autocmd (created lazily on first put) marks every cached scan stale; get() never builds. |
| Cache/Memoize | `insights.nvim/lua/insights/symbols/rg_index.lua:180` | get() loads from scan.cache keyed by cwd hash and variant, rebuilds on miss, saves back; ttl and validation live in scan/cache.lua:90. |
| Cache/Memoize | `insights.nvim/lua/insights/todos/init.lua:82` | derived() lazily builds keyword index once and caches it; regex_cache (49) memoizes compiled patterns; M.reset invalidates. |
| Chain of Responsibility | `insights.nvim/lua/insights/symbols/init.lua:20` | get() chooses Treesitter+rg hybrid vs rg-only vs buffer scan from config; get_cwd_ts_lua (106) merges two sources. |
| Facade | `insights.nvim/lua/insights/scan/rg.lua:16` | build_cmd/run wrap ripgrep invocation for all scanners (imports, symbols, todos). |
| Registry | `insights.nvim/lua/insights/symbols/patterns.lua:13` | PATTERNS table plus get_patterns(enabled) filter; a data-driven rule list. |

### language.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `language.nvim/lua/language/translate/providers/registry.lua:21` | PROVIDERS table of translate engines each wrapped once by chunk.wrap(); resolve() (line 40) walks engine then fallback chain. |
| Decorator | `language.nvim/lua/language/translate/chunk.lua:342` | wrap(provider) returns a copy whose translate() splits oversized input into blocks and delegates to the original; transparent to callers. |
| Debounce/Throttle | `language.nvim/lua/language/spell/live.lua:108` | Per-buffer uv timer stopped/restarted on each change; rescans after scan_debounce_ms. |
| Cache/Memoize | `language.nvim/lua/language/translate/markdown/cache.lua:139` | get/set memory cache with lazy disk load, debounced flush via defer_fn (203) and a VimLeavePre autocmd (206). |
| Cache/Memoize | `language.nvim/lua/language/spell/core/cache.lua:58` | Per-buffer native scan cache with get/set/invalidate keyed on buffer plus config. |
| Chain of Responsibility | `language.nvim/lua/language/spell/core/collect.lua:53` | CLI_MODULES maps provider names to modules sharing available()/scan_async(); gather() (196) picks the first available provider from providers.cwd. |
| Adapter | `language.nvim/lua/language/hover.lua:237` | setup() registers the plugin as a contributor with hover.nvim when present; registered() (218) reads state back from hover's registry. |
| Memento | `language.nvim/lua/language/translate/history.lua:81` | Capped, deduped, newest-first history persisted to disk and re-pickable; closest is a recall list, not a full undo Memento. |

### lib.nvim (20)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `lua/lib/nvim/registry/init.lua:53` | Registry class with register/unregister/get/find/validate/loader (class-based, metatable). |
| Registry | `lua/lib/nvim/bindings/usercmd/composer/registry.lua:9` | Composer verbs kept in a lib.nvim.registry instance, giving stable ordering for generated docs. |
| Event Bus | `lua/lib/nvim/hooks/init.lua:146` | hooks.new() builds an event registry with on/off/run, priorities and vetoable events; on() returns an unsubscribe function. |
| Chain of Responsibility | `lua/lib/nvim/bindings/autocmd/dispatcher/init.lua:241` | One autocmd fans out to many keyed handlers (glob keys, priorities, isolation, lazy { load = fn }); a single mediator in front of nvim autocmds. |
| Lazy Initialization | `lua/lib/strategies/lazy.lua:15` | lazy_module returns a setmetatable proxy whose __index/__call require the module on first access. |
| Lazy Initialization | `lua/lib/lua/lazy/init.lua:54` | LAZY.fn requires the target on first call and rebinds the wrapper to the real function. |
| Facade | `lua/lib/strategies/eager.lua:10` | Aggregator LIB table re-exports hundreds of submodule functions under one namespace; lazy.lua and eager.lua are two interchangeable strategies (classless Strategy via module tables). |
| Decorator | `lua/lib/strategies/telemetry_wrap.lua:1` | Wraps the lib aggregate and its submodules with telemetry without changing their API; soft dependency via pcall(require). |
| Null Object | `lua/lib/lua/null/init.lua:19` | Shared NULL sentinel (setmetatable({})) used by json/yaml/xml to represent explicit null, distinct from nil; strictly a sentinel more than a behavioural null object. |
| Debounce/Throttle | `lua/lib/nvim/debounce/init.lua:34` | Closure-based debounce with libuv timer, vim.schedule, cancel; plus a variant counting skipped calls (line 90). |
| Async/Promise | `lua/lib/nvim/async/init.lua:68` | await yields a starter to a coroutine driver (run at :86, wrap at :129); includes Semaphore (:159), Condvar (:210), map_limit (:286). |
| Command | `lua/lib/nvim/ui/kit/history.lua:108` | History snapshots selected state keys and offers back/forward/go (jumplist-like undo stack), with history.CLEAR sentinel. |
| Builder | `lua/lib/nvim/bindings/usercmd/composer/init.lua:257` | make_builder returns a fluent builder (desc/bang/range/count/buffer/route/build) that finalises via register(). |
| Command | `lua/lib/nvim/bindings/usercmd/composer/init.lua:321` | M.verb declares routes (token paths to run handlers) with typed args (register_type at :368), i.e. a command table and subcommand dispatcher. |
| Cache/Memoize | `lua/lib/lua/memo/lru.lua:93` | LRU cache class (get/put/evict), reused by the dispatcher resolved-key cache (dispatcher/init.lua:27); TTL namespaces in nvim/cache/memory.lua:77. |
| Composite | `lua/lib/nvim/progress/init.lua:142` | A progress handle fans out start/update/finish to a list of interchangeable style impls (statusline, echo, fidget, notify, float, kit), each guarded by pcall. |
| Template Method | `lua/lib/lua/class/init.lua:45` | make_class with __index inheritance, init hook, extend and mixin include; used by async Semaphore/Condvar/LatestWins. |
| Template Method | `lua/lib/lua/context_manager/init.lua:49` | with(acquire, release, body) guarantees release around the body; a bracket pattern. |
| Memento | `lua/lib/nvim/checkpoint/init.lua:58` | create/restore/forget/discard of file checkpoints; a persistent memento. |
| Singleton | `lua/lib/nvim/store/init.lua:12` | Every module returns a table M; the store namespace is a thin facade over store.project. Applies repo-wide. |

### lsp.nvim (18)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `lsp.nvim/lua/lsp/integrations/init.lua:32` | ADAPTERS names the optional-plugin adapters; load_all pcall-requires them and capability_contributors (line 107) and attach_hooks (line 123) collect their hooks. |
| Adapter | `lsp.nvim/lua/lsp/integrations/cmp.lua:1` | One module per third-party plugin (cmp, blink, conform, trouble, mason, lazydev, ...) exposing capabilities/on_attach/on_init; the core does not know the plugins. |
| Middleware/Pipeline | `lsp.nvim/lua/lsp/core/capabilities.lua:36` | get() folds ordered contributor functions over the base capabilities, each in pcall, collecting warnings. |
| Dependency Injection | `lsp.nvim/lua/lsp/core/attach.lua:31` | build(opts.hooks) receives on_attach/on_init hook lists from lsp.init instead of requiring plugins; the registry passes a shared table into each server's setup. |
| Registry | `lsp.nvim/lua/lsp/core/registry.lua:25` | setup_all resolves server names to lsp.servers.* (or webdev.*) modules and returns enabled names and warnings. |
| Template Method | `lsp.nvim/lua/lsp/init.lua:68` | step(label, fn) runs each bootstrap phase in pcall and records failures in _warnings; try_module (line 93) does the same for optional modules. |
| Facade | `lsp.nvim/lua/lsp/init.lua:488` | M.setup coordinates config, keymaps, handlers, capabilities, attach, formatter, servers and tools behind one call. |
| Observer | `lsp.nvim/lua/lsp/core/supervisor.lua:582` | LspAttach and VimLeavePre autocmds plus on_exit feed the tracked[] table; backoff() at line 412 and max_attempts (line 496) cap retries; counters reset on survival (line 447). Circuit-breaker-like. |
| Debounce/Throttle | `lsp.nvim/lua/lsp/core/handlers.lua:123` | open_window keeps one uv timer per key and forwards only the last pending publishDiagnostics payload when it fires. |
| Debounce/Throttle | `lsp.nvim/lua/lsp/core/lightbulb.lua:489` | lib.nvim.debounce.new(refresh, debounce_ms) rate-limits the code-action request. |
| Cache/Memoize | `lsp.nvim/lua/lsp/core/workspace_diagnostics.lua:130` | Namespaced memory cache for walked file lists with a TTL; pending callbacks per key coalesce concurrent calls. |
| Cache/Memoize | `lsp.nvim/lua/lsp/core/symbols.lua:75` | Per-buffer symbol cache, dropped on buffer wipe (autocmd at line 365). |
| Cache/Memoize | `lsp.nvim/lua/lsp/core/env_links.lua:1930` | heading_index validates the cache entry with fs_stat; index_cache_order bounds the size; clear_cache at line 1901. |
| State | `lsp.nvim/lua/lsp/core/env_links.lua:990` | block_step advances an explicit LspNvim.EnvLink.Blocks state (lists, comment, fence) line by line (new_blocks at 951). |
| Command | `lsp.nvim/lua/lsp/bindings/usrcmds.lua:313` | dispatch(map, choice, fallback) picks a handler from an action map; switch_route (line 330) shares the toggle/on/off/status/clear behaviour for hints, lightbulb, winbar and implement. |
| Lazy Initialization | `lsp.nvim/lua/lsp/usercmds/init.lua:14` | A table of start/stop/restart/info thunks that lazily require the command modules. |
| Adapter | `lsp.nvim/lua/lsp/completion/blink.lua:24` | Source.__index and setmetatable at line 30 adapt the plugin's completion data to the blink.cmp source interface; register.lua:174 does the same for nvim-cmp. |
| Singleton | `lsp.nvim/lua/lsp/core/supervisor.lua:87` | Module-local state/tracked/expected tables with idempotent setup() that resets the augroup. |

### markdown.nvim (11)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Lazy Initialization | `markdown.nvim/lua/markdown/tables/registry.lua:23` | BUILTIN name list plus M.get (line 44) lazily pcall-requires markdown.tables.formats.<name> and memoizes it; each format module implements scan/parse/render/lossy (Strategy by duck typing) |
| Facade | `markdown.nvim/lua/markdown/tables/registry.lua:133` | M.find (133), M.render (178), M.lossy (204) hide 13 format modules behind one API used by table_convert.lua:78 |
| Facade | `markdown.nvim/lua/markdown/commands/init.lua:25` | subcommand name -> run function table; M.execute (69) dispatches and feature-gates via SUBCOMMAND_FEATURES (line 8); classless Command |
| Mediator | `markdown.nvim/lua/markdown/bindings/autocmds.lua:43` | one FileType autocmd via lib dispatcher; features subscribe with on_filetype (line 76: register/unregister by owner) instead of each adding its own autocmd |
| Debounce/Throttle | `markdown.nvim/lua/markdown/core/table_mode.lua:120` | lib.nvim.debounce.buffer gives a per-buffer 120 ms debounced reformat after edits |
| Debounce/Throttle | `markdown.nvim/lua/markdown/core/refs.lua:268` | M.on_change restarts a uv timer per buffer for live ref reconcile; also autocmds.lua:304 for resize reflow |
| Singleton | `markdown.nvim/lua/markdown/core/table_mode.lua:33` | module-level S[bufnr] holds per-buffer mode state (augroup, busy guard); same shape in refs.lua and render.lua:1001 |
| State | `markdown.nvim/lua/markdown/core/render.lua:242` | scan_fences walks lines with comment/math/fence state and tags each row with a role (open/in/close/cstart/mstart...); implemented with booleans, not objects |
| Cache/Memoize | `markdown.nvim/lua/markdown/core/render.lua:84` | icon_cache memoizes the devicons/mini.icons lookup per filetype |
| Null Object | `markdown.nvim/lua/markdown/commands/export.lua:17` | pdfport() wraps pcall(require) and returns nil when absent; export/image commands are thin delegators to pdfport.nvim / images.nvim |
| Lazy Initialization | `markdown.nvim/lua/markdown/commands/table_list.lua:99` | setmetatable on a picker item whose __index renders the table source only when the preview reads it |

### mdview.nvim (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Chain of Responsibility | `mdview.nvim/lua/mdview/bindings/autocmds/enter_hub.lua:92` | register(owner, spec) with priority puts features on one BufEnter dispatcher; reset() unregisters by owner |
| Debounce/Throttle | `mdview.nvim/lua/mdview/bindings/autocmds/live_push.lua:208` | on_text_changed sends at the leading edge and arms exactly one trailing uv timer (pending_timer, line 225) inside the window |
| Debounce/Throttle | `mdview.nvim/lua/mdview/bindings/autocmds/scroll_sync.lua:117` | on_cursor_moved drops events inside scroll_sync_throttle_ms; selection_sync.lua has a third copy |
| Debounce/Throttle | `mdview.nvim/lua/mdview/bindings/autocmds/spotlight_sync.lua:202` | debounce.new(M.sync_now, DEBOUNCE_MS) with call()/cancel() used from the sync/reset functions |
| Event Bus | `mdview.nvim/lua/mdview/bindings/autocmds/init.lua:22` | teardown() clears the augroup and resets each subscriber; attach() wires bufenter, live_push, scroll_sync, selection_sync into one group |
| Middleware/Pipeline | `mdview.nvim/lua/mdview/core/mirror.lua:75` | M.lines/lines_for_path are the single read entry for preview text, so a display transform hooks in once; a guard spec enforces it |
| Middleware/Pipeline | `mdview.nvim/lua/mdview/core/display.lua:772` | M.stream feeds text through an optional browser.transform hook or language.nvim engine; per-room generation counter discards stale results (line 51 Room) |
| Lazy Initialization | `mdview.nvim/lua/mdview/core/session.lua:38` | entry_mt.__index computes and rawsets the sha256 hash on first read |
| Command | `mdview.nvim/lua/mdview/adapter/ws_client.lua:411` | lane_post queues POSTs per channel+room, drops superseded or same merge_key entries, pumps one curl at a time with a stall watchdog (line 403) |
| Singleton | `mdview.nvim/lua/mdview/core/state.lua:27` | WebKey enum plus getters/setters guard the web_state table; mutations go through validated accessors |
| Factory Method | `mdview.nvim/src/client/transport/transportFactory.ts:35` | createTransport returns a Transport (interface at transport.interface.ts:4) as WebTransport or WebSocket, with silent fallback to WebSocket |
| Memento | `mdview.nvim/src/client/render/history.ts:21` | installHistory pushes one browser history entry per document ping and reopens the document on popstate; viaPopstate flag prevents a loop |
| Builder | `mdview.nvim/native/wasm-render/src/lib.rs:298` | render_markdown wraps comrak (Options built in build_options, line 8) and ammonia::Builder (sanitizer, line 227); Rust uses free functions and no traits/Arc<Mutex> |

### media.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `media.nvim/lua/media/core/registry.lua:20` | Engine registry (register/unregister/get/all, idempotent, insertion-ordered); engines are tables with id/available/transcribe, so duck-typed Strategies. |
| Chain of Responsibility | `media.nvim/lua/media/core/resolver.lua:44` | build_chain() assembles requested/auto/fallback engine ids; resolve() (line 100) takes the first engine whose available()/ready() is true. |
| Lazy Initialization | `media.nvim/lua/media/engines/init.lua:25` | load_all() runs once behind a _loaded flag and pcall(require)s each built-in engine; also lazy-resolved images.nvim is_image in hub/kinds.lua:79. |
| Flyweight | `media.nvim/lua/media/core/dispatcher.lua:203` | inflight[key] jobs are shared; join() adds waiters and returns a cancel handle that only stops the shared run when the last waiter leaves (ref-counted shared job). |
| Object Pool | `media.nvim/lua/media/core/cache.lua:120` | inflight + high/normal/low priority queues + running counter cap concurrent renders (take/dequeue/settle at 168-200); classless. |
| Strategy | `media.nvim/lua/media/output/init.lua:26` | SUBTITLES maps mode to a writer module exposing path()/serialize(); deliver() at line 84 dispatches through it (third format = one line). |
| Composite | `media.nvim/lua/media/hub/actions.lua:44` | TABLE keyed by kind lists action descriptors (id/label/mode/needs_text); run_batch (212) executes a list of them over entries. |
| Null Object | `media.nvim/lua/media/hub/text.lua:148` | M.tool() returns a uniform {ok,tool,reason,fix} descriptor, including an explicit not-ok object for unknown kinds instead of nil. |

### my.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Observer | `my.nvim/lua/my/config/core/observer.lua:25` | Classless observer: on_after_set(ns, fn) with identity de-dup, trigger() at :47 fans out under pcall; hl_config/init.lua:285 and persist subscribe. |
| Middleware/Pipeline | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/init.lua:192` | _build_context walks configurable providers_order (lsp_symbols, ts_symbol, lang_extra, word); first non-empty result wins, disabled or failing providers are skipped. |
| Lazy Initialization | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/init.lua:46` | get_provider() pcall-requires providers by name, memoizes failure as false, and maps the legacy alias lsp_func to lsp_symbols. |
| Strategy | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/base.lua:27` | Dynamic require of ctx.lang.<ft> (lua.lua, javascript.lua) selects the language strategy; not a class, just a module convention. |
| Debounce/Throttle | `my.nvim/lua/my/hl_config/breadcrumbs/ctx/providers/lsp_symbols.lua:275` | Per-buffer debounced documentSymbol request; results cached per changedtick in __lsp_doc_cache (:117). |
| Debounce/Throttle | `my.nvim/lua/my/hl_config/cword_occurrences/init.lua:369` | update_debounced() with a handle recreated in enable() (:383) so debounce_ms changes apply. |
| Sonstige | `my.nvim/lua/my/config/persist.lua:276` | schedule_write coalesces dirty keys into one vim.schedule write with bounded retries; flush() at :327 runs on VimLeavePre. |
| Strategy | `my.nvim/lua/my/guicursor_profile/selector.lua:11` | Preset name looked up in a profiles table and applied; unknown name raises. |

### open.nvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `open.nvim/lua/open/registry.lua:13` | Handler registry _handlers; register() at :22 validates the shape, dispatch() at :88 runs handler.run under pcall and returns (ok, err); keymaps/completion read the live registry (keymaps.lua:61). |
| Factory Method | `open.nvim/lua/open/handlers/browser.lua:96` | make_named_handler builds one handler table per browser (firefox, opera, ...) from a few parameters. |
| Lazy Initialization | `open.nvim/lua/open/init.lua:26` | HANDLER_MODULES maps keys to require paths; handlers are only required when configured (used at :101); each handler module exposes register_all(register_fn). |
| Specification | `open.nvim/lua/open/viewer/init.lua:39` | FILTERS table of predicates (all/urls/mdlinks/files/paths) over links, next to the SORTS set at :31. |
| Cache/Memoize | `open.nvim/lua/open/context.lua:44` | with_cache() makes gather() (:277) return one memoized signals snapshot for the duration of a single open. |
| Registry | `open.nvim/lua/open/bindings/usrcmds.lua:65` | composer.register_type registers OPEN_TARGET, OPEN_SCOPE, VIEWER_SCOPE and VIEWER_KIND completion types (live handler keys). |

### openinnvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Dependency Injection | `openinnvim/src/Program.cs:17` | Hooks is built from OPEN_IN_NVIM_* env vars and passed into Discovery.Find, Spawner.Start and Chooser.Pick, so tests control dry-run, pick index, PATH refresh and pid limits. |
| Chain of Responsibility | `openinnvim/src/Spawner.cs:143` | Wrap() returns SpawnPlan[] in order wezterm, wt, console and the caller tries them in turn; console is the guaranteed last. |
| Result/Option | `openinnvim/src/MsgPack.cs:16` | DecodeStatus {Ok, Incomplete, Malformed} plus DecodeResult (:30) instead of exceptions for the streaming decoder. |
| Sonstige | `openinnvim/src/Discovery.cs:30` | Session : IDisposable owns the RPC connection to the instance that passed the probe. |
| Null Object | `openinnvim/src/Log.cs:14` | Static Log buffers lines in memory; when Init gets no path pending stays null and Line() is a no-op (:28), so call sites never check. |
| Middleware/Pipeline | `openinnvim/src/Config.cs:64` | Parse() switches over known keys; Choice (:103) and Flag (:114) validate and fall back to a default, recording a note instead of failing. |

### pdfport.nvim (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `pdfport.nvim/lua/pdfport/core/registry.lua:17` | register_backend (:17), register_producer (:69) and register_renderer (:122) keep insertion order and O(1) lookup. |
| Chain of Responsibility | `pdfport.nvim/lua/pdfport/core/resolver.lua:65` | resolve() walks build_chain (:24: requested, then config fallback_chain, then registry order) and picks the first backend whose available() is true; composer.lua:153 does the same for producers. |
| Adapter | `pdfport.nvim/lua/pdfport/backends/init.lua:15` | BUILTIN_BACKENDS (pdftotext, docling, marker, ollama, claude, gemini...) all expose available()/extract() behind the registry contract. |
| Lazy Initialization | `pdfport.nvim/lua/pdfport/backends/init.lua:30` | make_lazy_backend returns a setmetatable proxy (:47) that requires the real backend on first field access; producers/init.lua:47 does the same. |
| Cache/Memoize | `pdfport.nvim/lua/pdfport/util/cache.lua:91` | dispatcher.dispatch consults cache.get before running a backend and cache.set after (dispatcher.lua:156 onward); evict_oldest at :72 caps size. |
| Facade | `pdfport.nvim/lua/pdfport/core/dispatcher.lua:156` | dispatch()/open() (:360) hide resolver, cache, backend, progress and renderer behind two calls. |
| Strategy | `pdfport.nvim/lua/pdfport/core/dispatcher.lua:396` | registry.get_renderer(mode) picks buffer, float, system or terminal rendering; failures are isolated with pcall. |
| Adapter | `pdfport.nvim/lua/pdfport/integrations/oil.lua:1` | neotree, nvim_tree, netrw, oil, telescope and fzf each adapt a host plugin to the same hook-up shape; integrations/init.lua:18 is the facade. |

### pickers.nvim (7)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Adapter | `pickers.nvim/lua/pickers/engines/telescope.lua:156` | telescope, fzf and snacks engines each implement pick_files (fzf.lua:193, snacks.lua:123), live_grep, smart, pick_item and pick_dir behind one contract; engines/init.lua:31 load() selects one. |
| Chain of Responsibility | `pickers.nvim/lua/pickers/engines/init.lua:31` | Requested engine first, then telescope, fzf, snacks; try_load (:18) checks mod.available(). |
| Registry | `pickers.nvim/lua/pickers/builtins/init.lua:69` | M.REGISTRY name -> {engine = impl}; names() (:475), supported_engines() (:487) and run() (:503) query it; ENGINE_MODULE (:458) maps engine to native module. |
| Adapter | `pickers.nvim/lua/pickers/keys/init.lua:323` | One resolved key spec is translated by telescope_mappings, fzf_keymap (:330) and snacks_win (:308); entry_actions/adapters/{telescope,fzf,snacks}.lua do the same for actions. |
| Middleware/Pipeline | `pickers.nvim/lua/pickers/engines/patcher.lua:107` | Contributors (CONTRIBUTORS at :46) return functions over the engine's current config; run() merges all contributions, applies them once per engine; entry_actions/patch.lua:34 keeps host entries first. |
| Proxy | `pickers.nvim/lua/pickers/engines/when_loaded.lua:64` | on_require inserts a one-shot package.searchers entry that wraps the real loader and schedules fn after the module loads. |
| Command | `pickers.nvim/lua/pickers/refine/init.lua:142` | Refine handle holds a filter stack plus the remembered full list; quickfix/init.lua:369 applies the stack and :396 restores. |

### recommender.nvim (3)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Strategy | `recommender.nvim/lua/recommender/bindings/usrcmds.lua:53` | ANALYZER_NAMES (regex, treesitter, javascript, python, perf) all expose analyze(threshold, aliases, blacklist, lines); get_analyzer (:130) lazy-requires and memoizes (:123). |
| Command | `recommender.nvim/lua/recommender/bindings/usrcmds.lua:222` | execute() is the single entry point behind :Recommender; classify_pos_args (:157) classifies tokens by content. |
| Observer | `recommender.nvim/lua/recommender/float/autocmds.lua:160` | WinClosed and FileType autocmds drive float cleanup. |

### replacer.nvim (7)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Dependency Injection | `replacer.nvim/lua/replacer/history.lua:156` | history, presets (:174), batch (:239), surround (:431) and command (:712) each register(run_fun) so they never require init back (no cycle). |
| Middleware/Pipeline | `replacer.nvim/lua/replacer/hooks.lua:22` | Four events (before/after apply/write) on lib.nvim.hooks; before_apply may veto a file; on() at :42, run() at :66. |
| Result/Option | `replacer.nvim/lua/replacer/error.lua:49` | safe_call returns {ok, result, err}; typed errors via M.new (:18); rg.collect returns (items, RP_Error/nil). |
| Memento | `replacer.nvim/lua/replacer/checkpoint.lua:98` | create() snapshots files with a manifest, undo() (:160) restores; manifest entries are validated before use. |
| Strategy | `replacer.nvim/lua/replacer/rg.lua:755` | pick_backend chooses ripgrep or vimgrep; collect (:899), collect_async (:930) and collect_streaming (:975) branch on it; post_filter (:884) composes the line-range, word-boundary and code-only filters. |
| Adapter | `replacer.nvim/lua/replacer/pickers/fzf.lua:1` | fzf and telescope pickers share pickers/common.lua (session_open :165, session_result :207) and are selected by init.lua:59. |
| Command | `replacer.nvim/lua/replacer/history.lua:73` | add(request, result) persists each real apply; pick() (:118) replays one. |

### reposcope.nvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Abstract Factory | `reposcope.nvim/lua/reposcope/controllers/provider_controller.lua:27` | providers table (github, gitlab, codeberg) of entrypoints with the same shape (readme_manager, repo_fetcher, cloner, query_builder); _resolve_provider (:57) picks one. |
| Facade | `reposcope.nvim/lua/reposcope/providers/github/entrypoint.lua:8` | Each provider exposes one table bundling its four sub-modules. |
| Strategy | `reposcope.nvim/lua/reposcope/network/clients/http_client.lua:87` | curl, gh and wget modules under request_tools/ share request(); selected by if-chain; auth header built per provider/tool at :32. |
| Cache/Memoize | `reposcope.nvim/lua/reposcope/cache/readme_cache.lua:164` | get()/has() (:179) check RAM first then file, with warm_ram_from_file_cache (:302) and freshness by updated_at (:285). |
| Debounce/Throttle | `reposcope.nvim/lua/reposcope/controllers/provider_controller.lua:85` | README fetch is debounced 100 ms via utils/protection.lua:36 (debounce_with_counter). |
| Registry | `reposcope.nvim/lua/reposcope/state/requests_state.lua:16` | register/start/end_request by UUID; api_client dedupes by UUID. |

### rules-desktop (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `rules-desktop/crates/rules-hub/src/routes.rs:35` | ROUTES: &[(&str, MakeRoute)] is the one list; app_routes (routes.rs:55) folds it into the Router and DATA_ROUTES (lib.rs:95, LazyLock) feeds the security matrix from the same table. |
| Decorator | `rules-desktop/crates/rules-hub/src/bodies.rs:291` | BodiesEngine wraps Arc<dyn Engine> inner, handles Calls::Bodies itself and delegates everything else. |
| Null Object | `rules-desktop/crates/rules-hub/src/bodies.rs:37` | HostProbe trait with CliEngine impl (bodies.rs:58) and NoHost (bodies.rs:49) for the process-per-question engine. |
| Dependency Injection | `rules-desktop/crates/rules-hub/src/locate.rs:23` | Locate trait with ProcessLocator (locate.rs:108); routes depend on the trait. |
| Cache/Memoize | `rules-desktop/crates/rules-hub/src/runtime.rs:306` | sources_body computed once per held snapshot via OnceLock (runtime.rs:128). |
| Specification | `rules-desktop/crates/rules-hub/src/sources.rs:465` | SourcePolicy.classify evaluates every key against a source path and picks the strictest/longest, returning a Verdict; loosens() (sources.rs:264) compares two policies. |
| Command | `rules-desktop/ui/src/lib/app.svelte.ts:651` | command(Command) switch on name with palette/go/search/next/previous/open/escape; escape works as a small chain (palette, detail, selection). Undo via write notice at line 966. |
| Specification | `rules-desktop/crates/rules-hub/src/write.rs:33` | OPS_ALLOWED const list gates which engine ops the page may request; policy.rs:38 apply() builds the next policy as an immutable copy (with_key/with_default). |

### rules.nvim (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Strategy | `rules.nvim/lua/rules/engine/checks/init.lua:21` | BY_TYPE maps grep/file_exists/json_key_absent/lua_predicate to impl.run; unknown type becomes an error result |
| Circuit Breaker | `rules.nvim/lua/rules/engine/checks/init.lua:51` | safe_call turns a crashing check into status 'error' plus findings, so one bad rule does not abort the family run; the status/findings pair is the Result |
| Cache/Memoize | `rules.nvim/lua/rules/engine/checks/grep.lua:76` | cached_readfile memoizes file contents and read errors in ctx for one check_family run |
| Cache/Memoize | `rules.nvim/lua/rules/engine/agent/cache.lua:25` | key = sha256 of system, prompt, provider and model; a changed input gives a new key and an unreadable entry is a miss |
| Command | `rules.nvim/lua/rules/ops.lua:205` | new/set/retire/reinstate/move are operations; each returns an `inverse` op (e.g. line 769, 902); Tx records old bytes and rollback() (212) restores them |
| Template Method | `rules.nvim/lua/rules/ops.lua:1439` | lib.nvim.contract.ops door is configured with an ops table, context() and finish() hooks (line 1467, rebuild catalog once after all ops) |
| Facade | `rules.nvim/lua/rules/api.lua:27` | one door `call(method, request)` with a methods table (hello/snapshot/list/rule/next_id/ops) validated by lib.nvim.contract.api |
| Dependency Injection | `rules.nvim/lua/rules/ui/vault_cmd.lua:117` | M.select overrides vim.ui.select for specs; agent.lua:341 does the same with opts.ask or M.transport falling back to ai.ask |
| Registry | `rules.nvim/lua/rules/ui/vault_routes.lua:116` | register_types registers RULES_VAULT_TARGET/PART with composer argtypes; routes.lua:117 expires_kv uses an __index metatable so help text is read lazily |
| Composite | `rules.nvim/lua/rules/engine/gate.lua:26` | Gate.run concatenates runner.check_family results over a configured list of families |
| Specification | `rules.nvim/lua/rules/engine/runner.lua:47` | predicates_allowed evaluates a policy bool/function per rule; a throwing policy means not trusted |
| State | `rules.nvim/lua/rules/engine/verdicts.lua:461` | stale() is a pure comparison of verdict date and evidence against git changes passed in; accept (408) is the only writer |
| Registry | `rules.nvim/lua/rules/util/sandbox.lua:40` | created_here = setmetatable({}, { __mode = 'k' }) tracks sandboxes without keeping them alive |

### runtime-analysis.nvim (19)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Observer | `runtime-analysis.nvim/lua/runtime-analysis/startup/init.lua:200` | Startup timeline subscribes to VimEnter, User VeryLazy, User LazyLoad and LspAttach via lib.nvim autocmd group, each stamping a mark; classless Observer. |
| Event Bus | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:89` | dispatch() fans one wrapped call out to every subscribed telemetry instance (site.subs), each recording via inst._record. |
| Decorator | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:111` | make_wrapper replaces a function field with a counting/timing wrapper that forwards to the original with varargs; the core idea of the plugin. |
| Registry | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:285` | attach() keeps one site per (container, field) in a weak-keyed table (line 34) so several instances share one wrapper; restored when last subscriber detaches. |
| Registry | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/registry.lua:34` | sites = setmetatable({}, {__mode='k'}) as the global bookkeeping registry; also instances list in telemetry/init.lua:90 with M.get/M.instances (1252-1258). |
| Factory Method | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/init.lua:376` | M.new builds a closure-based instance (no setmetatable) per namespace; M.auto at line 1226 is a convenience factory that wraps and starts. |
| Singleton | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/toggle.lua:34` | module-level `disabled` cache plus on-disk flag acts as global state shared by all callers; same for statusline caches. |
| Facade | `runtime-analysis.nvim/lua/runtime-analysis/init.lua:132` | Top-level setup() hides telemetry.lazy, usercmd registration and lib.nvim deps behind one entry; also runner.lua:116 M.run hides curl+format. |
| Command | `runtime-analysis.nvim/lua/runtime-analysis/bindings/usrcmds.lua:1011` | composer.verb('RA') declares routes = {{path, desc, run}} as a table of command handlers; custom completer types registered at lines 62/79/114 (Strategy-ish). |
| Strategy | `runtime-analysis.nvim/lua/runtime-analysis/curl.lua:107` | VALUE_FLAGS maps curl flag to a kind, then a switch applies it (see candidate); at least the flag classification is table-driven. |
| Strategy | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/report_style.lua:21` | resolve() picks a renderer (kit/preview-tab/mdview/file/html) based on availability, falling back down the chain; renderers live in telemetry/renderers/. |
| Dependency Injection | `runtime-analysis.nvim/lua/runtime-analysis/env.lua:183` | M.select defaults to vim.ui.select but is replaceable by specs; M.choose uses it at line 191. Also soft deps injected via pcall(require) (health.lua:104). |
| Cache/Memoize | `runtime-analysis.nvim/lua/runtime-analysis/statusline.lua:54` | STATUS_TTL_SECONDS whole-status cache and disk_cache (line 60) with expires_at, invalidated by M.invalidate (69) so statusline renders stay cheap. |
| Lazy Initialization | `runtime-analysis.nvim/lua/runtime-analysis/startup/init.lua:155` | get_lazy_cfg() requires lazy.core.config on first use and memoizes the result (or false) in lazy_cfg, since lazy may not be on rtp early; telemetry/command.lua:244 telemetry() also defers require. |
| Adapter | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/lazy.lua:1` | Adapts lazy.nvim's plugin specs and LazyLoad events into telemetry targets (candidates()/configured()); manager-agnostic setup_all.lua consumes only that. |
| Null Object | `runtime-analysis.nvim/lua/runtime-analysis/runner.lua:116` | M.run returns (lines, err, meta) Result-style tuple instead of throwing; run_async delivers the same through a callback scheduled onto the main loop (154-170). |
| Debounce/Throttle | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/init.lua:840` | uv timer fires every flush_interval_ms and hops via vim.schedule into inst.flush(), batching writes instead of writing per call. |
| Sonstige | `runtime-analysis.nvim/lua/runtime-analysis/bindings/usrcmds.lua:213` | pending_token/in_flight/is_current make stale async results no-ops; a logical cancel in a classless Future-like pattern. |
| Template Method | `runtime-analysis.nvim/lua/runtime-analysis/runner.lua:84` | format_response shared by blocking M.run and async M.run_async; only the fetch step differs. |

### sandbox.nvim (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Adapter | `sandbox.nvim/lua/sandbox/core/ports/container_engine.lua:4` | Port with erroring default stubs (abstract-class style); adapters docker, podman, nerdctl implement it; sandbox/init.lua:7 maps engine name to adapter and get_engine() resolves it. |
| Composite | `sandbox.nvim/lua/sandbox/adapters/docker/engine.lua:17` | tbl_extend merges containers/images/volumes/networks/registry sub-engines into one engine object. |
| Chain of Responsibility | `sandbox.nvim/lua/sandbox/init.lua:50` | resolve_engine_name: vim.g override, then .sandboxrc, then config, then engine_utils.get_live_engine (:121) probe. |
| Command | `sandbox.nvim/lua/sandbox/bindings/usrcmds/init.lua:259` | container_routes, image_routes (:490), volume_routes, network_routes, compose_routes, wsl_routes... declare :Sandbox sub-commands as data. |
| Cache/Memoize | `sandbox.nvim/lua/sandbox/bindings/usrcmds/init.lua:66` | cached_names caches daemon queries used for completion. |
| Observer | `sandbox.nvim/lua/sandbox/ui/list_actions.lua:483` | setup_autorefresh runs a per-buffer uv timer guarded by a buffer-local flag. |

### sessions.nvim (5)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Event Bus | `sessions.nvim/lua/sessions/core.lua:459` | announce (SessionsSavePost/LoadPost) and announce_file (:473; Rename/Delete) fire User autocmds with data, any number of listeners, failures isolated. |
| Memento | `sessions.nvim/lua/sessions/layout.lua:32` | capture() serialises the window tree and restore() (:145) rebuilds it; sidecars (meta, buforder, pins) are further mementos. |
| Template Method | `sessions.nvim/lua/sessions/util/sidecar.lua:21` | One write path for meta, buforder and pins; a stale sidecar is removed on failure. |
| Strategy | `sessions.nvim/lua/sessions/picker.lua:275` | pick() tries pick_snacks (:117), then pick_telescope (:190), else errors. |
| Lazy Initialization | `sessions.nvim/lua/sessions/chip.lua:201` | ensure_mounted() mounts the chip on first use; schedule_hide (:177) uses a generation counter to drop stale timers. |

### spotlight.nvim (5)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Observer | `spotlight.nvim/lua/spotlight/core/registry.lua:40` | on_change(fn) with notify_change (:52) calling each listener under pcall; persistence subscribes. |
| Event Bus | `spotlight.nvim/lua/spotlight/core/events.lua:97` | changed() merges reasons into one pending payload and flushes one User SpotlightChanged per tick via vim.schedule. |
| Repository | `spotlight.nvim/lua/spotlight/core/registry.lua:551` | The registry is the item store (add, find_by_text, find_at); snapshot() and restore() (:491) serialise it, restore bypasses listeners. |
| Debounce/Throttle | `spotlight.nvim/lua/spotlight/persist.lua:143` | save() builds a lib.debounce saver on first use and calls .call(). |
| Memento | `spotlight.nvim/lua/spotlight/sets.lua:153` | save/switch (:212)/delete (:226) store and restore named spotlight sets. |

### streamtap (8)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Command | `streamtap/desktop/crates/streamtap-sink/src/main.rs:200` | Header enum Hello/Segment/Event decoded by serde tag; handle_connection (main.rs:809) matches (header, session) pairs as a small state machine (before hello, after hello). |
| Sonstige | `streamtap/desktop/crates/streamtap-sink/src/main.rs:376` | Budget charges bytes via compare_exchange; Refusals (main.rs:411) is a mutex-guarded bounded FIFO set shared across connections. |
| Result/Option | `streamtap/desktop/crates/streamtap-sink/src/main.rs:957` | Admit Skip/Write/Mark returned by TrackState::admit_media (main.rs:1083); Probe enum (main.rs:2995) does the same for ffprobe. |
| Registry | `streamtap/desktop/crates/streamtap-sink/src/proc.rs:46` | Tool enum is the closed verb set; Tools.program(tool) (proc.rs:116) resolves path overrides so tests substitute binaries. |
| Prototype | `streamtap/extension/src/hook.js:471` | patch(proto, name, make) wraps MediaSource/SourceBuffer methods (e.g. appendBuffer at hook.js:712), calls the original, then reports, swallowing hook errors. |
| Sonstige | `streamtap/extension/src/sink-link.js:341` | Reconnect delay doubles to 10 s and resets only after a socket stayed open SINK_STABLE_MS; linkSend (sink-link.js:360) queues while connecting with byte caps. |
| Async/Promise | `streamtap/extension/src/content.js:313` | link.chain = link.chain.then(...) serialises segment posts per MediaSource while a queuedBytes budget drops overflow. |
| Facade | `streamtap/desktop/crates/streamtap-app/src/main.rs:63` | AppState wraps Inner with poison-tolerant lock; ten #[tauri::command] fns (main.rs:156 onward) are the facade for the UI; KillOnClose (jobs.rs:20) is an RAII guard for child lifetime. |

### takt (6)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Strategy | `takt/crates/takt-clock/src/lib.rs:62` | Clock trait with AudioMasterClock, WallClock, TimelineClock; ClockKind (lib.rs:49) tags the mode and may_drop encodes policy differences. |
| Bridge | `takt/crates/takt-backend/src/lib.rs:85` | VideoBackend trait; NullBackend (null.rs:152) is the synthetic implementation that also acts as Null Object/test double until a real decoder exists. |
| Object Pool | `takt/crates/takt-core/src/frame.rs:214` | FramePool hands out PooledFrame (frame.rs:169) that returns to the pool in Drop (frame.rs:195); bounded capacity returns None instead of allocating. |
| Dependency Injection | `takt/crates/takt-clock/src/anchor.rs:49` | MonotonicSource trait with SystemMonotonic and ManualMonotonic, injected as Arc<dyn MonotonicSource> into every clock for deterministic tests. |
| Sonstige | `takt/crates/takt-clock/src/audio_master.rs:180` | AudioClockWriter is deliberately not Clone and handed out once (writer_taken swap, audio_master.rs:74); AnchorCell (anchor.rs:130) is the seqlock cell. |
| Result/Option | `takt/crates/takt-backend/src/scheduler.rs:27` | Presentation Shown/Repeated/Eof returned by Scheduler::accept (scheduler.rs:122); core uses its own Result alias (takt-core/src/error.rs:12). |

### tasks-desktop (11)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Strategy | `tasks-desktop/crates/tasks-hub/src/editor.rs:20` | FileOpener trait (open/reveal/pick_folder) with TerminalOpener (editor.rs:215); pure plan() functions take os and a `find` closure so they test without spawning. |
| State | `tasks-desktop/crates/tasks-hub/src/server/check.rs:9` | CheckJob Idle/Running/Done/Failed with to_json; one check at a time, dropped with the vault. |
| Debounce/Throttle | `tasks-desktop/crates/tasks-hub/src/server/check.rs:217` | follow_changes waits for a quiet period and a minimum gap after store changes, only while an event stream listens; AutoCheckTiming at line 150. |
| Registry | `tasks-desktop/crates/tasks-hub/src/server/mod.rs:235` | app_routes builds the axum Router from named IDENTITY routes. |
| Specification | `tasks-desktop/crates/tasks-hub/src/classes.rs:345` | AreaPolicy.shown/allows decides fail-closed whether an area may be used (Use enum at line 59); Classes (line ~190) holds one policy per vault. |
| Command | `tasks-desktop/ui/src/lib/app.svelte.ts:1190` | inverseOf(result) computes the ops that take back a write; undo() (line 1289) replays them from the toast. Classless TS; no history stack, only the last write. |
| Debounce/Throttle | `tasks-desktop/ui/src/lib/app.svelte.ts:3230` | scheduleTextSearch clears the timer and aborts the previous AbortController, 250 ms first try, 1500 ms retry. |
| Adapter | `tasks-desktop/ui/src/web/hub.ts:165` | createWebHub answers the Rust hub's routes inside the page from the engine worker, behind the same fetch the Hub client takes; HubDeps (line 26) is the injected dependency set. |
| Async/Promise | `tasks-desktop/ui/src/web/vault-session.ts:172` | exclusive() chains every read/write of the folder onto one promise tail so a re-read never sees half a write; idle() (line 184) waits for it. |
| Async/Promise | `tasks-desktop/ui/src/web/client.ts:68` | WorkerClient.ask keeps a pending Map<id, resolver>; WorkerRequest/WorkerReply union in worker.ts:16 is the protocol. |
| Command | `tasks-desktop/ui/src/lib/paletteActions.ts:11` | Builds a list of {key,label,run} closures depending on current state; only possible actions are listed. |

### tasks.nvim (13)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Lazy Initialization | `tasks.nvim/lua/tasks_nvim/init.lua:96` | setmetatable __index requires submodules on first access and rawsets them; facade plus lazy load. |
| Facade | `tasks.nvim/lua/tasks_nvim/done_flow.lua:1` | Single entry for finishing a task (mutate.done plus plan/marker/next chain); command, dashboard and CLI all call run. |
| Command | `tasks.nvim/lua/tasks_nvim/ops.lua:1371` | HANDLERS name->function and FIELDS schema per op (:143), assembled into ops registry at :1393 for the tasks-ops/1 door. |
| Command | `tasks.nvim/lua/tasks_nvim/cli.lua:950` | commands.<verb>(ctx) functions with SPECS option table at :173. |
| Registry | `tasks.nvim/lua/tasks_nvim/ui/routes.lua:227` | register_types registers TASK_AREA, TASK_ID, TASK_QUERY etc with validate/complete; idempotent register() in bindings/usrcmds/init.lua:16. |
| Debounce/Throttle | `tasks.nvim/lua/tasks_nvim/ui/dash_watch.lua:253` | Watcher class with injected start/schedule/now (DI for tests); debounced on_refresh at :300; the dashboard wires it at ui/dash.lua:1173. |
| Dependency Injection | `tasks.nvim/lua/tasks_nvim/ui/dash_watch.lua:262` | opts.start/schedule/now defaulted then injectable; also ci.lua run_lint, and M.select_task/M.select overrides at ui/cmd.lua:2244. |
| Cache/Memoize | `tasks.nvim/lua/tasks_nvim/fsio.lua:68` | read_scope caches stat/lstat/realpath per coroutine, dropped on write (drop_cache :53); used by contract.lua:365. |
| Sonstige | `tasks.nvim/lua/tasks_nvim/soft.lua:14` | Single probe for optional plugins (pcall require plus required fields); callers fall back. |
| Memento | `tasks.nvim/lua/tasks_nvim/mutate.lua:2334` | rollback_done restores from checkpoint snapshots when a multi-file done fails midway. |
| Null Object | `tasks.nvim/lua/tasks_nvim/mutate.lua:39` | M.REMOVE sentinel marks field removal in patches (distinguishes from nil). |
| Result/Option | `tasks.nvim/lua/tasks_nvim/ops.lua:1391` | Operations answered with a tasks.result document, one entry per op; (nil, err) convention throughout. |
| Middleware/Pipeline | `tasks.nvim/lua/tasks_nvim/ci.lua:1` | Ordered steps check, index --check, md_lint with injectable run_lint. |

### terminal.nvim (7)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Dependency Injection | `terminal.nvim/lua/terminal/backends/tmux.lua:96` | native, tmux and wezterm (wezterm.lua:95) all build a Terminal.Backend (spawn, send, probe, focus, capture, list, close); tmux/wezterm take an injectable runner (default_runner :63) so specs run without a real multiplexer. |
| Registry | `terminal.nvim/lua/terminal/core/registry.lua:24` | Registry.new() returns a metatable instance (add/get/find/find_by_buf); no module-level state. |
| Lazy Initialization | `terminal.nvim/lua/terminal/init.lua:122` | multiplexer(name) validates against backends.MULTIPLEXERS, probes available(), caches the instance and remembers unavailability reasons. |
| Sonstige | `terminal.nvim/lua/terminal/backends/init.lua:28` | detect() builds the innermost-first list via Env.SIGNALS; resolve() (:51) falls back to native with a note. |
| Event Bus | `terminal.nvim/lua/terminal/events.lua:23` | fire() emits TerminalCommandPost and TerminalExitPost via nvim_exec_autocmds. |
| Debounce/Throttle | `terminal.nvim/lua/terminal/status/init.lua:30` | EXPORTERS table (tmux, wezterm) of module and env signal; failing exporters are switched off after one notice; publish is debounced (:218). |
| Result/Option | `terminal.nvim/lua/terminal/core/exec.lua:60` | result() normalises vim.system output to {code, stdout, stderr}, folding signals into code 128+signal. |

### testing.nvim (22)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Lazy Initialization | `testing.nvim/lua/testing/dialect/init.lua:89` | LOADERS table maps dialect name to a lazy loader returning run_file; M.get (line 123) resolves, M.run_file (line 139) dispatches; unknown name becomes a visible error case. |
| Registry | `testing.nvim/lua/testing/report/init.lua:16` | REPORTERS name->module map; resolve (line 38) does pcall(require) so term/github/junit/agent are interchangeable render(result, opts) strategies. |
| Registry | `testing.nvim/lua/testing/guard/init.lua:107` | GUARD_MODULES + config.ORDER; the install loop at line 221 builds each guard with require(...).new(h, gcfg) and rolls back all on failure. |
| Observer | `testing.nvim/lua/testing/state.lua:673` | State.subscribe returns an unsubscribe closure; emit (line 684) calls subscribers under pcall so one failing listener cannot hurt the others. Classless, closure-based. |
| Composite | `testing.nvim/lua/testing/bindings/usrcmds.lua:611` | M.routes() declares the :Testing subcommand tree as data (path, args, flags, run fn); the same tree drives dispatch and completion. |
| Object Pool | `testing.nvim/lua/testing/run/pool.lua:163` | Pool:acquire/release/shutdown lend warm child editors with a FIFO waiter queue; a leaking or crashed member is discarded instead of returned. |
| Dependency Injection | `testing.nvim/lua/testing/run/pool.lua:115` | self.opts.rpc or require('testing.rpc'): the RPC layer is injectable for specs. Similar: cli.main(argv, services) with services.trust (cli.lua:838) and watch opts.clock. |
| Strategy | `testing.nvim/lua/testing/isolation/init.lua:54` | M.backend() picks the guard layer's soft_backend when it validates, else the internal snapshot backend; capture/diff/restore is the shared interface. |
| Memento | `testing.nvim/lua/testing/isolation/snapshot.lua:1` | capture() returns a plain-table snapshot of modules, globals, options, autocmds and keymaps; diff entries know how to restore themselves; used by the warm pool reset. |
| Adapter | `testing.nvim/lua/testing/dialect/busted.lua:439` | Dialect modules adapt busted, luassert and the harness A/B/C/D styles to one run_file(a, spec, opts) -> cases signature; harness_conventions adapts differing failure conventions. |
| Decorator | `testing.nvim/lua/testing/guard/patch.lua:33` | Patcher:wrap replaces tbl[key] with make(orig) and keeps a stack to undo in reverse order; every guard (fs, prompt, clock, process_net) wraps editor APIs through it. |
| Registry | `testing.nvim/lua/testing/dialect/harness_conventions.lua:182` | M.register(convention) appends to CONVENTIONS; each convention supplies optional hooks (classify, fail_line, counters) that are resolved into one adapter. |
| Observer | `testing.nvim/lua/testing/hover/init.lua:425` | try_register reads package.loaded['hover.registry'] without requiring it (line 400) and retries on VimEnter or a User autocmd (lines 448-449). |
| Debounce/Throttle | `testing.nvim/lua/testing/run/watch.lua:162` | Watch:due fires after debounce_ms of quiet, or after max_wait_ms regardless; clock is injectable. |
| Builder | `testing.nvim/lua/testing/core/result.lua:98` | new_run/new_case/add_case/finish_case/finalize assemble the Result-IR step by step; finish_case turns a case without assertions into a failure. |
| Facade | `testing.nvim/lua/testing/cli.lua:838` | cli.main(argv, services) is the single entry that parses args, applies trust, loads config and delegates to run/ci/stamp/surface subsystems. |
| Chain of Responsibility | `testing.nvim/lua/testing/deps.lua:156` | resolve tries $<NAME>_DIR, .deps/, sibling checkout, then the lazy data dir in fixed order; the first valid one wins and all four are named on failure. |
| Cache/Memoize | `testing.nvim/lua/testing/cache/hash.lua:152` | Hasher object keeps a hash index with lazy load (Hasher:load, line 166) so unchanged files are not re-hashed; entry store validates on read (cache/store.lua). The conformance runner also memoizes sources (conformance/runner.lua:94). |
| Null Object | `testing.nvim/lua/testing/guard/init.lua:38` | M.CANCEL is a unique sentinel table with __tostring that stands for a cancelled prompt, distinct from nil or an empty string. |
| Singleton | `testing.nvim/lua/testing/statelock.lua:86` | M.with(path, fn) takes an O_EXCL lock file around read-modify-write of state files, with stale takeover and a timeout. Module-level state is used widely (trust.lua armed context at line 465, hover registered flag). |
| Middleware/Pipeline | `testing.nvim/lua/testing/conformance/catalog.lua:14` | ORDER lists k01..k16 check modules that share a Ctx and run through one runner; checks/common.lua holds shared steps. |
| Result/Option | `testing.nvim/lua/testing/args.lua:590` | Options are data records (name, long, kind, field, min, help) walked by one parser at args.lua:1105; the same records feed help and completion. |

### ui.nvim (14)

| Pattern | Fundstelle | Begruendung |
|---|---|---|
| Registry | `ui.nvim/lua/ui/tabline/styles.lua:92` | register/unregister map a name to a chip-boundary decorator function. cfg.style resolves through it, so hosts can add styles without patching. Old names stay as aliases. |
| Registry | `ui.nvim/lua/ui/config/variants.lua:44` | register/unregister/list for statusline variants. Same shape as tabline.styles, and :UI variant completes over list(). |
| Lazy Initialization | `ui.nvim/lua/ui/slots/kinds/registry.lua:80` | Kinds are tables with apply/validate/render/preview/persist, validated by check_kind. Built-ins load lazily via ensure_builtins (line 41). Hosts add kinds through register() or setup({kinds=...}). |
| Null Object | `ui.nvim/lua/ui/slots/kinds/registry.lua:196` | M.apply validates the slot, builds the context, then pcalls kind.apply. It turns errors into false,err so one bad kind cannot break a view. render() (line 215) falls back for an unregistered kind. |
| Observer | `ui.nvim/lua/ui/slots/store.lua:704` | on_change(fn) returns a listener id and off(id) removes it. emit() (line 93) bumps a revision and calls listeners under pcall. The views subscribe to it. |
| Chain of Responsibility | `ui.nvim/lua/ui/vim_ui/init.lua:190` | M.select goes to confirm buttons if n<=buttons_max and they fit, then to the kit chooser if n<=chooser_max, else to the fallback_select. The fallback is also taken on passthrough kinds and when a float cannot open. The original vim.ui.select is kept as the fallback (Decorator/Proxy of the previous function). |
| Lazy Initialization | `ui.nvim/lua/ui/health.lua:39` | A setmetatable proxy forwards to vim.health at call time so tests can stub it. menu/icons.lua:38 uses the same trick to resolve nerd-font glyphs lazily. |
| Template Method | `ui.nvim/lua/ui/slots/kinds/lua.lua:32` | The slot context is a table with an __index function that resolves placeholders on demand. file.lua:148 and expand.lua:94 do the same, layering on a base context (prototype-style delegation). |
| Adapter | `ui.nvim/lua/ui/kit/history.lua:3` | Most ui.kit.* files are one-line re-exports of lib.nvim.ui.kit.* (async, sidebar_state, toast, viewer and others), a thin facade giving one module name for both namespaces. kit/async.lua is the coroutine-based async/await layer over the callback components. |
| Registry | `ui.nvim/lua/ui/statusline/utils/clickable.lua:58` | register(handlers) returns an integer id that the statusline %@ click protocol resolves via the UiSlClick global. render.lua:~45 caches one id per key (generic_click_id), so the registry does not grow on every redraw. |
| Registry | `ui.nvim/lua/ui/statusline/catalog.lua:1` | A plain data list of segments (key, source, requires, used_by, essential, live). render.lua:221 pcall-requires entry.source on demand. The order/modules walk is a Pipeline-style composition. |
| Strategy | `ui.nvim/lua/ui/context/init.lua:1330` | draw() picks draw_chips or draw_mimic by cfg.style. This is a two-way if/else, a hard-wired Strategy. |
| Memento | `ui.nvim/lua/ui/tabline/reopen.lua:152` | A ring of recently closed file buffers is kept and reopened with M.reopen(entry). |
| Debounce/Throttle | `ui.nvim/lua/ui/context/init.lua:1437` | build_refresher wraps refresh in lib.nvim.debounce.new with cfg.debounce_ms. The theme picker preview uses the same (bindings/usrcmds/themes/picker.lua:83). |

## 5 Kandidaten nach Pattern

Aufwand XS/S/M/L; `Lohnt` = yes (klarer Nutzen) oder marginal (nur bei Gelegenheit, bewusst als schwach markiert).

### Builder (1)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| takt | `takt/crates/takt-backend/src/null.rs:55` | NullBackend::new takes five positional arguments (meta, rate, duration, pattern, pool capacity) and tests/player repeat them. A builder or Default config is only worth it once a real backend adds options. | XS | marginal |

### Factory Method (1)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| lsp.nvim | `lsp.nvim/lua/lsp/bindings/actions.lua:304` | hints_toggle/toggle_filetype/on/off (304-350) and lightbulb_* (356-402) are near-identical, and format_*/workspace_* follow the same shape. A make_switch_actions(loader) factory would remove roughly 100 lines and the repeated empty-filetype warning. | S | yes |

### Facade (6)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| docmap.nvim | `docmap.nvim/lua/docmap/core/check.lua:164` | 2409-line file with about 24 independent check_* functions; one module per check group registered into the check table would keep each reviewable. | M | marginal |
| docmap-desktop | `docmap-desktop/src-tauri/src/main.rs:607` | 5827-line main.rs holds about 60 tauri commands plus workspace, clone/import, and link-walk logic; split into command modules (workspace, import, engine, nvim) with main.rs only wiring generate_handler!. | M | yes |
| docmap-desktop | `docmap-desktop/src/main.js:1244` | About 69 inline invoke("name", {...}) calls; a lib/ipc.js with one function per command centralizes names, argument shapes and error mapping (cf. lib/contract.js). | M | marginal |
| hover.nvim | `hover.nvim/lua/hover/init.lua:1058` | M.show spans about 270 lines (1058-1330) and present() about 190 lines; the file is 2861 lines. Splitting by concern (show flow, pin/dir-nav, zoom, mode/switch API) would improve readability and test isolation. | L | marginal |
| insights.nvim | `insights.nvim/lua/insights/symbols/open.lua:45` | Picker selection (fzf/telescope/scratch/snacks/qf) is re-implemented in symbols/open.lua:45, todos/init.lua:405, imports/init.lua:811, with two different default_ui() (symbols/open.lua:31, todos/init.lua:338) and diverging fallbacks; one insights.ui.open(entries,title,ui) with a backend table fixes it. | S | yes |
| streamtap | `streamtap/desktop/crates/streamtap-sink/src/main.rs:1` | One file holds protocol parsing, DRM detection, Session/TrackState, index rows, tfdt rewriting, mux planning and ffprobe probing (5623 lines, 900+ of them tests). Splitting into modules (wire, init detection, session, mux) would keep proc.rs/error.rs style and make the Container enum above natural. | M | yes |

### Chain of Responsibility (1)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| gopath.nvim | `gopath.nvim/lua/gopath/resolve.lua:32` | resolve_at_cursor is about 150 lines of hand-written stages with repeated pcall(require) boilerplate and config gating. Expressing the stages as an ordered list of {name, enabled(cfg), run} would remove the boilerplate and let the Lua pipeline and :GopathProbe report which stage matched. Stage 3 is special (a held fallback), so keep that handled explicitly. | S | yes |

### Command (13)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| lib.nvim | `lua/lib/nvim/logger/command.lua:44` | LibLogger subcommands (on/off/level/dump/clear/tags/show) are a six-branch elseif on a string; a subcommand table also gives completion for free (or use the library's own composer, which already supports routes). | S | marginal |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/command.lua:920` | The :RATelemetry callback is one ~350-line if/elseif chain on `first` (reset/start/stop/flush/disable/status/coverage/export/startup/flamegraph/cost/snapshot...). A subcommands table name -> handler(mod, rest) (or composer.verb routes like :RA already uses in usrcmds.lua:1011) would flatten it and give completion for free. | M | yes |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/init.lua:376` | M.new is a single closure of roughly 1300 lines (start/stop/flush/report/wrap...) all sharing locals; splitting into sub-modules (recorder, flusher, wrapper-manager) with explicit state tables would improve testability, but the closure state sharing makes it costly. | L | marginal |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/cli.lua:952` | commands.lists branches on sub (ls/show/save/delete/rename) with repeated usage-check and error-print boilerplate, in a 2192-line file. A subcommand table {min_args,max_args,run} with one shared usage/error wrapper removes the repetition. | S | yes |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/cli.lua:1885` | Print of rule-sync plan items is an elseif chain on action to tsv line; a small formatter table action->format is clearer. | XS | marginal |
| docmap-desktop | `docmap-desktop/src/main.js:2151` | Large message/menu handlers dispatch on string ids; verify whether they use if chains and, if so, a handlers map keyed by id would simplify them (not fully confirmed). | S | marginal |
| ui.nvim | `ui.nvim/lua/ui/slots/view/chips.lua:810` | on_pointer is an if/elseif chain on base and item.kind (up/down/slot) with embedded actions. A small table keyed by base then kind would work, but the chain is only about 10 lines. Low value, listed for completeness. | XS | marginal |
| markdown.nvim | `markdown.nvim/lua/markdown/commands/init.lua:25` | Subcommands live in three parallel tables (commands at 25, SUBCOMMAND_FEATURES at 8, sub_complete at 101); the file's own comment says a missing entry once broke `format`. One table of {run, complete, nested, features} removes the sync hazard | S | yes |
| rules.nvim | `rules.nvim/lua/rules/init.lua:204` | check_family, check_family_json, check_family_work_list and the run_gate* trio (lines 204-306) are six near-identical wrappers over run_family/run_gate_results differing only in output (quickfix+buffer, JSON, work list); a sink/format table would make it 2 runners plus 3 sinks | S | marginal |
| fileops.nvim | `fileops.nvim/lua/fileops/bindings/usrcmds.lua:633` | dispatch() is a ~150-line elseif chain over ~20 subcommands that composer routes then re-enter via fargs_of; a table subcmd to handler(ctx) cuts the double-dispatch and the reconstruct step. | M | yes |
| emojis.nvim | `emojis.nvim/lua/emojis/commands.lua:91` | execute() is a 12-branch elseif/if chain and composer routes forward() back into it by rebuilding fargs; direct per-action handlers keyed by name would remove the round trip (unicode.dispatch at unicode/init.lua:375 has the same shape). | S | yes |
| my.nvim | `my.nvim/lua/my/hl_config/init.lua:84` | after_set is a 100-line if/return chain over key names; a table of key (or prefix) -> handler would shrink it, make each feature's mapping data and remove the repeated State.set_enabled plus enable(cfg) shape. | S | yes |
| recommender.nvim | `recommender.nvim/lua/recommender/bindings/usrcmds.lua:222` | execute() is about 300 lines of closures mixing arg validation, scope resolution, state/refresh and rendering; splitting into resolve-request, collect, and present steps (State object for ignored/visible) would make it testable. | M | yes |

### Iterator (1)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/dashboard/view.lua:1129` | _run_bulk is a ~200-line closure holding queue, running count, cancel, generation, lock-retry and pump inside a 2579-line view; a dashboard/bulk.lua runner with injected redraw/action callbacks would be unit-testable without a buffer and shrink view.lua | M | yes |

### Mediator (1)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| docmap-desktop | `docmap-desktop/src/main.js:144` | 5196-line main.js with about 25 top-level mutable lets (engine, projects, selectedId, mapTab, mapWatch...) mutated from many render/select functions; extract a small state store with subscribe so renderers react instead of being called imperatively. | L | yes |

### State (3)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| lsp.nvim | `lsp.nvim/lua/lsp/core/env_links.lua:1` | 2233 lines mix link parsing (446-715), a markdown block state machine (859-1185), a heading slugger (1402-1900) and an index cache plus preview (1901-2233), all in one module. Splitting into env_links/{parse,blocks,headings}.lua behind the current M facade would give each part its own spec. | M | yes |
| markdown.nvim | `markdown.nvim/lua/markdown/core/render.lua:242` | scan_fences carries comment/math/fence as parallel booleans and role strings, followed by role if-chains at lines 769-830; a table of block kinds with open/close predicates and render handlers would let new block types be added in one place | M | marginal |
| tasks-desktop | `tasks-desktop/ui/src/lib/app.svelte.ts:206` | The App class is about 3250 lines with write, undo, search, bulk, views and routing; lib/state/ already holds check, vaults, views and matrix. Moving write/undo and search into further state classes would continue that direction. | L | marginal |

### Strategy (27)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/command.lua:617` | open_report's inner dispatch is an if/elseif on resolved style (mdview/preview-tab/file/html/kit), each with its own 'warn then fall back to kit float' code, while report_style.lua already resolves the name. A table style -> opener returning ok,err with one shared fallback would remove the duplicated fallback blocks. | S | yes |
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/curl.lua:215` | VALUE_FLAGS already classifies flags into kinds, but a second if/elseif chain applies each kind; map kind -> apply(state, value) so adding a flag is one table row. Chain is only 7 branches, so gain is modest. | XS | marginal |
| testing.nvim | `testing.nvim/lua/testing/run/project.lua:907` | Mode selection is by conditionals (prep.mode == 'off' and similar) spread through project.lua, with isolated.lua and inproc.lua exposing parallel but separately shaped M.run functions. A small runner interface (run, list_case_ids, begin_listing) chosen once would replace the scattered branching. | M | marginal |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/clipboard.lua:585` | M.value is a 20-branch if/elseif on field key, and ui/insert.lua:94 repeats near-identical branches (snow, link, title, company). One shared FIELDS table key->resolver(entry,meta) removes duplication and gives completion the key list for free. | M | yes |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/open_targets.lua:139` | elseif chain on target (links/solution/stream/snow/resolve/folder); a table target->resolver lets describe() and completion reuse the same keys. | S | marginal |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/anonymize_rules.lua:210` | Rule-file parser dispatches on verb with a 22-branch elseif; pattern and regex branches (:235 and :270) are near duplicates differing in the matcher. A VERBS table with shared validate helper would cut the duplication. | M | yes |
| casedesk.nvim | `casedesk.nvim/lua/casedesk/plan.lua:122` | describe() branches on action kind, and apply.lua repeats the same kind switch. A kind->{describe,apply} table keeps the two in sync when a kind is added. | S | marginal |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/mutate.lua:660` | The patch normaliser is a ~150-line if/elseif on key (title, status, kind, prio, effort, ... order). A FIELD_NORMALIZERS[key](value)->(string/nil, err) table makes each field testable, mirrors ops.lua FIELDS, and the SETTABLE list derives from its keys. | M | yes |
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/cli.lua:739` | plan and quick-wins commands each branch on format ids/tsv/md (:742, :837) with the same shape. A shared renderers table format->fn(report) would let new formats apply to every listing command. | S | marginal |
| ui.nvim | `ui.nvim/lua/ui/context/init.lua:1330` | context/init.lua is 1896 lines with draw_mimic and draw_chips (about 340 lines) behind a string if/else. A styles table like tabline/styles.lua, or splitting the chip renderer into its own module, would shrink the file and let hosts add styles. Splitting the file is the main gain. A registry only pays off if a third style is wanted. | M | marginal |
| hover.nvim | `hover.nvim/lua/hover/init.lua:632` | build() is a roughly 110-line if/elseif ladder on target.type, running after registry.preview_for(type). Register the built-ins (missing, directory, file, image, pdf, office, video, git, url) in the same registry or a local table keyed by type. A new type then no longer edits init.lua. | M | yes |
| gopath.nvim | `gopath.nvim/lua/gopath/commands.lua:154` | res.kind == 'help'/'url'/file ladders are repeated in check (154-163), copy_location (198-206), open/init.lua:58 and the open-mode checks. A KIND_HANDLERS table with open/check/copy_text per kind would put the knowledge of each result kind in one place. | S | marginal |
| gopath.nvim | `gopath.nvim/lua/gopath/open/init.lua:50` | M.open mixes mode == 'explorer' and mode == 'filetree' special cases with the PLACEMENT table. Moving these into a MODE_HANDLERS table (like PLACEMENT) would shorten the function, but there are only two special modes. | XS | marginal |
| cascade.nvim | `cascade.nvim/lua/cascade/lists/marker.lua:149` | The digit/ascii/roman if/elseif on marker kind is repeated in marker.lua:149 and :317, shape.lua:58 and :80, and sequence/renumber.lua:49; one table kind -> {parse, to_int, to_token, next} would add a kind in one place. | M | yes |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/core/shell.lua:303` | get_shell_history parses via an if/elseif per shell (zsh, bash/ksh/csh, fish, nu, powershell, fallback) and line_matches_command (:351) repeats the shell knowledge; a SHELLS[name] = {parse_line, line_matches} table keeps the two in sync (they must mirror each other today). | S | yes |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/ops/filepath.lua:25` | opts.mode if/elseif (abs/nvim/repos/env) mirrors location.lua:34-38; a MODES[mode] resolver table would let both reuse one registry and be extended without editing the chain. | S | marginal |
| buffer-ctx.nvim | `buffer-ctx.nvim/lua/buffer_ctx/commands.lua:69` | sink_text and sink_lines duplicate the clip.copy + notify block; making sinks objects {text=fn, lines=fn} (or having sink_lines join and call sink_text) removes the copy. | XS | marginal |
| media.nvim | `media.nvim/lua/media/hub/text.lua:148` | The audio/video / image / pdf if-chain on kind repeats in text.lua at 148-151, 167, 273-284, 318, 350 and hub/dashboard.lua:121; a KIND_HANDLERS table (tool, modes, run, sidecar_title) would make a new kind one entry instead of five edits. | S | yes |
| images.nvim | `images.nvim/lua/images/paste.lua:75` | clipboard_to_file (Windows worker or powershell / pngpaste / wl-paste / xclip) and screenshot.lua:84-283 each branch on OS separately; a single images.platform backend table with clipboard_image() and capture() per OS would keep each OS in one place. | M | marginal |
| diff.nvim | `diff.nvim/lua/diff/core/init.lua:459` | The prompt/file/clipboard/stat branches inside the buffer-output code each call a render.* function with the same six arguments and finish_text_output; an OUTPUTS[output](ctx) table would shrink the large execute pipeline and make outputs addable. | S | marginal |
| emojis.nvim | `emojis.nvim/lua/emojis/actions.lua:122` | clear/replace/unreplace/wrap selection is duplicated in actions.edit (122-130) and search.apply_across_files (search.lua:93-96, which silently treats everything but clear as replace); a shared ops.apply(action, lines, cfg) removes the drift risk. | XS | yes |
| reposcope.nvim | `reposcope.nvim/lua/reposcope/network/clients/http_client.lua:87` | Request-tool selection (:87) and _build_auth_header (:32) are if/elseif chains on tool and provider; two small lookup tables (tool -> module, provider -> header builder) would do. Small gain. | S | marginal |
| replacer.nvim | `replacer.nvim/lua/replacer/rg.lua:899` | collect (:909), collect_async (:941) and collect_streaming (:989) each branch on pick_backend; a backend table {collect, collect_async, stream} for ripgrep and vimgrep (also moves ~600 of the 1105 lines out into their own modules) makes a third backend or testing one path easy. | M | yes |
| replacer.nvim | `replacer.nvim/lua/replacer/init.lua:163` | dispatch() is about 190 lines with nested closures (apply_func, open_picker) selecting plan-only, quickfix, ALL+checkpoint, per-file, confirm-all or picker; each mode as a function in a small table taking a shared context would shorten it. open_picker also hard-wires fzf vs telescope (:260) while pickers.nvim already has an engine abstraction. | M | yes |
| replacer.nvim | `replacer.nvim/lua/replacer/command.lua:244` | apply_value_flag is an if/elseif chain over type/glob/exclude/engine/context/export/max-filesize with repeated integer validation; table of key -> {validate, apply} would also let the option help and completion (usrcmd_option_help) derive from the same data. | S | marginal |
| streamtap | `streamtap/desktop/crates/streamtap-sink/src/main.rs:536` | The container kind ("mp4"/"webm") is a String compared in init_prefix_len (536), has_samples (589), init_scan (632), payload_encrypted (479), flush_init (1340), head_format (2666) and mux (2771). A Container enum with methods (or a small trait) makes the compiler check every branch and removes the stringly typing. | S | yes |
| ai-desktop | `ai-desktop/src/secrets.cpp:233` | store_read/write/delete_locked each repeat `#ifdef _WIN32 if (!use_file_backend()) return wincred_*` before the file path. A small SecretBackend with WinCred and File implementations chosen once would remove the triplicated branch and ease testing. | S | marginal |

### Template Method (14)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| docmap.nvim | `docmap.nvim/lua/docmap/bindings/usrcmds/init.lua:39` | About 14 ACTIONS thunks are identical 'require("docmap.bindings.usrcmds.X").run(ctx, arg)'; generate them from a name list and keep explicit thunks only for special cases (full/all). | XS | marginal |
| docmap.nvim | `docmap.nvim/lua/docmap/core/render/html.lua:27` | 10235-line file embedding CSS (line 27) and ~9000 lines of JS (line 928) as Lua long strings; split into section/asset modules assembled by render, so the JS can be linted and tested as real files. | L | yes |
| ui.nvim | `ui.nvim/lua/ui/statusline/state.lua:112` | statusline/state.lua (184 lines) and context/state.lua (219 lines) carry near-identical private helpers: may_touch (112 vs 147), inspect (74 vs 109), sanitize, read/write/remove. The same file-safety rules are kept in two places, so a fix must land twice. One small 'safe_json_state' helper, parameterised by schema/default_path/sanitize, would remove the copy. | S | yes |
| filetree.nvim | `filetree.nvim/lua/filetree/adapter/neotree.lua:1` | At 1822 lines, neotree.lua implements the whole FiletreeAdapter interface plus redraw/debounce, race self-healing and render-event bridging. A thin facade that delegates to sub-modules (nodes, redraw, events) would improve navigability. nvimtree.lua is 555 lines, so the two adapters are very unequal. | M | marginal |
| lsp.nvim | `lsp.nvim/lua/lsp/servers/gopls.lua:12` | About 18 server modules repeat the same setup(shared, opts) skeleton: vim.lsp.config(name, {cmd, filetypes, root_markers, capabilities, on_attach, on_init, settings}) followed by a pcall(lsp.enable) branch (gopls:36, clangd:26, zig:29, bashls:97, ...). A shared define(name, spec) helper would leave only per-server data. The registry passes enable=false and then init.lua:261 enables anyway, so the per-server enable branches are redundant. | M | yes |
| ai.nvim | `ai.nvim/lua/ai/providers/copilot.lua:424` | Long if/elseif chain on event `kind` (message_start/delta/message/result/call_finished...) inside the stream callback; a kind->handler table with shared state would flatten it and let claude.lua:344 and claude_cli.lua:520 share the same decode-dispatch skeleton. | S | marginal |
| ai.nvim | `ai.nvim/lua/ai/providers/claude.lua:289` | claude/openai/gemini stream() and ask() repeat key check, attachments.unsupported, timeout, on_error/failed bookkeeping and on_done; a small helper taking decode_event(decoded, state) would remove the near-duplicate scaffolding (sse.lua already shares part). | M | marginal |
| cmdlog.nvim | `cmdlog.nvim/lua/cmdlog/ui/history_picker.lua:29` | history/history_unique, shell/shell_unique and all/all_unique picker pairs are near-identical (same delete adapters at history_picker.lua:18 vs history_unique_picker.lua:19, shell_picker.lua:17 vs shell_unique_picker.lua:18, all_picker.lua:21 vs all_unique_picker.lua:19); one builder taking {source, unique, title} would collapse six files to three. | M | yes |
| dap.nvim | `dap.nvim/lua/wkddap/ui/dapui.lua:34` | dapui.lua:34-48 and dapview.lua:35-50 duplicate the dap.listeners bootstrap and the open-on-initialized/close-on-terminated/exited wiring (memory/init.lua:526 re-does the lazy per-event table creation); one `ui_listeners(key, open, close)` helper removes it. | XS | yes |
| debugging.nvim | `debugging.nvim/lua/debugging/actions/neotest.lua:297` | The loops at :297 (is_test_file) and :348 (root) repeat the same pcall-adapter-method-and-format-verdict skeleton; a probe(adapters, method_name, arg, interpret) helper would cover both. | XS | marginal |
| github_stats.nvim | `github_stats.nvim/lua/github_stats/bindings/usrcmds/export.lua:57` | execute() branches on target(all/repo) x metric(both/one) x format(csv/md/pdf), duplicating the query + error-handling + pdf-vs-md choice four ways; export.lua has four near-identical build/write/pdf triples (333-632). A (scope,format) to builder table plus one write_or_pdf helper would collapse both. | M | yes |
| recommender.nvim | `recommender.nvim/lua/recommender/analyzers/regex.lua:35` | regex.lua, javascript.lua and python.lua are about 70 lines each and differ only in the identifier class and alias template (local / const ...; / plain assignment), as their own headers admit. A single make_regex_analyzer({ident, fmt}) would remove two copies and the places where a fix must be made three times. | S | yes |
| reposcope.nvim | `reposcope.nvim/lua/reposcope/providers/gitlab/clone/clone_manager.lua:1` | codeberg and gitlab are copy-paste: clone_manager 0 differing lines after renaming, readme_manager 2, repository_manager 2, readme_fetcher 8 (github differs more). A provider factory configured with name, URLs and query builder would remove roughly 600 duplicated lines and keep fixes in one place. | M | yes |
| sandbox.nvim | `sandbox.nvim/lua/sandbox/adapters/docker/containers/stop_container.lua:1` | docker, podman and nerdctl each carry about 52 files; diffing docker against podman after renaming shows many files differ by 2 to 6 lines (stop_container 2, run_container 2, pull_image 6, remove_image 6), only list/inspect/exec differ in real parsing. A shared command-builder keyed by the CLI binary, with per-engine overrides for list_containers, inspect and list_images, would remove most of ~100 duplicated files. Large risk surface (argv_matrix_spec and callbacks specs pin every argv). | L | yes |

### Registry (10)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| lib.nvim | `lua/lib/nvim/progress/resolve_style.lua:11` | Seven-branch if-chain on style name duplicates the require paths and fallback; a table {name -> loader} (or the existing lib.nvim.registry) would make styles pluggable and remove the duplicated fidget/notify fallback. | XS | yes |
| testing.nvim | `testing.nvim/lua/testing/report/init.lua:16` | REPORTERS is a closed constant table, whereas dialect conventions already have M.register (harness_conventions.lua:182). A register(name, module) would let a project add a custom reporter. Only useful if there is a real user request. | XS | marginal |
| filetree.nvim | `filetree.nvim/lua/filetree/features/system/file_clipboard/backend.lua:124` | M.build uses an if plat==windows / mac / linux chain, trash/platform.lua:404 does the same, and util/pdf.lua:42 repeats it with is_mac/is_wsl. Each file repeats the platform check. A shared table keyed by platform for send/open/clipboard, or a util.platform.dispatch(map), would make adding a platform one entry. The chains are short and stable, so the gain is limited. | S | marginal |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/plugins/fetch.lua:55` | fetch.lua:55 and report.lua:503/771 call pcall(require, 'gitsuite.adapter.lazy') directly, bypassing adapter.resolve('lazy') that adapter/init.lua says is the single soft-dependency door (PRIN-07) | XS | yes |
| markdown.nvim | `markdown.nvim/lua/markdown/commands/links.lua:161` | 56 pcall(require) sites for snacks.picker, images, pdfport, pickers.nvim, hover are spread over commands; gitsuite's adapter registry shows the central alternative, but a full registry is more machinery than most sites need, so only the picker/image group is worth it | M | marginal |
| fileops.nvim | `fileops.nvim/lua/fileops/ops/file.lua:172` | reload_explorers (172) and refresh_explorers (941) both hard-wire nvim-tree, neo-tree (and netrw) with near-identical pcall blocks; an explorer-adapter table with reload(dir) and a single loop removes the duplication and allows user-added explorers. | S | yes |
| language.nvim | `language.nvim/lua/language/spell/core/collect.lua:53` | Spell providers are spread over CLI_MODULES (53), hard-coded native/lsp/cspell_server branches (143-210) and a native_tree special case, unlike the translate registry; one provider registry with scope capabilities (buffer/cwd) and available() would remove the special cases. | M | marginal |
| pdfport.nvim | `pdfport.nvim/lua/pdfport/integrations/init.lua:18` | current_pdf_path is a filetype if-chain (neo-tree, NvimTree, netrw, oil) that open.nvim/lua/open/context.lua:246 repeats for the same trees, and renderers/buffer.lua:48 hard-codes a third list. One shared 'cursor path by filetype' adapter table would give both plugins one source and let new trees plug in. | M | yes |
| open.nvim | `open.nvim/lua/open/context.lua:246` | resolve_tree_node_path switches on filetype with three branches; same duplication as pdfport. Only worth doing together with a shared helper, alone it is small. | XS | marginal |
| ai-desktop | `ai-desktop/src/main.cpp:69` | Provider name is compared as a string in about 7 places: main.cpp:74-108 (two parallel if-chains for ask and ask_stream), models.cpp:57,71-73,125-127, catalog.cpp:92-102 and 140-142, catalog_parse.cpp:273-281. One Provider descriptor (ask, ask_stream, key_name, prefixes, list-fetch, presets) in a table would make a new provider a one-entry change. | M | yes |

### Event Bus (2)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| testing.nvim | `testing.nvim/lua/testing/run/events.lua:1` | The NDJSON events writer is a concrete sink called directly by the runners; reporters, the on_case hooks (dialect/init.lua opts.on_case) and the watch status lines are separate ad-hoc callbacks. One small emitter that the events file, term reporter and watch status subscribe to (state.lua:673 already has this shape) would unify them. Only worth it if more sinks are planned. | M | marginal |
| filetree.nvim | `filetree.nvim/lua/filetree/features/infra/hooks_api/init.lua:116` | hooks_api is a complete emitter, but its own header (lines 14-17) says no .emit() call exists in the repo. Wiring before/after_delete, move and copy emits in trash, move and copy_move would give third parties the documented extension point. The alternative is to remove the dead API. | S | yes |

### Middleware/Pipeline (5)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| testing.nvim | `testing.nvim/lua/testing/run/isolated.lua:650` | M.run is a single function of about 1050 lines (650 to 1703) with 16 elseif branches on input.reason, entry.dialect and mode. Splitting into named phases (plan, spawn, drive, collect, finalize) with a small file-state table would make it testable piecewise. | L | yes |
| testing.nvim | `testing.nvim/lua/testing/run/project.lua:539` | M.execute_run is about 1000 lines (539 to roughly 1556) mixing guards, cache, affected selection, shard, pool and reporting. Extracting stages that share one run-context object would cut its size and the overlap with isolated.lua and inproc.lua (M.run at inproc.lua:691), which share much of the same sequencing. | L | yes |
| docmap.nvim | `docmap.nvim/lua/docmap/core/check.lua:2341` | M.run hard-codes 24 calls with different signatures; a table of {name, fn} would allow per-check timing, selective runs, the opts.checks switch-off at source and uniform extra_checks handling, and could be tested for completeness. | S | marginal |
| gopath.nvim | `gopath.nvim/lua/gopath/registry.lua:113` | The treesitter and lsp PIPELINE handlers repeat 'if has_name(active, X) and L.X then local r = L.X.resolve() if r then return r end end'. A resolve_first(L, active, {names}) helper would remove about 25 lines. It is small, but it makes the repeated try-in-order shape explicit. | XS | marginal |
| data.nvim | `data.nvim/lua/data/init.lua:436` | M.filter is ~180 lines (436-617: resolve, decode, extmark anchor, interactive filter, preview, write); run (:302) and convert (:348) share the same formatter-lookup + resolve_io + decode prelude, so a common prepare(fmt,cmd,opts,flags) step plus named stages would shorten and unify them. | M | yes |

### Lazy Initialization (1)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| docmap.nvim | `docmap.nvim/lua/docmap/init.lua:253` | Six near-identical setmetatable/__index proxies (browse, diff, cli, history, testing, generate_all); a local lazy(modname) factory removes the duplication. | XS | yes |

### Debounce/Throttle (5)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| mdview.nvim | `mdview.nvim/lua/mdview/bindings/autocmds/live_push.lua:208` | Three hand-rolled throttles (live_push with trailing timer, scroll_sync.lua:117, selection_sync.lua) share last_sent_at logic; lib.nvim has debounce but no throttle, so one lib throttle with leading/trailing options would remove the copies and the timer-leak (PERF-62) handling | S | yes |
| markdown.nvim | `markdown.nvim/lua/markdown/core/refs.lua:268` | refs.on_change and autocmds.lua:304 (resize reflow) re-implement stop/close/restart timers with the PERF-62 workaround, while table_mode.lua:120 already uses lib.nvim.debounce.buffer | XS | yes |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/integrations/lazy.lua:208` | on_sync and setup (line 246) manage the `pending` uv timer by hand (stop, close, nil); a lib debounce handle would drop about 15 lines and the manual close bookkeeping | XS | yes |
| mdview.nvim | `mdview.nvim/lua/mdview/core/display.lua:555` | display.debounce builds a uv timer owned by a room; inbound_poll.lua:1072 and shared_relay.lua:385 have further hand-made timers. Only the display one needs room-aware cancel, so convert the others to lib timers | S | marginal |
| tasks-desktop | `tasks-desktop/crates/tasks-hub/src/server/check.rs:217` | follow_changes hand-rolls quiet-time waiting on a broadcast receiver; appkit store.rs:536 settle() does the same for fs hints. A generic quiet/max-wait helper in appkit would unify the two. | S | marginal |

### Cache/Memoize (1)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/statusline.lua:69` | statusline.invalidate() is documented as 'after a flush' but must be called manually; flush could fire a User RuntimeAnalysisFlush autocmd that statusline subscribes to. Short TTL (1s) already bounds staleness, so benefit is small. | S | marginal |

### Specification (2)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| tasks.nvim | `tasks.nvim/lua/tasks_nvim/model.lua:1199` | filter loop mixes status/kind/area/prio/tag/category in one elseif and a keep flag, with the ref_stale check separate. A list of compiled predicates built once from the filter would remove the per-task branching and make readiness/saved-list filters reusable. | M | marginal |
| gitsuite.nvim | `gitsuite.nvim/lua/gitsuite/features/plugins/breaking.lua:338` | classify is a ~110-line if/elseif cascade over revert, ignore, bang, footer, prefix, forced and many heuristic regexes; an ordered table of {id, test, tier, score} would make adding signals data-only. Risk: ordering and score interplay are subtle | M | marginal |

### Result/Option (4)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| runtime-analysis.nvim | `runtime-analysis.nvim/lua/runtime-analysis/bindings/usrcmds.lua:593` | The same 'pcall(require, ui.kit) else vim.ui.select / fallback' choreography recurs at lines 593, 656, 849 and 898; one small picker/adapter helper (as env.lua:191 already does with a seam) would dedupe it. | S | yes |
| testing.nvim | `testing.nvim/lua/testing/surface/init.lua:474` | Hand-rolled while/elseif parser (about 20 branches at lines 510-607) duplicates what the declarative option table in args.lua already does. The same approach is used in ci/repos.lua:110-165 and the other M.parse in ci/init.lua:93, ci/overview.lua:138, ci/remote.lua:139 and ci/hook.lua:143. A shared option-spec helper would remove duplicated value/inline/missing-value handling and give help and completion for free. | M | yes |
| testing.nvim | `testing.nvim/lua/testing/ci/repos.lua:131` | A flag loop followed by a second elseif key == chain (lines 149-165). Replacing it with a handler table keyed by option name (value validator plus setter) would remove the nested chain and share validation with the surface parser. Subsumed by the shared option-spec candidate if that is done. | S | marginal |
| gopath.nvim | `gopath.nvim/lua/gopath/create.lua:164` | The ui.kit presence check (pcall(require) at load plus vim.ui fallback) exists in create.lua, and lsp.nvim and hover.nvim repeat the pattern of a hand-written optional-dependency pcall. Moving it to one lib.nvim helper (confirm/input with fallback) would share it across repos, if lib.nvim does not already offer one. | S | marginal |

### Sonstige (7)

| Repo | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| docmap-desktop | `docmap-desktop/src-tauri/src/server.rs:99` | ROUTES is intentionally duplicated from docmap.nvim core/api.lua:450; a contract check test or generated file would catch drift without weakening the whitelist. | S | marginal |
| cascade.nvim | `cascade.nvim/lua/cascade/init.lua:102` | lf/cf/xf are three copies of the same feature-flag lookup differing only in the config section; one feature_gate(section) factory removes the duplication. | XS | marginal |
| debugging.nvim | `debugging.nvim/lua/debugging/views/capture/init.lua:291` | Three copy-pasted try/attempt/debug-notify blocks for noice, execute, exec2; iterate over an ordered {name, fn} list instead. | XS | yes |
| spotlight.nvim | `spotlight.nvim/lua/spotlight/init.lua:237` | lock_set/line_set (:237, :281) and lock_toggle/line_toggle (:255, :302) are line-for-line copies except the property, setter and message; one flag_set/flag_toggle helper taking the property name removes about 50 lines. | XS | yes |
| tasks-desktop | `tasks-desktop/crates/tasks-hub/src/server/mod.rs:89` | StreamCounter, StreamGuard and the Drop logic are copied verbatim in rules-desktop/crates/rules-hub/src/runtime.rs:70-110; EventStream wrapper is also identical (tasks events.rs:26 vs rules live.rs:24). Moving them into appkit-hub removes about 60 duplicated lines and the risk of fixing one copy only. | S | yes |
| rules-desktop | `rules-desktop/crates/rules-hub/src/editor.rs:20` | FileOpener, Launch, plan(), TerminalOpener and on_path duplicate tasks-desktop/crates/tasks-hub/src/editor.rs:20-240 (rules adds a line argument, tasks adds reveal/pick_folder). One kit trait with default methods or a superset would serve both apps. | M | yes |
| streamtap | `streamtap/extension/src/sink-link.js:276` | The pair `nextRetryAt = now + retryDelay; retryDelay = min(retryDelay*2, 10000)` is repeated at sink-link.js:276-277 and 352-353 (plus the reset at 351). A single scheduleRetry(link, stable) function would keep the policy in one place. | XS | yes |

## 6 Kandidaten nach Repo

### ai-desktop (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy / provider registry (table of provider descriptors) | `ai-desktop/src/main.cpp:69` | Provider name is compared as a string in about 7 places: main.cpp:74-108 (two parallel if-chains for ask and ask_stream), models.cpp:57,71-73,125-127, catalog.cpp:92-102 and 140-142, catalog_parse.cpp:273-281. One Provider descriptor (ask, ask_stream, key_name, prefixes, list-fetch, presets) in a table would make a new provider a one-entry change. | M | yes |
| Strategy (secret backend interface) | `ai-desktop/src/secrets.cpp:233` | store_read/write/delete_locked each repeat `#ifdef _WIN32 if (!use_file_backend()) return wincred_*` before the file path. A small SecretBackend with WinCred and File implementations chosen once would remove the triplicated branch and ease testing. | S | marginal |

### ai.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy table (per-event handlers) / Template Method | `ai.nvim/lua/ai/providers/copilot.lua:424` | Long if/elseif chain on event `kind` (message_start/delta/message/result/call_finished...) inside the stream callback; a kind->handler table with shared state would flatten it and let claude.lua:344 and claude_cli.lua:520 share the same decode-dispatch skeleton. | S | marginal |
| Template Method (shared stream/ask skeleton) | `ai.nvim/lua/ai/providers/claude.lua:289` | claude/openai/gemini stream() and ask() repeat key check, attachments.unsupported, timeout, on_error/failed bookkeeping and on_done; a small helper taking decode_event(decoded, state) would remove the near-duplicate scaffolding (sse.lua already shares part). | M | marginal |

### buffer-ctx.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy table (path mode) | `buffer-ctx.nvim/lua/buffer_ctx/ops/filepath.lua:25` | opts.mode if/elseif (abs/nvim/repos/env) mirrors location.lua:34-38; a MODES[mode] resolver table would let both reuse one registry and be extended without editing the chain. | S | marginal |
| Strategy (sink function) | `buffer-ctx.nvim/lua/buffer_ctx/commands.lua:69` | sink_text and sink_lines duplicate the clip.copy + notify block; making sinks objects {text=fn, lines=fn} (or having sink_lines join and call sink_text) removes the copy. | XS | marginal |

### cascade.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy table (kind codecs) | `cascade.nvim/lua/cascade/lists/marker.lua:149` | The digit/ascii/roman if/elseif on marker kind is repeated in marker.lua:149 and :317, shape.lua:58 and :80, and sequence/renumber.lua:49; one table kind -> {parse, to_int, to_token, next} would add a kind in one place. | M | yes |
| Dedup of identical gates (higher-order helper) | `cascade.nvim/lua/cascade/init.lua:102` | lf/cf/xf are three copies of the same feature-flag lookup differing only in the config section; one feature_gate(section) factory removes the duplication. | XS | marginal |

### casedesk.nvim (4)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy (field-resolver table) | `casedesk.nvim/lua/casedesk/clipboard.lua:585` | M.value is a 20-branch if/elseif on field key, and ui/insert.lua:94 repeats near-identical branches (snow, link, title, company). One shared FIELDS table key->resolver(entry,meta) removes duplication and gives completion the key list for free. | M | yes |
| Strategy (target resolver table) | `casedesk.nvim/lua/casedesk/open_targets.lua:139` | elseif chain on target (links/solution/stream/snow/resolve/folder); a table target->resolver lets describe() and completion reuse the same keys. | S | marginal |
| Strategy / table-driven verbs | `casedesk.nvim/lua/casedesk/anonymize_rules.lua:210` | Rule-file parser dispatches on verb with a 22-branch elseif; pattern and regex branches (:235 and :270) are near duplicates differing in the matcher. A VERBS table with shared validate helper would cut the duplication. | M | yes |
| Visitor / dispatch table | `casedesk.nvim/lua/casedesk/plan.lua:122` | describe() branches on action kind, and apply.lua repeats the same kind switch. A kind->{describe,apply} table keeps the two in sync when a kind is added. | S | marginal |

### cmdlog.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy table per shell (parse + match) | `cmdlog.nvim/lua/cmdlog/core/shell.lua:303` | get_shell_history parses via an if/elseif per shell (zsh, bash/ksh/csh, fish, nu, powershell, fallback) and line_matches_command (:351) repeats the shell knowledge; a SHELLS[name] = {parse_line, line_matches} table keeps the two in sync (they must mirror each other today). | S | yes |
| Template Method / parametrization (unique flag) | `cmdlog.nvim/lua/cmdlog/ui/history_picker.lua:29` | history/history_unique, shell/shell_unique and all/all_unique picker pairs are near-identical (same delete adapters at history_picker.lua:18 vs history_unique_picker.lua:19, shell_picker.lua:17 vs shell_unique_picker.lua:18, all_picker.lua:21 vs all_unique_picker.lua:19); one builder taking {source, unique, title} would collapse six files to three. | M | yes |

### dap.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Listener-wiring helper (Template Method) | `dap.nvim/lua/wkddap/ui/dapui.lua:34` | dapui.lua:34-48 and dapview.lua:35-50 duplicate the dap.listeners bootstrap and the open-on-initialized/close-on-terminated/exited wiring (memory/init.lua:526 re-does the lazy per-event table creation); one `ui_listeners(key, open, close)` helper removes it. | XS | yes |

### data.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Pipeline / extract steps (decompose giant function) | `data.nvim/lua/data/init.lua:436` | M.filter is ~180 lines (436-617: resolve, decode, extmark anchor, interactive filter, preview, write); run (:302) and convert (:348) share the same formatter-lookup + resolve_io + decode prelude, so a common prepare(fmt,cmd,opts,flags) step plus named stages would shorten and unify them. | M | yes |

### debugging.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Loop over strategies (data-driven fallback chain) | `debugging.nvim/lua/debugging/views/capture/init.lua:291` | Three copy-pasted try/attempt/debug-notify blocks for noice, execute, exec2; iterate over an ordered {name, fn} list instead. | XS | yes |
| Template Method / probe helper | `debugging.nvim/lua/debugging/actions/neotest.lua:297` | The loops at :297 (is_test_file) and :348 (root) repeat the same pcall-adapter-method-and-format-verdict skeleton; a probe(adapters, method_name, arg, interpret) helper would cover both. | XS | marginal |

### diff.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy (output renderer table) | `diff.nvim/lua/diff/core/init.lua:459` | The prompt/file/clipboard/stat branches inside the buffer-output code each call a render.* function with the same six arguments and finish_text_output; an OUTPUTS[output](ctx) table would shrink the large execute pipeline and make outputs addable. | S | marginal |

### docmap-desktop (5)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Module split / Facade | `docmap-desktop/src-tauri/src/main.rs:607` | 5827-line main.rs holds about 60 tauri commands plus workspace, clone/import, and link-walk logic; split into command modules (workspace, import, engine, nvim) with main.rs only wiring generate_handler!. | M | yes |
| Module split / Mediator (state store) | `docmap-desktop/src/main.js:144` | 5196-line main.js with about 25 top-level mutable lets (engine, projects, selectedId, mapTab, mapWatch...) mutated from many render/select functions; extract a small state store with subscribe so renderers react instead of being called imperatively. | L | yes |
| Facade (typed IPC wrapper) | `docmap-desktop/src/main.js:1244` | About 69 inline invoke("name", {...}) calls; a lib/ipc.js with one function per command centralizes names, argument shapes and error mapping (cf. lib/contract.js). | M | marginal |
| Generated shared constants (single source) | `docmap-desktop/src-tauri/src/server.rs:99` | ROUTES is intentionally duplicated from docmap.nvim core/api.lua:450; a contract check test or generated file would catch drift without weakening the whitelist. | S | marginal |
| Command / Strategy table for menu events | `docmap-desktop/src/main.js:2151` | Large message/menu handlers dispatch on string ids; verify whether they use if chains and, if so, a handlers map keyed by id would simplify them (not fully confirmed). | S | marginal |

### docmap.nvim (5)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Facade helper / Factory (lazy proxy) | `docmap.nvim/lua/docmap/init.lua:253` | Six near-identical setmetatable/__index proxies (browse, diff, cli, history, testing, generate_all); a local lazy(modname) factory removes the duplication. | XS | yes |
| Template Method / table-driven Command | `docmap.nvim/lua/docmap/bindings/usrcmds/init.lua:39` | About 14 ACTIONS thunks are identical 'require("docmap.bindings.usrcmds.X").run(ctx, arg)'; generate them from a name list and keep explicit thunks only for special cases (full/all). | XS | marginal |
| Registry / Pipeline (named check table) | `docmap.nvim/lua/docmap/core/check.lua:2341` | M.run hard-codes 24 calls with different signatures; a table of {name, fn} would allow per-check timing, selective runs, the opts.checks switch-off at source and uniform extra_checks handling, and could be tested for completeness. | S | marginal |
| Composite / Template Method (split giant module) | `docmap.nvim/lua/docmap/core/render/html.lua:27` | 10235-line file embedding CSS (line 27) and ~9000 lines of JS (line 928) as Lua long strings; split into section/asset modules assembled by render, so the JS can be linted and tested as real files. | L | yes |
| Module split / Facade | `docmap.nvim/lua/docmap/core/check.lua:164` | 2409-line file with about 24 independent check_* functions; one module per check group registered into the check table would keep each reviewable. | M | marginal |

### emojis.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Command table (replace if/elseif dispatch) | `emojis.nvim/lua/emojis/commands.lua:91` | execute() is a 12-branch elseif/if chain and composer routes forward() back into it by rebuilding fargs; direct per-action handlers keyed by name would remove the round trip (unicode.dispatch at unicode/init.lua:375 has the same shape). | S | yes |
| Strategy (replace action if-chains) | `emojis.nvim/lua/emojis/actions.lua:122` | clear/replace/unreplace/wrap selection is duplicated in actions.edit (122-130) and search.apply_across_files (search.lua:93-96, which silently treats everything but clear as replace); a shared ops.apply(action, lines, cfg) removes the drift risk. | XS | yes |

### fileops.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy / Adapter registry for explorers | `fileops.nvim/lua/fileops/ops/file.lua:172` | reload_explorers (172) and refresh_explorers (941) both hard-wire nvim-tree, neo-tree (and netrw) with near-identical pcall blocks; an explorer-adapter table with reload(dir) and a single loop removes the duplication and allows user-added explorers. | S | yes |
| Command table (replace if/elseif dispatch) | `fileops.nvim/lua/fileops/bindings/usrcmds.lua:633` | dispatch() is a ~150-line elseif chain over ~20 subcommands that composer routes then re-enter via fargs_of; a table subcmd to handler(ctx) cuts the double-dispatch and the reconstruct step. | M | yes |

### filetree.nvim (3)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy / Registry table for platform backends | `filetree.nvim/lua/filetree/features/system/file_clipboard/backend.lua:124` | M.build uses an if plat==windows / mac / linux chain, trash/platform.lua:404 does the same, and util/pdf.lua:42 repeats it with is_mac/is_wsl. Each file repeats the platform check. A shared table keyed by platform for send/open/clipboard, or a util.platform.dispatch(map), would make adding a platform one entry. The chains are short and stable, so the gain is limited. | S | marginal |
| Template Method / split giant module | `filetree.nvim/lua/filetree/adapter/neotree.lua:1` | At 1822 lines, neotree.lua implements the whole FiletreeAdapter interface plus redraw/debounce, race self-healing and render-event bridging. A thin facade that delegates to sub-modules (nodes, redraw, events) would improve navigability. nvimtree.lua is 555 lines, so the two adapters are very unequal. | M | marginal |
| Event Bus actually wired (Observer emit sites) | `filetree.nvim/lua/filetree/features/infra/hooks_api/init.lua:116` | hooks_api is a complete emitter, but its own header (lines 14-17) says no .emit() call exists in the repo. Wiring before/after_delete, move and copy emits in trash, move and copy_move would give third parties the documented extension point. The alternative is to remove the dead API. | S | yes |

### github_stats.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Template Method / table-driven export jobs | `github_stats.nvim/lua/github_stats/bindings/usrcmds/export.lua:57` | execute() branches on target(all/repo) x metric(both/one) x format(csv/md/pdf), duplicating the query + error-handling + pdf-vs-md choice four ways; export.lua has four near-identical build/write/pdf triples (333-632). A (scope,format) to builder table plus one write_or_pdf helper would collapse both. | M | yes |

### gitsuite.nvim (4)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Debounce (use existing lib.nvim.debounce) | `gitsuite.nvim/lua/gitsuite/integrations/lazy.lua:208` | on_sync and setup (line 246) manage the `pending` uv timer by hand (stop, close, nil); a lib debounce handle would drop about 15 lines and the manual close bookkeeping | XS | yes |
| Registry (use the existing adapter registry) | `gitsuite.nvim/lua/gitsuite/features/plugins/fetch.lua:55` | fetch.lua:55 and report.lua:503/771 call pcall(require, 'gitsuite.adapter.lazy') directly, bypassing adapter.resolve('lazy') that adapter/init.lua says is the single soft-dependency door (PRIN-07) | XS | yes |
| Extract object (bulk runner / Iterator over repos) | `gitsuite.nvim/lua/gitsuite/features/dashboard/view.lua:1129` | _run_bulk is a ~200-line closure holding queue, running count, cancel, generation, lock-retry and pump inside a 2579-line view; a dashboard/bulk.lua runner with injected redraw/action callbacks would be unit-testable without a buffer and shrink view.lua | M | yes |
| Chain of Responsibility / rule table (Specification) | `gitsuite.nvim/lua/gitsuite/features/plugins/breaking.lua:338` | classify is a ~110-line if/elseif cascade over revert, ignore, bang, footer, prefix, forced and many heuristic regexes; an ordered table of {id, test, tier, score} would make adding signals data-only. Risk: ordering and score interplay are subtle | M | marginal |

### gopath.nvim (5)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Chain of Responsibility (declarative stage list) | `gopath.nvim/lua/gopath/resolve.lua:32` | resolve_at_cursor is about 150 lines of hand-written stages with repeated pcall(require) boilerplate and config gating. Expressing the stages as an ordered list of {name, enabled(cfg), run} would remove the boilerplate and let the Lua pipeline and :GopathProbe report which stage matched. Stage 3 is special (a held fallback), so keep that handled explicitly. | S | yes |
| Strategy (kind handler table) | `gopath.nvim/lua/gopath/commands.lua:154` | res.kind == 'help'/'url'/file ladders are repeated in check (154-163), copy_location (198-206), open/init.lua:58 and the open-mode checks. A KIND_HANDLERS table with open/check/copy_text per kind would put the knowledge of each result kind in one place. | S | marginal |
| Table-driven mode handlers (Strategy) | `gopath.nvim/lua/gopath/open/init.lua:50` | M.open mixes mode == 'explorer' and mode == 'filetree' special cases with the PLACEMENT table. Moving these into a MODE_HANDLERS table (like PLACEMENT) would shorten the function, but there are only two special modes. | XS | marginal |
| Template Method / Factory (resolver list for language pipelines) | `gopath.nvim/lua/gopath/registry.lua:113` | The treesitter and lsp PIPELINE handlers repeat 'if has_name(active, X) and L.X then local r = L.X.resolve() if r then return r end end'. A resolve_first(L, active, {names}) helper would remove about 25 lines. It is small, but it makes the repeated try-in-order shape explicit. | XS | marginal |
| Facade over optional soft dependencies | `gopath.nvim/lua/gopath/create.lua:164` | The ui.kit presence check (pcall(require) at load plus vim.ui fallback) exists in create.lua, and lsp.nvim and hover.nvim repeat the pattern of a hand-written optional-dependency pcall. Moving it to one lib.nvim helper (confirm/input with fallback) would share it across repos, if lib.nvim does not already offer one. | S | marginal |

### hover.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy (type to previewer table) | `hover.nvim/lua/hover/init.lua:632` | build() is a roughly 110-line if/elseif ladder on target.type, running after registry.preview_for(type). Register the built-ins (missing, directory, file, image, pdf, office, video, git, url) in the same registry or a local table keyed by type. A new type then no longer edits init.lua. | M | yes |
| Extract Facade pieces (split giant functions) | `hover.nvim/lua/hover/init.lua:1058` | M.show spans about 270 lines (1058-1330) and present() about 190 lines; the file is 2861 lines. Splitting by concern (show flow, pin/dir-nav, zoom, mode/switch API) would improve readability and test isolation. | L | marginal |

### images.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy (platform backend table) | `images.nvim/lua/images/paste.lua:75` | clipboard_to_file (Windows worker or powershell / pngpaste / wl-paste / xclip) and screenshot.lua:84-283 each branch on OS separately; a single images.platform backend table with clipboard_image() and capture() per OS would keep each OS in one place. | M | marginal |

### insights.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy (shared UI picker facade) | `insights.nvim/lua/insights/symbols/open.lua:45` | Picker selection (fzf/telescope/scratch/snacks/qf) is re-implemented in symbols/open.lua:45, todos/init.lua:405, imports/init.lua:811, with two different default_ui() (symbols/open.lua:31, todos/init.lua:338) and diverging fallbacks; one insights.ui.open(entries,title,ui) with a backend table fixes it. | S | yes |

### language.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Registry unification | `language.nvim/lua/language/spell/core/collect.lua:53` | Spell providers are spread over CLI_MODULES (53), hard-coded native/lsp/cspell_server branches (143-210) and a native_tree special case, unlike the translate registry; one provider registry with scope capabilities (buffer/cwd) and available() would remove the special cases. | M | marginal |

### lib.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Registry / Strategy table | `lua/lib/nvim/progress/resolve_style.lua:11` | Seven-branch if-chain on style name duplicates the require paths and fallback; a table {name -> loader} (or the existing lib.nvim.registry) would make styles pluggable and remove the duplicated fidget/notify fallback. | XS | yes |
| Command table / dispatch table | `lua/lib/nvim/logger/command.lua:44` | LibLogger subcommands (on/off/level/dump/clear/tags/show) are a six-branch elseif on a string; a subcommand table also gives completion for free (or use the library's own composer, which already supports routes). | S | marginal |

### lsp.nvim (3)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Factory (generate repeated actions) | `lsp.nvim/lua/lsp/bindings/actions.lua:304` | hints_toggle/toggle_filetype/on/off (304-350) and lightbulb_* (356-402) are near-identical, and format_*/workspace_* follow the same shape. A make_switch_actions(loader) factory would remove roughly 100 lines and the repeated empty-filetype warning. | S | yes |
| Template Method / Builder (server definition helper) | `lsp.nvim/lua/lsp/servers/gopls.lua:12` | About 18 server modules repeat the same setup(shared, opts) skeleton: vim.lsp.config(name, {cmd, filetypes, root_markers, capabilities, on_attach, on_init, settings}) followed by a pcall(lsp.enable) branch (gopls:36, clangd:26, zig:29, bashls:97, ...). A shared define(name, spec) helper would leave only per-server data. The registry passes enable=false and then init.lua:261 enables anyway, so the per-server enable branches are redundant. | M | yes |
| Split God module (Strategy/State collaborators) | `lsp.nvim/lua/lsp/core/env_links.lua:1` | 2233 lines mix link parsing (446-715), a markdown block state machine (859-1185), a heading slugger (1402-1900) and an index cache plus preview (1901-2233), all in one module. Splitting into env_links/{parse,blocks,headings}.lua behind the current M facade would give each part its own spec. | M | yes |

### markdown.nvim (4)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Debounce (use existing lib.nvim.debounce) | `markdown.nvim/lua/markdown/core/refs.lua:268` | refs.on_change and autocmds.lua:304 (resize reflow) re-implement stop/close/restart timers with the PERF-62 workaround, while table_mode.lua:120 already uses lib.nvim.debounce.buffer | XS | yes |
| Command (single table for run/complete/feature) | `markdown.nvim/lua/markdown/commands/init.lua:25` | Subcommands live in three parallel tables (commands at 25, SUBCOMMAND_FEATURES at 8, sub_complete at 101); the file's own comment says a missing entry once broke `format`. One table of {run, complete, nested, features} removes the sync hazard | S | yes |
| State pattern (block-kind table) | `markdown.nvim/lua/markdown/core/render.lua:242` | scan_fences carries comment/math/fence as parallel booleans and role strings, followed by role if-chains at lines 769-830; a table of block kinds with open/close predicates and render handlers would let new block types be added in one place | M | marginal |
| Adapter registry for soft dependencies | `markdown.nvim/lua/markdown/commands/links.lua:161` | 56 pcall(require) sites for snacks.picker, images, pdfport, pickers.nvim, hover are spread over commands; gitsuite's adapter registry shows the central alternative, but a full registry is more machinery than most sites need, so only the picker/image group is worth it | M | marginal |

### mdview.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Throttle (extract to lib.nvim.throttle) | `mdview.nvim/lua/mdview/bindings/autocmds/live_push.lua:208` | Three hand-rolled throttles (live_push with trailing timer, scroll_sync.lua:117, selection_sync.lua) share last_sent_at logic; lib.nvim has debounce but no throttle, so one lib throttle with leading/trailing options would remove the copies and the timer-leak (PERF-62) handling | S | yes |
| Debounce (shared helper with room ownership) | `mdview.nvim/lua/mdview/core/display.lua:555` | display.debounce builds a uv timer owned by a room; inbound_poll.lua:1072 and shared_relay.lua:385 have further hand-made timers. Only the display one needs room-aware cancel, so convert the others to lib timers | S | marginal |

### media.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy / handler table per kind | `media.nvim/lua/media/hub/text.lua:148` | The audio/video / image / pdf if-chain on kind repeats in text.lua at 148-151, 167, 273-284, 318, 350 and hub/dashboard.lua:121; a KIND_HANDLERS table (tool, modes, run, sidecar_title) would make a new kind one entry instead of five edits. | S | yes |

### my.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Dispatch table (Strategy/Command) replacing if-chain | `my.nvim/lua/my/hl_config/init.lua:84` | after_set is a 100-line if/return chain over key names; a table of key (or prefix) -> handler would shrink it, make each feature's mapping data and remove the repeated State.set_enabled plus enable(cfg) shape. | S | yes |

### open.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Dispatch table / Adapter registry | `open.nvim/lua/open/context.lua:246` | resolve_tree_node_path switches on filetype with three branches; same duplication as pdfport. Only worth doing together with a shared helper, alone it is small. | XS | marginal |

### pdfport.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Adapter registry (file-tree provider table) | `pdfport.nvim/lua/pdfport/integrations/init.lua:18` | current_pdf_path is a filetype if-chain (neo-tree, NvimTree, netrw, oil) that open.nvim/lua/open/context.lua:246 repeats for the same trees, and renderers/buffer.lua:48 hard-codes a third list. One shared 'cursor path by filetype' adapter table would give both plugins one source and let new trees plug in. | M | yes |

### recommender.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Template Method / parameterised factory | `recommender.nvim/lua/recommender/analyzers/regex.lua:35` | regex.lua, javascript.lua and python.lua are about 70 lines each and differ only in the identifier class and alias template (local / const ...; / plain assignment), as their own headers admit. A single make_regex_analyzer({ident, fmt}) would remove two copies and the places where a fix must be made three times. | S | yes |
| Command / Extract Method (giant function) | `recommender.nvim/lua/recommender/bindings/usrcmds.lua:222` | execute() is about 300 lines of closures mixing arg validation, scope resolution, state/refresh and rendering; splitting into resolve-request, collect, and present steps (State object for ignored/visible) would make it testable. | M | yes |

### replacer.nvim (3)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy (backend objects instead of branching) | `replacer.nvim/lua/replacer/rg.lua:899` | collect (:909), collect_async (:941) and collect_streaming (:989) each branch on pick_backend; a backend table {collect, collect_async, stream} for ripgrep and vimgrep (also moves ~600 of the 1105 lines out into their own modules) makes a third backend or testing one path easy. | M | yes |
| Strategy (apply mode) / Extract Method | `replacer.nvim/lua/replacer/init.lua:163` | dispatch() is about 190 lines with nested closures (apply_func, open_picker) selecting plan-only, quickfix, ALL+checkpoint, per-file, confirm-all or picker; each mode as a function in a small table taking a shared context would shorten it. open_picker also hard-wires fzf vs telescope (:260) while pickers.nvim already has an engine abstraction. | M | yes |
| Dispatch table for flag handlers | `replacer.nvim/lua/replacer/command.lua:244` | apply_value_flag is an if/elseif chain over type/glob/exclude/engine/context/export/max-filesize with repeated integer validation; table of key -> {validate, apply} would also let the option help and completion (usrcmd_option_help) derive from the same data. | S | marginal |

### reposcope.nvim (2)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Template Method / shared base provider | `reposcope.nvim/lua/reposcope/providers/gitlab/clone/clone_manager.lua:1` | codeberg and gitlab are copy-paste: clone_manager 0 differing lines after renaming, readme_manager 2, repository_manager 2, readme_fetcher 8 (github differs more). A provider factory configured with name, URLs and query builder would remove roughly 600 duplicated lines and keep fixes in one place. | M | yes |
| Strategy table | `reposcope.nvim/lua/reposcope/network/clients/http_client.lua:87` | Request-tool selection (:87) and _build_auth_header (:32) are if/elseif chains on tool and provider; two small lookup tables (tool -> module, provider -> header builder) would do. Small gain. | S | marginal |

### rules-desktop (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Extract shared component into appkit (FileOpener + launch plan) | `rules-desktop/crates/rules-hub/src/editor.rs:20` | FileOpener, Launch, plan(), TerminalOpener and on_path duplicate tasks-desktop/crates/tasks-hub/src/editor.rs:20-240 (rules adds a line argument, tasks adds reveal/pick_folder). One kit trait with default methods or a superset would serve both apps. | M | yes |

### rules.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Command/Strategy sink (render target as parameter) | `rules.nvim/lua/rules/init.lua:204` | check_family, check_family_json, check_family_work_list and the run_gate* trio (lines 204-306) are six near-identical wrappers over run_family/run_gate_results differing only in output (quickfix+buffer, JSON, work list); a sink/format table would make it 2 runners plus 3 sinks | S | marginal |

### runtime-analysis.nvim (6)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy / handler table (replace if/elseif on subcommand) | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/command.lua:920` | The :RATelemetry callback is one ~350-line if/elseif chain on `first` (reset/start/stop/flush/disable/status/coverage/export/startup/flamegraph/cost/snapshot...). A subcommands table name -> handler(mod, rest) (or composer.verb routes like :RA already uses in usrcmds.lua:1011) would flatten it and give completion for free. | M | yes |
| Strategy table for report-style dispatch | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/command.lua:617` | open_report's inner dispatch is an if/elseif on resolved style (mdview/preview-tab/file/html/kit), each with its own 'warn then fall back to kit float' code, while report_style.lua already resolves the name. A table style -> opener returning ok,err with one shared fallback would remove the duplicated fallback blocks. | S | yes |
| Strategy table for flag application (replace if/elseif on kind) | `runtime-analysis.nvim/lua/runtime-analysis/curl.lua:215` | VALUE_FLAGS already classifies flags into kinds, but a second if/elseif chain applies each kind; map kind -> apply(state, value) so adding a flag is one table row. Chain is only 7 branches, so gain is modest. | XS | marginal |
| Extract Command handlers / split giant function | `runtime-analysis.nvim/lua/runtime-analysis/telemetry/init.lua:376` | M.new is a single closure of roughly 1300 lines (start/stop/flush/report/wrap...) all sharing locals; splitting into sub-modules (recorder, flusher, wrapper-manager) with explicit state tables would improve testability, but the closure state sharing makes it costly. | L | marginal |
| Extract duplicated optional-UI fallback (kit vs vim.ui.select) into an adapter | `runtime-analysis.nvim/lua/runtime-analysis/bindings/usrcmds.lua:593` | The same 'pcall(require, ui.kit) else vim.ui.select / fallback' choreography recurs at lines 593, 656, 849 and 898; one small picker/adapter helper (as env.lua:191 already does with a seam) would dedupe it. | S | yes |
| Event-bus / Observer between telemetry flush and statusline cache | `runtime-analysis.nvim/lua/runtime-analysis/statusline.lua:69` | statusline.invalidate() is documented as 'after a flush' but must be called manually; flush could fire a User RuntimeAnalysisFlush autocmd that statusline subscribes to. Short TTL (1s) already bounds staleness, so benefit is small. | S | marginal |

### sandbox.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Template Method / parameterised adapter (one CLI, many engines) | `sandbox.nvim/lua/sandbox/adapters/docker/containers/stop_container.lua:1` | docker, podman and nerdctl each carry about 52 files; diffing docker against podman after renaming shows many files differ by 2 to 6 lines (stop_container 2, run_container 2, pull_image 6, remove_image 6), only list/inspect/exec differ in real parsing. A shared command-builder keyed by the CLI binary, with per-engine overrides for list_containers, inspect and list_images, would remove most of ~100 duplicated files. Large risk surface (argv_matrix_spec and callbacks specs pin every argv). | L | yes |

### spotlight.nvim (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Extract Method (duplicated near-identical functions) | `spotlight.nvim/lua/spotlight/init.lua:237` | lock_set/line_set (:237, :281) and lock_toggle/line_toggle (:255, :302) are line-for-line copies except the property, setter and message; one flag_set/flag_toggle helper taking the property name removes about 50 lines. | XS | yes |

### streamtap (3)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Enum + methods (Container strategy) instead of kind strings | `streamtap/desktop/crates/streamtap-sink/src/main.rs:536` | The container kind ("mp4"/"webm") is a String compared in init_prefix_len (536), has_samples (589), init_scan (632), payload_encrypted (479), flush_init (1340), head_format (2666) and mux (2771). A Container enum with methods (or a small trait) makes the compiler check every branch and removes the stringly typing. | S | yes |
| Retry/backoff helper (remove triple duplication) | `streamtap/extension/src/sink-link.js:276` | The pair `nextRetryAt = now + retryDelay; retryDelay = min(retryDelay*2, 10000)` is repeated at sink-link.js:276-277 and 352-353 (plus the reset at 351). A single scheduleRetry(link, stable) function would keep the policy in one place. | XS | yes |
| Module split / Facade over a 5600-line file | `streamtap/desktop/crates/streamtap-sink/src/main.rs:1` | One file holds protocol parsing, DRM detection, Session/TrackState, index rows, tfdt rewriting, mux planning and ffprobe probing (5623 lines, 900+ of them tests). Splitting into modules (wire, init detection, session, mux) would keep proc.rs/error.rs style and make the Container enum above natural. | M | yes |

### takt (1)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Builder for many positional arguments | `takt/crates/takt-backend/src/null.rs:55` | NullBackend::new takes five positional arguments (meta, rate, duration, pattern, pool capacity) and tests/player repeat them. A builder or Default config is only worth it once a real backend adds options. | XS | marginal |

### tasks-desktop (3)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Extract shared component into appkit (StreamCounter/StreamGuard, EventStream) | `tasks-desktop/crates/tasks-hub/src/server/mod.rs:89` | StreamCounter, StreamGuard and the Drop logic are copied verbatim in rules-desktop/crates/rules-hub/src/runtime.rs:70-110; EventStream wrapper is also identical (tasks events.rs:26 vs rules live.rs:24). Moving them into appkit-hub removes about 60 duplicated lines and the risk of fixing one copy only. | S | yes |
| Shared debounce helper | `tasks-desktop/crates/tasks-hub/src/server/check.rs:217` | follow_changes hand-rolls quiet-time waiting on a broadcast receiver; appkit store.rs:536 settle() does the same for fs hints. A generic quiet/max-wait helper in appkit would unify the two. | S | marginal |
| Split God class into state modules | `tasks-desktop/ui/src/lib/app.svelte.ts:206` | The App class is about 3250 lines with write, undo, search, bulk, views and routing; lib/state/ already holds check, vaults, views and matrix. Moving write/undo and search into further state classes would continue that direction. | L | marginal |

### tasks.nvim (5)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Strategy (field validators) | `tasks.nvim/lua/tasks_nvim/mutate.lua:660` | The patch normaliser is a ~150-line if/elseif on key (title, status, kind, prio, effort, ... order). A FIELD_NORMALIZERS[key](value)->(string/nil, err) table makes each field testable, mirrors ops.lua FIELDS, and the SETTABLE list derives from its keys. | M | yes |
| Command table | `tasks.nvim/lua/tasks_nvim/cli.lua:952` | commands.lists branches on sub (ls/show/save/delete/rename) with repeated usage-check and error-print boilerplate, in a 2192-line file. A subcommand table {min_args,max_args,run} with one shared usage/error wrapper removes the repetition. | S | yes |
| Strategy (output format renderers) | `tasks.nvim/lua/tasks_nvim/cli.lua:739` | plan and quick-wins commands each branch on format ids/tsv/md (:742, :837) with the same shape. A shared renderers table format->fn(report) would let new formats apply to every listing command. | S | marginal |
| Specification (composable predicates) | `tasks.nvim/lua/tasks_nvim/model.lua:1199` | filter loop mixes status/kind/area/prio/tag/category in one elseif and a keep flag, with the ref_stale check separate. A list of compiled predicates built once from the filter would remove the per-task branching and make readiness/saved-list filters reusable. | M | marginal |
| Command (action to text map) | `tasks.nvim/lua/tasks_nvim/cli.lua:1885` | Print of rule-sync plan items is an elseif chain on action to tsv line; a small formatter table action->format is clearer. | XS | marginal |

### testing.nvim (7)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Declarative option spec (table-driven parser) - reuse the args.lua mechanism | `testing.nvim/lua/testing/surface/init.lua:474` | Hand-rolled while/elseif parser (about 20 branches at lines 510-607) duplicates what the declarative option table in args.lua already does. The same approach is used in ci/repos.lua:110-165 and the other M.parse in ci/init.lua:93, ci/overview.lua:138, ci/remote.lua:139 and ci/hook.lua:143. A shared option-spec helper would remove duplicated value/inline/missing-value handling and give help and completion for free. | M | yes |
| Template Method / decompose into a phase pipeline (or State machine for per-file lifecycle) | `testing.nvim/lua/testing/run/isolated.lua:650` | M.run is a single function of about 1050 lines (650 to 1703) with 16 elseif branches on input.reason, entry.dialect and mode. Splitting into named phases (plan, spawn, drive, collect, finalize) with a small file-state table would make it testable piecewise. | L | yes |
| Template Method / Pipeline of stages | `testing.nvim/lua/testing/run/project.lua:539` | M.execute_run is about 1000 lines (539 to roughly 1556) mixing guards, cache, affected selection, shard, pool and reporting. Extracting stages that share one run-context object would cut its size and the overlap with isolated.lua and inproc.lua (M.run at inproc.lua:691), which share much of the same sequencing. | L | yes |
| Strategy (run mode as an interface: isolated / inproc / pool) | `testing.nvim/lua/testing/run/project.lua:907` | Mode selection is by conditionals (prep.mode == 'off' and similar) spread through project.lua, with isolated.lua and inproc.lua exposing parallel but separately shaped M.run functions. A small runner interface (run, list_case_ids, begin_listing) chosen once would replace the scattered branching. | M | marginal |
| Table-driven dispatch (Command table) for option handlers | `testing.nvim/lua/testing/ci/repos.lua:131` | A flag loop followed by a second elseif key == chain (lines 149-165). Replacing it with a handler table keyed by option name (value validator plus setter) would remove the nested chain and share validation with the surface parser. Subsumed by the shared option-spec candidate if that is done. | S | marginal |
| Event Bus / Observer for run progress | `testing.nvim/lua/testing/run/events.lua:1` | The NDJSON events writer is a concrete sink called directly by the runners; reporters, the on_case hooks (dialect/init.lua opts.on_case) and the watch status lines are separate ad-hoc callbacks. One small emitter that the events file, term reporter and watch status subscribe to (state.lua:673 already has this shape) would unify them. Only worth it if more sinks are planned. | M | marginal |
| Registry with register() for reporters | `testing.nvim/lua/testing/report/init.lua:16` | REPORTERS is a closed constant table, whereas dialect conventions already have M.register (harness_conventions.lua:182). A register(name, module) would let a project add a custom reporter. Only useful if there is a real user request. | XS | marginal |

### ui.nvim (3)

| Pattern | Fundstelle | Nutzen | Aufwand | Lohnt |
|---|---|---|---|---|
| Template Method / Shared Module (extract common persistence helper) | `ui.nvim/lua/ui/statusline/state.lua:112` | statusline/state.lua (184 lines) and context/state.lua (219 lines) carry near-identical private helpers: may_touch (112 vs 147), inspect (74 vs 109), sanitize, read/write/remove. The same file-safety rules are kept in two places, so a fix must land twice. One small 'safe_json_state' helper, parameterised by schema/default_path/sanitize, would remove the copy. | S | yes |
| Strategy (tabbed renderer table) for context draw mode | `ui.nvim/lua/ui/context/init.lua:1330` | context/init.lua is 1896 lines with draw_mimic and draw_chips (about 340 lines) behind a string if/else. A styles table like tabline/styles.lua, or splitting the chip renderer into its own module, would shrink the file and let hosts add styles. Splitting the file is the main gain. A registry only pays off if a third style is wanted. | M | marginal |
| Command table for mouse actions | `ui.nvim/lua/ui/slots/view/chips.lua:810` | on_pointer is an if/elseif chain on base and item.kind (up/down/slot) with embedded actions. A small table keyed by base then kind would work, but the chain is only about 10 lines. Low value, listed for completeness. | XS | marginal |

## 7 Metriken

### 7.1 Signatur-Zaehler pro Repo (Lua, ohne TESTS)

Grep-Zaehlung von Zeilen, die ein Muster enthalten; Naeherungswerte, keine Beweise. `autocmd` = `nvim_create_autocmd` (Observer), `setmetatable` (Klassen/Proxy), `ctor` = `M.new`/`:new`, `register` = `register*(` (Registry), `coroutine`, `schedule` = `vim.schedule`, `pcall_require` = optionale/lazy Abhaengigkeit, `fn_tables` = `handlers[`/`strategies[`/`dispatch[`. Die Spalte `notify_bus` der Rohdatei war zu unscharf und ist weggelassen.

| repo | autocmd | setmetatable | ctor | register | coroutine | schedule | pcall_require | fn_tables |
|---|---|---|---|---|---|---|---|---|
| ai.nvim | 3 | 1 | 0 | 6 | 0 | 11 | 13 | 0 |
| buffer-ctx.nvim | 2 | 1 | 0 | 27 | 0 | 0 | 41 | 0 |
| cascade.nvim | 2 | 1 | 0 | 2 | 0 | 0 | 10 | 1 |
| casedesk.nvim | 1 | 2 | 1 | 22 | 0 | 23 | 72 | 0 |
| cmdlog.nvim | 0 | 0 | 0 | 12 | 0 | 13 | 6 | 0 |
| color_my_ascii.nvim | 0 | 2 | 0 | 5 | 0 | 4 | 14 | 0 |
| dap.nvim | 0 | 0 | 0 | 14 | 43 | 5 | 64 | 0 |
| data.nvim | 0 | 0 | 0 | 6 | 0 | 6 | 15 | 0 |
| debugging.nvim | 13 | 1 | 0 | 3 | 0 | 4 | 27 | 0 |
| diff.nvim | 0 | 0 | 0 | 21 | 0 | 3 | 10 | 2 |
| docmap.nvim | 5 | 28 | 2 | 31 | 0 | 18 | 45 | 0 |
| emojis.nvim | 0 | 0 | 0 | 4 | 0 | 6 | 17 | 0 |
| fileops.nvim | 0 | 0 | 0 | 6 | 0 | 20 | 12 | 0 |
| filetree.nvim | 7 | 1 | 1 | 62 | 0 | 61 | 127 | 7 |
| github_stats.nvim | 0 | 0 | 0 | 4 | 0 | 9 | 13 | 0 |
| gitsuite.nvim | 11 | 1 | 2 | 16 | 0 | 22 | 32 | 0 |
| gopath.nvim | 0 | 9 | 0 | 12 | 0 | 17 | 54 | 0 |
| hover.nvim | 1 | 1 | 0 | 6 | 0 | 14 | 68 | 0 |
| images.nvim | 2 | 0 | 0 | 13 | 1 | 32 | 35 | 0 |
| insights.nvim | 1 | 0 | 0 | 7 | 0 | 10 | 38 | 0 |
| language.nvim | 1 | 3 | 1 | 13 | 6 | 23 | 33 | 0 |
| lib.nvim | 23 | 57 | 22 | 108 | 17 | 176 | 62 | 0 |
| lsp.nvim | 5 | 2 | 0 | 32 | 0 | 34 | 116 | 17 |
| markdown.nvim | 26 | 2 | 0 | 16 | 0 | 13 | 56 | 0 |
| mdview.nvim | 3 | 1 | 0 | 8 | 0 | 29 | 42 | 0 |
| media.nvim | 2 | 1 | 0 | 9 | 0 | 35 | 32 | 0 |
| my.nvim | 1 | 0 | 0 | 6 | 0 | 8 | 26 | 0 |
| open.nvim | 0 | 0 | 0 | 41 | 0 | 1 | 30 | 3 |
| pdfport.nvim | 0 | 2 | 0 | 22 | 0 | 22 | 33 | 0 |
| pickers.nvim | 5 | 4 | 4 | 16 | 0 | 14 | 84 | 0 |
| recommender.nvim | 0 | 0 | 0 | 4 | 0 | 13 | 11 | 0 |
| replacer.nvim | 2 | 0 | 5 | 23 | 0 | 21 | 39 | 0 |
| reposcope.nvim | 0 | 1 | 0 | 26 | 0 | 45 | 14 | 0 |
| rules.nvim | 0 | 2 | 1 | 16 | 0 | 0 | 6 | 0 |
| runtime-analysis.nvim | 59 | 85 | 36 | 287 | 18 | 335 | 196 | 0 |
| sandbox.nvim | 1 | 0 | 0 | 16 | 0 | 48 | 19 | 0 |
| sessions.nvim | 4 | 1 | 0 | 5 | 0 | 5 | 29 | 0 |
| spotlight.nvim | 1 | 0 | 0 | 5 | 0 | 7 | 9 | 0 |
| tasks.nvim | 1 | 2 | 7 | 19 | 2 | 26 | 12 | 0 |
| terminal.nvim | 7 | 1 | 4 | 9 | 0 | 17 | 9 | 0 |
| testing.nvim | 14 | 41 | 35 | 48 | 7 | 43 | 107 | 0 |
| ui.nvim | 7 | 5 | 1 | 41 | 0 | 32 | 69 | 1 |

### 7.2 Abgeleitete Kennzahlen aus dem Index

| Repo | Verwendungen | Kandidaten | davon lohnend (yes) | Muster-Vielfalt (distinkte Patterns) |
|---|---|---|---|---|
| ai-desktop | 8 | 2 | 1 | 8 |
| ai.nvim | 13 | 2 | 0 | 12 |
| appkit | 13 | 0 | 0 | 12 |
| buffer-ctx.nvim | 6 | 2 | 0 | 5 |
| cascade.nvim | 8 | 2 | 1 | 8 |
| casedesk.nvim | 16 | 4 | 2 | 12 |
| cmdlog.nvim | 8 | 2 | 2 | 7 |
| color_my_ascii.nvim | 8 | 0 | 0 | 8 |
| dap.nvim | 9 | 1 | 1 | 8 |
| data.nvim | 8 | 1 | 1 | 7 |
| debugging.nvim | 6 | 2 | 1 | 4 |
| diff.nvim | 6 | 1 | 0 | 6 |
| docmap-desktop | 10 | 5 | 2 | 9 |
| docmap.nvim | 13 | 5 | 2 | 10 |
| emojis.nvim | 5 | 2 | 2 | 4 |
| fileops.nvim | 5 | 2 | 2 | 4 |
| filetree.nvim | 14 | 3 | 1 | 11 |
| github_stats.nvim | 8 | 1 | 1 | 8 |
| gitsuite.nvim | 14 | 4 | 3 | 12 |
| gopath.nvim | 13 | 5 | 1 | 11 |
| hover.nvim | 13 | 2 | 1 | 13 |
| images.nvim | 6 | 1 | 0 | 6 |
| insights.nvim | 8 | 1 | 1 | 5 |
| language.nvim | 8 | 1 | 0 | 7 |
| lib.nvim | 20 | 2 | 1 | 16 |
| lsp.nvim | 18 | 3 | 3 | 13 |
| markdown.nvim | 11 | 4 | 2 | 8 |
| mdview.nvim | 13 | 2 | 1 | 10 |
| media.nvim | 8 | 1 | 1 | 8 |
| my.nvim | 8 | 1 | 1 | 6 |
| open.nvim | 6 | 1 | 0 | 5 |
| openinnvim | 6 | 0 | 0 | 6 |
| pdfport.nvim | 8 | 1 | 1 | 7 |
| pickers.nvim | 7 | 0 | 0 | 6 |
| recommender.nvim | 3 | 2 | 2 | 3 |
| replacer.nvim | 7 | 3 | 2 | 7 |
| reposcope.nvim | 6 | 2 | 1 | 6 |
| rules-desktop | 8 | 1 | 1 | 7 |
| rules.nvim | 13 | 1 | 0 | 11 |
| runtime-analysis.nvim | 19 | 6 | 3 | 17 |
| sandbox.nvim | 6 | 1 | 1 | 6 |
| sessions.nvim | 5 | 0 | 0 | 5 |
| spotlight.nvim | 5 | 1 | 1 | 5 |
| streamtap | 8 | 3 | 3 | 7 |
| takt | 6 | 1 | 0 | 6 |
| tasks-desktop | 11 | 3 | 1 | 8 |
| tasks.nvim | 13 | 5 | 2 | 12 |
| terminal.nvim | 7 | 0 | 0 | 7 |
| testing.nvim | 22 | 7 | 3 | 19 |
| ui.nvim | 14 | 3 | 1 | 10 |

Kandidaten nach Aufwand: XS=22, S=39, M=36, L=8. Lohnend (yes): 56 von 105.

### 7.3 Weitere Metriken, die sich guenstig erheben lassen (Vorschlaege)

Noch nicht erhoben, jeweils per Grep/Skript in Minuten machbar und gut zu den Patterns passend:

- **Verzweigungs-Leitern:** Anzahl `elseif`-Ketten mit >= 5 Zweigen auf demselben Wert pro Repo (Strategy-/Dispatch-Tabellen-Kandidaten); Skript zaehlt pro Funktion.
- **Funktionslaenge und Dateigroesse:** laengste Funktionen und Dateien > 1000 Zeilen pro Repo (God-Object, Facade-Aufteilung). Einzelne Dateien mit ueber 2000 Zeilen wurden bei den Kandidaten bereits genannt.
- **Duplikate:** near-identische Funktionen ueber Repos hinweg (z. B. handgeschriebenes Debounce statt `lib.nvim.debounce`), mit jscpd o. ae.; Mass fuer verpasste lib.nvim-Nutzung.
- **lib.nvim-Adoption:** Anteil Dateien mit `require('lib...')` je Repo und Zahl der Eigenimplementierungen von debounce/registry/hooks/memo.
- **Kopplung:** `require`-Graph, Fan-in/Fan-out pro Modul, Zyklen (Mediator-/Facade-Bedarf, Dependency-Injection-Kandidaten).
- **Hartverdrahtete Abhaengigkeiten:** Zahl der `pcall(require, ...)` pro Repo und Anteil, der eine Strategy-/Adapter-Schnittstelle verdient (siehe 7.1, filetree und lsp liegen vorn).
- **Globaler Zustand:** Modul-lokale veraenderliche Tabellen (`local state = {}`) pro Modul (State-/Memento-Bedarf, Testbarkeit).
- **Pattern-Dichte:** Verwendungen pro 1000 Zeilen Code (aus 7.2 und der Zeilenzahl der Repos), um duenn und dicht gepruefte Repos zu vergleichen.

## 8 Folge-Tasks

Aus den 56 lohnenden Kandidaten (worth=yes) wurde je Repo eine Task `<area>/pattern-kandidaten-umsetzen` angelegt (Tag `pattern-index`, kein Umbau in der Index-Task). Die Kandidaten mit "marginal" bleiben nur im Index. Besonders lohnend: testing.nvim (zwei ~1000-Zeilen-Funktionen), docmap-desktop (5800/5200-Zeilen-Dateien), lsp.nvim `env_links.lua` (2233 Zeilen), das geteilte appkit-Extraktionspotenzial (StreamCounter/FileOpener in tasks-desktop und rules-desktop), sowie die XS-Debounce-Treffer (markdown, gitsuite) fuer `lib.nvim.debounce`.

- `lib.nvim/pattern-kandidaten-umsetzen` (1)
- `runtime-analysis.nvim/pattern-kandidaten-umsetzen` (3)
- `testing.nvim/pattern-kandidaten-umsetzen` (3)
- `casedesk.nvim/pattern-kandidaten-umsetzen` (2)
- `tasks.nvim/pattern-kandidaten-umsetzen` (2)
- `docmap.nvim/pattern-kandidaten-umsetzen` (2)
- `docmap-desktop/pattern-kandidaten-umsetzen` (2)
- `ui.nvim/pattern-kandidaten-umsetzen` (1)
- `filetree.nvim/pattern-kandidaten-umsetzen` (1)
- `hover.nvim/pattern-kandidaten-umsetzen` (1)
- `lsp.nvim/pattern-kandidaten-umsetzen` (3)
- `gopath.nvim/pattern-kandidaten-umsetzen` (1)
- `mdview.nvim/pattern-kandidaten-umsetzen` (1)
- `markdown.nvim/pattern-kandidaten-umsetzen` (2)
- `gitsuite.nvim/pattern-kandidaten-umsetzen` (3)
- `cascade.nvim/pattern-kandidaten-umsetzen` (1)
- `cmdlog.nvim/pattern-kandidaten-umsetzen` (2)
- `dap.nvim/pattern-kandidaten-umsetzen` (1)
- `data.nvim/pattern-kandidaten-umsetzen` (1)
- `debugging.nvim/pattern-kandidaten-umsetzen` (1)
- `media.nvim/pattern-kandidaten-umsetzen` (1)
- `fileops.nvim/pattern-kandidaten-umsetzen` (2)
- `emojis.nvim/pattern-kandidaten-umsetzen` (2)
- `insights.nvim/pattern-kandidaten-umsetzen` (1)
- `github_stats.nvim/pattern-kandidaten-umsetzen` (1)
- `my.nvim/pattern-kandidaten-umsetzen` (1)
- `pdfport.nvim/pattern-kandidaten-umsetzen` (1)
- `recommender.nvim/pattern-kandidaten-umsetzen` (2)
- `reposcope.nvim/pattern-kandidaten-umsetzen` (1)
- `sandbox.nvim/pattern-kandidaten-umsetzen` (1)
- `replacer.nvim/pattern-kandidaten-umsetzen` (2)
- `spotlight.nvim/pattern-kandidaten-umsetzen` (1)
- `ai-desktop/pattern-kandidaten-umsetzen` (1)
- `streamtap/pattern-kandidaten-umsetzen` (3)
- `tasks-desktop/pattern-kandidaten-umsetzen` (1)
- `rules-desktop/pattern-kandidaten-umsetzen` (1)
