# Tauri-Projekt (Rust-Backend + Web-Frontend)

- Backend (`src-tauri/`): `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`.
- Frontend: pnpm; Lint/Typecheck/Tests des Projekts vor "fertig".
- Der globale Hook prueft `.rs` (rustfmt) und Frontend-Dateien (lokales prettier).
- `cargo tauri build`/`dev` nicht selbst starten, ausser ausdruecklich gewuenscht.
- Neue Abhaengigkeiten (crates/npm) nur nach Rueckfrage.
- Git: In einer Cloud-Sitzung (`CLAUDE_CODE_REMOTE` gesetzt) nie auf `main` pushen, nur auf den eigenen Branch `claude/…`; gelandet wird lokal per Rebase, der Geräteschlüssel signiert dabei (`GIT-09`). Das „auf main pushen“ (`GIT-01`) gilt nur lokal.
