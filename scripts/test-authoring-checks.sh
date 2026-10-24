#!/usr/bin/env bash
# Public seam: the repository check's output and exit status, with real rule files.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh
mkdir -p "$PWD/.scratch"
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_authoring_checks.XXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/rules/recommended/security"
file="$work/rules/recommended/security/example.yml"
base="$work/base.yml"
printf '%s\n' 'id: example' 'language: TypeScript' 'severity: off' 'rule: {kind: string}' 'metadata:' '  category: security' '  precision: high' '  precision-rationale: Reviewed matcher evidence.' '  impact: low' '  impact-rationale: Reviewed impact evidence.' '  references: ["https://example.com/docs?q=1#part"]' '  scope-profile: [unique]' '  scope-rationale: Reviewed custom scope.' 'ignores: []' >"$base"
cp "$base" "$file"
run_check() {
  local expected=$1 pattern=$2 status=0
  shift 2
  bash "${check_script:-scripts/check-authoring.sh}" "$@" >"$work/out" 2>&1 || status=$?
  [[ $status == "$expected" ]] || {
    printf 'Expected status %s, got %s\n' "$expected" "$status" >&2
    tail -15 "$work/out" >&2
    exit 1
  }
  [[ $(<"$work/out") == *"$pattern"* ]] || {
    printf 'Missing output: %s\n' "$pattern" >&2
    tail -15 "$work/out" >&2
    exit 1
  }
}
run_check 0 'Authoring checks passed' "$file"
# JSON-form YAML exercises real-file flow collections and quoted keys.
yq -o=json '.' "$base" >"$file"
run_check 0 'Authoring checks passed' "$file"
yq 'del(.metadata.precision)' "$base" >"$file"
run_check 1 'require-authoring-precision' "$file"
cp "$base" "$file"
yq 'del(.metadata.category)' "$base" >"$file"
run_check 1 'category:' "$file"
yq --from-file authoring/recipes/category.yq "$file" >"$work/repaired.yml"
cp "$work/repaired.yml" "$file"
run_check 0 'Authoring checks passed' "$file"
# Unsupported scope is visible, never asserted as an established comparison.
yq '.metadata.scope-profile = ["frontend"] | .files = ["src/frontend/specific.ts"] | .ignores = (load(strenv(RULE_AUTHORING_DIR) + "/policy.yml") | .baseline + .test-exclusions)' "$base" >"$file"
run_check 0 'REVIEW:' "$file"
# Source bytes remain untouched by the check.
before=$(shasum -a 256 "$file")
run_check 0 'REVIEW:' "$file"
[[ $(shasum -a 256 "$file") == "$before" ]]
printf '%s\n' 'id: [' >"$file"
run_check 2 'parse' "$file"
cp "$base" "$file"
printf '\n---\nid: second\n' >>"$file"
run_check 2 'YAML' "$file"
cp "$base" "$file"
printf '\nid: duplicate\n' >>"$file"
run_check 2 'YAML' "$file"
yq '.metadata.precision-rationale anchor = "rationale"' "$base" >"$file"
run_check 2 'YAML' "$file"
printf '%s\n' 'id: example' 'rule: {kind: string}' 'metadata: !custom {}' >"$file"
run_check 2 'YAML' "$file"
printf '%s\n' '? [complex, key]' ': value' >"$file"
run_check 2 'YAML' "$file"
printf '%s\n' 'null' >"$file"
run_check 2 'YAML' "$file"
cp "$base" "$file"
mkdir "$work/bin"
printf '#!/usr/bin/env bash\nexit 7\n' >"$work/bin/ast-grep"
chmod +x "$work/bin/ast-grep"
PATH="$work/bin:$PATH" run_check 2 'scanner failed' "$file"
# Even a misleading findings status without a valid result must fail as a tool error.
printf '#!/usr/bin/env bash\nprintf "[]\\n"\nexit 1\n' >"$work/bin/ast-grep"
PATH="$work/bin:$PATH" run_check 2 'scanner failed' "$file"
# A new disabled definition cannot opt out, even with an exact former ledger entry.
# Exercise default repository discovery and explicit repair in an isolated checkout.
sandbox="$work/repository"
mkdir -p "$sandbox/scripts" "$sandbox/rules/recommended/security"
cp scripts/check-authoring.sh scripts/rule-metadata-env.sh "$sandbox/scripts/"
cp -R authoring "$sandbox/authoring"
candidate=rules/recommended/security/example.yml
yq 'del(.metadata)' "$base" >"$sandbox/$candidate"
digest=$(shasum -a 256 "$sandbox/$candidate")
printf '%s\t%s\t%s\n' "$candidate" "${digest%% *}" ' category metadata ratings rationales references require-authoring-metadata scope-ignores scope-selectors' >"$sandbox/authoring/legacy-allowances.tsv"
check_script="$sandbox/scripts/check-authoring.sh"
run_check 1 'require-authoring-metadata'
cp "$base" "$sandbox/$candidate"
run_check 0 'Authoring checks passed'
[[ $(yq '.severity' "$sandbox/$candidate") == off ]]
yq 'del(.metadata.category)' "$base" >"$sandbox/$candidate"
run_check 1 'category:'
yq --from-file authoring/recipes/category.yq "$sandbox/$candidate" >"$work/repaired.yml"
cp "$work/repaired.yml" "$sandbox/$candidate"
run_check 0 'Authoring checks passed'
[[ $(yq '.severity' "$sandbox/$candidate") == off ]]
# The same definition is enforced when enabled; the matrix is not an override.
yq '.severity = "info"' "$base" >"$sandbox/$candidate"
run_check 0 'Authoring checks passed'
yq 'del(.metadata.impact-rationale)' "$sandbox/$candidate" >"$work/invalid.yml"
cp "$work/invalid.yml" "$sandbox/$candidate"
run_check 1 'rationales:'
# Wrong yq implementations and failing parsers are execution failures, not findings.
printf '#!/usr/bin/env bash\nprintf "yq incompatible\\n"\n' >"$work/bin/yq"
chmod +x "$work/bin/yq"
PATH="$work/bin:$PATH" run_check 2 'Expected Mike Farah yq'
# The generated stub evaluates its own argument.
# shellcheck disable=SC2016
printf '#!/usr/bin/env bash\nif [[ $1 == --version ]]; then printf "yq (https://github.com/mikefarah/yq/) version v4.54.1\\n"; else exit 7; fi\n' >"$work/bin/yq"
PATH="$work/bin:$PATH" run_check 2 'parse/structure' "$file"
unset check_script
# Discover all current definitions, including future files and language companions.
run_check 0 'Authoring checks passed'
printf 'Authoring orchestration checks passed.\n'
