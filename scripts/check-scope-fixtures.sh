#!/usr/bin/env bash
# Public seam: scan real files with shipped configs; snippets cannot test routing.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh
# Changed rule paths can be checked alone; changes to routing infrastructure need
# the complete matrix. An unknown/deleted rule also falls back to the full run.
selected=()
full=false
[[ $# -gt 0 ]] || full=true
for path in "$@"; do
  case $path in
    rules/*/*/*.yml)
      if [[ -f $path ]] && awk -F '\t' -v path="$path" '$1 == path { found = 1 } END { exit !found }' rule-tests/fixtures/scope-routing.tsv; then
        selected+=("$path")
      else
        full=true
      fi
      ;;
    *) full=true ;;
  esac
done
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_scope.XXXXXX")
phase_started=$SECONDS
report_timing() {
  printf 'scope phase %-22s %ss\n' "$1" "$((SECONDS - phase_started))" >&2
  phase_started=$SECONDS
}
# Keep routing evidence under .scratch for maintainer inspection.
for config in recommended strict atlassian ecosol; do
  yq -r '.ruleDirs[]' "sgconfig.$config.yml" >"$work/$config.dirs"
  : >"$work/$config.ids"
  : >"$work/$config.apps"
  : >"$work/$config.expected"
done
count=0
while IFS=$'\t' read -r rule scope tests; do
  [[ $rule != \#* && -n $rule ]] || continue
  if [[ $full == false ]]; then
    found=false
    for path in "${selected[@]}"; do
      [[ $rule == "$path" ]] && found=true
    done
    [[ $found == true ]] || continue
  fi
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
  id=${rule##*/}
  id=${id%.yml}
  tier=${rule#rules/}
  tier=${tier%%/*}
  test="rule-tests/${rule#rules/}"
  test=${test%.yml}.test.yml
  app="$work/$id"
  mkdir -p "$app"
  payload="$app/payload"
  metadata="$work/metadata"
  TEST_FILE="$test" yq -r '[.language, (load(strenv(TEST_FILE)).invalid[0])] | .[]' "$rule" >"$metadata"
  {
    IFS= read -r language || true
    while IFS= read -r line || [[ -n $line ]]; do
      printf '%s\n' "$line"
    done
  } <"$metadata" >"$payload"
  [[ -s $payload ]] || {
    printf 'Missing invalid example: %s\n' "$test" >&2
    exit 1
  }
  case $language in
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
        parent="$app/$(dirname "$path")"
        [[ -d $parent ]] || mkdir -p "$parent"
        [[ -e $app/$path ]] || ln "$payload" "$app/$path"
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
        parent="$app/$(dirname "$path")"
        [[ -d $parent ]] || mkdir -p "$parent"
        ln "$payload" "$app/$path"
        if [[ $included == true && $tests == include && $scope != frontend-index && $name == source.* ]]; then
          printf '%s\n' "$path" >>"$work/expected"
        fi
      done
      if [[ $scope == entry && $directory == src ]]; then
        for prefix in . nested build fixtures tests/helpers tests/config dist coverage specs node_modules; do
          path="$prefix/src/index.$ext"
          path=${path#./}
          parent="$app/$(dirname "$path")"
          [[ -d $parent ]] || mkdir -p "$parent"
          ln "$payload" "$app/$path"
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
      ln "$payload" "$app/other.$ext"
    fi
  done
  sort -u "$work/expected" -o "$work/expected"
  directory=${rule%/*}
  for config in recommended strict atlassian ecosol; do
    active=false
    case $tier:$config in
    recommended:* | strict:strict | strict:atlassian | strict:ecosol | atlassian:atlassian | atlassian:ecosol | ecosol:ecosol) active=true ;;
    esac
    configured=false
    grep -Fqx "$directory" "$work/$config.dirs" && configured=true
    if [[ $active != "$configured" ]]; then
      printf 'Unexpected rule-directory membership: %s in %s (expected %s)\n' \
        "$directory" "$config" "$active" >&2
      exit 1
    fi
    [[ $active == true ]] || continue
    printf '%s\n' "$id" >>"$work/$config.ids"
    printf '%s\n' "$app" >>"$work/$config.apps"
    while IFS= read -r path; do
      printf '%s\t%s\n' "$id" "$path" >>"$work/$config.expected"
    done <"$work/expected"
  done
  count=$((count + 1))
done <rule-tests/fixtures/scope-routing.tsv
report_timing fixture-generation

for tier in recommended strict atlassian ecosol; do
  [[ -s $work/$tier.ids ]] || continue
  ids=$(paste -sd '|' "$work/$tier.ids")
  apps=()
  while IFS= read -r app; do
    apps[${#apps[@]}]=$app
  done <"$work/$tier.apps"
  status=0
  ast-grep scan --config "sgconfig.$tier.yml" --filter "^($ids)$" \
    --no-ignore hidden --no-ignore vcs --no-ignore dot --no-ignore global --no-ignore exclude \
    --json=compact "${apps[@]}" >"$work/$tier.scan.json" 2>"$work/$tier.errors" || status=$?
  if [[ $status -gt 1 ]] || ! jq -e 'type == "array"' "$work/$tier.scan.json" >/dev/null; then
    printf 'Scanner failed for %s routing (status %s)\n' "$tier" "$status" >&2
    cat "$work/$tier.errors" >&2
    exit 1
  fi
  report_timing "$tier-scan"
  jq -r --arg root "$work/" '
    .[] | .ruleId as $id | (.file | ltrimstr($root)) as $path |
    select($path | split("/")[0] == $id) |
    [$id, ($path | sub("^[^/]+/"; ""))] | @tsv
  ' "$work/$tier.scan.json" | sort -u >"$work/$tier.actual"
  sort -u "$work/$tier.expected" -o "$work/$tier.expected"
  if ! diff -u "$work/$tier.expected" "$work/$tier.actual"; then
    printf 'Unexpected routing in %s; evidence: %s\n' "$tier" "$work" >&2
    exit 1
  fi
  report_timing "$tier-compare"
done
printf '%s\n' rules/*/*/*.yml | sort >"$work/definitions"
awk -F '\t' '!/^#/ && NF { print $1 }' rule-tests/fixtures/scope-routing.tsv | sort >"$work/cases"
diff -u "$work/definitions" "$work/cases" || {
  printf 'Missing, duplicate or stale scope cases\n' >&2
  exit 1
}
[[ $count -gt 0 ]] || {
  printf 'No scope cases selected\n' >&2
  exit 1
}
printf 'Scope routing passed: %s definitions across four shipped tiers.\n' "$count"
