#!/usr/bin/env sh
# Exercise real scanner routing; ast-grep test does not check files/ignores.
set -eu
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp -d tmp_rovo_security.XXXXXX)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
AST_GREP=${AST_GREP:-ast-grep}

# Each source file has one sink per new/improved source rule family.
for ext in ts tsx js jsx mjs cjs mts cts; do
  cp rule-tests/fixtures/security/source.txt "$TMP/source.$ext"
  cp rule-tests/fixtures/security/safe-logging.txt "$TMP/safe-logging.$ext"
done
mkdir -p "$TMP/static/custom-ui" "$TMP/tests" "$TMP/dist" "$TMP/build" "$TMP/node_modules/example"
cp rule-tests/fixtures/security/html.txt "$TMP/static/custom-ui/widget.jsx"
cp rule-tests/fixtures/security/source.txt "$TMP/tests/source.test.ts"
cp rule-tests/fixtures/security/source.txt "$TMP/tests/source.spec.js"
for dir in dist build node_modules/example; do
  cp rule-tests/fixtures/security/source.txt "$TMP/$dir/source.ts"
done
cp rule-tests/fixtures/security/manifest.txt "$TMP/manifest.yml"
cp rule-tests/fixtures/security/manifest.txt "$TMP/manifest.yaml"
cp rule-tests/fixtures/security/manifest.txt "$TMP/other.yaml"
cp rule-tests/fixtures/security/package.txt "$TMP/package.json"
cp rule-tests/fixtures/security/package.txt "$TMP/other.json"

# --files-with-matches can exit 1 for error findings; other failures must fail CI.
scan() {
  status=0
  "$AST_GREP" scan --config "$1" --filter "$2" --files-with-matches "$TMP" > "$TMP/actual" 2> "$TMP/errors" || status=$?
  if [ "$status" -gt 1 ]; then
    echo "Scanner failed for $2 (exit $status)" >&2
    while IFS= read -r line; do printf '%s\n' "$line" >&2; done < "$TMP/errors"
    exit "$status"
  fi
  sort "$TMP/actual" -o "$TMP/actual"
  sort "$TMP/expected" -o "$TMP/expected"
  if ! diff -u "$TMP/expected" "$TMP/actual"; then
    echo "Unexpected scan routing for $2 in $1" >&2
    exit 1
  fi
}

for rule in no-environment-disclosure no-dynamic-code-evaluation review-raw-html-sink review-dynamic-forge-sql no-disabled-tls-verification no-sensitive-data-logging; do
  : > "$TMP/expected"
  for ext in ts tsx js jsx mjs cjs mts cts; do
    printf '%s/source.%s\n' "$TMP" "$ext" >> "$TMP/expected"
  done
  if [ "$rule" = review-raw-html-sink ]; then
    printf '%s/static/custom-ui/widget.jsx\n' "$TMP" >> "$TMP/expected"
  fi
  scan sgconfig.strict.yml "^$rule(-tsx|-js)?$"
  : > "$TMP/expected"
  # Include an existing unrelated rule so an intentionally absent strict rule
  # does not make ast-grep reject an empty filter match.
  scan sgconfig.recommended.yml "^($rule(-tsx|-js)?|no-package-main)$"
done
for rule in no-wildcard-egress no-unsafe-custom-ui-csp; do
  for config in sgconfig.recommended.yml sgconfig.strict.yml; do
    printf '%s/manifest.yaml\n%s/manifest.yml\n' "$TMP" "$TMP" > "$TMP/expected"
    scan "$config" "^$rule$"
  done
done
printf '%s/package.json\n' "$TMP" > "$TMP/expected"
scan sgconfig.strict.yml '^no-disabled-tls-verification-package-script$'
# Second-wave review rules: separate fixtures keep each family's expectations isolated.
mkdir -p "$TMP/review/tests" "$TMP/review/__tests__" "$TMP/review/dist" "$TMP/review/build" "$TMP/review/node_modules/example"
for ext in ts tsx js jsx mjs cjs mts cts; do
  cp rule-tests/fixtures/security/review-source.txt "$TMP/review/source.$ext"
  cp rule-tests/fixtures/security/review-safe-source.txt "$TMP/review/safe.$ext"
done
cp rule-tests/fixtures/security/review-source.txt "$TMP/review/tests/source.test.ts"
cp rule-tests/fixtures/security/review-source.txt "$TMP/review/tests/source.spec.js"
for dir in __tests__ dist build node_modules/example; do
  cp rule-tests/fixtures/security/review-source.txt "$TMP/review/$dir/source.ts"
done
for rule in review-untrusted-authorization-identity review-fail-open-authorization review-llm-call-in-loop; do
  for config in sgconfig.recommended.yml sgconfig.strict.yml; do
    : > "$TMP/expected"
    if [ "$config" = sgconfig.strict.yml ] || [ "$rule" = review-llm-call-in-loop ]; then
      for ext in ts tsx js jsx mjs cjs mts cts; do
        printf '%s/review/source.%s\n' "$TMP" "$ext" >> "$TMP/expected"
      done
    fi
    scan "$config" "^($rule(-tsx|-js)?|no-package-main)$"
  done
done
cp rule-tests/fixtures/security/review-manifest.txt "$TMP/review/manifest.yml"
cp rule-tests/fixtures/security/review-manifest.txt "$TMP/review/manifest.yaml"
cp rule-tests/fixtures/security/review-manifest.txt "$TMP/review/other.yaml"
cp rule-tests/fixtures/security/review-manifest.txt "$TMP/review/node_modules/example/manifest.yml"
cp rule-tests/fixtures/security/review-package.txt "$TMP/review/package.json"
cp rule-tests/fixtures/security/review-package.txt "$TMP/review/other.json"
cp rule-tests/fixtures/security/review-package.txt "$TMP/review/node_modules/example/package.json"
for config in sgconfig.recommended.yml sgconfig.strict.yml; do
  printf '%s/review/manifest.yaml\n%s/review/manifest.yml\n' "$TMP" "$TMP" > "$TMP/expected"
  scan "$config" '^review-privileged-manifest-capabilities$'
  printf '%s/review/package.json\n' "$TMP" > "$TMP/expected"
  scan "$config" '^review-download-and-execute-script$'
done
echo 'Security fixtures: language variants, tier inclusion, manifest/package paths, and source exclusions passed.'
