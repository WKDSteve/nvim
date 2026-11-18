#!/usr/bin/env bash
# install-repos-luarc.sh <repos-dir> [source] -- copy luarc.repos-root.jsonc to <repos-dir>/.luarc.jsonc.
#
# Called by setup-claude-code.sh; same as install-repos-luarc.ps1 (reasons there). An existing, different file is
# moved to <name>.bak-<timestamp> first.
set -u

repos_dir="${1:-}"
src="${2:-$(cd "$(dirname "$0")" && pwd)/luarc.repos-root.jsonc}"

if [ -z "$repos_dir" ] || [ ! -d "$repos_dir" ]; then
  echo "  REPOS_DIR fehlt oder existiert nicht: uebersprungen."
  exit 0
fi
dst="$repos_dir/.luarc.jsonc"
if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
  echo "  Bereits aktuell: $dst"
  exit 0
fi
if [ -e "$dst" ]; then
  # %N is GNU-only; $$ keeps two runs in the same second apart elsewhere
  backup="$dst.bak-$(date +%Y%m%d-%H%M%S)-$$"
  mv "$dst" "$backup" || exit 1
  echo "  Bestehende Datei gesichert nach: $backup"
fi
cp "$src" "$dst" || exit 1
echo "  Kopiert: $dst"
