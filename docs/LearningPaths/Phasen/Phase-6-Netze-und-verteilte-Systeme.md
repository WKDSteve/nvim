# Phase 6: Netze und verteilte Systeme

Teil des [Lernplans](../Lernplan.md), Hauptspur, Monate 22–26 (ca. 16 Wochen). Hebt in der
[Kompetenzmatrix](../Kompetenzmatrix.md) Netze und Verteilte Systeme →3–4. Voraussetzung: [Phase 0](Phase-0-Betriebssysteme.md)
(Prozesse, Nebenläufigkeit), [Phase 5](Phase-5-Datenbanken.md) (Replikation, Logs).

**Nachweis:** ein HTTP-Server direkt auf Sockets (kein Framework), eine Raft-Implementierung, die die MIT-6.5840-Tests
besteht, alle Fragen unten ohne Nachschlagen beantwortet.

**Lage im Bestand:** van Steen/Tanenbaum *Distributed Systems* (kostenlos online) und Kleppmann *DDIA* Kap. 8–9
liegen nicht im Bestand; Kleppmann steht in der [Beschaffungsliste]($REPOS_DIR/Literatur/Beschaffungsliste.md),
Abschnitt 7. Das Raft-Paper (Ongaro/Ousterhout, *In Search of an Understandable Consensus Algorithm*) und die MIT-Kurs-
seite 6.5840 mit den Labs sind kostenlos.

Links mit `#page=N` zeigen auf die PDF-Seite, nicht auf die gedruckte Seitenzahl. Pfade liegen unter `$REPOS_DIR`.

## Quellen

| Kürzel | Buch | Datei |
|---|---|---|
| **[K]** | Kerrisk, *The Linux Programming Interface* (Kap. 56–63) | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf) |
| **[T]** | Tanenbaum/Wetherall, *Computer Networks* (5th) | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf) |
| **[TI]** | Fall/Stevens, *TCP/IP Illustrated, Vol. 1* (2nd), Vertiefung | [PDF]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/TCP-IP/TCP-IP-Illustrated-Vol1_Fall-Stevens_2011_2ed.pdf) |
| **[PR]** | Blandy/Orendorff, *Programming Rust* | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf) |
| **[RR]** | Gjengset, *Rust for Rustaceans* | [PDF]($REPOS_DIR/Literatur/02_Programming/Rust/Rust-for-Rustaceans_Gjengset_2022.pdf) |
| **[CG]** | Cox-Buday, *Concurrency in Go*, für die Labs | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Concurrency-in-Go_Cox-Buday_2017.pdf) |
| **[GO]** | Donovan/Kernighan, *The Go Programming Language*, für die Labs | [PDF]($REPOS_DIR/Literatur/02_Programming/Golang/The-Go-Programming-Language_Donovan-Kernighan_2015.pdf) |
| **[NG]** | Newmarch, *Network Programming with Go* | [PDF]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Network-Programming-with-Go_Newmarch_2017.pdf) |

## Wochenplan

### Woche 1–2: Sockets und Protokollschichten

Lesen: [K 56: Sockets, Einführung]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1194) · [K 57: UNIX-Domain-Sockets]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1209) ·
[K 58: Grundlagen von Netzen]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1223) · [K 59: Internet-Sockets]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1241) ·
[T 1.4: Referenzmodelle]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=65)

**Fragen**

1. Welche Systemaufrufe braucht ein TCP-Server (`socket`, `bind`, `listen`, `accept`), welche ein Client
   (`connect`)? Was bedeutet das Argument `backlog`? (K S. 1199–1203)
2. Was ist die Netzwerk-Byte-Reihenfolge, und was geht schief, wenn man ein `struct` roh über einen Socket schickt?
   (K S. 1242)
3. Warum ist TCP ein Bytestrom, kein Nachrichtenstrom, und was folgt daraus für Teil-Lesen und -Schreiben?
   (K S. 1298)
4. Vergleiche OSI- und TCP/IP-Modell: Welche Schicht macht was, und welche Aufgaben tauchen in beiden auf?
   (T S. 65)
5. Wie löst `getaddrinfo` Namen auf (IPv4/IPv6, DNS), und warum soll man es statt `gethostbyname` nutzen?
   (K S. 1248)

**Aufgabe (C):** Echo-Server und -Client mit TCP und mit UDP, IPv4 und IPv6, mit `getaddrinfo`. Danach: Datei-
übertragung mit eigenem Protokoll (Längenpräfix), das auch bei zufällig zerstückelten Lesevorgängen stimmt (Test:
Client schickt Bytes einzeln).

### Woche 3: Server-Entwürfe

Lesen: [K 60: Server-Entwürfe]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1283) · [K 61: Sockets, Fortgeschrittenes]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1298) ·
[K 63: Alternative I/O-Modelle]($REPOS_DIR/Literatur/01_Fundamentals/Operating_Systems/Linux/System_Programming/The-Linux-Programming-Interface_Kerrisk_2010.pdf#page=1369) · [PR 18: Networking]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=475)

**Fragen**

1. Iterativer Server, Prozess pro Verbindung, Thread pro Verbindung, Thread-Pool, ereignisgesteuert: Vor- und
   Nachteile, Skalierung bis wie viele Verbindungen? (K S. 1283)
2. Wie arbeiten `select`/`poll`, und wo liegt ihr Problem bei vielen Dateideskriptoren? Was macht `epoll`
   besser (level- gegen edge-triggered)? (K S. 1374–1390, 1369)
3. Was passiert bei `SIGPIPE` und bei `shutdown(SHUT_WR)` im Vergleich zu `close`? (K S. 1300)
4. Was ist das „C10K-Problem“?

**Aufgabe:** Denselben Echo-Server dreimal bauen: Thread pro Verbindung, `poll`-Schleife, `epoll` (Linux). Mit einem
Lastgenerator (selbst geschrieben oder `wrk`) 1, 100, 10 000 Verbindungen messen; Zahlen in die Notiz.

### Woche 4–5: Netz- und Transportschicht

Lesen: [T 5.2: Routing-Algorithmen]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=386) · [T 5.6: Netzwerkschicht im Internet]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=460) ·
[T 6.1–6.2: Transportdienst, Elemente der Protokolle]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=519) · [T 6.3: Überlastkontrolle]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=554) ·
[T 6.4: UDP]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=565) · [T 6.5: TCP]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=576) · Vertiefung [TI 13: TCP-Verbindungen]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/TCP-IP/TCP-IP-Illustrated-Vol1_Fall-Stevens_2011_2ed.pdf#page=634) ·
[TI 14: Timeout und Neuübertragung]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/TCP-IP/TCP-IP-Illustrated-Vol1_Fall-Stevens_2011_2ed.pdf#page=686) · [TI 15: Datenfluss und Fenster]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/TCP-IP/TCP-IP-Illustrated-Vol1_Fall-Stevens_2011_2ed.pdf#page=730) ·
[TI 16: Überlastkontrolle]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/TCP-IP/TCP-IP-Illustrated-Vol1_Fall-Stevens_2011_2ed.pdf#page=766)

**Fragen**

1. Wie funktioniert der Drei-Wege-Handschlag, warum drei und nicht zwei, und welche Zustände (TIME_WAIT, CLOSE_WAIT)
   siehst du in `netstat`? (T S. 576, TI S. 634)
2. Wie berechnet TCP den Timeout (SRTT, RTTVAR), und was ist Karns Algorithmus? (TI S. 686)
3. Erkläre das Schiebefenster, Empfangsfenster gegen Überlastfenster, Slow Start, Congestion Avoidance, schnelle
   Neuübertragung. (T S. 554, TI S. 766)
4. Was ist IP-Fragmentierung, was Path MTU Discovery? (T S. 460)
5. Distanzvektor- gegen Link-State-Routing: Wie konvergieren sie, und wo liegt das Count-to-Infinity-Problem?
   (T S. 386)
6. Was unterscheidet UDP von TCP, wann nutzt man welches (DNS, Streaming, Spiele)? (T S. 565)

**Aufgabe:** Mit `tcpdump` oder Wireshark einen Verbindungsaufbau, eine Übertragung und einen Abbau mitschneiden
und jedes Segment (Flags, Sequenz- und Bestätigungsnummern, Fenster) in einer Tabelle erklären. Dann mit
`tc netem` (Linux) Verlust und Verzögerung zuschalten und die Retransmissions im Mitschnitt finden.

### Woche 6–8: HTTP-Server auf Sockets (Nachweis 1)

Lesen: [T 7.3: Das World Wide Web]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=670) · [T 8.9: Websicherheit]($REPOS_DIR/Literatur/01_Fundamentals/Networking_Protocols/Computer-Networks_Tanenbaum-Wetherall_2011_5ed.pdf#page=870) · [RR 8: Asynchrone
Programmierung]($REPOS_DIR/Literatur/02_Programming/Rust/Rust-for-Rustaceans_Gjengset_2022.pdf#page=143) · [PR 19: Concurrency]($REPOS_DIR/Literatur-Programming/02_Programming/Rust/Programming-Rust_Blandy-Orendorff_2018.pdf#page=479). Spezifikation: RFC 9110 (Semantik) und RFC 9112
(HTTP/1.1), beide frei.

Mindestumfang (Rust oder C, keine HTTP-Bibliothek, `std::net` oder rohe Sockets):

- Anfragezeile und Header parsen (Groß-/Kleinschreibung, Zeilenfortsetzung, Größenlimits), `Content-Length` und
  `Transfer-Encoding: chunked` (Anfrage und Antwort)
- `GET`/`HEAD`/`POST`, korrekte Statuscodes (`400`, `404`, `405`, `411`, `413`, `431`, `501`), `Date`, `Server`
- Keep-Alive und Pipelining-Verhalten; Timeouts für langsame Clients (Slowloris)
- statische Dateien ohne Pfad-Ausbruch (`..`, absolute Pfade, Symlinks), `Range`-Anfragen, `If-Modified-Since`
- Nebenläufigkeit: Thread-Pool, danach `epoll`/`mio`; Grenzen für Verbindungen und Puffer
- Tests: Zufalls- und kaputte Eingaben (Fuzzing des Parsers), Vergleich mit einem Referenzserver, Lasttest

**Fragen**

1. Was unterscheidet HTTP/1.0, 1.1, 2 und 3 im Kern (Verbindungen, Multiplexing, Kopfkompression, QUIC)? (T S. 670)
2. Wie erkennt der Server das Ende einer Anfrage mit Rumpf (Content-Length, chunked), und warum ist
   „Request Smuggling“ möglich, wenn zwei Parteien das verschieden lesen?
3. Wie sichert TLS die Verbindung (Zertifikat, Handschlag, Schlüsselableitung)? Was prüft ein Client genau? (T S. 870)
4. Welche Angriffe muss ein statischer Dateiserver abwehren (Pfad-Traversal, Header-Injection, Ressourcen-
   erschöpfung)?

### Woche 9: Theorie verteilter Systeme

Lesen: van Steen/Tanenbaum *Distributed Systems* (kostenlos): Architekturen, Prozesse, Kommunikation, Koordination
(Uhren, Konsens), Konsistenz und Replikation, Fehlertoleranz. Dazu [DDIA] Kap. 8 und 9, sobald vorhanden.

**Fragen**

1. Welche Annahmen enthält das asynchrone Systemmodell (Nachrichtenverlust, Verzögerung, Ausfälle der Knoten),
   und was bedeuten „crash-stop“ und „Byzantine“?
2. Warum kann man Uhren in verteilten Systemen nicht trauen? Was ist eine Lamport-Uhr, was eine Vektoruhr, und was
   sagen sie über „passierte vor“ aus?
3. Was besagt das FLP-Resultat in einem Satz, und wie umgehen Paxos und Raft es praktisch (Zeitüberschreitung)?
4. Was sagt das CAP-Theorem, und wo ist es irreführend (Latenz, PACELC)?
5. Linearisierbarkeit gegen sequentielle Konsistenz gegen Eventual Consistency: je ein Beispiel für eine
   Ausführung, die nur die schwächere Stufe erlaubt.

### Woche 10–16: MIT 6.5840 Labs und Raft (Nachweis 2)

Voraussetzung: Go für die Labs (Skelette und Tests sind vorgegeben). Zum Einstieg [GO: Kap. 8–9, Goroutines und
Nebenläufigkeit mit gemeinsamem Zustand]($REPOS_DIR/Literatur/02_Programming/Golang/The-Go-Programming-Language_Donovan-Kernighan_2015.pdf#page=1) und [CG]($REPOS_DIR/Literatur-Programming/02_Programming/Golang/Concurrency-in-Go_Cox-Buday_2017.pdf#page=1). Das Raft-Paper (Figure 2 ausgedruckt!)
ist die Spezifikation.

| Woche | Lab | Inhalt |
|---|---|---|
| 10 | Lab 1: MapReduce | Koordinator und Arbeiter über RPC, Ausfall eines Arbeiters |
| 11 | Lab 2: Key/Value-Server | Linearisierbarkeit mit Wiederholungs-Erkennung |
| 12 | Lab 3A: Raft, Leader-Wahl | Wahlen, Heartbeats, Randomisierte Timeouts |
| 13 | Lab 3B: Raft, Log-Replikation | `AppendEntries`, Konsistenzprüfung, Commit-Regel |
| 14 | Lab 3C: Raft, Persistenz | `currentTerm`, `votedFor`, `log` sichern und laden |
| 15 | Lab 3D: Raft, Snapshots | Log-Kompaktierung, `InstallSnapshot` |
| 16 | Lab 4: Fehlertoleranter KV-Dienst | Raft + Zustandsmaschine, Clients und Duplikate |

**Fragen**

1. Welche Zustände hat ein Raft-Knoten, und wann wechselt er (Follower → Candidate → Leader)?
2. Warum sind die Wahl-Timeouts zufällig? Was passiert bei gleichzeitigen Kandidaten?
3. Was sagt die Log-Matching-Eigenschaft, und wie prüft `AppendEntries` sie (`prevLogIndex`, `prevLogTerm`)?
4. Warum committet ein Leader nur Einträge **seiner eigenen** Amtszeit direkt (Figure 8)? Zeichne das Gegenbeispiel.
5. Welche drei Dinge müssen vor jeder Antwort persistent sein? Was passiert, wenn man `votedFor` nicht speichert?
6. Wie bleibt ein Client-Befehl bei Leader-Wechsel und Wiederholung genau einmal (Client-ID, Sequenznummer)?
7. Was kostet ein Snapshot (Ablauf, Zustandsmaschine serialisieren, Log abschneiden), und wann ist `InstallSnapshot`
   nötig?

**Aufgabe:** Die Labs 1–4 in Go lösen (die Tests laufen mit `-race` und je 100× ohne Fehler). Danach Raft in
Rust nachbauen (Zustandsmaschine, Netzwerk als Trait, deterministischer Simulator mit zufälligen Ausfällen und
Nachrichtenreihenfolgen). Das ist die Vorstufe zur Master-Stufe der Matrix („klassisches Paper nachimplementieren,
mit Messungen“).

## Nachweis und Abschluss

- [ ] HTTP-Server-Repository mit Fuzz- und Lasttests
- [ ] MIT-6.5840-Labs 1–4 bestanden (Testausgaben als Beleg)
- [ ] Raft in Rust mit Simulator
- [ ] Alle Fragen beantwortet; van Steen gelesen, Kleppmann besorgt
- [ ] Matrix aktualisiert: Netze, Verteilte Systeme →3–4

## Fortschritt

| Block | Gelesen | Fragen | Aufgabe | Notiz (Link) |
|---|---|---|---|---|
| Woche 1–2 | | | | |
| Woche 3 | | | | |
| Woche 4–5 | | | | |
| Woche 6–8 | | | | |
| Woche 9 | | | | |
| Woche 10–16 | | | | |
