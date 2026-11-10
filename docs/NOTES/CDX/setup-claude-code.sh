#!/usr/bin/env bash
# Richtet Claude Code auf dieser Maschine (Linux/macOS) gemaess der in
# diesem Ordner versionierten Vorlagen ein (Env-Vars, ~/.claude/CLAUDE.md,
# ~/.claude/settings.json). Idempotent - nach jedem Pull erneut ausfuehrbar.
# Windows-Pendant: setup-claude-code.ps1
#
# Usage: ./setup-claude-code.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# CDX -> NOTES -> docs -> nvim-config-root. Always derived from this script's location, never taken
# from the environment (an inherited NVIM_CONFIG_DIR may point at another checkout).
NVIM_CONFIG_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "NVIM_CONFIG_DIR = $NVIM_CONFIG_DIR"

# --- 1. Env-Variablen -------------------------------------------------------

echo
echo "[1/3] Env-Variablen"

mkdir -p "$CLAUDE_DIR"
ENV_FILE="$CLAUDE_DIR/env.sh"

REPOS_DIR_VALUE="${REPOS_DIR:-}"
if [ -z "$REPOS_DIR_VALUE" ] && [ -f "$ENV_FILE" ]; then
  REPOS_DIR_VALUE="$(sed -n 's/^export REPOS_DIR="\(.*\)"$/\1/p' "$ENV_FILE" | tail -1)"
fi
if [ -z "$REPOS_DIR_VALUE" ]; then
  while true; do
    read -r -p "  REPOS_DIR ist auf dieser Maschine nicht gesetzt. Pfad zur Repos-Wurzel eingeben (z.B. /home/user/repos): " REPOS_DIR_VALUE
    if [ -n "$REPOS_DIR_VALUE" ] && [ -d "$REPOS_DIR_VALUE" ]; then
      break
    fi
    echo "  Pfad '$REPOS_DIR_VALUE' existiert nicht - bitte erneut eingeben."
  done
  echo "  REPOS_DIR gesetzt: $REPOS_DIR_VALUE"
else
  echo "  REPOS_DIR bereits gesetzt: $REPOS_DIR_VALUE"
fi

# A variable the setup keeps once it is set: this shell first, then the env file of the last run.
known_value() {
  local value="${!1:-}"
  if [ -z "$value" ] && [ -f "$ENV_FILE" ]; then
    value="$(sed -n "s/^export $1=\"\(.*\)\"$/\1/p" "$ENV_FILE" | tail -1)"
  fi
  printf '%s' "$value"
}

# TESTING_TRUST_ROOTS: testing.nvim runs a project's .testing.lua only once it is trusted. Without it local runs end
# with exit 2, and so does the pre-push gate of tasks-vault below, for every push. A list that is set stays.
TRUST_ROOTS_VALUE="$(known_value TESTING_TRUST_ROOTS)"
TRUST_ROOTS_VALUE="${TRUST_ROOTS_VALUE:-$REPOS_DIR_VALUE}"

# RULES_VAULT, TASKS_VAULT: roots of the repos of the same name, as in setup-claude-code.ps1.
RULES_VAULT_VALUE="$(known_value RULES_VAULT)"
if [ -z "$RULES_VAULT_VALUE" ] && [ -d "$REPOS_DIR_VALUE/rules-vault" ]; then
  RULES_VAULT_VALUE="$REPOS_DIR_VALUE/rules-vault"
fi
TASKS_VAULT_VALUE="$(known_value TASKS_VAULT)"
if [ -z "$TASKS_VAULT_VALUE" ] && [ -d "$REPOS_DIR_VALUE/tasks-vault" ]; then
  TASKS_VAULT_VALUE="$REPOS_DIR_VALUE/tasks-vault"
fi

cat > "$ENV_FILE" <<EOF
# Generiert von setup-claude-code.sh - nicht von Hand editieren.
export NVIM_CONFIG_DIR="$NVIM_CONFIG_DIR"
# Alter Name, fuer aeltere Skripte/Notizen weiter gesetzt.
export NVIM_CONFIG="$NVIM_CONFIG_DIR"
export REPOS_DIR="$REPOS_DIR_VALUE"
export TESTING_TRUST_ROOTS="$TRUST_ROOTS_VALUE"
EOF
if [ -n "$RULES_VAULT_VALUE" ]; then
  echo "export RULES_VAULT=\"$RULES_VAULT_VALUE\"" >> "$ENV_FILE"
else
  echo "  RULES_VAULT nicht gesetzt und $REPOS_DIR_VALUE/rules-vault fehlt: Repo rules-vault klonen, dann das Skript erneut ausfuehren."
fi
if [ -n "$TASKS_VAULT_VALUE" ]; then
  echo "export TASKS_VAULT=\"$TASKS_VAULT_VALUE\"" >> "$ENV_FILE"
else
  echo "  TASKS_VAULT nicht gesetzt und $REPOS_DIR_VALUE/tasks-vault fehlt: Repo tasks-vault klonen, dann das Skript erneut ausfuehren."
fi
echo "  $ENV_FILE geschrieben."

# NVIM_MACHINE_ROLE (workstation | nicht gesetzt = privater Rechner) wird hier nicht gesetzt, nur angezeigt:
# lua/machine.lua der nvim-Config und die Claude-Regeln lesen sie. Gleiche Auswertung wie machine.lua (lower()).
MACHINE_ROLE="$(printf '%s' "${NVIM_MACHINE_ROLE:-}" | tr '[:upper:]' '[:lower:]')"
case "$MACHINE_ROLE" in
  workstation) echo "  Maschine: workstation (NVIM_MACHINE_ROLE)" ;;
  "") echo "  Maschine: privater Rechner (NVIM_MACHINE_ROLE nicht gesetzt)" ;;
  default) echo "  Maschine: privater Rechner (NVIM_MACHINE_ROLE=default)" ;;
  *) echo "  Maschine: unbekannte NVIM_MACHINE_ROLE '$NVIM_MACHINE_ROLE' - nvim nimmt 'default'; Tippfehler?" ;;
esac

SOURCE_LINE="[ -f \"$ENV_FILE\" ] && . \"$ENV_FILE\""
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$rc" ]; then
    if ! grep -qF "$ENV_FILE" "$rc"; then
      printf '\n# Claude Code env (siehe %s)\n%s\n' "$ENV_FILE" "$SOURCE_LINE" >> "$rc"
      echo "  Sourcing-Zeile ergaenzt in $rc"
    else
      echo "  $rc sourced $ENV_FILE bereits."
    fi
  fi
done

echo "  Hinweis: neue Shell starten (oder 'source $ENV_FILE'), damit die Env-Vars gelten."

# --- 2. ~/.claude/CLAUDE.md (Symlink, Fallback Kopie) -----------------------

echo
echo "[2/3] CLAUDE.md"

CLAUDE_MD_SOURCE="$SCRIPT_DIR/CLAUDE.global.md"
CLAUDE_MD_TARGET="$CLAUDE_DIR/CLAUDE.md"

if [ -L "$CLAUDE_MD_TARGET" ] && [ "$(readlink "$CLAUDE_MD_TARGET")" = "$CLAUDE_MD_SOURCE" ]; then
  echo "  Symlink bereits korrekt."
else
  if [ -e "$CLAUDE_MD_TARGET" ] || [ -L "$CLAUDE_MD_TARGET" ]; then
    backup="$CLAUDE_MD_TARGET.bak-$(date +%Y%m%d-%H%M%S%N)"
    mv "$CLAUDE_MD_TARGET" "$backup"
    echo "  Bestehende CLAUDE.md gesichert nach: $backup"
  fi
  ln -s "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
  echo "  Symlink angelegt: $CLAUDE_MD_TARGET -> $CLAUDE_MD_SOURCE"
fi

# --- 3. ~/.claude/settings.json (Merge, via gemeinsames Node-Skript) --------

echo
echo "[3/3] settings.json"

if ! command -v node > /dev/null 2>&1; then
  echo "  FEHLER: node nicht gefunden. Wird sowohl fuer den Merge als auch fuer" >&2
  echo "  check-lua-hook.js gebraucht - bitte Node.js installieren und Skript erneut ausfuehren." >&2
  exit 1
fi

node "$SCRIPT_DIR/merge-claude-settings.js" \
  "$SCRIPT_DIR/settings.global.json" \
  "$CLAUDE_DIR/settings.json" \
  "$NVIM_CONFIG_DIR"

echo
echo "[git] Globale Hooks"
HOOK_SRC="${REPOS_DIR_VALUE:+$REPOS_DIR_VALUE/tasks-vault/TOOLS/scripts/git-global-hooks}"
HOOK_DST="$HOME/.config/git/global-hooks"
if [ -z "$HOOK_SRC" ] || [ ! -d "$HOOK_SRC" ]; then
  echo "  Quelle fehlt (${HOOK_SRC:-REPOS_DIR unbekannt}): Repo tasks-vault klonen, dann das Skript erneut ausfuehren."
else
  mkdir -p "$HOOK_DST"
  cp "$HOOK_SRC"/* "$HOOK_DST/"
  chmod +x "$HOOK_DST"/*
  CURRENT_HOOKS="$(git config --global --get core.hooksPath || true)"
  if [ -z "$CURRENT_HOOKS" ]; then
    git config --global core.hooksPath "$HOOK_DST"
    echo "  core.hooksPath gesetzt: $HOOK_DST"
  elif [ "$CURRENT_HOOKS" = "$HOOK_DST" ]; then
    echo "  core.hooksPath bereits gesetzt."
  else
    echo "  core.hooksPath zeigt auf '$CURRENT_HOOKS' (fremd): nicht ueberschrieben."
  fi
  echo "  Hinweis: History-Rewrites brauchen ALLOW_FORCE_PUSH=1 (TOOLS/history-rewrite-runbook.md)."
fi

# merge=ours in .gitattributes (generated docs/map): git knows the driver only when it is configured per machine.
# Without it, pull --rebase --autostash conflicts as soon as a session has regenerated the map.
git config --global merge.ours.driver true
echo "  merge.ours.driver gesetzt."

# The pre-push of the vault lives in .git/hooks (not versioned, the global hook calls it): it checks the pushed commit
# on a snapshot, not the shared working tree. testing ci is refused on the workstation, the hook would block every push
# there. Same step as in setup-claude-code.ps1. A failure here only warns, under `set -e` too.
echo
echo "[git] pre-push-Gate von tasks-vault"
VAULT_ROOT="${REPOS_DIR_VALUE:+$REPOS_DIR_VALUE/tasks-vault}"
TESTING_DRIVER="${REPOS_DIR_VALUE:+$REPOS_DIR_VALUE/testing.nvim/scripts/testing.lua}"
if [ "$MACHINE_ROLE" = "workstation" ]; then
  echo "  Workstation: nicht installiert (dort prueft nur die CI)."
elif [ -z "$VAULT_ROOT" ] || [ ! -d "$VAULT_ROOT" ] || [ ! -f "$TESTING_DRIVER" ]; then
  echo "  tasks-vault oder testing.nvim fehlt unter '$REPOS_DIR_VALUE': klonen, dann das Skript erneut ausfuehren."
elif ! command -v nvim > /dev/null 2>&1; then
  echo "  nvim nicht auf dem PATH: Hook nicht installiert."
elif ! nvim -n -i NONE --headless -u NONE -l "$TESTING_DRIVER" ci hook install --run=fast --verify=fast --snapshot "--root=$VAULT_ROOT"; then
  echo "  Hook nicht installiert, siehe Ausgabe oben."
fi

echo
echo "[git] Commit-Signatur (Geraete-Registry fuer den runner-guard von testing.nvim)"
bash "$SCRIPT_DIR/setup-git-signing.sh" || echo "  Signatur nicht eingerichtet (siehe oben)."

echo
INSTALL_TOOLS="$SCRIPT_DIR/../../../scripts/install-tools/install-tools.sh"
echo "[optional] Dev-Toolchains (nvim/cpp/rust/web/tauri) installieren?"
if [ "$(printf '%s' "${NVIM_MACHINE_ROLE:-}" | tr '[:upper:]' '[:lower:]')" = "workstation" ]; then
  echo "  Workstation (EDR/Falcon): hier wird nichts installiert. Bewusst von Hand:"
  echo "  bash \"$INSTALL_TOOLS\" --profile <profile> --force"
else
  echo "  Was auf dieser Maschine schon da ist:"
  bash "$INSTALL_TOOLS" --status || true
  read -r -p "  Profile kommagetrennt (nvim,cpp,rust,web,tauri), all = alle, leer = ueberspringen: " PROFILES
  if [ -n "$PROFILES" ]; then
    bash "$INSTALL_TOOLS" --profile "$PROFILES" || true
  fi
  echo "  Die CLI-Tools der Plugins (pandoc, poppler, ImageMagick, ...) bringt nach dem Klonen der Repos:"
  echo "  bash \"$INSTALL_TOOLS\" --list   (dann ohne --list zum Installieren)"
fi

echo
echo "Fertig."
