#!/usr/bin/env bash
# Repository-only native-tool coordination. Every finding fails; source is read-only.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh || exit 2
for tool in ast-grep jq; do
  command -v "$tool" >/dev/null || {
    printf 'Missing required tool: %s\n' "$tool" >&2
    exit 2
  }
done
mkdir -p "$PWD/.scratch"
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_authoring.XXXXXX")
trap 'rm -rf "$work"' EXIT
if [[ $# == 0 ]]; then
  set -- rules/*/*/*.yml
fi
: >"$work/findings"
for file in "$@"; do
  if ! yq eval-all --exit-status --from-file authoring/checks/document.yq "$file" >/dev/null; then
    printf '%s: YAML parse/structure check failed\n' "$file" >&2
    exit 2
  fi
  if ! yq --from-file authoring/checks/values.yq "$file" >"$work/values"; then
    printf '%s: value parser/check failed\n' "$file" >&2
    exit 2
  fi
  while IFS= read -r diagnostic; do
    [[ -n $diagnostic ]] || continue
    if [[ $diagnostic == REVIEW:* ]]; then
      printf '%s: %s\n' "$file" "$diagnostic"
    else
      printf '%s\t%s\t%s\n' "$file" "${diagnostic%%:*}" "$diagnostic" >>"$work/findings"
    fi
  done <"$work/values"
done
status=0
ast-grep scan --config authoring/sgconfig.yml --json=compact "$@" >"$work/scan.json" 2>"$work/scanner-errors" || status=$?
if [[ $status -gt 1 ]] || ! jq -e 'type == "array" and all(.[]; (.file | type == "string") and (.ruleId | type == "string") and (.message | type == "string"))' "$work/scan.json" >/dev/null; then
  printf 'Authoring scanner failed (status %s)\n' "$status" >&2
  exit 2
fi
if [[ $status == 1 ]] && ! jq -e 'any(.[]; .severity == "error")' "$work/scan.json" >/dev/null; then
  printf 'Authoring scanner failed without error diagnostics\n' >&2
  exit 2
fi
jq -r '.[] | [.file, .ruleId, .message] | @tsv' "$work/scan.json" >>"$work/findings"
sort -u "$work/findings" >"$work/sorted"
errors=0
while IFS=$'\t' read -r file code message; do
  [[ -n $file ]] || continue
  printf '%s: %s: %s\n' "$file" "$code" "$message" >&2
  errors=$((errors + 1))
done <"$work/sorted"
if [[ $errors != 0 ]]; then
  printf 'Authoring checks failed: %s findings.\n' "$errors" >&2
  exit 1
fi
printf 'Authoring checks passed (REVIEW lines remain unvalidated).\n'
