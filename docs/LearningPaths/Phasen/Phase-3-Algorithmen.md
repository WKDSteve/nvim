# Phase 3: Algorithmen und Datenstrukturen (CLRS)

Teil des [Lernplans](../Lernplan.md), Hauptspur, Monate 10–14 (ca. 16 Wochen). Hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) Algorithmen 2→4. Voraussetzung: [Phase 1](Phase-1-Systeme-und-C.md) (C,
Zeiger, Speicher).

**Nachweis:** jede Datenstruktur aus Teil II–VI selbst in C oder Rust, mit Tests (inkl. Zufalls- und
Gegenprobe-Tests gegen die Standardbibliothek); ca. 100 gelöste Aufgaben (LeetCode, Codeforces); alle Fragen
unten ohne Nachschlagen beantwortet.

Links mit `#page=N` zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.
Die Seite hinter jeder Frage nennt, wo das Kapitel beginnt; Unterabschnitte stehen als „Abschnitt N.M“.

## Quellen

| Kürzel | Buch | Datei |
|---|---|---|
| **[CL]** | Cormen/Leiserson/Rivest/Stein, *Introduction to Algorithms* (4th, 2022) | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf) |
| **[W]** | Weiss, *Data Structures and Algorithm Analysis in C* (2nd), die kürzere Alternative | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf) |

[W] deckt Listen, Bäume, Hashing, Heaps, Sortieren, Disjoint Sets, Graphen und Entwurfstechniken ab
(Kapitel-Links in der Tabelle unten). Wer wenig Zeit hat, arbeitet [W] Kap. 1–10 statt CLRS durch und nimmt aus
CLRS nur die Kapitel 14–16 (DP, Greedy, amortisiert) dazu.

| [W]-Kapitel | Seite | Entspricht in [CL] |
|---|---|---|
| [Algorithm Analysis]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=24) | 24 | 2–4 |
| [Lists, Stacks, Queues]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=59) | 59 | 10 |
| [Trees]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=113) | 113 | 12–13 |
| [Hashing]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=187) | 187 | 11 |
| [Priority Queues (Heaps)]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=223) | 223 | 6 |
| [Sorting]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=276) | 276 | 7–9 |
| [Disjoint Set ADT]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=332) | 332 | 19 |
| [Graph Algorithms]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=358) | 358 | 20–22 |
| [Algorithm Design Techniques]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=447) | 447 | 14–15 |
| [Amortized Analysis]($REPOS_DIR/Literatur/01_Fundamentals/Data_Structures_Algorithms/Data-Structures-and-Algorithm-Analysis-in-C_Weiss_1997_2ed.pdf#page=542) | 542 | 16 |

## Wochenplan

Jede Woche: lesen, die Fragen schriftlich beantworten (WKDBooks, Feynman-Test), die Implementierung schreiben,
5–7 Aufgaben aus der Aufgabenliste lösen. In [CL] sind die Aufgaben am Ende jedes Abschnitts („Exercises“) und
jedes Kapitels („Problems“); Lösungen stehen nur für eine Auswahl im Buch; sonst selbst prüfen (Beweis oder Test).

### Woche 1: Grundlagen (Kap. 1–3)

Lesen in [CL]: [1 Role of Algorithms]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=28) · [2 Getting Started]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=44) ·
[3 Characterizing Running Times]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=85)

**Fragen**

1. Was ist eine Schleifeninvariante, und welche drei Eigenschaften musst du zeigen? Beweise damit die Korrektheit
   von Insertion Sort. (Abschnitt 2.1)
2. Wie lautet die Rekurrenz von Merge Sort, und warum ergibt sie Θ(n lg n)? (Abschnitt 2.3)
3. Definiere O, Ω, Θ, o und ω formal. Gilt `n² = O(n³)`? `2^(n+1) = O(2^n)`? `2^(2n) = O(2^n)`? (Kap. 3)
4. Warum ist „die Laufzeit ist mindestens O(n²)“ eine sinnlose Aussage? (Kap. 3)

**Aufgabe:** Insertion Sort und Merge Sort in C, Zeitmessung für n = 10³…10⁶, Messung gegen Θ-Kurve zeichnen.

### Woche 2: Teile und herrsche, Wahrscheinlichkeit (Kap. 4–5)

Lesen: [4 Divide-and-Conquer]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=119) · [5 Probabilistic Analysis]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=184)

**Fragen**

1. Nenne die drei Fälle des Master-Theorems und löse `T(n)=2T(n/2)+n`, `T(n)=T(n/2)+1`, `T(n)=8T(n/2)+n²`
   und `T(n)=T(n/2)+n lg n` (letzter Fall: warum greift das Theorem nicht?). (Abschnitt 4.5)
2. Wie funktioniert die Substitutionsmethode, und warum muss man die Induktionsannahme manchmal verstärken?
   (Abschnitt 4.3)
3. Wie schlägt Strassen die Standardmultiplikation, und was ist die Rekurrenz? (Abschnitt 4.2)
4. Was sind Indikator-Zufallsvariablen? Berechne die erwartete Anzahl von Einstellungen beim Hiring-Problem.
   (Abschnitt 5.2)

**Aufgabe:** Maximales Teilarray (Divide-and-Conquer gegen Kadane), Matrixmultiplikation (Standard, Strassen) mit
Messung; Fisher-Yates-Shuffle mit Verteilungstest (Chi-Quadrat).

### Woche 3: Heapsort und Quicksort (Kap. 6–7)

Lesen: [6 Heapsort]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=229) · [7 Quicksort]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=255)

**Fragen**

1. Wie ist ein binärer Heap im Array eingebettet (Eltern-/Kindindex)? (Abschnitt 6.1)
2. Warum läuft `BUILD-MAX-HEAP` in O(n) und nicht in O(n lg n)? (Abschnitt 6.3)
3. Wann ist Quicksort quadratisch? Wie hilft eine zufällige Pivotwahl, und wie hoch ist die erwartete Laufzeit?
   (Abschnitt 7.2, 7.4)
4. Vergleiche Lomuto- und Hoare-Partitionierung. (Abschnitt 7.1, Problem 7-1)

**Aufgabe:** Heap (Min und Max), Priority Queue mit `decrease_key`, Heapsort, Quicksort mit Dreier-Pivot
(Median-of-3) und Insertion Sort für kleine Teile; Messen gegen `qsort`.

### Woche 4: Lineare Sortierung, Auswahl (Kap. 8–9)

Lesen: [8 Sorting in Linear Time]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=284) · [9 Medians and Order Statistics]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=312)

**Fragen**

1. Beweise die untere Schranke Ω(n lg n) für vergleichsbasiertes Sortieren (Entscheidungsbaum). (Abschnitt 8.1)
2. Warum muss Counting Sort stabil sein, damit Radix Sort funktioniert? (Abschnitt 8.2, 8.3)
3. Wie funktioniert Randomized-Select, und warum ist die erwartete Laufzeit O(n)? (Abschnitt 9.2)
4. Wie funktioniert Median-der-Mediane (5er-Gruppen), und warum garantiert er O(n) im schlechtesten Fall?
   (Abschnitt 9.3)

**Aufgabe:** Counting Sort, Radix Sort (LSD, Basis 256), Bucket Sort, Quickselect, Median der Mediane.

### Woche 5–6: Listen, Hashtabellen (Kap. 10–11)

Lesen: [10 Elementary Data Structures]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=344) · [11 Hash Tables]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=368)

**Fragen**

1. Wie baut man einen Stack und eine Queue im Array, und wann ist die Queue voll/leer? (Abschnitt 10.1)
2. Doppelt verkettete Liste mit Sentinel: Was spart der Sentinel? (Abschnitt 10.2)
3. Hashtabelle mit Verkettung: Erwartete Suchzeit in Abhängigkeit des Lastfaktors α? (Abschnitt 11.2)
4. Wie unterscheiden sich lineares Sondieren, quadratisches Sondieren und doppeltes Hashing, und wie geht das
   Löschen? (Abschnitt 11.4)
5. Was ist universelles Hashing, und welches Problem löst es (Gegner wählt Schlüssel)? (Abschnitt 11.3)

**Aufgabe (C oder Rust):** Dynamisches Array, einfach/doppelt verkettete Liste, Ringpuffer, Hashtabelle (Verkettung
und offene Adressierung), Vergleich mit `std::collections::HashMap` in Zeit und Speicher.

### Woche 7: Suchbäume (Kap. 12–13)

Lesen: [12 Binary Search Trees]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=418) · [13 Red-Black Trees]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=442)

**Fragen**

1. Wie sehen `SEARCH`, `INSERT`, `DELETE`, `SUCCESSOR` im BST aus, und was kostet jeder? (Abschnitt 12.1–12.3)
2. Wie hoch wird ein zufällig gebauter BST im Erwartungswert? (Abschnitt 12.4)
3. Nenne die fünf Rot-Schwarz-Eigenschaften und beweise, dass die Höhe höchstens 2 lg(n+1) ist. (Abschnitt 13.1)
4. Welche Fälle hat die Einfüge-Reparatur, und wie viele Rotationen braucht sie höchstens? (Abschnitt 13.3)

**Aufgabe:** BST und Rot-Schwarz-Baum mit Einfügen und Löschen. Test: 10⁶ Zufallsoperationen gegen eine
sortierte Referenz; Invariantenprüfer, der alle fünf Eigenschaften nach jeder Operation kontrolliert.

### Woche 8–9: Dynamische Programmierung (Kap. 14)

Lesen: [14 Dynamic Programming]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=481)

**Fragen**

1. Welche zwei Eigenschaften braucht ein Problem für DP (optimale Teilstruktur, überlappende Teilprobleme)? Warum
   hat Merge Sort keine überlappenden? (Abschnitt 14.3)
2. Rod Cutting: Top-down mit Memoization gegen Bottom-up – Rekurrenz, Laufzeit, Rekonstruktion der Lösung.
   (Abschnitt 14.1)
3. Matrix-Kettenmultiplikation: Aufbau der Tabelle `m[i,j]`, Laufzeit O(n³), Klammerung rekonstruieren.
   (Abschnitt 14.2)
4. Längste gemeinsame Teilfolge: Rekurrenz und Platz auf O(min(m,n)) reduzieren. (Abschnitt 14.4)
5. Optimaler Suchbaum: Wozu braucht man die Gewichtssumme `w[i,j]`? (Abschnitt 14.5)

**Aufgabe:** Rod Cutting, Matrixketten, LCS, Rucksack (0/1 und unbeschränkt), Editierdistanz, längste
aufsteigende Teilfolge in O(n log n). Jedes Mal erst die Rekurrenz auf Papier.

### Woche 10: Greedy und amortisierte Analyse (Kap. 15–16)

Lesen: [15 Greedy Algorithms]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=552) · [16 Amortized Analysis]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=593)

**Fragen**

1. Aktivitätsauswahl: Beweise die Greedy-Wahl-Eigenschaft (Austauschargument). (Abschnitt 15.1)
2. Huffman: Warum ist die Wahl der zwei seltensten Symbole optimal? (Abschnitt 15.3)
3. Wann versagt Greedy, obwohl optimale Teilstruktur vorliegt (0/1-Rucksack)? (Abschnitt 15.2)
4. Aggregat-, Buchungs- und Potenzialmethode: Wende alle drei auf den Binärzähler und das dynamische Array an.
   (Abschnitt 16.1–16.4)

**Aufgabe:** Huffman-Kodierung (Kompressor und Dekompressor für Dateien), Intervall-Scheduling, Münzwechsel
(Greedy gegen DP an einem Gegenbeispiel). Beweis der amortisierten Kosten von `push_back` mit Verdopplung.

### Woche 11: Erweiterte Datenstrukturen (Kap. 17–19)

Lesen: [17 Augmenting Data Structures]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=633) · [18 B-Trees]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=655) ·
[19 Disjoint Sets]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=683)

**Fragen**

1. Wie macht man aus einem Rot-Schwarz-Baum einen Order-Statistic-Tree (`OS-SELECT`, `OS-RANK`)? (Abschnitt 17.1)
2. Wie sieht die Methodik des Augmentierens aus (vier Schritte)? (Abschnitt 17.2)
3. B-Baum mit Minimalgrad t: Höhe, Einfügen mit Aufteilen (Split), warum nutzt man ihn auf Platte? (Kap. 18)
4. Union-Find: Was bringen Vereinigung nach Rang und Pfadkompression, und was ist α(n)? (Kap. 19)

**Aufgabe:** Order-Statistic-Tree (oder Intervallbaum), B-Baum mit `insert` und `search`, Union-Find mit beiden
Optimierungen; Test: gleiche Ergebnisse wie naive Version bei 10⁶ Operationen.

### Woche 12–14: Graphen (Kap. 20–22)

Lesen: [20 Elementary Graph Algorithms]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=718) · [21 Minimum Spanning Trees]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=762) ·
[22 Single-Source Shortest Paths]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=785)

**Fragen**

1. Adjazenzliste gegen Matrix: Speicher und Kosten für Kantenabfrage, wann welche? (Abschnitt 20.1)
2. BFS: Beweise, dass die Entfernungen kürzeste Wege liefern. DFS: Klassifiziere Kanten (Baum, Rück, Vorwärts,
   Quer) und gib die Klammerstruktur der Zeitstempel an. (Abschnitt 20.2–20.3)
3. Topologische Sortierung und starke Zusammenhangskomponenten (zwei DFS). (Abschnitt 20.4–20.5)
4. Schnitt-Eigenschaft (Cut Property) und ihr Beweis; Kruskal gegen Prim: Laufzeiten mit Union-Find
   beziehungsweise Heap. (Kap. 21)
5. Relaxation: Warum liefert Bellman-Ford korrekte Distanzen und erkennt negative Zyklen? Warum scheitert Dijkstra
   an negativen Kanten? (Abschnitt 22.1–22.3)
6. Kürzeste Wege im DAG in O(V+E): Wie? (Abschnitt 22.2)

**Aufgabe:** Graph-Bibliothek (Liste und Matrix), BFS/DFS, Topo-Sort, SCC (Kosaraju), Kruskal, Prim, Dijkstra mit
Heap, Bellman-Ford. Test: zufällige Graphen gegen eine Referenz (NetworkX oder eigene Brute-Force-Lösung).

### Woche 15–16: Auswahl und Wiederholung (Kap. 23–25, 34)

Lesen nach Interesse: [23 All-Pairs Shortest Paths]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=838) · [24 Maximum Flow]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=869) ·
[25 Matchings in Bipartite Graphs]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=911) · [34 NP-Completeness]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1343)

**Fragen**

1. Floyd-Warshall: Rekurrenz und Laufzeit, Wiederherstellung der Pfade? (Abschnitt 23.2)
2. Ford-Fulkerson: Restgraph, Erweiterungspfade; warum braucht Edmonds-Karp O(VE²)? (Kap. 24)
3. Reduziere bipartites Matching auf Maximalfluss. (Kap. 25)
4. Was sind P, NP, NP-vollständig? Wie zeigt man NP-Vollständigkeit durch Reduktion (Beispiel: 3-SAT → Clique)?
   (Kap. 34)

**Aufgabe:** Floyd-Warshall, Edmonds-Karp, ein Wettbewerbsproblem mit Fluss. Wiederholung: aus dem Kopf alle
Datenstrukturen aufzählen, Laufzeiten ihrer Operationen aufschreiben und mit dem Buch abgleichen.

## Aufgabenliste (ca. 100)

Die Wochen oben nennen die Implementierungen. Dazu pro Thema Aufgaben auf einer Wettbewerbsplattform (LeetCode,
Codeforces, AtCoder); Namen sind Beispiele, die Nummern findest du auf der Plattform:

| Thema | Beispielaufgaben (ca. Anzahl) |
|---|---|
| Arrays, Zwei Zeiger, Fenster | Two Sum, 3Sum, Container With Most Water, Longest Substring Without Repeating Characters, Trapping Rain Water (10) |
| Sortieren, Suchen | Merge Intervals, Kth Largest Element, Search in Rotated Sorted Array, Median of Two Sorted Arrays (8) |
| Hashtabellen, Heaps | Top K Frequent Elements, LRU Cache, Merge k Sorted Lists, Sliding Window Maximum (10) |
| Bäume | Validate BST, Lowest Common Ancestor, Serialize/Deserialize Tree, Binary Tree Maximum Path Sum (10) |
| Dynamische Programmierung | Coin Change, Longest Increasing Subsequence, Edit Distance, House Robber, Partition Equal Subset Sum, Unique Paths (20) |
| Greedy | Jump Game, Gas Station, Meeting Rooms II, Task Scheduler (8) |
| Graphen | Number of Islands, Course Schedule, Word Ladder, Network Delay Time, Cheapest Flights Within K Stops, Redundant Connection (20) |
| Rest (Backtracking, Bits, Mathematik) | N-Queens, Subsets, Permutations, Single Number (14) |

Führe pro Aufgabe eine Zeile in der Fortschrittstabelle: Datum, Link, Idee in einem Satz, Laufzeit.

## Nachweis und Abschluss

- [ ] Repository mit allen Datenstrukturen, jede mit Tests und Invariantenprüfer
- [ ] ~100 Aufgaben gelöst und notiert
- [ ] Alle Fragen beantwortet
- [ ] Matrix aktualisiert: Algorithmen 2→4

## Fortschritt

| Block | Gelesen | Fragen | Implementierung | Aufgaben (Anzahl) |
|---|---|---|---|---|
| Woche 1 | | | | |
| Woche 2 | | | | |
| Woche 3 | | | | |
| Woche 4 | | | | |
| Woche 5–6 | | | | |
| Woche 7 | | | | |
| Woche 8–9 | | | | |
| Woche 10 | | | | |
| Woche 11 | | | | |
| Woche 12–14 | | | | |
| Woche 15–16 | | | | |
