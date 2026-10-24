#!/usr/bin/env bash
# Public seam: the actual archive and the consumer configurations inside it.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_package.XXXXXX")
# Retain the archive and file lists for contributor inspection.
bun pm pack --ignore-scripts --quiet --filename "$work/package.tgz" >"$work/pack.log"
tar -tzf "$work/package.tgz" | sort >"$work/actual"
{
  printf 'package/%s\n' package.json LICENSE README.md
  printf 'package/%s\n' rules/*/*/*.yml
  for tier in recommended strict atlassian ecosol; do
    printf 'package/sgconfig.%s.yml\n' "$tier"
  done
} | sort >"$work/expected"
diff -u "$work/expected" "$work/actual" || {
  printf 'Unexpected package contents; evidence: %s\n' "$work" >&2
  exit 1
}
tar -xzf "$work/package.tgz" -C "$work"
mkdir "$work/empty"
for tier in recommended strict atlassian ecosol; do
  config="$work/package/sgconfig.$tier.yml"
  # No repo-only utility/test directories or paths outside the consumer rule tree.
  yq -o=json '.' "$config" | jq -e '
    ((keys - ["ruleDirs", "languageGlobs"]) | length == 0) and
    (.ruleDirs | type == "array" and length > 0 and
      all(.[]; type == "string" and test("^rules/(recommended|strict|atlassian|ecosol)/[a-z-]+$")))
  ' >/dev/null || {
    printf 'Repository-only or unsupported configuration in %s\n' "$config" >&2
    exit 1
  }
  # Loading the packed config also rejects absent directories or malformed rules.
  ast-grep scan --config "$config" --json=compact "$work/empty" >"$work/$tier.json"
  jq -e 'type == "array" and length == 0' "$work/$tier.json" >/dev/null
done
printf 'Package boundary passed: consumer rules/configs only; evidence: %s\n' "$work"
