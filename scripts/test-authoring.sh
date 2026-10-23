#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh || exit 2
# ast-grep otherwise exits successfully for a test with no matching rule.
for rule in authoring/rules/*.yml; do
  id=$(yq '.id' "$rule")
  [[ -f authoring/tests/"$id".test.yml ]] || {
    printf 'Missing authoring test: %s\n' "$id" >&2
    exit 2
  }
done
for test in authoring/tests/*.test.yml; do
  id=$(yq '.id' "$test")
  [[ -f authoring/rules/"$id".yml ]] || {
    printf 'Missing authoring rule: %s\n' "$id" >&2
    exit 2
  }
done
ast-grep test --config authoring/sgconfig.yml --test-dir authoring/tests --skip-snapshot-tests
bash scripts/test-authoring-values.sh
bash scripts/test-authoring-checks.sh
bash scripts/test-rule-metadata.sh
bash scripts/check-authoring.sh
