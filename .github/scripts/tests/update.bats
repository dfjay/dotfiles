setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export SCRIPT="$SCRIPT_DIR/nixpkgs-darwin-update.sh"
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
