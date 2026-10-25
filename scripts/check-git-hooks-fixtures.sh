#!/usr/bin/env bash
# Scan declarations only; never install or execute hooks or their commands.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_git_hooks.XXXXXX")

# The stored snapshot predates pre-push delegation; apply only the pinned hook wiring.
yq 'del(.lint) | .["pre-push"] = {"commands": {"check": {"run": "npm run check"}}}' \
  fixtures/drop-calf-forge-app/lefthook.yml >"$work/generated.txt"
for variant in generated bun owner-names flow missing-push inert-push copied-list nested-push wrong-hook lookalike-push optional-push masked-push inert-format check-only unstaged-format split-format inert-scanner unstaged-scanner nested-scanner; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  bun) edit='.["pre-commit"].commands.format.run = "bun run --if-present format" | .["pre-push"].commands.check.run = "bun run check"' ;;
  owner-names) edit='.["pre-commit"].commands.style = .["pre-commit"].commands.format | del(.["pre-commit"].commands.format) | .["pre-commit"].commands.scan = .["pre-commit"].commands.gitleaks | del(.["pre-commit"].commands.gitleaks) | .["pre-push"].commands.verify = .["pre-push"].commands.check | del(.["pre-push"].commands.check) | .["pre-push"].parallel = true' ;;
  flow) edit='.["pre-commit"].commands.gitleaks.run = "gitleaks git --staged --pre-commit" | .. style="flow"' ;;
  missing-push)
    edit='del(.["pre-push"])'
    expected='require-lefthook-pre-push-check'
    ;;
  inert-push)
    edit='.["pre-push"].commands.check.run = "echo npm run check"'
    expected='require-lefthook-pre-push-check'
    ;;
  copied-list)
    edit='.["pre-push"].commands = {"lint": {"run": "npm run lint"}, "test": {"run": "npm run test"}, "size": {"run": "npm run size:check"}}'
    expected='require-lefthook-pre-push-check'
    ;;
  nested-push)
    edit='.other.["pre-push"] = .["pre-push"] | del(.["pre-push"])'
    expected='require-lefthook-pre-push-check'
    ;;
  wrong-hook)
    edit='.["pre-commit"].commands.check = .["pre-push"].commands.check | del(.["pre-push"])'
    expected='require-lefthook-pre-push-check'
    ;;
  lookalike-push)
    edit='.["pre-push"].commands.check.run = "npm run check-extra"'
    expected='require-lefthook-pre-push-check'
    ;;
  optional-push)
    edit='.["pre-push"].commands.check.run = "npm run check --if-present"'
    expected='require-lefthook-pre-push-check'
    ;;
  masked-push)
    edit='.["pre-push"].commands.check.run = "npm run check || true"'
    expected='require-lefthook-pre-push-check'
    ;;
  inert-format)
    edit='.["pre-commit"].commands.format.run = "echo npm run format"'
    expected='require-lefthook-pre-commit-format'
    ;;
  check-only)
    edit='.["pre-commit"].commands.format.run = "npm run format:check"'
    expected='require-lefthook-pre-commit-format'
    ;;
  unstaged-format)
    edit='del(.["pre-commit"].commands.format.stage_fixed)'
    expected='require-lefthook-pre-commit-format'
    ;;
  split-format)
    edit='.["pre-commit"].commands.other.stage_fixed = true | del(.["pre-commit"].commands.format.stage_fixed)'
    expected='require-lefthook-pre-commit-format'
    ;;
  inert-scanner)
    edit='.["pre-commit"].commands.gitleaks.run = "echo gitleaks git --pre-commit --staged"'
    expected='require-lefthook-pre-commit-gitleaks'
    ;;
  unstaged-scanner)
    edit='.["pre-commit"].commands.gitleaks.run = "gitleaks git --pre-commit"'
    expected='require-lefthook-pre-commit-gitleaks'
    ;;
  nested-scanner)
    edit='.["pre-commit"].commands.gitleaks.other.run = .["pre-commit"].commands.gitleaks.run | del(.["pre-commit"].commands.gitleaks.run)'
    expected='require-lefthook-pre-commit-gitleaks'
    ;;
  esac
  yq "$edit" "$work/generated.txt" >"$work/lefthook.yml"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-lefthook-' --include-metadata --json=compact "$work/lefthook.yml")
  if ! jq -e --arg expected "$expected" '
    type == "array" and
    map(.ruleId) == (if $expected == "" then [] else [$expected] end) and
    all(.[]; (.metadata.tags | index("capability:git-hooks") != null) and
      .severity == (if .ruleId == "require-lefthook-pre-commit-gitleaks" then "warning" else "info" end))
  ' <<<"$findings" >/dev/null; then
    printf 'Unexpected hook findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done

for variant in generated strict fallback-spacing missing inert nested non-string; do
  expected=1
  case "$variant" in
  generated)
    edit='.'
    expected=0
    ;;
  strict)
    edit='.scripts.prepare = "lefthook install"'
    expected=0
    ;;
  fallback-spacing)
    edit='.scripts.prepare = "lefthook install||true"'
    expected=0
    ;;
  missing) edit='del(.scripts.prepare)' ;;
  inert) edit='.scripts.prepare = "echo lefthook install"' ;;
  nested) edit='.other.scripts.prepare = .scripts.prepare | del(.scripts.prepare)' ;;
  non-string) edit='.scripts.prepare = ["lefthook", "install"]' ;;
  esac
  jq "$edit" fixtures/drop-calf-forge-app/package.json >"$work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-lefthook-prepare$' --include-metadata --json=compact "$work/package.json")
  if ! jq -e --argjson count "$expected" '
    length == $count and all(.[]; .ruleId == "require-lefthook-prepare" and
      .severity == "info" and (.metadata.tags | index("capability:git-hooks") != null))
  ' <<<"$findings" >/dev/null; then
    printf 'Unexpected prepare findings for %s: %s\n' "$variant" "$findings" >&2
    exit 1
  fi
done

# Existing medium/high scanner advice remains nonblocking at the error-only gate.
for mode in --min-severity=error --off=require-lefthook-pre-commit-gitleaks; do
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-lefthook-pre-commit-gitleaks$' "$mode" --json=compact "$work/lefthook.yml")
  jq -e 'type == "array" and length == 0' <<<"$findings" >/dev/null
done
# Filename routing deliberately remains lefthook.yml only, not lefthook.yaml.
cp "$work/lefthook.yml" "$work/lefthook.yaml"
findings=$(ast-grep scan --config sgconfig.ecosol.yml \
  --filter '^require-lefthook-' --json=compact "$work/lefthook.yaml")
jq -e 'type == "array" and length == 0' <<<"$findings" >/dev/null
printf 'Generated hooks, prepare fallbacks, static mutations, metadata and filename boundary passed.\n'
