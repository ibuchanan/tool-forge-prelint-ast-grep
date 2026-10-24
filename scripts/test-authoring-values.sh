#!/usr/bin/env bash
# Public seam: native yq diagnostics, not internal helper calls.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh
mkdir -p "$PWD/.scratch"
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_authoring_values.XXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/rules/recommended/security"
file="$work/rules/recommended/security/example.yml"
base="$work/base.yml"
printf '%s\n' 'id: example' 'language: TypeScript' 'severity: off' 'rule: {kind: string}' 'metadata:' '  category: security' '  precision: high' '  precision-rationale: Reviewed matcher evidence.' '  impact: low' '  impact-rationale: Reviewed impact evidence.' '  references: ["https://example.com/docs?q=1#part"]' '  scope-profile: ["frontend"]' 'files: ["**/frontend/**"]' >"$base"
yq '.ignores = (load(strenv(RULE_AUTHORING_DIR) + "/policy.yml") | .baseline + .test-exclusions)' "$base" >"$file"
cp "$file" "$base"
check() {
  local edit=$1 expected=$2 output
  yq "$edit" "$base" >"$file"
  output=$(yq --from-file authoring/checks/values.yq "$file")
  if [[ $expected == clean ]]; then
    [[ -z $output ]] || {
      printf 'Unexpected diagnostics for %s:\n%s\n' "$edit" "$output" >&2
      exit 1
    }
  else
    [[ $output == *"$expected:"* ]] || {
      printf 'Missing %s for %s:\n%s\n' "$expected" "$edit" "$output" >&2
      exit 1
    }
  fi
}
check '.' clean
check '.metadata.category = "cost"' category
check '.id = "different"' layout
check '.metadata.precision = 3' ratings
check '.metadata.impact = "HIGH"' ratings
check '.metadata.precision-rationale = "  "' rationales
check '.metadata.impact-rationale = []' rationales
check '.metadata.references = []' references
check '.metadata.references = ["https://example.com", "https://example.com"]' references
check '.metadata.references = ["https://example.com/a b"]' references
check '.metadata.references = ["https://"]' references
check '.metadata.references = [12]' references
check '.metadata.tags = ["module:jira:issuePanel"]' clean
check '.metadata.tags = ["jira:issuePanel"]' tags
check '.metadata.tags = ["module:jira:issuePanel", "module:jira:issuePanel"]' tags
check '.metadata.tags = null' tags
check '.metadata.owasp = []' classification
check '.metadata.scope-profile = []' scope-selectors
check '.metadata.scope-profile = ["tests"]' scope-selectors
check '.metadata.scope-profile = ["frontend", "frontend"]' scope-selectors
check '.metadata.scope-profile = ["unknown"]' scope-selectors
check '.metadata.scope-profile = ["unique", "frontend"]' scope-selectors
check '.metadata.scope-profile = ["unique"]' scope-selectors
check '.metadata.scope-profile = ["unique"] | .metadata.scope-rationale = "Reviewed custom scope" | .ignores = []' clean
check '.metadata.scope-profile = ["frontend", "tests"] | .ignores = load(strenv(RULE_AUTHORING_DIR) + "/policy.yml").baseline' clean
check '.ignores = []' scope-ignores
check '.ignores += [.ignores[0]]' native-globs
check '.files = []' native-globs
check '.files = [true]' native-globs
check 'del(.ignores)' native-globs
check '.files = ["**/backend/**", "**/resolvers/**", "**/external/**", "**/import-lifecycle/**"]' positive-scope
check '.files = ["**/package.json"]' positive-scope
check '.metadata.scope-profile = ["frontend", "package-json"] | .files = ["**/frontend/**/package.json"]' clean
check '.metadata.scope-profile = ["frontend", "backend", "package-json"] | .files = ["**/package.json"]' clean
check '.metadata.scope-profile = ["package-json", "manifest"] | .files = ["**/package.json", "**/manifest.yml", "**/manifest.yaml"]' clean
check '.metadata.scope-profile = ["backend"] | .files = load(strenv(RULE_AUTHORING_DIR) + "/policy.yml").runtime.backend' clean
check '.metadata.scope-profile = ["frontend", "backend"] | del(.files)' clean
check '.metadata.scope-profile = ["frontend"] | del(.files)' positive-scope
check '.files = ["src/frontend/specific.ts"]' REVIEW
check '.files = ["src/frontend/specific.ts", "src/frontend/specific.ts"]' native-globs
check 'del(.metadata.precision-rationale)' rationales
check 'del(.metadata.impact-rationale)' rationales
check 'del(.metadata.precision)' ratings
check 'del(.metadata.impact)' ratings
check '.metadata.scope-profile = ["tests", "frontend"] | .ignores = load(strenv(RULE_AUTHORING_DIR) + "/policy.yml").baseline' clean
check '.metadata.scope-profile = ["unique"] | .metadata.scope-rationale = "   "' scope-selectors
check '.metadata.scope-profile = [true]' scope-selectors
check '.metadata.scope-profile = null' scope-selectors
check '.ignores = [true]' native-globs
check '.files = "**/*"' native-globs
check '.metadata = null' metadata
check '.metadata = []' metadata
printf 'Authoring value checks passed (including disabled definitions).\n'
