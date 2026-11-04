#!/usr/bin/env bash
# pre-push-manual-only.sh -- a repo whose commits leave the machine only when a person
# pushes them by hand, after confirming. Committing stays free.
#
# For repos with customer data or work tasks (WKDBook-Tricentis, tricentis-vault): an
# agent, an editor plugin or a GUI client may commit there, but a push needs someone
# who answers the question below. The default answer is no.
#
# Who is asked:
#   * the terminal, when /dev/tty opens (Linux, macOS);
#   * else the Neovim the push runs under ($NVIM: a Neovim terminal, lazygit in Neovim),
#     as a dialog via lib.nvim's bin/nvim-ask. Git for Windows starts hooks without any
#     /dev/tty, so on Windows this is the only way to be asked;
#   * nobody (Claude's shell, a plugin job, a GUI, a plain Windows terminal): the push is
#     refused. Pushing by hand from there: git push --no-verify.
#
# MANUAL_PUSH_TTY and MANUAL_PUSH_NVIM_ASK exist for the scenario test only
# (test-pre-push-manual-only.sh); they are not a way around the question.
#
# Installed per repo by scripts/git-hooks/install.sh --manual-push-only, which writes a
# one-line .git/hooks/pre-push that calls this file.

remote="$1"
url="$2"
repo="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")"
zero="0000000000000000000000000000000000000000"

# What would leave: one block per pushed ref (stdin: <local ref> <local sha> <remote ref> <remote sha>).
summary=""
while read -r local_ref local_sha remote_ref remote_sha; do
  [ -z "$local_ref" ] && continue
  if [ "$local_sha" = "$zero" ]; then
    summary+="delete ${remote_ref}"$'\n'
  elif [ "$remote_sha" = "$zero" ]; then
    summary+="new ${remote_ref}: $(git rev-list --count "$local_sha" 2>/dev/null) commit(s)"$'\n'
    summary+="$(git log --oneline -n 5 "$local_sha" 2>/dev/null)"$'\n'
  else
    summary+="${remote_ref}: $(git rev-list --count "${remote_sha}..${local_sha}" 2>/dev/null) commit(s)"$'\n'
    summary+="$(git log --oneline -n 10 "${remote_sha}..${local_sha}" 2>/dev/null)"$'\n'
  fi
done
[ -z "$summary" ] && exit 0

refuse() {
  echo "pre-push: $repo is pushed only by hand, and nobody confirmed this push. Nothing was pushed." >&2
  echo "  By hand: git push in a Neovim terminal (asks), or deliberately: git push --no-verify" >&2
  exit 1
}

# Who answers: the terminal when /dev/tty opens, else the Neovim the push runs under.
channel=""
tty="${MANUAL_PUSH_TTY:-/dev/tty}"
if [ -r "$tty" ] && { exec 3<"$tty"; } 2>/dev/null; then
  channel=tty
elif [ -n "${NVIM:-}" ]; then
  nvim_ask="${MANUAL_PUSH_NVIM_ASK:-${NVIM_ASK:-$(command -v nvim-ask 2>/dev/null)}}"
  if [ -z "$nvim_ask" ]; then
    nvim_ask="$(nvim --clean --headless --server "$NVIM" --remote-expr \
      "luaeval('require(\"lib.nvim.terminal.ask\").script()')" 2>/dev/null)"
  fi
  [ -n "$nvim_ask" ] && [ -f "$nvim_ask" ] && channel=nvim
fi
[ -z "$channel" ] && refuse

question="$(printf 'Push %s to %s (%s)?\n%s' "$repo" "$remote" "$url" "$summary")"
if [ "$channel" = tty ]; then
  printf '%s\n' "$question" >&2
  printf 'Push? [y/N] ' >&2
  read -r answer <&3
  exec 3<&-
  case "$answer" in
    y | Y | yes | j | J | ja) exit 0 ;;
    *) refuse ;;
  esac
fi

answer="$(bash "$nvim_ask" --title " pre-push " --timeout "${MANUAL_PUSH_ASK_TIMEOUT:-300}" \
  "$question" "Do not push" "Push")"
[ "$answer" = "Push" ] && exit 0
refuse
