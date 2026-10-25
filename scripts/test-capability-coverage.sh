#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh || exit 2
pattern="\$A"

report=$(bash scripts/report-capability-coverage.sh)
expected=$'gitignore\tunsupported\t'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "gitignore"')
if [[ $actual != "$expected" ]]; then
  printf 'FAIL: gitignore must be reported as unsupported, not implemented or unmapped; got: %s\n' "$actual" >&2
  exit 1
fi
printf 'PASS: gitignore coverage is explicitly unsupported\n'

expected=$'package-metadata\timplemented\trequire-package-private-true,require-package-type-module'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "package-metadata"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: existing package metadata checks must remain discoverable; got: %s\n' "$actual" >&2
  exit 1
}
[[ $(printf '%s\n' "$report" | tail -n +2 | cut -f1) == "$(yq -r '.capabilities[]' authoring/policy.yml)" ]]
# A disabled placeholder is not an acceptable substitute for the gap either.
[[ -z $(yq -N -r 'select((.metadata.tags // []) | contains(["capability:gitignore"])) | .id' rules/*/*/*.yml) ]]
printf 'PASS: active mappings are discoverable without a gitignore placeholder\n'

expected=$'node\timplemented\trequire-package-license-apache-2-0,use-node-24'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "node"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: node coverage must expose package engines and catalog-derived licensing checks; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: node coverage exposes engines and catalog-derived licensing checks\n'

expected=$'forge-manifest\timplemented\tlint-with-forge,require-numeric-forge-runtime'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "forge-manifest"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: manifest coverage must expose runtime shape and the Forge lint entrypoint; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: manifest runtime shape and Forge lint entrypoint are discoverable\n'

expected=$'changelog\timplemented\trequire-changelog-script'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "changelog"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: changelog regeneration must be discoverable; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: changelog regeneration entrypoint is discoverable\n'

expected=$'release\timplemented\trequire-release-check-script,require-release-script'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "release"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: explicit release and owner validation entrypoints must be discoverable; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: explicit release and owner validation entrypoints are discoverable\n'

expected=$'secrets\timplemented\tno-unguarded-fence-rider-evaluation,require-fence-rider-script-execution,use-fence-rider-for-forge-deploy,use-fence-rider-for-forge-install,use-fence-rider-for-forge-uninstall,use-fence-rider-for-forge-variables,use-forge-deploy,use-forge-install,use-forge-register,use-forge-uninstall,use-forge-upgrade,use-forge-variables-set'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "secrets"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: lifecycle naming, wrappers and execution safety must be discoverable without lint/tunnel preferences; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: secrets lifecycle conventions are discoverable without optional lint/tunnel preferences\n'

expected=$'prelint\timplemented\tlint-with-forge,lint-with-prelint,require-prelint-node-modules-glob,require-prelint-specs-glob,require-valid-prelint-config'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "prelint"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: Prelint tasks, config and both exclusion checks must be discoverable; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: Prelint tasks, config and both exclusions are discoverable\n'

expected=$'biome\timplemented\tlint-and-format-with-biome,no-write-flags-in-readonly-script,require-biome-files-exclude-dist,require-biome-formatter-indent-style,require-biome-vcs-default-branch,require-biome-vcs-use-ignore-file'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "biome"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: Biome scripts and reviewed configuration defaults must be discoverable; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: Biome scripts and reviewed configuration defaults are discoverable\n'

expected=$'lint\timplemented\tno-write-flags-in-readonly-script,require-composed-check,require-composed-lint'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "lint"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: lint aggregates and the shared read-only guard must be discoverable; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: lint aggregates and shared read-only guard are discoverable\n'

expected=$'test\timplemented\trequire-vitest-coverage-script,require-vitest-globals-false,require-vitest-run-script,use-explicit-vitest-watch'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "test"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: Vitest run, watch, coverage and explicit-globals conventions must be discoverable as test; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: Vitest conventions are discoverable under the test capability\n'

expected=$'typescript\timplemented\tlint-with-typescript,no-forge-jsx-factory-override-mismatch,no-forge-jsx-override-mismatch,no-forge-source-map-override-mismatch,require-tsconfig-include-src,require-tsconfig-lib-es2022,require-tsconfig-module-resolution-node,require-tsconfig-out-dir-dist,require-tsconfig-root-dir-src,require-tsconfig-target-es2022,require-tsconfig-typecheck-exact-optional-property-types,require-tsconfig-typecheck-extends-no-emit,require-tsconfig-typecheck-include-tests,require-tsconfig-typecheck-no-implicit-override,require-tsconfig-typecheck-no-implicit-returns,require-tsconfig-typecheck-no-property-access-from-index-signature,require-tsconfig-typecheck-no-unchecked-indexed-access,require-tsconfig-typecheck-no-unchecked-side-effect-imports,require-typescript-build-script,typecheck-with-typescript,use-tsconfig-consistent-file-casing,use-tsconfig-es-module-interop,use-tsconfig-skip-lib-check,use-tsconfig-strict-mode,use-typescript-5'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "typescript"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: compiler, build and typecheck conventions must be discoverable as typescript; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: compiler, build and typecheck conventions are discoverable\n'

expected=$'forge-ahead\timplemented\tuse-forge-ahead-api-types,use-forge-ahead-errors,use-forge-ahead-logging'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "forge-ahead"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: Forge Ahead dependency conventions must be discoverable without runtime logging advice; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: Forge Ahead dependency conventions are discoverable\n'

expected=$'size-limit\timplemented\tno-size-limit-preset-app,require-size-check-script,use-size-limit'
actual=$(printf '%s\n' "$report" | awk -F '\t' '$1 == "size-limit"')
[[ $actual == "$expected" ]] || {
  printf 'FAIL: size-budget advice, file preset and build-before-measure checks must be discoverable; got: %s\n' "$actual" >&2
  exit 1
}
printf 'PASS: size-limit conventions are discoverable without aggregate or hook ownership\n'

mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_gitignore.XXXXXX")
# These are Git ignore syntax, not shell programs or YAML/JSON documents.
cp fixtures/drop-calf-forge-app/.gitignore "$work/.gitignore"
printf '\n# Owner content\n!keep/\n**/*.tmp\n/root-only/\n\\#literal\n\\!literal\n' >>"$work/.gitignore"
for language in gitignore ignore text; do
  if ast-grep run --lang "$language" --pattern "$pattern" --stdin <"$work/.gitignore" >"$work/output" 2>"$work/error"; then
    printf 'FAIL: %s is now supported; reassess the gitignore coverage gap\n' "$language" >&2
    exit 1
  fi
  grep -Fq "$language is not supported" "$work/error" || {
    printf 'FAIL: parser probe failed for a reason other than unsupported %s\n' "$language" >&2
    exit 1
  }
done
printf 'PASS: installed ast-grep has no gitignore, ignore or text language\n'

# Catch-all positive control prevents a broken CLI from looking like no coverage.
printf 'const value = 1;\n' >"$work/control.ts"
ast-grep run --pattern "$pattern" --no-ignore hidden --no-ignore vcs --json=compact "$work/control.ts" >"$work/control.json"
jq -e 'length > 0' "$work/control.json" >/dev/null
cp "$work/.gitignore" "$work/generated.txt"
for variant in generated missing-end nested; do
  cp "$work/generated.txt" "$work/.gitignore"
  case "$variant" in
  missing-end) printf '# Created by drop-calf additional ignores\n.scratch/\n' >>"$work/.gitignore" ;;
  nested) printf '# Created by drop-calf additional ignores\n# Created by drop-calf additional ignores\n# End of drop-calf additional ignores\n# End of drop-calf additional ignores\n' >>"$work/.gitignore" ;;
  esac
  # Explicit input, hidden/VCS overrides and inclusion globs remove ignore filtering
  # as an explanation. No matches means no native coverage, NOT a valid file.
  ast-grep run --pattern "$pattern" --no-ignore hidden --no-ignore vcs \
    --globs '**/.gitignore' --json=compact "$work/.gitignore" >"$work/$variant.json" || {
    status=$?
    [[ $status == 1 ]] || exit "$status"
  }
  jq -e 'type == "array" and length == 0' "$work/$variant.json" >/dev/null || {
    printf 'FAIL: native .gitignore routing changed for %s; reassess coverage\n' "$variant" >&2
    exit 1
  }
done
printf 'PASS: native routing does not validate generated or malformed ignore files\n'

# Exercise reporting without editing real rules or freezing other ticket mappings.
repo="$work/report-repo"
mkdir -p "$repo/scripts" "$repo/authoring" "$repo/rules/ecosol/devtools"
cp scripts/report-capability-coverage.sh scripts/rule-metadata-env.sh "$repo/scripts/"
cp authoring/policy.yml "$repo/authoring/"
printf 'id: example\nseverity: off\nmetadata: {tags: [capability:catalog]}\n' >"$repo/rules/ecosol/devtools/example.yml"
report=$(bash "$repo/scripts/report-capability-coverage.sh")
[[ $(printf '%s\n' "$report" | awk -F '\t' '$1 == "catalog"') == $'catalog\tnot-mapped\t' ]] || {
  printf 'FAIL: disabled rules must not appear as implemented coverage\n' >&2
  exit 1
}
# Even an off placeholder must not hide the explicitly unsupported disposition.
for severity in off info; do
  printf 'id: example\nseverity: %s\nmetadata: {tags: [capability:gitignore]}\n' "$severity" >"$repo/rules/ecosol/devtools/example.yml"
  if bash "$repo/scripts/report-capability-coverage.sh" >"$work/conflict.tsv" 2>"$work/conflict.error"; then
    printf 'FAIL: %s gitignore placeholder must conflict with unsupported coverage\n' "$severity" >&2
    exit 1
  fi
  [[ ! -s "$work/conflict.tsv" ]]
  grep -Fq 'Unsupported capability has rule tags: gitignore' "$work/conflict.error"
done
printf 'PASS: disabled rules are not implemented and conflicting tags fail without partial TSV\n'
