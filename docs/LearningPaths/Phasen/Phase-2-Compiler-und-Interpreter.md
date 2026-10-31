# Phase 2: Interpreter und Compiler (Crafting Interpreters)

Teil des [Lernplans](../Lernplan.md), Hauptspur, Monate 6–10 (ca. 16 Wochen). Hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) Compiler 1→4 und Lua T 3→4. Voraussetzung: [Phase 1](Phase-1-Systeme-und-C.md)
(Zeiger, Speicher, Assembly).

**Nachweis:** `jlox` (Tree-Walking-Interpreter, Java oder Go) **und** `clox` (Bytecode-VM in C), beide vollständig
mit den Tests des Buchs; jede Challenge, die du gelöst hast, mit Notiz.

Links mit `#page=N` zeigen auf die PDF-Seite. Pfade liegen unter `$REPOS_DIR`. Die Seite hinter jeder Frage nennt
die Stelle, an der die Antwort beginnt.

## Quellen

| Kürzel | Buch | Datei |
|---|---|---|
| **[CI]** | Nystrom, *Crafting Interpreters* | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf) |
| **[L]** | Ierusalimschy u. a., *The Implementation of Lua 5.0* (18 Seiten) | [PDF]($REPOS_DIR/Literatur/02_Programming/Lua/The-Implementation-of-Lua-5-0_Ierusalimschy-etal_2005.pdf) |
| **[B]** | Ball, *Writing an Interpreter in Go* (Alternative für Teil 1: Monkey statt Lox) | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Writing-an-Interpreter-in-Go_Ball_2016.pdf) |

Als Nachschlagewerk, nicht zum Durcharbeiten: Aho u. a. (Dragon Book), Cooper/Torczon, Appel (siehe
[Lernplan](../Lernplan.md), „Nur nachschlagen“).

Jedes Kapitel in [CI] endet mit **Challenges** (Übungsaufgaben) und einem **Design Note**. Die Challenges sind die
Aufgaben dieser Phase; die Lösung steht nicht im Buch, also selbst lösen und gegen das eigene Verhalten prüfen.

## Wochenplan

### Woche 1: Überblick und Sprache (Kap. 1–3)

Lesen in [CI]: [1 Introduction]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=2) · [2 A Map of the Territory]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=10) ·
[3 The Lox Language]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=21)

**Fragen**

1. Welche Stationen hat ein Compiler (Scanner, Parser, Analyse, IR, Optimierung, Codegen)? Wo liegt der Unterschied
   zwischen Front End und Back End? (S. 10)
2. Wann ist etwas ein Interpreter, wann ein Compiler, wann ein Transpiler? Was ist eine Virtual Machine? (S. 17)
3. Welche Typen, Kontrollstrukturen und Funktionsmerkmale hat Lox (Closures, Klassen, dynamische Typisierung)?
   Schreibe ein Lox-Programm mit Closure-Zähler. (S. 21)

**Aufgabe:** Die Challenges der Kapitel 1–3; dazu drei Lox-Programme von Hand schreiben (Fibonacci rekursiv,
Closure-Zähler, Klasse mit Vererbung) – sie sind später die Tests.

### Woche 2–3: Scanner und Syntaxbaum (Kap. 4–5)

Lesen in [CI]: [4 Scanning]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=38) · [5 Representing Code]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=57)

**Fragen**

1. Was ist ein Lexem, was ein Token? Warum scannt man „maximal munch“? (S. 38)
2. Wie behandelt der Scanner Zeilenkommentare, Strings über mehrere Zeilen und Zahlen wie `12.`? (S. 38)
3. Was ist eine kontextfreie Grammatik, und wie leitet man mit ihr einen Ausdruck ab? (S. 57)
4. Was ist das Visitor-Muster, und welches Problem löst es für den Syntaxbaum (Expression Problem)? (S. 57)

**Aufgabe:** Scanner für Lox mit Zeilennummern in Fehlermeldungen. Challenges 4: verschachtelte Blockkommentare.
Dann: Klassen für den AST (per Hand oder Generator) mit `AstPrinter` in umgekehrt polnischer Notation.

### Woche 4–5: Parser und Auswertung (Kap. 6–7)

Lesen in [CI]: [6 Parsing Expressions]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=76) · [7 Evaluating Expressions]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=94)

**Fragen**

1. Wie sieht die Grammatik mit Rangfolge (Gleichheit, Vergleich, Term, Faktor, unär) aus, und wie macht
   rekursiver Abstieg daraus eine Funktion pro Regel? (S. 76)
2. Was ist Fehler-Erholung im Parser („Panic Mode“ und Synchronisation)? (S. 76)
3. Wie bildet man dynamische Typen im Host ab (Java `Object`), und wie prüft man Operanden? (S. 94)
4. Was ist „truthiness“ in Lox, und welchen Wert hat `nil == nil`? (S. 94)

**Aufgabe:** Rekursiver Abstiegsparser für Ausdrücke. Challenges 6: Komma-Operator, `?:`, binäre Operatoren ohne
linken Operanden als Fehler. Auswerter mit Laufzeitfehlern (Zeilennummer, Meldung).

### Woche 6–7: Anweisungen, Zustand, Kontrollfluss (Kap. 8–9)

Lesen in [CI]: [8 Statements and State]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=108) · [9 Control Flow]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=133)

**Fragen**

1. Wie sind Umgebungen (Environments) verkettet, und was bedeutet Shadowing? (S. 108)
2. Warum ist `var a;` etwas anderes als `var a = nil;`? Was soll `print a` vor der Definition tun? (S. 108)
3. Wie ersetzt man `for` durch `while` („Desugaring“) und was spart das? (S. 133)
4. Was sind `and`/`or` in Lox genau (Kurzschluss, liefern Operanden)? (S. 133)

**Aufgabe:** Variablen, Blöcke, `if`, `while`, `for` (als Desugaring), REPL, der auch einzelne Ausdrücke auswertet.
Challenges 8 und 9, inklusive `break`.

### Woche 8–9: Funktionen, Auflösung, Closures im Baum (Kap. 10–11)

Lesen in [CI]: [10 Functions]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=147) · [11 Resolving and Binding]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=168)

**Fragen**

1. Was ist ein Funktionsaufruf in der Umgebungskette: Wo liegt der Closure-Zustand, wo die Parameter? (S. 147)
2. Welches Verhalten bricht ein Closure, das später eine Variable im umgebenden Scope neu bindet, und wie löst die
   statische Auflösung das? (S. 168)
3. Warum prüft der Resolver `return` außerhalb von Funktionen und `var a = a;` in lokalen Scopes? (S. 168)
4. Wie viele Durchgänge hat der Interpreter nach diesem Kapitel? (S. 168)

**Aufgabe:** Funktionen, `return` (per Exception oder Result-Typ), Closures, Resolver mit Schrittzähler pro
Variable. Challenges 10 und 11: anonyme Funktionen, unbenutzte Variablen als Warnung.

### Woche 10: Klassen und Vererbung (Kap. 12–13)

Lesen in [CI]: [12 Classes]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=190) · [13 Inheritance]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=217)

**Fragen**

1. Was sind Instanzen, Felder und Methoden, und woher kommt `this`? (S. 190)
2. Wie funktioniert `init`, was liefert ein Aufruf des Konstruktors? (S. 190)
3. Wie wird `super` aufgelöst (statisch gegen dynamisch), und was sind die Fallstricke bei mehreren Ebenen?
   (S. 217)

**Aufgabe:** Klassen, Methoden, `this`, `super`. Challenge 12: Getter. Dann: **`jlox` gegen die Tests des
Buch-Repositories laufen lassen** (frei erhältlich), bis alle bestehen.

### Woche 11–12: Bytecode und VM (Kap. 14–17)

Lesen in [CI]: [14 Chunks of Bytecode]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=233) · [15 A Virtual Machine]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=257) ·
[16 Scanning on Demand]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=277) · [17 Compiling Expressions]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=297)

**Fragen**

1. Wie sieht ein Chunk aus (Opcodes, Konstantenpool, Zeileninformation), und warum ist der Opcode ein Byte?
   (S. 233)
2. Stack-VM: Wie rechnet `1 + 2 * 3` Schritt für Schritt auf dem Stack? Was kostet eine Register-VM mehr, was
   gewinnt sie? (S. 257)
3. Wie unterscheidet sich Scannen „auf Anforderung“ vom Scanner aus Teil I? (S. 277)
4. Was ist ein Pratt-Parser, und wie hängt die Präzedenztabelle mit `ParseRule` zusammen? (S. 297)
5. Vergleiche: Welches Design (Baum, Bytecode) braucht wie viel Speicher und Zeit pro Operation? (S. 257)

**Aufgabe (C):** `chunk`, `debug` (Disassembler), VM-Schleife mit Stack, Scanner, Single-Pass-Compiler für
Ausdrücke. Challenges 14–17: Zeilen-RLE, `OP_CONSTANT_LONG`, Trinitär-Operator.

### Woche 13: Werte, Strings, Hashtabellen (Kap. 18–20)

Lesen in [CI]: [18 Types of Values]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=318) · [19 Strings]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=332) · [20 Hash Tables]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=349)

**Fragen**

1. Wie ist `Value` als getaggte Union aufgebaut, und warum nicht nur `double`? (S. 318)
2. Was ist String-Interning, und was gewinnt die Gleichheit auf Zeigerebene? (S. 332)
3. Offene Adressierung mit linearem Sondieren: Wie laufen Einfügen, Suchen, Löschen (Tombstones)? Wann wächst die
   Tabelle? (S. 349)

**Aufgabe (C):** Typen `Bool`/`Nil`/`Number`/`Obj`, Strings mit Flexible Array Member, Hashtabelle mit Wachstum.
Challenges 20: Lasten faktor ändern und messen.

### Woche 14: Variablen und Kontrollfluss im Bytecode (Kap. 21–23)

Lesen in [CI]: [21 Global Variables]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=373) · [22 Local Variables]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=391) ·
[23 Jumping Back and Forth]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=405)

**Fragen**

1. Warum liegen lokale Variablen im Stack, und wie weiß der Compiler ihren Slot? (S. 391)
2. Wie kommen Sprungadressen in den Code (Backpatching bei `if`/`while`), und warum nicht beim Schreiben schon?
   (S. 405)
3. Wie entsteht `switch`, wenn man es als Challenge ergänzt? (S. 405)

**Aufgabe (C):** Globale und lokale Variablen, `if`, `while`, `for`, `and`/`or`. Challenges 22 und 23 (`switch`,
`continue`).

### Woche 15: Funktionen und Closures in der VM (Kap. 24–25)

Lesen in [CI]: [24 Calls and Functions]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=425) · [25 Closures]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=457)

**Fragen**

1. Was ist ein Call Frame, und welche Zustände (ip, Slot-Basis) enthält er? (S. 425)
2. Wie nutzt der Compiler „Upvalues“, und was passiert beim „Schließen“ eines Upvalues, wenn der Stackrahmen
   endet? (S. 457)
3. Vergleiche das mit der Umgebungskette aus `jlox` (Woche 8–9). Was ist schneller? (S. 457)
4. Lies [L, Abschnitt „Functions and Closures“]($REPOS_DIR/Literatur/02_Programming/Lua/The-Implementation-of-Lua-5-0_Ierusalimschy-etal_2005.pdf#page=8): Wie macht Lua Upvalues, und was ist anders als bei
   Lox? (Lua S. 8)

**Aufgabe (C):** Funktionen, native Funktionen (`clock`), Closures. Challenge 25: Regel, dass Closures per Wert
statt per Referenz fangen können, ausprobieren.

### Woche 16: Speicherbereinigung und Optimierung (Kap. 26 und 30)

Lesen in [CI]: [26 Garbage Collection]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=492) · [30 Optimization]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=574) und in [L]
[Abschnitt 3: Values]($REPOS_DIR/Literatur/02_Programming/Lua/The-Implementation-of-Lua-5-0_Ierusalimschy-etal_2005.pdf#page=4) · [Tabellen]($REPOS_DIR/Literatur/02_Programming/Lua/The-Implementation-of-Lua-5-0_Ierusalimschy-etal_2005.pdf#page=6) · [Virtuelle Maschine]($REPOS_DIR/Literatur/02_Programming/Lua/The-Implementation-of-Lua-5-0_Ierusalimschy-etal_2005.pdf#page=11)

**Fragen**

1. Was sind Wurzeln, was heißt „erreichbar“? Wie funktioniert Mark-and-Sweep mit Drei-Farben-Abstraktion? (S. 492)
2. Warum braucht man „Gray Stack“, und wann startet der GC (Schwellwert)? (S. 492)
3. Welche Optimierungen zeigt Kap. 30 (NaN-Boxing, Hash-Tabelle), und wie misst man sie? (S. 574)
4. Wie stellt Lua Werte dar (Tagged Value, 16 Byte), und warum hat es seine Tabelle in Array- und Hash-Teil
   getrennt? (Lua S. 4–6)
5. Lua 5.0 hat eine Register-VM. Vergleiche mit `clox` (Stack-VM): Befehlsanzahl, Dekodierung. (Lua S. 11)

**Aufgabe (C):** Mark-and-Sweep-GC mit `DEBUG_STRESS_GC` und `DEBUG_LOG_GC`; Fehler zeigen sich als
Use-after-free. Benchmark-Skripte aus dem Buch laufen lassen, vorher/nachher messen (NaN-Boxing optional).

### Danach: Klassen in der VM (Kap. 27–29) – Abschluss von `clox`

Lesen in [CI]: [27 Classes and Instances]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=519) · [28 Methods and Initializers]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=532) ·
[29 Superclasses]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=558)

**Fragen**

1. Wie sind Instanzen im Speicher aufgebaut (Felder in Hashtabelle), und was kostet ein Feldzugriff? (S. 519)
2. Was ist ein gebundener Methodenaufruf, und warum optimiert man `OP_INVOKE` (S. 532)?
3. Wie kopiert die „Vererbung“ Methoden (Copy-Down), und was ändert das für späte Änderungen der Oberklasse?
   (S. 558)

**Aufgabe (C):** Klassen, Methoden, `init`, Vererbung, `super`. Dann `clox` gegen die Buchtests laufen lassen.

## Alternative Vertiefung: Interpreter in Go

Wer `jlox` in Go statt Java bauen möchte oder einen zweiten Blick auf Pratt-Parsing sucht: [B] baut die Sprache
Monkey: [Lexer]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Writing-an-Interpreter-in-Go_Ball_2016.pdf#page=11) · [Parser]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Writing-an-Interpreter-in-Go_Ball_2016.pdf#page=30) · [Pratt-Parsing]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Writing-an-Interpreter-in-Go_Ball_2016.pdf#page=71) ·
[Auswertung]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Writing-an-Interpreter-in-Go_Ball_2016.pdf#page=105) · [Erweiterungen]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Writing-an-Interpreter-in-Go_Ball_2016.pdf#page=154).

## Nachweis und Abschluss

- [ ] `jlox` besteht alle Tests des Buch-Repositories (Link zum Repository)
- [ ] `clox` besteht alle Tests; GC läuft mit Stress-Modus ohne Fehler
- [ ] Benchmark `jlox` gegen `clox` mit Zahlen
- [ ] Alle Fragen beantwortet, mindestens 10 Challenges gelöst und notiert
- [ ] Matrix aktualisiert: Compiler 1→4, Lua T 3→4

## Fortschritt

| Block | Gelesen | Fragen | Aufgabe | Notiz (Link) |
|---|---|---|---|---|
| Woche 1 | | | | |
| Woche 2–3 | | | | |
| Woche 4–5 | | | | |
| Woche 6–7 | | | | |
| Woche 8–9 | | | | |
| Woche 10 | | | | |
| Woche 11–12 | | | | |
| Woche 13 | | | | |
| Woche 14 | | | | |
| Woche 15 | | | | |
| Woche 16 | | | | |
| Kap. 27–29 | | | | |
