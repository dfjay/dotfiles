#!/usr/bin/env bash
# Keeps one tracking issue in sync with the latest report: the body always
# holds the current state, and a comment is posted only when that state
# changed, so an unchanged week is silent.
set -uo pipefail

TITLE="${ISSUE_TITLE:-Darwin auto-update: branches ready for PR}"
PING="${ISSUE_PING:-@dfjay}"

state_of() {
  grep -vE '^\[Run log\]|^[[:space:]]*$' || true
}

state_changed() {
  [ "$(printf '%s\n' "$1" | state_of)" != "$(printf '%s\n' "$2" | state_of)" ]
}

REPO="${GITHUB_REPOSITORY:-}"

open_issue_number() {
  gh issue list --repo "$REPO" --state open --limit 50 --json number,title \
    --jq "[.[] | select(.title == \"$TITLE\")][0].number // empty"
}

main() {
  local body_file="${1:?usage: sync-update-issue.sh <body file>}"
  local number new_body old_body
  : "${REPO:?GITHUB_REPOSITORY is not set}"
  number="$(open_issue_number)"
  new_body="$(cat "$body_file" 2>/dev/null)"

  if [ -z "$(printf '%s\n' "$new_body" | state_of)" ]; then
    [ -n "$number" ] || return 0
    gh issue comment "$number" --repo "$REPO" --body "Nothing left to send. Closing until the next find."
    gh issue close "$number" --repo "$REPO"
    return 0
  fi

  if [ -z "$number" ]; then
    gh issue create --repo "$REPO" --title "$TITLE" --body "$new_body"
    return 0
  fi

  old_body="$(gh issue view "$number" --repo "$REPO" --json body --jq .body)"
  gh issue edit "$number" --repo "$REPO" --body "$new_body"

  if state_changed "$old_body" "$new_body"; then
    gh issue comment "$number" --repo "$REPO" --body "$PING this changed:

$new_body"
  fi
}

if [ "${1:-}" != "--source-only" ]; then
  main "$@"
fi
