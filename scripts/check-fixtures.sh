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

# Drop Calf's default forge-app output is generated separately. Its Fence Rider
# migration findings are unresolved; check only the Biome contract here.
DROP_CALF_BIOME="fixtures/drop-calf-forge-app/biome.jsonc"
if [ ! -f "$DROP_CALF_BIOME" ]; then
  echo "Missing Drop Calf fixture: $DROP_CALF_BIOME" >&2
  exit 1
fi
if ! grep -Fq '"!!**/dist"' "$DROP_CALF_BIOME"; then
  echo "Expected a hard exclusion for nested dist in $DROP_CALF_BIOME" >&2
  exit 1
fi
matches=$(ast-grep scan --config sgconfig.ecosol.yml \
  --rule rules/ecosol/devtools/require-biome-files-exclude-dist.yml \
  --files-with-matches "$DROP_CALF_BIOME")
if [ -n "$matches" ]; then
  echo "Drop Calf's hard dist exclusion was flagged: $matches" >&2
  exit 1
fi
echo "$DROP_CALF_BIOME hard-excludes dist without a finding."

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
