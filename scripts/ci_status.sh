#!/usr/bin/env bash
# Per-platform CI verdict for every repo, in one table.
#
# A thin wrapper around testing.nvim's CI adapter (`testing ci remote`, see
# testing.nvim/docs/CI.md): owner/repo from `origin`, the commit from
# `origin/main`, only the workflow "CI", a run without jobs is a rejected
# workflow file. No GitHub logic of its own lives here any more.
#
# Usage:
#   scripts/ci_status.sh              # every repo under $REPOS_DIR
#   scripts/ci_status.sh markdown     # only repos whose name matches
#   scripts/ci_status.sh --red        # only repos that are not fully green
#
# Exit code of `testing ci remote`: 0 all green, 1 at least one red, 3 unknown.
# Token: TESTING_GITHUB_TOKEN, else `gh auth token`.
set -u

repos="${REPOS_DIR:-/e/repos}"
testing="${TESTING_NVIM_DIR:-$repos/testing.nvim}/scripts/testing.lua"
[ -f "$testing" ] || { echo "ci_status.sh: $testing not found (set TESTING_NVIM_DIR)" >&2; exit 2; }

red=0
filter=""
for a in "$@"; do
  case "$a" in
    --red) red=1 ;;
    *) filter="$a" ;;
  esac
done

out=$(nvim --headless -u NONE -l "$testing" ci remote --repos-root="$repos" 2>&1)
code=$?
header=$(printf '%s\n' "$out" | head -1)
rows=$(printf '%s\n' "$out" | tail -n +2)
[ -n "$filter" ] && rows=$(printf '%s\n' "$rows" | grep -i -- "$filter")
[ "$red" = 1 ] && rows=$(printf '%s\n' "$rows" | grep -E 'FAIL|failure|unknown|pending' )
printf '%s\n' "$header"
[ -n "$rows" ] && printf '%s\n' "$rows"
exit "$code"
