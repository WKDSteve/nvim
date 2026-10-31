# Phase 5: Datenbanken (relational, Speicher-Engines, Transaktionen)

Teil des [Lernplans](../Lernplan.md), Hauptspur, Monate 18–22 (ca. 16 Wochen). Hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) Datenbanken 1→4 und Rust. Voraussetzung: [Phase 1](Phase-1-Systeme-und-C.md)
(Dateien, Speicher), [Phase 3](Phase-3-Algorithmen.md) (B-Bäume, Hashtabellen).

**Nachweis:** ein Key-Value-Store in Rust mit Write-Ahead-Log (WAL) und LSM-Tree (Memtable, SSTables, Compaction,
Crash-Recovery-Test) mit Messungen, dazu alle Fragen unten ohne Nachschlagen beantwortet.

**Lage im Bestand:** Das Datenbank-Lehrbuch (Kemper/Eickler, *Datenbanksysteme*) und Kleppmanns *Designing
Data-Intensive Applications* **fehlen im Bestand**; sie stehen jetzt in der
[Beschaffungsliste]($REPOS_DIR/Literatur/Beschaffungsliste.md), Abschnitt 7. Diese Seite trägt die Phase bis dahin mit
dem, was im Bestand liegt (B-Bäume, Dateisysteme, Puffer-Cache, Rust), und nennt zu den fehlenden Büchern Themen
statt Seitenlinks. Kapitelnummern der fehlenden Bücher beim Kauf prüfen.

Links mit `#page=N` zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.

## Quellen

| Kürzel | Buch | Stand |
|---|---|---|
| **[KE]** | Kemper/Eickler, *Datenbanksysteme* | fehlt, Beschaffungsliste |
| **[DDIA]** | Kleppmann, *Designing Data-Intensive Applications* | fehlt, Beschaffungsliste |
| **[CL]** | Cormen u. a., *Introduction to Algorithms* (4th) | [PDF]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf) |
| **[S]** | Stallings, *Operating Systems* (9th) | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf) |
| **[K]** | Kerrisk, *The Linux Programming Interface* | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf) |
| **[PR]** | Blandy/Orendorff, *Programming Rust* (2018) | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf) |
| **[RR]** | Gjengset, *Rust for Rustaceans* | [PDF]($REPOS_DIR/Literatur/02_Programming/Rust/Rust-for-Rustaceans_Gjengset_2022.pdf) |
| **[TR]** | Klabnik/Nichols, *The Rust Programming Language* (2019) | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/The-Rust-Programming-Language_Klabnik-Nichols_2019.pdf) |

Kostenlos und gut: SQLite-Dokumentation („How SQLite Is Tested“, „Atomic Commit In SQLite“, „Write-Ahead
Logging“), das Paper *The Log-Structured Merge-Tree* (O'Neil u. a., 1996) und die CMU-Vorlesung 15-445
(Datenbanksysteme, Videos und Übungen frei).

## Wochenplan

### Woche 1–3: Relationales Modell und SQL

Lesen in [KE]: Einführung, Datenbankentwurf (E/R-Modell), relationales Modell und Relationenalgebra, SQL.
Übung: `sqlite3` auf der Kommandozeile.

**Fragen**

1. Wie übersetzt du ein E/R-Diagramm (1:n, n:m, Generalisierung) in Tabellen, mit Primär- und Fremdschlüsseln?
2. Wie lauten Selektion, Projektion, Verbund (Join), Vereinigung, Differenz in Relationenalgebra und in SQL?
3. Was ist der Unterschied zwischen `INNER`, `LEFT`, `FULL OUTER` Join; wann braucht man `GROUP BY` mit `HAVING`?
4. Was bedeutet `NULL` in der dreiwertigen Logik (`NULL = NULL`, `NOT IN` mit `NULL`), und welche Fallen folgen?
5. Wann ist eine Unterabfrage korreliert, und wie ersetzt man sie durch einen Join?

**Aufgabe (SQL):** Schema für eine Bibliotheksverwaltung (Bücher, Autoren, Exemplare, Leser, Ausleihen) in SQLite
anlegen, mit Fremdschlüsseln (`PRAGMA foreign_keys=ON`). 25 Abfragen schreiben, jede einmal in Relationenalgebra
auf Papier: Top-N, Ausleihen pro Monat, nie ausgeliehene Bücher, überfällige Exemplare, Fensterfunktionen
(`ROW_NUMBER`, `SUM() OVER`).

### Woche 4–5: Entwurfstheorie und Normalformen

Lesen in [KE]: Funktionale Abhängigkeiten, Normalformen, Zerlegung.

**Fragen**

1. Was ist eine funktionale Abhängigkeit, und wie berechnest du die Hülle `F⁺` und den Attributhüllen-Test
   `X⁺`?
2. Definiere 1NF, 2NF, 3NF, BCNF. Gib für jede Stufe ein Beispiel, das sie verletzt.
3. Wann ist eine Zerlegung verlustfrei und abhängigkeitserhaltend, und warum geht BCNF nicht immer mit beidem?
4. Wann denormalisiert man bewusst (Berichte, Lesehäufigkeit), und welche Anomalien holt man sich damit zurück?

**Aufgabe:** Das Bibliotheksschema aus Woche 1–3 bewusst schlecht entwerfen (eine große Tabelle), Anomalien beim
Einfügen, Ändern, Löschen vorführen, dann in 3NF/BCNF zerlegen und beweisen, dass die Zerlegung verlustfrei ist.

### Woche 6–7: Physische Speicherung und Indizes

Lesen: [CL 18: B-Trees]($REPOS_DIR/Literatur-Programming/01_Fundamentals/Data_Structures_Algorithms/Introduction-to-Algorithms_Cormen-etal_2022_4ed.pdf#page=655) · [S 12.3: B-Trees]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=562) · [S 12.7: Verwaltung des Sekundärspeichers]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=573) ·
[K 13.1–13.3: Puffer-Cache, `fsync`]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=277) · [K 14.4: I-Nodes]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=300) · [K 14.6: Journaling-Dateisysteme]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=304)
und in [KE]: Physische Datenorganisation, Anfragebearbeitung.

**Fragen**

1. Warum ist ein B-Baum für Platte und SSD besser geeignet als ein Rot-Schwarz-Baum? Berechne die Höhe für
   10⁹ Schlüssel bei 4-KiB-Seiten und 100 Schlüsseln pro Knoten. (CL S. 655)
2. Was ist ein B⁺-Baum, und wie unterscheidet er sich vom B-Baum bei Bereichsabfragen? (CL S. 655)
3. Was garantiert `write()` ohne `fsync` nicht, und warum reicht `fsync` auf die Datei allein nicht, wenn eine
   Datei neu angelegt oder umbenannt wurde (Verzeichnis-`fsync`)? (K S. 283)
4. Was tut ein Journaling-Dateisystem (Metadaten gegen Daten), und welche Garantie bekommt eine Anwendung davon
   nicht? (K S. 304)
5. Wie wählt der Optimierer zwischen Tabellen- und Indexscan (Selektivität, Clustered Index)? [KE]
6. Wann ist ein Hash-Index besser als ein B⁺-Baum, wann nicht? [KE]

**Aufgabe (Rust):** B⁺-Baum im Speicher mit Seiten (Knoten fester Größe), `insert`, `get`, Bereichsabfrage, dann
auf eine Datei abgebildet (Seiten per `pread`/`pwrite`). Test gegen `BTreeMap` mit Zufallsoperationen.

### Woche 8–9: Transaktionen und Wiederherstellung

Lesen in [KE]: Transaktionsverwaltung, Mehrbenutzersynchronisation, Logging und Recovery. Dazu [DDIA] Kap. 7
(Transactions).

**Fragen**

1. Was bedeuten A, C, I, D, und welche davon sorgt der Datenbankkern, welche die Anwendung für?
2. Was ist Serialisierbarkeit, und wie prüfst du sie mit dem Konfliktgraph? Zeichne ihn für einen Beispielplan.
3. Wie arbeitet Zwei-Phasen-Sperren (2PL) und warum ist strenges 2PL (Sperren bis Commit) nötig? Wann entsteht
   ein Deadlock, wie erkennt man ihn? (Vergleiche [S 6.4 Erkennung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=307).)
4. Isolationsstufen: Dirty Read, Non-repeatable Read, Phantom, Lost Update, Write Skew. Welche Stufe verhindert
   was? Wie funktioniert Snapshot Isolation (MVCC)?
5. Write-Ahead-Logging: Warum erst das Log, dann die Seite? Was heißen *steal* und *no-force*, und wie sehen
   Redo und Undo bei der Wiederherstellung aus (ARIES in Grundzügen)?

**Aufgabe:** Mit `sqlite3` und zwei Terminals: Lost Update und Write Skew reproduzieren (im `WAL`-Modus und im
Journal-Modus), die Beobachtungen mit den Isolationsstufen vergleichen. Dann lies den SQLite-Artikel „Atomic
Commit In SQLite“ und zeichne den Ablauf für den Rollback-Journal-Modus.

### Woche 10–11: Datenmodelle und Speicher-Engines

Lesen in [DDIA]: Kap. 1 (Reliable, Scalable, Maintainable), Kap. 2 (Data Models), Kap. 3 (Storage and Retrieval),
Kap. 4 (Encoding). Dazu [PR: Collections]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=381) (besonders `BTreeMap` auf [S. 400]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=400)) und
[PR: Input and Output]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=453).

**Fragen**

1. Wann passt ein Dokument-, ein Graph- und ein relationales Modell? Was bedeutet „Schema on read“?
2. Beschreibe einen LSM-Tree: Memtable, WAL, SSTable, Compaction (size-tiered gegen leveled). Was sind
   Schreib-, Lese- und Raumverstärkung?
3. Wie vermeiden Bloom-Filter unnötige Lesezugriffe auf SSTables, und wie hängt die Fehlerrate mit Bits pro
   Schlüssel und Anzahl der Hashfunktionen zusammen?
4. Vergleiche LSM-Tree und B-Baum: Welche Last (viele Schreibvorgänge, Punktabfragen, Scans) liegt wem?
5. Was ist ein Tombstone und warum bleibt er bis zur Compaction im untersten Level?
6. Wie kodierst du Datensätze (varint, Längenpräfix, CRC) so, dass ein halb geschriebener Eintrag erkannt wird?

**Aufgabe (Rust):** Kodierung für Einträge (Länge, Schlüssel, Wert, CRC32), `Memtable` als `BTreeMap`, `WAL`-Schreiber
mit `sync_data` pro Batch und Wiederherstellung beim Start (Prüfsumme prüfen, bei Fehler abschneiden).

### Woche 12–14: LSM-Store bauen (Nachweis)

Ablauf:

1. **Schreibpfad:** `put`/`delete` → WAL → Memtable; Flush bei Größenschwelle in eine neue SSTable (sortierte Blöcke,
   Index, Bloom-Filter, Footer).
2. **Lesepfad:** Memtable, dann SSTables von neu nach alt, Bloom-Filter vor jedem Blocklesen; `scan` mit
   mischendem Iterator (`merge iterator`), der Tombstones und Überschreibungen auflöst.
3. **Compaction:** size-tiered oder leveled; Hintergrund-Thread, atomarer Austausch der Dateimenge über eine
   Manifest-Datei (schreiben, `fsync`, umbenennen, Verzeichnis-`fsync`).
4. **Recovery-Test:** Prozess zufällig mit `SIGKILL` beenden oder die Datei an einer zufälligen Stelle abschneiden;
   nach dem Neustart gilt: jede bestätigte Schreiboperation ist da, keine halb geschriebene sichtbar.
5. **Test gegen Referenz:** Zufallsoperationen gegen eine `BTreeMap`, nach jedem Schritt (und nach jedem Neustart)
   gleicher Zustand.
6. **Messen:** Durchsatz für Schreiben, Punktabfragen, Scans; Vergleich mit SQLite (`WAL`) und, wenn möglich,
   mit RocksDB; Schreibverstärkung zählen.

Rust-Hilfen: [PR 19: Concurrency]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=479) · [PR 18: I/O]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=453) · [RR 6: Testing]($REPOS_DIR/Literatur/02_Programming/Rust/Rust-for-Rustaceans_Gjengset_2022.pdf#page=111) ·
[RR 10: Concurrency]($REPOS_DIR/Literatur/02_Programming/Rust/Rust-for-Rustaceans_Gjengset_2022.pdf#page=193) · [TR 16: Fearless Concurrency]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/The-Rust-Programming-Language_Klabnik-Nichols_2019.pdf#page=379). Für Dateizugriffe mit `mmap`:
[K 49: Memory Mappings]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1061), für Sperren der Datenbankdatei (nur eine Instanz): [K 55: File Locking]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1161).

### Woche 15: Replikation und Partitionierung

Lesen in [DDIA]: Kap. 5 (Replication) und Kap. 6 (Partitioning).

**Fragen**

1. Leader/Follower-Replikation: synchron, asynchron, halb-synchron. Welche Anomalien entstehen durch
   Replikationsverzögerung (Read-your-writes, Monotonic Reads)?
2. Was passiert beim Ausfall des Leaders (Failover), und was ist „Split Brain“?
3. Bereichs- gegen Hash-Partitionierung: Vor- und Nachteile für Scans und für Hotspots.
4. Wie ordnet konsistentes Hashing Schlüssel Knoten zu, und was passiert beim Hinzufügen eines Knotens?

**Aufgabe:** Auf dem eigenen Store: asynchroner Follower, der das WAL liest (nur Lesezugriff) und nachzieht;
Test: Leader ausschalten, Follower übernimmt, Verlust messen.

### Woche 16: Abschluss

Alle Fragen aus dem Kopf. Bericht mit den Messungen aus Woche 12–14, einer Skizze des Dateiformats und einer Liste
der Entscheidungen als ADRs (siehe [Phase 4](Phase-4-Architektur-und-Testen.md)). Veröffentlichung als Repository.

## Nachweis und Abschluss

- [ ] Repository mit LSM-Store (WAL, Recovery, Compaction), Recovery-Tests grün
- [ ] Messbericht (Durchsatz, Verstärkung, Vergleich mit SQLite)
- [ ] 25 SQL-Abfragen gelöst, Normalisierungsübung durchgeführt
- [ ] Alle Fragen beantwortet
- [ ] Matrix aktualisiert: Datenbanken 1→4, Rust
- [ ] Kemper/Eickler und Kleppmann besorgt; die Wochen 1–5, 8 und 10–11 mit Kapitel- und Seitenlinks ergänzt

## Fortschritt

| Block | Gelesen | Fragen | Aufgabe | Notiz (Link) |
|---|---|---|---|---|
| Woche 1–3 | | | | |
| Woche 4–5 | | | | |
| Woche 6–7 | | | | |
| Woche 8–9 | | | | |
| Woche 10–11 | | | | |
| Woche 12–14 | | | | |
| Woche 15 | | | | |
| Woche 16 | | | | |
