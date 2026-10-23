#!/usr/bin/env bash
# Small explicit conventional examples, not arbitrary glob evaluation.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_scope_composition.XXXXXX")
mkdir -p "$work/app/frontend/tests" "$work/app/frontend/dist" "$work/app/backend" "$work/app/odd" "$work/app/frontend/child"
for path in package.json frontend/package.json frontend/tests/package.json frontend/dist/package.json frontend/child/package.json backend/package.json odd/package.json frontend/other.json; do
  yq -r '.invalid[0]' rule-tests/recommended/package-json/no-package-main.test.yml >"$work/app/$path"
done
for path in manifest.yml frontend/manifest.yaml frontend/tests/manifest.yml backend/manifest.yml; do
  yq -r '.invalid[0]' rule-tests/recommended/security/no-wildcard-egress.test.yml >"$work/app/$path"
done
for selection in frontend frontend-tests backend both artifact-union manifest-union narrowing; do
  source_rule=rules/recommended/package-json/no-package-main.yml
  ignores='.baseline + .test-exclusions'
  case $selection in
  frontend | frontend-tests)
    profile='["frontend", "package-json"]'
    files='["**/frontend/**/package.json"]'
    printf 'frontend/child/package.json\nfrontend/package.json\n' >"$work/expected"
    if [[ $selection == frontend-tests ]]; then
      profile='["frontend", "package-json", "tests"]'
      ignores=.baseline
      printf 'frontend/tests/package.json\n' >>"$work/expected"
    fi
    ;;
  backend)
    profile='["backend", "package-json"]'
    files='["**/backend/**/package.json", "**/resolvers/**/package.json", "**/external/**/package.json", "**/import-lifecycle/**/package.json"]'
    printf 'backend/package.json\n' >"$work/expected"
    ;;
  both)
    profile='["frontend", "backend", "package-json"]'
    files='["**/package.json"]'
    printf 'backend/package.json\nfrontend/child/package.json\nfrontend/package.json\nodd/package.json\npackage.json\n' >"$work/expected"
    ;;
  artifact-union | manifest-union)
    profile='["frontend", "package-json", "manifest", "tests"]'
    files='["**/frontend/**/package.json", "**/frontend/**/manifest.yml", "**/frontend/**/manifest.yaml"]'
    ignores=.baseline
    printf 'frontend/child/package.json\nfrontend/package.json\nfrontend/tests/package.json\n' >"$work/expected"
    if [[ $selection == manifest-union ]]; then
      source_rule=rules/recommended/security/no-wildcard-egress.yml
      printf 'frontend/manifest.yaml\nfrontend/tests/manifest.yml\n' >"$work/expected"
    fi
    ;;
  narrowing)
    profile='["frontend", "package-json", "tests"]'
    files='["**/frontend/child/package.json"]'
    ignores=.baseline
    printf 'frontend/child/package.json\n' >"$work/expected"
    ;;
  esac
  yq ".metadata.scope-profile = $profile | .files = $files | .ignores = (load(strenv(RULE_AUTHORING_DIR) + \"/policy.yml\") | $ignores)" "$source_rule" >"$work/example.yml"
  sort "$work/expected" -o "$work/expected"
  diagnostics=$(yq --from-file authoring/checks/values.yq "$work/example.yml")
  # The fixture path is intentionally not a shipped rule path.
  if [[ $selection == narrowing ]]; then
    [[ $diagnostics == *'REVIEW: unsupported positive-scope comparison'* ]]
  else
    [[ $diagnostics != *'positive-scope:'* && $diagnostics != *'REVIEW:'* ]]
  fi
  for tier in recommended strict atlassian ecosol; do
    status=0
    ast-grep scan --config "sgconfig.$tier.yml" --rule "$work/example.yml" --no-ignore hidden --no-ignore vcs --json=compact "$work/app" >"$work/scan.json" || status=$?
    [[ $status -le 1 ]]
    jq -r --arg root "$work/app/" '.[].file | ltrimstr($root)' "$work/scan.json" | sort -u >"$work/actual"
    diff -u "$work/expected" "$work/actual" || {
      printf 'Composition failed: %s in %s\n' "$selection" "$tier" >&2
      exit 1
    }
  done
done
printf 'Scope composition passed: intersection, union, additive tests, parser boundary and reviewed narrowing.\n'
