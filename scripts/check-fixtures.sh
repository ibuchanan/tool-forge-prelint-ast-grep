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

# Both Biome filenames must be parsed as JSON and checked by the same rule.
for path in rule-tests/fixtures/biome-invalid/biome.json rule-tests/fixtures/biome-invalid/biome.jsonc; do
  matches=$(ast-grep scan --config sgconfig.ecosol.yml \
    --rule rules/ecosol/devtools/require-biome-formatter-indent-style.yml \
    --files-with-matches "$path")
  if [ "$matches" != "$path" ]; then
    echo "Expected a Biome formatter finding in $path; got: $matches" >&2
    exit 1
  fi
done

echo "Both Biome config formats produced the expected finding."
