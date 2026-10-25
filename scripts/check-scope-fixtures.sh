#!/usr/bin/env bash
# Public seam: scan real files with shipped configs; snippets cannot test routing.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_scope.XXXXXX")
# Keep routing evidence under .scratch for maintainer inspection.
count=0
while IFS=$'\t' read -r rule scope tests; do
  [[ $rule != \#* && -n $rule ]] || continue
  [[ $# == 0 || $rule == "$1/"* || $rule == "$1" ]] || continue
  case $scope in
  all | non-frontend | frontend | frontend-index | resolvers | backend | entry | package | manifest | catalog | biome | hooks | tsconfig | typecheck | vitest) ;;
  *)
    printf 'Unknown routing case: %s\n' "$scope" >&2
    exit 1
    ;;
  esac
  [[ $tests == include || $tests == exclude ]] || {
    printf 'Unknown test policy: %s\n' "$tests" >&2
    exit 1
  }
  id=$(yq '.id' "$rule")
  tier=${rule#rules/}
  tier=${tier%%/*}
  test="rule-tests/${rule#rules/}"
  test=${test%.yml}.test.yml
  app="$work/$id"
  mkdir -p "$app"
  yq -r '.invalid[0]' "$test" >"$work/payload"
  [[ -s $work/payload ]] || {
    printf 'Missing invalid example: %s\n' "$test" >&2
    exit 1
  }
  case $(yq '.language' "$rule") in
  TypeScript) extensions='ts mts cts' ;;
  Tsx) extensions=tsx ;;
  JavaScript) extensions='js jsx mjs cjs' ;;
  Json)
    if [[ $scope == biome ]]; then extensions='json jsonc'; else extensions=json; fi
    ;;
  Yaml) extensions='yml yaml' ;;
  *)
    printf 'Unsupported fixture language: %s\n' "$rule" >&2
    exit 1
    ;;
  esac
  : >"$work/expected"
  for ext in $extensions; do
    case $scope in
    package) name=package.json ;;
    manifest) name=manifest.$ext ;;
    catalog) name=catalog-info.$ext ;;
    biome) name=biome.$ext ;;
    hooks) name=lefthook.yml ;;
    tsconfig) name=tsconfig.json ;;
    typecheck) name=tsconfig.typecheck.json ;;
    vitest) name=vitest.config.ts ;;
    frontend-index) name=index.$ext ;;
    *) name=source.$ext ;;
    esac
    case $scope in
    frontend | frontend-index) target=frontend ;;
    resolvers | backend | entry) target=resolvers ;;
    *) target=. ;;
    esac
    for directory in . nested src frontend nested/frontend backend resolvers external import-lifecycle static/custom-ui lib; do
      included=false
      case $scope:$directory in
      catalog:*) [[ $ext != yaml ]] || included=true ;;
      all:* | package:* | manifest:* | biome:* | hooks:* | tsconfig:* | typecheck:* | vitest:*) included=true ;;
      non-frontend:frontend | non-frontend:nested/frontend) ;;
      non-frontend:*) included=true ;;
      frontend:frontend | frontend:nested/frontend | frontend-index:frontend | frontend-index:nested/frontend) included=true ;;
      resolvers:resolvers | backend:resolvers | backend:external | backend:import-lifecycle | entry:resolvers | entry:external | entry:import-lifecycle) included=true ;;
      *) ;;
      esac
      prefixes=.
      if [[ $directory == "$target" ]]; then
        prefixes='. nested/dist node_modules dep/node_modules dist coverage nested/coverage specs nested/specs build vendor fixtures spec test tests __tests__ tests/helpers tests/config'
      fi
      for prefix in $prefixes; do
        path="$prefix/$directory/$name"
        path=${path#./}
        path=${path#./}
        path=${path//\/\.\//\/}
        mkdir -p "$app/$(dirname "$path")"
        cp "$work/payload" "$app/$path"
        expected=$included
        case $prefix in
        nested/dist | node_modules | dep/node_modules | dist | coverage | nested/coverage | specs | nested/specs) expected=false ;;
        test | tests | __tests__ | tests/helpers | tests/config) [[ $tests == include ]] || expected=false ;;
        esac
        [[ $expected == false ]] || printf '%s\n' "$path" >>"$work/expected"
      done
      for suffix in test spec; do
        path="$directory/source.$suffix.$ext"
        path=${path#./}
        mkdir -p "$app/$(dirname "$path")"
        cp "$work/payload" "$app/$path"
        if [[ $included == true && $tests == include && $scope != frontend-index && $name == source.* ]]; then
          printf '%s\n' "$path" >>"$work/expected"
        fi
      done
      if [[ $scope == entry && $directory == src ]]; then
        for prefix in . nested build fixtures tests/helpers tests/config dist coverage specs node_modules; do
          path="$prefix/src/index.$ext"
          path=${path#./}
          mkdir -p "$app/$(dirname "$path")"
          cp "$work/payload" "$app/$path"
          [[ $ext == ts ]] || continue
          case $prefix in
          dist | coverage | specs | node_modules) continue ;;
          tests/helpers | tests/config) [[ $tests == include ]] || continue ;;
          esac
          printf '%s\n' "$path" >>"$work/expected"
        done
      fi
    done
    # Similar names must not widen filename-specific policies.
    if [[ $name != source.* ]]; then
      cp "$work/payload" "$app/other.$ext"
    fi
  done
  sort -u "$work/expected" -o "$work/expected"
  for config in recommended strict atlassian ecosol; do
    active=false
    case $tier:$config in
    recommended:* | strict:strict | strict:atlassian | strict:ecosol | atlassian:atlassian | atlassian:ecosol | ecosol:ecosol) active=true ;;
    esac
    status=0
    # A recommended sentinel keeps filters nonempty in tiers without this rule.
    ast-grep scan --config "sgconfig.$config.yml" --filter "^($id|no-package-main)$" --no-ignore hidden --no-ignore vcs --no-ignore dot --no-ignore global --no-ignore exclude --json=compact "$app" >"$work/scan.json" 2>"$work/errors" || status=$?
    if [[ $status -gt 1 ]] || ! jq -e 'type == "array"' "$work/scan.json" >/dev/null; then
      printf 'Scanner failed for %s in %s (status %s)\n' "$id" "$config" "$status" >&2
      exit 1
    fi
    jq -r --arg id "$id" --arg root "$app/" '.[] | select(.ruleId == $id) | .file | ltrimstr($root)' "$work/scan.json" | sort -u >"$work/actual"
    if [[ $active == true ]]; then
      cp "$work/expected" "$work/tier-expected"
    else
      : >"$work/tier-expected"
    fi
    if ! diff -u "$work/tier-expected" "$work/actual"; then
      printf 'Unexpected routing: %s in %s; evidence: %s\n' "$id" "$config" "$work" >&2
      exit 1
    fi
  done
  count=$((count + 1))
done <rule-tests/fixtures/scope-routing.tsv
if [[ $# == 0 ]]; then
  printf '%s\n' rules/*/*/*.yml | sort >"$work/definitions"
  awk -F '\t' '!/^#/ && NF { print $1 }' rule-tests/fixtures/scope-routing.tsv | sort >"$work/cases"
  diff -u "$work/definitions" "$work/cases" || {
    printf 'Missing, duplicate or stale scope cases\n' >&2
    exit 1
  }
fi
[[ $count -gt 0 ]] || {
  printf 'No scope cases selected\n' >&2
  exit 1
}
printf 'Scope routing passed: %s definitions across four shipped tiers.\n' "$count"
