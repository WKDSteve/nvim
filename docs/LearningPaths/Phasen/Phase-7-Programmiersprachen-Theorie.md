# Phase 7: Programmiersprachen-Theorie (SICP, Typsysteme)

Teil des [Lernplans](../Lernplan.md), Hauptspur, ab Monat 24 (offenes Ende, ca. 28 Wochen). Hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) PL-Theorie →3. Voraussetzung: [Phase 2](Phase-2-Compiler-und-Interpreter.md)
(Lox-Interpreter), sinnvoll ist die Mathe-Spur bis M2 (Beweise, Induktion).

**Nachweis:** ein statischer Typchecker für Lox (mit Beweis-Skizze der Typsicherheit), SICP komplett mit allen
Pflichtaufgaben, alle Fragen unten ohne Nachschlagen beantwortet.

**Lage im Bestand:** Pierce, *Types and Programming Languages* (TAPL) fehlt im Bestand und steht jetzt in der
[Beschaffungsliste]($REPOS_DIR/Literatur/Beschaffungsliste.md), Abschnitt 7. Für SICP liegen drei Ausgaben vor; die
Seitenlinks unten gehen in die englische 2. Auflage (hat Lesezeichen), die deutsche Ausgabe hat denselben Aufbau.

Links mit `#page=N` zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.

## Quellen

| Kürzel | Buch | Datei |
|---|---|---|
| **[SICP]** | Abelson/Sussman, *Structure and Interpretation of Computer Programs* (2nd, englisch) | [PDF]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf) |
| **[SICP-DE]** | dasselbe, *Struktur und Interpretation von Computerprogrammen* (4. Aufl.) | [PDF]($REPOS_DIR/Literatur/02_Programming/SICP/Struktur-und-Interpretation-von-Computerprogrammen_Abelson-Sussman_2001_4ed.pdf) |
| **[SICP-JS]** | dasselbe, JavaScript Edition (2022), falls Scheme stört | [PDF]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs-JavaScript-Edition_Abelson-Sussman_2022.pdf) |
| **[TAPL]** | Pierce, *Types and Programming Languages* | fehlt, Beschaffungsliste |
| **[CI]** | Nystrom, *Crafting Interpreters*, das Grundgerüst für den Typchecker | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf) |
| **[LUI]** | Steele/Sussman, *Lambda: The Ultimate Imperative* (1976), Lesestück | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Paradigmen/Lambda-The-Ultimate-Imperative_Steele-Sussman_1976.pdf) |
| **[PR]** | *Programming Rust*, Kap. 11 „Traits and Generics“ als praktisches Gegenstück | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf) |

## Wochenplan SICP (Wochen 1–14)

### Woche 1–3: Prozeduren (Kap. 1)

Lesen: [1.1 Elemente des Programmierens]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=34) · [1.2 Prozeduren und die Prozesse, die sie erzeugen]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=68) ·
[1.3 Abstraktion mit Prozeduren höherer Ordnung]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=102)

**Fragen**

1. Was ist das Substitutionsmodell, und was unterscheidet applikative von normaler Auswertungsreihenfolge?
   (SICP 1.1.5)
2. Wann erzeugt eine rekursive Prozedur einen iterativen Prozess (Endrekursion), und was kostet der rekursive
   Prozess an Platz? (SICP 1.2.1)
3. Wie wächst die Zahl der Aufrufe bei der naiven Fibonacci-Rekursion, und wie machst du daraus eine Laufzeit
   von O(log n)? (SICP 1.2.2, 1.2.4)
4. Was bedeutet „Prozeduren als Argumente und als Rückgabewerte“, und wie bildet `lambda` Closures? (SICP 1.3)

**Aufgaben (SICP-Aufgaben):** 1.3, 1.7 (bessere `good-enough?`), 1.11 (rekursiv und iterativ), 1.16
(schnelles Potenzieren, iterativ), 1.19 (Fibonacci in logarithmischer Zeit), 1.22 (Primzahltest mit Zeit), 1.29
(Simpson), 1.46 (iterative Verbesserung).

### Woche 4–6: Daten (Kap. 2)

Lesen: [2.1 Datenabstraktion]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=140) · [2.2 Hierarchische Daten]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=160) ·
[2.3 Symbolische Daten]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=220) · [2.4 Mehrfache Darstellungen]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=257) ·
[2.5 Systeme mit generischen Operationen]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=282)

**Fragen**

1. Was ist eine Abstraktionsbarriere, und wie zeigt das Beispiel der rationalen Zahlen den Nutzen? (SICP 2.1)
2. Was heißt „Abschlusseigenschaft“ (closure property), und wie baut man damit Listen von Listen? (SICP 2.2)
3. Wie bildet man `map`, `filter` und `accumulate` aus Listenoperationen, und wie kombiniert man sie zu
   „Signalfluss“-Programmen? (SICP 2.2.3)
4. Wie funktionieren datengesteuerte Programmierung und Nachrichtenübergabe? (SICP 2.4.3–2.4.4)

**Aufgaben:** 2.17, 2.18, 2.27, 2.29 (Mobile), 2.33–2.39 (`accumulate`), 2.42 (Acht Damen), 2.56 (symbolisches
Ableiten), 2.73 (datengesteuertes Ableiten).

### Woche 7–9: Zustand, Objekte, Ströme (Kap. 3)

Lesen: [3.1 Zuweisung und lokaler Zustand]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=324) · [3.2 Das Umgebungsmodell]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=348) ·
[3.3 Mutierbare Daten]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=369) · [3.4 Nebenläufigkeit]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=429) · [3.5 Ströme]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=456)

**Fragen**

1. Warum zerstört Zuweisung das Substitutionsmodell, und was ist „referentielle Transparenz“? (SICP 3.1.3)
2. Wie sieht das Umgebungsmodell aus (Rahmen, Zeiger auf die umgebende Umgebung)? Zeichne es für einen Aufruf einer
   Closure. (SICP 3.2) *(Vergleich: `jlox` in [Phase 2](Phase-2-Compiler-und-Interpreter.md).)*
3. Welche Probleme entstehen bei gemeinsamem veränderlichem Zustand und Nebenläufigkeit? (SICP 3.4.1)
4. Wie arbeiten verzögerte Auswertung und Ströme (`delay`, `force`, `cons-stream`), und was ist ein
   unendlicher Strom? (SICP 3.5)

**Aufgaben:** 3.5 (Monte-Carlo), 3.17 (`count-pairs`), 3.22 (Warteschlange als Prozedur), 3.59 (Potenzreihen als
Ströme), 3.77 (Gleichungen als Ströme).

### Woche 10–12: Meta-linguistische Abstraktion (Kap. 4)

Lesen: [4.1 Der metazirkuläre Auswerter]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=520) · [4.2 Lazy Evaluation]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=569) ·
[4.3 Nichtdeterministisches Rechnen]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=587) · [4.4 Logikprogrammierung]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=622)

**Fragen**

1. Wie arbeiten `eval` und `apply` gegenseitig, und welche Sonderformen (`if`, `define`, `lambda`) behandelt
   `eval` selbst? (SICP 4.1.1)
2. Wie unterscheidet sich Lazy Evaluation (4.2) vom Ausführen mit `delay`, wo liegt der Preis (Thunks)?
3. Was ist `amb`, und wie sucht der Auswerter mit Backtracking? (SICP 4.3)
4. Wie arbeitet ein Logik-Auswerter: Unifikation, Mustervergleich? (SICP 4.4)

**Aufgaben:** 4.1 (Reihenfolge der Operanden), 4.6 (`let`), 4.11, 4.14, 4.22, 4.35 (`an-integer-between`), 4.55
(Datenbankabfragen). Dann **`eval` für Lox in Lox**: ein Lox-Interpreter in Lox (nur die Teilmenge ohne Klassen),
und vergleiche mit dem Aufbau von `jlox`.

### Woche 13–14: Registermaschinen und Compilation (Kap. 5)

Lesen: [5.1 Entwurf von Registermaschinen]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=696) · [5.2 Ein Simulator]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=724) ·
[5.3 Speicherverwaltung]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=751) · [5.4 Der Evaluator mit expliziter Steuerung]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=769) ·
[5.5 Compilation]($REPOS_DIR/Literatur/02_Programming/SICP/Structure-and-Interpretation-of-Computer-Programs_Abelson-Sussman_1996_2ed.pdf#page=795)

**Fragen**

1. Wie baust du aus Registern und Operationen eine Maschine für den größten gemeinsamen Teiler?
2. Wie funktioniert Stop-and-Copy-Speicherbereinigung (Cheney)? Vergleiche mit dem Mark-and-Sweep aus
   [Phase 2, Woche 16](Phase-2-Compiler-und-Interpreter.md). (SICP 5.3.2)
3. Wie übersetzt der Compiler in 5.5 einen Ausdruck, was spart er gegenüber dem Interpreter? (SICP 5.5)

**Aufgaben:** 5.4 (Registermaschinen für `expt`), 5.19 (Haltepunkte im Simulator).

Lesestück dazu: [LUI]($REPOS_DIR/Literatur/01_Fundamentals/Paradigmen/Lambda-The-Ultimate-Imperative_Steele-Sussman_1976.pdf#page=1) – wie `lambda` Zuweisung, Schleifen und `goto` ersetzt.

## Wochenplan Typsysteme (Wochen 15–28)

Lesen in [TAPL] (Kapitelnummern der Originalausgabe, beim Kauf prüfen):

| Woche | Kapitel | Inhalt |
|---|---|---|
| 15–16 | 1–3 | Einführung, mathematische Grundlagen, untypisierte arithmetische Ausdrücke (Syntax, Semantik, Beweis durch Induktion) |
| 17–18 | 5–7 | Untypisierter λ-Kalkül, namenlose Darstellung (de Bruijn), Umsetzung |
| 19–20 | 8–10 | Typisierte Arithmetik, **einfach typisierter λ-Kalkül**, Typchecker-Umsetzung |
| 21 | 11–12 | Einfache Erweiterungen (Tupel, Records, Varianten, `let`), Normalisierung |
| 22 | 13–14 | Referenzen, Ausnahmen |
| 23–24 | 15–16 | Untertypen (Subtyping), Metatheorie |
| 25–26 | 22–23 | Typrekonstruktion (Hindley-Milner), universelle Typen (System F) |
| 27–28 | 24 oder 29 | Existenzielle Typen oder Typoperatoren (nach Wahl) |

**Fragen** (nach den Kapiteln, ohne Seiten)

1. Was sind Fortschritt (Progress) und Erhaltung (Preservation), und wie folgt daraus „wohlgetypte Programme
   bleiben nicht stecken“?
2. Wie lauten die Typisierungsregeln für Variable, Abstraktion und Anwendung im einfach typisierten λ-Kalkül?
   Beweise den Substitutionslemma-Fall für die Abstraktion.
3. Warum terminiert jedes wohlgetypte Programm im einfach typisierten λ-Kalkül (Normalisierung), und was bricht
   das (Rekursion, `fix`)?
4. Wie lautet die Regel für Untertypen bei Funktionen (kontravariant im Argument, kovariant im Ergebnis), und
   warum sind veränderliche Arrays, die kovariant sind, unsicher (Java)?
5. Wie funktioniert Hindley-Milner: Typvariablen, Constraints, Unifikation, Let-Polymorphismus?
6. Was kann System F, das einfach typisierte λ-Kalkül nicht (`∀a. a → a`), und warum ist Typinferenz dort
   unentscheidbar?

Praktisch dazu: [PR 11: Traits and Generics]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=257) (Rust als angewandte Typtheorie: Bounds,
Assoziierte Typen, Lebensdauern) und [CI 11: Resolving and Binding]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=168) (statische Analyse in Lox).

### Abschlussprojekt: Typchecker für Lox (Nachweis)

1. **Syntax erweitern:** optionale Typannotationen (`var x: Number = 1;`, `fun f(a: Number, b: String): Bool`).
2. **Typen:** `Number`, `String`, `Bool`, `Nil`, Funktionstypen, Klassentypen, `Any` für nicht annotierte Teile
   (graduelle Typisierung).
3. **Algorithmus:** bidirektionales Prüfen (Typ ableiten und gegen einen erwarteten Typ prüfen) auf dem AST von
   `jlox`; Fehlermeldungen mit Zeile und Spalte.
4. **Untertypen:** Klassenvererbung und Nullbarkeit (`T | Nil`) mit der Funktionsregel (kontravariant/kovariant).
5. **Beweis-Skizze:** Fortschritt und Erhaltung für das Kernfragment (ohne Klassen) auf Papier oder in Lean/Coq.
6. **Test:** 100 Programme, die abgelehnt werden müssen (mit erwarteter Meldung), 100, die durchgehen; ein
   Zufallsgenerator für wohlgetypte Programme prüft, dass der Interpreter nie einen Typfehler zur Laufzeit meldet.

## Nachweis und Abschluss

- [ ] SICP: alle genannten Aufgaben gelöst (Repository)
- [ ] Typchecker für Lox mit Tests und Beweis-Skizze
- [ ] Alle Fragen beantwortet
- [ ] TAPL besorgt; Typsystem-Wochen mit Kapitel- und Seitenlinks ergänzt
- [ ] Matrix aktualisiert: PL-Theorie →3

## Fortschritt

| Block | Gelesen | Fragen | Aufgabe | Notiz (Link) |
|---|---|---|---|---|
| SICP Kap. 1 | | | | |
| SICP Kap. 2 | | | | |
| SICP Kap. 3 | | | | |
| SICP Kap. 4 | | | | |
| SICP Kap. 5 | | | | |
| Typen 15–20 | | | | |
| Typen 21–28 | | | | |
| Typchecker für Lox | | | | |
