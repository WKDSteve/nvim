# Phase 1: Rechner von unten (C, Assembly, Speicher)

Teil des [Lernplans](../Lernplan.md), Hauptspur, Monate 2–6 (ca. 16 Wochen). Hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) Rechnerarchitektur, C und Betriebssysteme P. Voraussetzung:
[Phase 0](Phase-0-Betriebssysteme.md) (die Shell in C).

**Nachweis:** vier selbst geschriebene Lösungen im Stil der CS:APP-Labs (Bit-Rätsel, Bomb, Buffer-Overflow, eigener
`malloc`) plus alle Fragen unten ohne Nachschlagen beantwortet.

**Maschine:** Bomb Lab und Attack Lab laufen auf einer Linux-x86-64-Umgebung (VM oder WSL), nur auf dem privaten
Rechner; auf der Workstation ist das Bauen und Starten unsignierter Programme tabu.

Links mit `#page=N` zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.
Die Seite hinter jeder Frage nennt die Stelle, an der die Antwort beginnt.

## Quellen

CS:APP (Bryant/O'Hallaron) steht in der Beschaffungsliste und fehlt im Bestand. Die Labs dazu sind frei von der
CMU-Kursseite erhältlich; als Lesestoff ersetzen die folgenden Bücher aus dem Bestand es:

| Kürzel | Buch | Datei |
|---|---|---|
| **[C]** | Gustedt, *Modern C* (Level 1 und 2) | [PDF]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf) |
| **[PH]** | Patterson/Hennessy, *Computer Organization and Design, RISC-V Edition* | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf) |
| **[SF]** | Seyfarth, *64 Bit Intel Assembly Language Programming for Linux* | [PDF]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf) |
| **[HD]** | Warren, *Hacker's Delight* (2nd) | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Hackers-Delight_Warren_2012_2ed.pdf) |
| **[K]** | Kerrisk, *The Linux Programming Interface* | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf) |
| **[KR]** | Kernighan/Ritchie, *The C Programming Language* (2nd), Nachschlagen | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/C/The-C-Programming-Language_Kernighan-Ritchie_1988_2ed.pdf) |
| **[EC]** | van der Linden, *Expert C Programming* („Deep C Secrets“), Nachschlagen | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/C/Expert-C-Programming_VanDerLinden_1994.pdf) |

## Wochenplan

### Woche 1–2: C-Grundlagen (Level 1)

Lesen in [C]: [3 Kontrollfluss]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=31) · [4 Berechnungen]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=39) · [5 Werte und Daten]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=48) ·
[6 Abgeleitete Typen]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=75) · [7 Funktionen]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=90) · [8 C-Bibliothek]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=100)

**Fragen**

1. Was ist die „abstrakte Zustandsmaschine“, und warum ist ein Programm mit undefiniertem Verhalten nicht
   „irgendwie falsch, aber trotzdem lauffähig“? (S. 48)
2. Wann konvertiert C implizit, und was passiert bei `unsigned` gegen `signed` in einem Vergleich? (S. 58)
3. Wie ist eine Zahl binär dargestellt (Zweierkomplement, `unsigned`-Überlauf gegen `signed`-Überlauf)? (S. 66)
4. Was ist ein Array-zu-Zeiger-Zerfall (Decay) und warum hat `sizeof` in einer Funktion den falschen Wert für
   einen Array-Parameter? (S. 75)
5. Was verlangt `main`, und was passiert mit dem Rückgabewert? (S. 92)
6. Wann endet die Rekursion nicht, und wie viele Stackrahmen verträgt ein Programm? (S. 94)

**Aufgabe (C):** Die Übungen („Exercises and challenges“) der Kapitel 3–8 in [C]. Dazu `wc`, `head`, `tac` und
`cat -n` selbst nachbauen (nur `stdio.h`).

### Woche 3–4: Zeiger, Speichermodell, Stil (Level 2)

Lesen in [C]: [9 Stil]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=128) · [10 Organisation]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=133) · [11 Zeiger]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=143) ·
[12 Speichermodell]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=160) · [13 Speicher/Lebensdauer]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=170) · [14 IO]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=191)

**Fragen**

1. Welche Operationen auf Zeigern sind erlaubt, welche undefiniert (Arithmetik außerhalb des Objekts,
   Vergleich fremder Zeiger)? (S. 143)
2. Wie liest man `int (*fp)(const char *, ...)`? Wozu braucht man Funktionszeiger (`qsort`, Callback-Tabellen)?
   (S. 155)
3. Was sind Alignment und „effective type“, und was kann bei einem Zugriff über den falschen Typ passieren?
   (S. 166)
4. Vier Speicherdauern (static, thread, automatic, allocated): Wo liegt was, und wann ist eine Variable
   „lebendig“? (S. 178)
5. Welche Fehler gibt es bei `malloc` (Rückgabe prüfen, Doppelfreigabe, Use-after-free), und wie findet man sie
   (ASan, Valgrind)? (S. 170)
6. Wie geht man bei Fehlern in I/O-Code mit Aufräumen um (`goto cleanup`)? (S. 206)

**Aufgabe (C):** Dynamische Liste, Hashtabelle und Stack/Queue mit eigener Allokation; alle Tests unter
`-fsanitize=address,undefined` ohne Warnung. Lies danach das Kap. „Pointers“ in [EC] als Gegenprobe.

### Woche 5–6: Daten als Bits (Data Lab)

Lesen: [HD 2: Basics]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Hackers-Delight_Warren_2012_2ed.pdf#page=24) · [HD 5: Bits zählen]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Hackers-Delight_Warren_2012_2ed.pdf#page=81) · [HD 7: Bits umsortieren]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Hackers-Delight_Warren_2012_2ed.pdf#page=124) ·
[SF 2: Zahlen]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=27) · [PH 2.4: vorzeichenlose und -behaftete Zahlen]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=184) ·
[PH 3.5: Gleitkomma]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=398)

**Fragen**

1. Warum ist `x & (x - 1)` das Löschen des niedrigsten Bits, und was folgt daraus für `popcount`? (HD S. 81)
2. Wie berechnet man ohne Verzweigung `abs`, `min`, `max`, `sign`? (HD S. 24)
3. Zweierkomplement: Warum ist `-x == ~x + 1`, und warum hat der Bereich einen Wert mehr auf der negativen Seite?
   (PH S. 184)
4. Wie ist ein `float` aufgebaut (Vorzeichen, Exponent, Mantisse, Bias)? Warum ist `0.1 + 0.2 != 0.3`?
   (PH S. 398)
5. Welche Gleitkommawerte sind denormalisiert, und warum gibt es sie? (PH S. 398)

**Aufgabe (C):** Data-Lab-Stil: Funktionen `bitAnd`, `getByte`, `logicalShift`, `bitCount`, `isPower2`,
`negate`, `isLessOrEqual`, `float_neg`, `float_i2f` nur mit `~ & ^ | + << >>` und einer Operatorenobergrenze.
Gegen die Referenzimplementierung mit allen 32-Bit-Eingaben testen (oder Zufallstest, Zufall + Randfälle).

### Woche 7–10: Assembly lesen (Bomb Lab)

Lesen: [SF 5: Register]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=59) · [SF 6: Mathe]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=67) · [SF 8: Verzweigung und Schleifen]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=87) ·
[SF 9: Funktionen und Stack]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=105) · [SF 10: Arrays]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=115) · [SF 13: Structs]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=153) ·
[SF A: gdb]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=233) · [PH 2.7: Entscheidungen]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=210) · [PH 2.8: Prozeduren]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=218) ·
[PH 2.14: Arrays gegen Zeiger]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=279)

**Fragen**

1. Welche Register übergeben die ersten sechs Argumente im System-V-ABI, wo steht der Rückgabewert, welche
   Register muss der Aufgerufene sichern? (SF S. 107)
2. Zeichne einen Stackrahmen mit Rücksprungadresse, gesichertem `rbp`, lokalen Variablen. Wie wächst der Stack?
   (SF S. 108)
3. Wie übersetzt ein Compiler `if/else`, `switch` (Sprungtabelle) und `for`? (SF S. 89–98, PH S. 210)
4. Was macht `lea`, und warum nutzt der Compiler es für Arithmetik? (SF S. 62)
5. Was ist der Unterschied zwischen dem Zugriff auf `a[i]` bei `int a[]` und `int *p` (PH 2.14)? (PH S. 279)
6. Welche gdb-Befehle brauchst du für Bomb Lab (`break`, `stepi`, `x/s`, `info registers`, `disas`)? (SF S. 233)

**Aufgabe:** Bomb Lab (CMU, selbst herunterladen): alle Phasen entschärfen, danach pro Phase einen Absatz, wie
der Code aussah (Schleife, Switch, Rekursion, verkettete Liste). Übungshälfte vorher: drei eigene C-Funktionen mit
`gcc -O0 -S` und `-O2 -S` übersetzen und die Unterschiede in Prosa erklären.

### Woche 11–12: Stack-Angriffe (Attack Lab)

Lesen: [SF 9.5: Stackrahmen]($REPOS_DIR/Literatur/02_Programming/Assembly/x86_64/Introduction-to-64-Bit-Intel-Assembly-Language-Programming-for-Linux_Seyfarth_2011.pdf#page=108) · [PH 2.8]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=218) · [S 15.2: Buffer Overflow]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=663) (Stallings, Quelle aus [Phase 0](Phase-0-Betriebssysteme.md)) ·
[K 6.3: Speicherlayout]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=159) · [K 6.5: Stack und Stackrahmen]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=165)

**Fragen**

1. Warum überschreibt `gets` eine Rücksprungadresse, und was ändert ein Stack-Canary daran?
2. Was ist Return-Oriented Programming, und wogegen schützen NX/DEP nicht?
3. Wie arbeitet ASLR, und warum reicht ein einzelner Informationsleak, um es zu umgehen?
4. Welche C-Funktionen sind unsicher (`strcpy`, `sprintf`, `gets`) und was ist der sichere Ersatz?

**Aufgabe:** Attack Lab (CMU, Phasen 1–5: Code-Injection, ROP) in der VM. Nur auf dem privaten Rechner.

### Woche 13–14: Speicherhierarchie

Lesen: [PH 5.1 Einführung]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=737) · [PH 5.3 Cache-Grundlagen]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=754) ·
[PH 5.4 Cache-Leistung]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=776) · [PH 5.7 Virtueller Speicher]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=818) · [PH 5.15 Cache Blocking]($REPOS_DIR/Literatur/01_Fundamentals/Computer_Architecture/Computer-Organization-and-Design-RISC-V-Edition_Patterson-Hennessy_nd.pdf#page=922)

**Fragen**

1. Räumliche und zeitliche Lokalität: Gib je ein Beispiel für guten und schlechten Zugriff (Matrix zeilen- gegen
   spaltenweise). (PH S. 737)
2. Direct-Mapped, Set-Associative, Fully Associative: Rechne an einer 32-Bit-Adresse Tag/Index/Offset aus. (PH S. 754)
3. AMAT-Formel und ein Zahlenbeispiel: Wie viel bringt ein L2 bei 5 % Fehlerrate? (PH S. 776)
4. Wie hängt der TLB mit Seitentabellen zusammen (vgl. Phase 0, Woche 4)? (PH S. 818)
5. Wie sieht Cache Blocking für die Matrixmultiplikation aus, und wie viel schneller wird es? (PH S. 922)

**Aufgabe (C):** Matrixmultiplikation in drei Schleifenreihenfolgen und geblockt; Zeit messen (`clock_gettime`) für
N = 256…2048, Diagramm der Ergebnisse, Erklärung in der Notiz. Cache-Simulator (Parameter s, E, b; LRU)
nachbauen und gegen `valgrind --tool=cachegrind` prüfen.

### Woche 15–16: Eigener Allokator (Malloc Lab)

Lesen: [C 13.1: malloc und Freunde]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=170) · [C 12.7: Alignment]($REPOS_DIR/Literatur/02_Programming/C/Modern-C_Gustedt_2019.pdf#page=167) ·
[S 7.2: Partitionierung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=345) · [K 7.1: Heap-Speicher, `brk`, `malloc`-Implementierung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=183)

**Fragen**

1. Was sind implizite, explizite und segregierte Freilisten, und was sind ihre Kosten für `malloc`/`free`?
2. Wie verhindert man externe Fragmentierung (Coalescing, Best-Fit gegen First-Fit)?
3. Warum braucht ein Block Header und Footer (Boundary Tags)?
4. Wie viel Speicher reserviert `brk`/`sbrk`, wie `mmap`, und warum nutzen große Allokationen `mmap`?

**Aufgabe (C):** `malloc`/`free`/`realloc` im Malloc-Lab-Stil auf einer simulierten Heap-Fläche, mindestens
explizite Freiliste mit Coalescing, 8-Byte-Ausrichtung (16 Byte auf x86-64), Heap-Konsistenzprüfer
(`mm_check`). Messen: Speichernutzung und Durchsatz gegen glibc auf denselben Traces.

## Nachweis und Abschluss

- [ ] Data Lab, Bomb Lab, Attack Lab, Malloc Lab gelöst (Repository mit Code und Notizen)
- [ ] Alle Fragen schriftlich beantwortet (WKDBooks, Feynman-Test)
- [ ] Matrix aktualisiert: Rechnerarchitektur, C, Betriebssysteme P

## Fortschritt

| Block | Gelesen | Fragen | Aufgabe | Notiz (Link) |
|---|---|---|---|---|
| Wochen 1–2 | | | | |
| Wochen 3–4 | | | | |
| Wochen 5–6 | | | | |
| Wochen 7–10 | | | | |
| Wochen 11–12 | | | | |
| Wochen 13–14 | | | | |
| Wochen 15–16 | | | | |
