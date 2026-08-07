#!/usr/bin/env bash
# Updates darwin-only nixpkgs packages, builds them, pushes branches to the fork.
set -uo pipefail

SEP=$'\x1f'

resolve_packages() {
  if [ -n "${PACKAGES:-}" ]; then
    # shellcheck disable=SC2086  # word splitting is intentional here
    printf '%s\n' ${PACKAGES}
    return 0
  fi
  [ -f "${LIST_FILE:-}" ] || return 0
  sed -e 's/#.*//' "$LIST_FILE" | tr -d '[:blank:]' | grep -v '^$' || true
}

report() {
  printf '%s\n' "$1$SEP$2$SEP$3$SEP$4$SEP$5$SEP$6" >> "$REPORT_FILE"
}

parse_bump() {
  local attr="$1" subject="$2"
  [[ "$subject" =~ ^"$attr":\ (.+)\ -\>\ (.+)$ ]] || return 1
  printf '%s\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
}

classify_update_failure() {
  if grep -q 'does not have a .passthru.updateScript' "$1"; then
    echo no-update-script
  else
    echo build-failed
  fi
}

has_open_pr() {
  local attr="$1" count
  count="$(GH_TOKEN="" GITHUB_TOKEN="" gh api -X GET search/issues \
             -f q="repo:NixOS/nixpkgs is:pr is:open in:title ${attr}" \
             --jq "[.items[] | select(.title | startswith(\"${attr}: \"))] | length" \
             2>/dev/null)" || return 2
  [[ "$count" =~ ^[0-9]+$ ]] || return 2
  [ "$count" -gt 0 ]
}

publish_branch() {
  local attr="$1" old="$2" new="$3" branch="$4" warn="${5:-}"

  # Never touch an existing branch: it may hold an unsent PR.
  if git -C "$NIXPKGS_DIR" ls-remote --exit-code --heads fork "$branch" >/dev/null 2>&1; then
    report branch-exists "$attr" "$old" "$new" "$branch" "branch already in the fork"
    return 0
  fi

  if [ "${DRY_RUN:-1}" = "1" ]; then
    report updated "$attr" "$old" "$new" "$branch" "${warn:+$warn; }dry run, not pushed"
    return 0
  fi

  git -C "$NIXPKGS_DIR" branch -f "$branch" HEAD
  if ! git -C "$NIXPKGS_DIR" push fork "$branch" >/dev/null 2>&1; then
    report push-failed "$attr" "$old" "$new" "$branch" "the package built, but the push to the fork failed"
    return 0
  fi
  report updated "$attr" "$old" "$new" "$branch" "$warn"
}

process_package() {
  local attr="$1"
  local before after subject old new branch warn=""

  has_open_pr "$attr"
  case $? in
    0)
      report pr-exists "$attr" "" "" "" "a PR is already open in NixOS/nixpkgs"
      return 0
      ;;
    2)
      warn="could not check upstream for a duplicate PR"
      ;;
  esac

  before="$(git -C "$NIXPKGS_DIR" rev-parse HEAD)"

  if ! ( cd "$NIXPKGS_DIR" && nix-shell maintainers/scripts/update.nix \
           --argstr package "$attr" --arg commit true --arg skip-prompt true ) \
         > "/tmp/update-${attr}.log" 2>&1; then
    case "$(classify_update_failure "/tmp/update-${attr}.log")" in
      no-update-script)
        report no-update-script "$attr" "" "" "" "no passthru.updateScript"
        ;;
      *)
        report build-failed "$attr" "" "" "" "update.nix failed: $(tail -n 1 "/tmp/update-${attr}.log")"
        ;;
    esac
    return 0
  fi

  after="$(git -C "$NIXPKGS_DIR" rev-parse HEAD)"
  if [ "$before" = "$after" ]; then
    report up-to-date "$attr" "" "" "" ""
    return 0
  fi

  subject="$(git -C "$NIXPKGS_DIR" log -1 --format=%s)"
  if ! IFS=$'\t' read -r old new < <(parse_bump "$attr" "$subject"); then
    report build-failed "$attr" "" "" "" "unexpected commit subject: ${subject}"
    return 0
  fi

  branch="auto-update/${attr}-${new}"

  if ! nix-build "$NIXPKGS_DIR" -A "$attr" --no-out-link > "/tmp/build-${attr}.log" 2>&1; then
    report build-failed "$attr" "$old" "$new" "" "$(tail -n 1 "/tmp/build-${attr}.log")"
    return 0
  fi

  publish_branch "$attr" "$old" "$new" "$branch" "$warn"
}

main() {
  : "${NIXPKGS_DIR:?NIXPKGS_DIR is not set}"
  : "${REPORT_FILE:?REPORT_FILE is not set}"
  : > "$REPORT_FILE"

  local base_rev attr
  base_rev="$(git -C "$NIXPKGS_DIR" rev-parse HEAD)"

  while read -r attr; do
    [ -n "$attr" ] || continue
    echo "::group::$attr"
    process_package "$attr"

    git -C "$NIXPKGS_DIR" reset --hard "$base_rev" >/dev/null
    echo "::endgroup::"
  done < <(resolve_packages)

  echo "=== report ==="
  cat "$REPORT_FILE"
}

# --source-only lets the tests load the functions without running main.
if [ "${1:-}" != "--source-only" ]; then
  main "$@"
fi
