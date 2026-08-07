setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export SCRIPT="$SCRIPT_DIR/nixpkgs-darwin-update.sh"
  export SYNC="$SCRIPT_DIR/sync-update-issue.sh"
  export LIST_FILE="$BATS_TEST_TMPDIR/list.txt"
  # Same separator the scripts use.
  SEP=$'\x1f'
}

@test "resolve_packages: reads the file, drops comments and blank lines" {
  printf '# a comment\nlulu\n\nsoundsource   # inline\n' > "$LIST_FILE"
  PACKAGES="" run bash -c 'source "$SCRIPT" --source-only; resolve_packages'
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "lulu" ]
  [ "${lines[1]}" = "soundsource" ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "resolve_packages: PACKAGES overrides the file" {
  printf 'lulu\nsoundsource\n' > "$LIST_FILE"
  PACKAGES="mos iina" run bash -c 'source "$SCRIPT" --source-only; resolve_packages'
  [ "${lines[0]}" = "mos" ]
  [ "${lines[1]}" = "iina" ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "parse_bump: extracts both versions from a commit subject" {
  run bash -c 'source "$SCRIPT" --source-only; parse_bump lulu "lulu: 4.3.1 -> 4.4.3"'
  [ "$status" -eq 0 ]
  [ "$output" = "4.3.1	4.4.3" ]
}

@test "parse_bump: rejects an unrelated subject" {
  run bash -c 'source "$SCRIPT" --source-only; parse_bump lulu "treewide: fix something"'
  [ "$status" -ne 0 ]
}

@test "report: writes exactly six separated columns" {
  export REPORT_FILE="$BATS_TEST_TMPDIR/report"
  : > "$REPORT_FILE"
  bash -c 'source "$SCRIPT" --source-only; report updated lulu 4.3.1 4.4.3 auto-update/lulu-4.4.3 ""'
  run cat "$REPORT_FILE"
  [ "$output" = "updated${SEP}lulu${SEP}4.3.1${SEP}4.4.3${SEP}auto-update/lulu-4.4.3${SEP}" ]
}

@test "report: an empty middle column survives a write/read round trip" {
  export REPORT_FILE="$BATS_TEST_TMPDIR/report"
  : > "$REPORT_FILE"
  bash -c 'source "$SCRIPT" --source-only; report build-failed mos 1.0 1.1 "" "hash mismatch"'
  IFS="$SEP" read -r status attr old new branch detail < "$REPORT_FILE"
  [ "$status" = "build-failed" ]
  [ "$attr" = "mos" ]
  [ "$old" = "1.0" ]
  [ "$new" = "1.1" ]
  [ "$branch" = "" ]
  [ "$detail" = "hash mismatch" ]
}

@test "report: a row warning is prefixed onto the detail" {
  export REPORT_FILE="$BATS_TEST_TMPDIR/report"
  : > "$REPORT_FILE"
  bash -c 'source "$SCRIPT" --source-only; ROW_WARNING="check failed"; report push-failed mos 1.0 1.1 b "push denied"'
  IFS="$SEP" read -r _ _ _ _ _ detail < "$REPORT_FILE"
  [ "$detail" = "check failed; push denied" ]
}

# Verbatim shape of a real update.nix failure log, banners and all.
@test "log_reason: prefers the real cause over update.nix banners and git housekeeping" {
  cat > "$BATS_TEST_TMPDIR/log" <<'EOF'
Enqueuing group of 1 packages
 - soundsource-6.1.0: UPDATING ...
 - soundsource-6.1.0: ERROR

--- SHOWING ERROR LOG FOR soundsource-6.1.0 ----------------------

soundsource: unexpected Wayback Machine response: 'https://web.archive.org/save/x'


--- SHOWING ERROR LOG FOR soundsource-6.1.0 ----------------------
The update script for soundsource-6.1.0 failed with exit code 1
Deleted branch update-tmpqnbb0u3_ (was 1f5a62ea0071).
EOF
  run bash -c "source \"\$SCRIPT\" --source-only; log_reason \"$BATS_TEST_TMPDIR/log\""
  [ "$output" = "soundsource: unexpected Wayback Machine response: 'https://web.archive.org/save/x'" ]
}

@test "log_reason: falls back to the last real line when nothing looks like an error" {
  printf 'building\nHEAD is now at ac858eb\nsomething happened\nDeleted branch update-tmpabc (was ac858eb).\n' > "$BATS_TEST_TMPDIR/log"
  run bash -c "source \"\$SCRIPT\" --source-only; log_reason \"$BATS_TEST_TMPDIR/log\""
  [ "$output" = "something happened" ]
}

@test "log_reason: strips the field separator so a detail cannot corrupt the report" {
  printf 'error: bad\x1fthing happened\n' > "$BATS_TEST_TMPDIR/log"
  run bash -c "source \"\$SCRIPT\" --source-only; log_reason \"$BATS_TEST_TMPDIR/log\""
  [ "$output" = "error: badthing happened" ]
}

@test "state_changed: the same table is not news" {
  local t='| `lulu` | 4.3.1 → 4.5.1 | built | [open PR](x) |'
  run bash -c "source \"\$SYNC\" --source-only; state_changed '$t' '$t'"
  [ "$status" -ne 0 ]
}

@test "state_changed: only the run-log footer moving is not news" {
  run bash -c "source \"\$SYNC\" --source-only; state_changed 'row' \$'row\n\n[Run log](https://x/1)'"
  [ "$status" -ne 0 ]
}

@test "state_changed: a new row is news" {
  run bash -c "source \"\$SYNC\" --source-only; state_changed 'row' \$'row\nsecond row'"
  [ "$status" -eq 0 ]
}

fake_gh() {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  {
    echo '#!/usr/bin/env bash'
    echo "printf '%s' \"\$FAKE_GH_OUT\""
    echo 'exit ${FAKE_GH_RC}'
  } > "$BATS_TEST_TMPDIR/bin/gh"
  chmod +x "$BATS_TEST_TMPDIR/bin/gh"
  export FAKE_GH_OUT="$1" FAKE_GH_RC="$2"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

@test "has_open_pr: a matching upstream PR is found" {
  fake_gh 1 0
  run bash -c 'source "$SCRIPT" --source-only; has_open_pr lulu'
  [ "$status" -eq 0 ]
}

@test "has_open_pr: no matching PR is a clean negative" {
  fake_gh 0 0
  run bash -c 'source "$SCRIPT" --source-only; has_open_pr lulu'
  [ "$status" -eq 1 ]
}

@test "has_open_pr: a failed query is not reported as no PR" {
  fake_gh "" 1
  run bash -c 'source "$SCRIPT" --source-only; has_open_pr lulu'
  [ "$status" -eq 2 ]
}

@test "has_open_pr: a non-numeric answer is not reported as no PR" {
  fake_gh "gateway timeout" 0
  run bash -c 'source "$SCRIPT" --source-only; has_open_pr lulu'
  [ "$status" -eq 2 ]
}

@test "classify_update_failure: an absent updateScript is reported as such" {
  printf 'error: Package with an attribute name `mos` does not have a `passthru.updateScript` attribute defined.\n' > "$BATS_TEST_TMPDIR/log"
  run bash -c "source \"\$SCRIPT\" --source-only; classify_update_failure \"$BATS_TEST_TMPDIR/log\""
  [ "$output" = "no-update-script" ]
}

@test "classify_update_failure: a failing updateScript is not mistaken for an absent one" {
  printf 'soundsource: unexpected Wayback Machine response\nThe update script for soundsource-6.1.0 failed with exit code 1\n' > "$BATS_TEST_TMPDIR/log"
  run bash -c "source \"\$SCRIPT\" --source-only; classify_update_failure \"$BATS_TEST_TMPDIR/log\""
  [ "$output" = "build-failed" ]
}

@test "render: emits a table with a compare link" {
  printf 'updated%slulu%s4.3.1%s4.4.3%sauto-update/lulu-4.4.3%s\n' "$SEP" "$SEP" "$SEP" "$SEP" "$SEP" > "$BATS_TEST_TMPDIR/report"
  run bash "$SCRIPT_DIR/render-update-report.sh" "$BATS_TEST_TMPDIR/report"
  [ "$status" -eq 0 ]
  [[ "$output" == *"4.3.1 → 4.4.3"* ]]
  [[ "$output" == *"https://github.com/NixOS/nixpkgs/compare/master...dfjay:nixpkgs:auto-update/lulu-4.4.3?expand=1"* ]]
}

@test "render: build-failed row keeps its detail and carries no compare link" {
  printf 'build-failed%smos%s1.0%s1.1%s%shash mismatch\n' "$SEP" "$SEP" "$SEP" "$SEP" "$SEP" > "$BATS_TEST_TMPDIR/report"
  run bash "$SCRIPT_DIR/render-update-report.sh" "$BATS_TEST_TMPDIR/report"
  [[ "$output" == *"hash mismatch"* ]]
  [[ "$output" != *"compare/master"* ]]
}

@test "render: push-failed is not reported as a build failure" {
  printf 'push-failed%smos%s1.0%s1.1%sauto-update/mos-1.1%sthe package built, but the push to the fork failed\n' "$SEP" "$SEP" "$SEP" "$SEP" "$SEP" > "$BATS_TEST_TMPDIR/report"
  run bash "$SCRIPT_DIR/render-update-report.sh" "$BATS_TEST_TMPDIR/report"
  [ "$status" -eq 0 ]
  [[ "$output" == *"push failed"* ]]
  [[ "$output" != *"build failed"* ]]
  [[ "$output" != *"compare/master"* ]]
}

@test "render: up-to-date only produces empty output" {
  printf 'up-to-date%ssoundsource%s6.1.0%s%s%s\n' "$SEP" "$SEP" "$SEP" "$SEP" "$SEP" > "$BATS_TEST_TMPDIR/report"
  run bash "$SCRIPT_DIR/render-update-report.sh" "$BATS_TEST_TMPDIR/report"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "render: missing file produces empty output and exit 0" {
  run bash "$SCRIPT_DIR/render-update-report.sh" "$BATS_TEST_TMPDIR/nope"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
