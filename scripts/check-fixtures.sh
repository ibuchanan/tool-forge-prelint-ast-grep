#!/usr/bin/env sh
set -eu

FIXTURE_DIR="rule-tests/fixtures/repo-init-forge-app"
OUTPUT=$(ast-grep scan --config sgconfig.ecosol.yml "$FIXTURE_DIR")

if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT"
  echo
  echo "$FIXTURE_DIR is meant to model a fully repo-init-compliant Forge app and" >&2
  echo "should produce zero ecosol findings. See the output above for what drifted." >&2
  exit 1
fi

echo "$FIXTURE_DIR produced zero ecosol findings, as expected."
