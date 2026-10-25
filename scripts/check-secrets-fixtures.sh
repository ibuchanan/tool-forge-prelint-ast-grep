#!/usr/bin/env sh
set -eu

# Static text only: never resolve SecretSpec or execute Forge/Fence Rider commands.
# Six maintained commands from Drop Calf be86d05309a32f7eef8988205208c17ca94e7a4c,
# src/capabilities/secrets.ts; the stored generated fixture predates forwarded flags.
mkdir -p .scratch
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_secrets.XXXXXX")
jq '.scripts = {
  "forge:register": "forge register",
  "forge:deploy": "cmd=$(fence-rider deploy -- --non-interactive) && sh -c \"$cmd\" sh",
  "forge:install": "cmd=$(fence-rider install -- --confirm-scopes --non-interactive) && sh -c \"$cmd\" sh",
  "forge:uninstall": "cmd=$(fence-rider uninstall) && sh -c \"$cmd\" sh",
  "forge:upgrade": "cmd=$(fence-rider install -- --upgrade --confirm-scopes --non-interactive) && sh -c \"$cmd\" sh",
  "forge:variables:set": "fence-rider variables",
  "lint:check:forge": "forge lint"
}' fixtures/drop-calf-forge-app/package.json >"$work/generated.json"
filter='^(use-forge-(register|deploy|install|uninstall|upgrade|variables-set)|use-fence-rider-for-forge-(deploy|install|uninstall|variables|lint)|require-fence-rider-script-execution|no-unguarded-fence-rider-evaluation)$'
for role in register deploy install uninstall upgrade variables-set; do
  key="forge:$role"
  [ "$role" != variables-set ] || key='forge:variables:set'
  for variant in generated missing wrong-role wrong-type nested lookalike; do
    expected="use-forge-$role"
    case "$variant" in
    generated)
      edit='.'
      expected=''
      ;;
    missing) edit='del(.scripts[$key])' ;;
    wrong-role) edit='.scripts[$key] = "npm run build"' ;;
    wrong-type) edit='.scripts[$key] = {command: .scripts[$key]}' ;;
    nested) edit='.owner = {scripts: {($key): .scripts[$key]}} | del(.scripts[$key])' ;;
    lookalike) edit='.scripts[$key] |= gsub("forge "; "forge-lookalike ") | .scripts[$key] |= gsub("fence-rider "; "fence-rider-lookalike ")' ;;
    esac
    jq --arg key "$key" "$edit" "$work/generated.json" >"$work/package.json"
    findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter "$filter" \
      --include-metadata --json=compact "$work/package.json")
    if ! printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
      (map(.ruleId) | unique | sort) == (if $expected == "" then [] else [$expected] end) and
      all(.[]; .severity == "info" and (.metadata.tags | index("capability:secrets") != null))
    ' >/dev/null; then
      printf 'Unexpected secrets findings for %s/%s: expected "%s", got %s\n' "$role" "$variant" "$expected" "$findings" >&2
      exit 1
    fi
  done
done

for variant in generator-only unguarded direct-eval direct-deploy direct-install direct-uninstall direct-variables; do
  case "$variant" in
  generator-only)
    edit='.scripts["forge:deploy"] = "fence-rider deploy -- --non-interactive"'
    expected='require-fence-rider-script-execution'
    ;;
  unguarded)
    edit='.scripts["forge:deploy"] = "cmd=$(fence-rider deploy); sh -c \"$cmd\" sh"'
    expected='no-unguarded-fence-rider-evaluation'
    ;;
  direct-eval)
    edit='.scripts["forge:deploy"] = "eval \"$(fence-rider deploy)\""'
    expected='no-unguarded-fence-rider-evaluation'
    ;;
  direct-deploy)
    edit='.scripts["forge:deploy"] = "forge deploy"'
    expected='use-fence-rider-for-forge-deploy'
    ;;
  direct-install)
    edit='.scripts["forge:install"] = "forge install"'
    expected='use-fence-rider-for-forge-install'
    ;;
  direct-uninstall)
    edit='.scripts["forge:uninstall"] = "forge uninstall"'
    expected='use-fence-rider-for-forge-uninstall'
    ;;
  direct-variables)
    edit='.scripts["forge:variables:set"] = "forge variables set"'
    expected='use-fence-rider-for-forge-variables'
    ;;
  esac
  jq "$edit" "$work/generated.json" >"$work/package.json"
  findings=$(ast-grep scan --config sgconfig.ecosol.yml --filter "$filter" \
    --include-metadata --json=compact "$work/package.json")
  printf '%s\n' "$findings" | jq -e --arg expected "$expected" '
    map(.ruleId) == [$expected] and all(.[];
      .severity == (if $expected == "no-unguarded-fence-rider-evaluation" then "warning" else "info" end) and
      (.metadata.tags | index("capability:secrets") != null))
  ' >/dev/null || {
    printf 'Unexpected secrets safety findings for %s: expected %s, got %s\n' "$variant" "$expected" "$findings" >&2
    exit 1
  }
done
printf 'Pinned six-command secrets matrix, direct lint exception and unsafe mutations produced the expected findings.\n'
