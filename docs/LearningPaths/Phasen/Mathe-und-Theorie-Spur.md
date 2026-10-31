# Mathe- und Theorie-Spur (M1–M4, T1, T2)

Teil des [Lernplans](../Lernplan.md), läuft parallel zur Hauptspur (ca. 3 Stunden pro Woche). Sie hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) die Theorie-Werte (T) in Algorithmen, Compiler, Datenbanken, Verteilte
Systeme und PL-Theorie. Ohne sie bleibt Stufe 4 in der Theorie unerreichbar.

**Nachweis je Block:** eine alte Uni-Klausur ohne Hilfsmittel bestanden (M1–M4, T1) oder ausgewählte Kapitel mit
allen Übungen gelöst (T2), dazu die Fragen und Aufgaben unten.

**Lage im Bestand:** Die Kernbücher dieser Spur (Beutelspacher, Velleman, MCS, Teschl, Strang, Henze, Blitzstein,
Schöning, Sipser, Hromkovič, Arora/Barak, *Concrete Mathematics*) **fehlen im Bestand**; sie stehen in der
[Beschaffungsliste]($REPOS_DIR/Literatur/Beschaffungsliste.md), Abschnitt 1–6. Diese Seite trägt die Spur bis dahin
mit Büchern, die schon da sind (Stavely, Bronson, *Mathematics for Machine Learning*, CLRS-Anhang, Knuth, Sedgewick/
Flajolet, DasGupta, MacKay, Wilf), und nennt zu den fehlenden Büchern Themen statt Seitenlinks. Die Aufgaben sind
so gestellt, dass du sie mit Papier, Python oder Rust prüfen kannst.

Links mit `#page=N` zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.

## Quellen

| Kürzel | Buch | Stand |
|---|---|---|
| **[STV]** | Stavely, *Programming and Mathematical Thinking* (diskrete Mathematik mit Python) | [PDF]($REPOS_DIR/Literatur-PythonAI/02_Programming/Python/Programming-and-Mathematical-Thinking-A-Gentle-Introduction-to-Discrete-Math-Featuring-Python_Stavely_2014.pdf) |
| **[CL]** | Cormen u. a., *Introduction to Algorithms* (4th), Anhang A–C und Kap. 34 | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf) |
| **[BR]** | Bronson u. a., *Linear Algebra: Algorithms, Applications, and Techniques* (3rd) | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf) |
| **[MML]** | Deisenroth u. a., *Mathematics for Machine Learning* (frei) | [PDF]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf) |
| **[KN]** | Knuth, *TAOCP* Band 1, Abschnitt 1.2 (Mathematische Grundlagen) | [PDF]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf) |
| **[SF]** | Sedgewick/Flajolet, *An Introduction to the Analysis of Algorithms* (2nd) | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf) |
| **[DG]** | DasGupta, *Probability for Statistics and Machine Learning* | [PDF]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Probability-for-Statistics-and-Machine-Learning_DasGupta_2011.pdf) |
| **[MK]** | MacKay, *Information Theory, Inference, and Learning Algorithms* (frei) | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Information-Theory-Inference-and-Learning-Algorithms_MacKay_2005.pdf) |
| **[WI]** | Wilf, *Algorithms and Complexity* (frei) | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Algorithms-and-Complexity_Wilf_1994.pdf) |
| **[AG]** | Joyner u. a., *Algorithmic Graph Theory and Sage* | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Algorithmic-Graph-Theory-and-Sage_Joyner-etal_2013.pdf) |
| **[CH]** | Chaitin, *Algorithmic Information Theory* | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Algorithmic-Information-Theory_Chaitin_2003.pdf) |
| Fehlt | Beutelspacher, Velleman, MCS, Teschl 1+2, Strang, Henze, Blitzstein/Hwang, Schöning, Sipser, Hromkovič, Arora/Barak, Graham/Knuth/Patashnik | Beschaffungsliste |

Kostenlos und gut dazu: MIT OCW 6.042J (*Mathematics for Computer Science*, Videos, Problem Sets, Klausuren),
MIT OCW 18.06 (Strang, Videos und Klausuren), Harvard Stat 110 (Blitzstein, Videos und Übungen), MIT OCW 6.045J
(Automaten und Berechenbarkeit).

## Arbeitsweise

- **Beweise schreibst du aus, in ganzen Sätzen.** Ein Beweis, den du nicht einer Mitlernenden vorlesen könntest, ist
  keiner.
- **Jede Woche eine Übungsrunde mit Zeitlimit** (wie in einer Klausur), danach vergleichen mit der Musterlösung.
- **Jede Rechenaufgabe einmal im Programm prüfen** (Python oder Rust). Das ist keine Vorgabe, sondern die
  Gegenprobe, die in der Praxis später zählt.
- Die Notizen wandern wie in der Hauptspur nach WKDBooks (Feynman-Test).

---

## M1: Beweisen und diskrete Mathematik (Monate 2–6, ca. 16 Wochen)

Fehlen: Beutelspacher *Das ist o.B.d.A. trivial!*, Velleman *How to Prove It*, MCS (Teil Beweise, Induktion,
Zahlentheorie, Graphen, Zählen), Teschl Band 1 (diskreter Teil).

Aus dem Bestand: [STV 5: Tupel]($REPOS_DIR/Literatur-PythonAI/02_Programming/Python/Programming-and-Mathematical-Thinking-A-Gentle-Introduction-to-Discrete-Math-Featuring-Python_Stavely_2014.pdf#page=65) · [STV 8: Mengen]($REPOS_DIR/Literatur-PythonAI/02_Programming/Python/Programming-and-Mathematical-Thinking-A-Gentle-Introduction-to-Discrete-Math-Featuring-Python_Stavely_2014.pdf#page=121) · [STV 9: Abbildungen]($REPOS_DIR/Literatur-PythonAI/02_Programming/Python/Programming-and-Mathematical-Thinking-A-Gentle-Introduction-to-Discrete-Math-Featuring-Python_Stavely_2014.pdf#page=141) ·
[STV 10: Relationen]($REPOS_DIR/Literatur-PythonAI/02_Programming/Python/Programming-and-Mathematical-Thinking-A-Gentle-Introduction-to-Discrete-Math-Featuring-Python_Stavely_2014.pdf#page=167) · [CL B.1: Mengen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1484) · [CL B.2: Relationen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1490) ·
[CL B.3: Funktionen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1493) · [CL B.4: Graphen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1497) · [CL B.5: Bäume]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1503) ·
[CL A.1: Summenformeln]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1469) · [CL C.1: Zählen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1514) · [KN 1.2.1: Vollständige Induktion]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=27) ·
[KN 1.2.6: Binomialkoeffizienten]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=68)

### Woche 1–4: Aussagen, Beweistechniken

**Fragen**

1. Wann ist `A ⇒ B` wahr? Warum ist `A ⇒ B` gleichwertig zu `¬B ⇒ ¬A`, aber nicht zu `B ⇒ A`? Prüfe mit
   Wahrheitstabellen.
2. Nenne vier Beweistechniken (direkt, Kontraposition, Widerspruch, Induktion) und für jede ein Beispielsatz.
3. Was heißt `∀x ∃y P(x,y)` gegenüber `∃y ∀x P(x,y)`? Gib ein Beispiel, in dem sie sich unterscheiden.
4. Wie negierst du `∀ε>0 ∃δ>0 …`, ohne das Wort „nicht“ zu verstecken?
5. Was ist der Unterschied zwischen vollständiger und starker Induktion, und was ist das Wohlordnungsprinzip? (KN S. 27)

**Aufgaben (schriftlicher Beweis)**

1. `√2` ist irrational (Widerspruch).
2. Es gibt unendlich viele Primzahlen (Euklid).
3. `1 + 3 + 5 + … + (2n−1) = n²` für alle `n ≥ 1` (Induktion).
4. `∑ k³ von k=1 bis n = (n(n+1)/2)²` (Induktion).
5. Jede natürliche Zahl `≥ 2` ist ein Produkt von Primzahlen (starke Induktion).
6. Fehlersuche: Wo steckt der Fehler im „Beweis“, dass alle Pferde dieselbe Farbe haben?
7. Taubenschlagprinzip: In jeder Menge von 5 Punkten im Einheitsquadrat gibt es zwei mit Abstand `≤ √2/2`.

### Woche 5–8: Mengen, Relationen, Abbildungen

**Fragen**

1. Wie ist `A × B`, `P(A)` definiert, wie viele Elemente haben sie? (STV S. 121, CL S. 1484)
2. Wann ist eine Abbildung injektiv, surjektiv, bijektiv? Was ist die Umkehrabbildung? (STV S. 141, CL S. 1493)
3. Wann ist eine Relation reflexiv, symmetrisch, antisymmetrisch, transitiv? Was ist eine Äquivalenzrelation,
   was eine Halbordnung? (STV S. 167, CL S. 1490)
4. Was ist die Äquivalenzklasse, und wie erzeugt sie eine Partition der Menge?
5. Wie beweist man `|A| = |B|` ohne zu zählen (Bijektion)?

**Aufgaben**

1. Jede Äquivalenzrelation erzeugt eine Partition und umgekehrt (Beweis).
2. In Python: transitiver Abschluss einer Relation (Warshall), Test gegen eine Brute-Force-Lösung auf zufälligen
   Relationen mit 6 Elementen. (STV S. 167)
3. Zeige: `P(A)` und `{0,1}^A` sind gleichmächtig (Bijektion angeben).
4. Zeige, dass `ℕ` und `ℤ` gleichmächtig sind, `ℕ` und `ℝ` nicht (Cantors Diagonalargument).

### Woche 9–12: Zählen, Zahlentheorie

**Fragen**

1. Summenregel, Produktregel, Inklusion-Exklusion; wie zählt man Permutationen und Kombinationen? (CL S. 1514)
2. Wie lautet der binomische Lehrsatz, und warum ist `C(n,k)` die Zahl der `k`-Teilmengen? (KN S. 68)
3. Euklidischer Algorithmus und erweiterter Euklid: Wie berechnet man `ggT(a,b)` und `x,y` mit `ax+by = ggT`?
4. Rechnen modulo `n`: Wann existiert das Inverse von `a`? Kleiner Satz von Fermat und Satz von Euler.
5. Wie arbeitet RSA im Prinzip (Schlüsselerzeugung, Ver- und Entschlüsselung), und warum stützt sich die
   Sicherheit auf die Faktorisierung?

**Aufgaben**

1. Python: erweiterter Euklid, modulares Inverses, schnelle Exponentiation `a^b mod n`.
2. RSA mit kleinen Primzahlen (`p=61`, `q=53`, `e=17`) von Hand: `d` bestimmen, die Nachricht `42` verschlüsseln und
   entschlüsseln, mit dem Programm prüfen.
3. Beweise `C(n,k) = C(n−1,k−1) + C(n−1,k)` kombinatorisch (Doppelzählen) und durch Rechnung.
4. Wie viele Wörter der Länge 6 über `{a,b,c}` enthalten mindestens ein `a`? (Zähle zwei Wege.)
5. Handschlag-Lemma: In jedem Graphen ist die Summe der Grade `2·|E|`; folgere, dass die Zahl der Knoten mit
   ungeradem Grad gerade ist. (CL S. 1497)

### Woche 13–16: Graphen, Rekursion, Abschluss

**Fragen**

1. Wann ist ein Graph ein Baum (fünf gleichwertige Aussagen)? (CL S. 1503)
2. Eulersche und Hamiltonsche Wege: Was gilt, wie schwer ist das Entscheiden?
3. Was ist eine Rekurrenzrelation, und wie löst man `a_n = a_{n−1} + a_{n−2}` (charakteristische Gleichung)?
   (Vorgriff auf [SF 2: Rekurrenzen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=60).)

**Aufgaben**

1. Fibonacci in geschlossener Form herleiten und für `n ≤ 30` gegen die Rekursion prüfen.
2. Zeige: Ein Baum mit `n` Knoten hat `n−1` Kanten.
3. Alte Klausur MIT 6.042J (frei, OCW) unter Zeitlimit; Ziel: ≥ 60 %.

---

## M2: Lineare Algebra (Monate 6–10, ca. 16 Wochen)

Fehlen: Teschl Band 1 (Lineare Algebra), Strang *Introduction to Linear Algebra*. Videos MIT 18.06 sind frei.

Aus dem Bestand: [BR 1: Matrizen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=8) · [BR 1: Lineare Gleichungssysteme]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=37) ·
[BR 1: Determinanten]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=54) · [BR 1: LU-Zerlegung]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=88) · [BR 2: Vektorräume]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=99) ·
[BR 3: Lineare Abbildungen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=180) · [BR 4: Eigenwerte]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=241) · [BR 6: Orthogonalität]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=326) ·
[MML 2: Lineare Algebra]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=23) · [MML 3: Analytische Geometrie]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=76) ·
[MML 4: Matrixzerlegungen]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=104)

### Woche 1–4: Gleichungssysteme und Matrizen

**Fragen**

1. Wie löst das Gauß-Verfahren ein lineares Gleichungssystem, wann hat es keine, genau eine, unendlich viele Lösungen?
   (BR S. 37, MML S. 33)
2. Wie multipliziert man Matrizen (Zeile mal Spalte, Spalte-mal-Zeile-Sicht), warum gilt `AB ≠ BA`? (BR S. 17)
3. Wann ist `A` invertierbar, und wie berechnest du `A⁻¹` mit dem Gauß-Jordan-Verfahren? (BR S. 74)
4. Was leistet die LU-Zerlegung, und was kostet sie im Vergleich zu `A⁻¹`? (BR S. 88)
5. Was ist die Determinante, welche geometrische Bedeutung hat sie, und wie hängt sie mit der Invertierbarkeit
   zusammen? (BR S. 54, MML S. 105)

**Aufgaben**

1. Gauß-Elimination für ein 3×3-System von Hand, danach in Code: Gauß mit Pivotsuche, LU-Zerlegung, Test gegen
   `numpy.linalg.solve` auf 1000 Zufallssystemen (Abweichung messen).
2. Zeige `det(AB) = det(A)·det(B)` für 2×2 durch Rechnung.
3. Warum ist die Determinante der Dreiecksmatrix das Produkt der Diagonale?

### Woche 5–8: Vektorräume

**Fragen**

1. Axiome eines Vektorraums; Unterraum-Kriterium. (BR S. 122, MML S. 41)
2. Lineare Unabhängigkeit, Basis, Dimension, Rang; Dimensionssatz `dim ker + dim im = dim V`. (BR S. 133–167,
   MML S. 46–54)
3. Zeilenraum, Spaltenraum, Kern: Wie bestimmst du Basen? (BR S. 157)
4. Lineare Abbildungen: Matrixdarstellung, Basiswechsel. (BR S. 196, 209, MML S. 54)

**Aufgaben**

1. Zeige: Die Lösungsmenge von `Ax = 0` ist ein Unterraum von `ℝⁿ`; bestimme die Dimension für eine 3×5-Matrix mit
   Rang 2.
2. Beweise den Dimensionssatz für Matrizen (Rangsatz).
3. Bestimme die Basiswechsel-Matrix zwischen zwei Basen von `ℝ³` und prüfe sie im Programm.

### Woche 9–12: Eigenwerte und Diagonalisierung

**Fragen**

1. Definiere Eigenwert und Eigenvektor, charakteristisches Polynom. (BR S. 241, MML S. 111)
2. Wann ist eine Matrix diagonalisierbar, und wozu nützt `A = PDP⁻¹` (Potenzen, Differenzgleichungen)? (BR S. 260,
   MML S. 121)
3. Was besagt der Spektralsatz für symmetrische Matrizen? (MML S. 121)
4. Wie funktioniert die Potenzmethode zur Berechnung des größten Eigenwerts? (BR S. 280)

**Aufgaben**

1. Fibonacci als Matrixpotenz `[[1,1],[1,0]]ⁿ`: Eigenwerte bestimmen, geschlossene Formel, Vergleich mit M1.
2. Potenzmethode in Code; PageRank auf einem 5-Knoten-Graphen (BR S. 315–324 und Markov-Ketten ab S. 415).
3. Zeige: Die Eigenwerte einer Dreiecksmatrix stehen auf der Diagonale.

### Woche 13–16: Orthogonalität, Zerlegungen

**Fragen**

1. Skalarprodukt, Norm, Winkel; Orthonormalbasis; Gram-Schmidt. (MML S. 77–85, BR S. 339)
2. Orthogonale Projektion; Kleinste Quadrate: Normalengleichung `AᵀAx = Aᵀb`. (BR S. 363, MML S. 87)
3. QR-Zerlegung und ihr Nutzen; Singulärwertzerlegung (SVD) und Niedrigrang-Approximation. (BR S. 354, MML S. 125–135)

**Aufgaben**

1. Gram-Schmidt und QR in Code; kleinste Quadrate für eine Gerade durch 20 verrauschte Punkte; Vergleich mit
   `numpy.linalg.lstsq`.
2. SVD eines Graustufenbildes: Rang-`k`-Näherung für `k = 5, 20, 50`, Fehler gegen `k` zeichnen.
3. Alte Klausur MIT 18.06 unter Zeitlimit.

---

## M3: Analysis (Monate 10–14, ca. 16 Wochen)

Fehlt: Teschl Band 2 (Analysis und Statistik).

Aus dem Bestand: [CL A: Summen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1469) · [CL A.2: Summen abschätzen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1475) ·
[SF 4: Asymptotische Näherungen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=170) · [SF 4.5: Euler-Maclaurin]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=198) ·
[MML 5: Vektoranalysis]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=145) · [MML 5.6: Backpropagation und automatisches Differenzieren]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=165) ·
[MML 5.8: Taylorreihen]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=171) · [KN 1.2.3: Summen und Produkte]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=43) · [KN 1.2.11: Asymptotische Darstellung]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=123)

### Woche 1–4: Folgen, Grenzwerte, Stetigkeit

**Fragen**

1. Formale Definition `lim aₙ = L` mit `ε` und `N`. Wie beweist man damit, dass `1/n → 0`?
2. Wann konvergiert eine Folge (Beschränktheit, Monotonie, Cauchy), und was ist Vollständigkeit von `ℝ`?
3. Stetigkeit (`ε`-`δ`), Zwischenwertsatz, Satz vom Maximum; Gegenbeispiele für Funktionen mit Sprungstellen.
4. Landau-Symbole `O`, `o`, `Θ` für Funktionen: Wie beweist man `n log n = O(n²)`? (SF S. 172, KN S. 123)

**Aufgaben**

1. Zeige mit `ε`-`N`: `(3n+1)/(n+2) → 3`.
2. Zeige `lim (1 + 1/n)ⁿ` existiert (Monotonie und Beschränktheit).
3. Beweise: Jede stetige Funktion auf `[a,b]` ist beschränkt.

### Woche 5–8: Differenzieren

**Fragen**

1. Ableitung als Grenzwert; Produkt-, Quotienten-, Kettenregel (Herleitung der Kettenregel). (MML S. 147)
2. Mittelwertsatz und Folgerungen (Monotonie, Extrema). Satz von Taylor mit Restglied. (MML S. 171)
3. Mehrere Variablen: Partielle Ableitungen, Gradient, Jacobi-Matrix, Kettenregel für Vektorfunktionen.
   (MML S. 152–161)
4. Wie arbeitet automatisches Differenzieren (Vorwärts- und Rückwärtsmodus) und wie hängt es mit Backpropagation
   zusammen? (MML S. 165)

**Aufgaben**

1. Taylorreihe von `eˣ`, `sin x`, `1/(1−x)`; Restgliedabschätzung für `e` mit Fehler `< 10⁻⁶`.
2. Vorwärts-AD in Rust oder Python mit Dualzahlen (`a + bε`, `ε² = 0`) für `+ − × ÷ sin exp`; Test gegen
   die symbolische Ableitung.
3. Gradientenabstieg für `f(x,y) = x² + 10y²` mit verschiedenen Schrittweiten; Zeichne die Bahnen und erkläre das Zickzack.
4. Newton-Verfahren für `√2`: Konvergenzordnung messen (Verdopplung der korrekten Stellen).

### Woche 9–12: Integrieren und Reihen

**Fragen**

1. Riemann-Integral, Hauptsatz der Differential- und Integralrechnung (Skizze des Beweises).
2. Partielle Integration, Substitution; uneigentliche Integrale.
3. Wann konvergiert eine Reihe (Quotienten-, Wurzel-, Vergleichskriterium)? Harmonische Reihe und Euler-Maclaurin. (SF S. 198)
4. Wie schätzt man `∑ 1/k` und `n!` ab (Stirling)? (CL S. 1475, SF S. 195–205)

**Aufgaben**

1. Zeige `H_n = ln n + γ + o(1)` mit dem Integralkriterium und prüfe `n = 10⁶` im Programm.
2. Simpson- und Trapezregel in Code, Fehlerordnung messen (Verdopplung der Stützstellen).
3. Beweise `n! = Θ(√n (n/e)ⁿ)` mit Hilfe von Stirling (Verweis in SF) und prüfe die Abweichung.

### Woche 13–16: Mehrdimensional, Optimierung

**Fragen**

1. Lagrange-Multiplikatoren: Warum zeigen Gradient der Zielfunktion und Gradient der Nebenbedingung in dieselbe
   Richtung? (MML 7: Continuous Optimization, [S. 231]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=231))
2. Konvexe Funktionen: Definition, Test über die Hesse-Matrix, warum ist jedes lokale Minimum global?
3. Wann konvergiert Gradientenabstieg, und wie hängt die Schrittweite von der Krümmung ab?

**Aufgaben**

1. Minimiere `x² + y²` unter `x + y = 1` mit Lagrange von Hand, dann numerisch.
2. Logistische Regression (Binärklassifikation) mit eigenem Gradientenabstieg auf einem kleinen Datensatz; Gradient
   herleiten und mit numerischer Ableitung prüfen.
3. Alte Klausur „Analysis für Informatik“ einer Uni unter Zeitlimit.

---

## M4: Stochastik (Monate 14–18, ca. 16 Wochen)

Fehlen: Henze *Stochastik für Einsteiger*, Blitzstein/Hwang *Introduction to Probability* (frei).

Aus dem Bestand: [CL C.2: Wahrscheinlichkeit]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1522) · [CL C.3: Zufallsvariablen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1529) ·
[CL C.4: Geometrische und Binomialverteilung]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1536) · [MML 6: Wahrscheinlichkeit und Verteilungen]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=178) ·
[MML 6.3: Summen-, Produktregel, Bayes]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=189) · [MML 6.5: Normalverteilung]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=203) ·
[DG 1: Univariate Wahrscheinlichkeit]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Probability-for-Statistics-and-Machine-Learning_DasGupta_2011.pdf#page=22) · [MK 2: Wahrscheinlichkeit, Entropie, Inferenz]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Information-Theory-Inference-and-Learning-Algorithms_MacKay_2005.pdf#page=36) ·
[SF 1.7: Verteilungen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=49)

### Woche 1–4: Wahrscheinlichkeitsraum, bedingte Wahrscheinlichkeit

**Fragen**

1. Axiome von Kolmogorov (`Ω`, `σ`-Algebra, `P`); Laplace-Raum. (CL S. 1522, MML S. 178)
2. Bedingte Wahrscheinlichkeit, Multiplikationsregel, Satz von der totalen Wahrscheinlichkeit, Satz von Bayes.
   (MML S. 189)
3. Wann sind Ereignisse unabhängig, und wann paarweise gegenüber gemeinsam unabhängig? (MML S. 192)

**Aufgaben**

1. Medizinischer Test: Krankheit 1 %, Sensitivität 95 %, Spezifität 90 %. Wie hoch ist `P(krank | positiv)`?
   Rechne mit Bayes, simuliere mit 10⁶ Personen.
2. Monty Hall: Beweis und Simulation (Wechseln gewinnt mit `2/3`).
3. Geburtstagsparadoxon: Herleitung von `P(keine Übereinstimmung)` und Simulation; ab wie vielen Personen `> 50 %`?
4. Zeige: Aus paarweiser Unabhängigkeit folgt nicht gemeinsame Unabhängigkeit (Gegenbeispiel mit zwei Münzwürfen
   und dem Ereignis „gleich“).

### Woche 5–8: Zufallsvariablen, Erwartungswert, Varianz

**Fragen**

1. Verteilungsfunktion, Zähldichte, Dichte; Bernoulli, Binomial, geometrisch, Poisson, Gleichverteilung, Normal.
   (CL S. 1536, MML S. 184–203)
2. Linearität des Erwartungswerts (auch bei Abhängigkeit); Varianz, Kovarianz, Korrelation. (CL S. 1529, MML S. 192)
3. Markov- und Tschebyscheff-Ungleichung; schwaches Gesetz der großen Zahlen. (DG Kap. 1 und 7)
4. Zentraler Grenzwertsatz in einem Satz; wann darf man ihn nutzen? (DG Kap. 7)

**Aufgaben**

1. Linearität des Erwartungswerts: erwartete Anzahl Fixpunkte einer zufälligen Permutation (Antwort: `1`), erwartete
   Anzahl der Einstellungen im Hiring-Problem aus [Phase 3, Woche 2](Phase-3-Algorithmen.md).
2. Bloom-Filter: Leite die Falsch-positiv-Rate `(1 − e^{−kn/m})^k` her und bestimme das optimale `k`; Verbindung
   zu [Phase 5, Woche 10–11](Phase-5-Datenbanken.md).
3. Simulation des zentralen Grenzwertsatzes: Summe von 30 Gleichverteilten, Histogramm gegen Normalverteilung.
4. Beweise `Var(X) = E[X²] − E[X]²` und `Var(aX+b) = a²Var(X)`.

### Woche 9–12: Markov-Ketten, Zufallsprozesse

**Fragen**

1. Übergangsmatrix, stationäre Verteilung, Irreduzibilität, Aperiodizität; Konvergenz gegen die stationäre
   Verteilung. ([DG 10: Markov-Ketten]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Probability-for-Statistics-and-Machine-Learning_DasGupta_2011.pdf#page=360), [BR Anhang: Markov-Ketten]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Linear-Algebra-Algorithms-Applications-and-Techniques_Bronson-etal_2014_3ed.pdf#page=415))
2. Zufallsirrfahrt: Rückkehr, erwartete Zeit bis zum Ruin des Spielers. ([DG 11: Random Walks]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Probability-for-Statistics-and-Machine-Learning_DasGupta_2011.pdf#page=396))
3. Poisson-Prozess und Warteschlangen im Überblick. ([DG 13]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Probability-for-Statistics-and-Machine-Learning_DasGupta_2011.pdf#page=458))

**Aufgaben**

1. PageRank als Markov-Kette (Dämpfung `0,85`), Vergleich mit der Eigenvektor-Rechnung aus M2.
2. Simuliere das Ruinproblem für `p = 0,5` und `p = 0,49` und vergleiche mit der geschlossenen Formel.
3. Markov-Kette für Text (Bigramme) auf einem Buchtext, erzeuge einen Satz.

### Woche 13–16: Statistik und Information

**Fragen**

1. Maximum-Likelihood-Schätzer für Normal- und Bernoulli-Verteilung; Bias eines Schätzers (`1/n` gegen `1/(n−1)`
   für die Varianz). ([MML 8: When Models Meet Data]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Mathematics-for-Machine-Learning_Deisenroth-etal_2020.pdf#page=257))
2. Konfidenzintervall und Hypothesentest (p-Wert, Fehler 1. und 2. Art): Was sagt ein p-Wert nicht aus?
3. Entropie, Kreuzentropie, KL-Divergenz; Quellencodierungssatz. ([MK 4]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Information-Theory-Inference-and-Learning-Algorithms_MacKay_2005.pdf#page=81))

**Aufgaben**

1. Entropie eines Textes (Buchstaben, Bigramme) berechnen; Huffman-Länge aus [Phase 3](Phase-3-Algorithmen.md) vergleichen.
2. A/B-Test simulieren: wie oft liefert ein Test bei gleicher Wahrscheinlichkeit ein „signifikantes“ Ergebnis
   (`α = 0,05`), und wie ändert sich das bei 20 parallelen Tests?
3. Alte Klausur Stochastik unter Zeitlimit.

---

## T1: Theoretische Informatik und Logik (Monate 18–24, ca. 24 Wochen)

Fehlen: Schöning *Theoretische Informatik – kurz gefasst*, Sipser, Hromkovič, Hopcroft/Motwani/Ullman, Schöning *Logik für Informatiker*.

Aus dem Bestand: [CL 34: NP-Vollständigkeit]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=1343) · [WI: Algorithms and Complexity]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Algorithms-and-Complexity_Wilf_1994.pdf) (Kapitel zu NP-Vollständigkeit) ·
[CI 4: Scanning]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=38) als Anwendung regulärer Sprachen · [CI 5: Representing Code]($REPOS_DIR/Literatur/01_Fundamentals/Compilers_Interpreters_etc/Crafting-Interpreters_Nystrom_2021.pdf#page=57) als Anwendung kontextfreier Grammatiken

### Woche 1–6: Endliche Automaten und reguläre Sprachen

**Fragen**

1. Definiere einen DEA und einen NEA; wie macht die Potenzmengenkonstruktion aus einem NEA einen DEA, und wie groß
   kann dieser werden?
2. Warum beschreiben reguläre Ausdrücke, DEA und NEA dieselbe Sprachklasse (Skizze der Umformungen)?
3. Pumping-Lemma: Formuliere es und zeige damit, dass `{aⁿbⁿ}` nicht regulär ist.
4. Wie minimiert man einen DEA (Myhill-Nerode)?

**Aufgaben**

1. Python: NEA→DEA (Potenzmenge), Minimierung, Äquivalenztest zweier DEAs. Test gegen die `re`-Bibliothek auf
   Zufallswörtern.
2. Regex-Engine nach Thompson (Ausdruck → NEA → Simulation), Laufzeit linear in der Eingabe; vergleiche mit einer
   rückverfolgenden Variante an `(a*)*b` auf `aaaa…a` (exponentielles Verhalten zeigen).

### Woche 7–12: Kontextfreie Sprachen

**Fragen**

1. Grammatik, Ableitungsbaum, Mehrdeutigkeit; Chomsky-Normalform.
2. Kellerautomat (PDA) und Äquivalenz zu kontextfreien Grammatiken (Skizze).
3. Pumping-Lemma für kontextfreie Sprachen: Zeige, dass `{aⁿbⁿcⁿ}` nicht kontextfrei ist.
4. CYK-Algorithmus: Laufzeit `O(n³)`, Tabelle ausfüllen.

**Aufgaben**

1. CYK-Parser in Code für eine Grammatik in Normalform, Test mit Klammerausdrücken.
2. Grammatik für Ausdrücke mit Vorrang, Umformung zu einer LL(1)-Grammatik; vergleiche mit dem rekursiven Abstieg
   in [Phase 2, Woche 4–5](Phase-2-Compiler-und-Interpreter.md).

### Woche 13–18: Berechenbarkeit

**Fragen**

1. Turingmaschine formal; Church-Turing-These; Mehrband-TM simuliert durch Einband (Zeitverlust quadratisch).
2. Entscheidbar, semi-entscheidbar; Unentscheidbarkeit des Halteproblems (Diagonalisierung, Beweis auswendig).
3. Reduktion: Zeige per Reduktion, dass das Leerheitsproblem für TM unentscheidbar ist. Satz von Rice in einem Satz.
4. Zusammenhang zu Chaitins Unvollständigkeitssätzen (Überblick). ([CH]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Algorithmic-Information-Theory_Chaitin_2003.pdf))

**Aufgaben**

1. Turingmaschinen-Simulator in Rust, Programme: Palindromerkennung, binäre Inkrementierung, `aⁿbⁿ`.
2. Schreibe das Halteproblem-Argument als Programm mit einer angenommenen Funktion `halts(p, x)` und führe den
   Widerspruch aus.

### Woche 19–24: Komplexität und Logik

**Fragen**

1. `P`, `NP`, `NP`-vollständig: Definiere, erkläre den Zusammenhang mit Verifizierern und Zeugen. (CL S. 1343)
2. Satz von Cook-Levin in zwei Sätzen; Reduktionskette `SAT → 3SAT → Clique → Vertex Cover → Hamiltonkreis`
   (CL S. 1343 ff.).
3. Aussagenlogik: Syntax, Semantik, Erfüllbarkeit, Resolution, DPLL; Prädikatenlogik: Struktur, Belegung,
   Unentscheidbarkeit der Gültigkeit.
4. Was bedeutet `P ≠ NP` praktisch, was die Klasse `PSPACE`?

**Aufgaben**

1. DPLL-SAT-Löser in Rust mit Einheitspropagation; teste auf zufälligen 3-SAT-Instanzen und beobachte den Phasenübergang
   bei Verhältnis ca. 4,26 Klauseln pro Variable.
2. Implementiere die Reduktion `3SAT → Clique` und den Verifizierer; prüfe auf kleinen Instanzen mit Brute Force.
3. Alte Klausur Theoretische Informatik unter Zeitlimit.

---

## T2: Master-Niveau nach Wahl (ab Monat 24)

Fehlen: Arora/Barak, Graham/Knuth/Patashnik *Concrete Mathematics*, Axler, Forster. Wähle **ein** Buch und arbeite
ausgewählte Kapitel **mit allen Übungen** durch (Nachweis: Notizen und Lösungen im Repository).

Aus dem Bestand als Ersatz und Vorbereitung auf *Concrete Mathematics*:

- [KN 1.2: Mathematische Grundlagen]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=26): Induktion, Summen, [Binomialkoeffizienten]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=68),
  [Harmonische Zahlen]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=91), [Fibonacci]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=95), [erzeugende Funktionen]($REPOS_DIR/Literatur/Top/The-Art-of-Computer-Programming-Books/The-Art-of-Computer-Programming-Vol1_Knuth_1997_3ed.pdf#page=103)
- [SF 2: Rekurrenzen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=60) · [SF 3: Erzeugende Funktionen]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=110) · [SF 4: Asymptotik]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=170) ·
  [SF 5: Analytische Kombinatorik]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=238) · [SF 6: Bäume]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/An-Introduction-to-the-Analysis-of-Algorithms_Sedgewick-Flajolet_2013_2ed.pdf#page=276)
- [AG: Algorithmic Graph Theory and Sage]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Algorithmic-Graph-Theory-and-Sage_Joyner-etal_2013.pdf) für Diestel-ähnliche Graphentheorie
- [DG 14–20: Martingale, Large Deviations, MCMC]($REPOS_DIR/Literatur-PythonAI/07_AI_ML/Machine_Learning/Probability-for-Statistics-and-Machine-Learning_DasGupta_2011.pdf#page=484) für Wahrscheinlichkeitstheorie auf Master-Niveau

**Fragen** (beispielhaft; aus dem gewählten Buch weitere)

1. Löse `T(n) = 2T(n/2) + n` exakt (nicht nur asymptotisch) mit erzeugenden Funktionen und vergleiche mit dem Master-Theorem aus [Phase 3, Woche 2](Phase-3-Algorithmen.md). (SF S. 99–148)
2. Wie viele binäre Bäume mit `n` Knoten gibt es (Catalan-Zahlen)? Leite die Rekurrenz und die geschlossene Form her. (SF S. 277–283, KN S. 103)
3. Mittlere Laufzeit von Quicksort `2 n ln n`: Leite sie aus der Rekurrenz her. (SF S. 22–46)
4. Martingale: Zeige, dass `Sₙ² − n` ein Martingal ist (symmetrische Irrfahrt), und leite die Azuma-Hoeffding-Ungleichung ab. (DG S. 484)

**Aufgaben**

1. Wähle ein Kapitel und löse **jede** Übung; Lösungsweg schriftlich, Programm als Gegenprobe wo möglich.
2. Reproduziere ein Ergebnis aus einem Paper zu einem Thema aus [Phase 5/6](Phase-5-Datenbanken.md) (zum Beispiel
   die Analyse der Falsch-positiv-Rate von Bloom-Filtern oder die Wahrscheinlichkeit einer Wahlspaltung in Raft) und
   vergleiche Theorie und Simulation.

---

## Nachweis und Abschluss

- [ ] M1: Klausur MIT 6.042J bestanden, alle Beweise aus Woche 1–4 ausgeschrieben
- [ ] M2: Klausur MIT 18.06 bestanden, Gauß/LU/QR/SVD-Code
- [ ] M3: Klausur Analysis bestanden, AD-Bibliothek und Gradientenabstieg
- [ ] M4: Klausur Stochastik bestanden, Simulationen
- [ ] T1: Klausur Theoretische Informatik bestanden, Regex-Engine, TM-Simulator, SAT-Löser
- [ ] T2: ein Buch, ein Kapitel, alle Übungen
- [ ] Beschaffungsliste abhaken: Kernbücher besorgt und die Wochen mit Kapitel- und Seitenlinks ergänzt
- [ ] Matrix aktualisiert: Algorithmen, Compiler, Datenbanken, Verteilte Systeme, PL-Theorie (T-Werte)

## Fortschritt

| Block | Begonnen | Klausur bestanden | Nachweis (Link) |
|---|---|---|---|
| M1 | | | |
| M2 | | | |
| M3 | | | |
| M4 | | | |
| T1 | | | |
| T2 | | | |
