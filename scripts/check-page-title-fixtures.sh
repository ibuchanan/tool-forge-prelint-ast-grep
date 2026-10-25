#!/usr/bin/env bash
# Public seam: advisory diagnostics and blocking-gate behavior on a real TSX file.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_page_title.XXXXXX")
mkdir -p "$work/frontend"
file="$work/frontend/page.tsx"
printf '%s\n' 'import { Heading } from "@forge/react";' '<Heading size="xlarge">Configure</Heading>' >"$file"
mkdir -p "$work/static/custom-ui"
cp "$file" "$work/frontend/page.jsx"
cp "$file" "$work/static/custom-ui/page.tsx"
ast-grep scan --config sgconfig.recommended.yml --filter '^review-duplicate-page-title$' \
  --min-severity hint --json=compact "$work" >"$work/scan.json"
jq -e --arg file "$file" '
  length == 1 and
  .[0].file == $file and
  .[0].ruleId == "review-duplicate-page-title" and
  .[0].severity == "hint" and
  .[0].text == "<Heading size=\"xlarge\">Configure</Heading>" and
  .[0].range.start.line == 1 and
  .[0].message == "This heading may repeat the host-rendered title; compare it with the module title.\n"
' "$work/scan.json" >/dev/null || {
  printf 'Expected an advisory review prompt on the candidate heading; evidence: %s\n' "$work" >&2
  exit 1
}
ast-grep scan --config sgconfig.recommended.yml --filter '^review-duplicate-page-title$' \
  --min-severity error --json=compact "$file" >"$work/blocking.json"
jq -e 'type == "array" and length == 0' "$work/blocking.json" >/dev/null
printf 'Page-title diagnostics passed: candidate range, advisory message and nonblocking gate.\n'
