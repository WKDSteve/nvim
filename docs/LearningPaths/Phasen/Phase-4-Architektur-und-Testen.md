# Phase 4: Software-Handwerk (Testen, Refactoring, Architektur)

Teil des [Lernplans](../Lernplan.md), Hauptspur, Monate 14–18 (ca. 16 Wochen). Hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) Architektur und Testing 3→4. Voraussetzung: [Phase 2](Phase-2-Compiler-und-Interpreter.md)
(größere Programme), [Phase 3](Phase-3-Algorithmen.md) (Datenstrukturen).

**Nachweis:** ein eigenes Plugin komplett refaktoriert, mit Tests (vorher/nachher gemessen) und Entscheidungen als
ADRs; alle Fragen unten ohne Nachschlagen beantwortet.

Links mit `#page=N` zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.

## Quellen

Die im [Lernplan](../Lernplan.md) genannten Bücher Ousterhout (*A Philosophy of Software Design*), Fowler
(*Refactoring*), Khorikov (*Unit Testing*) und Starke (*Effektive Softwarearchitekturen*) fehlen im Bestand; sie
stehen jetzt in der [Beschaffungsliste]($REPOS_DIR/Literatur/Beschaffungsliste.md), Abschnitt 7. Bis sie da sind, trägt diese
Seite die Phase mit folgenden Büchern aus dem Bestand; jede Woche nennt, welches Beschaffungsbuch sie später
ergänzt.

| Kürzel | Buch | Datei |
|---|---|---|
| **[WE]** | Westphal, *Testgetriebene Entwicklung mit JUnit & FIT* (Deutsch, 2006) | [PDF]($REPOS_DIR/Literatur/Deutsch/Java/Testgetriebene-Entwicklung-mit-JUnit-und-FIT_Westphal_2006.pdf) |
| **[O]** | Osherove, *The Art of Unit Testing* (2nd, C#) | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf) |
| **[LA]** | Langr, *Pragmatic Unit Testing in Java 8 with JUnit* | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf) |
| **[BU]** | Burchard, *Refactoring JavaScript* | [PDF]($REPOS_DIR/Literatur-Web/02_Programming/Web/JavaScript/Refactoring-JavaScript_Burchard_2017.pdf) |
| **[GoF]** | Gamma u. a., *Design Patterns* (1994) | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf) |
| **[BR]** | Brown, *Software Architecture for Developers* | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/Software-Architecture-for-Developers_Brown_2022.pdf) |
| **[C4]** | Brown, *The C4 Model for Visualising Software Architecture* | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/The-C4-Model-for-Visualising-Software-Architecture_Brown_2023.pdf) |
| **[PE]** | Percival, *Test-Driven Development with Python* (2nd), als Praxisbeispiel eines vollständigen TDD-Projekts | [PDF]($REPOS_DIR/Literatur-PythonAI/02_Programming/Python/Test-Driven-Development-with-Python_Percival_2017_2ed.pdf) |

Die Beispiele sind in Java/C#/JavaScript; die Konzepte übertragen sich auf Lua, Rust und TypeScript. Als
Prüfstein für die eigenen Plugins dienen die Regelwerke unter `$RULES_VAULT/rulesets/lua`.

## Wochenplan

### Woche 1–2: Testgetriebene Entwicklung

Lesen: [WE 2: Über die Schulter geschaut]($REPOS_DIR/Literatur/Deutsch/Java/Testgetriebene-Entwicklung-mit-JUnit-und-FIT_Westphal_2006.pdf#page=25) · [WE 4: Testgetriebene Programmierung]($REPOS_DIR/Literatur/Deutsch/Java/Testgetriebene-Entwicklung-mit-JUnit-und-FIT_Westphal_2006.pdf#page=67) ·
[WE 7: Testfälle schreiben von A bis Z]($REPOS_DIR/Literatur/Deutsch/Java/Testgetriebene-Entwicklung-mit-JUnit-und-FIT_Westphal_2006.pdf#page=143) · [O 1: Grundlagen]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=31) ·
[O 2: Erster Test]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=47) · [LA: Teil I, Grundlagen]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=18) · [LA: FIRST]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=64) ·
[LA: Right-BICEP]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=76) · [LA: CORRECT]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=89)

**Fragen**

1. Was sind die drei Direktiven von Westphal (TDD, Refactoring, häufige Integration), und wie hängen sie
   zusammen? (WE S. 67, 89, 125)
2. Wie sieht der TDD-Zyklus aus (Rot, Grün, Refactor), und warum soll man den Test erst fehlschlagen sehen?
   (WE 4.6–4.8, S. 72)
3. Was bedeutet FIRST, und welche Eigenschaften hat ein schlechter Test? (LA S. 64)
4. Was sind Right-BICEP und CORRECT, und wie findest du damit Randfälle? (LA S. 76, 89)
5. Was macht einen Test „gut“ (lesbar, vertrauenswürdig, wartbar)? (O S. 33–38)
6. Wie benennt man Tests, und wie ist ein Test nach dem Arrange-Act-Assert-Muster aufgebaut? (O S. 54, LA S. 26)

**Aufgabe:** Eine Kata mit reinem TDD, Test zuerst, jeden Schritt als Commit: String Calculator, danach Roman
Numerals und Bowling Game. Ablauf der Commits im Repository als Nachweis (rote und grüne Commits abwechselnd).

### Woche 3–4: Abhängigkeiten, Stubs und Mocks

Lesen: [O 3: Stubs]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=77) · [O 4: Interaktionstests]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=103) · [O 5: Isolations-Frameworks]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=118) ·
[WE 8: Isoliertes Testen]($REPOS_DIR/Literatur/Deutsch/Java/Testgetriebene-Entwicklung-mit-JUnit-und-FIT_Westphal_2006.pdf#page=191) · [WE 9: Mock-Objekte]($REPOS_DIR/Literatur/Deutsch/Java/Testgetriebene-Entwicklung-mit-JUnit-und-FIT_Westphal_2006.pdf#page=231) · [LA: Mocks]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=132)

**Fragen**

1. Was ist der Unterschied zwischen Stub und Mock, und welcher von beiden prüft das Ergebnis eines Tests? (O S. 105)
2. Wie bringt man eine Abhängigkeit testbar ein: Interface extrahieren, Konstruktor-Injektion, Property-Injektion?
   (O S. 82–90)
3. Wann ist eine Verifikation per Mock überspezifiziert, und woran erkennst du es? (O S. 134)
4. „Tell, don't ask“ und „von außen nach innen“: Was bedeuten sie für das Design? (WE S. 231–232)
5. Wann ist ein Mikro-Integrationstest besser als ein strikter Unit-Test? (WE S. 194)

**Aufgabe:** Ein Modul des eigenen Plugins (zum Beispiel einen Teil mit Dateisystem- oder Prozesszugriff) so
umbauen, dass die Außenwelt über eine Naht (Funktionstabelle, Konstruktorargument) hereinkommt. Schreibe je drei
Tests mit handgeschriebenem Stub, mit Fake und mit Verifikation der Interaktion.

### Woche 5–6: Gute Testcodebasis

Lesen: [O 7: Testhierarchie und Organisation]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=153) · [O 8: Vertrauenswürdig, wartbar, lesbar]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=179) ·
[LA: Test-Gerüche]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=145) · [LA: Größeres Bild]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=160)

**Fragen**

1. Welche Tests gehören in die „sichere grüne Zone“, und wie trennt man Unit- von Integrationstests? (O S. 158)
2. Warum hat gute Testcode keine Logik (`if`, Schleifen), und wie prüft man mehrere Fälle stattdessen? (O S. 183)
3. Nenne fünf Test-Gerüche aus dem Buch und für jeden die Abhilfe. (LA S. 147–157)
4. Wann ist Code-Coverage eine nützliche Messung, wann eine irreführende? (O S. 186)
5. Wie testet man private Methoden, und warum ist die Frage meist ein Hinweis auf ein Designproblem? (O S. 188)

**Aufgabe:** Die eigene Testsuite eines Plugins nach den Gerüchen durchsehen: eine Liste von zehn Befunden mit
Zeile, Geruch, Abhilfe. Davon fünf umsetzen. Messen vorher/nachher: Laufzeit, Anzahl, Lesbarkeit (Stichprobe).

### Woche 7–8: Legacy-Code und Testbarkeit

Lesen: [O 10: Legacy-Code]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=235) · [O 11: Design und Testbarkeit]($REPOS_DIR/Literatur-Programming/02_Programming/CSharp/The-Art-of-Unit-Testing-with-Examples-in-CSharp_Osherove_2014_2ed.pdf#page=246) · [WE 5: Refactoring]($REPOS_DIR/Literatur/Deutsch/Java/Testgetriebene-Entwicklung-mit-JUnit-und-FIT_Westphal_2006.pdf#page=89)

**Fragen**

1. Wo fängt man bei Code ohne Tests an: leicht zuerst oder schwer zuerst? Vor- und Nachteile. (O S. 236)
2. Warum schreibt man vor dem Refactoring Integrations- oder Akzeptanztests (Charakterisierungstests)? (O S. 238)
3. Nenne die Entwurfsziele für Testbarkeit (virtuell, Interface-basiert, keine statischen Aufrufe, …). (O S. 247)
4. Was sind „übel riechende“ Codestellen (Westphals Katalog), und welcher Refactoring-Zug gehört zu welchem?
   (WE S. 91 ff.)

**Aufgabe:** Das größte Modul des Plugins mit der geringsten Testabdeckung wählen. Zuerst
Charakterisierungstests (Ist-Verhalten festschreiben, auch Fehler), danach in kleinen Schritten refaktorieren.
Jeder Schritt ein Commit, Tests bleiben grün.

### Woche 9–10: Refactoring

Lesen: [BU 1: Was ist Refactoring?]($REPOS_DIR/Literatur-Web/02_Programming/Web/JavaScript/Refactoring-JavaScript_Burchard_2017.pdf#page=27) · [BU 5: Basis-Ziele]($REPOS_DIR/Literatur-Web/02_Programming/Web/JavaScript/Refactoring-JavaScript_Burchard_2017.pdf#page=113) ·
[BU 6: Einfache Strukturen]($REPOS_DIR/Literatur-Web/02_Programming/Web/JavaScript/Refactoring-JavaScript_Burchard_2017.pdf#page=151) · [BU 7: Funktionen und Objekte]($REPOS_DIR/Literatur-Web/02_Programming/Web/JavaScript/Refactoring-JavaScript_Burchard_2017.pdf#page=189) ·
[LA: Refactoring]($REPOS_DIR/Literatur-Programming/02_Programming/Java/Pragmatic-Unit-Testing-in-Java-8-with-JUnit_Langr_2015.pdf#page=105)

**Fragen**

1. Was ist Refactoring, was nicht (Verhalten ändern, Feature, Performance)? (BU S. 27)
2. Wann ist eine Funktion „zu lang“, und wie sieht „Extract Function“ im Detail aus? (BU S. 189)
3. Was ist das Single-Responsibility-Prinzip, und wo siehst du eine Verletzung in der Phase-0-Shell? (LA S. 117)
4. Was ist Command-Query-Separation? (LA S. 124)
5. Wann geht man beim Refactoring „zu weit“? (LA S. 113)

**Aufgabe:** Drei Funktionen des Plugins finden, die >60 Zeilen oder tiefer als 3 Ebenen verschachtelt sind.
Je einen Refactoring-Plan (Schritte, Test dazwischen) aufschreiben, dann durchführen. Sobald Ousterhout und Fowler
vorliegen: dieselben Funktionen erneut mit dem Katalog von Fowler und den Begriffen „tiefe Module“ und
„Komplexität“ nach Ousterhout lesen.

### Woche 11–12: Entwurfsmuster

Lesen in [GoF]: [1 Einführung]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=21) · [Strategy]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=335) · [Observer]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=313) ·
[Command]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=253) · [Decorator]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=195) · [Adapter]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=159) ·
[Factory Method]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=127) · [Template Method]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=345) · [Facade]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Design-Patterns_Gamma-etal_1994.pdf#page=205)

**Fragen**

1. „Programmiere auf eine Schnittstelle, nicht auf eine Implementierung“ und „Komposition vor Vererbung“: Erkläre
   beide mit je einem Beispiel. (GoF Kap. 1)
2. Strategy gegen State, Decorator gegen Proxy, Adapter gegen Facade: Wo liegt der Unterschied? (GoF je Muster,
   Abschnitt „Related Patterns“)
3. Observer: Wie vermeidest du Speicherlecks und Rekursion beim Benachrichtigen? (GoF S. 313)
4. Welche Muster sind in Lua (Funktionen sind Werte) überflüssig, weil eine Tabelle genügt? (eigene Antwort)
5. Wo steckt Command im Undo-System eines Editors? (GoF S. 253)

**Aufgabe:** Drei Stellen im eigenen Code finden, an denen ein Muster hilft (oder schon unbewusst steckt),
benennen, und eine umgekehrt: eine Stelle mit unnötigem Muster vereinfachen.

### Woche 13: Architektur und Dokumentation

Lesen: [BR: Was ist Software-Architektur?]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/Software-Architecture-for-Developers_Brown_2022.pdf#page=13) · [BR: Architekturtreiber]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/Software-Architecture-for-Developers_Brown_2022.pdf#page=25) ·
[BR: Technische Risiken]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/Software-Architecture-for-Developers_Brown_2022.pdf#page=78) · [C4: Das C4-Modell]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/The-C4-Model-for-Visualising-Software-Architecture_Brown_2023.pdf#page=40) · [C4: Kontext]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/The-C4-Model-for-Visualising-Software-Architecture_Brown_2023.pdf#page=44) ·
[C4: Container]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/The-C4-Model-for-Visualising-Software-Architecture_Brown_2023.pdf#page=49) · [C4: Komponenten]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/The-C4-Model-for-Visualising-Software-Architecture_Brown_2023.pdf#page=55) · [C4: Diagramme müssen der Realität entsprechen]($REPOS_DIR/Literatur/01_Fundamentals/Software_Architecture/The-C4-Model-for-Visualising-Software-Architecture_Brown_2023.pdf#page=83)

**Fragen**

1. Was ist Architektur, was Design? Was sind Architekturtreiber (Qualitätsattribute, Randbedingungen,
   Anforderungen)? (BR S. 13, 25)
2. Wie gehst du mit technischen Risiken um (Risikostorming)? (BR S. 78)
3. Welche vier Ebenen hat C4 (Kontext, Container, Komponente, Code), und für wen ist jede Ebene? (C4 S. 40)
4. Wie schreibt man eine ADR (Kontext, Entscheidung, Konsequenzen, Status)? Warum hält man auch verworfene
   Alternativen fest?

**Aufgabe:** C4-Diagramme (Kontext, Container, Komponenten) des Plugins oder, besser, der Apps aus
[Rust-Apps-Lernplan](../Rust-Apps-Lernplan.md); mindestens drei ADRs zu bereits getroffenen Entscheidungen.

### Woche 14–16: Projekt – komplette Refaktorierung (Nachweis)

Ziel: ein eigenes Plugin vollständig überarbeiten. Ablauf:

1. **Ausgangsmessung:** Zeilen, Funktionen >60 Zeilen, zyklomatische Komplexität (`luacheck`/Skript), Testzahl,
   Abdeckung, Laufzeit der Suite, öffentliche API.
2. **Charakterisierungstests** für alles, was nicht abgedeckt ist (Woche 7–8).
3. **Schritte** in kleinen Commits: Namen, Funktionen teilen, Module schneiden, Nähte für Abhängigkeiten,
   Muster wo es hilft (Woche 11–12).
4. **ADRs** für jede Architekturentscheidung (Woche 13), `docs/adr/NNNN-titel.md`.
5. **Endmessung** wie in 1, Tabelle vorher/nachher in der Notiz.
6. **Review** durch Dritte: Pull Request öffentlich, Rückmeldung dokumentieren (Nachweis für Stufe 4).

Hilfreich: [PE]($REPOS_DIR/Literatur-PythonAI/02_Programming/Python/Test-Driven-Development-with-Python_Percival_2017_2ed.pdf#page=39) (Teil I, ein vollständiges TDD-Projekt von der ersten Zeile an) als Vorbild für
den Rhythmus von Test, Code, Commit.

## Nachweis und Abschluss

- [ ] Drei Katas mit TDD-Commit-Verlauf
- [ ] Refaktorierungsprojekt mit Messung vorher/nachher
- [ ] Mindestens drei ADRs, C4-Diagramme
- [ ] Alle Fragen beantwortet
- [ ] Matrix aktualisiert: Architektur, Testing 3→4
- [ ] Ousterhout, Fowler, Khorikov, Starke besorgt (Beschaffungsliste) und die Wochen 9–10 und 13 mit ihnen ergänzt

## Fortschritt

| Block | Gelesen | Fragen | Aufgabe | Notiz (Link) |
|---|---|---|---|---|
| Woche 1–2 | | | | |
| Woche 3–4 | | | | |
| Woche 5–6 | | | | |
| Woche 7–8 | | | | |
| Woche 9–10 | | | | |
| Woche 11–12 | | | | |
| Woche 13 | | | | |
| Woche 14–16 | | | | |
