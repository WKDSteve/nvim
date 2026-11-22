# Rust-Projekt

- Vor "fertig": `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`.
- Der globale Hook prueft nach jedem Edit einer `.rs`-Datei `rustfmt --check`.
- Keine `unwrap()`/`expect()` in Library-Code; Fehler ueber `Result` propagieren.
- Neue Abhaengigkeiten nur nach Rueckfrage.
- Git: In einer Cloud-Sitzung (`CLAUDE_CODE_REMOTE` gesetzt) nie auf `main` pushen, nur auf den eigenen Branch `claude/…`; gelandet wird lokal per Rebase, der Geräteschlüssel signiert dabei (`GIT-09`). Das „auf main pushen“ (`GIT-01`) gilt nur lokal.
