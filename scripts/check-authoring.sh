#!/usr/bin/env bash
# Repository-only native-tool coordination. Never edits source or generates allowances.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh || exit 2
for tool in ast-grep jq shasum; do
  command -v "$tool" >/dev/null || {
    printf 'Missing required tool: %s\n' "$tool" >&2
    exit 2
  }
done
work=$(mktemp -d "$PWD/tmp_rovo_authoring.XXXXXX")
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
allowed=0
previous=''
codes=''
while IFS=$'\t' read -r file code message; do
  [[ -n $file ]] || continue
  if [[ $file != "$previous" ]]; then
    digest=$(shasum -a 256 "$file") || exit 2
    digest=${digest%% *}
    codes=''
    if [[ -f authoring/legacy-allowances.tsv ]]; then
      codes=$(awk -F '\t' -v file="$file" -v digest="$digest" '
        $1 == file && $2 == digest { print $3 }
      ' authoring/legacy-allowances.tsv) || exit 2
    fi
    previous=$file
  fi
  # Exact path + source digest + diagnostic: edits and new rules never inherit debt.
  if [[ " $codes " == *" $code "* ]]; then
    allowed=$((allowed + 1))
  else
    printf '%s: %s: %s\n' "$file" "$code" "$message" >&2
    errors=$((errors + 1))
  fi
done <"$work/sorted"
if [[ $errors != 0 ]]; then
  printf 'Authoring checks failed: %s unallowlisted findings (%s frozen legacy findings).\n' "$errors" "$allowed" >&2
  exit 1
fi
printf 'Authoring checks passed (%s frozen legacy findings; REVIEW lines remain unvalidated).\n' "$allowed"
