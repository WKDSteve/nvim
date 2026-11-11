# install-tools – alle CLI-Tools auf einem neuen Gerät mit einem Befehl

Installiert, was die eigenen nvim-Plugins und Repos an externen Programmen
brauchen: zuerst über **winget**, sonst scoop, sonst npm / pip / cargo; was es
nirgends als Paket gibt, wird mit Download-Link genannt. Schon Vorhandenes
wird übersprungen, ein zweiter Lauf ist also harmlos.

## Benutzung

Windows (PowerShell 5.1 oder 7):

```powershell
pwsh -File "$env:NVIM_CONFIG_DIR\scripts\install-tools\install-tools.ps1"
```

Linux / macOS / WSL:

```bash
"$NVIM_CONFIG_DIR/scripts/install-tools/install-tools.sh"
```

Ohne Argumente: Gruppen `core`, `plugins` und `dev`, mit einer Rückfrage vor
dem Start (winget/apt fragen danach selbst noch einmal).

| Windows | Linux / macOS / WSL | Wirkung |
|---|---|---|
| `-List` | `--list` | Tabelle: Tool, Gruppe, vorhanden?, Weg, wer es braucht |
| `-DryRun` | `--dry-run` | nur die Befehle zeigen |
| `-All` | `--all` | auch die Gruppe `heavy` (LibreOffice, Chrome, ffmpeg, OCR, Whisper, …) |
| `-Only core,dev` | `--only core,dev` | nur diese Gruppen |
| `-Skip dev` | `--skip dev` | Gruppen auslassen |
| `-Yes` | `--yes` | keine Rückfragen; winget-Lizenzen annehmen, apt/dnf `-y` |
| `-ReposDir E:\repos` | `--repos-dir …` | Wurzel der Repos (Default `$REPOS_DIR`) |
| `-WriteReadme` | `--write-readme` | die Liste unten neu erzeugen |
| `-Force` | `--force` | auf der Workstation auch Bau-Toolchains und `cargo install` |
| `-Profile nvim,rust` | `--profile nvim,rust` | statt Gruppen die Stack-Profile (s. u.); `all`, `saved` = die gemerkten |
| `-Status` | `--status` | je Profil zeigen, was da ist; installiert nichts |

**Workstation** (`NVIM_MACHINE_ROLE=workstation`): fertige Pakete werden
installiert wie überall (lazygit für gitsuite.nvim, rg, pandoc, … per winget,
scoop, npm, pip). Ausgelassen wird nur, was lokal **gebaut** würde, denn ein
eigenes unsigniertes Programm meldet CrowdStrike Falcon:

- die Bau-Toolchains (in `tools.json` `not_on_workstation`): rustup/cargo,
  cargo-audit/-deny, MSVC, clang, cmake, ninja, Inno Setup, sowie tree-sitter-CLI
  und zig, die nur Parser kompilieren (die Config kompiliert dort keine);
- der Weg `cargo install` (ein Tool mit winget/scoop-Paket kommt trotzdem);
- pip-Quellpakete: pip nimmt dort nur fertige Wheels (`--only-binary :all:`);
- der scoop-Bootstrap: fehlt scoop, startet das Skript dort keinen Installer
  per `iex` aus dem Netz (eigener Falcon-Auslöser, auch nicht mit `-Force`);
  scoop dann von Hand einrichten oder die scoop-Tools (luacheck) weglassen.

`-List` und `-Status` zeigen solche Tools als „workstation: builds“. Eine
bewusste Ausnahme geht mit `-Force`. Die eigenen Desktop-Apps installiert
dieses Skript nirgends.

Danach: neues Terminal öffnen (PATH), dann in nvim `:Lib deps status` und
`:checkhealth`; für die Runner `scripts/runner_tools_check.ps1`.
LSP-Server, Formatter und Linter aus Mason installiert lsp.nvim selbst
(`ensure_install`), nicht dieses Skript.

## Woher die Liste kommt

- **Plugin-Tools:** jede `$REPOS_DIR/*/docs/install.json` (das Spec-Format von
  `lib.nvim.deps`, siehe `lib.nvim/lua/lib/nvim/deps/README.md`). Zusammengeführt
  wie bei `:Lib deps status`: ein Eintrag pro Programm, „Pflicht“ wenn ein Plugin
  es verlangt, „wer braucht es“ sammelt alle Plugins.
- **[`tools.json`](tools.json):** Gruppe und fehlende Wege für die Spec-Tools
  (`overrides`), dazu Tools, die Plugins ohne Spec nutzen (gh, lazygit, nvr,
  cspell, typos, …), und die Dev-Toolchain (stylua, luacheck, rustup, pnpm, …).
  Ein neues Tool kommt **in die `docs/install.json` des Plugins**, wenn ein
  Plugin es braucht, sonst hierher.

## Stack-Profile (Claude-Setup)

Zweite Auswahl neben den Gruppen, für die Toolchains, die die Claude-Hooks je
Stack brauchen. `setup-claude-code.ps1/.sh` zeigt `-Status` und fragt nach
Profilen (früher `setup-devtools.js`, das in diesem Skript aufgegangen ist).

| Profil | Tools |
|---|---|
| `core` (immer dabei) | git, node, rg, fd |
| `nvim` | nvim, stylua, luacheck, lua-language-server |
| `cpp` | cmake, ninja, MSVC Build Tools (Windows), LLVM/clang nur solange MSVC fehlt |
| `rust` | rustup (cargo) |
| `web` | pnpm |
| `tauri` | WebView2 (Windows) + `rust` + `web` |

Die Zuordnung steht als `profiles` an den Tools in `tools.json`; die gewählten
Profile merkt sich `~/.claude/devtools.profile` (`-Profile saved`). Die
Profil-Tools stehen alle selbst in `tools.json`, damit das Setup sie kennt,
bevor die Plugin-Repos geklont sind.

Die Logik steht einmal in [`install_tools.py`](install_tools.py) (nur
Standardbibliothek); `install-tools.ps1` und `install-tools.sh` sorgen nur
dafür, dass Python da ist (winget `Python.Python.3.14` nach Rückfrage, der
Store-Stub zählt nicht; unter Linux der Paketmanager), und starten es. Unter Linux laufen
pip-Tools über `pipx` (PEP 668), unter WSL entfallen GUI-Programme, die auf
der Windows-Seite laufen (WezTerm).

## Die Tools

Pflicht = mindestens ein Plugin funktioniert ohne das Tool nicht. Alles
andere schaltet eine Funktion frei oder macht sie schneller.

<!-- tools:begin (generated: install_tools.py --write-readme) -->

### core - Basis: Editor, Suche, Git, Laufzeiten - ohne die geht wenig

| Tool | Wofür (aus der Spec) | Wer braucht es | Windows | Linux / macOS |
|---|---|---|---|---|
| `7z` | Archives: release packaging of the repos, extracting downloads. | release workflows | winget `7zip.7zip` | apt `7zip`, brew `sevenzip` |
| `curl` (Pflicht) | Carries every provider's HTTP request and the streamed response (lib.nvim.net.curl shells out to it); witho... | ai.nvim, casedesk.nvim, diff.nvim, emojis.nvim, language.nvim, mdview.nvim, pdfport.nvim, runtime-analysis.nvim | winget `cURL.cURL` | apt `curl`, brew `curl` |
| `fd` | Fastest live filesystem search for resolving a truncated path tail when the in-memory cache misses (falls b... | gopath.nvim, pickers.nvim, Claude setup (profile core) | winget `sharkdp.fd` | apt `fd-find`, brew `fd` |
| `fzf` | Enables the fzf engine (an alternative matching/UI backend to the built-in picker engine). | pickers.nvim | winget `junegunn.fzf` | apt `fzf`, brew `fzf` |
| `gh` | GitHub CLI: pickers.nvim's GitHub source, terminal.nvim's repo list, private reads of the runners and ci_st... | pickers.nvim, terminal.nvim, runners | winget `GitHub.cli` | apt `gh`, brew `gh` |
| `git` | Backs the two opt-in git features: the ambient on_hold line-diff preview (argv-only git blame/git show, ful... | fileops.nvim, Claude setup (profile core) | winget `Git.Git` | apt `git`, brew `git` |
| `lazygit` | The git UI gitsuite.nvim opens in a float. | gitsuite.nvim | winget `JesseDuffield.lazygit` | apt `lazygit`, brew `lazygit` |
| `node` | Keeps the persistent cspell sidecar alive (node/cspell_server.js), which makes buffer and live spell checks... | language.nvim, Claude setup (profile core) | winget `OpenJS.NodeJS.LTS` | apt `nodejs`, brew `node` |
| `nvim` | Neovim itself; the plugins, the tasks/rules engines and testing.nvim all run on it. | nvim-config, testing.nvim | winget `Neovim.Neovim` | brew `neovim` |
| `python` | Runs tools/*.py of every repo and the pip routes of this script (python3 on Windows is the Store stub, whic... | all repos, pdfport.nvim, media.nvim | winget `Python.Python.3.14` | apt `python3`, brew `python` |
| `rg` (Pflicht) | Makes :Cases grep and the full-text search behind :Case similar fast on a large case tree. | casedesk.nvim, emojis.nvim, filetree.nvim, gopath.nvim, insights.nvim, markdown.nvim, pickers.nvim, replacer.nvim, Claude setup (profile core) | winget `BurntSushi.ripgrep.MSVC` | apt `ripgrep`, brew `ripgrep` |
| `tree-sitter` (nicht auf der Workstation) | nvim-treesitter (branch main) compiles every parser with the tree-sitter CLI. | nvim-config, lib.nvim (parser_policy) | winget `tree-sitter.tree-sitter-cli` | brew `tree-sitter-cli` |
| `zig` (nicht auf der Workstation) | A C compiler for nvim-treesitter's parser builds (any of zig, gcc, clang, cl counts). | nvim-config | winget `zig.zig` | apt `gcc`, brew `zig` |

### plugins - leichte Werkzeuge einzelner Plugins (PDF, Bilder, Rechtschreibung, ...)

| Tool | Wofür (aus der Spec) | Wer braucht es | Windows | Linux / macOS |
|---|---|---|---|---|
| `chafa` | Renders PDF pages as images inside the terminal for :PdfPort preview, on terminals without their own image... | pdfport.nvim | winget `hpjansson.Chafa` | apt `chafa`, brew `chafa` |
| `codespell` | Spell provider of language.nvim for common misspellings in code and docs. | language.nvim | pip `codespell` | apt `codespell`, brew `codespell` |
| `cspell` | The code-aware spell checker of language.nvim (fast with node as a sidecar). | language.nvim | npm `cspell` | npm `cspell` |
| `dot` | Lays out the import-dependency graph (imports/graph.lua) when a graph-based layout is requested, instead of... | insights.nvim | winget `Graphviz.Graphviz` | apt `graphviz`, brew `graphviz` |
| `ffmpeg` (Pflicht) | Lifts a still out of a video under the cursor, so a .mp4 shows a frame in the hover window instead of a siz... | hover.nvim, media.nvim | winget `Gyan.FFmpeg` | apt `ffmpeg`, brew `ffmpeg` |
| `ffprobe` (Pflicht) | Answers what is in a file: duration, dimensions, codecs, whether there is a moving picture at all. | media.nvim | winget `Gyan.FFmpeg` | apt `ffmpeg`, brew `ffmpeg` |
| `gs` | Enables the ghostscript producer — pdfport.merge() fallback #3 (last resort: recompresses page content). | pdfport.nvim | winget `ArtifexSoftware.GhostScript` | apt `ghostscript`, brew `ghostscript` |
| `img2pdf` | Enables the img2pdf creation producer — the lossless first choice for image -> PDF (embeds JPEG/PNG data un... | pdfport.nvim | pip `img2pdf` | apt `img2pdf`, brew `img2pdf` |
| `magick` | Enables SVG-to-PNG conversion (WezTerm/kitty can't decode SVG themselves), image-to-PDF export, the redact... | images.nvim, pdfport.nvim | winget `ImageMagick.ImageMagick` | apt `imagemagick`, brew `imagemagick` |
| `nvr` | neovim-remote: lazygit inside gitsuite.nvim opens files in the running nvim instead of a nested one. | gitsuite.nvim | pip `neovim-remote` | pip `neovim-remote` |
| `pandoc` | :Cases export converts a case's bundled markdown to standalone HTML before printing it. | casedesk.nvim, pdfport.nvim | winget `JohnMacFarlane.Pandoc` | apt `pandoc`, brew `pandoc` |
| `pdftk` | Enables the pdftk producer — pdfport.merge() fallback #2, behind qpdf. | pdfport.nvim | winget `PDFLabs.PDFtk` | apt `pdftk`, brew `pdftk-java` |
| `pdftoppm` | :Case pdf renders the pages of a scanned PDF (no text layer) as images for tesseract, so the PDF gets a mac... | casedesk.nvim, hover.nvim, images.nvim, pdfport.nvim | winget `oschwartz10612.Poppler` | apt `poppler-utils`, brew `poppler` |
| `pdftotext` | :Case pdf extracts the text of a case's PDF attachments into <file>.pdf.text.md sidecars, which is what mak... | casedesk.nvim, pdfport.nvim | winget `oschwartz10612.Poppler` | apt `poppler-utils`, brew `poppler` |
| `qpdf` | Enables the qpdf producer — first choice for pdfport.merge() (small, exact, no page-content re-encoding). | pdfport.nvim | winget `qpdf.qpdf` | apt `qpdf`, brew `qpdf` |
| `tmux` | Terminal backend of terminal.nvim outside WezTerm. | terminal.nvim | nur Linux/macOS | apt `tmux`, brew `tmux` |
| `trans` | translate-shell: the shell translate provider of language.nvim (no API key needed). | language.nvim | nur Linux/macOS | apt `translate-shell`, brew `translate-shell` |
| `trash-put` | Enables moving deleted files to the desktop trash (with undo) on Linux instead of a permanent delete. | filetree.nvim | nur Linux/macOS | apt `trash-cli`, brew `trash-cli` |
| `typos` | Spell provider of language.nvim (fast source-code typo finder). | language.nvim | winget `Crate-CI.Typos` | brew `typos-cli` |
| `wslview` | Under WSL, hands a URL to the Windows browser through wslu rather than through cmd.exe /C start, which re-t... | open.nvim | nur Linux/macOS | apt `wslu` |
| `zip` | filetree.nvim's compress action (tar/bsdtar is the fallback, Windows ships tar). | filetree.nvim | winget `GnuWin32.Zip` | apt `zip`, brew `zip` |

### heavy - gross oder selten gebraucht (Office, Browser, Player, OCR, lokale KI) - nur mit --all

| Tool | Wofür (aus der Spec) | Wer braucht es | Windows | Linux / macOS |
|---|---|---|---|---|
| `chrome` | The PDF engine for :Cases export: a headless Chromium prints the HTML pandoc produced via --print-to-pdf. | casedesk.nvim, hover.nvim, pdfport.nvim | winget `Google.Chrome` | apt `chromium`, brew `google-chrome` |
| `clang-format` (nicht auf der Workstation) | LLVM/clang: formatter of the C++ hooks, and the compiler when MSVC is not there (only installed then). | C++ projects (Claude hooks, profile cpp) | winget `LLVM.LLVM` | apt `clang clang-format`, brew `llvm` |
| `marker_single` | pdfport.nvim's ML PDF-to-markdown producer (marker-pdf, pulls PyTorch, several GB). | pdfport.nvim | pip `marker-pdf` | pip `marker-pdf` |
| `mpv` | Two things, both optional. :Media window opens a real player window this plugin owns and can stop; and medi... | media.nvim | winget `shinchiro.mpv` | apt `mpv`, brew `mpv` |
| `msvc` (nicht auf der Workstation) | MSVC Build Tools (VC tools workload): the C++ compiler the cpp profile builds with on Windows; several GB. | C++ projects (Claude hooks, profile cpp) | winget `Microsoft.VisualStudio.2022.BuildTools` | nur Windows |
| `ollama` | Enables the ollama provider: local models, nothing leaves the machine. | ai.nvim, pdfport.nvim | winget `Ollama.Ollama` | brew `ollama` |
| `soffice` | Turns an office document (doc/docx/odt and friends) under the cursor into a picture in the hover window ins... | hover.nvim, pdfport.nvim | winget `TheDocumentFoundation.LibreOffice` | apt `libreoffice`, brew `libreoffice` |
| `tesseract` | :Case ocr reads the text out of a case's screenshots into <image>.ocr.md sidecars, which is what makes :Cas... | casedesk.nvim, images.nvim, media.nvim, pdfport.nvim | winget `UB-Mannheim.TesseractOCR` | apt `tesseract-ocr`, brew `tesseract` |
| `vlc` | External player hover.nvim hands a video to. | hover.nvim | winget `VideoLAN.VLC` | apt `vlc`, brew `vlc` |
| `weasyprint` | Enables the weasyprint creation producer — first choice for html -> PDF (clean CSS Paged Media support). | pdfport.nvim | pip `weasyprint` | apt `weasyprint`, brew `weasyprint` |
| `whisper` | The second transcription engine: OpenAI's reference Whisper (PyTorch), used by engine = "auto" when whisper... | media.nvim | pip `openai-whisper` | brew `openai-whisper` |
| `whisper-cli` | Turns speech into text, locally and without Python. | media.nvim | [Download](https://github.com/ggml-org/whisper.cpp/releases) | [Download](https://github.com/ggml-org/whisper.cpp/releases) |

### dev - Toolchain fuer Tests, Lint, CI und Builds der eigenen Repos

| Tool | Wofür (aus der Spec) | Wer braucht es | Windows | Linux / macOS |
|---|---|---|---|---|
| `actionlint` | Lints GitHub workflow files (streamtap hygiene job). | streamtap | winget `rhysd.actionlint` | brew `actionlint` |
| `cargo` (nicht auf der Workstation) | Rust toolchain via rustup (cargo, rustc, rustfmt, clippy) for all Rust repos. | streamtap, testing.nvim runner, *-desktop | winget `Rustlang.Rustup` | apt `rustup`, brew `rustup` |
| `cargo-audit` (nicht auf der Workstation) | Supply-chain job of the Rust repos (needs cargo first). | Rust repos | cargo `cargo-audit` | cargo `cargo-audit` |
| `cargo-deny` (nicht auf der Workstation) | Supply-chain job of the Rust repos (needs cargo first). | Rust repos | cargo `cargo-deny` | cargo `cargo-deny` |
| `cmake` (nicht auf der Workstation) | Build of ai-desktop (and whisper.cpp from source). | ai-desktop | winget `Kitware.CMake` | apt `cmake`, brew `cmake` |
| `iscc` (nicht auf der Workstation) | Inno Setup compiler for the ai-desktop installer. | ai-desktop | winget `JRSoftware.InnoSetup` | nur Windows |
| `jq` | JSON in shell steps: docmap-desktop and the release workflows. | docmap-desktop, release workflows | winget `jqlang.jq` | apt `jq`, brew `jq` |
| `lua-language-server` | Enables the opt-in luals enrichment pass: lua-language-server --doc output is merged into the IR, adding @c... | docmap.nvim, Claude setup (profile nvim) | winget `LuaLS.lua-language-server` | apt `lua-language-server`, brew `lua-language-server` |
| `luacheck` | Lua linter of every .nvim repo (lint gates, CI parity before push). | all .nvim repos | scoop `luacheck` | apt `lua-check`, brew `luacheck` |
| `ninja` (nicht auf der Workstation) | Build backend of the C++ projects (CMake generator). | C++ projects (Claude hooks, profile cpp) | winget `Ninja-build.Ninja` | apt `ninja-build`, brew `ninja` |
| `pnpm` | Package manager of tasks-desktop, rules-desktop and the appkit UI. | tasks-desktop, rules-desktop, appkit | winget `pnpm.pnpm` | brew `pnpm` |
| `pwsh` | PowerShell 7: workflow steps with shell: pwsh, the scripts of the nvim config, several plugin helpers. | nvim-config, lib.nvim, workflows | winget `Microsoft.PowerShell` | brew `powershell` |
| `shellcheck` | Hygiene jobs: lints the shell scripts of the repos. | hygiene jobs | winget `koalaman.shellcheck` | apt `shellcheck`, brew `shellcheck` |
| `stylua` | Lua formatter of every .nvim repo (format gates, CI parity before push). | all .nvim repos | winget `JohnnyMorganz.StyLua` | brew `stylua` |
| `webview2` | WebView2 runtime the Tauri apps render in (preinstalled on Windows 11). | docmap-desktop, tasks-desktop, rules-desktop | winget `Microsoft.EdgeWebView2Runtime` | nur Windows |
| `wezterm` | The terminal the Configs repo sets up; terminal.nvim's WezTerm backend. | Configs, terminal.nvim | winget `wez.wezterm` | brew `wezterm` |

<!-- tools:end -->

Nicht im Skript, nur bei Bedarf: Java/JDK (`EclipseAdoptium.Temurin.21.JDK`),
.NET SDK (`Microsoft.DotNet.SDK.8`), Dart/Flutter – nur für die Mobile- und
C#-Server von lsp.nvim.
