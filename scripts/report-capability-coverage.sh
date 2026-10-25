#!/usr/bin/env bash
# Read-only TSV of active tag mappings and explicit unsupported dispositions.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh || exit 2

rules=$(yq -N -o=json -I=0 '{"id": .id, "severity": .severity, "tags": (.metadata.tags // [])}' rules/*/*/*.yml | jq -s '.')
rows=$(yq -o=json authoring/policy.yml | jq -r --argjson rules "$rules" '
  . as $policy | .capabilities[] as $capability |
  [$rules[] | select(.tags | index("capability:" + $capability))] as $tagged |
  [$tagged[] | select(.severity != "off") | .id] | unique as $ids |
  (($policy."capability-coverage-gaps" // []) | index($capability)) as $gap |
  if $gap != null and ($tagged | length) > 0 then
    error("Unsupported capability has rule tags: " + $capability)
  else
    [$capability,
      (if $gap != null then "unsupported"
       elif ($ids | length) > 0 then "implemented"
       else "not-mapped" end), ($ids | join(","))] | @tsv
  end
')
printf 'capability\tstatus\trule-ids\n%s\n' "$rows"
