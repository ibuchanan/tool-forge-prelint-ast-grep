#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
# shellcheck source=scripts/rule-metadata-env.sh
source scripts/rule-metadata-env.sh
mkdir -p "$ROOT/.scratch"
WORK=$(mktemp -d "$ROOT/.scratch/tmp_rovo_metadata.XXXXXX")
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/a quoted ' workspace/rules/recommended/package-json"
RULE="$WORK/a quoted ' workspace/rules/recommended/package-json/example.yml"

cat >"$RULE" <<'YAML'
id: example
language: Json
severity: off
message: Keep this message.
note: Keep https://example.com/reference?q=one#two in prose.
rule: {kind: object}
files: ['**/package.json']
ignores: ['**/node_modules/**', '**/node_modules/**']
YAML
BEFORE=$(yq -o=json -I=0 'del(.metadata) | sort_keys(..)' "$RULE")
yq --from-file "$RULE_AUTHORING_DIR/recipes/category.yq" "$RULE" >"$WORK/preview"
[[ $(yq '.metadata.category' "$WORK/preview") == package-json ]]
[[ $(yq 'has("metadata")' "$RULE") == false ]]
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/category.yq" "$RULE"
[[ $(yq -o=json -I=0 'del(.metadata) | sort_keys(..)' "$RULE") == "$BEFORE" ]]
printf 'PASS: category preview/apply preserves native behavior in quoted paths\n'

expect_rejected() {
  local recipe=$1 path=$2 message=$3
  cp "$path" "$WORK/rejected-original"
  if yq -e -i --from-file "$RULE_AUTHORING_DIR/recipes/$recipe.yq" "$path" >"$WORK/out" 2>"$WORK/error"; then
    echo "FAIL: expected rejection: $message" >&2
    exit 1
  fi
  grep -Fq "$message" "$WORK/error"
  cmp "$path" "$WORK/rejected-original"
}

# A category correction is explicit, but malformed values are never overwritten.
printf '{"id": example, language: Json, metadata: {category: 42}}\n' >"$RULE"
expect_rejected category "$RULE" 'category must be a string'
for metadata in 'null' '[]' 'false' 'broken'; do
  printf 'id: example\nmetadata: %s\n' "$metadata" >"$RULE"
  expect_rejected category "$RULE" 'metadata must be a mapping'
done
for layout in 'recommended/unknown/example.yml' 'unknown/package-json/example.yml' 'recommended/package-json/extra/example.yml'; do
  path="$WORK/rules/$layout"
  mkdir -p "$(dirname "$path")"
  printf 'id: example\n' >"$path"
  expect_rejected category "$path" 'Error:'
done
printf 'id: other\n' >"$RULE"
expect_rejected category "$RULE" 'filename/id mismatch'
printf 'id: [\n' >"$RULE"
expect_rejected category "$RULE" 'Error:'
printf 'id: example\n---\nid: example\n' >"$RULE"
expect_rejected category "$RULE" 'one YAML document'
printf '{"id": example, "metadata": {category: security, precision: high, custom: keep}, rule: {metadata: nested}}\n' >"$RULE"
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/category.yq" "$RULE"
[[ $(yq -o=json -I=0 '.metadata | sort_keys(..)' "$RULE") == '{"category":"package-json","custom":"keep","precision":"high"}' ]]
[[ $(yq '.rule.metadata' "$RULE") == nested ]]

mkdir -p "$WORK/bin"
printf '#!/bin/sh\necho "yq 3.4.3 (other implementation)"\n' >"$WORK/bin/yq"
chmod +x "$WORK/bin/yq"
if PATH="$WORK/bin:$PATH" bash -c 'source scripts/rule-metadata-env.sh' 2>"$WORK/error"; then
  echo 'FAIL: accepted wrong yq implementation' >&2
  exit 1
fi
grep -Fq 'Expected Mike Farah yq v4' "$WORK/error"
# Only Bash is exposed so the missing-tool guard runs without system yq.
ln -s "$(command -v bash)" "$WORK/bin/bash"
rm "$WORK/bin/yq"
if PATH="$WORK/bin" bash -c 'source scripts/rule-metadata-env.sh' 2>"$WORK/error"; then
  echo 'FAIL: accepted missing yq' >&2
  exit 1
fi
grep -Fq 'Install Mike Farah yq v4' "$WORK/error"
printf 'PASS: explicit correction, malformed inputs, layout and tool guards\n'

cat >"$RULE" <<'YAML'
id: example
note: >
  Keep [reference](https://example.com/start?q=1#fragment), including punctuation.
metadata:
  references: ['https://example.com/start?q=1#fragment', 'https://example.com/start?q=1#fragment']
  scope-profile: [unique]
  scope-rationale: Reviewed legacy scope.
  precision: high
  custom: {keep: true}
rule: {kind: object}
ignores: ['**/node_modules/**', '**/node_modules/**']
YAML
BEFORE=$(yq -o=json -I=0 'del(.metadata.references) | sort_keys(..)' "$RULE")
export REFERENCE='https://example.org/reviewed?q=a,b#anchor'
yq --from-file "$RULE_AUTHORING_DIR/recipes/reference.yq" "$RULE" >"$WORK/preview"
[[ $(yq -o=json -I=0 '.metadata.references' "$WORK/preview") == '["https://example.com/start?q=1#fragment","https://example.org/reviewed?q=a,b#anchor"]' ]]
[[ $(yq -o=json -I=0 'del(.metadata.references) | sort_keys(..)' "$WORK/preview") == "$BEFORE" ]]
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/reference.yq" "$RULE"
cp "$RULE" "$WORK/once"
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/reference.yq" "$RULE"
cmp "$RULE" "$WORK/once"
for reference in '' ' https://example.com' 'https://example.com ' 'http://' 'https:///path' 'ftp://example.com' 'https://example.com:bad'; do
  export REFERENCE="$reference"
  expect_rejected reference "$RULE" 'reference URL'
done
export REFERENCE='https://example.org/reviewed?q=a,b#anchor'
for references in null '{}' '[42]' '["https:///bad"]' '["https://example.com "]'; do
  printf 'id: example\nmetadata: {references: %s}\n' "$references" >"$RULE"
  expect_rejected reference "$RULE" 'references'
done
printf 'id: example\n' >"$RULE"
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/reference.yq" "$RULE"
[[ $(yq -o=json -I=0 '.metadata' "$RULE") == '{"references":["https://example.org/reviewed?q=a,b#anchor"]}' ]]
printf 'PASS: explicitly supplied references preserve prose, judgments, and exact URLs\n'

cat >"$RULE" <<'YAML'
id: example
language: Tsx
severity: error
metadata:
  precision: medium
  precision-rationale: Reviewed precision, not inferred from severity.
  impact: high
  impact-rationale: Reviewed impact.
  owasp: 'A02:2025'
  cwe: 'CWE-79'
  custom: {retain: yes}
  references: ['https://example.com/a#one', 'https://example.com/a?x=1#one', 'https://example.com/a#one']
  tags: [module:jira:issuePanel, module:jira:issuePanel]
  scope-profile: [tests, manifest, backend, frontend, package-json]
rule: {kind: string}
files: ['**/frontend/**', '**/package.json']
ignores: ['**/tests/**', '**/node_modules/**', '**/tests/**']
YAML
BEFORE=$(yq -o=json -I=0 'del(.metadata.references, .metadata.tags, .metadata.scope-profile) | sort_keys(..)' "$RULE")
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/normalize.yq" "$RULE"
[[ $(yq -o=json -I=0 '.metadata.scope-profile' "$RULE") == '["frontend","backend","package-json","manifest","tests"]' ]]
[[ $(yq -o=json -I=0 '.metadata.tags' "$RULE") == '["module:jira:issuePanel"]' ]]
[[ $(yq '.metadata.references | length' "$RULE") == 2 ]]
[[ $(yq -o=json -I=0 'del(.metadata.references, .metadata.tags, .metadata.scope-profile) | sort_keys(..)' "$RULE") == "$BEFORE" ]]
for profile in '[]' '[tests]' '[frontend,frontend]' '[unique,tests]' '[unknown]' 'null' 'frontend' '[42]'; do
  printf 'id: example\nmetadata: {scope-profile: %s}\n' "$profile" >"$RULE"
  expect_rejected normalize "$RULE" 'scope-profile'
done
for tags in 'null' 'module:jira:issuePanel' '[target:frontend]' '[42]'; do
  printf 'id: example\nmetadata: {tags: %s}\n' "$tags" >"$RULE"
  expect_rejected normalize "$RULE" 'tags'
done
printf 'id: example\nmetadata: {scope-profile: [unique], scope-rationale: Reviewed, custom: keep}\n' >"$RULE"
cp "$RULE" "$WORK/once"
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/normalize.yq" "$RULE"
[[ $(yq -o=json -I=0 '.' "$RULE") == $(yq -o=json -I=0 '.' "$WORK/once") ]]
for scope in 'files: ["**/package.json"]\nignores: ["**/node_modules/**"]' 'files: ["**/{src,lib}/**"]\nignores: []'; do
  printf 'id: example\n%b\n' "$scope" >"$RULE"
  yq -i --from-file "$RULE_AUTHORING_DIR/recipes/normalize.yq" "$RULE"
  [[ $(yq 'has("metadata")' "$RULE") == false ]]
done
printf 'PASS: normalization orders valid selectors without inferring scope or ratings\n'

# All public recipes must accept mixed tags and preserve their order/content.
export REFERENCE='https://example.org/reviewed'
for recipe in category reference normalize severity; do
  printf '%s\n' 'id: example' 'severity: off' 'metadata:' '  precision: high' '  impact: low' '  tags: [capability:test, module:jira:issuePanel, capability:catalog]' '  custom: keep' >"$RULE"
  yq --from-file "$RULE_AUTHORING_DIR/recipes/$recipe.yq" "$RULE" >"$WORK/preview"
  [[ $(yq -o=json -I=0 '.metadata.tags' "$WORK/preview") == '["capability:test","module:jira:issuePanel","capability:catalog"]' ]]
  [[ $(yq '.metadata.custom' "$WORK/preview") == keep ]]
done
printf 'PASS: every metadata recipe preserves distinct mixed tags\n'
for recipe in category reference normalize severity; do
  for tags in '[capability:catlog]' '[capability:vitest]' '[capability:aidev]' '[capability:evals]' '[capability:Catalog]' '[capability:catalog:extra]' '[capability:catalog, 42]' '[true]' '[{}]'; do
    printf 'id: example\nseverity: off\nmetadata: {tags: %s}\n' "$tags" >"$RULE"
    expect_rejected "$recipe" "$RULE" 'tags'
  done
done
printf 'id: example\nmetadata: {tags: [capability:test, module:jira:issuePanel, capability:test]}\n' >"$RULE"
yq -i --from-file "$RULE_AUTHORING_DIR/recipes/normalize.yq" "$RULE"
[[ $(yq -o=json -I=0 '.metadata.tags' "$RULE") == '["capability:test","module:jira:issuePanel"]' ]]
printf 'PASS: recipes reject unsupported tags; explicit normalization removes exact duplicates\n'

printf 'id: example\nmetadata: &shared {category: security}\nrule: *shared\n' >"$RULE"
expect_rejected category "$RULE" 'anchors'
printf 'id: example\nmetadata: {category: security, category: cost}\n' >"$RULE"
expect_rejected category "$RULE" 'duplicate mapping keys'
printf 'id: example\nmetadata: {precision: null, impact: [high], owasp: 42, cwe: false}\n' >"$RULE"
expect_rejected normalize "$RULE" 'classification'
printf 'PASS: ambiguous YAML and malformed classifications require review\n'

# Capability discovery maps the two existing policies, not other packaging advice.
discovered=$(yq -N -r 'select((.metadata.tags // []) | contains(["capability:package-metadata"])) | .id' rules/*/*/*.yml | sort)
expected=$'require-package-private-true\nrequire-package-type-module'
if [[ $discovered != "$expected" ]]; then
  printf 'FAIL: package-metadata discovery expected:\n%s\nGot:\n%s\n' "$expected" "$discovered" >&2
  exit 1
fi
printf 'PASS: package-metadata discovery returns exactly the type and privacy rules\n'
