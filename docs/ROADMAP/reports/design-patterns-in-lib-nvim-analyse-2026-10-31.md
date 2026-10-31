---
title: Design Patterns als lib.nvim-Module - lohnt sich das?
date: 2026-10-31
refs: [ALL/design-pattern-index-2026-10-31.md]
---

# Design Patterns als lib.nvim-Module: Analyse (2026-10-31)

Frage: Sollen Design Patterns als Module in `lib.nvim` angelegt und in allen Repos verwendet werden, um einen Standard zu schaffen und die Patterns im Code sichtbar zu machen (der Modulname traegt den Pattern-Namen)?

**Kurzantwort:** Ja fuer die *verhaltenstragenden* Patterns, nein fuer die *strukturellen*. Die meisten lohnenden Module gibt es in lib.nvim schon. Das eigentliche Problem ist die Nutzung, nicht der Bestand: die Repos bauen dieselben Dinge selbst nach. Der groesste Hebel sind daher Adoption, Auffindbarkeit (Pattern-Karte in der Doku) und ein Lint-Gate, dazu zwei oder drei neue Module. Ein Umbenennen auf GoF-Namen (`lib.patterns.observer`) oder ein zweiter Alias-Namensraum lohnt nicht.

## 1 Bestand: was lib.nvim schon hat und wer es nutzt

Zaehlung: Repos (`*.nvim` ausser lib.nvim, 42 Stueck), die das Modul per `require` laden.

| Pattern | lib.nvim-Modul | Repos, die es nutzen | Eigenbauten in den Repos |
|---|---|---|---|
| Command (Subcommand-Routing) | `lib.nvim.bindings.usercmd.composer` | **40** | trotzdem 333 `elseif sub/cmd/action/kind/mode == ...`-Zeilen, oft Dispatch hinter dem Composer |
| Debounce | `lib.nvim.debounce` | 15 | 57 `new_timer()`-Aufrufe in 35 Repos, ein Teil davon handgebaute Debounce/Throttle (markdown, gitsuite, casedesk, mdview x3) |
| Registry | `lib.nvim.registry` | **1** (docmap) | eigene `register/unregister`-Tabellen u. a. in filetree (adapter, refs, create_names), ui (variants, slots/kinds, tabline/styles, menu/contributors), replacer, diff, gitsuite. Viele `M.register()` sind aber nur Setup-Funktionen und keine Registry. |
| Observer / Event Bus | `lib.nvim.hooks` | **1** (replacer) | eigene `listeners = {}`/`emit()` in 14 Repos (testing.nvim 7 Dateien, casedesk, tasks, markdown, filetree, ui ...) |
| Async/Promise | `lib.nvim.async` | 4 | dap.nvim nutzt 43 rohe `coroutine.*` |
| Cache/Memoize | `lib.lua.memo` | 6 | - |
| Lazy Initialization / Proxy | `lib.lua.lazy`, `strategies/lazy` | 3 | docmap.nvim: 6 handgebaute `setmetatable/__index`-Proxys (init.lua:253) |
| Klassen / Template Method | `lib.lua.class` | **0** | testing.nvim 30 eigene `__index`-Klassen, pickers 4, lsp 2 |
| Memento | `lib.nvim.ui.kit.history`, `lib.nvim.checkpoint` | 0 / 1 | - |
| RAII / Bracket | `lib.lua.context_manager` | 0 | - |
| Null Object | `lib.lua.null` | 4 | - |

Rohdaten: Signatur-Zaehler in `design-pattern-index-2026-10-31.md` Abschnitt 7, Adoptionszaehlung aus diesem Lauf.

Befund: Die Module fuer Registry, Observer, Klassen und Memento sind da, getestet und dokumentiert, werden aber fast nirgends genutzt. Das zeigt sich auch daran, dass der Index 484 Pattern-Verwendungen fand, die ueberwiegend handgebaut sind.

## 2 Welche Patterns gehoeren in eine Bibliothek, welche nicht

Ein Pattern eignet sich fuer ein lib-Modul, wenn es **wiederkehrenden, fehleranfaelligen Mechanismus** enthaelt (Timer, Lebenszyklus, Fehlerisolation, Reihenfolge). Patterns, die nur eine **Codeform** beschreiben, werden durch ein Modul nur indirekter.

| Gruppe | Patterns | Als lib-Modul? | Grund |
|---|---|---|---|
| Mechanismus | Observer/Event Bus, Registry, Debounce/Throttle, Async, Memoize, Lazy, Memento/History, Retry/Backoff, State Machine | **ja** | Timer-Aufraeumen, `pcall`-Isolation, Prioritaeten, Unsubscribe, Weak-Refs: das wird beim Nachbauen regelmaessig falsch gemacht (Beispiel: der PERF-62-Timer-Workaround ist in markdown.nvim von Hand nachgebaut). |
| Duenner Helfer | Strategy/Dispatch-Tabelle, Adapter-Registry, Null Object | **teilweise** | In Lua ist die Strategy die Tabelle selbst (`local handlers = { a = fn }`). Ein Helfer lohnt nur, wenn er mehr mitbringt: Fallback, Fehlermeldung bei unbekanntem Key, Completion-Liste, Registrierung von aussen. |
| Struktur | Facade, Module, Singleton, Composite, Decorator, Template Method, Builder, Visitor, Interpreter, Bridge, Flyweight, Mediator | **nein** | Das ist Architektur, kein wiederverwendbarer Code. Ein `lib.patterns.facade` waere eine leere Huelle. Sichtbar machen per Doku/Annotation statt per Modul. |

## 3 Namensgebung und Sichtbarkeit

Der Gedanke "Modul aus lib.nvim heisst wie das Pattern, also ist das Pattern sichtbar" stimmt teilweise schon heute: `registry`, `lazy`, `memo`, `null`, `debounce`, `history`, `checkpoint` sind sprechend. Abweichend sind `hooks` (= Observer/Event Bus), `composer` (= Command), `context_manager` (= RAII/Bracket).

Optionen:

| Option | Vorteil | Nachteil | Empfehlung |
|---|---|---|---|
| A: Module auf GoF-Namen umbenennen (`lib.nvim.observer`) | Pattern sofort am `require` erkennbar | Breaking Change in allen Nutzer-Repos, Doku-Churn, `hooks` beschreibt das Feature (Veto, Prioritaet) treffender als "observer" | nein |
| B: Alias-Namensraum `lib.pattern.*`, der re-exportiert | Kein Breaking Change, Pattern-Namen durchsuchbar | Zwei Namen fuer dasselbe, Index/Doku muss beide pflegen, Agents nutzen zufaellig mal den einen, mal den anderen | nein |
| C: Pattern-Karte `lib.nvim/docs/patterns.md` (Pattern -> Modul -> Beispiel) plus Zeile `Pattern: Observer` im README jedes Moduls und in der LuaLS-Doku (`---@module`-Block) | Billig, durchsuchbar, aendert keinen Code, Agents finden das Modul ueber den Pattern-Namen | Sichtbarkeit nur in der Doku, nicht am Aufruf | **ja** |
| D: Kurzkommentar an der Nutzungsstelle (`-- Strategy: renderer per style`) bei klasslosen Umsetzungen | Pattern im Code sichtbar, auch ohne lib-Modul | Disziplinfrage, kann veralten | ja, als Konvention in `LUA_NVIM.md`, nicht als Pflicht |

## 4 Vorteile

- **Ein getesteter Mechanismus statt vieler Nachbauten.** Timer-Lecks, fehlende `pcall`-Isolation in Listenern, vergessenes Unsubscribe werden einmal in lib.nvim behoben und nicht in 15 Repos. Beispiele: 57 rohe Timer, 14 eigene Emitter.
- **Standard und Wiedererkennung.** Wer `lib.nvim.registry` oder `lib.nvim.hooks` sieht, kennt die API (register/get/find, on/off/run, Rueckgabe = Unsubscribe-Funktion). Das hilft mir und vor allem Agents, die sonst pro Repo eine neue Variante erfinden.
- **Messbar.** Die Adoption ist per Grep zaehlbar (wie in Abschnitt 1). Das macht ein Gate moeglich: "neuer `new_timer()` ausserhalb lib.nvim nur mit Begruendung".
- **Weniger Code pro Plugin.** Die Kandidaten aus dem Index (Dispatch-Ketten, doppelte Throttle, Proxy-Kopien) schrumpfen beim Umbau auf das lib-Modul.
- **Konsistenz zur bestehenden Regel** "lib.nvim verwenden, wo moeglich" (Wartbarkeit).

## 5 Nachteile und Risiken

- **Indirektion.** Ein 5-Zeilen-`listeners`-Array ist lesbarer als `hooks.new{}` mit Prioritaeten und Veto, wenn man beides nicht braucht. Generische Module verlocken zu Over-Engineering ("Pattern um des Patterns willen", im Index bewusst ausgeschlossen).
- **Kopplung.** Jede API-Aenderung an `registry`/`hooks` trifft potenziell alle Repos. Bei 40 Composer-Nutzern ist das schon heute so; mehr Module heisst mehr Bindung und hoehere Anforderungen an Stabilitaet und Versionierung von lib.nvim.
- **Startzeit.** Zusaetzliche `require`s beim Setup. Gering, wenn ueber `lib.lua.lazy` geladen, aber pro Plugin messen (`PERFORMANCE.md`).
- **Typisierung.** Generische Registries/Hooks verlieren in LuaLS Typinformation (Eintraege werden `any`), solange keine Generics/`@generic`-Annotationen gepflegt werden.
- **Migrationsaufwand und Risiko.** Jeder Umbau braucht laut Regel einen Test, der ohne ihn rot waere. Das ist bei reinen Refactorings oft muehsam, und die Flotten-Regeln (sauberer Baum, Suite gruen, CI) gelten pro Repo.
- **Falsche Vereinheitlichung.** Nicht jedes `M.register()` ist eine Registry (viele sind Setup fuer Keymaps/Autocmds). Wer blind umstellt, macht Code schlechter.

## 6 Aufwand

| Schritt | Inhalt | Aufwand |
|---|---|---|
| 1 Pattern-Karte | `lib.nvim/docs/patterns.md` (Pattern -> Modul -> Beispiel -> Gegenanzeige), `Pattern:`-Zeile in den Modul-READMEs, Verweis aus `LUA_NVIM.md` | S (0.5 d) |
| 2 Fehlende Module | `lib.nvim.throttle` (leading/trailing, Vorlage: 3 Kopien in mdview), Option `leading` fuer `debounce`; `lib.nvim.explorer` als Adapter-Registry fuer neo-tree/NvimTree/netrw/oil (heute in filetree, pdfport, fileops, open.nvim, debugging, my.nvim je eigen erkannt); optional `lib.lua.dispatch` (Tabelle + Fallback + Completion) | S + M + S |
| 3 Adoption, billig | Debounce/Throttle-Eigenbauten auf lib umstellen (markdown, gitsuite, casedesk, mdview, docmap-Proxys), je XS-S. Liegt groesstenteils schon in den 35 Folge-Tasks `*/pattern-kandidaten-umsetzen`. | ca. 2-3 d gesamt |
| 4 Adoption, teuer | eigene Emitter/Registries auf `hooks`/`registry` (testing.nvim, ui.nvim, filetree, tasks.nvim, casedesk) nur dort, wo sie echte Duplikate sind | M je Repo, ca. 5-8 d gesamt, nur bei Gelegenheit |
| 5 Gate | luacheck-/rules-vault-Gate: `new_timer()`-Debounce und eigene `listeners`-Arrays ausserhalb lib.nvim melden (Warnung, Ausnahmeliste) | S |

Nicht empfohlen: Klassen-Migration (testing.nvim 30 eigene `__index`-Klassen auf `lib.lua.class`). Die eigenen Klassen funktionieren, der Umbau ist L und bringt kaum Nutzen.

## 7 Nutzen-Aufwand-Bewertung

| Massnahme | Nutzen | Aufwand | Verhaeltnis |
|---|---|---|---|
| Pattern-Karte + README-Zeilen (Option C) | hoch (Auffindbarkeit fuer Agents, genau das Ziel "sichtbar") | S | **sehr gut** |
| Throttle/Debounce vereinheitlichen | mittel-hoch (Timer-Bugs, PERF-Workarounds an einer Stelle) | S-M | **sehr gut** |
| Explorer-Adapter-Registry | mittel (6 Repos, neue Explorer nur einmal einbauen) | M | gut |
| Gate gegen neue Eigenbauten | mittel (verhindert Rueckfall) | S | gut |
| hooks/registry-Adoption in Gross-Repos | mittel (Standard), aber Risiko | M je Repo | nur bei Gelegenheit, wenn das Modul ohnehin umgebaut wird |
| Dispatch-Helfer `lib.lua.dispatch` | gering-mittel (Tabelle ist in Lua schon die Loesung; Gewinn nur Fallback/Completion) | S | marginal |
| State-Machine-Modul | gering (zwei echte Faelle: testing.nvim per-file lifecycle, lsp.nvim markdown-Block-Parser) | M | erst bei drittem Fall |
| GoF-Umbenennung / Alias-Namensraum | gering | M-L | **nicht machen** |

## 8 Empfehlung

1. **Option C umsetzen:** Pattern-Karte in lib.nvim und `Pattern:`-Zeilen. Damit sind die Patterns ohne Code-Churn sichtbar, und der Design-Pattern-Index kann auf sie verweisen.
2. **Zwei Module ergaenzen:** `throttle` (bzw. `debounce` mit `leading`) und `explorer`-Adapter. Danach die XS/S-Kandidaten aus den Folge-Tasks auf lib umstellen.
3. **Gate als Warnung** gegen neue Timer-/Emitter-Eigenbauten, damit der Standard haelt.
4. **Keine** Struktur-Patterns als Module, keine Umbenennung, keine Pflicht-Migration der grossen Repos. `hooks`/`registry` nur bei ohnehin anstehenden Umbauten einziehen.

Offen fuer die Entscheidung: Task `ALL/design-patterns-in-lib-nvim-entscheiden`.
