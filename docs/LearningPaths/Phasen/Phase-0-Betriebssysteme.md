# Phase 0: Betriebssysteme (Stallings) und Shell in C

Teil des [Lernplans](../Lernplan.md), Hauptspur, Monate 0–2. Hebt in der [Kompetenzmatrix](../Kompetenzmatrix.md)
Betriebssysteme T 3→4. **Nachweis:** Shell in C mit Pipes, `fork`/`exec`, Umleitungen (ohne KI geschrieben) und
alle Kontrollfragen unten ohne Nachschlagen beantwortet.

Die Links (`#page=N`) zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.
In den Fragen steht hinter jeder Frage die PDF-Seite, auf der die Antwort beginnt.

## Quellen

| Kürzel | Buch | Datei |
|---|---|---|
| **[S]** | Stallings, *Operating Systems* (9th, 2018) | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf) |
| **[K]** | Kerrisk, *The Linux Programming Interface* | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf) |

Zusätzlich in [S]: Programmierprojekt „Developing a Shell“ ab [S. 953]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=953), Anhang B (Projekte) ab
[S. 748]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=748). Hausaufgaben mit Lösungen: `HW_Problems_and_Solutions.zip` im Ordner des Buchs.

## Wochenplan

Jede Woche: lesen, die Fragen schriftlich beantworten (Notiz in WKDBooks, Feynman-Test), eine Programmieraufgabe
lösen.

### Woche 1: Prozesse (Kap. 3, 4)

Lesen: [3.1 Prozess]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=132) · [3.2 Zustände]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=134) · [3.3 Beschreibung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=149) ·
[3.4 Steuerung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=158) · [3.5 Ausführung des OS]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=164) · [Kap. 4 Threads]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=177)

**Fragen**

1. Was gehört zum Prozess-Image, und was steht im Process Control Block? Warum liegt der PCB im Kernel? (S. 149)
2. Zeichne das Fünf-Zustands-Modell. Welcher Übergang kommt mit einem Suspend-Zustand dazu, und warum braucht man
   ihn? (S. 134)
3. Was passiert Schritt für Schritt bei einem Prozesswechsel (Process Switch), und was unterscheidet ihn vom
   Mode Switch? (S. 158)
4. Wo läuft der Kern: außerhalb der Prozesse, innerhalb der Prozesse oder als Prozesse? Je ein Vor- und Nachteil.
   (S. 164)
5. Was teilen sich Threads eines Prozesses, was hat jeder Thread für sich? Welche Vorteile hat ein Thread
   gegenüber einem Prozess? (S. 177 ff.)
6. User-Level- gegen Kernel-Level-Threads: Was passiert bei einem blockierenden Systemaufruf? (Abschnitt 4.2)

**Aufgabe (C):** `fork`-Experimente. Programm, das 3 Kinder erzeugt, jedes mit `getpid()`/`getppid()` ausgibt und
vom Elternprozess mit `waitpid` eingesammelt wird. Dann einen Zombie absichtlich erzeugen und in `ps` sichtbar
machen; eine Waise erzeugen und beobachten, wer sie adoptiert. Vertiefung: [K 24: Prozess erzeugen]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=557), [K 25: beenden]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=575), [K 26: Kindprozesse überwachen]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=585).

### Woche 2: Nebenläufigkeit (Kap. 5)

Lesen: [5.1 Software-Ansätze]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=227) · [5.2 Prinzipien]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=233) · [5.3 Hardware]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=242) ·
[5.4 Semaphore]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=245) · [5.5 Monitore]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=258) · [5.6 Nachrichten]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=264) ·
[5.7 Readers/Writers]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=271)

**Fragen**

1. Definiere kritischen Abschnitt, Race Condition, Livelock, Starvation. Gib je ein Beispiel. (S. 233)
2. Warum reicht „Interrupts sperren“ auf Multiprozessoren nicht? Wie funktioniert `compare_and_swap`, und welche
   Nachteile hat Busy-Waiting? (S. 242)
3. Wie arbeiten `semWait`/`semSignal` (schwache gegen starke Semaphore)? Warum müssen beide atomar sein? (S. 245)
4. Löse Producer/Consumer mit Semaphoren. Was geht schief, wenn man im Producer die beiden `semWait`-Aufrufe
   vertauscht? (S. 245 ff.)
5. Was bietet ein Monitor, das Semaphore nicht bieten? Wozu dienen Condition-Variablen? (S. 258)
6. Readers/Writers: Wie sieht die Lösung mit Leser-Vorrang aus, und wo hungert der Schreiber aus? (S. 271)

**Aufgabe (C):** Producer/Consumer mit POSIX-Threads (`pthread_mutex_t`, `pthread_cond_t`), Ringpuffer fester
Größe. Test: 4 Producer, 4 Consumer, 10⁶ Elemente, Summe vergleichen; mit ThreadSanitizer (`-fsanitize=thread`)
bauen. Zweite Variante: Readers/Writers mit Schreiber-Vorrang. Vertiefung: [K 29: Threads]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=661), [K 30: Synchronisation]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=675).

### Woche 3: Deadlock (Kap. 6)

Lesen: [6.1 Prinzipien]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=291) · [6.2 Prävention]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=300) · [6.3 Avoidance]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=301) ·
[6.4 Erkennung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=307) · [6.6 Dining Philosophers]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=310)

**Fragen**

1. Nenne die vier Bedingungen für Deadlock. Welche streicht welche Präventionsstrategie? (S. 291, 300)
2. Wie funktioniert der Bankiers-Algorithmus? Rechne das Beispiel im Buch von Hand nach: sicherer Zustand ja
   oder nein? (S. 301)
3. Wie erkennt man Deadlock, und was tut man danach (Recovery-Optionen)? (S. 307)
4. Dining Philosophers: Gib drei Lösungen an (Semaphor mit Limit 4, Ressourcen-Ordnung, Monitor) und sage, welche
   Deadlock **und** Starvation verhindert. (S. 310)

**Aufgabe (C):** Dining Philosophers mit Pthreads. Version A mit Deadlock (reproduzierbar machen, z. B. `usleep`
zwischen den Gabeln), Version B mit Ressourcen-Ordnung. Ein Absatz Beweis, warum B nicht verklemmen kann.

### Woche 4: Speicher (Kap. 7, 8)

Lesen: [7.1 Anforderungen]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=341) · [7.2 Partitionierung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=345) · [7.3 Paging]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=356) ·
[7.4 Segmentierung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=359) · [8.1 Hardware und Kontrollstrukturen]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=372) ·
[8.2 OS-Software]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=389) · [8.4 Linux]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=414)

**Fragen**

1. Welche Anforderungen an Speicherverwaltung nennt das Buch? (S. 341)
2. Interne gegen externe Fragmentierung: Welches Verfahren leidet worunter? First-, Best-, Next-Fit vergleichen.
   (S. 345)
3. Übersetze eine logische Adresse mit zweistufiger Seitentabelle von Hand (eigenes Zahlenbeispiel: 4-KiB-Seiten,
   32 Bit). Was leistet der TLB? (S. 372)
4. Ersetzungsstrategien OPT, LRU, FIFO, Clock: Führe die Referenzfolge aus dem Buch mit allen vier durch und zähle
   die Seitenfehler. (S. 389)
5. Was ist Thrashing, und wie begrenzt man es (Working Set, Page-Fault-Frequency)? (S. 389)
6. Wie verwaltet Linux den Speicher (Seitentabellen, Buddy-System, Slab)? (S. 414)

**Aufgabe (C):** Seitenersetzungs-Simulator: liest eine Referenzfolge, simuliert FIFO/LRU/Clock/OPT mit N Rahmen
und gibt die Fehlerzahl aus. Belady-Anomalie mit FIFO nachweisen (Folge 1 2 3 4 1 2 5 1 2 3 4 5 mit 3 und 4
Rahmen).

### Woche 5: Scheduling (Kap. 9)

Lesen: [9.1 Arten]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=427) · [9.2 Algorithmen]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=431) · [9.3 UNIX]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=453)

**Fragen**

1. Kurz-, Mittel-, Langzeit-Scheduling: Was entscheiden sie jeweils? (S. 427)
2. Rechne dieselbe Prozessmenge (Tabelle im Buch) mit FCFS, RR (q=1, q=4), SPN, SRT, HRRN und Feedback durch.
   Vergleiche Turnaround, normalisierte Turnaround-Zeit und Antwortzeit. (S. 431)
3. Warum braucht SPN eine Schätzung der Laufzeit, und wie funktioniert die exponentielle Glättung? (S. 431)
4. Was ist Aging, und wo hilft es? (S. 431)
5. Wie bildet traditionelles UNIX Prioritäten aus CPU-Nutzung und `nice`? (S. 453)

**Aufgabe (C):** Scheduler-Simulator mit Eingabedatei (Ankunft, Laufzeit), Ausgabe als Gantt-Zeile und Tabelle,
Algorithmen aus Frage 2. Die Ergebnisse müssen mit dem Beispiel im Buch übereinstimmen (das ist der Test).

### Woche 6: I/O und Dateisysteme (Kap. 11, 12)

Lesen: [11.4 Pufferung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=515) · [11.5 Disk-Scheduling]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=518) · [11.6 RAID]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=525) ·
[12.1 Überblick]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=552) · [12.7 Sekundärspeicher]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=573) · [12.8 UNIX-Dateien]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=581) ·
[12.9 Linux VFS]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=586)

**Fragen**

1. Warum puffert das OS? Vergleiche Einfach-, Doppel- und Ringpuffer. (S. 515)
2. Disk-Scheduling FIFO, SSTF, SCAN, C-SCAN: Rechne die Kopfbewegung für die Anfragefolge im Buch. (S. 518)
3. Erkläre RAID 0, 1, 5 mit Kapazität, Ausfalltoleranz und Schreibkosten. (S. 525)
4. Wie sieht ein UNIX-Inode aus (direkte und indirekte Blöcke)? Wie groß kann eine Datei bei 4-KiB-Blöcken,
   12 direkten und je einem einfach/zweifach/dreifach indirekten Zeiger werden? (S. 581)
5. Was leistet das Linux-VFS (Superblock, Inode, Dentry, File)? (S. 586)
6. Wie verwaltet ein Dateisystem freien Platz (Bitmap, verkettet, Index)? (S. 573)

**Aufgabe (C):** Kleines Dateisystem-Image in einer Datei: Header, Bitmap, Inodes mit 12 direkten und einem
einfach indirekten Zeiger. Dateien per Programm anlegen, lesen und löschen; Konsistenzprüfer, der Bitmap gegen
Inodes vergleicht. Kein Mounten nötig.

### Woche 7–8: Abschlussprojekt Shell (Nachweis)

Spezifikation: [S, Programming Project One]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/W_Stallings_OS/Operating-Systems-Internals-and-Design-Principles_Stallings_2018_9ed.pdf#page=953) und [K] [Kap. 24–28]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=557) (Prozesse, `exec`), [Kap. 44]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=933) (Pipes), [Kap. 20–22]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=431) (Signale).
Mindestumfang:

- Prompt, Zeile lesen, in Wörter zerlegen (Anführungszeichen beachten)
- externe Programme per `fork` + `execvp`, Exit-Status in `$?`
- Umleitungen `<`, `>`, `>>`, `2>`
- Pipelines beliebiger Länge (`a | b | c`); jeder Prozess bekommt die richtigen Dateideskriptoren, alle
  unbenutzten Pipe-Enden werden geschlossen
- Eingebaut: `cd`, `exit`, `export`
- Hintergrund `&`, Signale (`SIGINT` trifft nur den Vordergrundjob, die Shell überlebt), keine Zombies
- Tests: Skript mit 20 Fällen, das Ausgabe und Exit-Status gegen `bash` vergleicht

**Selbstprüfung nach dem Projekt**

1. Warum ist `cd` kein externes Programm?
2. Was geschieht bei `a | b`, wenn der Elternprozess das Schreibende der Pipe offen lässt?
3. Was unterscheidet `fork` von `vfork` und `posix_spawn`?
4. Wie kommt der Exit-Status eines Kindes zur Shell (`wait`-Status-Makros)?

Antworten dazu: [K 24–28]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=557) und [K 44]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=933).

## Fortschritt

| Woche | Gelesen | Fragen | Aufgabe | Notiz (Link) |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |
| 7–8 | | | | |
