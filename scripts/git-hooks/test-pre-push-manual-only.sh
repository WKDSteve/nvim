#!/usr/bin/env bash
# test-pre-push-manual-only.sh -- scenario test for pre-push-manual-only.sh.
#
#   bash scripts/git-hooks/test-pre-push-manual-only.sh
#
# Builds a throwaway repo with a local bare remote, installs the hook and checks what
# reaches the remote. Terminal answers come from a file via MANUAL_PUSH_TTY, Neovim
# answers from a fake nvim-ask via MANUAL_PUSH_NVIM_ASK.

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(mktemp -d)"
trap 'rm -rf "$root"' EXIT
fails=0

check() { # check <description> <command...>
  local what="$1"
  shift
  if "$@"; then echo "ok   $what"; else echo "FAIL $what"; fails=$((fails + 1)); fi
}
not() { ! "$@"; }
# Nobody to ask unless a case says so: no real terminal, no real Neovim.
export MANUAL_PUSH_TTY=/nonexistent
unset NVIM NVIM_ASK MANUAL_PUSH_NVIM_ASK

git init -q --bare "$root/remote.git"
repo="$root/repo"
mkdir -p "$repo" && cd "$repo" && git init -q -b main && git config user.email t@t && git config user.name t
git remote add origin "$root/remote.git"
bash "$here/install.sh" --manual-push-only . >/dev/null

remote_head() { git --git-dir="$root/remote.git" rev-parse -q --verify refs/heads/main 2>/dev/null; }
commit() { echo "$1" >>f.txt && git add f.txt && git commit -qm "$1"; }
pushed() { [ "$(remote_head)" = "$(git rev-parse HEAD)" ]; }

check "install: only a pre-push hook" test -f .git/hooks/pre-push
check "install: no pre-commit hook" not test -f .git/hooks/pre-commit
check "install: hook carries the marker" grep -q "# manual-push-hook" .git/hooks/pre-push

# Nobody to ask: refused, the remote stays empty.
commit one
git push -q origin main 2>"$root/err" </dev/null
check "no channel: push refused" not pushed
check "no channel: remote untouched" test -z "$(remote_head)"
check "no channel: says how to push by hand" grep -q "no-verify" "$root/err"

# Terminal answers no, nothing, yes.
printf 'n\n' >"$root/tty"
MANUAL_PUSH_TTY="$root/tty" git push -q origin main 2>/dev/null </dev/null
check "tty 'n': push refused" not pushed
: >"$root/tty"
MANUAL_PUSH_TTY="$root/tty" git push -q origin main 2>/dev/null </dev/null
check "tty empty answer: push refused (default no)" not pushed
printf 'y\n' >"$root/tty"
MANUAL_PUSH_TTY="$root/tty" git push -q origin main 2>"$root/err" </dev/null
check "tty 'y': pushed" pushed
check "tty: the question lists the commit" grep -q "one" "$root/err"

# Neovim answers (fake nvim-ask prints the chosen button).
printf '#!/usr/bin/env bash\necho "Do not push"\n' >"$root/ask-no"
printf '#!/usr/bin/env bash\necho "Push"\n' >"$root/ask-yes"
commit two
NVIM=fake MANUAL_PUSH_NVIM_ASK="$root/ask-no" git push -q origin main 2>/dev/null </dev/null
check "nvim 'Do not push': push refused" not pushed
NVIM=fake MANUAL_PUSH_NVIM_ASK="$root/ask-yes" git push -q origin main 2>/dev/null </dev/null
check "nvim 'Push': pushed" pushed

# --no-verify is the deliberate way past the question.
commit three
git push -q --no-verify origin main 2>/dev/null </dev/null
check "--no-verify: pushed without a question" pushed

# A pre-push hook that is not ours stays.
other="$root/other"
mkdir -p "$other" && cd "$other" && git init -q
printf '#!/bin/sh\nexit 0\n' >.git/hooks/pre-push
bash "$here/install.sh" --manual-push-only . >/dev/null 2>&1
check "foreign pre-push: left alone" not grep -q "manual-push-hook" .git/hooks/pre-push

echo
[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
exit "$fails"
