#!/usr/bin/env bash
# Public seam: native scans of package delegates and distinct compiler configs.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_typescript.XXXXXX")

for variant in generated bun missing inert wrong-target nested missing-typecheck; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  bun) edit='.scripts["lint:check:typecheck"] = "bun run typecheck"' ;;
  missing)
    edit='del(.scripts["lint:check:typecheck"])'
    expected='lint-with-typescript'
    ;;
  inert)
    edit='.scripts["lint:check:typecheck"] = "echo npm run typecheck"'
    expected='lint-with-typescript'
    ;;
  wrong-target)
    edit='.scripts["lint:check:typecheck"] = "npm run build"'
    expected='lint-with-typescript'
    ;;
  nested)
    edit='.config.scripts = .scripts | del(.scripts["lint:check:typecheck"])'
    expected='lint-with-typescript'
    ;;
  missing-typecheck)
    edit='del(.scripts.typecheck)'
    expected='typecheck-with-typescript'
    ;;
  esac
  # Apply only the pinned script wiring to the older generated snapshot.
  jq '.scripts["lint:check:typecheck"] = "npm run typecheck"' fixtures/drop-calf-forge-app/package.json |
    jq "$edit" >"$work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^(lint-with-typescript|require-typescript-build-script|typecheck-with-typescript)$' --json=compact "$work/package.json")
  actual=$(printf '%s\n' "$findings" | jq -r '.[].ruleId' | sort)
  [[ $actual == "$expected" ]] || {
    printf 'Unexpected TypeScript delegate findings for %s: expected "%s", got "%s"\n' "$variant" "$expected" "$actual" >&2
    exit 1
  }
done
printf 'PASS: TypeScript build/typecheck commands and isolated lint delegate mutations\n'

# JSONC content uses the conventional .json filenames, as TypeScript does.
# No cross-file resolution, compiler, build task or package command is executed.
filter='^(no-forge-(jsx.*|source-map.*)|require-tsconfig-.*|use-tsconfig-.*)$'
for config in base typecheck; do
  name=tsconfig.json
  if [[ $config == typecheck ]]; then name=tsconfig.typecheck.json; fi
  cp "fixtures/drop-calf-forge-app/$name" "$work/input.json"
  # Use the installed parser, not text substitution, to remove JSONC comments.
  ast-grep run --lang json --kind comment --rewrite '' --update-all \
    --no-ignore hidden --no-ignore vcs "$work/input.json" >"$work/rewrite.log" || [[ $? == 1 ]]
  for variant in generated owner-options node bundler root-dir inherited missing-no-emit missing-include; do
    expected=''
    edit='.'
    case "$config:$variant" in
    *:generated) ;;
    *:owner-options) edit='.compilerOptions.paths = {"@owner/*": ["src/*"]} | .compilerOptions.types = ["node", "owner"]' ;;
    base:node) edit='.compilerOptions.moduleResolution = "node"' ;;
    typecheck:node) edit='.compilerOptions.moduleResolution = "Node" | .include = ["src", "test", "tests"]' ;;
    base:bundler)
      edit='.compilerOptions.moduleResolution = "Bundler"'
      expected='require-tsconfig-module-resolution-node'
      ;;
    typecheck:bundler) edit='.compilerOptions.moduleResolution = "Bundler"' ;;
    base:root-dir)
      edit='.compilerOptions.rootDir = "."'
      expected='require-tsconfig-root-dir-src'
      ;;
    typecheck:root-dir) edit='.compilerOptions.rootDir = "."' ;;
    base:inherited) edit='{"extends": "./owner-base.json"}' ;;
    typecheck:missing-no-emit)
      edit='del(.compilerOptions.noEmit)'
      expected='require-tsconfig-typecheck-extends-no-emit'
      ;;
    typecheck:missing-include)
      edit='del(.include)'
      expected='require-tsconfig-typecheck-include-tests'
      ;;
    *) continue ;;
    esac
    if [[ $variant == generated ]]; then
      cp "fixtures/drop-calf-forge-app/$name" "$work/$name"
    else
      jq "$edit" "$work/input.json" >"$work/$name"
    fi
    findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter "$filter" \
      --include-metadata --json=compact "$work/$name")
    if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
      ([.[].ruleId] | sort | join("\n")) == $expected and
      all(.[]; .metadata.tags | index("capability:typescript") != null)
    ' >/dev/null; then
      printf 'Unexpected %s compiler findings for %s: expected "%s", got %s\n' "$config" "$variant" "$expected" "$findings" >&2
      exit 1
    fi
  done
done

# Even without extends, base-only defaults must not leak into variants.
printf '%s\n' '// Local-only compiler config' '{"compilerOptions":{"moduleResolution":"Bundler","rootDir":"."}}' >"$work/variant.txt"
for name in tsconfig.typecheck.json tsconfig.build.json tsconfig.declarations.json tsconfig.jsonc unrelated.json; do
  cp "$work/variant.txt" "$work/$name"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-tsconfig-(module-resolution-node|root-dir-src)$' --json=compact "$work/$name")
  printf '%s\n' "$findings" | jq -e 'type == "array" and length == 0' >/dev/null || {
    printf 'Base compiler policy leaked into %s: %s\n' "$name" "$findings" >&2
    exit 1
  }
done
printf 'PASS: JSONC base/typecheck configs, resolver variants, inherited backoff and isolated mutations\n'
