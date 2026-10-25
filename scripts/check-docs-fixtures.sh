#!/usr/bin/env bash
# Scan package text only; never execute documentation commands or load owner configs.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_docs.XXXXXX")
for variant in generated single-quotes missing non-string nested inert markdown-only spelling-only unquoted lookalike non-fail-fast fixing; do
  expected=1
  case "$variant" in
  generated)
    edit='.'
    expected=0
    ;;
  single-quotes)
    edit='.scripts["lint:docs"] = "  markdownlint-cli2  '\''./**/*.md'\''&&cspell lint '\''**/*.md'\''  "'
    expected=0
    ;;
  missing) edit='del(.scripts["lint:docs"])' ;;
  non-string) edit='.scripts["lint:docs"] = ["markdownlint-cli2", "cspell"]' ;;
  nested) edit='.config.scripts["lint:docs"] = .scripts["lint:docs"] | del(.scripts["lint:docs"])' ;;
  inert) edit='.scripts["lint:docs"] |= "echo " + .' ;;
  markdown-only) edit='.scripts["lint:docs"] = "markdownlint-cli2 \"**/*.md\""' ;;
  spelling-only) edit='.scripts["lint:docs"] = "cspell lint \"**/*.md\""' ;;
  unquoted) edit='.scripts["lint:docs"] = "markdownlint-cli2 **/*.md && cspell lint **/*.md"' ;;
  lookalike) edit='.scripts["lint:docs"] |= sub("cspell lint"; "cspell-extra lint")' ;;
  non-fail-fast) edit='.scripts["lint:docs"] |= sub(" && "; "; ")' ;;
  fixing) edit='.scripts["lint:docs"] |= sub("markdownlint-cli2 "; "markdownlint-cli2 --fix ")' ;;
  esac
  jq "$edit" fixtures/drop-calf-forge-app/package.json >"$work/package.json"
  # The sentinel makes an absent docs rule observable instead of an empty-filter error.
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^(lint-with-docs|no-package-main)$' --include-metadata --json=compact "$work/package.json")
  if ! jq -e --argjson count "$expected" '
    [.[] | select(.ruleId == "lint-with-docs")] |
    length == $count and all(.[]; .severity == "info" and
      (.metadata.tags | index("capability:docs") != null))
  ' <<<"$findings" >/dev/null; then
    printf 'Unexpected docs entrypoint findings for %s: expected %s, got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
printf 'Generated documentation command and package mutations produced expected findings.\n'
