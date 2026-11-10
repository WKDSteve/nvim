#!/usr/bin/env bash
# Installs the CLI tools the own nvim plugins and repos need - one command on a new machine.
# Linux / macOS / WSL. Thin starter for install_tools.py (the logic lives there once, shared
# with install-tools.ps1): makes sure python3 is there, then runs the script.
#
#   scripts/install-tools/install-tools.sh --list          # what is there, what is missing
#   scripts/install-tools/install-tools.sh --dry-run --all # show the commands only
#   scripts/install-tools/install-tools.sh                 # core, plugins, dev
#   scripts/install-tools/install-tools.sh --all --yes     # everything, no questions
#   scripts/install-tools/install-tools.sh --only core,dev
#
# Every argument is passed through to install_tools.py (--help lists them).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  role="$(printf '%s' "${NVIM_MACHINE_ROLE:-}" | tr '[:upper:]' '[:lower:]')"
  if [ "$role" = "workstation" ]; then
    echo "python3 fehlt, und auf der Workstation wird nichts installiert (EDR/Falcon)." >&2
    exit 2
  fi
  sudo=""
  if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then sudo="sudo"; fi
  echo "python3 fehlt - das Skript braucht es. Installiere es ueber den Paketmanager."
  if command -v apt-get >/dev/null 2>&1; then $sudo apt-get install python3
  elif command -v dnf >/dev/null 2>&1; then $sudo dnf install python3
  elif command -v pacman >/dev/null 2>&1; then $sudo pacman -S --needed python
  elif command -v zypper >/dev/null 2>&1; then $sudo zypper install python3
  elif command -v apk >/dev/null 2>&1; then $sudo apk add python3
  elif command -v brew >/dev/null 2>&1; then brew install python
  else
    echo "Kein Paketmanager gefunden - python3 bitte von Hand installieren." >&2
    exit 2
  fi
fi

exec python3 -I "$here/install_tools.py" "$@"
