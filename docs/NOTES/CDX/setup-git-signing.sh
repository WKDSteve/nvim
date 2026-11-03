#!/usr/bin/env bash
# Commit signing of this device and its entry in the device registry (git-allowed-signers).
# Idempotent; called by setup-claude-code.sh, also runnable on its own. See setup-git-signing.ps1 for the why.
# The variable TESTING_ALLOWED_SIGNERS is only printed here: add it to your shell profile.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIGNERS="$SCRIPT_DIR/git-allowed-signers"
KEY="$HOME/.ssh/git-signing_ed25519"
DEVICE="$(hostname -s 2>/dev/null || hostname)"

if ! command -v ssh-keygen > /dev/null 2>&1; then
  echo "  ssh-keygen fehlt (OpenSSH-Client): Signatur nicht eingerichtet."
  exit 1
fi

if [ ! -f "$KEY" ]; then
  mkdir -p "$(dirname "$KEY")"
  ssh-keygen -q -t ed25519 -N "" -C "git-signing@$DEVICE" -f "$KEY"
  echo "  Signing-Key erzeugt: $KEY"
else
  echo "  Signing-Key vorhanden: $KEY"
fi

git config --global gpg.format ssh
git config --global user.signingkey "$KEY.pub"
git config --global commit.gpgsign true
git config --global gpg.ssh.allowedSignersFile "$SIGNERS"
echo "  git signiert Commits (gpg.format ssh, commit.gpgsign true)."

read -r KTYPE KBLOB _ < "$KEY.pub"
EMAIL="$(git config --global user.email || echo unknown)"
if [ -f "$SIGNERS" ] && grep -qF "$KBLOB" "$SIGNERS"; then
  echo "  $DEVICE steht bereits in der Registry."
else
  printf '%s,%s namespaces="git" %s %s %s\n' "$DEVICE" "$EMAIL" "$KTYPE" "$KBLOB" "$DEVICE" >> "$SIGNERS"
  echo "  $DEVICE in die Registry eingetragen: $SIGNERS"
  echo "  -> nvim-Config committen und pushen; auf dem Runner-Rechner pullen."
fi

if [ "${TESTING_ALLOWED_SIGNERS:-}" != "$SIGNERS" ]; then
  echo "  Fuer den Runner-Rechner ins Shell-Profil: export TESTING_ALLOWED_SIGNERS=\"$SIGNERS\""
fi
