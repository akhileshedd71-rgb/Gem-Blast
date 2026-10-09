#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-godot}"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/gem-blast-tests.XXXXXX")"
trap 'rm -rf -- "$TEST_ROOT"' EXIT
export XDG_CONFIG_HOME="$TEST_ROOT/config"
export XDG_CACHE_HOME="$TEST_ROOT/cache"
export XDG_DATA_HOME="$TEST_ROOT/data"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
"$GODOT_BIN" --headless --path . --editor --import --quit
for suite in test_core test_ui test_save; do
  "$GODOT_BIN" --headless --path . --script "tests/$suite.gd" > "$TEST_ROOT/$suite.log" 2>&1 || {
    cat "$TEST_ROOT/$suite.log"
    exit 1
  }
  cat "$TEST_ROOT/$suite.log"
  if rg -q 'SCRIPT ERROR|^ERROR:' "$TEST_ROOT/$suite.log"; then exit 1; fi
done
