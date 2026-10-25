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

# Catalog seed values are examples, not a frozen title, lifecycle or year policy.
DROP_CALF_CATALOG="fixtures/drop-calf-forge-app/catalog-info.yaml"
if [ ! -f "$DROP_CALF_CATALOG" ]; then
  echo "Missing Drop Calf fixture: $DROP_CALF_CATALOG" >&2
  exit 1
fi
catalog_findings=$(ast-grep scan --config sgconfig.ecosol.yml \
  --filter '^require-catalog-' --json=compact "$DROP_CALF_CATALOG")
if ! printf '%s\n' "$catalog_findings" | jq -e 'type == "array" and length == 0' >/dev/null; then
  echo "Generated Drop Calf catalog must pass catalog convention checks: $catalog_findings" >&2
  exit 1
fi
echo "$DROP_CALF_CATALOG produced zero catalog convention findings."

# Package metadata maps existing policies without freezing catalog identity or version.
DROP_CALF_PACKAGE="fixtures/drop-calf-forge-app/package.json"
mkdir -p .scratch
package_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_package_metadata.XXXXXX")
for variant in generated commonjs missing-type public missing-private owner-metadata; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  commonjs)
    edit='.type = "commonjs"'
    expected='require-package-type-module'
    ;;
  missing-type)
    edit='del(.type)'
    expected='require-package-type-module'
    ;;
  public)
    edit='.private = false'
    expected='require-package-private-true'
    ;;
  missing-private)
    edit='del(.private)'
    expected='require-package-private-true'
    ;;
  owner-metadata) edit='.name = "@example/custom-app" | .version = "2.3.4-beta.1" | .description = "Owner-authored description" | del(.author)' ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$package_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-package-(type-module|private-true)$' \
    --json=compact "$package_work/package.json")
  actual=$(printf '%s\n' "$findings" | jq -r '.[].ruleId' | sort)
  if [ "$actual" != "$expected" ]; then
    printf 'Unexpected package metadata findings for %s: expected "%s", got "%s"\n' \
      "$variant" "$expected" "$actual" >&2
    exit 1
  fi
done
echo "$DROP_CALF_PACKAGE and metadata mutations produced the expected findings."

# OSS consumes catalog licensing; Node derives the independently checked package field.
oss_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_oss.XXXXXX")
for variant in generated catalog-license package-license; do
  cp "$DROP_CALF_CATALOG" "$oss_work/catalog-info.yaml"
  cp "$DROP_CALF_PACKAGE" "$oss_work/package.json"
  expected=''
  case "$variant" in
  catalog-license)
    yq -i '.metadata.annotations."forge-ranch/license" = "MIT"' "$oss_work/catalog-info.yaml"
    expected='require-catalog-license-apache-2-0'
    ;;
  package-license)
    jq '.license = "MIT"' "$DROP_CALF_PACKAGE" >"$oss_work/package.json"
    expected='require-package-license-apache-2-0'
    ;;
  esac
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-(catalog|package)-license-apache-2-0$' \
    --json=compact "$oss_work")
  actual=$(printf '%s\n' "$findings" | jq -r '.[].ruleId' | sort)
  if [ "$actual" != "$expected" ]; then
    printf 'Unexpected OSS findings for %s: expected "%s", got "%s"\n' \
      "$variant" "$expected" "$actual" >&2
    exit 1
  fi
done
echo "Generated OSS licensing inputs and independent mutations produced the expected findings."

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

sh scripts/check-security-fixtures.sh
bash scripts/check-scope-fixtures.sh
bash scripts/check-page-title-fixtures.sh
