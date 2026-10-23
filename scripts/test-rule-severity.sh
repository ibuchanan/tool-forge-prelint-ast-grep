#!/usr/bin/env bash
# Public seams: saved recipe documents, report/checker status, and real scans.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh
mkdir -p "$PWD/.scratch"
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_severity.XXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/rules/recommended/security"
file="$work/rules/recommended/security/example.yml"
base="$work/base.yml"
printf '%s\n' 'id: example' 'language: TypeScript' 'severity: warning' 'message: Keep this message.' 'rule: {kind: string}' 'fix: fixed' 'metadata:' '  category: security' '  precision: high' '  precision-rationale: Reviewed matcher evidence.' '  impact: high' '  impact-rationale: Reviewed impact evidence.' '  references: ["https://example.com/docs"]' '  scope-profile: [unique]' '  scope-rationale: Reviewed boundary.' 'ignores: []' >"$base"
recipe=authoring/recipes/severity.yq
# Literal expectations come from the published rubric, not the implementation.
while read -r precision impact expected; do
  PRECISION=$precision IMPACT=$impact yq '.metadata.precision = strenv(PRECISION) | .metadata.impact = strenv(IMPACT)' "$base" >"$file"
  before=$(shasum -a 256 "$file")
  native=$(yq -o=json -I=0 'del(.severity) | sort_keys(..)' "$file")
  yq --from-file "$recipe" "$file" >"$work/preview"
  [[ $(shasum -a 256 "$file") == "$before" ]]
  [[ $(yq '.severity' "$work/preview") == "$expected" ]] || {
    printf 'Wrong severity for %s/%s: expected %s\n' "$precision" "$impact" "$expected" >&2
    exit 1
  }
  [[ $(yq -o=json -I=0 'del(.severity) | sort_keys(..)' "$work/preview") == "$native" ]]
  yq -i --from-file "$recipe" "$file"
  cp "$file" "$work/once"
  yq -i --from-file "$recipe" "$file"
  cmp "$file" "$work/once"
done <<'CASES'
low low hint
low medium info
low high warning
medium low info
medium medium warning
medium high warning
high low info
high medium warning
high high error
CASES
printf 'Severity matrix: all nine cells, preview preservation and repeat apply passed.\n'
# Disabled definitions remain disabled; malformed metadata is not guessed or repaired.
yq '.severity = "off"' "$base" >"$file"
yq -i --from-file "$recipe" "$file"
[[ $(yq '.severity' "$file") == off ]]
for edit in 'del(.metadata.precision)' 'del(.metadata.impact)' '.metadata.precision = "HIGH"' '.metadata.impact = null' '.metadata.precision = []' '.metadata.impact = true' '.metadata = []' 'del(.severity)' '.severity = "fatal"'; do
  for severity in off warning; do
    SEVERITY=$severity yq '.severity = strenv(SEVERITY)' "$base" | yq "$edit" >"$file"
    cp "$file" "$work/original"
    if yq -i --from-file "$recipe" "$file" >"$work/out" 2>"$work/error"; then
      printf 'Accepted invalid severity input: %s (%s)\n' "$edit" "$severity" >&2
      exit 1
    fi
    cmp "$file" "$work/original"
  done
done
printf 'Severity recipe: off preservation and malformed-input rejection passed.\n'
# The report is read-only and identifies blocking promotions and demotions.
yq '.severity = "warning"' "$base" >"$file"
before=$(shasum -a 256 "$file")
bash scripts/report-rule-severity.sh "$file" >"$work/report"
printf 'file\tid\tprecision\timpact\tcurrent\texpected\tblocking\n%s\texample\thigh\thigh\twarning\terror\tpromote-to-error\n' "$file" >"$work/expected"
diff -u "$work/expected" "$work/report"
[[ $(shasum -a 256 "$file") == "$before" ]]
printf 'Severity report: identity, ratings and blocking transition passed.\n'
while read -r current precision impact expected blocking; do
  CURRENT=$current PRECISION=$precision IMPACT=$impact yq '.severity = strenv(CURRENT) | .metadata.precision = strenv(PRECISION) | .metadata.impact = strenv(IMPACT)' "$base" >"$file"
  bash scripts/report-rule-severity.sh "$file" >"$work/report"
  printf 'file\tid\tprecision\timpact\tcurrent\texpected\tblocking\n%s\texample\t%s\t%s\t%s\t%s\t%s\n' "$file" "$precision" "$impact" "$current" "$expected" "$blocking" >"$work/expected"
  diff -u "$work/expected" "$work/report"
done <<'REPORTS'
error medium high warning demote-from-error
warning low low hint nonblocking-change
error high high error unchanged
off high high off disabled
REPORTS
for edit in 'del(.metadata.impact)' '.metadata.precision = null' '.metadata = []' '.severity = "fatal"'; do
  yq "$edit" "$base" >"$file"
  status=0
  bash scripts/report-rule-severity.sh "$file" >"$work/report" 2>"$work/error" || status=$?
  [[ $status == 2 && ! -s $work/report ]]
done
# A later broken document must not leave a successful-looking partial report.
yq '.' "$base" >"$file"
printf 'id: [\n' >"$work/broken.yml"
status=0
bash scripts/report-rule-severity.sh "$file" "$work/broken.yml" >"$work/report" 2>"$work/error" || status=$?
[[ $status == 2 && ! -s $work/report ]]
printf 'Severity report: transitions and invalid-input status passed.\n'
# Repository enforcement is observed through its existing output/status boundary.
yq '.severity = "warning"' "$base" >"$file"
status=0
bash scripts/check-authoring.sh "$file" >"$work/out" 2>&1 || status=$?
[[ $status == 1 && $(<"$work/out") == *'severity:'* ]] || {
  printf 'Expected stale-severity violation; got status %s\n' "$status" >&2
  exit 1
}
yq -i --from-file "$recipe" "$file"
bash scripts/check-authoring.sh "$file" >"$work/out" 2>&1
printf 'Severity enforcement: stale declaration fails and explicit repair passes.\n'
# Real consumer rules: assert findings AND exit codes, not a swallowed nonzero scan.
mkdir -p "$work/app/backend"
scan="$work/app/backend/example.ts"
while read -r id expected; do
  yq -r '.invalid[0]' "rule-tests/strict/security/$id.test.yml" >"$scan"
  for mode in all blocking; do
    args=(--min-severity hint)
    [[ $mode == all ]] || args=(--min-severity error)
    status=0
    ast-grep scan --config sgconfig.strict.yml --filter "^$id$" --json=compact "${args[@]}" "$scan" >"$work/scan.json" 2>"$work/error" || status=$?
    if [[ $expected == error ]]; then
      [[ $status == 1 ]] && jq -e --arg id "$id" 'length > 0 and all(.[]; .ruleId == $id and .severity == "error")' "$work/scan.json" >/dev/null
    elif [[ $mode == blocking ]]; then
      [[ $status == 0 ]] && jq -e 'type == "array" and length == 0' "$work/scan.json" >/dev/null
    else
      [[ $status == 0 ]] && jq -e --arg id "$id" --arg severity "$expected" 'length > 0 and all(.[]; .ruleId == $id and .severity == $severity)' "$work/scan.json" >/dev/null
    fi || {
      printf 'Unexpected %s gate for %s: wanted %s, status %s\n' "$mode" "$id" "$expected" "$status" >&2
      exit 1
    }
  done
done <<'GATES'
no-global-state-mutation error
no-module-scope-mutable-state error
no-hardcoded-atlassian-token warning
GATES
# Configuration failures must not be treated as advisory success.
printf 'ruleDirs: [missing-rules]\n' >"$work/broken-config.yml"
status=0
ast-grep scan --config "$work/broken-config.yml" --json=compact "$scan" >"$work/scan.json" 2>"$work/error" || status=$?
[[ $status -gt 1 && -s $work/error ]]
printf 'Consumer gates: both promotions, token demotion, all/blocking scans and configuration failure passed.\n'
