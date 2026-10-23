#!/usr/bin/env bash
# Read-only TSV preview. Differences are review data, never an apply operation.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/rule-metadata-env.sh || exit 2
if [[ $# == 0 ]]; then
  set -- rules/*/*/*.yml
fi
# Buffer output so a bad later document cannot leave a plausible partial report.
rows=$(
  for file in "$@"; do
    yq eval-all --exit-status --from-file authoring/checks/document.yq "$file" >/dev/null || exit 2
    yq -r --from-file authoring/checks/severity-report.yq "$file" || exit 2
  done
) || exit 2
printf 'file\tid\tprecision\timpact\tcurrent\texpected\tblocking\n%s\n' "$rows"
