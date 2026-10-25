#!/usr/bin/env sh
set -eu

FIXTURE_DIR="rule-tests/fixtures/repo-init-forge-app"
OUTPUT=$(ast-grep scan --config sgconfig.ecosol.yml "$FIXTURE_DIR")

if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT"
  echo
  echo "$FIXTURE_DIR is meant to model a fully repo-init-compliant Forge app and" >&2
  echo "should produce zero ecosol findings. See the output above for what drifted." >&2
  exit 1
fi

echo "$FIXTURE_DIR produced zero ecosol findings, as expected."

# Drop Calf's default forge-app output is generated separately. Validate each
# supported convention subset without treating unrelated gaps as compliance.
DROP_CALF_BIOME="fixtures/drop-calf-forge-app/biome.jsonc"
if [ ! -f "$DROP_CALF_BIOME" ]; then
  echo "Missing Drop Calf fixture: $DROP_CALF_BIOME" >&2
  exit 1
fi
if ! grep -Fq '"!!**/dist"' "$DROP_CALF_BIOME"; then
  echo "Expected a hard exclusion for nested dist in $DROP_CALF_BIOME" >&2
  exit 1
fi
matches=$(ast-grep scan --config sgconfig.ecosol.yml \
  --rule rules/ecosol/devtools/require-biome-files-exclude-dist.yml \
  --files-with-matches "$DROP_CALF_BIOME")
if [ -n "$matches" ]; then
  echo "Drop Calf's hard dist exclusion was flagged: $matches" >&2
  exit 1
fi
echo "$DROP_CALF_BIOME hard-excludes dist without a finding."

# Catalog seed values are examples, not a frozen title, lifecycle or year policy.
DROP_CALF_CATALOG="fixtures/drop-calf-forge-app/catalog-info.yaml"
if [ ! -f "$DROP_CALF_CATALOG" ]; then
  echo "Missing Drop Calf fixture: $DROP_CALF_CATALOG" >&2
  exit 1
fi
catalog_findings=$(ast-grep scan --config sgconfig.ecosol.yml \
  --filter '^require-catalog-' --json=compact "$DROP_CALF_CATALOG")
if ! printf '%s\n' "$catalog_findings" | jq -e 'type == "array" and length == 0' >/dev/null; then
  echo "Generated Drop Calf catalog must pass catalog convention checks: $catalog_findings" >&2
  exit 1
fi
echo "$DROP_CALF_CATALOG produced zero catalog convention findings."

# Package metadata maps existing policies without freezing catalog identity or version.
DROP_CALF_PACKAGE="fixtures/drop-calf-forge-app/package.json"
mkdir -p .scratch
package_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_package_metadata.XXXXXX")
for variant in generated commonjs missing-type public missing-private owner-metadata; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  commonjs)
    edit='.type = "commonjs"'
    expected='require-package-type-module'
    ;;
  missing-type)
    edit='del(.type)'
    expected='require-package-type-module'
    ;;
  public)
    edit='.private = false'
    expected='require-package-private-true'
    ;;
  missing-private)
    edit='del(.private)'
    expected='require-package-private-true'
    ;;
  owner-metadata) edit='.name = "@example/custom-app" | .version = "2.3.4-beta.1" | .description = "Owner-authored description" | del(.author)' ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$package_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-package-(type-module|private-true)$' \
    --json=compact "$package_work/package.json")
  actual=$(printf '%s\n' "$findings" | jq -r '.[].ruleId' | sort)
  if [ "$actual" != "$expected" ]; then
    printf 'Unexpected package metadata findings for %s: expected "%s", got "%s"\n' \
      "$variant" "$expected" "$actual" >&2
    exit 1
  fi
done
echo "$DROP_CALF_PACKAGE and metadata mutations produced the expected findings."

# Forge Ahead declarations are static seed advice, not runtime integration proof.
forge_ahead_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_forge_ahead.XXXXXX")
for variant in generated api-app owner-references; do
  case "$variant" in
  generated) edit='.' ;;
  api-app) edit='.dependencies["@forge/api"] = "^7"' ;;
  owner-references) edit='.dependencies |= with_entries(.value = "file:../owner-helper")' ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$forge_ahead_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^use-forge-ahead-' \
    --json=compact "$forge_ahead_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e 'type == "array" and length == 0' >/dev/null; then
    printf 'Unexpected Forge Ahead findings for %s: %s\n' "$variant" "$findings" >&2
    exit 1
  fi
done
for helper in api-types errors logging; do
  package="@forge-ahead/$helper"
  if [ "$helper" = api-types ]; then package='@forge-ahead/atlassian-api-types'; fi
  for section in missing devDependencies config scripts; do
    jq --arg package "$package" --arg section "$section" '
      .dependencies["@forge/api"] = "^7" |
      .dependencies[$package] as $reference |
      del(.dependencies[$package]) |
      if $section == "missing" then .
      elif $section == "config" then .config.dependencies[$package] = $reference
      else .[$section][$package] = $reference end
    ' "$DROP_CALF_PACKAGE" >"$forge_ahead_work/package.json"
    findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^use-forge-ahead-' \
      --include-metadata --json=compact "$forge_ahead_work/package.json")
    if ! printf '%s\n' "$findings" | jq -e --arg rule "use-forge-ahead-$helper" '
      type == "array" and length == 1 and
      all(.[]; .ruleId == $rule and .severity == "info" and
        (.metadata.tags | index("capability:forge-ahead") != null))
    ' >/dev/null; then
      printf 'Unexpected Forge Ahead findings for %s in %s: %s\n' "$helper" "$section" "$findings" >&2
      exit 1
    fi
  done
done
gate=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^use-forge-ahead-' \
  --min-severity error --json=compact "$forge_ahead_work/package.json")
printf '%s\n' "$gate" | jq -e 'type == "array" and length == 0' >/dev/null
echo 'Generated Forge Ahead declarations, owner references and placement mutations produced expected advisory findings.'

# TODO tooling is optional seed advice; scan text without running owner commands.
todo_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_todo.XXXXXX")
for variant in generated custom logging-first no-markers missing non-string nested inert empty noop lookalike; do
  expected=1
  case "$variant" in
  generated)
    edit='.'
    expected=0
    ;;
  custom)
    edit='.scripts.todo = "bash scripts/owner-tasks.sh"'
    expected=0
    ;;
  logging-first)
    edit='.scripts.todo = "echo Scanning && owner-todo"'
    expected=0
    ;;
  no-markers)
    edit='.scripts.todo = "owner-task-list"'
    expected=0
    ;;
  missing) edit='del(.scripts.todo)' ;;
  non-string) edit='.scripts.todo = ["owner-todo"]' ;;
  nested) edit='.metadata.scripts.todo = .scripts.todo | del(.scripts.todo)' ;;
  inert) edit='.scripts.todo = "echo No markers found"' ;;
  empty) edit='.scripts.todo = "  "' ;;
  noop) edit='.scripts.todo = "exit 0"' ;;
  lookalike) edit='.scripts.todos = .scripts.todo | del(.scripts.todo)' ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$todo_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^prefer-todo-script$' \
    --include-metadata --json=compact "$todo_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --argjson count "$expected" '
    type == "array" and length == $count and
    all(.[]; .ruleId == "prefer-todo-script" and .severity == "hint" and
      (.metadata.tags | index("capability:todo") != null))
  ' >/dev/null; then
    printf 'Unexpected TODO entrypoint findings for %s: expected %s, got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
# Intentional removal stays nonblocking and supports explicit owner opt-out.
for mode in --min-severity=error --off=prefer-todo-script; do
  advice=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^prefer-todo-script$' \
    "$mode" --json=compact "$todo_work/package.json")
  printf '%s\n' "$advice" | jq -e 'type == "array" and length == 0' >/dev/null
done
echo 'Generated TODO command, optional mutations and owner opt-out produced expected advice.'

# Clean command checks inspect text only; never invoke cleanup on these fixtures.
clean_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_clean_build.XXXXXX")
for variant in generated relative missing non-string nested inert lookalike source root reinstall lockfile chain; do
  expected=1
  case "$variant" in
  generated)
    edit='.'
    expected=0
    ;;
  relative)
    edit='.scripts.clean = "  rm  -rf  ./dist/  "'
    expected=0
    ;;
  missing) edit='del(.scripts.clean)' ;;
  non-string) edit='.scripts.clean = ["rm -rf dist"]' ;;
  nested) edit='.config.scripts.clean = .scripts.clean | del(.scripts.clean)' ;;
  inert) edit='.scripts.clean = "echo '\''rm -rf dist'\''"' ;;
  lookalike) edit='.scripts.clean = "rm -rf distribution"' ;;
  source) edit='.scripts.clean = "rm -rf src"' ;;
  root) edit='.scripts.clean = "rm -rf ."' ;;
  reinstall) edit='.scripts.clean = "rm -rf node_modules package-lock.json dist"' ;;
  lockfile) edit='.scripts.clean = "rm -rf dist package-lock.json"' ;;
  chain) edit='.scripts.clean = "rm -rf dist && rm -rf src"' ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$clean_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^require-clean-script$' \
    --include-metadata --json=compact "$clean_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --argjson count "$expected" '
    type == "array" and length == $count and
    all(.[]; .ruleId == "require-clean-script" and .severity == "info" and
      (.metadata.tags | index("capability:clean-build") != null))
  ' >/dev/null; then
    printf 'Unexpected clean command findings for %s: expected %s, got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo 'Generated dist-only clean command and static mutations produced expected findings.'

# Size Limit checks static declarations only; never build or measure owner output.
size_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_size_limit.XXXXXX")
for variant in generated owner-budget custom-size legacy-size missing-check no-build preset-app; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  owner-budget)
    edit='.["size-limit"] = [{"name": "Owner worker", "path": "build/worker.mjs", "limit": "75 kB"}] |
      .devDependencies["size-limit"] = "^99" | .devDependencies["@size-limit/file"] = "^99"'
    ;;
  custom-size) edit='.scripts.size = "bash scripts/owner-size.sh"' ;;
  legacy-size) edit='.scripts.size = "npm run build && size-limit"' ;;
  missing-check)
    edit='del(.scripts["size:check"])'
    expected='require-size-check-script'
    ;;
  no-build)
    edit='.scripts["size:check"] = "size-limit"'
    expected='require-size-check-script'
    ;;
  preset-app)
    edit='del(.devDependencies["@size-limit/file"]) | .devDependencies["@size-limit/preset-app"] = "^14"'
    expected='no-size-limit-preset-app'
    ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$size_work/package.json"
  findings=$(ast-grep scan --config sgconfig.recommended.yml \
    --filter '^(use-size-limit|no-size-limit-preset-app|require-size-check-script)$' \
    --include-metadata --json=compact "$size_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    ([.[].ruleId] | unique | join("\n")) == $expected and
    all(.[]; .metadata.tags | index("capability:size-limit") != null)
  ' >/dev/null; then
    printf 'Unexpected Size Limit findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
  if [ "$variant" = missing-check ]; then
    if ! printf '%s\n' "$findings" | jq -e '
      length > 0 and all(.[];
        .severity == "info" and
        (.note | test("pre-push.*`check`.*`size:check`")) and
        (.note | contains("calls this script directly") | not))
    ' >/dev/null; then
      printf 'Size Limit diagnostic must describe pre-push through check to size:check: %s\n' "$findings" >&2
      exit 1
    fi
  fi
done
echo 'Generated Size Limit declarations, owner budgets/scripts and isolated mutations produced expected findings.'

# Vitest conventions map command/config text, not test execution or coverage quality.
vitest_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_vitest.XXXXXX")
for variant in generated no-optional-flag flag-order watch-default implicit-watch missing-coverage disabled-coverage; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  no-optional-flag) edit='.scripts |= with_entries(if (.key | startswith("test")) then .value |= sub(" --passWithNoTests"; "") else . end)' ;;
  flag-order) edit='.scripts["test:coverage"] = "vitest run --passWithNoTests --coverage"' ;;
  watch-default)
    edit='.scripts.test = "vitest run --watch"'
    expected='require-vitest-run-script'
    ;;
  implicit-watch)
    edit='.scripts["test:watch"] = "vitest"'
    expected='use-explicit-vitest-watch'
    ;;
  missing-coverage)
    edit='del(.scripts["test:coverage"])'
    expected='require-vitest-coverage-script'
    ;;
  disabled-coverage)
    edit='.scripts["test:coverage"] = "vitest run --coverage=false"'
    expected='require-vitest-coverage-script'
    ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$vitest_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^(require-vitest-(run-script|coverage-script)|use-explicit-vitest-watch)$' \
    --include-metadata --json=compact "$vitest_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    ([.[].ruleId] | sort | join("\n")) == $expected and
    all(.[]; .metadata.tags | index("capability:test") != null)
  ' >/dev/null; then
    printf 'Unexpected Vitest script findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
for variant in generated owner-config globals-on missing-globals; do
  expected=''
  case "$variant" in
  generated) cp fixtures/drop-calf-forge-app/vitest.config.ts "$vitest_work/vitest.config.ts" ;;
  owner-config) printf '%s\n' 'export default defineConfig({ test: { globals: false, exclude: ["owner/**"], coverage: { provider: "istanbul" } } });' >"$vitest_work/vitest.config.ts" ;;
  globals-on)
    printf '%s\n' 'export default defineConfig({ test: { globals: true } });' >"$vitest_work/vitest.config.ts"
    expected='require-vitest-globals-false'
    ;;
  missing-globals)
    printf '%s\n' 'export default defineConfig({ test: {} });' >"$vitest_work/vitest.config.ts"
    expected='require-vitest-globals-false'
    ;;
  esac
  findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^require-vitest-globals-false$' \
    --include-metadata --json=compact "$vitest_work/vitest.config.ts")
  if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    ([.[].ruleId] | sort | join("\n")) == $expected and
    all(.[]; .severity == "info" and (.metadata.tags | index("capability:test") != null))
  ' >/dev/null; then
    printf 'Unexpected Vitest config findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo 'Generated Vitest scripts/config, optional flags, owner config and isolated mutations produced expected findings.'

# Prelint checks command text only; never execute these package tasks.
prelint_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_prelint.XXXXXX")
jq '.scripts = {
  "lint:check:prelint": "ast-grep scan --globs '\''!specs/**'\'' --globs '\''!node_modules/**'\'' --config ./node_modules/@forge-ahead/prelint/sgconfig.ecosol.yml",
  "lint:check:forge": "forge lint"
}' "$DROP_CALF_PACKAGE" >"$prelint_work/generated.json"
for variant in generated missing-config wrong-config missing-node-modules missing-specs alias legacy unrelated; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  missing-config)
    edit='.scripts["lint:check:prelint"] |= sub(" --config .*"; "")'
    expected='require-valid-prelint-config'
    ;;
  wrong-config)
    edit='.scripts["lint:check:prelint"] |= sub("sgconfig.ecosol.yml"; "biome.json")'
    expected='require-valid-prelint-config'
    ;;
  missing-node-modules)
    edit='.scripts["lint:check:prelint"] |= sub("--globs '\''!node_modules/\\*\\*'\'' "; "")'
    expected='require-prelint-node-modules-glob'
    ;;
  missing-specs)
    edit='.scripts["lint:check:prelint"] |= sub("--globs '\''!specs/\\*\\*'\'' "; "")'
    expected='require-prelint-specs-glob'
    ;;
  alias)
    edit='.scripts["lint:check:prelint"] |= sub("@forge-ahead/prelint/sgconfig.ecosol.yml"; "owner-prelint/sgconfig.strict.yml")'
    ;;
  legacy)
    edit='.scripts["lint:prelint"] = .scripts["lint:check:prelint"] | del(.scripts["lint:check:prelint"])'
    expected='lint-with-prelint'
    ;;
  unrelated) edit='.scripts["lint:check:other"] = "ast-grep scan"' ;;
  esac
  jq "$edit" "$prelint_work/generated.json" >"$prelint_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^(lint-with-(prelint|forge)|require-valid-prelint-config|require-prelint-(node-modules|specs)-glob|use-fence-rider-for-forge-lint)$' \
    --include-metadata --json=compact "$prelint_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    map(.ruleId) == (if $expected == "" then [] else [$expected] end) and
    all(.[]; .severity == "info" and (.metadata.tags | index("capability:prelint") != null))
  ' >/dev/null; then
    printf 'Unexpected Prelint findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo "Pinned Prelint tasks and static mutations produced the expected findings."

# Biome owns package tasks, but its config is seeded then owner-managed.
# Scan command text only; never execute formatting or write-back tasks.
biome_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_biome.XXXXXX")
jq '.scripts |= (del(.["lint:check"]) + {
  "format": "biome format --write",
  "format:check": "biome format",
  "lint:check:biome": "biome lint",
  "lint:check:format": "npm run format:check",
  "lint:fix": "biome lint --write"
})' "$DROP_CALF_PACKAGE" >"$biome_work/generated.json"
for variant in generated bun missing-task write-lint write-format; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  bun) edit='.scripts["lint:check:format"] = "bun run format:check"' ;;
  missing-task)
    edit='del(.scripts["lint:check:format"])'
    expected='lint-and-format-with-biome'
    ;;
  write-lint)
    edit='.scripts["lint:check:biome"] += " --write"'
    expected='no-write-flags-in-readonly-script'
    ;;
  write-format)
    edit='.scripts["format:check"] += " --write"'
    expected='no-write-flags-in-readonly-script'
    ;;
  esac
  jq "$edit" "$biome_work/generated.json" >"$biome_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^(lint-and-format-with-biome|no-write-flags-in-readonly-script)$' \
    --include-metadata --json=compact "$biome_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    map(.ruleId) == (if $expected == "" then [] else [$expected] end) and
    all(.[]; .metadata.tags | index("capability:biome") != null)
  ' >/dev/null; then
    printf 'Unexpected Biome task findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo "Pinned Biome tasks, npm/Bun delegates and read-only mutations produced the expected findings."

for extension in json jsonc; do
  for variant in generated schema owner-options dist indent branch ignore; do
    expected=''
    case "$variant" in
    generated) edit='.' ;;
    schema)
      # Literal JSON key, not a shell variable.
      # shellcheck disable=SC2016
      edit='.["$schema"] = "https://biomejs.dev/schemas/999.0.0/schema.json"'
      ;;
    owner-options) edit='.linter.enabled = false | .javascript.formatter.quoteStyle = "single"' ;;
    dist)
      edit='.files.includes = ["**"]'
      expected='require-biome-files-exclude-dist'
      ;;
    indent)
      edit='.formatter.indentStyle = "tab"'
      expected='require-biome-formatter-indent-style'
      ;;
    branch)
      edit='.vcs.defaultBranch = "owner-branch"'
      expected='require-biome-vcs-default-branch'
      ;;
    ignore)
      edit='.vcs.useIgnoreFile = false'
      expected='require-biome-vcs-use-ignore-file'
      ;;
    esac
    {
      if [ "$extension" = jsonc ]; then printf '// Owner-managed Biome configuration\n'; fi
      jq "$edit" "$DROP_CALF_BIOME"
    } >"$biome_work/biome.$extension"
    findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^require-biome-' \
      --include-metadata --json=compact "$biome_work/biome.$extension")
    if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
      map(.ruleId) == (if $expected == "" then [] else [$expected] end) and
      all(.[]; .severity == "info" and (.metadata.tags | index("capability:biome") != null))
    ' >/dev/null; then
      printf 'Unexpected Biome %s findings for %s: expected "%s", got %s\n' \
        "$extension" "$variant" "$expected" "$findings" >&2
      exit 1
    fi
  done
done
echo "Biome JSON/JSONC defaults, owner options and advisory mutations produced the expected findings."

# Lint owns aggregate selection, not individual producer implementations or hooks.
# Apply the pinned package wiring to the older generated snapshot; never run tasks.
lint_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_lint.XXXXXX")
jq '.scripts |= (del(.["lint:check"], .["lint:forge"], .["lint:prelint"]) + {
  "lint": "run-p --npm-path npm --print-label \"lint:check:*\"",
  "check": "run-p --npm-path npm --print-label \"{lint,test,size:check,pack:check}\"",
  "lint:check:prelint": "ast-grep scan",
  "lint:check:biome": "biome lint",
  "lint:check:forge": "forge lint",
  "lint:check:format": "npm run format:check",
  "lint:check:typecheck": "npm run typecheck"
}) | del(.scripts["pack:check"])' "$DROP_CALF_PACKAGE" >"$lint_work/generated.json"
for variant in generated optional-pack explicit flags-only omitted-producer omitted-test self-lint self-check fix-lint fix-check format-check write-leaf lookalike nested; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  optional-pack) edit='.scripts["pack:check"] = "attw --pack"' ;;
  explicit)
    edit='.scripts.lint = "run-p lint:check:forge lint:check:format lint:check:prelint lint:check:typecheck lint:check:biome --print-label --npm-path npm" |
      .scripts.check = "run-p size:check lint test --print-label --npm-path npm"'
    ;;
  flags-only)
    edit='.scripts.lint = "run-p --npm-path npm --print-label"'
    expected='require-composed-lint'
    ;;
  omitted-producer)
    edit='.scripts.lint = "run-p lint:check:biome lint:check:forge lint:check:format lint:check:typecheck"'
    expected='require-composed-lint'
    ;;
  omitted-test)
    edit='.scripts.check = "run-p lint size:check"'
    expected='require-composed-check'
    ;;
  self-lint)
    edit='.scripts.lint += " lint"'
    expected='require-composed-lint'
    ;;
  self-check)
    edit='.scripts.check += " check"'
    expected='require-composed-check'
    ;;
  fix-lint)
    edit='.scripts.lint += " lint:fix"'
    expected='require-composed-lint'
    ;;
  fix-check)
    edit='.scripts.check += " lint:fix"'
    expected='require-composed-check'
    ;;
  format-check)
    edit='.scripts.check += " format"'
    expected='require-composed-check'
    ;;
  write-leaf)
    edit='.scripts["lint:check:biome"] += " --write"'
    expected='no-write-flags-in-readonly-script'
    ;;
  lookalike)
    edit='.scripts.lint = "run-p lint:check:prelint-extra lint:check:biome lint:check:forge lint:check:format lint:check:typecheck"'
    expected='require-composed-lint'
    ;;
  nested)
    edit='.config.scripts = .scripts | del(.scripts.lint)'
    expected='require-composed-lint'
    ;;
  esac
  jq "$edit" "$lint_work/generated.json" >"$lint_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^(require-composed-(lint|check)|no-write-flags-in-readonly-script)$' \
    --include-metadata --json=compact "$lint_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    map(.ruleId) == (if $expected == "" then [] else [$expected] end) and
    all(.[]; (.metadata.tags | index("capability:lint") != null) and
      .severity == (if .ruleId == "no-write-flags-in-readonly-script" then "warning" else "info" end))
  ' >/dev/null; then
    printf 'Unexpected lint aggregate findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo "Pinned lint/check selections, optional pack task and static mutations produced the expected findings."

# Changelog command checks are static; never run regeneration on these fixtures.
changelog_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_changelog.XXXXXX")
for variant in generated missing legacy; do
  expected=1
  case "$variant" in
  generated)
    edit='.'
    expected=0
    ;;
  missing) edit='del(.scripts.changelog)' ;;
  legacy) edit='.scripts.changelog = "git cliff --offline --unreleased --prepend CHANGELOG.md"' ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$changelog_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-changelog-script$' --include-metadata --json=compact "$changelog_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --argjson count "$expected" '
    type == "array" and length == $count and
    all(.[]; .ruleId == "require-changelog-script" and .severity == "info" and
      (.metadata.tags | index("capability:changelog") != null))
  ' >/dev/null; then
    printf 'Unexpected changelog findings for %s: expected %s, got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo "Generated changelog command and package mutations produced the expected findings."

# The stored generated package predates release; apply only the pinned package wiring.
# These are static inputs: never invoke the helper or any release checks.
release_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_release.XXXXXX")
jq '.scripts.release = "bash scripts/release.sh" |
  .scripts["release:check"] = "npm run test && npm run typecheck"' \
  "$DROP_CALF_PACKAGE" >"$release_work/generated.json"
for variant in generated owner-checks missing-release missing-check inert-release inert-check; do
  expected=''
  case "$variant" in
  generated) edit='.' ;;
  owner-checks) edit='.scripts["release:check"] = "npm run lint && npm run security:audit && npm run typecheck"' ;;
  missing-release)
    edit='del(.scripts.release)'
    expected='require-release-script'
    ;;
  missing-check)
    edit='del(.scripts["release:check"])'
    expected='require-release-check-script'
    ;;
  inert-release)
    edit='.scripts.release = "echo bash scripts/release.sh"'
    expected='require-release-script'
    ;;
  inert-check)
    edit='.scripts["release:check"] = "echo checks passed"'
    expected='require-release-check-script'
    ;;
  esac
  jq "$edit" "$release_work/generated.json" >"$release_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-release(-check)?-script$' --include-metadata --json=compact "$release_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    (map(.ruleId) | sort) == (if $expected == "" then [] else [$expected] end) and
    all(.[]; .severity == "info" and (.metadata.tags | index("capability:release") != null))
  ' >/dev/null; then
    printf 'Unexpected release findings for %s: expected "%s", got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
  # Advisory conventions must not turn the consumer error-only gate into a release test.
  gate=$(ast-grep scan --config sgconfig.ecosol.yml --filter '^require-release(-check)?-script$' \
    --min-severity error --json=compact "$release_work/package.json")
  printf '%s\n' "$gate" | jq -e 'type == "array" and length == 0' >/dev/null
done
echo "Pinned release package wiring and static mutations produced the expected findings."

# Node checks root engines policy, not seeded type versions or runtime selection.
node_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_node.XXXXXX")
for variant in generated refreshed-types removed-types nested-engines root-engines; do
  expected=0
  case "$variant" in
  generated) edit='.' ;;
  refreshed-types) edit='.devDependencies["@types/node"] = "^26.1.0"' ;;
  removed-types) edit='del(.devDependencies["@types/node"])' ;;
  nested-engines) edit='.config.engines = {"node": "24.x"}' ;;
  root-engines)
    edit='.engines = {"node": "24.x"}'
    expected=1
    ;;
  esac
  jq "$edit" "$DROP_CALF_PACKAGE" >"$node_work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^use-node-24$' --include-metadata --json=compact "$node_work/package.json")
  if ! printf '%s\n' "$findings" | jq -e --argjson count "$expected" '
    type == "array" and length == $count and
    all(.[]; .ruleId == "use-node-24" and .severity == "info" and
      (.metadata.tags | index("capability:node") != null))
  ' >/dev/null; then
    printf 'Unexpected Node findings for %s: expected %s informational capability findings, got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo "Generated Node package and type/engines mutations produced the expected findings."

# Runtime shape is local to an existing manifest, not platform/version agreement.
manifest_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_manifest.XXXXXX")
for variant in generated future missing-runtime malformed wrong-nesting comment whitespace empty; do
  expected=1
  case "$variant" in
  generated)
    payload='app: {runtime: {name: nodejs24.x}, id: owner-selected}'
    expected=0
    ;;
  future)
    payload='app: {runtime: {name: nodejs999999.x}}'
    expected=0
    ;;
  missing-runtime) payload='app: {id: owner-selected}' ;;
  malformed) payload='app: {runtime: {name: sandbox}}' ;;
  wrong-nesting) payload='metadata: {app: {runtime: {name: nodejs24.x}}}' ;;
  comment) payload='# owner has not declared a runtime yet' ;;
  whitespace) payload=' ' ;;
  empty)
    # Native ast-grep skips zero-byte files; no findings are not compliance.
    payload=''
    expected=0
    ;;
  esac
  printf '%s' "$payload" >"$manifest_work/manifest.yml"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-numeric-forge-runtime$' --include-metadata --json=compact "$manifest_work/manifest.yml")
  if ! printf '%s\n' "$findings" | jq -e --argjson count "$expected" '
    type == "array" and length == $count and
    all(.[]; .ruleId == "require-numeric-forge-runtime" and .severity == "info" and
      (.metadata.tags | index("capability:forge-manifest") != null))
  ' >/dev/null; then
    printf 'Unexpected runtime-shape findings for %s: expected %s, got %s\n' \
      "$variant" "$expected" "$findings" >&2
    exit 1
  fi
done
echo "Generated numeric runtime shape and manifest mutations produced the expected findings."

# OSS consumes catalog licensing; Node derives the independently checked package field.
oss_work=$(mktemp -d "$PWD/.scratch/tmp_rovo_oss.XXXXXX")
for variant in generated catalog-license package-license; do
  cp "$DROP_CALF_CATALOG" "$oss_work/catalog-info.yaml"
  cp "$DROP_CALF_PACKAGE" "$oss_work/package.json"
  expected=''
  case "$variant" in
  catalog-license)
    yq -i '.metadata.annotations."forge-ranch/license" = "MIT"' "$oss_work/catalog-info.yaml"
    expected='require-catalog-license-apache-2-0'
    ;;
  package-license)
    jq '.license = "MIT"' "$DROP_CALF_PACKAGE" >"$oss_work/package.json"
    expected='require-package-license-apache-2-0'
    ;;
  esac
  findings=$(ast-grep scan --config sgconfig.ecosol.yml \
    --filter '^require-(catalog|package)-license-apache-2-0$' \
    --json=compact "$oss_work")
  actual=$(printf '%s\n' "$findings" | jq -r '.[].ruleId' | sort)
  if [ "$actual" != "$expected" ]; then
    printf 'Unexpected OSS findings for %s: expected "%s", got "%s"\n' \
      "$variant" "$expected" "$actual" >&2
    exit 1
  fi
done
echo "Generated OSS licensing inputs and independent mutations produced the expected findings."

# Both Biome filenames must be parsed as JSON and checked by the same rule.
for path in rule-tests/fixtures/biome-invalid/biome.json rule-tests/fixtures/biome-invalid/biome.jsonc; do
  matches=$(ast-grep scan --config sgconfig.ecosol.yml \
    --rule rules/ecosol/devtools/require-biome-formatter-indent-style.yml \
    --files-with-matches "$path")
  if [ "$matches" != "$path" ]; then
    echo "Expected a Biome formatter finding in $path; got: $matches" >&2
    exit 1
  fi
done

echo "Both Biome config formats produced the expected finding."

bash scripts/check-git-hooks-fixtures.sh
bash scripts/check-docs-fixtures.sh
bash scripts/check-typescript-fixtures.sh
sh scripts/check-secrets-fixtures.sh
sh scripts/check-security-fixtures.sh
bash scripts/check-scope-fixtures.sh
bash scripts/check-page-title-fixtures.sh
