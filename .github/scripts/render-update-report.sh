#!/usr/bin/env bash
# Report file -> markdown. Empty output means "nothing worth reporting".
set -uo pipefail

REPORT="${1:?usage: render-update-report.sh <report file>}"
FORK="${FORK_OWNER:-dfjay}"

SEP=$'\x1f'

[ -s "$REPORT" ] || exit 0

noteworthy="$(grep -Ev "^(up-to-date|pr-exists)${SEP}" "$REPORT" || true)"
[ -n "$noteworthy" ] || exit 0

printf '| Package | Version | Status | Action |\n'
printf '|---|---|---|---|\n'

printf '%s\n' "$noteworthy" | while IFS="$SEP" read -r status attr old new branch detail; do
  case "$status" in
    updated)
      # shellcheck disable=SC2016  # backticks are markdown code-span syntax, not command substitution
      printf '| `%s` | %s → %s | built | [open PR](https://github.com/NixOS/nixpkgs/compare/master...%s:nixpkgs:%s?expand=1) |\n' \
        "$attr" "$old" "$new" "$FORK" "$branch"
      ;;
    build-failed)
      # shellcheck disable=SC2016  # backticks are markdown code-span syntax, not command substitution
      printf '| `%s` | %s → %s | **build failed** | %s |\n' "$attr" "$old" "$new" "${detail:-see the run log}"
      ;;
    push-failed)
      # shellcheck disable=SC2016  # backticks are markdown code-span syntax, not command substitution
      printf '| `%s` | %s → %s | **push failed** | built fine; branch `%s` never reached the fork |\n' \
        "$attr" "$old" "$new" "$branch"
      ;;
    branch-exists)
      # shellcheck disable=SC2016  # backticks are markdown code-span syntax, not command substitution
      printf '| `%s` | %s → %s | branch already exists | PR from an earlier run was never sent |\n' "$attr" "$old" "$new"
      ;;
    no-update-script)
      # shellcheck disable=SC2016  # backticks are markdown code-span syntax, not command substitution
      printf '| `%s` | %s | skipped | no `passthru.updateScript` |\n' "$attr" "$old"
      ;;
  esac
done
