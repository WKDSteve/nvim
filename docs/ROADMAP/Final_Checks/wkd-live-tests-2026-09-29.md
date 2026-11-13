# wkd — Live-Test-Checkliste (Stand 2026-09-29)

Alle Features/Fixes aus diesem Chat, die noch nicht live (sichtbarer Browser-Tab, echte
60fps-Bedienung) getestet wurden — in dieser Sandbox war das teils technisch nicht
möglich (`requestAnimationFrame` läuft bei ausgeblendetem Browser-Pane nicht/kaum, siehe
`Backlog/wkd_Completed.md` in wkdbook-native/wkd). Checkbox-Konvention: `- [ ]` offen, `- [x]`
verifiziert. Bei jedem Punkt eine Zeile `Notiz:` zum Eintragen von Beobachtungen.

**Wichtig für den Fight-Tab:** unbedingt auch auf der echten deployten Seite
(`https://wkdsteve.github.io/wkd/`) testen, nicht nur lokal per `pnpm dev` — der
CSP-Fix für die Charakterauswahl-Vorschau war in `pnpm dev` unsichtbar, weil der
Astro-Dev-Server die strikte CSP nicht durchsetzt wie das echte GitHub-Pages-Deployment.

**Sortiert am 2026-11-13** (Task `wkd/live-liste-wkd-live-tests-2026-09-29-sortieren-erledigtes-ab`). Der Fight
liegt seit wkd@a4d8e18 auf `/wkd/play/`, „Fight-Tab“ meint diese Seite. Jeder Punkt trägt in seiner Notiz, wo er
jetzt steht:

- abgehakt, weil eine Browser-Prüfung ihn belegt: 6
- abgehakt, weil überholt oder erledigt: 6
- bekommt ein Testblatt (`wkd/testblaetter-der-browser-engine-fuer-wkd`): 9
- von Hand am Bildschirm (`wkd/fight-am-bildschirm-abnehmen`): 31
- von Hand, zwei Geräte (`wkd/fight-online-zwischen-zwei-geraeten`): 6
- von Hand, echte Geräte (`wkd/fight-auf-echten-geraeten`): 8

---

## Wie starte ich das?

**Deployte Seite (empfohlen für die meisten Punkte, Pflicht für den CSP-Hinweis oben):**
einfach `https://wkdsteve.github.io/wkd/` im Browser öffnen. Alle Commits aus diesem
Chat sind bereits auf `main` gemergt und `.github/workflows/deploy.yml` deployt bei jedem
Push nach `main` automatisch — sollte also schon live sein (im Zweifel unter
`github.com/WKDSteve/wkd/actions` den letzten „deploy"-Run prüfen, falls die Seite
noch alt aussieht: GitHub Pages cached teils ein paar Minuten).

**Lokal per `pnpm dev`:** dein Haupt-Checkout unter `$REPOS_DIR/wkd` (nicht diese
Worktree-Session) steht noch auf dem alten Stand `9c6b500` — erst pullen:

```bash
cd $REPOS_DIR/wkd
git pull
pnpm install   # nur nötig, falls sich Dependencies geändert haben
pnpm dev
```

Dann `http://localhost:4321/wkd/` öffnen (Pfad-Präfix `/wkd/` nicht vergessen, sonst
404). **Für den Fight-Tab lokal:** Charakterauswahl-Vorschau/Filter werden dort
funktionieren, obwohl der zugrunde liegende CSP-Bug real war — der Dev-Server setzt die
CSP einfach nicht durch. Nur die deployte Seite ist der echte Test dafür.

Kein `pnpm build`/`pnpm preview` nötig zum Testen — beides nur für den reinen
Build-Check, nicht zum interaktiven Durchklicken.

---

## T13 — Mobile-Optimierung

- [x] Header-Nav bei 375px und 768px (echtes Handy/Tablet oder Android-Emulator) — kein
      horizontaler Scroll, `[ tui ]`-Link nicht abgeschnitten.
  - Notiz: auto 2026-11-13: wkd `tests/browser/site.browser.mjs` (wkd@c96ea71) grün, gegen `dist/` und gegen die Live-Seite; elf Seiten bei 375 und 768 px ohne Seitwärts-Scroll, beide Skins.
- [ ] Kachel-Grid, Orbit, Tree, `/stack`, `ui.nvim`-Detailseite auf Mobile/Tablet — kein
      Overflow.
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`. Die Seiten selbst sind bei 375 und 768 px geprüft; Tree und Orbit werden dort noch nicht umgeschaltet.
- [ ] Kachel-Hover-Flyout (T2) auf einem echten Touch-Gerät antippen — sollte (bekannt)
      strukturell nicht erreichbar sein, nur zur Bestätigung.
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.
- [ ] Tree-Ansicht auf Mobile: horizontaler Scroll-Container ohne Swipe-Hinweis —
      spürbar/verwirrend, oder ok so?
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.

---

## T14 — Grid/Tree/Orbit-Crossfade

- [ ] Zwischen Grid → Tree → Orbit → Grid wechseln — sanftes Einfaden, kein Layout-Sprung,
      keine kurz klickbaren/fokussierbaren Elemente der ausgeblendeten Ansicht.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`. Die Ansichten liegen jetzt auf `/wkd/nvim/`.

---

## T15 — Bug-Sweep (7 Fixes) + Folgefix `prefs.ts`

- [ ] Skin-Präferenz auf `tui` stellen (z. B. einmal auf `/tui/` wechseln), dann zurück zur
      `modern`-Startseite, Tree-Ansicht öffnen, einen Plugin-Knoten anklicken — sollte zum
      `tui`-Skin führen (nicht zurück nach `modern`).
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`.
- [ ] Dasselbe für die Orbit-Ansicht (Spoke anklicken statt Tree-Knoten).
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`.
- [ ] Kategorie-Filter rein per Tastatur ansteuern (Tab zu einem Filter-Pill, nicht
      Maus-Hover) — Pill sollte die Neon-Hover-Farbe wechseln.
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`.
- [ ] `tui`-Skin: `modern` als Präferenz speichern, dann `/tui/` aufrufen — gelber
      Skin-Hinweisbalken erscheint, Sidebar/Footer bleiben an der richtigen Stelle (kein
      aufgeblähter Hinweisbalken, keine verschobene Fußzeile).
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`.
- [x] `scripts/pull-demos.sh` einmal laufen lassen — `public/demos/` sollte sauber neu
      befüllt werden (alte, nicht mehr im `demo-assets`-Branch vorhandene Dateien
      verschwinden).
  - Notiz: erledigt 2026-11-13: gelaufen, `public/demos/` neu befüllt (84 Dateien); das Skript löscht den Ordner vorher.
- [ ] Nächstes Mal, wenn ein VHS-Tape mit `scripts/tape-chapters.mjs` generiert wird:
      Kapitel-Liste prüfen, falls das Tape zwei Titel-Starts während einer `Hide`-Phase
      hintereinander hat.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`. Bei Gelegenheit, kein eigener Termin.

---

## T7 — Fight-Minigame

- [ ] Fight-Tab öffnen — Charakterauswahl zeigt drei Karten (Samurai Mack, Martial Hero,
      Kenji), je ein sauberes Sprite-Standbild (nicht gequetscht/als Streifen).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`. Der Reiter ist jetzt die Seite `/wkd/play/` mit vier Kämpfern; die Zahl der Karten ist automatisch geprüft, das Bild nur per Auge.
- [ ] Martial Hero ist farblich (grünlich getönt) klar von Samurai Mack unterscheidbar.
      Kenji ist eine echt andere Grafik (eigenes Outfit/Farbe).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [x] Kämpfer wählen — Arena erscheint, beide Health-Bars bei 100 %, Timer bei 60.
  - Notiz: auto 2026-11-13: wkd `tests/browser/site.browser.mjs` (wkd@c96ea71) grün, gegen `dist/` und gegen die Live-Seite; beide Balken 100 %, Uhr bei 60 und sie läuft.
- [ ] Bewegung: Pfeil links/rechts bewegt den Charakter erwartungsgemäß.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] Sprung: Pfeil hoch springt (nur wenn am Boden, kein Doppelsprung in der Luft).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] Angriff: Leertaste (leicht) UND `X` (schwer, mehr Schaden, längerer Cooldown)
      lösen je eine eigene Angriffsanimation aus, danach geht der Charakter wieder
      normal in Idle/Run/Jump über (bleibt NICHT dauerhaft in der Angriffspose hängen).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [x] Kein „Phantom-Treffer": Health der Gegenseite sinkt nur, wenn wirklich kurz zuvor
      angegriffen wurde, nicht einfach beim Wieder-Annähern ohne neuen Angriff. _(auto 2026-10-29: wkd/tests/fight-sim.test.ts grün)_
  - Notiz:
- [x] **Besonders wichtig (war ein echter, vom Review gefundener Bug):** nach dem
      ERSTEN kassierten Treffer kann die getroffene Seite (Spieler UND KI) weiterhin
      normal angreifen/sich bewegen, bleibt NICHT dauerhaft in der Trefferpose hängen. _(auto 2026-10-29: wkd/tests/fight-sim.test.ts grün)_
  - Notiz:
- [ ] KI-Gegner bewegt sich Richtung Spieler, greift gelegentlich an, springt selten.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] Match endet nach 60 s (Timer-Ablauf) oder bei K. o. — Ergebnistext („You win." /
      „You lose." / „Draw.") stimmt mit dem tatsächlichen Verlauf überein.
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`.
- [ ] Rematch-Button startet ein neues Match; Level-Farbfilter (Tag/Dusk/Nacht) wirkt über
      mehrere Rematches hinweg sichtbar unterschiedlich (zufällig gewählt).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [x] Escape während eines laufenden Matches drücken — zurück zu Grid, UND das Match
      pausiert wirklich (Health ändert sich danach nicht mehr im Hintergrund).
  - Notiz: überholt 2026-11-13: es gibt kein Grid mehr neben dem Spiel; `Esc` beendet das Match (wkd@a4d8e18), geprüft in `tests/browser/`.
- [ ] Nach Escape/Tab-Wechsel: ins Suchfeld klicken, Leertaste/Pfeiltasten tippen —
      landet im Suchfeld, bewegt/attackiert NICHT den (pausierten) Kämpfer.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] Bewegungstaste (Pfeil links/rechts) gedrückt halten, während gehalten zu
      Grid/Tree/Orbit wechseln oder Tab wechseln, Taste dabei loslassen, dann zurück zu
      Fight — Charakter sollte NICHT von selbst weiterlaufen.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`. Der Teil mit Grid/Tree/Orbit ist überholt; es bleibt der Wechsel des Browser-Tabs.
- [x] Esc-Hinweis („Esc back to grid") ist auch auf dem Charakterauswahl-Screen sichtbar
      (bevor ein Kämpfer gewählt wurde), nicht erst in der Arena.
  - Notiz: überholt 2026-11-13: der Hinweis heißt „Esc end the match“ und gehört zum laufenden Match (wkd@a4d8e18).
- [ ] Gesamteindruck Performance: läuft spürbar flüssig, keine Ruckler/Hänger.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Auf der echten deployten Seite** (`wkdsteve.github.io/wkd`) wiederholen,
      mindestens die Charakterauswahl-Vorschau (CSP-Fix) und einen kompletten Kampf.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`. Die Live-Seite meldet in 15 Prüfungen keinen CSP-Verstoß (2026-11-13); der ganze Kampf bleibt von Hand.

### T7-Folgerunde (nach deinem Live-Test-Screenshot, `wkd@74e9bf4`, noch nicht gemergt)

- [ ] **Boden-Fix:** Kämpfer stehen jetzt mit den Füßen sauber auf dem Steinweg, nicht
      mehr schwebend darüber (war der ursprüngliche Bug aus deinem Screenshot).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Touch-Steuerung:** die On-Screen-Buttons (←/→/↑/A/B) unter der Arena bewegen/
      springen/greifen den Charakter genauso wie Tastatur — testweise auch mit der Maus
      anklickbar, nicht nur auf echtem Touch.
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.
- [ ] **Kenji spielbar:** eigene Animationen (kürzere Idle/Angriffs-Zyklen als die
      anderen beiden), Bodenausrichtung auch bei Kenji korrekt.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Vollbild-Button** — Arena geht in echten Vollbildmodus, Button-Text wechselt zu
      „Exit fullscreen", Escape/Browser-eigene Vollbild-Taste verlässt ihn wieder.
      **War ein echter, vom Review gefundener Bug:** Touch-Buttons und Tasten-Legende
      müssen im Vollbild sichtbar/erreichbar bleiben (nicht unten aus dem Bild
      gedrängt).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Sieg/Niederlage-Zähler** zwischen den Health-Bars zählt nach einem gewonnenen/
      verlorenen Match hoch und bleibt auch nach Neuladen der Seite erhalten
      (`localStorage`).
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`.
- [ ] **„FIGHT!"-Intro:** beim Start eines Matches (und jedem Rematch) fliegt „FIGHT!"
      groß ins Bild, kurz bevor die Steuerung aktiv wird. Dazu ein Sound — **das ist
      bewusst kein echtes „FIGHT!"-Voice-Sample, sondern ein synthetischer Platzhalter-
      Ton** (Web Audio, kein Audio-Asset vorhanden). Bewerten: stört es, ist es zu leise/
      laut, reicht es als Platzhalter? Zusätzlich: einen Touch-Button (z. B. Sprung)
      GENAU während der kurzen Intro-Phase gedrückt halten — sollte trotzdem wirken,
      sobald die Intro vorbei ist (war ebenfalls ein Review-Fund).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [x] **Musik-Toggle** (Button oben rechts): schaltet eine simple, ebenfalls nur
      prozedural erzeugte Hintergrund-Loop an/aus, Einstellung bleibt nach Neuladen
      erhalten, Musik startet automatisch mit jedem Match, wenn eingeschaltet.
  - Notiz: auto 2026-11-13: wkd `tests/browser/site.browser.mjs` (wkd@c96ea71) grün, gegen `dist/` und gegen die Live-Seite; die Einstellung übersteht das Neuladen; ob die Musik klingt, steht beim Punkt F3.

---

## T16/T17 — FightingGame-Ausbau (ab 2026-10-01)

Plan und Phasenstatus: `../wkd/handovers/wkd_FightingGame_Implementierungsplan.md`.

- [x] **T16 Hover-Sound:** Maus über den „Fight"-Tab bewegen — kurzer Blip (erst nach dem
      ersten Klick irgendwo auf der Seite hörbar, Browser-Autoplay-Regel).
  - Notiz: überholt 2026-11-13: den Reiter „Fight“ und seinen Ton gibt es nicht mehr (wkd@a4d8e18).
- [ ] **F1 Gegner trifft jetzt wirklich.** Die KI-Blickrichtung war seit T7 invertiert,
      sie konnte praktisch nie treffen. Jetzt verliert man im Stehen in rund 10 s.
      Bewerten: Schwierigkeit ok, zu hart, zu leicht?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **F1 Kenji schaut in die richtige Richtung** (als Spieler nach rechts zum Gegner,
      als Gegner nach links), Schwertschlag geht Richtung Gegner.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **F1 Geschwindigkeit:** auf einem 120/144-Hz-Display läuft das Spiel gleich schnell
      wie auf 60 Hz (vorher doppelt so schnell). Fühlt sich das Tempo insgesamt richtig an?
      Schwünge sind ca. 15 % schneller als vorher.
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.
- [ ] **F1 Gedrückt halten:** Leertaste/X/Touch-Button halten greift wiederholt an, sobald
      der Cooldown es zulässt; Pfeil hoch halten springt nach der Landung erneut.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [x] **F1 Pause:** während eines Matches zu Grid wechseln, 10 s warten, zurück — die
      Matchuhr steht dort, wo sie war (lief vorher im Hintergrund weiter).
  - Notiz: überholt 2026-11-13: es gibt kein Grid mehr neben dem Spiel. Die Pause mit `P` ist geprüft: die Uhr steht, Resume lässt sie weiterlaufen (`tests/browser/`).
- [ ] **F2 Gamepad:** Controller anschließen, eine Taste drücken — Legendenzeile
      „Gamepad: …" erscheint. Stick/D-Pad bewegt, A springt, X leicht, B/Y schwer.
      Bisher nur mit simuliertem Controller getestet.
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.
- [ ] **F3 Musik/SFX über AudioWorklet:** klingt die Musik-Loop gleichmäßig (kein
      Stottern, wenn die Seite gerade beschäftigt ist)? Treffer-, „FIGHT!"- und Hover-Sound
      ok? Auf der deployten Seite testen (CSP).
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **F4 Partikel:** bei Treffern fliegen Pixel-Funken in Schlagrichtung, beim Landen
      nach einem Sprung staubt es kurz. Stil passend, zu viel, zu wenig? (Nur mit WebGPU,
      also Chrome/Edge; ohne WebGPU oder mit „Bewegung reduzieren" gibt es keine.)
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [x] **F5 WASM-Kern:** Seite mit `?sim=wasm` öffnen — unter der Arena steht „Sim core:
      Rust / WebAssembly", das Spiel verhält sich identisch.
  - Notiz: auto 2026-11-13: wkd `tests/browser/site.browser.mjs` (wkd@c96ea71) grün, gegen `dist/` und gegen die Live-Seite; die Legende nennt „Rust / WebAssembly“; das gleiche Verhalten belegt `tests/fight-wasm.test.ts`.
- [ ] **F6 Rollback fühlen:** Seite mit `?net=loopback&lag=100` öffnen und gegen die KI
      spielen (auch `lag=200&jitter=50&loss=10` probieren). Statuszeile unter der Arena
      zählt Rollbacks. Eigene Eingaben sollten sich trotz Latenz direkt anfühlen, der
      Gegner „springt" bei Fehlvorhersagen leicht.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`. Die Statuszeile mit den Rollbacks ist automatisch geprüft (`?net=loopback&lag=100`); das Gefühl bleibt von Hand.
- [ ] **F7 Online gegen einen Freund (gleiches WLAN):** Gerät A „Invite a friend", Code an
      Gerät B schicken, dort „Join with a code", Antwortcode zurück, „Connect". Beide wählen
      einen Kämpfer. Prüfen: Verbindung kommt zustande, „you" steht über dem eigenen
      Balken, Ergebnis stimmt auf beiden Seiten, Rematch (beide klicken), ein Gerät
      schließt den Tab und das andere fällt auf die Kämpferauswahl zurück. Bisher nur mit
      zwei Tabs auf einem Rechner getestet.
  - Notiz: von Hand: Task `wkd/fight-online-zwischen-zwei-geraeten`.
- [ ] **F7 Balance:** Samurai Mack gegen Kenji im PvP, beide halten Angriff gedrückt —
      Kenji kommt nicht zum Zug (Stun-Lock). So lassen oder angleichen?
  - Notiz: von Hand: Task `wkd/fight-online-zwischen-zwei-geraeten`. Eine Entscheidung: so lassen oder angleichen.

### Nach dem Review (2026-10-01) — nur auf echten Geräten prüfbar

- [ ] **Tempo auf anderen Displays:** Spiel auf einem 144-Hz-, 75-Hz- und einem 60-Hz-
      Display (oder bei hoher Last) laufen lassen — Matchuhr und Bewegung gleich schnell?
      (Der alte Frame-Snap ließ 15-ms-Frames 11 % zu schnell und 18-ms-Frames 7 % zu
      langsam laufen.)
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.
- [ ] **Online: Verlassen, Rematch, Tippfehler.** Nach dem ersten Match gibt es oben in der
      Arena „Disconnect"; es führt zur Kämpferauswahl, das Gegenüber bekommt „connection
      lost". Falschen Antwortcode einfügen und „Connect": Meldung „not valid", die
      Einladung bleibt, ein zweiter Versuch mit dem richtigen Code klappt. Zweimal
      „Rematch" klicken löst nicht das übernächste Match aus.
  - Notiz: von Hand: Task `wkd/fight-online-zwischen-zwei-geraeten`.
- [ ] **Online: schlechte Leitung.** Eine Seite wechselt für > 1 s den Tab: die andere zeigt
      „waiting for your friend", nach 30 s ohne Spielpakete wird die Verbindung beendet.
      Mit WLAN-Aussetzern spielen (oder Gerät kurz in den Flugmodus): am Ende zeigen beide
      Seiten dasselbe Ergebnis.
  - Notiz: von Hand: Task `wkd/fight-online-zwischen-zwei-geraeten`.
- [ ] **Tap-Eingaben:** ein sehr kurzer Tipper auf einen Touch-Button während des
      „FIGHT!"-Intros löst den Angriff beim ersten Live-Frame aus (wie im alten Spiel).
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.
- [ ] **Treffer-Funken online:** bei 100 ms+ Latenz sehen und hören auch die Treffer, die
      erst durch eine Korrektur der Vorhersage entstehen, Funken und Sound (vorher rund
      9 % ohne). Ein vorhergesagter Treffer, der dann zurückgenommen wird, bleibt gemeldet.
  - Notiz: von Hand: Task `wkd/fight-online-zwischen-zwei-geraeten`.
- [ ] **Partikel beim Rematch:** das Match mit einem Treffer beenden, Rematch klicken — die
      Funken des letzten Schlags tauchen im neuen Match nicht wieder auf.
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Online nach langer Pause:** beide verbunden, 1 Minute auf der Kämpferauswahl oder
      dem Ergebnisbildschirm sitzen, dann Match/Rematch starten — die Verbindung bleibt.
      Gast-Tab beim Start in den Hintergrund legen: das Match wartet, der Host zeigt
      „waiting for your friend", nach Rückkehr geht es mit „FIGHT!"-Banner und Sound los.
  - Notiz: von Hand: Task `wkd/fight-online-zwischen-zwei-geraeten`.
- [ ] **Code mit Tippfehler:** im Antwort- oder Einladungscode ein Zeichen ändern und
      „Connect"/„Create reply" klicken — „not valid", die Einladung bleibt, der richtige
      Code funktioniert danach.
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`. Geht auf einem Rechner: ein ungültiger Code muss „not valid“ melden.
- [ ] **Leertaste auf Buttons:** nach einem Match Tab auf „Rematch" oder „Disconnect", Space
      löst sie aus (im laufenden Match bleibt Space der leichte Angriff).
  - Notiz: bekommt ein Testblatt: Task `wkd/testblaetter-der-browser-engine-fuer-wkd`.
- [ ] **Spezial-Moves:** jeder der vier Kämpfer hat einen (`C`, Pad `Y`, Touch `S`):
      Samurai Mack Bodenwelle, Martial Hero Orb, Kenji Teleport hinter den Gegner, Ronin
      Pistole. Name steht neben dem Kämpfernamen und ist abgedunkelt, solange der Move
      abklingt. Passen Tempo, Schaden, Abklingzeiten (2,5–4,5 s)? Sehen die gezeichneten
      Projektile gut genug aus oder sollen sie Pixel-Art bekommen?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Sprung-Ausweichen (Abnahme T21):** einem leichten Schwung kann man ausweichen, wenn
      man kurz *vor* dem Schwung springt (Samurai: 2–12 Frames vorher); der schwere Schwung
      trifft Springer weiter. Der Bodenwelle weicht jeder Sprung aus. Ist das der Mittelweg,
      zu leicht, zu schwer?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Figurengröße:** die Kämpfer sind größer gezeichnet (2,1 statt 1,7). Passt das zur
      Arena und zu den Treffern?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Unwinnable:** vierte Stufe in der Gegner-Zeile. Lässt sie sich wirklich nicht
      schlagen? (13 Skript-Strategien gewinnen kein Match; ein Mensch wurde nicht getestet.)
      Ist der Name ok oder lieber „Impossible"?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Gegner allgemein:** die KI schlägt jetzt aus voller Reichweite zu, nutzt ihren
      Spezial-Move und springt über Projektile. „Reinlaufen und Angriff halten" gewinnt
      gegen Hard aber noch oft — so lassen?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [x] **Schwierigkeitsgrad:** auf der Kämpferauswahl Easy / Normal / Hard (wird gemerkt,
      Standard Normal). „Hard" ist der Gegner von vorher. Passt die Abstufung, passt Normal
      als Standard?
  - Notiz: auto 2026-11-13: wkd `tests/browser/site.browser.mjs` (wkd@c96ea71) grün, gegen `dist/` und gegen die Live-Seite; die Wahl übersteht das Neuladen; ob die Abstufung passt, steht bei „Gegner allgemein“.
- [x] **Pause:** im Match gegen die KI `P` oder „Pause" — Bild steht, Uhr steht, „Paused"
      mit Resume / Change fighter. Zu Grid und zurück: bleibt pausiert. Online gibt es weder
      Pause noch „Change fighter".
  - Notiz: auto 2026-11-13: wkd `tests/browser/site.browser.mjs` (wkd@c96ea71) grün, gegen `dist/` und gegen die Live-Seite; `P` hält Bild und Uhr an, Resume setzt fort. „Zu Grid und zurück“ ist überholt; online ohne Pause steht in der Online-Task.
- [ ] **K.O.-Ausklang:** beim K.O. fällt der Verlierer wirklich um, „K.O." fliegt ein, gut
      eine Sekunde später kommt das Ergebnis („K.O. You win."), bei Zeitablauf „TIME" und
      „Time up. …". Fühlt sich die Länge richtig an?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **HUD und Treffer:** Namen über den Balken („You · Kenji"), Balken blinkt unter 25 %,
      bei Treffern ruckt das Bild kurz. Zu viel, zu wenig?
  - Notiz: von Hand: Task `wkd/fight-am-bildschirm-abnehmen`.
- [ ] **Flüssigkeit:** Nacht-/Dämmerungs-Arena und Martial Hero auf einem 120/144-Hz-Display
      oder einem schwachen Gerät — läuft es spürbar ruhiger als vorher? (Filter werden jetzt
      einmal vorgerendert; echte Messung auf dem Gerät steht aus.)
  - Notiz: von Hand: Task `wkd/fight-auf-echten-geraeten`.
- [x] **Hover-Blip vor dem ersten Klick:** frisch geladene Seite, Maus über den Fight-Tab:
      kein Ton, auch nicht verspätet nach dem ersten Klick. Danach (nach einem Klick)
      funktioniert der Blip. Safari/iOS: Ton kommt nach Telefonat/Sperrbildschirm zurück.
  - Notiz: überholt 2026-11-13: den Reiter „Fight“ und seinen Ton gibt es nicht mehr (wkd@a4d8e18). Der Safari-Teil (Ton nach Sperrbildschirm) steht in der Geräte-Task.

---

*Erstellt aus dem Chat-Verlauf der wkd-Handover-Fortsetzungs-Session vom 2026-09-29
(T13/T14/T15/T7 + alle Nachfixe + T7-Folgerunde nach Live-Test-Feedback). Vollständige
Historie/Details in `$REPOS_DIR/WKDBooks/Development/wkdbook-native/wkd/Backlog/wkd_Completed.md`
bzw. `Handover/wkd_Handover.md`.*
