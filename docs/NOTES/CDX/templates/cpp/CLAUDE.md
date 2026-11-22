# C++-Projekt

- Toolchain: MSVC (Windows, Fallback clang), CMake + Ninja.
- Build: `cmake -S . -B build -G Ninja && cmake --build build`, Tests: `ctest --test-dir build`.
- Format: `.clang-format` im Repo-Root ist massgeblich; der globale Hook
  prueft Edits nur, wenn diese Datei existiert.
- Neue Abhaengigkeiten nur nach Rueckfrage.
- Git: In einer Cloud-Sitzung (`CLAUDE_CODE_REMOTE` gesetzt) nie auf `main` pushen, nur auf den eigenen Branch `claude/…`; gelandet wird lokal per Rebase, der Geräteschlüssel signiert dabei (`GIT-09`). Das „auf main pushen“ (`GIT-01`) gilt nur lokal.
